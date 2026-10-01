import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCollapse Behavior & F27 Tests (C09 / COL01-COL02)', () {
    testWidgets(
      'F27 & COL01: sorting or inserting items preserves expansion states by stable id',
      (tester) async {
        final itemsInitial = [
          const AnimalCollapseItem(
            id: 'item_a',
            title: Text('Title A'),
            content: Text('Content A'),
          ),
          const AnimalCollapseItem(
            id: 'item_b',
            title: Text('Title B'),
            content: Text('Content B'),
          ),
          const AnimalCollapseItem(
            id: 'item_c',
            title: Text('Title C'),
            content: Text('Content C'),
          ),
        ];

        Set<String> active = {'item_b'};

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
                    items: itemsInitial,
                  );
                },
              ),
            ),
          ),
        );

        // Item B content should be visible, Item A and C hidden
        expect(find.text('Content B'), findsOneWidget);

        // Now reverse items order: [item_c, item_b, item_a]
        final itemsReversed = [
          const AnimalCollapseItem(
            id: 'item_c',
            title: Text('Title C'),
            content: Text('Content C'),
          ),
          const AnimalCollapseItem(
            id: 'item_b',
            title: Text('Title B'),
            content: Text('Content B'),
          ),
          const AnimalCollapseItem(
            id: 'item_a',
            title: Text('Title A'),
            content: Text('Content A'),
          ),
        ];

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
                    items: itemsReversed,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // In old positional implementation (F27), index 1 was expanded so whatever was at index 1 stayed open.
        // But now, item_b is still at index 1 here, but what if item_a was open?
        // Let's tap Title A to expand Item A
        await tester.tap(find.text('Title A'));
        await tester.pumpAndSettle();

        expect(active.contains('item_a'), isTrue);
        expect(active.contains('item_b'), isTrue);

        // Now reorder items so Item A is at the top: [item_a, item_c, item_b]
        final itemsReordered = [
          const AnimalCollapseItem(
            id: 'item_a',
            title: Text('Title A'),
            content: Text('Content A'),
          ),
          const AnimalCollapseItem(
            id: 'item_c',
            title: Text('Title C'),
            content: Text('Content C'),
          ),
          const AnimalCollapseItem(
            id: 'item_b',
            title: Text('Title B'),
            content: Text('Content B'),
          ),
        ];

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
                    items: itemsReordered,
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Item A and B should still be open, Item C should be closed
        expect(find.text('Content A'), findsOneWidget);
        expect(find.text('Content B'), findsOneWidget);
        expect(active, {'item_a', 'item_b'});
      },
    );

    testWidgets(
      'COL02: accordion mode guarantees mutually exclusive expansion',
      (tester) async {
        Set<String> active = {'item_1'};

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalCollapse(
                    accordion: true,
                    activeIds: active,
                    onChanged: (ids) => setState(() => active = ids),
                    items: const [
                      AnimalCollapseItem(
                        id: 'item_1',
                        title: Text('Q1'),
                        content: Text('A1'),
                      ),
                      AnimalCollapseItem(
                        id: 'item_2',
                        title: Text('Q2'),
                        content: Text('A2'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        expect(active, {'item_1'});

        // Tap Q2 -> should close Q1 and open Q2
        await tester.tap(find.text('Q2'));
        await tester.pumpAndSettle();

        expect(active, {'item_2'});

        // Tap Q2 again -> should close Q2, leaving none open
        await tester.tap(find.text('Q2'));
        await tester.pumpAndSettle();

        expect(active, isEmpty);
      },
    );

    testWidgets('AnimalCollapse.single factory correctly toggles expansion', (
      tester,
    ) async {
      bool expanded = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalCollapse.single(
                  question: const Text('Frequently Asked Question'),
                  answer: const Text('Detailed Helpful Answer'),
                  defaultExpanded: false,
                  onChanged: (val) => setState(() => expanded = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Frequently Asked Question'), findsOneWidget);

      await tester.tap(find.text('Frequently Asked Question'));
      await tester.pumpAndSettle();

      expect(expanded, isTrue);
    });
  });
}
