import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../internal/overlay/overlay_callback.dart';
import '../overlay_host/overlay_host.dart'
    show AnimalOverlayController, AnimalOverlayEntryHandle;
import 'notification_model.dart';

/// Builds the widget that renders one placement lane in the host overlay.
typedef AnimalNotificationLaneBuilder = Widget Function(
  AnimalNotificationLane lane,
);

/// One notification occurrence of a placement lane.
///
/// Its business [key] may repeat across occurrences; the occurrence itself is
/// never reused. Every transition is synchronous, so registering, updating and
/// closing never wait for a frame or a mounted widget.
final class AnimalNotificationOccurrence extends AnimalNotificationHandle {
  AnimalNotificationOccurrence._(
    this._lane,
    this.key,
    this._config,
    this._onClose,
    this._status,
  ) : _remaining = _config.duration;

  final AnimalNotificationLane _lane;

  /// Business key; a live occurrence with this key is updated in place.
  final String? key;

  AnimalNotificationConfig _config;
  VoidCallback? _onClose;
  AnimalNotificationStatus _status;
  Timer? _timer;
  Duration? _remaining;
  final Stopwatch _elapsed = Stopwatch();
  bool _paused = false;

  AnimalNotificationConfig get config => _config;

  @override
  AnimalNotificationStatus get status => _status;

  @override
  void close() => _lane._settle(<AnimalNotificationOccurrence>[this]);

  /// Pauses the duration timer while [paused]; resuming continues with the
  /// time that was left.
  void setPaused(bool paused) {
    if (_paused == paused) return;
    _paused = paused;
    if (paused) {
      final Timer? timer = _timer;
      final Duration? remaining = _remaining;
      if (timer == null || remaining == null) return;
      timer.cancel();
      _timer = null;
      final Duration left = remaining - _elapsed.elapsed;
      _remaining = left < Duration.zero ? Duration.zero : left;
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _cancelTimer();
    final Duration? remaining = _remaining;
    if (remaining == null ||
        _paused ||
        _status != AnimalNotificationStatus.active) {
      return;
    }
    _elapsed
      ..reset()
      ..start();
    _timer = Timer(remaining, close);
  }

  void _restartTimer() {
    _remaining = _config.duration;
    _startTimer();
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _elapsed.stop();
  }
}

/// The synchronous queue of one placement in one host.
///
/// At most [maxActive] occurrences are shown and [maxWaiting] wait behind
/// them. A new occurrence beyond that is rejected; an older one is never
/// dropped to make room.
class AnimalNotificationLane extends ChangeNotifier {
  AnimalNotificationLane._(this.placement, this._onChanged);

  /// Most occurrences shown at once per placement.
  static const int maxActive = 3;

  /// Most occurrences waiting behind the shown ones per placement.
  static const int maxWaiting = 50;

  final AnimalNotificationPlacement placement;
  final void Function(AnimalNotificationLane lane) _onChanged;
  final List<AnimalNotificationOccurrence> _active =
      <AnimalNotificationOccurrence>[];
  final List<AnimalNotificationOccurrence> _waiting =
      <AnimalNotificationOccurrence>[];
  AnimalOverlayEntryHandle? _container;

  /// The shown occurrences, oldest first.
  List<AnimalNotificationOccurrence> get active =>
      List<AnimalNotificationOccurrence>.unmodifiable(_active);

  bool get _isEmpty => _active.isEmpty && _waiting.isEmpty;

  AnimalNotificationOccurrence _open(
    AnimalNotificationConfig config,
    String? key,
    VoidCallback? onClose,
  ) {
    if (key != null) {
      for (final AnimalNotificationOccurrence live
          in <AnimalNotificationOccurrence>[..._active, ..._waiting]) {
        if (live.key != key) continue;
        live._config = config;
        live._onClose = onClose;
        live._restartTimer();
        _changed();
        return live;
      }
    }
    final AnimalNotificationStatus status;
    if (_active.length < maxActive) {
      status = AnimalNotificationStatus.active;
    } else if (_waiting.length < maxWaiting) {
      status = AnimalNotificationStatus.waiting;
    } else {
      return AnimalNotificationOccurrence._(
        this,
        key,
        config,
        onClose,
        AnimalNotificationStatus.rejected,
      );
    }
    final AnimalNotificationOccurrence occurrence =
        AnimalNotificationOccurrence._(this, key, config, onClose, status);
    if (status == AnimalNotificationStatus.active) {
      _active.add(occurrence);
      occurrence._startTimer();
    } else {
      _waiting.add(occurrence);
    }
    _changed();
    return occurrence;
  }

