import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  _navigationOracles();
  group('AnimalCollapse Behavior & F27 Tests (C09 / COL01-COL02)', () {
    testWidgets(
      'F27 & COL01: sorting or inserting items preserves expansion states by stable id',
      (tester) async {
        final itemsInitial = [
          AnimalCollapseItem(
            id: 'item_a',
            title: Text('Title A'),
            content: Text('Content A'),
          ),
          AnimalCollapseItem(
            id: 'item_b',
            title: Text('Title B'),
            content: Text('Content B'),
          ),
          AnimalCollapseItem(
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
          AnimalCollapseItem(
            id: 'item_c',
            title: Text('Title C'),
            content: Text('Content C'),
          ),
          AnimalCollapseItem(
            id: 'item_b',
            title: Text('Title B'),
            content: Text('Content B'),
          ),
          AnimalCollapseItem(
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
          AnimalCollapseItem(
            id: 'item_a',
            title: Text('Title A'),
            content: Text('Content A'),
          ),
          AnimalCollapseItem(
            id: 'item_c',
            title: Text('Title C'),
            content: Text('Content C'),
          ),
          AnimalCollapseItem(
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
                    items: [
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

Widget _navigationApp(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);
void _navigationOracles() {
  testWidgets(
    'COL01 defaults remain valid at construction and cleaned deletion preserves mounted expansion',
    (tester) async {
      var ids = ['a', 'b'];
      var initial = <String>{'b'};
      final proposals = <Set<String>>[];
      Widget app() => _navigationApp(
        AnimalCollapse(
          key: const ValueKey('strict-default-collapse'),
          items: [
            for (final id in ids)
              AnimalCollapseItem(
                id: id,
                title: Text('Header $id'),
                content: Text('Content $id'),
              ),
          ],
          defaultActiveIds: initial,
          onChanged: proposals.add,
        ),
      );
      bool expanded(String id) => tester
          .widgetList<Semantics>(
            find.ancestor(
              of: find.text('Header $id'),
              matching: find.byType(Semantics),
            ),
          )
          .singleWhere((node) => node.properties.expanded != null)
          .properties
          .expanded!;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final state = tester.state(find.byType(AnimalCollapse));
      expect(expanded('a'), isFalse);
      expect(expanded('b'), isTrue);
      initial = {'a'};
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(AnimalCollapse)), same(state));
      expect(expanded('a'), isFalse);
      expect(expanded('b'), isTrue);
      initial = {'b'};
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      ids = ['a'];
      expect(app, throwsArgumentError);
      initial = {};
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(AnimalCollapse)), same(state));
      expect(expanded('a'), isFalse);
      ids = [];
      expect(
        () => AnimalCollapse(items: [], defaultActiveIds: {'a'}),
        throwsArgumentError,
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(AnimalCollapse)), same(state));
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((node) => node.properties.expanded != null),
        isEmpty,
      );
      expect(proposals, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  test('COL02 constructor rejects invalid identity and accordion input and freezes values', () {
    final items = [
      AnimalCollapseItem(
        id: 'a',
        title: const Text('A'),
        content: const Text('body'),
      ),
    ];
    final expanded = {'a'};
    final widget = AnimalCollapse(items: items, activeIds: expanded);
    items.clear();
    expanded.clear();
    expect(widget.items.single.id, 'a');
    expect(widget.activeIds, {'a'});
    expect(
      () => AnimalCollapseItem(
        id: '',
        title: const Text('bad'),
        content: const Text('bad'),
      ),
      throwsArgumentError,
    );
    expect(
      () => AnimalCollapse(items: [], activeIds: {'gone'}),
      throwsArgumentError,
    );
    expect(
      () => AnimalCollapse(items: [widget.items.single, widget.items.single]),
      throwsArgumentError,
    );
    expect(
      () => AnimalCollapse(
        items: [
          widget.items.single,
          AnimalCollapseItem(
            id: 'b',
            title: const Text('B'),
            content: const Text('B'),
          ),
        ],
        accordion: true,
        activeIds: {'a', 'b'},
      ),
      throwsArgumentError,
    );
  });
  testWidgets(
    'COL01 reordered input state and focus remain with their ID and deletion releases it',
    (tester) async {
      var ids = ['a', 'b', 'c'];
      Widget app() => _navigationApp(
        AnimalCollapse(
          items: [
            for (final id in ids)
              AnimalCollapseItem(
                id: id,
                title: Text('Header $id'),
                content: TextField(key: ValueKey('field-$id')),
              ),
          ],
          defaultActiveIds: ids.toSet(),
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('field-a')),
        'belongs to A',
      );
      await tester.pump();
      final focus = FocusManager.instance.primaryFocus;
      ids = ['c', 'a', 'b'];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, same(focus));
      final editable = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const ValueKey('field-a')),
          matching: find.byType(EditableText),
        ),
      );
      expect(editable.controller.text, 'belongs to A');
      ids = ['c', 'b'];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('field-a')), findsNothing);
      expect(FocusManager.instance.primaryFocus, isNot(same(focus)));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'COL03 keyboard rejected proposal preserves expansion and hides focus and semantics',
    (tester) async {
      final proposals = <Set<String>>[];
      await tester.pumpWidget(
        _navigationApp(
          AnimalCollapse(
            activeIds: {},
            onChanged: proposals.add,
            items: [
              AnimalCollapseItem(
                id: 'a',
                title: const Text('Header'),
                content: const TextField(),
              ),
              AnimalCollapseItem(
                id: 'b',
                title: const Text('Disabled'),
                content: const Text('disabled body'),
                disabled: true,
              ),
            ],
          ),
        ),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(proposals, [
        {'a'},
        {'a'},
      ]);
      expect(
        tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((s) => s.properties.expanded == true),
        isEmpty,
      );
      expect(() => proposals.first.add('bad'), throwsUnsupportedError);
      await tester.tap(find.text('Disabled'));
      await tester.pump();
      expect(proposals, hasLength(2));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        FocusManager.instance.primaryFocus?.context?.widget,
        isNot(isA<EditableText>()),
      );
    },
  );
}
