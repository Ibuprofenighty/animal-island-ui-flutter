import 'package:flutter/foundation.dart';

import '../../foundation/models/date.dart';

/// A single civil-date grid position. A null [date] is an inert boundary cell.
@immutable
final class CalendarDayCell {
  final AnimalDate? date;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isDisabled;
  final bool isSelected;
  final bool isInRange;
  final bool isRangeStart;
  final bool isRangeEnd;

  const CalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isDisabled,
    this.isSelected = false,
    this.isInRange = false,
    this.isRangeStart = false,
    this.isRangeEnd = false,
  });
}

/// Pure Gregorian calendar calculations shared by inline and popover panels.
abstract final class CalendarModel {
  /// Validates the shared picker mode, controlled selection, and date bounds.
  ///
  /// Bounds-only model operations omit [mode] and [selection]. Any supplied
  /// selection must include its mode, so picker construction and grid
  /// generation share the same compatibility contract.
  static void validateInputs({
    AnimalDatePickerMode? mode,
    AnimalDateSelection? selection,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
  }) {
    if (firstDate != null && lastDate != null && firstDate.isAfter(lastDate)) {
      throw ArgumentError('firstDate must be on or before lastDate');
    }
    if (selection != null &&
        (mode == null || !selection.isCompatibleWith(mode))) {
      throw ArgumentError.value(
        selection,
        'selection',
        mode == null
            ? 'A mode is required for a selection'
            : 'Does not match $mode',
      );
    }
  }

