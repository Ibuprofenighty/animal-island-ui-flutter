import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalBackground Behavior Tests (S05 / C08 / BG01-BG03)', () {
    testWidgets(
      'BG01: bounded/unbounded constraints and expand true/false render without error',
      (tester) async {
        // 1. Expand false with child
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalBackground(
                expand: false,
                child: Text('Contained Content'),
              ),
            ),
          ),
        );
        expect(find.text('Contained Content'), findsOneWidget);

        // 2. Expand true inside unbounded vertical scroll view
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SingleChildScrollView(
                child: AnimalBackground(
                  expand: true,
                  child: SizedBox(
                    height: 300,
                    child: const Text('Scrollable Content'),
                  ),
                ),
              ),
            ),
          ),
        );
        expect(find.text('Scrollable Content'), findsOneWidget);

        // 3. Without child
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                width: 200,
                height: 200,
                child: AnimalBackground(),
              ),
            ),
          ),
        );
        expect(find.byType(AnimalBackground), findsOneWidget);
      },
    );

    testWidgets('BG02: renders background types (parchment, dots, grid)', (
      tester,
    ) async {
      for (final type in AnimalBackgroundType.values) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                width: 100,
                height: 100,
                child: AnimalBackground(type: type),
              ),
            ),
          ),
        );
        expect(find.byType(AnimalBackground), findsOneWidget);
      }
    });

    testWidgets(
      'BG03: background decoration does not block taps on child widgets',
      (tester) async {
        int buttonTaps = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalBackground(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => buttonTaps++,
                    child: const Text('Click Through'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Click Through'));
        await tester.pumpAndSettle();
        expect(buttonTaps, equals(1));
      },
    );
  });
}
