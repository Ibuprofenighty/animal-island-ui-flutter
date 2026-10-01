import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalDivider Behavior Tests (S05 / C07 / DIV01-DIV03)', () {
    testWidgets(
      'DIV01: renders plain, wavy, dashed, and preset variants (leaf, star, flower)',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalDivider(type: AnimalDividerType.solid),
                  AnimalDivider(type: AnimalDividerType.wavy),
                  AnimalDivider(type: AnimalDividerType.dashed),
                  AnimalDivider.leaf(),
                  AnimalDivider.star(),
                  AnimalDivider.flower(),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(AnimalDivider), findsNWidgets(6));
        expect(find.byType(CustomPaint), findsWidgets);
      },
    );

    testWidgets(
      'DIV02: renders divider with center child or icon without horizontal overflow',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalDivider(child: Text('Section Title'))),
          ),
        );

        expect(find.text('Section Title'), findsOneWidget);
      },
    );

    testWidgets(
      'DIV03: decorative divider does not create focus nodes or interactive noise',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalDivider(type: AnimalDividerType.wavy)),
          ),
        );

        final handle = tester.ensureSemantics();
        final dividerFinder = find.byType(AnimalDivider);
        expect(dividerFinder, findsOneWidget);
        // Pure decorative divider does not have button or focusable flags
        final semantics = tester.getSemantics(dividerFinder);
        expect(semantics.flagsCollection.isButton, isFalse);
        expect(semantics.flagsCollection.isTextField, isFalse);
        handle.dispose();
      },
    );
  });
}
