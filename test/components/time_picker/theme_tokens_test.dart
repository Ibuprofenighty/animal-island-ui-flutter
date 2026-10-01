import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/time_picker/time_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('time panel uses theme card, spacing, typography and accent', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      final now = DateTime.now();
      final initialHour = (now.hour + 12) % 24;
      AnimalTimeValue? changed;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalTimePickerPanel(
              value: AnimalTimeValue(hour: initialHour, minute: now.minute),
              showNow: true,
              allowClear: false,
              onChanged: (value) => changed = value,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final localizations = AnimalLocalizations.of(
        tester.element(find.byType(AnimalTimePickerPanel)),
      )!;

      final panel = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color ==
                    theme.colors.bgContent,
          );
      expect(
        (panel.decoration! as BoxDecoration).borderRadius,
        theme.radii.cardBorder,
      );
      expect(
        (panel.decoration! as BoxDecoration).border!.top.color,
        theme.colors.brightness == Brightness.dark
            ? theme.colors.border
            : theme.colors.borderLight,
      );
      expect(
        themeContrastRatio(
          (panel.decoration! as BoxDecoration).border!.top.color,
          theme.colors.bgContent,
        ),
        greaterThan(1.0),
        reason: '${theme.colors.brightness.name} time panel border pair',
      );
      expect(
        panel.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
      );

      final heading = tester.widget<Text>(
        find.text(localizations.timePickerTitle),
      );
      expect(heading.style!.fontSize, theme.typography.heading.fontSize);
      expect(
        heading.style!.letterSpacing,
        theme.typography.heading.letterSpacing,
      );
      expect(heading.style!.color, theme.colors.text);
      expect(
        themeContrastRatio(heading.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} time heading text pair',
      );
      expect(
        tester.widget<AnimalIcon>(find.byType(AnimalIcon).first).color,
        theme.colors.primaryText,
      );
      expect(
        themeContrastRatio(theme.colors.primaryText, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} clock icon pair',
      );

      final nowStyle = tester.widget<Text>(find.text('Now')).style!;
      expect(nowStyle.fontSize, theme.typography.caption.fontSize);
      expect(nowStyle.color, theme.colors.primaryText);
      expect(
        themeContrastRatio(nowStyle.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} Now label text pair',
      );
      final selectedLabel = localizations.timePickerWheelValue(
        initialHour,
        'hours',
      );
      final selectedSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere(
            (semantics) => semantics.properties.label == selectedLabel,
          );
      expect(selectedSemantics.properties.selected, isTrue);
      final selectedWheelText = tester.widget<Text>(
        find.descendant(
          of: find.byWidget(selectedSemantics),
          matching: find.byType(Text),
        ),
      );
      expect(
        selectedWheelText.style!.fontSize,
        theme.typography.subheading.fontSize,
      );
      expect(
        selectedWheelText.style!.letterSpacing,
        theme.typography.subheading.letterSpacing,
      );
      final nextHour = (initialHour + 1) % 24;
      final nextSemantics = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere(
            (semantics) =>
                semantics.properties.label ==
                localizations.timePickerWheelValue(nextHour, 'hours'),
          );
      expect(nextSemantics.properties.selected, isFalse);
      final nextText = tester.widget<Text>(
        find.descendant(
          of: find.byWidget(nextSemantics),
          matching: find.byType(Text),
        ),
      );
      expect(nextText.style!.fontSize, theme.typography.body.fontSize);
      expect(
        nextText.style!.letterSpacing,
        theme.typography.body.letterSpacing,
      );

      final activeBand = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color ==
                    theme.colors.primary.withValues(alpha: 0.15),
          );
      final bandDecoration = activeBand.decoration! as BoxDecoration;
      final highlightedSurface = Color.alphaBlend(
        bandDecoration.color!,
        theme.colors.bgContent,
      );
      expect(bandDecoration.borderRadius, theme.radii.pillBorder);
      expect(
        activeBand.margin,
        EdgeInsets.symmetric(horizontal: theme.spacing.xs),
      );
      expect(
        (bandDecoration.border! as Border).top.color,
        theme.colors.primaryActive.withValues(alpha: 0.4),
      );
      expect(
        themeContrastRatio(selectedWheelText.style!.color!, highlightedSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        themeContrastRatio(nextText.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
      );

      final hourWheel = tester
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .first;
      final activeController =
          hourWheel.controller! as FixedExtentScrollController;
      await tester.tap(find.text('Now'));
      await tester.pump();
      expect(activeController.position.isScrollingNotifier.value, isTrue);
      await tester.pump(theme.motion.fast);
      expect(activeController.selectedItem, changed!.hour);
    }
  });

  testWidgets('selected and unselected time text contrast on each active surface', (
    tester,
  ) async {
    final themes = animalIslandThemeVariants();
    const selectedHour = 8;
    for (final theme in themes) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalTimePickerPanel(
              value: AnimalTimeValue(hour: selectedHour, minute: 30),
              showNow: false,
              allowClear: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final localizations = AnimalLocalizations.of(
        tester.element(find.byType(AnimalTimePickerPanel)),
      )!;

      final heading = tester.widget<Text>(
        find.text(localizations.timePickerTitle),
      );
      expect(heading.style!.fontSize, theme.typography.heading.fontSize);
      expect(
        heading.style!.letterSpacing,
        theme.typography.heading.letterSpacing,
      );
      expect(heading.style!.color, theme.colors.text);
      expect(
        themeContrastRatio(heading.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
      );

      Semantics hourSemantics(int hour) => tester
          .widgetList<Semantics>(find.byType(Semantics))
          .singleWhere(
            (semantics) =>
                semantics.properties.label ==
                localizations.timePickerWheelValue(hour, 'hours'),
          );

      Text hourText(Semantics semantics) => tester.widget<Text>(
        find.descendant(
          of: find.byWidget(semantics),
          matching: find.byType(Text),
        ),
      );

      final selected = hourSemantics(selectedHour);
      expect(selected.properties.selected, isTrue);
      final selectedText = hourText(selected);
      expect(selectedText.style!.color, theme.colors.text);
      expect(
        selectedText.style!.fontSize,
        theme.typography.subheading.fontSize,
      );

      final adjacent = hourSemantics(selectedHour + 1);
      expect(adjacent.properties.selected, isFalse);
      final adjacentText = hourText(adjacent);
      expect(adjacentText.style!.color, theme.colors.textSecondary);
      expect(adjacentText.style!.fontSize, theme.typography.body.fontSize);

      final band = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color ==
                    theme.colors.primary.withValues(alpha: 0.15),
          );
      final bandDecoration = band.decoration! as BoxDecoration;
      final selectedSurface = Color.alphaBlend(
        bandDecoration.color!,
        theme.colors.bgContent,
      );
      expect(
        themeContrastRatio(selectedText.style!.color!, selectedSurface),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected time text pair',
      );
      expect(
        themeContrastRatio(adjacentText.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} unselected time text pair',
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalTimePickerPanel(
              value: AnimalTimeValue(hour: selectedHour, minute: 30),
              disabled: true,
              showNow: true,
              allowClear: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final disabledSelected = hourSemantics(selectedHour);
      expect(disabledSelected.properties.selected, isTrue);
      final disabledSelectedText = hourText(disabledSelected);
      expect(disabledSelectedText.style!.color, theme.colors.textDisabled);
      final disabledAdjacent = hourSemantics(selectedHour + 1);
      expect(disabledAdjacent.properties.selected, isFalse);
      final disabledAdjacentText = hourText(disabledAdjacent);
      expect(disabledAdjacentText.style!.color, theme.colors.textDisabled);

      final disabledBand = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).color ==
                    theme.colors.primary.withValues(alpha: 0.15),
          );
      final disabledSelectedSurface = Color.alphaBlend(
        (disabledBand.decoration! as BoxDecoration).color!,
        theme.colors.bgContent,
      );
      expect(
        themeContrastRatio(
          disabledSelectedText.style!.color!,
          disabledSelectedSurface,
        ),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} disabled selected wheel text pair; disabled exemption applies only while scrolling and callbacks are disabled',
      );
      expect(
        themeContrastRatio(
          disabledAdjacentText.style!.color!,
          theme.colors.bgContent,
        ),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} disabled adjacent wheel text pair',
      );
      final disabledHourWheel = tester
          .widgetList<ListWheelScrollView>(find.byType(ListWheelScrollView))
          .first;
      expect(disabledHourWheel.physics, isA<NeverScrollableScrollPhysics>());
      expect(disabledHourWheel.onSelectedItemChanged, isNull);
      final disabledNowRegion = tester.widget<InteractiveRegion>(
        find.ancestor(
          of: find.text('Now'),
          matching: find.byType(InteractiveRegion),
        ),
      );
      expect(disabledNowRegion.onPressed, isNull);
      expect(disabledNowRegion.disabled, isTrue);
      expect(
        tester.widget<Text>(find.text('Now')).style!.color,
        theme.colors.textDisabled,
      );
      expect(
        themeContrastRatio(theme.colors.textDisabled, theme.colors.bgContent),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled Now caption pair',
      );
    }
  });
}
