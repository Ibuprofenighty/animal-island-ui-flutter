import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/models/clock.dart';
import 'lifecycle_observer.dart';

/// Called on each periodic tick with the monotonic time elapsed since the
/// previous tick, or since the task last started.
typedef AnimalScheduledCallback = void Function(Duration monotonicElapsed);

/// Owns the timed work of one component state.
///
/// A scheduler has no process-wide registry. Component state owns its
/// instance, updates each registration's eligibility from
/// [AnimalMotionPolicy], and disposes the instance with its other resources.
///
/// Every registration except a deadline runs only while it is eligible and the
/// app is in the foreground (resumed, or its lifecycle state is not yet
/// known). Starting again never catches up the ticks it missed.
class AnimalMotionScheduler {
  /// Creates a scheduler driven by [clock] that observes the app lifecycle
  /// until [dispose].
  factory AnimalMotionScheduler({AnimalClock clock = const SystemClock()}) =>
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
  VoidCallback? _onPolicyChanged;
  int _policyRevision = 0;
  int _clockRevision = 0;
  bool _disposed = false;

  /// Registers decorative [onTick] work to run every [interval].
  ///
  /// Throws a [StateError] after [dispose] and an [ArgumentError] for an
  /// interval that is not positive.
  AnimalPeriodicRegistration schedulePeriodic({
    required Duration interval,
    required bool eligible,
    required AnimalScheduledCallback onTick,
  }) => _attach(() {
    _checkInterval(interval);
    return AnimalPeriodicRegistration._(this, eligible, interval, onTick);
  });

  /// Registers [controller] as a repeating decorative animation.
  ///
  /// The controller starts at [restValue]. While running it repeats over its
  /// current duration, and when it stops it returns to [restValue]; call
  /// [AnimalMotionRegistration.restart] after changing the duration. The
  /// component state still owns and disposes the controller. Throws a
  /// [StateError] after [dispose].
  AnimalMotionRegistration scheduleAnimation(
    AnimationController controller, {
    required bool eligible,
    double restValue = 0,
  }) => _attach(
    () => _AnimationRegistration(this, eligible, controller, restValue),
  );

  /// Registers a functional readout, such as a clock face.
  ///
  /// While running, [onReadout] runs after each delay returned by
  /// [nextReadout]; a null delay ends the readouts until the task starts
  /// again. [onReadout] also runs when the app returns to the foreground. A
  /// start through [AnimalMotionRegistration.setEligible] or
  /// [AnimalMotionRegistration.restart] only schedules the next readout,
  /// because the component refreshes its own state in that same call. Throws
  /// a [StateError] after [dispose].
  AnimalMotionRegistration scheduleReadout({
    required bool eligible,
    required Duration? Function() nextReadout,
    required VoidCallback onReadout,
  }) => _attach(
    () => _ReadoutRegistration(this, eligible, nextReadout, onReadout),
  );

  /// Registers a functional deadline that calls [onDue] once when [remaining]
  /// is no longer positive.
  ///
  /// Unlike the other registrations, a deadline also runs while the app is in
  /// the background. A timer that fires before [remaining] reaches zero waits
  /// again for the rest. Throws a [StateError] after [dispose].
  AnimalMotionRegistration scheduleDeadline({
    required bool eligible,
    required Duration Function() remaining,
    required VoidCallback onDue,
  }) => _attach(() => _DeadlineRegistration(this, eligible, remaining, onDue));

  /// Replaces the clock and restarts every running registration once, without
  /// duplicating it. Throws a [StateError] after [dispose].
  void updateClock(AnimalClock clock) {
    _checkLive();
    if (identical(_clock, clock)) return;
    _clock = clock;
    final revision = ++_clockRevision;
    for (final AnimalMotionRegistration task in _registrations.toList(
      growable: false,
    )) {
      if (revision != _clockRevision) return;
      if (!task._disposed) task.restart();
    }
  }

