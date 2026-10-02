import 'package:animal_island_ui/animal_island_ui.dart';

/// Controllable clock for deterministic tests without artificial async delays.
class FakeClock implements AnimalClock {
  DateTime _current;
  Duration _monotonic = Duration.zero;

  FakeClock([DateTime? initial])
    : _current = initial ?? DateTime(2026, 1, 1, 12, 0, 0);

  @override
  DateTime now() => _current;

  @override
  Duration get monotonicNow => _monotonic;

  void advance(Duration duration) {
    advanceWall(duration);
    advanceMonotonic(duration);
  }

  void advanceWall(Duration duration) {
    _current = _current.add(duration);
  }

  void advanceMonotonic(Duration duration) {
    _monotonic += duration;
  }

  void setTime(DateTime time) {
    _current = time;
  }
}
