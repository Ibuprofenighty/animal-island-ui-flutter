import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/tooltip/tooltip_shape.dart';

void main() {
  group('AnimalTooltip State & Variant Tests (C23 / TIP02-TIP04)', () {
    testWidgets('renders standard variant with the theme tooltip radius', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTooltip(
              variant: AnimalTooltipVariant.standard,
              message: 'Standard Cozy Tooltip',
              child: Text('Hover Me'),
            ),
          ),
        ),
      );

      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      final tooltipWidget = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltipWidget.message, 'Standard Cozy Tooltip');
      expect(tooltipWidget.decoration, isA<BoxDecoration>());
      final boxDec = tooltipWidget.decoration as BoxDecoration;
      expect(boxDec.borderRadius, AnimalIslandTheme.light.radii.tooltipBorder);
    });

    testWidgets('renders island variant with AnimalIslandBubbleShapeBorder', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTooltip(
              variant: AnimalTooltipVariant.island,
              message: 'Island Speech Bubble',
              child: Text('Hover Me'),
            ),
          ),
        ),
      );

      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);

      final tooltipWidget = tester.widget<Tooltip>(tooltipFinder);
      expect(tooltipWidget.decoration, isA<ShapeDecoration>());
      final shapeDec = tooltipWidget.decoration as ShapeDecoration;
      expect(shapeDec.shape, isA<AnimalIslandBubbleShapeBorder>());
    });

    testWidgets('bordered false renders without border stroke', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTooltip(
              bordered: false,
              message: 'Unbordered tooltip',
              child: Text('Hover Me'),
            ),
          ),
        ),
      );

      final tooltipFinder = find.byType(Tooltip);
      final tooltipWidget = tester.widget<Tooltip>(tooltipFinder);
      final boxDec = tooltipWidget.decoration as BoxDecoration;
      expect(boxDec.border, isNull);
    });
  });
}
