import 'package:animal_island_ui/animal_island_ui.dart';

/// Controllable clock for deterministic tests without artificial async delays.
class FakeClock implements AnimalClock {
  DateTime _current;

  FakeClock([DateTime? initial])
    : _current = initial ?? DateTime(2026, 1, 1, 12, 0, 0);

  @override
  DateTime now() => _current;

  @override
  Duration elapsed(DateTime since) => _current.difference(since);

  void advance(Duration duration) {
    _current = _current.add(duration);
  }

  void setTime(DateTime time) {
    _current = time;
  }
}
