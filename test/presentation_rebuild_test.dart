import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final parent in ['Card', 'Tag', 'Table']) {
    for (final externalWins in [false, true]) {
      testWidgets(
        '$parent pending child recovery survives benign host rebuild external=$externalWins',
        (t) async {
          var actionable = false, revision = 0;
          late StateSetter update;
          final childFocus = FocusNode(), external = FocusNode();
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
                            focusNode: childFocus,
                            onPressed: () {},
                            child: const Text('Child'),
                          );
                          final VoidCallback? action = actionable
                              ? () {}
                              : null;
                          final surface = switch (parent) {
                            'Card' => IslandCard(onTap: action, child: content),
                            'Tag' => IslandTag(
                              onPressed: action,
                              child: content,
                            ),
                            _ => IslandTable<int>(
                              columns: [
                                IslandTableColumn(
                                  id: 'child',
                                  title: const Text('Header'),
                                  cellBuilder: (_, row, index) => content,
                                ),
                              ],
                              rows: const [1],
                              rowKey: (row) => row,
                              onRowPressed: actionable
                                  ? (_) => action!()
                                  : null,
                            ),
                          };
                          return Theme(
                            data: IslandTheme.create(
                              brightness: revision.isEven
                                  ? Brightness.light
                                  : Brightness.dark,
                            ),
                            child: surface,
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
            childFocus.requestFocus();
            await t.pumpAndSettle();
            expect(childFocus.hasPrimaryFocus, isTrue);
            update(() => actionable = true);
            await t.pump();
            FocusManager.instance.rootScope.requestScopeFocus();
            await t.idle();
            expect(
              FocusManager.instance.primaryFocus,
              same(FocusManager.instance.rootScope),
            );
            update(() => revision++);
            if (externalWins) external.requestFocus();
            await t.pumpAndSettle();
            expect(
              externalWins
                  ? external.hasPrimaryFocus
                  : childFocus.hasPrimaryFocus,
              isTrue,
              reason: 'Unchanged pending owner survives a theme rebuild; explicit external destination wins.',
            );
            await t.pumpWidget(const SizedBox());
            expect(t.takeException(), isNull);
          } finally {
            childFocus.dispose();
            external.dispose();
          }
        },
      );
    }
  }
  for (final externalWins in [false, true]) {
    testWidgets(
      'Tabs pending header recovery survives benign host rebuild external=$externalWins',
      (t) async {
        var reverse = false, revision = 0;
        late StateSetter update;
        final external = FocusNode();
        final requests = <String>[];
        try {
          await t.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    StatefulBuilder(
                      builder: (_, set) {
                        update = set;
                        const items = [
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
                        return Theme(
                          data: IslandTheme.create(
                            brightness: revision.isEven
                                ? Brightness.light
                                : Brightness.dark,
                          ),
                          child: IslandTabs(
                            items: reverse ? items.reversed.toList() : items,
                            value: 'a',
                            onChanged: requests.add,
                          ),
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
          final header = Focus.of(t.element(find.text('Beta')));
          expect(header.hasPrimaryFocus, isTrue);
          update(() => reverse = true);
          await t.pump();
          FocusManager.instance.rootScope.requestScopeFocus();
          await t.idle();
          expect(
            FocusManager.instance.primaryFocus,
            same(FocusManager.instance.rootScope),
          );
          update(() => revision++);
          if (externalWins) external.requestFocus();
          await t.pumpAndSettle();
          expect(
            externalWins ? external.hasPrimaryFocus : header.hasPrimaryFocus,
            isTrue,
            reason: 'A benign rebuild must not cancel unchanged value-keyed header recovery.',
          );
          if (!externalWins) {
            await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
            await t.pumpAndSettle();
            expect(requests, ['b', 'a']);
          }
          await t.pumpWidget(const SizedBox());
          expect(t.takeException(), isNull);
        } finally {
          external.dispose();
        }
      },
    );
  }
}
