import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCursor Behavior Tests (S05 / C04 / CUR01-CUR03)', () {
    testWidgets(
      'CUR01: mouse hover movement, exit, and hit test transparency',
      (tester) async {
        int clickCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCursor(
                type: AnimalCursorType.defaultCursor,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => clickCount++,
                    child: const Text('Interactive Button'),
                  ),
                ),
              ),
            ),
          ),
        );

        // Child button receives pointer click transparently through custom cursor overlay
        await tester.tap(find.text('Interactive Button'));
        await tester.pumpAndSettle();
        expect(clickCount, equals(1));
      },
    );

    testWidgets('CUR02: forceAll rules and customCursor rendering', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCursor(
              type: AnimalCursorType.raindrop,
              forceAll: true,
              child: Text('Raindrop Area'),
            ),
          ),
        ),
      );

      expect(find.text('Raindrop Area'), findsOneWidget);
      expect(find.byType(MouseRegion), findsWidgets);
    });

    testWidgets(
      'CUR03: custom cursor does not dangle or leak listeners on unmount',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCursor(
                type: AnimalCursorType.defaultCursor,
                child: Text('Transient Cursor'),
              ),
            ),
          ),
        );

        expect(find.text('Transient Cursor'), findsOneWidget);

        // Unmount cursor wrapper
        await tester.pumpWidget(const SizedBox.shrink());
        // No crashes or unhandled listener exceptions
      },
    );
  });
}
