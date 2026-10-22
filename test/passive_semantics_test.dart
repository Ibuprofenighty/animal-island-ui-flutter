import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  for (final kind in ['Tag', 'Card', 'Table', 'Disabled Button']) {
    testWidgets('$kind does not advertise a fake tap', (t) async {
      final semantics = t.ensureSemantics();
      try {
        const label = Text('Read only');
        final child = switch (kind) {
          'Tag' => const IslandTag(child: label),
          'Card' => const IslandCard(child: label),
          'Table' => IslandTable<int>(
            columns: [
              IslandTableColumn(
                id: 'value',
                title: const Text('Header'),
                cellBuilder: (_, row, index) => label,
              ),
            ],
            rows: const [1],
            rowKey: (row) => row,
          ),
          _ => const IslandButton(onPressed: null, child: label),
        };
        await t.pumpWidget(MaterialApp(home: Scaffold(body: child)));
        expect(
          t
              .getSemantics(find.text('Read only'))
              .getSemanticsData()
              .hasAction(ui.SemanticsAction.tap),
          isFalse,
        );
      } finally {
        semantics.dispose();
      }
    });
  }
}
