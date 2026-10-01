import '../../foundation/models/time.dart';

/// Pure computation model for TimePicker wheels and steps.
class TimeWheelModel {
  static void validateStep(int step, String name) {
    if (step <= 0) {
      throw ArgumentError.value(step, name, '$name must be >= 1');
    }
  }

  /// Generates the list of valid wheel values.
  static List<int> generateItems(int maxExclusive, int step) {
    validateStep(step, 'step');
    final items = <int>[];
    for (int i = 0; i < maxExclusive; i += step) {
      items.add(i);
    }
    return items;
  }

  /// Snaps [value] to the closest valid item in [items].
  static int snapToStep(int value, List<int> items) {
    if (items.isEmpty) return value;
    if (items.contains(value)) return value;
    int closest = items.first;
    int minDiff = (value - closest).abs();
    for (final item in items) {
      final diff = (value - item).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = item;
      }
    }
    return closest;
  }

  /// Snaps a full [AnimalTimeValue] to the steps configured for hour, minute, and second.
  static AnimalTimeValue snapTimeToSteps({
    required AnimalTimeValue time,
    required int hourStep,
    required int minuteStep,
    required int secondStep,
  }) {
    final hours = generateItems(24, hourStep);
    final minutes = generateItems(60, minuteStep);
    final seconds = generateItems(60, secondStep);

    return AnimalTimeValue(
      hour: snapToStep(time.hour, hours),
      minute: snapToStep(time.minute, minutes),
      second: snapToStep(time.second, seconds),
    );
  }
}
