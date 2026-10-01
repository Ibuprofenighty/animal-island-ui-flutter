import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';

void main() {
  group('AnimalTime Behavior & Semantics Tests (C29 / TIM01-TIM03)', () {
    testWidgets('TIM01: renders formatted time snapshot', (tester) async {
      final staticTime = DateTime(2026, 9, 13, 9, 5, 8);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalTime(time: staticTime)),
        ),
      );

      expect(find.text('09:05:08'), findsOneWidget);
    });

    testWidgets('TIM02: live mode ticks with clock updates', (tester) async {
      final fakeClock = FakeClock(DateTime(2026, 9, 13, 10, 15, 30));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalTime(live: true, clock: fakeClock)),
        ),
      );

      expect(find.text('10:15:30'), findsOneWidget);

      fakeClock.advance(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('10:15:31'), findsOneWidget);
    });

    testWidgets(
      'TIM03: liveRegion defaults to false to prevent a11y flooding',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTime(time: DateTime(2026, 9, 13, 14, 0, 0)),
            ),
          ),
        );

        final semantics = tester.widget<Semantics>(
          find
              .descendant(
                of: find.byType(AnimalTime),
                matching: find.byType(Semantics),
              )
              .first,
        );
        expect(semantics.properties.liveRegion, isFalse);
      },
    );
  });
}
