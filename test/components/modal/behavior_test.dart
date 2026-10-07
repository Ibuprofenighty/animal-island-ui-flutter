import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/modal/modal_surface.dart';

void main() {
  group('AnimalModal Behavior & Async Confirm Tests (C21 / MOD01-MOD04)', () {
    testWidgets(
      'MOD01: renders modal with organic surface and action buttons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AnimalModal.confirm(
                      context: context,
                      title: const Text('Island Notice'),
                      content: const Text('Turnip prices are soaring today!'),
                    );
                  },
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        expect(find.text('Island Notice'), findsOneWidget);
        expect(find.text('Turnip prices are soaring today!'), findsOneWidget);
        expect(find.byType(AnimalModalSurface), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Dismiss via cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Island Notice'), findsNothing);
      },
    );

    testWidgets(
      'MOD02: async onConfirm returning false keeps modal open; true closes modal',
      (tester) async {
        bool shouldSucceed = false;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AnimalModal.confirm(
                      context: context,
                      title: const Text('Async Test'),
                      content: const Text('Confirm deletion?'),
                      onConfirm: () async {
                        await Future<void>.delayed(
                          const Duration(milliseconds: 50),
                        );
                        return shouldSucceed;
                      },
                    );
                  },
                  child: const Text('Open Modal'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Modal'));
        await tester.pumpAndSettle();

        // Tap confirm when shouldSucceed is false
        await tester.tap(find.text('Confirm'));
        await tester.pump(const Duration(milliseconds: 60));
        await tester.pumpAndSettle();

        // Modal should remain open
        expect(find.text('Async Test'), findsOneWidget);

        // Now set shouldSucceed to true
        shouldSucceed = true;
        await tester.tap(find.text('Confirm'));
        await tester.pump(const Duration(milliseconds: 60));
        await tester.pumpAndSettle();

        // Modal should now be closed
        expect(find.text('Async Test'), findsNothing);
      },
    );

    testWidgets(
      'MOD04: showDialogue renders speaker, avatar, and typewriter text without dynamic child reflection',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AnimalModal.showDialogue(
                      context: context,
                      speaker: 'Tom Nook',
                      avatar: const Icon(Icons.star),
                      dialogue: 'Yes, yes! Welcome to the island!',
                    );
                  },
                  child: const Text('Talk to Nook'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Talk to Nook'));
        await tester.pumpAndSettle();

        expect(find.text('Tom Nook'), findsOneWidget);
        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.text('Yes, yes! Welcome to the island!'), findsOneWidget);
      },
    );
  });
}
