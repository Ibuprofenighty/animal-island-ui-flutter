import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';

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
        final autoPlayNotifier = ValueNotifier<bool>(true);
        final clock = FakeClock();
        final changes = <int>[];

        Future<void> pumpElapsed(Duration elapsed) async {
          clock.advanceMonotonic(elapsed);
          await tester.pump(elapsed);
        }

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: tickerNotifier,
                builder: (context, enabled, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: autoPlayNotifier,
                    builder: (context, autoPlay, child) {
                      return TickerMode(
                        enabled: enabled,
                        child: AnimalCarousel(
                          height: 150,
                          autoPlay: autoPlay,
                          autoPlayInterval: const Duration(milliseconds: 100),
                          clock: clock,
                          onChange: changes.add,
                          items: const [Text('Slide A'), Text('Slide B')],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Slide A'), findsOneWidget);
        final pageController = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;

        // Disable TickerMode
        tickerNotifier.value = false;
        await tester.pump();

        await pumpElapsed(const Duration(milliseconds: 300));
        expect(
          pageController.position.isScrollingNotifier.value,
          isFalse,
          reason: 'CAR02_PAUSED_AUTOPLAY_STARTED_SCROLL',
        );
        expect(changes, isEmpty);
        expect(pageController.page, 0);
        expect(find.text('Slide A'), findsOneWidget);

        // Re-enable TickerMode
        tickerNotifier.value = true;
        await tester.pump();

        // The normal 100 ms interval must elapse after resume, with no catch-up.
        await pumpElapsed(const Duration(milliseconds: 50));
        expect(pageController.position.isScrollingNotifier.value, isFalse);
        await pumpElapsed(const Duration(milliseconds: 50));
        expect(pageController.position.isScrollingNotifier.value, isTrue);

        // Let this one in-flight transition finish without another autoplay tick.
        autoPlayNotifier.value = false;
        await tester.pump();
        for (int i = 0; i < 6; i++) {
          await pumpElapsed(const Duration(milliseconds: 50));
        }
        expect(pageController.page, 1);
        expect(changes, <int>[1]);
        expect(find.text('Slide B'), findsOneWidget);
      },
    );
  });
}
