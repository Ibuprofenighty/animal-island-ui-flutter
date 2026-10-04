import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/calendar_model.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

import '../../support/fake_clock.dart';

void main() {
  group('AnimalDatePicker Semantics Tests', () {
    testWidgets('Emits accessible semantics for Today and Clear', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                selection: AnimalDateSelection.date(AnimalDate(2026, 9, 15)),
                showToday: true,
                allowClear: true,
              ),
            ),
          ),
        );

        expect(find.bySemanticsLabel('Today'), findsOneWidget);
        expect(find.bySemanticsLabel('Clear date'), findsOneWidget);
      } finally {
        handle.dispose();
      }
    });

    testWidgets('Civil boundary placeholders have no day semantics or focus', (
      tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      try {
        final AnimalDate today = AnimalDate(1, 1, 1);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDatePicker(
                selection: AnimalDateSelection.date(today),
                firstDate: today,
                lastDate: today,
                clock: FakeClock(DateTime.utc(1, 1, 1, 12)),
                showToday: false,
                allowClear: false,
              ),
            ),
          ),
        );

        final Finder panel = find.byType(AnimalDatePickerPanel);
        final Finder viewport = find.descendant(
          of: panel,
          matching: find.byType(SingleChildScrollView),
        );
        final List<CalendarDayCell> cells = CalendarModel.buildMonthGrid(
          year: 1,
          month: 1,
          today: today,
          mode: AnimalDatePickerMode.date,
          selection: AnimalDateSelection.date(today),
          firstDate: today,
          lastDate: today,
        );
        final int datedCellCount = cells
            .where((CalendarDayCell cell) => cell.date != null)
            .length;
        final MaterialLocalizations material = MaterialLocalizations.of(
          tester.element(panel),
        );
        final Set<String> expectedDateLabels = cells
            .where((CalendarDayCell cell) => cell.date != null)
            .map(
              (CalendarDayCell cell) =>
                  material.formatFullDate(cell.date!.toDateTime()),
            )
            .toSet();
        expect(cells, hasLength(42));
        expect(
          cells.where((CalendarDayCell cell) => cell.date == null),
          isNotEmpty,
        );

        final List<InteractiveRegion> dateActions = tester
            .widgetList<InteractiveRegion>(
              find.descendant(
                of: viewport,
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is InteractiveRegion &&
                      widget.semanticLabel != null &&
                      expectedDateLabels.contains(widget.semanticLabel),
                ),
              ),
            )
            .toList();
        expect(dateActions, hasLength(datedCellCount));
        expect(
          find.descendant(of: viewport, matching: find.byType(Focus)),
          findsNWidgets(datedCellCount),
        );
        expect(
          find.descendant(
            of: viewport,
            matching: find.byWidgetPredicate(
              (widget) => widget is Semantics && widget.properties.label == '',
            ),
          ),
          findsNothing,
        );

        for (final CalendarDayCell cell in cells.where(
          (CalendarDayCell item) => item.date != null,
        )) {
          final AnimalDate date = cell.date!;
          final String label = material.formatFullDate(date.toDateTime());
          expect(
            find.descendant(
              of: viewport,
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is InteractiveRegion &&
                    widget.semanticLabel == label,
              ),
            ),
            findsOneWidget,
          );
        }
      } finally {
        handle.dispose();
      }
    });
  });
}
