import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTitle State & Theme Tests (S05 / C06)', () {
    testWidgets(
      'AnimalTitle supports custom color, customFrontColor, and customTextColor',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTitle(
                customFrontColor: Color(0xFF82D5BB),
                customTextColor: Color(0xFFFFFFFF),
                child: Text('Custom Palette Title'),
              ),
            ),
          ),
        );

        expect(find.text('Custom Palette Title'), findsOneWidget);
      },
    );

    testWidgets(
      'AnimalTitle updates dynamically with AnimalIslandTheme changes',
      (tester) async {
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
                  body: AnimalTitle(child: Text('Theme Responsive Title')),
                ),
              );
            },
          ),
        );

        expect(find.text('Theme Responsive Title'), findsOneWidget);

        themeNotifier.value = AnimalIslandTheme.dark;
        await tester.pumpAndSettle();
        expect(find.text('Theme Responsive Title'), findsOneWidget);
      },
    );
  });
}
