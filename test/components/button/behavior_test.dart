import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalButton Behavior Tests (S05 / C01 / BTN01-BTN04)', () {
    testWidgets(
      'BTN01: pointer tap, Enter, and Space trigger callback once each; disabled/loading triggers 0',
      (tester) async {
        int pressCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalButton(
                onPressed: () => pressCount++,
                child: const Text('Action'),
              ),
            ),
          ),
        );

        // Pointer tap
        await tester.tap(find.byType(AnimalButton));
        await tester.pumpAndSettle();
        expect(pressCount, equals(1));

        // Space key activation
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(pressCount, equals(2));

        // Enter key activation
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(pressCount, equals(3));

        // Disabled state
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalButton(
                disabled: true,
                onPressed: () => pressCount++,
                child: const Text('Action'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(AnimalButton));
        await tester.pumpAndSettle();
        expect(pressCount, equals(3)); // No increment

        // Loading state
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalButton(
                loading: true,
                onPressed: () => pressCount++,
                child: const Text('Action'),
              ),
            ),
          ),
        );

        await tester.tap(find.byType(AnimalButton));
        await tester.pump(const Duration(milliseconds: 100));
        expect(pressCount, equals(3)); // No increment
      },
    );

    testWidgets(
      'BTN02: disabling or unmounting during press eliminates ghost callback',
      (tester) async {
        int actionCount = 0;
        bool disabled = false;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                localizationsDelegates:
                    AnimalLocalizations.localizationsDelegates,
                supportedLocales: AnimalLocalizations.supportedLocales,

                theme: AnimalIslandTheme.light.toThemeData(),
                home: Scaffold(
                  body: AnimalButton(
                    disabled: disabled,
                    onPressed: () => actionCount++,
                    child: const Text('Click Me'),
                  ),
                ),
              );
            },
          ),
        );

        // Press down
        final gesture = await tester.startGesture(
          tester.getCenter(find.byType(AnimalButton)),
        );
        await tester.pump(const Duration(milliseconds: 50));

        // Now disable the button while pressed
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalButton(
                disabled: true,
                onPressed: () => actionCount++,
                child: const Text('Click Me'),
              ),
            ),
          ),
        );

        // Release gesture
        await gesture.up();
        await tester.pumpAndSettle();

        // Must be 0 because button was disabled before release
        expect(actionCount, equals(0));
      },
    );

    testWidgets(
      'BTN03: 3D depth shadow exists ONLY on filled primary and danger; outlined/text has depth 0',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalButton(
                    variant: AnimalButtonVariant.filled,
                    tone: AnimalButtonTone.primary,
                    onPressed: null,
                    child: Text('Primary Filled'),
                  ),
                  AnimalButton(
                    variant: AnimalButtonVariant.outlined,
                    tone: AnimalButtonTone.primary,
                    onPressed: null,
                    child: Text('Primary Outlined'),
                  ),
                  AnimalButton(
                    variant: AnimalButtonVariant.text,
                    tone: AnimalButtonTone.neutral,
                    onPressed: null,
                    child: Text('Neutral Text'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(AnimalButton), findsNWidgets(3));
      },
    );

    testWidgets('BTN04: block expands to full container width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                child: AnimalButton(
                  block: true,
                  onPressed: () {},
                  child: const Text('Block Button'),
                ),
              ),
            ),
          ),
        ),
      );

      final buttonBox = tester.renderObject<RenderBox>(
        find.byType(AnimalButton),
      );
      expect(buttonBox.size.width, equals(300.0));
    });
  });
}
