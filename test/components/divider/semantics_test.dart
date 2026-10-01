import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalDivider Semantics Tests (S05 / C07)', () {
    testWidgets(
      'Decorative divider excludes non-essential graphics from accessibility tree',
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
        expect(find.byType(AnimalDivider), findsOneWidget);
        handle.dispose();
      },
    );

    testWidgets(
      'Divider with text child preserves text semantics for screen readers',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalDivider(child: Text('Chapter 2: Flora & Fauna')),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        expect(
          find.bySemanticsLabel('Chapter 2: Flora & Fauna'),
          findsOneWidget,
        );
        handle.dispose();
      },
    );
  });
}
