import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCarousel Behavior Tests (C11 / CAR01-CAR03)', () {
    testWidgets('CAR01: arrow buttons advance and loop slides', (tester) async {
      int active = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCarousel(
              height: 150,
              showArrows: true,
              loop: true,
              onChange: (idx) => active = idx,
              items: const [Text('Slide 0'), Text('Slide 1'), Text('Slide 2')],
            ),
          ),
        ),
      );

      expect(find.text('Slide 0'), findsOneWidget);

      // Tap Next arrow
      final nextFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Next slide',
      );
      expect(nextFinder, findsOneWidget);

      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      expect(active, 1);
      expect(find.text('Slide 1'), findsOneWidget);
    });

    testWidgets(
      'CAR02: TickerMode disabled stops autoplay timer and resumes on enable',
      (tester) async {
        final tickerNotifier = ValueNotifier<bool>(true);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: tickerNotifier,
                builder: (context, enabled, child) {
                  return TickerMode(
                    enabled: enabled,
                    child: AnimalCarousel(
                      height: 150,
                      autoPlayInterval: const Duration(milliseconds: 100),
                      items: const [Text('Slide A'), Text('Slide B')],
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Slide A'), findsOneWidget);

        // Disable TickerMode
        tickerNotifier.value = false;
        await tester.pump();

        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Slide A'), findsOneWidget);

        // Re-enable TickerMode
        tickerNotifier.value = true;
        await tester.pump();

        // Step through timer trigger (100ms) + animation duration (250ms)
        for (int i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(find.text('Slide B'), findsOneWidget);
      },
    );
  });
}
