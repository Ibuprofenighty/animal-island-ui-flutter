import 'package:flutter/foundation.dart';

/// Local wall-clock time without a date or timezone.
@immutable
class IslandTimeValue {
  const IslandTimeValue(this.hour, this.minute, [this.second = 0])
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60),
      assert(second >= 0 && second < 60);
  final int hour, minute, second;
  IslandTimeValue copyWith({int? hour, int? minute, int? second}) =>
      IslandTimeValue(
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
      );
  String format([String pattern = 'HH:mm:ss']) => pattern
      .replaceAll('HH', hour.toString().padLeft(2, '0'))
      .replaceAll('mm', minute.toString().padLeft(2, '0'))
      .replaceAll('ss', second.toString().padLeft(2, '0'));
  @override
  bool operator ==(Object other) =>
      other is IslandTimeValue &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second;
  @override
  int get hashCode => Object.hash(hour, minute, second);
  @override
  String toString() => format();
}