  // The single settlement of occurrences: every close path (close button,
  // swipe, handle, closeAll, timeout, host release) ends here. The status
  // check runs each onClose exactly once; the lane changes once per batch,
  // before any onClose runs.
  void _settle(List<AnimalNotificationOccurrence> occurrences) {
    final List<AnimalNotificationOccurrence> settled =
        <AnimalNotificationOccurrence>[];
    for (final AnimalNotificationOccurrence occurrence in occurrences) {
      final AnimalNotificationStatus status = occurrence._status;
      if (status == AnimalNotificationStatus.closed ||
          status == AnimalNotificationStatus.rejected) {
        continue;
      }
      occurrence._status = AnimalNotificationStatus.closed;
      occurrence._cancelTimer();
      if (status == AnimalNotificationStatus.active) {
        _active.remove(occurrence);
      } else {
        _waiting.remove(occurrence);
      }
      settled.add(occurrence);
    }
    if (settled.isEmpty) return;
    _promote();
    _changed();
    for (final AnimalNotificationOccurrence occurrence in settled) {
      final VoidCallback? onClose = occurrence._onClose;
      if (onClose != null) {
        runOverlayCallback(
          onClose,
          'running an AnimalNotification onClose callback',
        );
      }
    }
  }

  void _promote() {
    while (_active.length < maxActive && _waiting.isNotEmpty) {
      final AnimalNotificationOccurrence next = _waiting.removeAt(0);
      next._status = AnimalNotificationStatus.active;
      _active.add(next);
      next._startTimer();
    }
  }

  /// Closes the occurrences present now; ones opened by an onClose survive.
  void _closeAll() =>
      _settle(<AnimalNotificationOccurrence>[..._waiting, ..._active]);

  void _changed() {
    _onChanged(this);
    notifyListeners();
  }
}

/// The notification queues of one overlay host, one lane per placement.
///
/// `AnimalNotification` keeps it as a host resource: the host's controller
/// owns it and calls [closeAll] when the host unbinds, which closes every
/// queued occurrence once. Each non-empty lane is rendered by exactly one
/// host occurrence, shown when the lane gets its first item and closed when
/// it empties.
class AnimalNotificationQueue {
  AnimalNotificationQueue(this._controller, this._buildLane);

  final AnimalOverlayController _controller;

  /// Renders one lane inside the lane's host occurrence.
  final AnimalNotificationLaneBuilder _buildLane;
  final Map<AnimalNotificationPlacement, AnimalNotificationLane> _lanes =
      <AnimalNotificationPlacement, AnimalNotificationLane>{};

  /// Opens or updates an occurrence; see `AnimalNotification.open`.
  AnimalNotificationHandle open(
    AnimalNotificationConfig config, {
    String? key,
    VoidCallback? onClose,
  }) => _laneFor(config.placement)._open(config, key, onClose);

  /// Closes the occurrences of [placement], or of every placement.
  void closeAll({AnimalNotificationPlacement? placement}) {
    for (final AnimalNotificationLane lane in _lanes.values.toList()) {
      if (placement == null || lane.placement == placement) lane._closeAll();
    }
  }

  AnimalNotificationLane _laneFor(AnimalNotificationPlacement placement) {
    final AnimalNotificationLane? existing = _lanes[placement];
    if (existing != null) return existing;
    final AnimalNotificationLane lane = AnimalNotificationLane._(
      placement,
      _sync,
    );
    _lanes[placement] = lane;
    return lane;
  }

  // Keeps exactly one host occurrence per non-empty lane.
  void _sync(AnimalNotificationLane lane) {
    final AnimalOverlayEntryHandle? container = lane._container;
    if (lane._isEmpty) {
      lane._container = null;
      container?.close();
    } else if (container == null) {
      lane._container = _controller.show(
        builder: (_, _) => _buildLane(lane),
        onClose: () => _containerClosed(lane),
      );
    }
  }

  // The lane's host occurrence closed. When something other than the lane
  // emptying closed it, its occurrences close with it.
  void _containerClosed(AnimalNotificationLane lane) {
    lane._container = null;
    lane._closeAll();
  }
}
