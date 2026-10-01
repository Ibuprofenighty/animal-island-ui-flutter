import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalButton State Tests (S05 / C01)', () {
    testWidgets('Button state transitions correctly across size variants', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalButton(
                  size: AnimalButtonSize.small,
                  onPressed: () {},
                  child: const Text('Small'),
                ),
                AnimalButton(
                  size: AnimalButtonSize.middle,
                  onPressed: () {},
                  child: const Text('Middle'),
                ),
                AnimalButton(
                  size: AnimalButtonSize.large,
                  onPressed: () {},
                  child: const Text('Large'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Small'), findsOneWidget);
      expect(find.text('Middle'), findsOneWidget);
      expect(find.text('Large'), findsOneWidget);

      final smallBox = tester.renderObject<RenderBox>(find.text('Small'));
      final largeBox = tester.renderObject<RenderBox>(find.text('Large'));
      expect(largeBox.size.height, greaterThan(smallBox.size.height));
    });

    testWidgets(
      'Button state transitions across tones: primary, neutral, success, warning, danger',
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
                    tone: AnimalButtonTone.primary,
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  AnimalButton(
                    tone: AnimalButtonTone.neutral,
                    onPressed: () {},
                    child: const Text('Neutral'),
                  ),
                  AnimalButton(
                    tone: AnimalButtonTone.success,
                    onPressed: () {},
                    child: const Text('Success'),
                  ),
                  AnimalButton(
                    tone: AnimalButtonTone.warning,
                    onPressed: () {},
                    child: const Text('Warning'),
                  ),
                  AnimalButton(
                    tone: AnimalButtonTone.danger,
                    onPressed: () {},
                    child: const Text('Danger'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(AnimalButton), findsNWidgets(5));
      },
    );

    testWidgets(
      'Button transitions smoothly between loading and normal states',
      (tester) async {
        bool isLoading = false;

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
                    loading: isLoading,
                    onPressed: () => setState(() => isLoading = !isLoading),
                    child: const Text('Submit'),
                  ),
                ),
              );
            },
          ),
        );

        expect(find.text('Submit'), findsOneWidget);
        expect(find.byType(SizedBox), findsWidgets);

        // Tap button to toggle loading
        await tester.tap(find.text('Submit'));
        await tester.pump();

        // In loading state, button remains visible
        expect(find.byType(AnimalButton), findsOneWidget);
      },
    );

    testWidgets('Button responds to AnimalIslandTheme dynamic changes', (
      tester,
    ) async {
      final themeNotifier = ValueNotifier<AnimalIslandTheme>(
        AnimalIslandTheme.light,
      );

      await tester.pumpWidget(
        ValueListenableBuilder<AnimalIslandTheme>(
          valueListenable: themeNotifier,
          builder: (context, currentTheme, _) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: currentTheme.toThemeData(),
              home: Scaffold(
                body: AnimalButton(
                  variant: AnimalButtonVariant.filled,
                  tone: AnimalButtonTone.primary,
                  onPressed: () {},
                  child: const Text('Themed Button'),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Themed Button'), findsOneWidget);

      // Switch to dark theme
      themeNotifier.value = AnimalIslandTheme.dark;
      await tester.pumpAndSettle();

      expect(find.text('Themed Button'), findsOneWidget);
    });
  });
}
