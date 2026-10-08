import 'package:flutter/foundation.dart';

import 'clock.dart';

/// An immutable Gregorian civil date, independent of any time zone.
///
/// Supported dates are from 0001-01-01 through 9999-12-31. Arithmetic uses
/// civil-day ordinals, so crossing a daylight-saving transition cannot change
/// the number of calendar days moved.
@immutable
final class AnimalDate implements Comparable<AnimalDate> {
  /// Earliest supported year.
  static const int minimumYear = 1;

  /// Latest supported year.
  static const int maximumYear = 9999;

  static const List<int> _daysBeforeMonth = <int>[
    0,
    31,
    59,
    90,
    120,
    151,
    181,
    212,
    243,
    273,
    304,
    334,
  ];

  /// Year, from [minimumYear] to [maximumYear].
  final int year;

  /// Month of the year, from 1 to 12.
  final int month;

  /// Day of the month, from 1 to [daysInMonth] for [year] and [month].
  final int day;

  /// Creates the civil date [year]-[month]-[day].
  ///
  /// Throws an [ArgumentError] when the year is outside [minimumYear] to
  /// [maximumYear] or the month or day does not exist.
  AnimalDate(this.year, this.month, this.day) {
    _validateYear(year);
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'Expected a month in 1..12');
    }
    final maximumDay = daysInMonth(year, month);
    if (day < 1 || day > maximumDay) {
      throw ArgumentError.value(
        day,
        'day',
        'Expected a day in 1..$maximumDay for $year-${month.toString().padLeft(2, '0')}',
      );
    }
  }

  // Whether [year] is a leap year in the Gregorian calendar.
  static bool _isLeapYear(int year) {
    return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
  }

  /// Returns the number of days in [month] of [year].
  static int daysInMonth(int year, int month) {
    _validateYear(year);
    if (month < 1 || month > 12) {
      throw ArgumentError.value(month, 'month', 'Expected a month in 1..12');
    }
    return switch (month) {
      2 => _isLeapYear(year) ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
  }

  /// The current civil date according to [clock].
  factory AnimalDate.today({AnimalClock clock = const SystemClock()}) {
    final now = clock.now();
    return AnimalDate(now.year, now.month, now.day);
  }

  /// Copies the year, month, and day fields as represented by [date].
  ///
  /// A UTC input keeps its UTC fields and a local input keeps its local fields;
  /// this method does not convert the instant to another time zone.
  factory AnimalDate.fromDateTime(DateTime date) =>
      AnimalDate(date.year, date.month, date.day);

  /// Converts to the same civil date at UTC midnight.
  DateTime toDateTime() => DateTime.utc(year, month, day);

  /// ISO-8601 weekday number: Monday is 1 and Sunday is 7.
  int get weekday => (_ordinal % 7) + 1;

  /// Adds [days] in the Gregorian civil calendar.
  ///
  /// Throws [RangeError] if the result would leave years 1 through 9999.
  AnimalDate addDays(int days) => _shiftDays(BigInt.from(days));

  /// Subtracts [days] in the Gregorian civil calendar.
  ///
  /// Throws [RangeError] if the result would leave years 1 through 9999.
  AnimalDate subtractDays(int days) => _shiftDays(-BigInt.from(days));

  AnimalDate _shiftDays(BigInt delta) {
    final target = BigInt.from(_ordinal) + delta;
    if (target < BigInt.zero || target > BigInt.from(_maximumOrdinal)) {
      throw RangeError('Date arithmetic must stay within years 1 through 9999');
    }
    return _fromOrdinal(target.toInt());
  }

  int get _ordinal {
    final leapAdjustment = month > 2 && _isLeapYear(year) ? 1 : 0;
    return _daysBeforeYear(year) +
        _daysBeforeMonth[month - 1] +
        leapAdjustment +
        day -
        1;
  }

  static int get _maximumOrdinal => _daysBeforeYear(maximumYear + 1) - 1;

  static AnimalDate _fromOrdinal(int ordinal) {
    var low = minimumYear;
    var high = maximumYear;
    var year = minimumYear;
    while (low <= high) {
      final candidate = (low + high) ~/ 2;
      final candidateStart = _daysBeforeYear(candidate);
      final nextYearStart = _daysBeforeYear(candidate + 1);
      if (ordinal < candidateStart) {
        high = candidate - 1;
      } else if (ordinal >= nextYearStart) {
        low = candidate + 1;
      } else {
        year = candidate;
        break;
      }
    }

    var dayOfYear = ordinal - _daysBeforeYear(year);
    for (var month = 1; month <= 12; month++) {
      final monthLength = daysInMonth(year, month);
      if (dayOfYear < monthLength) {
        return AnimalDate(year, month, dayOfYear + 1);
      }
      dayOfYear -= monthLength;
    }
    throw StateError('Civil ordinal could not be converted to a date');
  }

  static int _daysBeforeYear(int year) {
    final previousYear = year - 1;
    return previousYear * 365 +
        previousYear ~/ 4 -
        previousYear ~/ 100 +
        previousYear ~/ 400;
  }

  static void _validateYear(int year) {
    if (year < minimumYear || year > maximumYear) {
      throw ArgumentError.value(
        year,
        'year',
        'Expected a year in $minimumYear..$maximumYear',
      );
    }
  }

  /// Formats this date as a four-digit-year `YYYY-MM-DD` string.
  String toIso8601String() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  /// Whether this date is strictly earlier than [other].
  bool isBefore(AnimalDate other) => compareTo(other) < 0;

  /// Whether this date is strictly later than [other].
  bool isAfter(AnimalDate other) => compareTo(other) > 0;

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
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso8601String();
}

