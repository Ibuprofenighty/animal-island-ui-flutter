import 'package:flutter/foundation.dart';

import 'clock.dart';

/// An immutable representation of a wall clock time (hour, minute, second).
@immutable
class AnimalTimeValue implements Comparable<AnimalTimeValue> {
  /// Hour of the day, from 0 to 23.
  final int hour;

  /// Minute of the hour, from 0 to 59.
  final int minute;

  /// Second of the minute, from 0 to 59.
  final int second;

  /// Creates a time of day; [second] defaults to 0.
  ///
  /// Throws an [ArgumentError] when a component is out of range.
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
