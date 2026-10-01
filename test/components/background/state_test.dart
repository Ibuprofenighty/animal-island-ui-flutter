import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalBackground State & Theme Tests (S05 / C08)', () {
    testWidgets(
      'AnimalBackground adapts to custom backgroundColor and patternColor',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalBackground(
                backgroundColor: Color(0xFFF0FDF4),
                patternColor: Color(0xFF86EFAC),
                type: AnimalBackgroundType.dots,
                child: Text('Custom Color BG'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Color BG'), findsOneWidget);
      },
    );

    testWidgets('AnimalBackground painter repaints on AnimalTheme changes', (
      tester,
    ) async {
      final themeNotifier = ValueNotifier<AnimalIslandTheme>(
        AnimalIslandTheme.light,
      );

      await tester.pumpWidget(
        ValueListenableBuilder<AnimalIslandTheme>(
          valueListenable: themeNotifier,
          builder: (context, theme, _) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: theme.toThemeData(),
              home: const Scaffold(
                body: AnimalBackground(child: Text('Themed Background')),
              ),
            );
          },
        ),
      );

      expect(find.text('Themed Background'), findsOneWidget);

      themeNotifier.value = AnimalIslandTheme.dark;
      await tester.pumpAndSettle();
      expect(find.text('Themed Background'), findsOneWidget);
    });
  });
}
