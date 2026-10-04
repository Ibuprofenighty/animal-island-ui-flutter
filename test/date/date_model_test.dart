import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/calendar_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../support/fake_clock.dart';

void main() {
  setUpAll(timezone_data.initializeTimeZones);

  group('N16 civil date model', () {
    test(
      'Gregorian construction accepts leap days and years 1 through 9999',
      () {
        expect(AnimalDate.isLeapYear(2024), isTrue);
        expect(AnimalDate.isLeapYear(1900), isFalse);
        expect(AnimalDate.isLeapYear(2000), isTrue);
        expect(AnimalDate.daysInMonth(2024, 2), 29);
        expect(AnimalDate.daysInMonth(2025, 2), 28);

        expect(AnimalDate(2024, 2, 29).toIso8601String(), '2024-02-29');
        expect(AnimalDate.minimumYear, 1);
        expect(AnimalDate.maximumYear, 9999);
        expect(AnimalDate(1, 1, 1).toIso8601String(), '0001-01-01');
        expect(AnimalDate(9999, 12, 31).toIso8601String(), '9999-12-31');
        expect(AnimalDate(2026, 9, 1).weekday, 2);
        expect(AnimalDate(2026, 9, 6).weekday, 7);

        expect(() => AnimalDate(2025, 2, 29), throwsArgumentError);
        expect(() => AnimalDate(2025, 4, 31), throwsArgumentError);
        expect(() => AnimalDate(2025, 13, 1), throwsArgumentError);
        expect(() => AnimalDate(2025, 0, 1), throwsArgumentError);
        expect(() => AnimalDate(-1, 1, 1), throwsArgumentError);
        expect(() => AnimalDate(0, 1, 1), throwsArgumentError);
        expect(() => AnimalDate(10000, 1, 1), throwsArgumentError);
        expect(() => AnimalDate.daysInMonth(2025, 13), throwsArgumentError);
      },
    );

    test('DateTime conversion keeps civil fields and emits UTC midnight', () {
      final localInput = DateTime(2026, 11, 1, 23, 45, 12, 345, 678);
      final utcInput = DateTime.utc(2024, 2, 29, 23, 45, 12, 345, 678);

      final AnimalDate localCivil = AnimalDate.fromDateTime(localInput);
      final AnimalDate utcCivil = AnimalDate.fromDateTime(utcInput);
      expect(localCivil, AnimalDate(2026, 11, 1));
      expect(utcCivil, AnimalDate(2024, 2, 29));

      final DateTime localUtcMidnight = localCivil.toDateTime();
      final DateTime leapUtcMidnight = utcCivil.toDateTime();
      expect(localUtcMidnight.isUtc, isTrue);
      expect(localUtcMidnight, DateTime.utc(2026, 11, 1));
      expect(leapUtcMidnight.isUtc, isTrue);
      expect(leapUtcMidnight, DateTime.utc(2024, 2, 29));

      expect(
        AnimalDate.fromDateTime(DateTime.utc(1, 1, 1)),
        AnimalDate(1, 1, 1),
      );
      final DateTime civilYearOne = DateTime.fromMillisecondsSinceEpoch(
        -62135596800000,
        isUtc: true,
      );
      expect(civilYearOne.year, 1);
      expect(AnimalDate.fromDateTime(civilYearOne), AnimalDate(1, 1, 1));
      expect(AnimalDate(1, 1, 1).toDateTime(), civilYearOne);
      expect(
        () => AnimalDate.fromDateTime(DateTime.utc(0, 1, 1)),
        throwsArgumentError,
      );
      expect(
        AnimalDate.fromDateTime(DateTime.utc(9999, 12, 31, 23)),
        AnimalDate(9999, 12, 31),
      );
    });

    test(
      'Ordinal arithmetic crosses month ends and rejects civil overflow',
      () {
        expect(AnimalDate(2026, 1, 31).addDays(1), AnimalDate(2026, 2, 1));
        expect(AnimalDate(2024, 2, 28).addDays(1), AnimalDate(2024, 2, 29));
        expect(AnimalDate(2024, 2, 29).addDays(1), AnimalDate(2024, 3, 1));
        expect(AnimalDate(2026, 12, 31).addDays(1), AnimalDate(2027, 1, 1));
        expect(
          AnimalDate(2026, 1, 1).subtractDays(1),
          AnimalDate(2025, 12, 31),
        );
        expect(
          AnimalDate(2026, 11, 2).subtractDays(1),
          AnimalDate(2026, 11, 1),
        );
        expect(AnimalDate(2026, 1, 1).compareTo(AnimalDate(2026, 1, 2)), -1);
        expect(AnimalDate(2026, 1, 2).isAfter(AnimalDate(2026, 1, 1)), isTrue);
        expect(
          AnimalDate(2026, 1, 2).isAtSameMomentAs(AnimalDate(2026, 1, 2)),
          isTrue,
        );

        expect(() => AnimalDate(1, 1, 1).subtractDays(1), throwsRangeError);
        expect(() => AnimalDate(9999, 12, 31).addDays(1), throwsRangeError);
      },
    );

    test('Today reads the injected canonical clock date', () {
      final FakeClock clock = FakeClock(DateTime.utc(2026, 11, 1, 23, 59));
      expect(AnimalDate.today(clock: clock), AnimalDate(2026, 11, 1));
    });

    test('IANA fixtures agree across UTC, Toronto, Shanghai and New York', () {
      final fixtures = <({String name, int fallHours})>[
        (name: 'Etc/UTC', fallHours: 24),
        (name: 'America/Toronto', fallHours: 25),
        (name: 'Asia/Shanghai', fallHours: 24),
        (name: 'America/New_York', fallHours: 25),
      ];

      for (final fixture in fixtures) {
        final timezone.Location location = timezone.getLocation(fixture.name);
        final timezone.TZDateTime fallStart = timezone.TZDateTime(
          location,
          2026,
          11,
          1,
        );
        final timezone.TZDateTime fallNextCivilMidnight = timezone.TZDateTime(
          location,
          2026,
          11,
          2,
        );
        expect(
          fallNextCivilMidnight.difference(fallStart).inHours,
          fixture.fallHours,
          reason: '${fixture.name} IANA fall-back interval',
        );

        for (final (year, month, day) in <(int, int, int)>[
          (1, 1, 1),
          (2026, 10, 31),
          (2026, 11, 1),
          (2026, 11, 2),
          (2024, 2, 28),
          (2024, 2, 29),
          (2026, 12, 31),
          (2026, 1, 31),
          (9999, 12, 31),
        ]) {
          final timezone.TZDateTime input = timezone.TZDateTime(
            location,
            year,
            month,
            day,
            23,
            59,
          );
          final AnimalDate civil = AnimalDate.fromDateTime(input);
          expect(civil, AnimalDate(year, month, day), reason: fixture.name);
          expect(
            civil.toDateTime(),
            DateTime.utc(year, month, day),
            reason: '${fixture.name} UTC civil midnight',
          );

          if (civil != AnimalDate(9999, 12, 31)) {
            final timezone.TZDateTime next = timezone.TZDateTime(
              location,
              year,
              month,
              day + 1,
            );
            expect(
              civil.addDays(1),
              AnimalDate.fromDateTime(next),
              reason: '${fixture.name} ordinal next day from $year-$month-$day',
            );
          }
        }
      }
    });

    test(
      'Calendar grid uses 42 Sunday-first civil cells and inert edge slots',
      () {
        final List<CalendarDayCell> minimumYear = CalendarModel.buildMonthGrid(
          year: 1,
          month: 1,
          today: AnimalDate(1, 1, 1),
          mode: AnimalDatePickerMode.date,
        );
        expect(minimumYear, hasLength(42));
        expect(minimumYear.first.date, isNull);
        expect(minimumYear.first.isDisabled, isTrue);
        expect(minimumYear.first.isCurrentMonth, isFalse);
        expect(minimumYear.first.isToday, isFalse);
        expect(minimumYear.first.isSelected, isFalse);
        expect(minimumYear.first.isInRange, isFalse);
        expect(minimumYear.first.isRangeStart, isFalse);
        expect(minimumYear.first.isRangeEnd, isFalse);

        final List<CalendarDayCell> maximumYear = CalendarModel.buildMonthGrid(
          year: 9999,
          month: 12,
          today: AnimalDate(9999, 12, 31),
          mode: AnimalDatePickerMode.date,
        );
        expect(maximumYear, hasLength(42));
        final List<CalendarDayCell> beyondMaximum = maximumYear
            .where((CalendarDayCell cell) => cell.date == null)
            .toList();
        expect(beyondMaximum, isNotEmpty);
        expect(
          beyondMaximum.every(
            (CalendarDayCell cell) =>
                cell.isDisabled &&
                !cell.isCurrentMonth &&
                !cell.isToday &&
                !cell.isSelected &&
                !cell.isInRange &&
                !cell.isRangeStart &&
                !cell.isRangeEnd,
          ),
          isTrue,
        );
        expect(
          maximumYear.where((cell) => cell.date != null).last.date,
          AnimalDate(9999, 12, 31),
        );
      },
    );

    test('Range-disabled model checks endpoint, interior, and both bounds', () {
      final AnimalDate start = AnimalDate(2026, 1, 1);
      final AnimalDate end = AnimalDate(2026, 1, 10);

      expect(
        CalendarModel.hasDisabledInteriorDate(
          start: start,
          end: end,
          firstDate: AnimalDate(2026, 1, 4),
        ),
        isTrue,
      );
      expect(
        CalendarModel.hasDisabledInteriorDate(
          start: start,
          end: end,
          lastDate: AnimalDate(2026, 1, 8),
        ),
        isTrue,
      );
      expect(
        CalendarModel.hasDisabledInteriorDate(
          start: start,
          end: end,
          firstDate: start,
          lastDate: end,
        ),
        isFalse,
      );
      expect(
        CalendarModel.hasDisabledInteriorDate(
          start: start,
          end: end,
          disabledDate: (AnimalDate date) => date == AnimalDate(2026, 1, 5),
        ),
        isTrue,
      );
      expect(
        CalendarModel.hasDisabledInteriorDate(
          start: AnimalDate(9999, 12, 31),
          end: AnimalDate(9999, 12, 31),
        ),
        isFalse,
      );
    });

    test('Month-disabled model uses the canonical first day of each month', () {
      expect(
        CalendarModel.isMonthDisabled(
          year: 2026,
          month: 5,
          firstDate: AnimalDate(2026, 5, 15),
        ),
        isTrue,
      );
      expect(
        CalendarModel.isMonthDisabled(
          year: 2026,
          month: 5,
          disabledDate: (AnimalDate date) => date == AnimalDate(2026, 5, 1),
        ),
        isTrue,
      );
      expect(
        CalendarModel.isMonthDisabled(
          year: 2026,
          month: 6,
          firstDate: AnimalDate(2026, 5, 15),
        ),
        isFalse,
      );
    });

    test('Calendar model rejects a selection variant from another mode', () {
      final AnimalDateSingleSelection single = AnimalDateSelection.date(
        AnimalDate(2026, 5, 15),
      ) as AnimalDateSingleSelection;
      final AnimalDateRangeSelection range = AnimalDateSelection.range(
        start: AnimalDate(2026, 5, 15),
      ) as AnimalDateRangeSelection;

      expect(
        () => CalendarModel.buildMonthGrid(
          year: 2026,
          month: 5,
          today: AnimalDate(2026, 5, 15),
          mode: AnimalDatePickerMode.date,
          selection: range,
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarModel.buildMonthGrid(
          year: 2026,
          month: 5,
          today: AnimalDate(2026, 5, 15),
          mode: AnimalDatePickerMode.range,
          selection: single,
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarModel.buildMonthGrid(
          year: 2026,
          month: 5,
          today: AnimalDate(2026, 5, 15),
          mode: AnimalDatePickerMode.month,
          selection: range,
        ),
        throwsArgumentError,
      );
      expect(
        () => CalendarModel.buildMonthGrid(
          year: 2026,
          month: 5,
          today: AnimalDate(2026, 5, 15),
          mode: AnimalDatePickerMode.month,
          selection: AnimalDateSelection.date(AnimalDate(2026, 5, 2)),
        ),
        throwsArgumentError,
      );
    });

    test('Calendar model rejects reversed inclusive bounds', () {
      expect(
        () => CalendarModel.isDateDisabled(
          date: AnimalDate(2026, 5, 15),
          firstDate: AnimalDate(2026, 5, 16),
          lastDate: AnimalDate(2026, 5, 14),
        ),
        throwsArgumentError,
      );
    });
  });
}
