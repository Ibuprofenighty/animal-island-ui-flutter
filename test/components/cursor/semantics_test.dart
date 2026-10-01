import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCursor Semantics Tests (S05 / C04)', () {
    testWidgets('AnimalCursor does not modify child semantics tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCursor(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Target Semantics'),
              ),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Target Semantics'), findsOneWidget);
      final btnSemantics = tester.getSemantics(find.byType(ElevatedButton));
      expect(btnSemantics.flagsCollection.isButton, isTrue);
      handle.dispose();
    });
  });
}
