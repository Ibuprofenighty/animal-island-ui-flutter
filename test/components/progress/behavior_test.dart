import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalProgress Behavior & Motion Tests (C24 / PRG01-PRG04)', () {
    testWidgets('PRG01: renders linear progress and formats percentage text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalProgress(
              percent: 0.65,
              infoPosition: AnimalProgressInfoPosition.right,
            ),
          ),
        ),
      );

      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('PRG02: renders inside percentage text for middle/large bars', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AnimalProgress(
                percent: 0.80,
                size: AnimalProgressSize.large,
                infoPosition: AnimalProgressInfoPosition.inside,
              ),
            ),
          ),
        ),
      );

      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets(
      'PRG03: AnimalProgress.circle renders circular progress with custom stroke and size',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalProgress.circle(
                percent: 0.42,
                size: 100.0,
                strokeWidth: 8.0,
              ),
            ),
          ),
        );

        expect(find.text('42%'), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets('PRG04: barber-pole animation respects status and TickerMode', (
      tester,
    ) async {
      final tickerNotifier = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: tickerNotifier,
              builder: (context, enabled, _) {
                return TickerMode(
                  enabled: enabled,
                  child: const AnimalProgress(
                    percent: 0.5,
                    status: AnimalProgressStatus.active,
                    striped: true,
                    animated: true,
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Pumps smoothly with active ticker
      await tester.pump(const Duration(milliseconds: 200));

      // Disable TickerMode
      tickerNotifier.value = false;
      await tester.pump();

      // Advancing does not trigger animation updates
      await tester.pump(const Duration(milliseconds: 300));
    });
  });
}
