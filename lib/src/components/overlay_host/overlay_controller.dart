import 'dart:async';

import 'package:flutter/widgets.dart';

/// Lifecycle state machine for an overlay entry in Animal Island UI.
enum AnimalOverlayEntryState { created, inserting, active, closing, disposed }

/// Handle to an active overlay entry, allowing controlled dismissal and lifecycle tracking.
class AnimalOverlayEntryHandle {
  final String id;
  final VoidCallback _onCloseRequest;
  AnimalOverlayEntryState _state = AnimalOverlayEntryState.created;
  VoidCallback? _onDisposed;

  AnimalOverlayEntryHandle._({
    required this.id,
    required this._onCloseRequest,
    this._onDisposed,
  });

  AnimalOverlayEntryState get state => _state;
  bool get isActive => _state == AnimalOverlayEntryState.active;
  bool get isClosing => _state == AnimalOverlayEntryState.closing;
  bool get isDisposed => _state == AnimalOverlayEntryState.disposed;

  /// Requests the overlay entry to dismiss and play its exit transition.
  void close() {
    if (_state == AnimalOverlayEntryState.active ||
        _state == AnimalOverlayEntryState.inserting) {
      _state = AnimalOverlayEntryState.closing;
      _onCloseRequest();
    }
  }

  void _markDisposed() {
    if (_state != AnimalOverlayEntryState.disposed) {
      _state = AnimalOverlayEntryState.disposed;
      _onDisposed?.call();
      _onDisposed = null;
    }
  }
}

/// Scoped controller managing overlay resources, entries, and queues for a specific [AnimalOverlayHost].
///
/// Prevents cross-app interference and static singleton leaks (resolving F07 and F14).
class AnimalOverlayController {
  OverlayState? _overlayState;
  final Map<String, AnimalOverlayEntryHandle> _activeHandles = {};
  final Map<String, OverlayEntry> _overlayEntries = {};
  final Map<String, Timer> _entryTimers = {};
  bool _disposed = false;

  bool get isDisposed => _disposed;
  int get activeCount => _activeHandles.length;
  List<AnimalOverlayEntryHandle> get activeHandles =>
      _activeHandles.values.toList();

  void attachOverlay(OverlayState state) {
    _overlayState = state;
  }

  void detachOverlay() {
    _overlayState = null;
  }

  /// Shows a custom overlay entry managed by this host.
  ///
  /// [id]: Unique identifier for the entry. If an entry with the same [id] already exists,
  /// it is updated or replaced cleanly.
  /// [duration]: Optional auto-dismiss duration.
  /// [onClose]: Callback executed exactly once when this entry is fully removed/disposed.
  AnimalOverlayEntryHandle show({
    required String id,
    required Widget Function(
      BuildContext context,
      AnimalOverlayEntryHandle handle,
    )
    builder,
    Duration? duration,
    VoidCallback? onClose,
  }) {
    if (_disposed) {
      throw StateError(
        'Cannot show overlay on a disposed AnimalOverlayController',
      );
    }

    // Dismiss existing entry with the same ID if present
    if (_activeHandles.containsKey(id)) {
      close(id);
    }

    late final AnimalOverlayEntryHandle handle;
    late final OverlayEntry entry;

    handle = AnimalOverlayEntryHandle._(
      id: id,
      onCloseRequest: () => _removeEntry(id),
      onDisposed: onClose,
    );

    entry = OverlayEntry(builder: (context) => builder(context, handle));

    _activeHandles[id] = handle;
    _overlayEntries[id] = entry;

    if (_overlayState != null) {
      handle._state = AnimalOverlayEntryState.inserting;
      _overlayState!.insert(entry);
      handle._state = AnimalOverlayEntryState.active;
    }

    if (duration != null && duration > Duration.zero) {
      _entryTimers[id] = Timer(duration, () {
        if (!handle.isDisposed) {
          handle.close();
        }
      });
    }

    return handle;
  }

  /// Closes the entry with [id] if active.
  void close(String id) {
    final handle = _activeHandles[id];
    handle?.close();
  }

  /// Closes all active entries managed by this controller.
  void closeAll() {
    final ids = _activeHandles.keys.toList();
    for (final id in ids) {
      close(id);
    }
  }

  void _removeEntry(String id) {
    _entryTimers.remove(id)?.cancel();
    final entry = _overlayEntries.remove(id);
    final handle = _activeHandles.remove(id);

    if (entry != null) {
      try {
        entry.remove();
      } catch (_) {
        // OverlayEntry may already be removed if parent overlay unmounted
      }
      entry.dispose();
    }

    handle?._markDisposed();
  }

  /// Disposes this controller and tears down all active overlay entries safely.
  void dispose() {
    if (_disposed) return;
    _disposed = true;

    for (final timer in _entryTimers.values) {
      timer.cancel();
    }
    _entryTimers.clear();

    for (final entry in _overlayEntries.values) {
      try {
        entry.remove();
      } catch (_) {}
      entry.dispose();
    }
    _overlayEntries.clear();

    for (final handle in _activeHandles.values) {
      handle._markDisposed();
    }
    _activeHandles.clear();
    _overlayState = null;
  }
}
