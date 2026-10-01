import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalFooter State & Theme Tests (S05 / C36)', () {
    testWidgets(
      'AnimalFooter repaints when theme changes between light and dark',
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
                  body: AnimalFooter(content: Text('Theme Adaptive Footer')),
                ),
              );
            },
          ),
        );

        expect(find.text('Theme Adaptive Footer'), findsOneWidget);

        themeNotifier.value = AnimalIslandTheme.dark;
        await tester.pumpAndSettle();
        expect(find.text('Theme Adaptive Footer'), findsOneWidget);
      },
    );
  });
}
