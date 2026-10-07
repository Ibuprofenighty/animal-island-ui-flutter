import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalDrawer Behavior & Placement Tests (C22 / DRW01-DRW03)', () {
    testWidgets(
      'DRW01 & DRW02: renders drawer and maskClosable false prevents barrier dismissal',
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
                    AnimalDrawer.show<void>(
                      context: context,
                      placement: AnimalDrawerPlacement.right,
                      maskClosable: false,
                      title: const Text('Island Settings'),
                      builder: (context, close) =>
                          const Text('Audio and graphics settings'),
                    );
                  },
                  child: const Text('Open Drawer'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Drawer'));
        await tester.pumpAndSettle();

        expect(find.text('Island Settings'), findsOneWidget);
        expect(find.text('Audio and graphics settings'), findsOneWidget);

        // Tap on modal barrier (outside drawer)
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();

        // Drawer should remain open because maskClosable is false
        expect(find.text('Island Settings'), findsOneWidget);

        // Tapping close button dismisses drawer
        final closeButton = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Close drawer',
        );
        expect(closeButton, findsOneWidget);

        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        expect(find.text('Island Settings'), findsNothing);
      },
    );

    testWidgets('DRW01: supports top, bottom, and left placements', (
      tester,
    ) async {
      for (final placement in [
        AnimalDrawerPlacement.left,
        AnimalDrawerPlacement.top,
        AnimalDrawerPlacement.bottom,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    AnimalDrawer.show<void>(
                      context: context,
                      placement: placement,
                      title: Text('Drawer $placement'),
                      builder: (context, close) => const Text('Content'),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.text('Drawer $placement'), findsOneWidget);

        final closeButton = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Close drawer',
        );
        await tester.tap(closeButton);
        await tester.pumpAndSettle();

        expect(find.text('Drawer $placement'), findsNothing);
      }
    });
  });
}
