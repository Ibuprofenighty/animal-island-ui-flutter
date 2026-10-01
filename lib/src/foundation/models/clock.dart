/// Clock abstraction for deterministic time-dependent components.
abstract interface class AnimalClock {
  DateTime now();

  Duration elapsed(DateTime since);
}

/// Default clock backed by [DateTime.now].
class SystemClock implements AnimalClock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();

  @override
  Duration elapsed(DateTime since) => DateTime.now().difference(since);
}
