import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_clock.dart';

void main() {
  group('AnimalDatePicker State Tests', () {
    testWidgets(
      'DAT03 external selection changes and null reset recenter the panel',
      (tester) async {
        AnimalDateSelection? selection = AnimalDateSelection.date(
          AnimalDate(2026, 9, 15),
        );
        final FakeClock clock = FakeClock(DateTime.utc(2026, 11, 1, 12));

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                localizationsDelegates:
                    AnimalLocalizations.localizationsDelegates,
                supportedLocales: AnimalLocalizations.supportedLocales,
                theme: AnimalIslandTheme.light.toThemeData(),
                home: Scaffold(
                  body: Column(
                    children: [
                      AnimalDatePicker(
                        selection: selection,
                        clock: clock,
                        onChanged: (_) {},
                      ),
                      ElevatedButton(
                        onPressed: () => setState(
                          () => selection = AnimalDateSelection.date(
                            AnimalDate(2026, 10, 20),
                          ),
                        ),
                        child: const Text('Update selection'),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() => selection = null),
                        child: const Text('Reset selection'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePickerPanel)),
        );
        Finder heading(int year, int month) =>
            find.text(material.formatMonthYear(DateTime.utc(year, month)));

        expect(heading(2026, 9), findsOneWidget);
        await tester.tap(find.text('Update selection'));
        await tester.pumpAndSettle();
        expect(heading(2026, 10), findsOneWidget);

        await tester.tap(find.text('Reset selection'));
        await tester.pumpAndSettle();
        expect(heading(2026, 11), findsOneWidget);
      },
    );

    testWidgets('Date, range and month modes retain one selection contract', (
      tester,
    ) async {
      AnimalDateSelection? selection = AnimalDateSelection.date(
        AnimalDate(2026, 5, 1),
      );
      var mode = AnimalDatePickerMode.date;
      var proposals = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalDatePicker(
                    selection: selection,
                    mode: mode,
                    onChanged: (next) {
                      proposals++;
                      setState(() => selection = next);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => setState(
                      () => mode = mode == AnimalDatePickerMode.date
                          ? AnimalDatePickerMode.month
                          : AnimalDatePickerMode.date,
                    ),
                    child: const Text('Toggle date/month'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.widget<AnimalDatePicker>(find.byType(AnimalDatePicker)).mode,
        AnimalDatePickerMode.date,
      );
      await tester.tap(find.text('Toggle date/month'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimalDatePicker>(find.byType(AnimalDatePicker)).mode,
        AnimalDatePickerMode.month,
      );
      expect(selection, isA<AnimalDateSingleSelection>());
      expect(
        (selection! as AnimalDateSingleSelection).date,
        AnimalDate(2026, 5, 1),
      );
      expect(proposals, 0);

      await tester.tap(find.text('Toggle date/month'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimalDatePicker>(find.byType(AnimalDatePicker)).mode,
        AnimalDatePickerMode.date,
      );
      expect(
        (selection! as AnimalDateSingleSelection).date,
        AnimalDate(2026, 5, 1),
      );
      expect(proposals, 0);
    });

    test('Invalid selection and mode pairs throw at the public boundary', () {
      final AnimalDateSelection single = AnimalDateSelection.date(
        AnimalDate(2026, 5, 10),
      );
      final AnimalDateSelection range = AnimalDateSelection.range(
        start: AnimalDate(2026, 5, 10),
      );
      final AnimalDateSelection nonFirstOfMonth = AnimalDateSelection.date(
        AnimalDate(2026, 5, 2),
      );

      expect(
        () =>
            AnimalDatePicker(mode: AnimalDatePickerMode.date, selection: range),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePicker.popover(
          mode: AnimalDatePickerMode.range,
          selection: single,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePicker(
          mode: AnimalDatePickerMode.month,
          selection: range,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePicker(
          mode: AnimalDatePickerMode.month,
          selection: nonFirstOfMonth,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePickerPanel(
          mode: AnimalDatePickerMode.month,
          selection: nonFirstOfMonth,
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalDatePicker(
          selection: single,
          firstDate: AnimalDate(2026, 5, 11),
          lastDate: AnimalDate(2026, 5, 10),
        ),
        throwsArgumentError,
      );
    });

    testWidgets('Previous and next year navigation updates the visible month', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalDatePicker(
              selection: AnimalDateSelection.date(AnimalDate(2026, 5, 1)),
            ),
          ),
        ),
      );

      final MaterialLocalizations material = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );
      Finder heading(int year, int month) =>
          find.text(material.formatMonthYear(DateTime.utc(year, month)));

      expect(heading(2026, 5), findsOneWidget);
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right_rounded));
      await tester.pumpAndSettle();
      expect(heading(2027, 5), findsOneWidget);

      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left_rounded));
      await tester.pumpAndSettle();
      expect(heading(2025, 5), findsOneWidget);
    });
  });
}
