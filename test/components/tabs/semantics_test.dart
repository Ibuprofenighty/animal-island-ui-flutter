import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTabs Semantics & A11y Tests (C10 / TAB04)', () {
    testWidgets('tab items advertise selected and button semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTabs(
              selectedId: 'tab-${0}',
              onChanged: (_) {},
              tabs: [
                AnimalTabItem(id: 'tab-0', label: 'Fish Guide'),
                AnimalTabItem(id: 'tab-1', label: 'Bug Guide'),
              ],
            ),
          ),
        ),
      );

      final selectedTab = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.selected == true &&
            w.properties.button == true,
      );
      expect(selectedTab, findsOneWidget);

      final unselectedTab = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.selected == false &&
            w.properties.button == true,
      );
      expect(unselectedTab, findsOneWidget);
    });
  });
}