/// The only selection modes supported by `AnimalDatePicker`.
enum AnimalDatePickerMode {
  /// Selects one date with an [AnimalDateSingleSelection].
  date,

  /// Selects a start and end date with an [AnimalDateRangeSelection].
  range,

  /// Selects a month with an [AnimalDateSingleSelection] on its first day.
  month,
}

/// A controlled, discriminated date-picker selection.
///
/// A range selection with a null end is the controlled first-endpoint draft.
/// Month mode uses a single-date selection whose date is the first day of its
/// month.
@immutable
sealed class AnimalDateSelection {
  /// Base constructor for the sealed selection variants.
  const AnimalDateSelection();

  /// Creates a single-date selection of [date].
  const factory AnimalDateSelection.date(AnimalDate date) =
      AnimalDateSingleSelection;

  /// Creates a range selection from [start] to [end]; a null [end] is the
  /// first-endpoint draft.
  ///
  /// Throws an [ArgumentError] when [end] is before [start].
  factory AnimalDateSelection.range({
    required AnimalDate start,
    AnimalDate? end,
  }) = AnimalDateRangeSelection;

  /// Whether this variant is valid for [mode].
  bool isCompatibleWith(AnimalDatePickerMode mode);
}

/// A single selected civil date, also used for a first-of-month selection.
@immutable
final class AnimalDateSingleSelection extends AnimalDateSelection {
  /// Creates a selection of [date].
  const AnimalDateSingleSelection(this.date);

  /// Selected date; the first day of the month in
  /// [AnimalDatePickerMode.month].
  final AnimalDate date;

  @override
  bool isCompatibleWith(AnimalDatePickerMode mode) =>
      mode != AnimalDatePickerMode.range &&
      (mode != AnimalDatePickerMode.month || date.day == 1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalDateSingleSelection && date == other.date;

  @override
  int get hashCode => Object.hash(AnimalDateSingleSelection, date);
}

/// A controlled range selection. [end] is null until the second endpoint is
/// proposed and accepted by the parent.
@immutable
final class AnimalDateRangeSelection extends AnimalDateSelection {
  /// Creates a range from [start] to [end].
  ///
  /// Throws an [ArgumentError] when [end] is before [start].
  AnimalDateRangeSelection({required this.start, this.end}) {
    if (end != null && start.isAfter(end!)) {
      throw ArgumentError.value(
        end,
        'end',
        'Range end must be on or after start ($start)',
      );
    }
  }

  /// First date of the range.
  final AnimalDate start;

  /// Last date of the range, inclusive; null while only [start] is chosen.
  final AnimalDate? end;

  @override
  bool isCompatibleWith(AnimalDatePickerMode mode) =>
      mode == AnimalDatePickerMode.range;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalDateRangeSelection &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => Object.hash(AnimalDateRangeSelection, start, end);
}
