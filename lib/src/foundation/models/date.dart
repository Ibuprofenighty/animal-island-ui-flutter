import 'package:flutter/foundation.dart';

/// An immutable, timezone-independent representation of a calendar date (year, month, day).
///
/// Prevents daylight saving time glitches and UTC/local conversion shifts.
@immutable
class AnimalDate implements Comparable<AnimalDate> {
  final int year;
  final int month;
  final int day;

  AnimalDate(this.year, this.month, this.day) {
    if (year <= 0) {
      throw ArgumentError.value(year, 'year', 'Year must be positive');
    }
    if (month < 1 || month > 12) {
      throw ArgumentError.value(
        month,
        'month',
        'Month must be between 1 and 12',
      );
    }
    final maxDays = daysInMonth(year, month);
    if (day < 1 || day > maxDays) {
      throw ArgumentError.value(
        day,
        'day',
        'Invalid day $day for month $month in year $year (expected 1..$maxDays)',
      );
    }
  }

  /// Returns true if [year] is a leap year in the Gregorian calendar.
  static bool isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }

  /// Returns the number of days in [month] for [year].
  static int daysInMonth(int year, int month) {
    switch (month) {
      case 1:
      case 3:
      case 5:
      case 7:
      case 8:
      case 10:
      case 12:
        return 31;
      case 4:
      case 6:
      case 9:
      case 11:
        return 30;
      case 2:
        return isLeapYear(year) ? 29 : 28;
      default:
        throw ArgumentError.value(
          month,
          'month',
          'Month must be between 1 and 12',
        );
    }
  }

  /// Creates an [AnimalDate] representing today in local time.
  factory AnimalDate.today() {
    final now = DateTime.now();
    return AnimalDate(now.year, now.month, now.day);
  }

  /// Creates an [AnimalDate] from a standard [DateTime].
  factory AnimalDate.fromDateTime(DateTime dt) =>
      AnimalDate(dt.year, dt.month, dt.day);

  /// Converts this date to a local [DateTime] at midnight (00:00:00).
  DateTime toDateTime() => DateTime(year, month, day);

  /// Formats this date as `YYYY-MM-DD`.
  String toIso8601String() {
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$year-$m-$d';
  }

  /// Adds [days] to this date and returns a new [AnimalDate].
  AnimalDate addDays(int days) {
    final dt = toDateTime().add(Duration(days: days));
    return AnimalDate.fromDateTime(dt);
  }

  /// Subtracts [days] from this date and returns a new [AnimalDate].
  AnimalDate subtractDays(int days) => addDays(-days);

  bool isBefore(AnimalDate other) => compareTo(other) < 0;

  bool isAfter(AnimalDate other) => compareTo(other) > 0;

  bool isAtSameMomentAs(AnimalDate other) => compareTo(other) == 0;

  @override
  int compareTo(AnimalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalDate &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601String();
}

/// An immutable representation of a date range between [start] and [end].
@immutable
class AnimalDateRange {
  final AnimalDate start;
  final AnimalDate end;

  AnimalDateRange({required this.start, required this.end}) {
    if (start.isAfter(end)) {
      throw ArgumentError('start must not be after end: $start > $end');
    }
  }

  /// Formats the range as `YYYY-MM-DD to YYYY-MM-DD`.
  @override
  String toString() => '${start.toIso8601String()} to ${end.toIso8601String()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalDateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(start, end);
}