  /// Stops observing the lifecycle and disposes every registration.
  /// Repeated calls do nothing.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _policyRevision++;
    _clockRevision++;
    _onPolicyChanged = null;
    _lifecycleObserver.detach();
    for (final AnimalMotionRegistration task in _registrations.toList(
      growable: false,
    )) {
      task.dispose();
    }
  }

  T _attach<T extends AnimalMotionRegistration>(T Function() create) {
    _checkLive();
    final T task = create();
    if (_disposed) {
      task.dispose();
      return task;
    }
    _registrations.add(task);
    task._reconcile(resumed: false);
    return task;
  }

  void _checkLive() {
    if (_disposed) throw StateError('motion scheduler is disposed');
  }

  static void _checkInterval(Duration interval) {
    if (interval <= Duration.zero) {
      throw ArgumentError.value(interval, 'interval', 'must be positive');
    }
  }

  void _handleLifecycleChange(AppLifecycleState _) {
    final revision = ++_policyRevision;
    for (final AnimalMotionRegistration task in _registrations.toList(
      growable: false,
    )) {
      task._reconcile(resumed: true);
    }
    if (revision != _policyRevision) return;
    if (WidgetsBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (revision == _policyRevision) _onPolicyChanged?.call();
      });
    } else {
      _onPolicyChanged?.call();
    }
  }
}

/// Package-internal notification for native one-shot transition owners.
/// The scheduler keeps the sole lifecycle observer and clears the listener
/// before disposing its registered work. Notifications follow registration
/// reconciliation; during build or layout they coalesce after the frame.
/// Replacement, disposal or a newer policy change cancels pending delivery.
extension MotionSchedulerPolicyChanges on AnimalMotionScheduler {
  /// Replaces the owner's listener. New listeners after disposal throw
  /// StateError; removing a listener is idempotent, including after disposal.
  void setPolicyChangedListener(VoidCallback? listener) {
    if (listener != null) _checkLive();
    _policyRevision++;
    _onPolicyChanged = listener;
  }
}

/// One task of an [AnimalMotionScheduler], owned by the component state that
/// created it.
sealed class AnimalMotionRegistration {
  AnimalMotionRegistration._(this._scheduler, this._eligible);

  final AnimalMotionScheduler _scheduler;
  bool _eligible;
  bool _running = false;
  bool _disposed = false;
  int _workRevision = 0;

  /// Whether the task stops while the app is in the background.
  bool get _followsLifecycle => true;

  /// Updates whether the task may run. Throws a [StateError] after [dispose].
  void setEligible(bool eligible) {
    _checkLive();
    if (_eligible == eligible) return;
    _eligible = eligible;
    _reconcile(resumed: false);
  }

  /// Restarts the task if it is running, reading its timing again. Throws a
  /// [StateError] after [dispose].
  void restart() {
    _checkLive();
    if (!_running) return;
    final revision = ++_workRevision;
    _stop();
    if (revision != _workRevision) return;
    _start(resumed: false);
  }

  /// Stops the task and removes it from its scheduler. Repeated calls do
  /// nothing.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _workRevision++;
    if (_running) {
      _running = false;
      _stop(disposing: true);
    }
    _scheduler._registrations.remove(this);
  }

  void _checkLive() {
    if (_disposed) throw StateError('motion registration is disposed');
  }

  void _reconcile({required bool resumed}) {
    final bool shouldRun =
        !_disposed &&
        _eligible &&
        (!_followsLifecycle || _scheduler._lifecycleObserver.isForeground);
    if (shouldRun == _running) return;
    _running = shouldRun;
    _workRevision++;
    if (shouldRun) {
      _start(resumed: resumed);
    } else {
      _stop();
    }
  }

  /// Starts the work; [resumed] is true when the app returned to the
  /// foreground.
  void _start({required bool resumed});

  void _stop({bool disposing = false});
}

/// A decorative periodic task of an [AnimalMotionScheduler].
final class AnimalPeriodicRegistration extends AnimalMotionRegistration {
  AnimalPeriodicRegistration._(
    super._scheduler,
    super._eligible,
    this._interval,
    this._onTick,
  ) : super._();

  Duration _interval;
  final AnimalScheduledCallback _onTick;
  Timer? _timer;
  late Duration _lastMonotonic;

  /// Replaces the interval and restarts the cadence once, if running.
  ///
  /// Throws a [StateError] after [dispose] and an [ArgumentError] for an
  /// interval that is not positive.
  void updateInterval(Duration interval) {
    _checkLive();
    AnimalMotionScheduler._checkInterval(interval);
    if (_interval == interval) return;
    _interval = interval;
    restart();
  }

  @override
  void _start({required bool resumed}) {
    final revision = _workRevision;
    final now = _scheduler._clock.monotonicNow;
    if (revision != _workRevision) return;
    _lastMonotonic = now;
    _timer = Timer.periodic(_interval, (_) => _tick());
  }

