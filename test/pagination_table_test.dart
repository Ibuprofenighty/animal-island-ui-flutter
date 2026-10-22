import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  localizationsDelegates: IslandLocalizations.delegates,
  supportedLocales: IslandLocalizations.supportedLocales,
  home: Scaffold(body: child),
);
Finder button(String label) => find.byWidgetPredicate(
  (w) =>
      w is Semantics &&
      w.properties.button == true &&
      w.properties.label == label,
);

void main() {
  test('paging value clamps ranges, including no records', () {
    const value = IslandPaginationValue(page: 9, pageSize: 10);
    expect(value.normalized(23), const IslandPaginationValue(page: 3));
    expect(value.startIndex(23), 20);
    expect(value.endIndex(23), 23);
    expect(value.normalized(0), const IslandPaginationValue());
    expect(value.startIndex(0), 0);
    expect(value.endIndex(0), 0);
  });
  testWidgets('controlled paging rejects requests and size change is atomic', (
    t,
  ) async {
    final events = <IslandPaginationValue>[];
    final sizeEvents = <IslandPaginationValue>[];
    await t.pumpWidget(
      host(
        IslandPagination(
          total: 85,
          value: const IslandPaginationValue(page: 9),
          showSizeChanger: true,
          showQuickJumper: true,
          onChanged: events.add,
          onPageSizeChanged: sizeEvents.add,
        ),
      ),
    );
    await t.tap(button('Previous page'));
    await t.pump();
    expect(events.last, const IslandPaginationValue(page: 8));
    expect(t.widget<Semantics>(button('Page 9')).properties.selected, isTrue);
    await t.tap(button('10 / page'));
    await t.pumpAndSettle();
    await t.tap(find.text('50 / page'));
    await t.pumpAndSettle();
    expect(events.last, const IslandPaginationValue(page: 2, pageSize: 50));
    expect(sizeEvents, [const IslandPaginationValue(page: 2, pageSize: 50)]);
    expect(find.text('10 / page'), findsOneWidget);
    await t.enterText(find.byType(TextField), '999');
    await t.testTextInput.receiveAction(TextInputAction.done);
    await t.pump();
    expect(events.length, 2); // Clamps to already committed page 9.
    expect(
      t.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });
  testWidgets(
    'uncontrolled total shrink and disabled transitions dismiss size menu',
    (t) async {
      var total = 85;
      var disabled = false;
      late StateSetter update;
      final events = <IslandPaginationValue>[];
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandPagination.uncontrolled(
                total: total,
                initialValue: const IslandPaginationValue(page: 9),
                showSizeChanger: true,
                disabled: disabled,
                onChanged: events.add,
              );
            },
          ),
        ),
      );
      update(() => total = 15);
      await t.pump();
      expect(t.widget<Semantics>(button('Page 2')).properties.selected, isTrue);
      expect(events, isEmpty);
      await t.tap(button('10 / page'));
      await t.pumpAndSettle();
      expect(find.text('50 / page'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('50 / page'), findsNothing);
      await t.tap(button('10 / page'));
      await t.pumpAndSettle();
      update(() => disabled = true);
      await t.pumpAndSettle();
      expect(find.text('50 / page'), findsNothing);
      await t.tap(button('Previous page'));
      await t.pump();
      expect(events, isEmpty);
    },
  );
  testWidgets(
    'table owns one paging value and preserves keyed cells when reordered',
    (t) async {
      var rows = ['a', 'b', 'c', 'd', 'e'];
      late StateSetter update;
      final changes = <IslandPaginationValue>[];
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandTable<String>(
                columns: [
                  IslandTableColumn(
                    id: 'name',
                    title: const Text('Name'),
                    cellBuilder: (_, row, __) => _Counter(row),
                  ),
                ],
                rows: rows,
                rowKey: (r) => r,
                pagination: IslandTablePagination(
                  initialValue: const IslandPaginationValue(pageSize: 2),
                  onChanged: changes.add,
                ),
              );
            },
          ),
        ),
      );
      await t.tap(find.text('a:0'));
      await t.pump();
      expect(find.text('a:1'), findsOneWidget);
      update(() => rows = ['b', 'a', 'c', 'd', 'e']);
      await t.pump();
      expect(find.text('a:1'), findsOneWidget);
      await t.tap(button('Next page'));
      await t.pump();
      expect(find.text('c:0'), findsOneWidget);
      expect(find.text('a:1'), findsNothing);
      expect(changes, [const IslandPaginationValue(page: 2, pageSize: 2)]);
      update(() => rows = ['b']);
      await t.pump();
      expect(t.widget<Semantics>(button('Page 1')).properties.selected, isTrue);
      expect(find.text('b:0'), findsOneWidget);
      expect(changes.length, 1);
      update(() => rows = []);
      await t.pump();
      expect(find.text('No data'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'table cell action stays independent from row action; loading blocks both',
    (t) async {
      int rowCalls = 0, cellCalls = 0;
      bool loading = false;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandTable<String>(
                columns: [
                  IslandTableColumn(
                    id: 'name',
                    title: const Text('Name'),
                    cellBuilder: (_, r, __) => Text(r),
                  ),
                  IslandTableColumn(
                    id: 'action',
                    title: const Text('Action'),
                    cellBuilder: (_, r, __) => IslandButton(
                      onPressed: () => cellCalls++,
                      child: const Text('Edit'),
                    ),
                  ),
                ],
                rows: const ['a'],
                rowKey: (r) => r,
                onRowPressed: (_) => rowCalls++,
                loading: loading,
              );
            },
          ),
        ),
      );
      await t.tap(find.text('Edit'));
      await t.pump();
      expect(cellCalls, 1);
      expect(rowCalls, 0);
      await t.tap(find.text('a'));
      await t.pump();
      expect(rowCalls, 1);
      update(() => loading = true);
      await t.pump();
      await t.tap(find.text('Edit'), warnIfMissed: false);
      await t.pump();
      expect(cellCalls, 1);
      expect(rowCalls, 1);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'controlled table rejection keeps child paging and displayed records synchronized',
    (t) async {
      IslandPaginationValue? requested;
      await t.pumpWidget(
        host(
          IslandTable<String>(
            columns: [
              IslandTableColumn(
                id: 'name',
                title: const Text('Name'),
                cellBuilder: (_, r, __) => Text(r),
              ),
            ],
            rows: const ['a', 'b', 'c'],
            rowKey: (r) => r,
            pagination: IslandTablePagination(
              value: const IslandPaginationValue(pageSize: 1),
              onChanged: (v) => requested = v,
            ),
          ),
        ),
      );
      await t.tap(button('Next page'));
      await t.pump();
      expect(requested, const IslandPaginationValue(page: 2, pageSize: 1));
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsNothing);
      expect(t.widget<Semantics>(button('Page 1')).properties.selected, isTrue);
    },
  );
  testWidgets(
    'Pagination retains intrinsic sizing, resize and RTL focus across wrapped runs',
    (t) async {
      for (final direction in TextDirection.values) {
        double? width;
        late StateSetter resize;
        final requests = <IslandPaginationValue>[];
        await t.pumpWidget(
          host(
            StatefulBuilder(
              builder: (context, set) {
                resize = set;
                return Directionality(
                  textDirection: direction,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: width,
                      child: IntrinsicWidth(
                        child: IslandPagination(
                          total: 85,
                          value: const IslandPaginationValue(page: 4),
                          showSizeChanger: true,
                          onChanged: requests.add,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        FocusNode pageNode() => t
            .widget<FocusableActionDetector>(
              find
                  .descendant(
                    of: button('Page 3'),
                    matching: find.byType(FocusableActionDetector),
                  )
                  .first,
            )
            .focusNode!;
        final node = pageNode();
        node.requestFocus();
        await t.pump();
        expect(node.hasFocus, isTrue);
        final before = t.getRect(button('Page 3')).height;
        resize(() => width = 260);
        await t.pump();
        expect(pageNode(), same(node));
        expect(node.hasFocus, isTrue);
        expect(t.getRect(button('Page 3')).height, before);
        final bounds = t.getRect(find.byType(IslandPagination));
        for (final name in ['Previous page', 'Page 1', 'Page 3', 'Next page']) {
          final rect = t.getRect(button(name));
          expect(rect.left, greaterThanOrEqualTo(bounds.left));
          expect(rect.right, lessThanOrEqualTo(bounds.right));
        }
        if (direction == TextDirection.ltr) {
          expect(
            t.getCenter(button('Page 1')).dx,
            lessThan(t.getCenter(button('Page 3')).dx),
          );
        } else {
          expect(
            t.getCenter(button('Page 1')).dx,
            greaterThan(t.getCenter(button('Page 3')).dx),
          );
        }
        await t.sendKeyEvent(LogicalKeyboardKey.enter);
        await t.pump();
        expect(requests, [const IslandPaginationValue(page: 3)]);
        expect(
          t.widget<Semantics>(button('Page 4')).properties.selected,
          isTrue,
        );
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await t.pump();
      }
    },
  );
}

class _Counter extends StatefulWidget {
  const _Counter(this.name);
  final String name;
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count++),
    child: Text('${widget.name}:$count'),
  );
}
