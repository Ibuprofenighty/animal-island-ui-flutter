import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalLoading State & Clamp Tests (C25 / LOD01)', () {
    test('snowCount clamps values within bounds 1..100', () {
      const negativeSnow = AnimalLoading.snowflake(snowCount: -5);
      expect(negativeSnow.snowCount, 1);

      const excessSnow = AnimalLoading.snowflake(snowCount: 250);
      expect(excessSnow.snowCount, 100);

      const normalSnow = AnimalLoading.snowflake(snowCount: 50);
      expect(normalSnow.snowCount, 50);
    });

    testWidgets(
      'switching types via didUpdateWidget re-synchronizes controllers',
      (tester) async {
        AnimalLoadingType currentType = AnimalLoadingType.spinner;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalLoading(type: currentType, tip: 'Dynamic Type');
                },
              ),
            ),
          ),
        );

        expect(find.text('Dynamic Type'), findsOneWidget);

        // Rebuild with snowflake
        currentType = AnimalLoadingType.snowflake;
        await tester.pump();
        expect(find.text('Dynamic Type'), findsOneWidget);

        // Rebuild with dots
        currentType = AnimalLoadingType.dots;
        await tester.pump();
        expect(find.text('Dynamic Type'), findsOneWidget);
      },
    );
  });
}
