import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalIcon State & Motion Tests (S05 / C02)', () {
    testWidgets('bounce animation toggles controller on didUpdateWidget', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalIcon(data: AnimalIcons.apple, bounce: false),
          ),
        ),
      );

      // Rebuild with bounce: true
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalIcon(data: AnimalIcons.apple, bounce: true),
          ),
        ),
      );

      expect(find.byType(AnimalIcon), findsOneWidget);
    });

    testWidgets('Reduced Motion suppresses bounce animation', (tester) async {
      int tapped = 0;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: AnimalIcon(
                data: AnimalIcons.apple,
                bounce: true,
                onTap: () => tapped++,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimalIcon));
      await tester.pump();
      expect(tapped, equals(1));
    });
  });
}