  void _tick() {
    final revision = _workRevision;
    final Duration now = _scheduler._clock.monotonicNow;
    if (revision != _workRevision) return;
    final Duration elapsed = now - _lastMonotonic;
    if (elapsed.isNegative) {
      throw StateError('AnimalClock.monotonicNow moved backwards');
    }
    _lastMonotonic = now;
    _onTick(elapsed);
  }

  @override
  void _stop({bool disposing = false}) {
    _timer?.cancel();
    _timer = null;
  }
}

final class _AnimationRegistration extends AnimalMotionRegistration {
  _AnimationRegistration(
    super._scheduler,
    super._eligible,
    this._controller,
    this._restValue,
  ) : super._() {
    _controller.value = _restValue;
  }

  final AnimationController _controller;
  final double _restValue;

  @override
  void _start({required bool resumed}) {
    _controller.repeat();
  }

  @override
  void _stop({bool disposing = false}) {
    _controller.stop();
    if (!disposing) _controller.value = _restValue;
  }
}

final class _ReadoutRegistration extends AnimalMotionRegistration {
  _ReadoutRegistration(
    super._scheduler,
    super._eligible,
    this._nextReadout,
    this._onReadout,
  ) : super._();

  final Duration? Function() _nextReadout;
  final VoidCallback _onReadout;
  Timer? _timer;

  @override
  void _start({required bool resumed}) {
    if (resumed) {
      final revision = _workRevision;
      _onReadout();
      // The readout may have stopped or restarted this task.
      if (revision != _workRevision) return;
    }
    _arm();
  }

  void _arm() {
    final revision = _workRevision;
    final Duration? delay = _nextReadout();
    if (revision != _workRevision || delay == null) return;
    _timer = Timer(delay.isNegative ? Duration.zero : delay, _fire);
  }

  void _fire() {
    final revision = _workRevision;
    _timer = null;
    _onReadout();
    if (revision == _workRevision) _arm();
  }

  @override
  void _stop({bool disposing = false}) {
    _timer?.cancel();
    _timer = null;
  }
}

final class _DeadlineRegistration extends AnimalMotionRegistration {
  _DeadlineRegistration(
    super._scheduler,
    super._eligible,
    this._remaining,
    this._onDue,
  ) : super._();

  final Duration Function() _remaining;
  final VoidCallback _onDue;
  Timer? _timer;

  @override
  bool get _followsLifecycle => false;

  @override
  void _start({required bool resumed}) => _arm();

  void _arm() {
    final revision = _workRevision;
    final Duration remaining = _remaining();
    if (revision != _workRevision) return;
    _timer = Timer(remaining.isNegative ? Duration.zero : remaining, _fire);
  }

  void _fire() {
    final revision = _workRevision;
    _timer = null;
    final remaining = _remaining();
    if (revision != _workRevision) return;
    if (remaining > Duration.zero) {
      _arm();
      return;
    }
    _onDue();
  }

  @override
  void _stop({bool disposing = false}) {
    _timer?.cancel();
    _timer = null;
  }
}

/// Resolves shared motion and readout eligibility from framework signals and
/// component-local focus, hover, and visibility state.
abstract final class AnimalMotionPolicy {
  /// Whether the platform or the app asks for reduced motion.
  static bool reducesMotion(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Context-local eligibility used by a component-owned scheduler.
  ///
  /// App foreground state is owned by [AnimalMotionScheduler], so it is not
  /// read here. This lets a task mounted while the app is backgrounded start
  /// when the lifecycle observer reports resume.
  static bool decorativeContextEligible(
    BuildContext context, {
    bool focused = false,
    bool hovered = false,
    bool visible = true,
  }) =>
      visible &&
      !focused &&
      !hovered &&
      !reducesMotion(context) &&
      TickerMode.valuesOf(context).enabled;

  /// Context-local eligibility for functional wall-clock readouts.
  static bool functionalTimeContextEligible(
    BuildContext context, {
    bool visible = true,
  }) => visible && TickerMode.valuesOf(context).enabled;

  /// Whether a one-shot transition should animate now: the app is resumed (or
  /// its state is unknown) and [decorativeContextEligible] holds. Repeating
  /// motion uses [AnimalMotionScheduler.scheduleAnimation] instead, which
  /// follows later lifecycle changes.
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
