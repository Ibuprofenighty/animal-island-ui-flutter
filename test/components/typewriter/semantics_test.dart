import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTypewriter Semantics & A11y Tests (C03 / TYP04)', () {
    testWidgets(
      'provides full text in semantics tree and excludes typing partials',
      (tester) async {
        const fullText = 'Complete speech balloon dialogue.';

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTypewriter(
                text: fullText,
                speed: Duration(milliseconds: 100),
              ),
            ),
          ),
        );

        // Verify semantics node contains full text immediately
        final semanticsFinder = find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == fullText,
        );
        expect(semanticsFinder, findsOneWidget);

        // Verify child Text.rich is excluded from spamming semantics
        final excludedFinder = find.descendant(
          of: semanticsFinder,
          matching: find.byType(ExcludeSemantics),
        );
        expect(excludedFinder, findsOneWidget);
      },
    );
  });
}
