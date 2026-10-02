/// Clock abstraction for deterministic time-dependent components.
abstract interface class AnimalClock {
  DateTime now();

  /// A process-local monotonic reading for measuring elapsed time.
  ///
  /// This value is independent of [now] and must never move backwards.
  Duration get monotonicNow;
}

/// Default clock backed by [DateTime.now].
class SystemClock implements AnimalClock {
  const SystemClock();

  static final Stopwatch _monotonic = Stopwatch()..start();

  @override
  DateTime now() => DateTime.now();

  @override
  Duration get monotonicNow => _monotonic.elapsed;
}
