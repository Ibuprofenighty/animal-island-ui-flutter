import 'package:flutter/foundation.dart';

import '../../foundation/models/date.dart';

/// Represents a single cell in the calendar day grid.
@immutable
class CalendarDayCell {
  final AnimalDate date;
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

/// Pure computation model for calendar calculations.
class CalendarModel {
  /// Builds a 42-day calendar grid (6 rows of 7 days) for the specified [year] and [month].
  static List<CalendarDayCell> buildMonthGrid({
    required int year,
    required int month,
    AnimalDate? selectedDate,
    AnimalDateRange? selectedRange,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
    AnimalDate? today,
  }) {
    final effectiveToday = today ?? AnimalDate.today();
    final firstDayOfMonth = AnimalDate(year, month, 1);
    final daysInCurrent = AnimalDate.daysInMonth(year, month);

    // DateTime weekday: 1 = Monday, ..., 7 = Sunday.
    // In our calendar, Sunday is column 0 or Monday is column 0.
    // Sunday as column 0: weekday % 7 (Sunday = 0, Monday = 1, ... Saturday = 6).
    final startWeekday = firstDayOfMonth.toDateTime().weekday % 7;

    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    final daysInPrev = AnimalDate.daysInMonth(prevYear, prevMonth);

    final cells = <CalendarDayCell>[];

    // Leading days from previous month
    for (int i = startWeekday - 1; i >= 0; i--) {
      final d = AnimalDate(prevYear, prevMonth, daysInPrev - i);
      cells.add(
        _createCell(
          date: d,
          isCurrentMonth: false,
          today: effectiveToday,
          selectedDate: selectedDate,
          selectedRange: selectedRange,
          firstDate: firstDate,
          lastDate: lastDate,
          disabledDate: disabledDate,
        ),
      );
    }

    // Days of current month
    for (int day = 1; day <= daysInCurrent; day++) {
      final d = AnimalDate(year, month, day);
      cells.add(
        _createCell(
          date: d,
          isCurrentMonth: true,
          today: effectiveToday,
          selectedDate: selectedDate,
          selectedRange: selectedRange,
          firstDate: firstDate,
          lastDate: lastDate,
          disabledDate: disabledDate,
        ),
      );
    }

    // Trailing days from next month to complete 42 cells (6 rows x 7 cols)
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    int nextDay = 1;
    while (cells.length < 42) {
      final d = AnimalDate(nextYear, nextMonth, nextDay++);
      cells.add(
        _createCell(
          date: d,
          isCurrentMonth: false,
          today: effectiveToday,
          selectedDate: selectedDate,
          selectedRange: selectedRange,
          firstDate: firstDate,
          lastDate: lastDate,
          disabledDate: disabledDate,
        ),
      );
    }

    return cells;
  }

  static bool isDateDisabled({
    required AnimalDate date,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    if (firstDate != null && date.isBefore(firstDate)) return true;
    if (lastDate != null && date.isAfter(lastDate)) return true;
    if (disabledDate != null && disabledDate(date)) return true;
    return false;
  }

  /// Checks if any date strictly inside [start] and [end] is disabled.
  static bool hasDisabledInteriorDate({
    required AnimalDate start,
    required AnimalDate end,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    var cur = start.addDays(1);
    while (cur.isBefore(end)) {
      if (isDateDisabled(
        date: cur,
        firstDate: firstDate,
        lastDate: lastDate,
        disabledDate: disabledDate,
      )) {
        return true;
      }
      cur = cur.addDays(1);
    }
    return false;
  }

  static CalendarDayCell _createCell({
    required AnimalDate date,
    required bool isCurrentMonth,
    required AnimalDate today,
    AnimalDate? selectedDate,
    AnimalDateRange? selectedRange,
    AnimalDate? firstDate,
    AnimalDate? lastDate,
    bool Function(AnimalDate date)? disabledDate,
  }) {
    final disabled = isDateDisabled(
      date: date,
      firstDate: firstDate,
      lastDate: lastDate,
      disabledDate: disabledDate,
    );

    final isToday = date == today;
    final isSelected = selectedDate != null && date == selectedDate;

    bool isInRange = false;
    bool isRangeStart = false;
    bool isRangeEnd = false;

    if (selectedRange != null) {
      isRangeStart = date == selectedRange.start;
      isRangeEnd = date == selectedRange.end;
      isInRange =
          (date.isAfter(selectedRange.start) || date == selectedRange.start) &&
          (date.isBefore(selectedRange.end) || date == selectedRange.end);
    }

    return CalendarDayCell(
      date: date,
      isCurrentMonth: isCurrentMonth,
      isToday: isToday,
      isDisabled: disabled,
      isSelected: isSelected,
      isInRange: isInRange,
      isRangeStart: isRangeStart,
      isRangeEnd: isRangeEnd,
    );
  }
}
