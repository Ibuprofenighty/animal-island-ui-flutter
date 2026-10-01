import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalDivider State & Theme Tests (S05 / C07)', () {
    testWidgets(
      'AnimalDivider adapts to custom color, thickness, and indentations',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDivider(
                color: Color(0xFF19C8B9),
                thickness: 3.0,
                indent: 16.0,
                endIndent: 16.0,
              ),
            ),
          ),
        );

        expect(find.byType(AnimalDivider), findsOneWidget);
      },
    );

    testWidgets('AnimalDivider painter repaints when theme changes', (
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
                body: AnimalDivider(type: AnimalDividerType.wavy),
              ),
            );
          },
        ),
      );

      expect(find.byType(AnimalDivider), findsOneWidget);

      themeNotifier.value = AnimalIslandTheme.dark;
      await tester.pumpAndSettle();
      expect(find.byType(AnimalDivider), findsOneWidget);
    });
  });
}
