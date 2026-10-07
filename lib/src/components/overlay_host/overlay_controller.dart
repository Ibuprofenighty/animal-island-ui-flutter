part of 'overlay_host.dart';

/// Returns the resource [controller] holds under [key], creating it with
/// [create] on first use.
///
/// Package-internal and not exported from the package root. The notification
/// queue keeps its per-host state here so the host remains its single owner:
/// the controller releases every resource, through [release], when its host
/// unbinds or the controller is disposed, before it closes the remaining
/// occurrences. The next use after a release creates a fresh resource.
T animalOverlayHostResource<T extends Object>(
  AnimalOverlayController controller,
  Object key, {
  required T Function() create,
  void Function(T resource)? release,
}) => controller._resource<T>(key, create, release);

// Lifecycle of one occurrence. It only moves forward: created (registered,
// not yet in the overlay) → inserted → closing (removed; its onClose is
// running) → closed. A close before insertion, an error and a host detach
// all pass through closing.
enum _EntryState { created, inserted, closing, closed }

/// Owner-bound handle to one overlay occurrence.
///
/// Only the [AnimalOverlayController] that created it can close it. Closing
/// is idempotent and runs the occurrence's `onClose` exactly once.
final class AnimalOverlayEntryHandle {
  AnimalOverlayEntryHandle._(this._owner, this._onClose);

  final AnimalOverlayController _owner;
  VoidCallback? _onClose;
  OverlayEntry? _entry;
  _EntryState _state = _EntryState.created;

  /// Whether this occurrence has finished closing: it has left the overlay
  /// and its `onClose` has returned.
  ///
  /// While `onClose` runs the occurrence is already removed but not yet
  /// closed, so this is false and every further close request is ignored.
  bool get isClosed => _state == _EntryState.closed;

  /// Closes this occurrence. Repeated calls are ignored.
  void close() => _owner.close(this);
}

/// Scoped owner of the overlay occurrences of one [AnimalOverlayHost].
///
/// The controller registers an occurrence synchronously in [show] and inserts
/// it once its host's overlay is attached, so an occurrence shown before the
/// host's first frame is neither lost nor inserted after it was closed. When
/// the host detaches, every live occurrence is closed.
///
/// A caller-supplied controller stays owned by the caller: the host never
/// disposes it, and it can be bound to only one host at a time.
class AnimalOverlayController {
  final List<AnimalOverlayEntryHandle> _live = <AnimalOverlayEntryHandle>[];
  final Map<Object, ({Object value, void Function()? release})> _resources =
      <Object, ({Object value, void Function()? release})>{};
  OverlayState? _overlay;
  bool _disposed = false;

  /// Registers an occurrence built by [builder] and inserts it when the host
  /// overlay is attached.
  ///
  /// [onClose] runs exactly once when the occurrence closes for any reason.
  /// Throws a [StateError] on a disposed controller.
  AnimalOverlayEntryHandle show({
    required Widget Function(
      BuildContext context,
      AnimalOverlayEntryHandle handle,
    )
    builder,
    VoidCallback? onClose,
  }) {
    if (_disposed) {
      throw StateError('Cannot show an overlay on a disposed controller.');
    }
    final AnimalOverlayEntryHandle handle = AnimalOverlayEntryHandle._(
      this,
      onClose,
    );
    handle._entry = OverlayEntry(
      builder: (BuildContext context) => builder(context, handle),
    );
    _live.add(handle);
    final OverlayState? overlay = _overlay;
    if (overlay != null) _insert(handle, overlay);
    return handle;
  }

  /// Closes [handle], which must belong to this controller; a handle of
  /// another controller throws an [ArgumentError] and stays untouched.
  ///
  /// Closing an occurrence that is already closing or closed is a no-op. An
  /// exception thrown by its `onClose` is reported through
  /// [FlutterError.reportError]; the occurrence is closed either way.
  void close(AnimalOverlayEntryHandle handle) {
    if (!identical(handle._owner, this)) {
      throw ArgumentError.value(
        handle,
        'handle',
        'belongs to a different AnimalOverlayController',
      );
    }
    _settle(handle);
  }

  /// Closes every occurrence that is live when the call starts.
  ///
  /// An `onClose` may show or close occurrences re-entrantly: an occurrence it
  /// shows stays open, and one failing callback never leaves the others live.
  void closeAll() {
    for (final AnimalOverlayEntryHandle handle in _live.toList()) {
      _settle(handle);
    }
  }

  /// Closes every live occurrence and rejects further use.
  ///
  /// Only the controller's owner disposes it, after its host is removed; a
  /// host disposes only the controller it created itself.
  void dispose() {
    if (_disposed) return;
    if (_overlay != null) {
      throw StateError(
        'Dispose an AnimalOverlayController only after its host is removed.',
      );
    }
    // Mark disposed first: an onClose that calls show during this
    // settlement is rejected instead of registering a new occurrence.
    _disposed = true;
    _releaseResources();
    closeAll();
  }

  void _attach(OverlayState overlay) {
    if (_disposed) {
      throw StateError('A disposed AnimalOverlayController cannot attach.');
    }
    final OverlayState? current = _overlay;
    if (identical(current, overlay)) return;
    if (current != null) {
      throw StateError(
        'This AnimalOverlayController is already bound to another '
        'AnimalOverlayHost.',
      );
    }
    _overlay = overlay;
    for (final AnimalOverlayEntryHandle handle in _live.toList()) {
      if (handle._state == _EntryState.created) _insert(handle, overlay);
    }
  }

  void _detach(OverlayState overlay) {
    final OverlayState? current = _overlay;
    if (current == null) return;
    if (!identical(current, overlay)) {
      throw StateError('Only the bound AnimalOverlayHost can detach it.');
    }
    // Unbind before settling: an occurrence shown by an onClose during this
    // detach stays created on the unbound controller instead of entering
    // a host that is going away.
    _overlay = null;
    _releaseResources();
    closeAll();
  }

  T _resource<T extends Object>(
    Object key,
    T Function() create,
    void Function(T resource)? release,
  ) {
    if (_disposed) {
      throw StateError('A disposed AnimalOverlayController has no resources.');
    }
    final existing = _resources[key];
    if (existing != null) return existing.value as T;
    final T value = create();
    _resources[key] = (
      value: value,
      release: release == null ? null : () => release(value),
    );
    return value;
  }

  void _releaseResources() {
    final releases = _resources.values.toList();
    _resources.clear();
    for (final resource in releases) {
      final void Function()? release = resource.release;
      if (release != null) {
        runOverlayCallback(release, 'releasing an overlay resource');
      }
    }
  }

  void _insert(AnimalOverlayEntryHandle handle, OverlayState overlay) {
    overlay.insert(handle._entry!);
    handle._state = _EntryState.inserted;
  }

  void _settle(AnimalOverlayEntryHandle handle) {
    if (handle._state == _EntryState.closing ||
        handle._state == _EntryState.closed) {
      return;
    }
    final bool wasInserted = handle._state == _EntryState.inserted;
    handle._state = _EntryState.closing;
    _live.remove(handle);
    final OverlayEntry entry = handle._entry!;
    handle._entry = null;
    if (wasInserted) entry.remove();
    entry.dispose();
    final VoidCallback? onClose = handle._onClose;
    handle._onClose = null;
    if (onClose != null) {
      runOverlayCallback(onClose, 'running an overlay onClose callback');
    }
    handle._state = _EntryState.closed;
  }
}
