import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/models/clock.dart';
import 'lifecycle_observer.dart';

enum AnimalScheduledWork { decorative, functionalTime }

typedef AnimalScheduledCallback = void Function(
  DateTime wallTime,
  Duration monotonicElapsed,
);

/// Owns periodic work for one component state.
///
/// A scheduler has no process-wide registry. Component state owns its instance,
/// updates each registration's eligibility from [AnimalMotionPolicy], and
/// disposes the instance with its other resources.
class AnimalMotionScheduler {
  factory AnimalMotionScheduler({required AnimalClock clock}) =>
      AnimalMotionScheduler._(clock);

  AnimalMotionScheduler._(this._clock) {
    _lifecycleObserver = AnimalLifecycleObserver(
      onStateChanged: _handleLifecycleChange,
    )..attach();
  }

  AnimalClock _clock;
  late final AnimalLifecycleObserver _lifecycleObserver;
  final Set<AnimalMotionRegistration> _registrations =
      <AnimalMotionRegistration>{};
  bool _disposed = false;

  int get registrationCount => _registrations.length;

  int get activeRegistrationCount => _registrations
      .where((AnimalMotionRegistration task) => task.isActive)
      .length;

  bool get isForeground => _lifecycleObserver.isForeground;

  AnimalMotionRegistration schedulePeriodic({
    required Duration interval,
    required AnimalScheduledWork work,
    required bool eligible,
    required AnimalScheduledCallback onTick,
    VoidCallback? onResume,
  }) {
    if (_disposed) throw StateError('motion scheduler is disposed');
    if (interval.isNegative) {
      throw ArgumentError.value(interval, 'interval', 'must not be negative');
    }
    return AnimalMotionRegistration._(
      this,
      interval,
      work,
      eligible,
      onTick,
      onResume,
    );
  }

  /// Rebinds existing tasks to a replacement clock without duplicating them.
  void updateClock(AnimalClock clock) {
    if (_disposed) throw StateError('motion scheduler is disposed');
    if (identical(_clock, clock)) return;
    _clock = clock;
    for (final AnimalMotionRegistration task in _registrations.toList(
      growable: false,
    )) {
      task._clockReplaced();
    }
  }

  void _handleLifecycleChange(AppLifecycleState _) {
    for (final AnimalMotionRegistration task in _registrations.toList(
      growable: false,
    )) {
      task._lifecycleChanged();
    }
  }

  void _remove(AnimalMotionRegistration task) {
    _registrations.remove(task);
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _lifecycleObserver.detach();
    for (final AnimalMotionRegistration task in _registrations.toList(
      growable: false,
    )) {
      task.dispose();
    }
  }
}

class AnimalMotionRegistration {
  AnimalMotionRegistration._(
    this._scheduler,
    this._interval,
    this._work,
    this._eligible,
    this._onTick,
    this._onResume,
  ) {
    _scheduler._registrations.add(this);
    _reconcile(resuming: false);
  }

  final AnimalMotionScheduler _scheduler;
  Duration _interval;
  final AnimalScheduledWork _work;
  final AnimalScheduledCallback _onTick;
  final VoidCallback? _onResume;
  Timer? _timer;
  Duration? _lastMonotonic;
  bool _eligible;
  bool _hasStarted = false;
  bool _waitingForForeground = false;
  bool _disposed = false;

  bool get isActive => _timer != null;

  void setEligible(bool eligible) {
    if (_disposed) throw StateError('motion registration is disposed');
    if (_eligible == eligible) return;
    _eligible = eligible;
    _reconcile(resuming: eligible);
  }

  /// Replaces the interval and restarts the cadence once, if currently active.
  void updateInterval(Duration interval) {
    if (_disposed) throw StateError('motion registration is disposed');
    if (interval.isNegative) {
      throw ArgumentError.value(interval, 'interval', 'must not be negative');
    }
    if (_interval == interval) return;
    _interval = interval;
    _pause();
    _reconcile(resuming: _hasStarted);
  }

  void _lifecycleChanged() => _reconcile(
    resuming: _scheduler.isForeground && (_hasStarted || _waitingForForeground),
  );

  void _clockReplaced() {
    final bool wasActive = isActive;
    _pause();
    _reconcile(resuming: wasActive && _hasStarted);
  }

  void _reconcile({required bool resuming}) {
    final bool shouldRun =
        !_disposed &&
        !_scheduler._disposed &&
        _eligible &&
        _scheduler.isForeground;
    if (!shouldRun) {
      if (_eligible && !_scheduler.isForeground) {
        _waitingForForeground = true;
      }
      _pause();
      return;
    }
    if (_timer != null) return;

    _lastMonotonic = _scheduler._clock.monotonicNow;
    _timer = Timer.periodic(_interval, (_) => _handleTick());
    final bool resumedExistingTask = resuming;
    _hasStarted = true;
    _waitingForForeground = false;
    if (resumedExistingTask && _work == AnimalScheduledWork.functionalTime) {
      _onResume?.call();
    }
  }

  void _handleTick() {
    if (!isActive || _disposed || _scheduler._disposed) return;
    final Duration monotonicNow = _scheduler._clock.monotonicNow;
    final Duration previous = _lastMonotonic ?? monotonicNow;
    final Duration elapsed = monotonicNow - previous;
    if (elapsed.isNegative) {
      throw StateError('AnimalClock.monotonicNow moved backwards');
    }
    _lastMonotonic = monotonicNow;
    _onTick(_scheduler._clock.now(), elapsed);
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    _lastMonotonic = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _pause();
    _scheduler._remove(this);
  }
}

/// Resolves shared motion and readout eligibility from framework signals and
/// component-local focus, hover, and visibility state.
abstract final class AnimalMotionPolicy {
  /// Context-local eligibility used by a component-owned scheduler.
  ///
  /// App foreground state is owned by [AnimalMotionScheduler], so it is not
  /// cached here. This lets a task mounted while the app is backgrounded start
  /// when the lifecycle observer reports resume.
  static bool decorativeContextEligible(
    BuildContext context, {
    bool focused = false,
    bool hovered = false,
    bool visible = true,
  }) {
    final bool reducedMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return visible &&
        !focused &&
        !hovered &&
        !reducedMotion &&
        TickerMode.valuesOf(context).enabled;
  }

  /// Context-local eligibility for functional wall-clock readouts.
  static bool functionalTimeContextEligible(
    BuildContext context, {
    bool visible = true,
  }) => visible && TickerMode.valuesOf(context).enabled;

  static bool shouldAnimate(
    BuildContext context, {
    bool focused = false,
    bool hovered = false,
    bool visible = true,
  }) {
    final AppLifecycleState? lifecycleState =
        WidgetsBinding.instance.lifecycleState;
    final bool foreground =
        lifecycleState == null || lifecycleState == AppLifecycleState.resumed;
    return foreground &&
        decorativeContextEligible(
          context,
          focused: focused,
          hovered: hovered,
          visible: visible,
        );
  }
}
