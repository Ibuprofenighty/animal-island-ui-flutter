import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  for (final externalWins in [false, true]) {
    testWidgets(
      'Tab reorder reconciles view blur and preserves explicit external focus external=$externalWins',
      (t) async {
        var reverse = false;
        late StateSetter update;
        final requests = <String>[];
        final external = FocusNode();
        try {
          await t.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    StatefulBuilder(
                      builder: (_, set) {
                        update = set;
                        final items = const [
                          IslandTab(
                            value: 'a',
                            label: Text('Alpha'),
                            child: Text('Alpha panel'),
                          ),
                          IslandTab(
                            value: 'b',
                            label: Text('Beta'),
                            child: Text('Beta panel'),
                          ),
                        ];
                        return IslandTabs(
                          items: reverse ? items.reversed.toList() : items,
                          value: 'a',
                          onChanged: requests.add,
                        );
                      },
                    ),
                    TextButton(
                      focusNode: external,
                      onPressed: () {},
                      child: const Text('External'),
                    ),
                  ],
                ),
              ),
            ),
          );
          await t.tap(find.text('Alpha'));
          requests.clear();
          await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
          await t.pumpAndSettle();
          expect(requests, ['b']);
          update(() => reverse = true);
          await t.pump();
          if (externalWins) {
            external.requestFocus();
          } else {
            FocusManager.instance.rootScope.requestScopeFocus();
          }
          await t.pumpAndSettle();
          if (externalWins) {
            expect(external.hasPrimaryFocus, isTrue);
            expect(requests, ['b']);
          } else {
            await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await t.pumpAndSettle();
            expect(requests, ['b', 'a']);
          }
          await t.pumpWidget(const SizedBox());
        } finally {
          external.dispose();
        }
      },
    );
  }

  testWidgets('tab label subtree survives focus decoration changes', (
    tester,
  ) async {
    var mounts = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IslandTabs.uncontrolled(
            items: [
              IslandTab(
                value: 'a',
                label: _MountProbe(() => mounts++),
                child: const Text('Panel'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(mounts, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    expect(mounts, 1);
  });

  testWidgets(
    'stable values preserve focus/content across reorder and rejected host changes',
    (tester) async {
      var reverse = false;
      var current = 'a';
      final requests = <String>[];
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                update = set;
                final items = [
                  const IslandTab(
                    value: 'a',
                    label: Text('Alpha', style: TextStyle(color: Colors.red)),
                    child: TextField(),
                  ),
                  const IslandTab(
                    value: 'b',
                    label: Text('Beta'),
                    child: Text('Beta panel'),
                  ),
                ];
                return IslandTabs(
                  items: reverse ? items.reversed.toList() : items,
                  value: current,
                  onChanged: requests.add,
                );
              },
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'private draft');
      final state = tester.state(find.byType(TextField));
      await tester.tap(find.text('Alpha'));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(requests.last, 'b');
      expect(find.text('private draft'), findsOneWidget);
      update(() => reverse = true);
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(TextField)), same(state));
      expect(tester.widget<Text>(find.text('Alpha')).style!.color, Colors.red);
      // Focus follows Beta's value to index zero; ArrowRight now proposes Alpha.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(requests.last, 'a');
      update(() => current = 'b');
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Beta panel'), findsOneWidget);
    },
  );

  testWidgets(
    'uncontrolled active removal selects first remaining, empty collection stays safe',
    (tester) async {
      var values = ['a', 'b'];
      late StateSetter update;
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                update = set;
                return IslandTabs.uncontrolled(
                  items: [
                    for (final value in values)
                      IslandTab(
                        value: value,
                        label: Text(value),
                        child: Text('panel $value'),
                      ),
                  ],
                  initialValue: 'b',
                  onChanged: (_) => calls++,
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('panel b'), findsOneWidget);
      update(() => values = ['a']);
      await tester.pumpAndSettle();
      expect(find.text('panel a'), findsOneWidget);
      expect(calls, 0);
      update(() => values = []);
      await tester.pumpAndSettle();
      expect(find.text('panel a'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Tabs use the reference active fill, animate the dot scale and rise the panel once on mount',
    (tester) async {
      String value = 'a';
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                update = set;
                return IslandTabs(
                  value: value,
                  onChanged: (_) {},
                  items: const [
                    IslandTab(
                      value: 'a',
                      label: Text('Alpha'),
                      child: Text('Alpha panel'),
                    ),
                    IslandTab(
                      value: 'b',
                      label: Text('Beta'),
                      child: Text('Beta panel'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      double panelTop() => tester.getTopLeft(find.text('Alpha panel')).dy;
      final first = panelTop();
      await tester.pumpAndSettle();
      final settled = panelTop();
      expect(first - settled, closeTo(4, .01));
      // Opaque throughout: no Opacity/FadeTransition wraps required content.
      expect(
        find.ancestor(
          of: find.text('Alpha panel'),
          matching: find.descendant(
            of: find.byType(IslandTabs<String>),
            matching: find.byWidgetPredicate(
              (w) => w is Opacity || w is FadeTransition,
            ),
          ),
        ),
        findsNothing,
      );
      bool hasFill(String label, Color color) => tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(DecoratedBox),
            ),
          )
          .any((box) => (box.decoration as BoxDecoration).color == color);
      expect(hasFill('Alpha', const Color(0xff0cc0b5)), isTrue);
      double dotScale(String glyph) => tester
          .widget<AnimatedScale>(
            find.ancestor(
              of: find.text(glyph),
              matching: find.byType(AnimatedScale),
            ),
          )
          .scale;
      expect(dotScale('●'), 1.2);
      update(() => value = 'b');
      await tester.pump();
      expect(hasFill('Beta', const Color(0xff0cc0b5)), isTrue);
      final base = tester.getSize(find.text('●')).width;
      double painted() => tester.getRect(find.text('●')).width;
      expect(painted(), closeTo(base, .01));
      await tester.pump(const Duration(milliseconds: 100));
      expect(painted(), inExclusiveRange(base, base * 1.2));
      await tester.pumpAndSettle();
      expect(painted(), closeTo(base * 1.2, .01));
      // Switching does not replay the mount entrance.
      expect(tester.getTopLeft(find.text('Beta panel')).dy, settled);
    },
  );
}

class _MountProbe extends StatefulWidget {
  const _MountProbe(this.onMount);
  final VoidCallback onMount;
  @override
  State<_MountProbe> createState() => _MountProbeState();
}

class _MountProbeState extends State<_MountProbe> {
  @override
  void initState() {
    super.initState();
    widget.onMount();
  }

  @override
  Widget build(BuildContext context) => const Text('Label');
}
