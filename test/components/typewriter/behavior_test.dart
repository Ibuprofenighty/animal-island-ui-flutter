import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group(
    'AnimalTypewriter Behavior & Linear Layout Tests (C03 / TYP01-TYP03)',
    () {
      testWidgets(
        'TYP01: types Unicode characters including multi-byte emoji without crashing',
        (tester) async {
          int completeCount = 0;
          const testString = 'Welcome to Animal Island! 🏝️✨';

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalTypewriter(
                  text: testString,
                  speed: const Duration(milliseconds: 50),
                  showCursor: true,
                  onComplete: () => completeCount++,
                ),
              ),
            ),
          );

          expect(completeCount, 0);

          // Step through typing duration
          final graphemeCount = testString.characters.length;
          for (int i = 0; i < graphemeCount + 2; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }

          expect(completeCount, 1);
          // Further pump does NOT call onComplete again
          await tester.pump(const Duration(milliseconds: 100));
          expect(completeCount, 1);
        },
      );

      testWidgets(
        'TYP02: text update resets index and restarts typing to new completion',
        (tester) async {
          int completeCount = 0;
          final textNotifier = ValueNotifier<String>('First');

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: ValueListenableBuilder<String>(
                  valueListenable: textNotifier,
                  builder: (context, text, _) {
                    return AnimalTypewriter(
                      text: text,
                      speed: const Duration(milliseconds: 50),
                      onComplete: () => completeCount++,
                    );
                  },
                ),
              ),
            ),
          );

          for (int i = 0; i < 7; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          expect(completeCount, 1);

          // Change text dynamically
          textNotifier.value = 'Second Text';
          await tester.pump();

          for (int i = 0; i < 15; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          expect(completeCount, 2);
        },
      );

      testWidgets(
        'TYP03: TickerMode disabled pauses typing and resumes on re-enable',
        (tester) async {
          final tickerNotifier = ValueNotifier<bool>(true);
          int completeCount = 0;

          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: ValueListenableBuilder<bool>(
                  valueListenable: tickerNotifier,
                  builder: (context, enabled, _) {
                    return TickerMode(
                      enabled: enabled,
                      child: AnimalTypewriter(
                        text: 'Long dialogue text to type out smoothly.',
                        speed: const Duration(milliseconds: 50),
                        onComplete: () => completeCount++,
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          // Type 3 characters
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pump(const Duration(milliseconds: 50));
          expect(completeCount, 0);

          // Disable TickerMode
          tickerNotifier.value = false;
          await tester.pump();

          // Advancing time should not complete while disabled
          await tester.pump(const Duration(milliseconds: 500));
          expect(completeCount, 0);

          // Re-enable TickerMode
          tickerNotifier.value = true;
          await tester.pump();

          for (int i = 0; i < 50; i++) {
            await tester.pump(const Duration(milliseconds: 50));
          }
          expect(completeCount, 1);
        },
      );
    },
  );
}
