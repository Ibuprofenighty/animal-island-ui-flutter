import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTitle Semantics Tests (S05 / C06)', () {
    testWidgets(
      'AnimalTitle registers heading semantics node for screen readers',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalTitle(child: Text('Island Bulletin'))),
          ),
        );

        final handle = tester.ensureSemantics();
        final headerNode = find.bySemanticsLabel('Island Bulletin');
        expect(headerNode, findsOneWidget);
        final semantics = tester.getSemantics(headerNode);
        expect(semantics.flagsCollection.isHeader, isTrue);
        handle.dispose();
      },
    );

    testWidgets(
      'AnimalTitle supports custom semanticLabel overriding visual child',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTitle(
                semanticLabel: 'Important Island Bulletin Heading',
                child: Text('Bulletin'),
              ),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        expect(
          find.bySemanticsLabel(RegExp(r'Important Island Bulletin Heading')),
          findsOneWidget,
        );
        handle.dispose();
      },
    );
  });
}
