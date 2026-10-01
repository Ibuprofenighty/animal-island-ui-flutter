import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCard Semantics Tests (S05 / C05)', () {
    testWidgets(
      'Clickable card produces accessible button semantics with custom label',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                semanticLabel: 'Village Resident Card',
                onTap: () {},
                child: const Text('Tom Nook'),
              ),
            ),
          ),
        );

        expect(
          find.bySemanticsLabel(RegExp(r'Village Resident Card')),
          findsOneWidget,
        );
        handle.dispose();
      },
    );

    testWidgets('Static card does not advertise click actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalCard(child: Text('Plain Static Info'))),
        ),
      );

      final handle = tester.ensureSemantics();
      final cardSemantics = tester.getSemantics(find.byType(AnimalCard));
      expect(cardSemantics.flagsCollection.isButton, isFalse);
      handle.dispose();
    });
  });
}
