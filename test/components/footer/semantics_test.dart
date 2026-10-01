import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalFooter Semantics Tests (S05 / C36)', () {
    testWidgets('AnimalFooter content is readable by screen readers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalFooter(
              content: Text('All Rights Reserved Animal Island 2026'),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel('All Rights Reserved Animal Island 2026'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}
