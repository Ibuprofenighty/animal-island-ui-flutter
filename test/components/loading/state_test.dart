import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
// The particle painter is package-internal; tests observe it directly.
import 'package:animal_island_ui/src/components/loading/loading_painter.dart';

/// Particle counts of every snowflake painter in the tree.
List<int> _particleCounts(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((paint) => paint.painter)
    .whereType<SnowflakeOverlayPainter>()
    .map((painter) => painter.snowflakes.length)
    .toList();

void main() {
  group('AnimalLoading State & Clamp Tests (C25 / LOD01)', () {
    test('snowCount accepts 1..100 and rejects values outside it', () {
      expect(AnimalLoading.snowflake(snowCount: 1).snowCount, 1);
      expect(AnimalLoading.snowflake(snowCount: 100).snowCount, 100);
      expect(AnimalLoading(snowCount: 50).snowCount, 50);
      expect(() => AnimalLoading.snowflake(snowCount: 0), throwsRangeError);
      expect(() => AnimalLoading.snowflake(snowCount: -5), throwsRangeError);
      expect(() => AnimalLoading.snowflake(snowCount: 101), throwsRangeError);
      expect(() => AnimalLoading(snowCount: 250), throwsRangeError);
    });

    testWidgets(
      'switching types via didUpdateWidget re-synchronizes controllers',
      (tester) async {
        AnimalLoadingType currentType = AnimalLoadingType.spinner;
        int snowCount = 12;
        late StateSetter rebuild;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  rebuild = setState;
                  return AnimalLoading(
                    type: currentType,
                    tip: 'Dynamic Type',
                    fullScreen: true,
                    snowCount: snowCount,
                    snowSeed: 7,
                  );
                },
              ),
            ),
          ),
        );

        // One state owns exactly one ticking controller.
        expect(find.text('Dynamic Type'), findsOneWidget);
        expect(tester.binding.transientCallbackCount, 1);
        expect(_particleCounts(tester), isEmpty);

        rebuild(() => currentType = AnimalLoadingType.snowflake);
        await tester.pump();
        expect(find.text('Dynamic Type'), findsOneWidget);
        expect(tester.binding.transientCallbackCount, 1);
        expect(_particleCounts(tester), [12]);

        rebuild(() => snowCount = 30);
        await tester.pump();
        expect(_particleCounts(tester), [30]);

        // Leaving the snowflake type releases its particles.
        rebuild(() => currentType = AnimalLoadingType.dots);
        await tester.pump();
        expect(find.text('Dynamic Type'), findsOneWidget);
        expect(tester.binding.transientCallbackCount, 1);
        expect(_particleCounts(tester), isEmpty);

        for (int i = 0; i < 6; i++) {
          rebuild(
            () => currentType =
                AnimalLoadingType.values[i % AnimalLoadingType.values.length],
          );
          await tester.pump();
          expect(tester.binding.transientCallbackCount, 1);
        }

        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  });
}
