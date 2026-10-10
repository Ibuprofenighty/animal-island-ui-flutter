import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCollapse Semantics & A11y Tests (C09 / COL03)', () {
    testWidgets('header registers expanded semantics and keyboard activation', (
      tester,
    ) async {
      Set<String> active = <String>{};

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalCollapse(
                  activeIds: active,
                  onChanged: (ids) => setState(() => active = ids),
                  items: [
                    AnimalCollapseItem(
                      id: 'faq',
                      title: Text('Island Rules'),
                      content: Text('Keep the island clean.'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      final headerSemantics = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.expanded == false,
      );
      expect(headerSemantics, findsOneWidget);

      // Trigger keyboard activation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(active, {'faq'});

      final expandedSemantics = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.expanded == true,
      );
      expect(expandedSemantics, findsOneWidget);
    });
  });
}
