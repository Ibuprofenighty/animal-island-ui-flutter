import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

void main() {
  group('AnimalDatePicker Tests (DAT01-DAT05)', () {
    test('DAT01: 2024-02-29 is valid leap year date, 2025-02-29 throws ArgumentError', () {
      final leapDate = AnimalDate(2024, 2, 29);
      expect(leapDate.year, 2024);
      expect(leapDate.month, 2);
      expect(leapDate.day, 29);
      expect(leapDate.toIso8601String(), '2024-02-29');

      expect(() => AnimalDate(2025, 2, 29), throwsArgumentError);
      expect(() => AnimalDate(2025, 4, 31), throwsArgumentError);
      expect(() => AnimalDate(2025, 13, 1), throwsArgumentError);
      expect(() => AnimalDate(2025, 0, 1), throwsArgumentError);
      expect(() => AnimalDate(-2025, 1, 1), throwsArgumentError);
    });

    testWidgets(
      'DAT02: Enforces date bounds and normalizes disabled dates (OLD-T024)',
      (tester) async {
        AnimalDate? chosenDate;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                value: AnimalDate(2026, 9, 15),
                firstDate: AnimalDate(2026, 9, 10),
                lastDate: AnimalDate(2026, 9, 20),
                onChanged: (d) => chosenDate = d,
              ),
            ),
          ),
        );

        final materialLocalizations = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePicker)),
        );
        Finder dateTarget(DateTime date) => find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion &&
              widget.semanticLabel ==
                  materialLocalizations.formatFullDate(date),
        );

        expect(find.text('15'), findsOneWidget);

        // Tap a valid date (16)
        final validDateTarget = dateTarget(DateTime(2026, 9, 16));
        expect(validDateTarget, findsOneWidget);
        await tester.ensureVisible(
          find.descendant(of: validDateTarget, matching: find.text('16')),
        );
        final validDateRect = tester.getRect(validDateTarget);
        expect(validDateRect.width, 48);
        expect(validDateRect.height, 48);
        expect(
          tester.widget<InteractiveRegion>(validDateTarget).disabled,
          isFalse,
        );
        await tester.tap(validDateTarget);
        await tester.pumpAndSettle();
        expect(chosenDate, AnimalDate(2026, 9, 16));

        // Tap a disabled date (5)
        chosenDate = null;
        final disabledDateTarget = dateTarget(DateTime(2026, 9, 5));
        expect(disabledDateTarget, findsOneWidget);
        await tester.ensureVisible(
          find.descendant(of: disabledDateTarget, matching: find.text('5')),
        );
        final disabledDateRect = tester.getRect(disabledDateTarget);
        expect(disabledDateRect.width, 48);
        expect(disabledDateRect.height, 48);
        final disabledDateOwner = tester.widget<InteractiveRegion>(
          disabledDateTarget,
        );
        expect(disabledDateOwner.disabled, isTrue);
        expect(disabledDateOwner.onPressed, isNull);
        await tester.tap(disabledDateTarget);
        await tester.pumpAndSettle();
        expect(chosenDate, isNull);
      },
    );

    testWidgets(
      'DAT02: Today and Clear buttons enforce disabled guard (OLD-T042)',
      (tester) async {
        AnimalDate? selectedDate = AnimalDate(2026, 9, 15);
        int changeCalls = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                value: selectedDate,
                disabled: true,
                onChanged: (d) {
                  changeCalls++;
                  selectedDate = d;
                },
              ),
            ),
          ),
        );

        // Tap Today and Clear when disabled -> 0 calls
        await tester.tap(find.text('Today'));
        await tester.pumpAndSettle();
        expect(changeCalls, 0);

        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(changeCalls, 0);
      },
    );

    testWidgets(
      'DAT03: Range selection commits AnimalDateRange when end date is tapped',
      (tester) async {
        AnimalDateRange? rangeResult;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                range: true,
                value: AnimalDate(2026, 9, 10),
                onRangeChanged: (r) => rangeResult = r,
              ),
            ),
          ),
        );

        final materialLocalizations = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePicker)),
        );
        Finder dateTarget(DateTime date) => find.byWidgetPredicate(
          (widget) =>
              widget is InteractiveRegion &&
              widget.semanticLabel ==
                  materialLocalizations.formatFullDate(date),
        );

        final startDate = DateTime(2026, 9, 12);
        final startTarget = dateTarget(startDate);
        expect(startTarget, findsOneWidget);
        await tester.ensureVisible(find.text('12'));
        final startRect = tester.getRect(startTarget);
        expect(startRect.width, 48);
        expect(startRect.height, 48);
        await tester.tap(startTarget);
        await tester.pumpAndSettle();
        expect(rangeResult, isNull);

        // Select end date (18)
        final endDate = DateTime(2026, 9, 18);
        final endTarget = dateTarget(endDate);
        expect(endTarget, findsOneWidget);
        await tester.ensureVisible(find.text('18'));
        final endRect = tester.getRect(endTarget);
        expect(endRect.width, 48);
        expect(endRect.height, 48);
        await tester.tap(endTarget);
        await tester.pumpAndSettle();

        expect(rangeResult, isNotNull);
        expect(rangeResult!.start, AnimalDate(2026, 9, 12));
        expect(rangeResult!.end, AnimalDate(2026, 9, 18));
      },
    );

    testWidgets('DAT04: Clear button works on enabled date picker', (
      tester,
    ) async {
      AnimalDate? selected = AnimalDate(2026, 9, 15);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalDatePicker(
              value: selected,
              onChanged: (d) => selected = d,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();
      expect(selected, isNull);
    });

    testWidgets(
      'DAT05: AnimalDatePicker.popover opens panel on tap and displays selected date',
      (tester) async {
        AnimalDate? pickedDate;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker.popover(
                key: const ValueKey('date-picker'),
                value: AnimalDate(2026, 9, 15),
                onChanged: (d) => pickedDate = d,
              ),
            ),
          ),
        );

        final selectedDateLabel = MaterialLocalizations.of(
          tester.element(find.byKey(const ValueKey('date-picker'))),
        ).formatMediumDate(DateTime(2026, 9, 15));
        expect(find.text(selectedDateLabel), findsOneWidget);

        // Tap trigger to open popover menu
        await tester.tap(find.text(selectedDateLabel));
        await tester.pumpAndSettle();

        // Tap day 20 in panel
        await tester.tap(find.text('20'));
        await tester.pumpAndSettle();

        expect(pickedDate, AnimalDate(2026, 9, 20));
      },
    );
  });
}