  /// Builds a 42-position, Sunday-first month grid.
  ///
  /// [today] is explicit so the model has no hidden clock or host-time-zone
  /// dependency. Positions outside the supported civil years are inert cells
  /// with a null date.
  static List<CalendarDayCell> buildMonthGrid({
    required int year,
    required int month,
    required AnimalDate today,
    required AnimalDatePickerMode mode,
    AnimalDateSelection? selection,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    validateInputs(
      mode: mode,
      selection: selection,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    final firstOfMonth = AnimalDate(year, month, 1);
    final daysInMonth = AnimalDate.daysInMonth(year, month);
    final leadingCount = firstOfMonth.weekday % 7;
    final dates = <AnimalDate?>[];

    if (leadingCount > 0) {
      final previousMonth = month == 1 ? 12 : month - 1;
      final previousYear = month == 1 ? year - 1 : year;
      final previousMonthDays = previousYear < AnimalDate.minimumYear
          ? 0
          : AnimalDate.daysInMonth(previousYear, previousMonth);
      for (var index = leadingCount - 1; index >= 0; index--) {
        dates.add(
          previousMonthDays == 0
              ? null
              : AnimalDate(
                  previousYear,
                  previousMonth,
                  previousMonthDays - index,
                ),
        );
      }
    }

    for (var day = 1; day <= daysInMonth; day++) {
      dates.add(AnimalDate(year, month, day));
    }

    while (dates.length < 42) {
      final offset = dates.length - leadingCount - daysInMonth + 1;
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      dates.add(
        nextYear > AnimalDate.maximumYear
            ? null
            : AnimalDate(nextYear, nextMonth, offset),
      );
    }

    final selectedDate = switch (selection) {
      AnimalDateSingleSelection(:final date) => date,
      _ => null,
    };
    final selectedRange = switch (selection) {
      AnimalDateRangeSelection range => range,
      _ => null,
    };

    return List<CalendarDayCell>.unmodifiable(
      List<CalendarDayCell>.generate(42, (index) {
        final date = dates[index];
        if (date == null) {
          return const CalendarDayCell(
            date: null,
            isCurrentMonth: false,
            isToday: false,
            isDisabled: true,
          );
        }

        final isMonth = date.year == year && date.month == month;
        final rangeStart = selectedRange?.start == date;
        final rangeEnd = selectedRange?.end == date;
        final isWithinRange =
            selectedRange?.end != null &&
            !date.isBefore(selectedRange!.start) &&
            !date.isAfter(selectedRange.end!);
        final selected = switch (mode) {
          AnimalDatePickerMode.date => selectedDate == date,
          AnimalDatePickerMode.range => rangeStart || rangeEnd,
          AnimalDatePickerMode.month =>
            selectedDate != null &&
                selectedDate.year == date.year &&
                selectedDate.month == date.month,
        };

        return CalendarDayCell(
          date: date,
          isCurrentMonth: isMonth,
          isToday: date == today,
          isDisabled: isDateDisabled(
            date: date,
            firstDate: firstDate,
            lastDate: lastDate,
            disabledDate: disabledDate,
          ),
          isSelected: selected,
          isInRange: isWithinRange,
          isRangeStart: rangeStart,
          isRangeEnd: rangeEnd,
        );
      }, growable: false),
    );
  }

  static bool isDateDisabled({
    required AnimalDate date,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    validateInputs(firstDate: firstDate, lastDate: lastDate);
    if (firstDate != null && date.isBefore(firstDate)) return true;
    if (lastDate != null && date.isAfter(lastDate)) return true;
    return disabledDate?.call(date) ?? false;
  }

  /// A month is selectable when its canonical first day is enabled.
  static bool isMonthDisabled({
    required int year,
    required int month,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) => isDateDisabled(
    date: AnimalDate(year, month, 1),
    firstDate: firstDate,
    lastDate: lastDate,
    disabledDate: disabledDate,
  );

  /// Returns whether any strictly interior date is disabled.
  ///
  /// Traversal advances one civil ordinal at a time and stops before [end], so
  /// it stays bounded at both supported-year boundaries and across DST.
  static bool hasDisabledInteriorDate({
    required AnimalDate start,
    required AnimalDate end,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    validateInputs(firstDate: firstDate, lastDate: lastDate);
    if (start.isAfter(end)) {
      throw ArgumentError.value(end, 'end', 'Must be on or after start');
    }
    if (start == end) return false;

    final firstInterior = start.addDays(1);
    final lastInterior = end.subtractDays(1);
    if (firstInterior.isBefore(end) &&
        firstDate != null &&
        firstInterior.isBefore(firstDate)) {
      return true;
    }
    if (lastInterior.isAfter(start) &&
        lastDate != null &&
        lastInterior.isAfter(lastDate)) {
      return true;
    }
    if (disabledDate == null) return false;

    var cursor = firstInterior;
    while (true) {
      if (cursor == end) return false;
      if (disabledDate(cursor)) return true;
      cursor = cursor.addDays(1);
    }
  }

  /// Tests both endpoints and every interior date before creating a range.
  static bool isRangeDisabled({
    required AnimalDate start,
    required AnimalDate end,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    if (start.isAfter(end)) {
      throw ArgumentError.value(end, 'end', 'Must be on or after start');
    }
    if (isDateDisabled(
      date: start,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDate: disabledDate,
    )) {
      return true;
    }
    if (start != end &&
        isDateDisabled(
          date: end,
          firstDate: firstDate,
          lastDate: lastDate,
          disabledDate: disabledDate,
        )) {
      return true;
    }
    return hasDisabledInteriorDate(
      start: start,
      end: end,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDate: disabledDate,
    );
  }

  /// Whether the target month intersects the inclusive bounds by month.
  static bool canNavigateToMonth({
    required int year,
    required int month,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
  }) {
    validateInputs(firstDate: firstDate, lastDate: lastDate);
    final target = AnimalDate(year, month, 1);
    if (firstDate != null &&
        (target.year < firstDate.year ||
            (target.year == firstDate.year &&
                target.month < firstDate.month))) {
      return false;
    }
    if (lastDate != null &&
        (target.year > lastDate.year ||
            (target.year == lastDate.year && target.month > lastDate.month))) {
      return false;
    }
    return true;
  }
}
