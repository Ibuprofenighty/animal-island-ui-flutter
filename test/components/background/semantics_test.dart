import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalBackground Semantics Tests (S05 / C08)', () {
    testWidgets(
      'Decorative background does not generate accessibility tree noise',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalBackground(
                type: AnimalBackgroundType.dots,
                child: Text('Meaningful Content'),
              ),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        expect(find.bySemanticsLabel('Meaningful Content'), findsOneWidget);
        final bgFinder = find.byType(AnimalBackground);
        final bgSemantics = tester.getSemantics(bgFinder);
        expect(bgSemantics.flagsCollection.isButton, isFalse);
        handle.dispose();
      },
    );
  });
}
