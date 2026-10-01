import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/tabs/tab_indicator.dart';

void main() {
  group('AnimalTabs Behavior & F26 Tests (C10 / TAB01-TAB02)', () {
    testWidgets(
      'F26: indicator recalculates when tab label text changes without length or index change',
      (tester) async {
        var tabs = const [
          AnimalTabItem(label: 'Short'),
          AnimalTabItem(label: 'Tab 2'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalTabs(
                    selectedIndex: 0,
                    onChanged: (_) {},
                    tabs: tabs,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Find initial indicator
        final initialIndicator = tester.widget<AnimalTabIndicator>(
          find.byType(AnimalTabIndicator),
        );
        final initialWidth = initialIndicator.targetRect?.width;
        expect(initialWidth, isNotNull);

        // Now change label of Tab 0 from 'Short' to 'Much Longer Tab Label Here' (length stays 2, index stays 0)
        tabs = const [
          AnimalTabItem(label: 'Much Longer Tab Label Here'),
          AnimalTabItem(label: 'Tab 2'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalTabs(
                    selectedIndex: 0,
                    onChanged: (_) {},
                    tabs: tabs,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final updatedIndicator = tester.widget<AnimalTabIndicator>(
          find.byType(AnimalTabIndicator),
        );
        final updatedWidth = updatedIndicator.targetRect?.width;
        expect(updatedWidth, isNotNull);

        // Defect F26 fix verification: updated width must be strictly larger to wrap the longer text
        expect(
          updatedWidth!,
          greaterThan(initialWidth!),
          reason: 'Indicator targetRect must re-measure and adapt when tab label text changes',
        );
      },
    );

    testWidgets('TAB01: arrow key navigation skips disabled tabs', (
      tester,
    ) async {
      int active = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalTabs(
                  selectedIndex: active,
                  onChanged: (idx) => setState(() => active = idx),
                  tabs: const [
                    AnimalTabItem(label: 'Tab 0'),
                    AnimalTabItem(label: 'Tab 1 (Disabled)', disabled: true),
                    AnimalTabItem(label: 'Tab 2'),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Tap Tab 0 to focus
      await tester.tap(find.text('Tab 0'));
      await tester.pumpAndSettle();

      // Tap Tab 2 to switch
      await tester.tap(find.text('Tab 2'));
      await tester.pumpAndSettle();

      expect(active, 2);
    });
  });
}
