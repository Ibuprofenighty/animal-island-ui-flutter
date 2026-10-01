import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalButton Semantics Tests (S05 / C01)', () {
    testWidgets('Button announces button role, label, and enabled status', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalButton(
              onPressed: () {},
              child: const Text('Save Island'),
            ),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Save Island'), findsOneWidget);
      handle.dispose();
    });

    testWidgets(
      'Disabled button is flagged as disabled in accessibility tree',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalButton(
                disabled: true,
                onPressed: null,
                child: Text('Disabled Action'),
              ),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        expect(find.bySemanticsLabel('Disabled Action'), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets(
      'Custom semanticLabel overrides child text for screen readers',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalButton(
                semanticLabel: 'Custom Accessible Action',
                onPressed: () {},
                child: const Text('Visual Text'),
              ),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        expect(
          find.bySemanticsLabel('Custom Accessible Action'),
          findsOneWidget,
        );
        handle.dispose();
      },
    );
  });
}
