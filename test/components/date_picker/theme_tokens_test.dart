import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('date panel uses theme card, spacing, typography and tone pairs', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalDatePickerPanel(
              value: AnimalDate(2024, 5, 10),
              disabledDate: (date) =>
                  date.year == 2024 && date.month == 5 && date.day == 11,
              showToday: true,
              allowClear: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final materialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );

      final panel = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color ==
                    theme.colors.bgContent,
          );
      final decoration = panel.decoration! as BoxDecoration;
      expect(decoration.borderRadius, theme.radii.cardBorder);
      expect(panel.padding, EdgeInsets.all(theme.spacing.md));
      final panelBorder = theme.colors.brightness == Brightness.dark
          ? theme.colors.border
          : theme.colors.borderLight;
      expect(decoration.border!.top.color, panelBorder);
      expect(
        themeContrastRatio(panelBorder, theme.colors.bgContent),
        greaterThan(1.0),
        reason: '${theme.colors.brightness.name} date panel border pair',
      );

      final monthTitle = tester.widget<Text>(
        find.text(materialLocalizations.formatMonthYear(DateTime(2024, 5))),
      );
      expect(monthTitle.style!.fontSize, 15.0);
      expect(
        monthTitle.style!.letterSpacing,
        theme.typography.heading.letterSpacing,
      );
      expect(monthTitle.style!.color, theme.colors.text);
      expect(
        themeContrastRatio(monthTitle.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} date heading text pair',
      );
      final weekdayHeader = find.byWidgetPredicate((widget) {
        if (widget is! Row || widget.children.length != 7) {
          return false;
        }
        return widget.children.every(
          (child) =>
              child is SizedBox &&
              child.width == 48 &&
              child.child is Center &&
              (child.child! as Center).child is Text,
        );
      });
      final weekday = tester.widget<Text>(
        find
            .descendant(
              of: weekdayHeader,
              matching: find.text(materialLocalizations.narrowWeekdays.first),
            )
            .first,
      );
      expect(weekday.style!.fontSize, theme.typography.caption.fontSize);
      expect(weekday.style!.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(weekday.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} weekday text pair',
      );

      Semantics daySemantics(String date) => tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere((semantics) => semantics.properties.label == date);

      Text dayText(Semantics semantics, String day) => tester.widget<Text>(
        find.descendant(of: find.byWidget(semantics), matching: find.text(day)),
      );

      Container dayCell(Semantics semantics, Color expectedColor) =>
          tester.widget<Container>(
            find.descendant(
              of: find.byWidget(semantics),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is Container &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration! as BoxDecoration).color ==
                        expectedColor,
              ),
            ),
          );

      final selectedSemantics = daySemantics(
        materialLocalizations.formatFullDate(DateTime(2024, 5, 10)),
      );
      expect(selectedSemantics.properties.selected, isTrue);
      expect(selectedSemantics.properties.enabled, isTrue);
      final selectedDay = dayText(selectedSemantics, '10');
      expect(selectedDay.style!.fontSize, 13.0);
      expect(selectedDay.style!.color, theme.colors.onPrimary);
      expect(
        selectedDay.style!.letterSpacing,
        theme.typography.body.letterSpacing,
      );
      final selectedDecoration =
          dayCell(selectedSemantics, theme.colors.primary).decoration!
              as BoxDecoration;
      expect(selectedDecoration.color, theme.colors.primary);
      expect(selectedDecoration.shape, BoxShape.circle);
      expect(
        themeContrastRatio(
          selectedDay.style!.color!,
          selectedDecoration.color!,
        ),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected date text pair',
      );

      final disabledSemantics = daySemantics(
        materialLocalizations.formatFullDate(DateTime(2024, 5, 11)),
      );
      expect(disabledSemantics.properties.selected, isFalse);
      expect(disabledSemantics.properties.enabled, isFalse);
      final disabledDay = dayText(disabledSemantics, '11');
      expect(disabledDay.style!.color, theme.colors.textDisabled);
      expect(
        themeContrastRatio(disabledDay.style!.color!, theme.colors.bgContent),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled date cell text pair; exemption is scoped to this disabled cell',
      );

      final adjacentSemantics = daySemantics(
        materialLocalizations.formatFullDate(DateTime(2024, 4, 28)),
      );
      expect(adjacentSemantics.properties.enabled, isTrue);
      final adjacentDay = dayText(adjacentSemantics, '28');
      expect(adjacentDay.style!.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(adjacentDay.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} adjacent-month text pair',
      );

      final todayStyle = tester.widget<Text>(find.text('Today')).style!;
      expect(todayStyle.fontSize, theme.typography.caption.fontSize);
      expect(todayStyle.color, theme.colors.primaryText);
      expect(
        themeContrastRatio(todayStyle.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} Today label text pair',
      );

      final dateGridScrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(dateGridScrollView.scrollDirection, Axis.horizontal);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalDatePickerPanel(
              value: AnimalDate(2024, 5, 10),
              picker: AnimalDatePickerMode.month,
              showToday: false,
              allowClear: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final monthMaterialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );
      final selectedMonthSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere(
            (semantics) =>
                semantics.properties.label ==
                monthMaterialLocalizations.formatMonthYear(DateTime(2024, 5)),
          );
      expect(selectedMonthSemantics.properties.selected, isTrue);
      expect(selectedMonthSemantics.properties.enabled, isTrue);
      final selectedMonth = tester.widget<Text>(
        find.descendant(
          of: find.byWidget(selectedMonthSemantics),
          matching: find.text('May'),
        ),
      );
      expect(selectedMonth.style!.color, theme.colors.onPrimary);
      final selectedMonthCell = tester.widget<Container>(
        find.descendant(
          of: find.byWidget(selectedMonthSemantics),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color ==
                    theme.colors.primary,
          ),
        ),
      );
      final monthDecoration = selectedMonthCell.decoration! as BoxDecoration;
      expect(monthDecoration.color, theme.colors.primary);
      expect(monthDecoration.borderRadius, theme.radii.pillBorder);
      expect(
        themeContrastRatio(selectedMonth.style!.color!, monthDecoration.color!),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected month text pair',
      );
    }
  });

  testWidgets(
    'date range endpoints and in-range days use contrasting theme pairs',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ObjectKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: AnimalDatePickerPanel(
                range: true,
                rangeValue: AnimalDateRange(
                  start: AnimalDate(2024, 5, 10),
                  end: AnimalDate(2024, 5, 15),
                ),
                showToday: false,
                allowClear: false,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        final materialLocalizations = MaterialLocalizations.of(
          tester.element(find.byType(AnimalDatePickerPanel)),
        );

        Semantics dateSemantics(DateTime date) => tester
            .widgetList<Semantics>(find.byType(Semantics))
            .singleWhere(
              (semantics) =>
                  semantics.properties.label ==
                  materialLocalizations.formatFullDate(date),
            );

        Text dateText(Semantics semantics, String day) => tester.widget<Text>(
          find.descendant(
            of: find.byWidget(semantics),
            matching: find.text(day),
          ),
        );

        Container dateCell(Semantics semantics, Color expectedColor) =>
            tester.widget<Container>(
              find.descendant(
                of: find.byWidget(semantics),
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Container &&
                      widget.decoration is BoxDecoration &&
                      (widget.decoration! as BoxDecoration).color ==
                          expectedColor,
                ),
              ),
            );

        for (final date in <(DateTime, String)>[
          (DateTime(2024, 5, 10), '10'),
          (DateTime(2024, 5, 15), '15'),
        ]) {
          final semantics = dateSemantics(date.$1);
          expect(semantics.properties.selected, isTrue);
          expect(semantics.properties.enabled, isTrue);
          final text = dateText(semantics, date.$2);
          expect(text.style!.color, theme.colors.onWarning);
          final decoration =
              dateCell(semantics, theme.colors.warning).decoration!
                  as BoxDecoration;
          expect(decoration.color, theme.colors.warning);
          expect(
            themeContrastRatio(text.style!.color!, decoration.color!),
            greaterThanOrEqualTo(4.5),
            reason: '${theme.colors.brightness.name} range endpoint pair',
          );
        }

        final inRangeSemantics = dateSemantics(DateTime(2024, 5, 12));
        expect(inRangeSemantics.properties.selected, isFalse);
        expect(inRangeSemantics.properties.enabled, isTrue);
        final inRangeText = dateText(inRangeSemantics, '12');
        expect(inRangeText.style!.color, theme.colors.text);
        final rangeFill = theme.colors.warning.withValues(alpha: 0.18);
        final rangeSurface = Color.alphaBlend(
          rangeFill,
          theme.colors.bgContent,
        );
        final inRangeCell = dateCell(inRangeSemantics, rangeFill);
        expect((inRangeCell.decoration! as BoxDecoration).color, rangeFill);
        expect(
          themeContrastRatio(inRangeText.style!.color!, rangeSurface),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.colors.brightness.name} range interior text pair',
        );
      }
    },
  );
}
