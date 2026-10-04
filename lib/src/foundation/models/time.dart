import 'package:flutter/material.dart';

import 'clock.dart';

/// An immutable representation of a wall clock time (hour, minute, second).
@immutable
class AnimalTimeValue implements Comparable<AnimalTimeValue> {
  final int hour;
  final int minute;
  final int second;

  AnimalTimeValue({required this.hour, required this.minute, this.second = 0}) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'Hour must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError.value(
        minute,
        'minute',
        'Minute must be between 0 and 59',
      );
    }
    if (second < 0 || second > 59) {
      throw ArgumentError.value(
        second,
        'second',
        'Second must be between 0 and 59',
      );
    }
  }

  /// Creates a copy of this [AnimalTimeValue] with replaced values.
  AnimalTimeValue copyWith({int? hour, int? minute, int? second}) {
    return AnimalTimeValue(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
    );
  }

  /// The current wall-clock time of day according to [clock].
  factory AnimalTimeValue.now({AnimalClock clock = const SystemClock()}) {
    final now = clock.now();
    return AnimalTimeValue(
      hour: now.hour,
      minute: now.minute,
      second: now.second,
    );
  }

  /// Creates an [AnimalTimeValue] from a standard Flutter [TimeOfDay].
  factory AnimalTimeValue.fromTimeOfDay(TimeOfDay tod, [int second = 0]) =>
      AnimalTimeValue(hour: tod.hour, minute: tod.minute, second: second);

  /// Converts this time value to a Flutter [TimeOfDay].
  TimeOfDay toTimeOfDay() => TimeOfDay(hour: hour, minute: minute);

  /// Formats this time value as `HH:mm:ss` or `HH:mm` if [includeSeconds] is false.
  String format({bool includeSeconds = true}) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    if (!includeSeconds) return '$h:$m';
    final s = second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  int compareTo(AnimalTimeValue other) {
    if (hour != other.hour) return hour.compareTo(other.hour);
    if (minute != other.minute) return minute.compareTo(other.minute);
    return second.compareTo(other.second);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTimeValue &&
          runtimeType == other.runtimeType &&
          hour == other.hour &&
          minute == other.minute &&
          second == other.second;

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() => format();
}
