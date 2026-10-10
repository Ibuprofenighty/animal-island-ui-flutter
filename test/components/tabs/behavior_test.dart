import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/tabs/tab_indicator.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

void main() {
  _liveGeometryOracles();
  _navigationOracles();
  group('AnimalTabs Behavior & F26 Tests (C10 / TAB01-TAB02)', () {
    testWidgets(
      'F26: indicator recalculates when tab label text changes without length or index change',
      (tester) async {
        var tabs = [
          AnimalTabItem(id: 'tab-0', label: 'Short'),
          AnimalTabItem(id: 'tab-1', label: 'Tab 2'),
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
                    selectedId: 'tab-${0}',
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
        tabs = [
          AnimalTabItem(id: 'tab-0', label: 'Much Longer Tab Label Here'),
          AnimalTabItem(id: 'tab-1', label: 'Tab 2'),
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
                    selectedId: 'tab-${0}',
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
      String active = 'tab-0';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalTabs(
                  selectedId: active,
                  onChanged: (idx) => setState(() => active = idx),
                  tabs: [
                    AnimalTabItem(id: 'tab-0', label: 'Tab 0'),
                    AnimalTabItem(
                      id: 'tab-1',
                      label: 'Tab 1 (Disabled)',
                      disabled: true,
                    ),
                    AnimalTabItem(id: 'tab-2', label: 'Tab 2'),
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

      expect(active, 'tab-2');
    });
  });
}

void _liveGeometryOracles() {
  testWidgets(
    'TAB02 direction-only LTR RTL flips realign the selected indicator without proposing selection',
    (tester) async {
      final proposals = <String>[];
      final tabs = [
        AnimalTabItem(id: 'a', label: 'First'),
        AnimalTabItem(id: 'b', label: 'Second'),
        AnimalTabItem(id: 'c', label: 'Third'),
      ];
      Widget app(TextDirection direction, bool scrollable) => _navigationApp(
        Align(
          child: SizedBox(
            width: 320,
            height: 120,
            child: AnimalTabs(
              tabs: tabs,
              selectedId: 'a',
              onChanged: proposals.add,
              scrollable: scrollable,
            ),
          ),
        ),
        direction: direction,
      );
      Rect selectedBounds() {
        final stack = find
            .ancestor(
              of: find.byType(AnimalTabIndicator),
              matching: find.byType(Stack),
            )
            .first;
        final tab = find
            .ancestor(
              of: find.text('First'),
              matching: find.byType(InteractiveRegion),
            )
            .first;
        return (tester.getTopLeft(tab) - tester.getTopLeft(stack)) &
            tester.getSize(tab);
      }

      for (final scrollable in [false, true]) {
        await tester.pumpWidget(app(TextDirection.ltr, scrollable));
        await tester.pumpAndSettle();
        final state = tester.state(find.byType(AnimalTabs));
        final ltrBounds = selectedBounds();
        for (final direction in [TextDirection.rtl, TextDirection.ltr]) {
          await tester.pumpWidget(app(direction, scrollable));
          await tester.pumpAndSettle();
          expect(tester.state(find.byType(AnimalTabs)), same(state));
          expect(tester.getSize(find.byType(AnimalTabs)), const Size(320, 120));
          final bounds = selectedBounds();
          expect(
            bounds,
            direction == TextDirection.rtl ? isNot(ltrBounds) : ltrBounds,
          );
          expect(
            tester
                .widget<AnimalTabIndicator>(find.byType(AnimalTabIndicator))
                .targetRect,
            bounds,
            reason: 'TAB02_DIRECTION_GEOMETRY_STALE',
          );
          expect(
            tester.widget<AnimalTabs>(find.byType(AnimalTabs)).selectedId,
            'a',
          );
          expect(proposals, isEmpty);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
  testWidgets(
    'TAB02 live text scaling realigns the indicator to the selected ID',
    (tester) async {
      var scale = 1.0;
      Widget app() => _navigationApp(
        SizedBox(
          width: 180,
          child: AnimalTabs(
            tabs: [
              AnimalTabItem(id: 'a', label: 'First tab'),
              AnimalTabItem(id: 'b', label: 'Selected long label'),
            ],
            selectedId: 'b',
            onChanged: (_) {},
          ),
        ),
        scale: scale,
      );
      Rect selectedBounds() {
        final stack = find
            .ancestor(
              of: find.byType(AnimalTabIndicator),
              matching: find.byType(Stack),
            )
            .first;
        final tab = find
            .ancestor(
              of: find.text('Selected long label'),
              matching: find.byType(InteractiveRegion),
            )
            .first;
        return (tester.getTopLeft(tab) - tester.getTopLeft(stack)) &
            tester.getSize(tab);
      }

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final before = selectedBounds();
      scale = 2;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final after = selectedBounds();
      expect(after, isNot(before));
      expect(
        tester
            .widget<AnimalTabIndicator>(find.byType(AnimalTabIndicator))
            .targetRect,
        after,
        reason: 'TAB02_LIVE_SCALE_GEOMETRY',
      );
    },
  );
  testWidgets(
    'TAB01 rejected keyboard proposals reveal focused tabs without changing selection',
    (tester) async {
      final proposals = <String>[];
      await tester.pumpWidget(
        _navigationApp(
          SizedBox(
            width: 180,
            child: AnimalTabs(
              tabs: [
                for (var i = 0; i < 6; i++)
                  AnimalTabItem(id: 't$i', label: 'Tab $i'),
              ],
              selectedId: 't0',
              onChanged: proposals.add,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();
      expect(proposals, ['t5']);
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('t5'));
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      final focused = tester.getRect(
        find
            .ancestor(
              of: find.text('Tab 5'),
              matching: find.byType(InteractiveRegion),
            )
            .first,
      );
      expect(focused.left, greaterThanOrEqualTo(viewport.left - 1));
      expect(focused.right, lessThanOrEqualTo(viewport.right + 1));
      expect(
        tester.widget<AnimalTabs>(find.byType(AnimalTabs)).selectedId,
        't0',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(proposals.last, 't0');
      final first = tester.getRect(
        find
            .ancestor(
              of: find.text('Tab 0'),
              matching: find.byType(InteractiveRegion),
            )
            .first,
      );
      expect(first.left, greaterThanOrEqualTo(viewport.left - 1));
      expect(first.right, lessThanOrEqualTo(viewport.right + 1));
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _navigationApp(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
}) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Directionality(
      textDirection: direction,
      child: Scaffold(body: child),
    ),
  ),
);

void _navigationOracles() {
  test('TAB03 stable IDs reject duplicate, unknown and disabled selection and freeze input', () {
    final items = [AnimalTabItem(id: 'a', label: 'A')];
    final tabs = AnimalTabs(tabs: items, selectedId: 'a', onChanged: (_) {});
    items.clear();
    expect(tabs.tabs.single.id, 'a');
    expect(() => AnimalTabItem(id: '', label: 'bad'), throwsArgumentError);
    expect(
      () => AnimalTabs(
        tabs: [
          AnimalTabItem(id: 'a', label: 'A'),
          AnimalTabItem(id: 'a', label: 'B'),
        ],
        selectedId: 'a',
        onChanged: (_) {},
      ),
      throwsArgumentError,
    );
    expect(
      () => AnimalTabs(
        tabs: [AnimalTabItem(id: 'a', label: 'A', disabled: true)],
        selectedId: 'a',
        onChanged: (_) {},
      ),
      throwsArgumentError,
    );
    expect(
      () => AnimalTabs(tabs: [], selectedId: 'gone', onChanged: (_) {}),
      throwsArgumentError,
    );
  });
  testWidgets(
    'TAB01 roving arrows Home End RTL and rejected proposals preserve the selected ID',
    (tester) async {
      final proposals = <String>[];
      var items = [
        AnimalTabItem(id: 'a', label: 'A'),
        AnimalTabItem(id: 'x', label: 'Disabled', disabled: true),
        AnimalTabItem(id: 'b', label: 'B'),
        AnimalTabItem(id: 'c', label: 'C'),
      ];
      Widget app(TextDirection direction) => _navigationApp(
        AnimalTabs(tabs: items, selectedId: 'a', onChanged: proposals.add),
        direction: direction,
      );
      await tester.pumpWidget(app(TextDirection.ltr));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('a'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(proposals, ['b']);
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('b'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(proposals.last, 'c');
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(proposals.last, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(proposals.last, 'c');
      final selected = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where(
            (s) => s.properties.selected == true && s.properties.label == 'A',
          );
      expect(selected, hasLength(1));
      items = [items[3], items[0], items[2]];
      await tester.pumpWidget(app(TextDirection.rtl));
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus?.debugLabel, contains('c'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(proposals.last, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(proposals.last, 'c');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(proposals.last, 'c');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(proposals.last, 'c');
      items = [items[1], items[2]];
      await tester.pumpWidget(app(TextDirection.ltr));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'TAB02 same ID long Chinese label remeasures indicator and reveals the selected tab at 200 percent',
    (tester) async {
      var label = '短';
      Widget app() => _navigationApp(
        SizedBox(
          width: 220,
          child: AnimalTabs(
            tabs: [
              AnimalTabItem(id: 'a', label: 'First'),
              AnimalTabItem(id: 'b', label: label),
            ],
            selectedId: 'b',
            onChanged: (_) {},
          ),
        ),
        scale: 2,
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final before = tester
          .widget<AnimalTabIndicator>(find.byType(AnimalTabIndicator))
          .targetRect!;
      label = '非常长的中文标签';
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final after = tester
          .widget<AnimalTabIndicator>(find.byType(AnimalTabIndicator))
          .targetRect!;
      expect(
        after.width,
        greaterThan(before.width),
        reason: 'TAB02_LABEL_GEOMETRY_STALE',
      );
      final scroll = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(
        scroll.controller!.offset,
        greaterThan(0),
        reason: 'selected tab must be revealed',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
