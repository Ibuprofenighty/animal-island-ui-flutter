import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';

void main() {
  group('AnimalCountdown Behavior & Clock Tests (C28 / CTD01-CTD04)', () {
    testWidgets(
      'CTD01: remaining mode decrements and calls onFinish exactly once',
      (tester) async {
        int finishCount = 0;
        Duration? lastChange;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCountdown(
                remaining: const Duration(seconds: 3),
                onChange: (d) => lastChange = d,
                onFinish: () => finishCount++,
              ),
            ),
          ),
        );

        expect(finishCount, 0);

        // Tick 1
        await tester.pump(const Duration(seconds: 1));
        expect(lastChange?.inSeconds, 2);
        expect(finishCount, 0);

        // Tick 2
        await tester.pump(const Duration(seconds: 1));
        expect(lastChange?.inSeconds, 1);
        expect(finishCount, 0);

        // Tick 3 (completion)
        await tester.pump(const Duration(seconds: 1));
        expect(finishCount, 1);

        // Extra ticks do not fire onFinish again
        await tester.pump(const Duration(seconds: 2));
        expect(finishCount, 1);
      },
    );

    testWidgets(
      'CTD02: targetTime with FakeClock provides deterministic stepping',
      (tester) async {
        final fakeClock = FakeClock(DateTime(2026, 9, 13, 12, 0, 0));
        final target = DateTime(2026, 9, 13, 12, 0, 5);
        int finishCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCountdown(
                targetTime: target,
                clock: fakeClock,
                onFinish: () => finishCount++,
              ),
            ),
          ),
        );

        expect(finishCount, 0);

        // Advance clock by 3 seconds
        fakeClock.advance(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 1));
        expect(finishCount, 0);

        // Advance clock past target
        fakeClock.advance(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 1));
        expect(finishCount, 1);
      },
    );

    testWidgets('CTD03: initial zero duration invokes onFinish exactly once', (
      tester,
    ) async {
      int finishCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCountdown(
              remaining: Duration.zero,
              onFinish: () => finishCount++,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(finishCount, 1);
    });
  });
}
