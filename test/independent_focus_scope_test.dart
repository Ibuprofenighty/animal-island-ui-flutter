import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final parent in ['Card', 'Tag', 'Table']) {
    for (final applicationScope in [true, false]) {
      testWidgets(
        '$parent child remains outside parent focus at scope boundary application=$applicationScope',
        (t) async {
          final child = FocusNode();
          late StateSetter update;
          var active = true;
          try {
            final content = StatefulBuilder(
              builder: (_, set) {
                update = set;
                final button = IslandButton(
                  focusNode: child,
                  onPressed: () {},
                  child: const Text('Independent'),
                );
                final VoidCallback? action = active ? () {} : null;
                return switch (parent) {
                  'Card' => IslandCard(onTap: action, child: button),
                  'Tag' => IslandTag(onPressed: action, child: button),
                  _ => IslandTable<int>(
                    columns: [
                      IslandTableColumn(
                        id: 'child',
                        title: const Text('Header'),
                        cellBuilder: (_, row, index) => button,
                      ),
                    ],
                    rows: const [1],
                    rowKey: (row) => row,
                    onRowPressed: active ? (_) => action!() : null,
                  ),
                };
              },
            );
            await t.pumpWidget(
              applicationScope
                  ? MaterialApp(
                      theme: IslandTheme.create(),
                      home: Scaffold(body: Center(child: content)),
                    )
                  : MediaQuery(
                      data: const MediaQueryData(size: Size(800, 600)),
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Theme(
                          data: IslandTheme.create(),
                          child: Material(child: Center(child: content)),
                        ),
                      ),
                    ),
            );
            child.requestFocus();
            await t.pumpAndSettle();
            expect(child.hasPrimaryFocus, isTrue);
            final owner = t
                .widgetList<FocusableActionDetector>(
                  find.byType(FocusableActionDetector),
                )
                .first
                .focusNode!;
            expect(
              owner.hasFocus,
              isFalse,
              reason: 'An independent child must not put its optional parent in the focused path or project a parent focus outline over the child.',
            );
            expect(child.ancestors.contains(owner), isFalse);
            update(() => active = false);
            await t.pumpAndSettle();
            expect(child.hasPrimaryFocus, isTrue);
            expect(owner.hasFocus, isFalse);
            await t.pumpWidget(const SizedBox());
            expect(t.takeException(), isNull);
          } finally {
            child.dispose();
          }
        },
      );
    }
  }
}
