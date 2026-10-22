import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final parent in ['Card', 'Tag']) {
    for (final externalWins in [false, true]) {
      testWidgets(
        '$parent optional activation reconciles child view blur external=$externalWins',
        (t) async {
          var actionable = false;
          late StateSetter update;
          final child = FocusNode(), external = FocusNode();
          try {
            await t.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: Column(
                    children: [
                      StatefulBuilder(
                        builder: (_, set) {
                          update = set;
                          final content = TextButton(
                            focusNode: child,
                            onPressed: () {},
                            child: const Text('Child'),
                          );
                          return parent == 'Card'
                              ? IslandCard(
                                  onTap: actionable ? () {} : null,
                                  child: content,
                                )
                              : IslandTag(
                                  onPressed: actionable ? () {} : null,
                                  child: content,
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
            child.requestFocus();
            await t.pumpAndSettle();
            for (final active in [true, false]) {
              update(() => actionable = active);
              await t.pump();
              if (externalWins) {
                external.requestFocus();
              } else {
                FocusManager.instance.rootScope.requestScopeFocus();
              }
              await t.pumpAndSettle();
              expect(
                externalWins ? external.hasPrimaryFocus : child.hasPrimaryFocus,
                isTrue,
              );
              if (externalWins) {
                child.requestFocus();
                await t.pumpAndSettle();
              }
            }
            await t.pumpWidget(const SizedBox());
          } finally {
            child.dispose();
            external.dispose();
          }
        },
      );
    }
  }

  for (final parent in ['Card', 'Tag', 'Table']) {
    testWidgets(
      '$parent optional activation preserves opaque child state and child-only dispatch',
      (t) async {
        var actionable = false, parentCalls = 0;
        late StateSetter update;
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (_, set) {
                  update = set;
                  const child = _Counter(key: ValueKey('opaque'));
                  final VoidCallback? action = actionable
                      ? () {
                          parentCalls++;
                        }
                      : null;
                  return switch (parent) {
                    'Card' => IslandCard(onTap: action, child: child),
                    'Tag' => IslandTag(onPressed: action, child: child),
                    _ => IslandTable<int>(
                      columns: [
                        IslandTableColumn(
                          id: 'child',
                          title: const Text('Child'),
                          cellBuilder: (_, row, index) => child,
                        ),
                      ],
                      rows: const [1],
                      rowKey: (v) => v,
                      onRowPressed: actionable ? (_) => action!() : null,
                    ),
                  };
                },
              ),
            ),
          ),
        );
        final state = t.state(find.byType(_Counter));
        await t.tap(find.text('Count 0'));
        await t.pumpAndSettle();
        expect(find.text('Count 1'), findsOneWidget);
        expect(parentCalls, 0);
        update(() => actionable = true);
        await t.pumpAndSettle();
        expect(t.state(find.byType(_Counter)), same(state));
        await t.tap(find.text('Count 1'));
        await t.pumpAndSettle();
        expect(find.text('Count 2'), findsOneWidget);
        final childFocus = Focus.of(t.element(find.text('Count 2')));
        childFocus.requestFocus();
        await t.pumpAndSettle();
        expect(childFocus.hasPrimaryFocus, isTrue);
        expect(parentCalls, 0);
        update(() => actionable = false);
        await t.pumpAndSettle();
        expect(t.state(find.byType(_Counter)), same(state));
        expect(childFocus.hasPrimaryFocus, isTrue);
        await t.tap(find.text('Count 2'));
        await t.pumpAndSettle();
        expect(find.text('Count 3'), findsOneWidget);
        expect(parentCalls, 0);
        expect(t.takeException(), isNull);
      },
    );
  }
}

class _Counter extends StatefulWidget {
  const _Counter({super.key});
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count++),
    child: Text('Count $count'),
  );
}
