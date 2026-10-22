import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 600, child: child)),
);
void main() {
  testWidgets(
    'opaque cell intrinsic sizes share columns and react to child-only changes',
    (t) async {
      final width = ValueNotifier<double>(80);
      addTearDown(width.dispose);
      var tableBuilds = 0;
      await t.pumpWidget(
        host(
          Builder(
            builder: (context) {
              tableBuilds++;
              return IslandTable<int>(
                columns: [
                  IslandTableColumn(
                    id: 'fixed',
                    width: 100,
                    title: const SizedBox(),
                    cellBuilder: (_, r, i) => const SizedBox(height: 20),
                  ),
                  IslandTableColumn(
                    id: 'short',
                    title: const SizedBox(),
                    cellBuilder: (_, r, i) => const SizedBox(
                      key: ValueKey('short-content'),
                      width: 40,
                      height: 20,
                    ),
                  ),
                  IslandTableColumn(
                    id: 'long',
                    title: const SizedBox(),
                    cellBuilder: (_, r, i) => ValueListenableBuilder<double>(
                      valueListenable: width,
                      builder: (_, v, child) => SizedBox(
                        key: const ValueKey('long-content'),
                        width: v,
                        height: 20,
                      ),
                    ),
                  ),
                ],
                rows: const [1],
                rowKey: (r) => r,
              );
            },
          ),
        ),
      );
      await t.pump();
      // Content max widths plus 40px cell padding are 80:120. Available is 488.
      expect(t.getTopLeft(find.byKey(const ValueKey('short-content'))).dx, 126);
      expect(
        t.getTopLeft(find.byKey(const ValueKey('long-content'))).dx,
        closeTo(321.2, .01),
      );
      width.value = 200;
      await t.pump();
      // The parent widget did not rebuild; the layout must still observe 80:240.
      expect(tableBuilds, 1);
      expect(
        t.getTopLeft(find.byKey(const ValueKey('long-content'))).dx,
        closeTo(248, .01),
      );
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'explicit widths support constraint-dependent cells without probing their widgets',
    (t) async {
      await t.pumpWidget(
        host(
          IslandTable<int>(
            columns: [
              IslandTableColumn(
                id: 'layout',
                width: 100,
                title: const Text('Layout'),
                cellBuilder: (_, r, i) => LayoutBuilder(
                  builder: (_, constraints) =>
                      Text('width ${constraints.maxWidth.round()}'),
                ),
              ),
              IslandTableColumn(
                id: 'auto',
                title: const Text('Auto'),
                cellBuilder: (_, r, i) => const Text('Value'),
              ),
            ],
            rows: const [1],
            rowKey: (r) => r,
          ),
        ),
      );
      expect(find.text('width 60'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('column reorder, removal, resize and RTL preserve opaque state', (
    t,
  ) async {
    var ids = ['a', 'b', 'c'];
    var width = 600.0;
    var direction = TextDirection.ltr;
    late StateSetter update;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, setState) {
            update = setState;
            return Directionality(
              textDirection: direction,
              child: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: IslandTable<int>(
                    columns: [
                      for (final id in ids)
                        IslandTableColumn(
                          id: id,
                          title: Text(id),
                          cellBuilder: (_, row, index) => _CellCounter(id),
                        ),
                    ],
                    rows: const [1],
                    rowKey: (row) => row,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await t.tap(find.text('b:0'));
    await t.pump();
    final original = t.state(
      find.byWidgetPredicate((w) => w is _CellCounter && w.id == 'b'),
    );
    update(() {
      ids = ['c', 'b'];
      width = 360;
      direction = TextDirection.rtl;
    });
    await t.pump();
    expect(find.text('b:1'), findsOneWidget);
    expect(find.text('a:0'), findsNothing);
    expect(
      t.state(find.byWidgetPredicate((w) => w is _CellCounter && w.id == 'b')),
      same(original),
    );
    expect(
      t.getCenter(find.text('c:0')).dx,
      greaterThan(t.getCenter(find.text('b:1')).dx),
    );
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'preferred columns shrink to intrinsic minima and retain fixed-cell contract',
    (t) async {
      var width = 300.0;
      late StateSetter resize;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) {
              resize = set;
              return Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: IslandTable<int>(
                    columns: [
                      IslandTableColumn(
                        id: 'preferred',
                        preferredWidth: 120,
                        title: const SizedBox(
                          key: ValueKey('preferred-header'),
                          width: 40,
                          height: 20,
                        ),
                        cellBuilder: (_, r, i) =>
                            const SizedBox(width: 40, height: 20),
                      ),
                      IslandTableColumn(
                        id: 'auto',
                        title: const SizedBox(
                          key: ValueKey('auto-header'),
                          width: 40,
                          height: 20,
                        ),
                        cellBuilder: (_, r, i) =>
                            const SizedBox(width: 40, height: 20),
                      ),
                    ],
                    rows: const [1],
                    rowKey: (r) => r,
                  ),
                ),
              );
            },
          ),
        ),
      );
      double gap() =>
          t.getTopLeft(find.byKey(const ValueKey('auto-header'))).dx -
          t.getTopLeft(find.byKey(const ValueKey('preferred-header'))).dx;
      expect(gap(), 120);
      resize(() => width = 192);
      await t.pump();
      expect(gap(), 100);
      resize(() => width = 172);
      await t.pump();
      expect(gap(), 80);
      resize(() => width = 300);
      await t.pump();
      expect(gap(), 120);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('line boxes grow for text scaling and taller opaque children', (
    t,
  ) async {
    var childHeight = 1.0, scale = 1.0;
    late StateSetter update;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, setState) {
            update = setState;
            return MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(scale)),
              child: IslandTable<int>(
                columns: [
                  IslandTableColumn(
                    id: 'content',
                    title: const SizedBox(width: 10, height: 1),
                    cellBuilder: (_, row, index) =>
                        SizedBox(width: 20, height: childHeight),
                  ),
                ],
                rows: const [1],
                rowKey: (row) => row,
              ),
            );
          },
        ),
      ),
    );
    expect(
      t.getSize(find.byType(IslandTable<int>)).height,
      closeTo(115.390625, .001),
    );
    update(() => childHeight = 80);
    await t.pump();
    expect(t.getSize(find.byType(IslandTable<int>)).height, closeTo(173, .001));
    update(() {
      childHeight = 1;
      scale = 2;
    });
    await t.pump();
    expect(
      t.getSize(find.byType(IslandTable<int>)).height,
      closeTo(158.796875, .001),
    );
    expect(t.takeException(), isNull);
  });
}

class _CellCounter extends StatefulWidget {
  const _CellCounter(this.id);
  final String id;
  @override
  State<_CellCounter> createState() => _CellCounterState();
}

class _CellCounterState extends State<_CellCounter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => setState(() => count++),
    child: Text('${widget.id}:$count'),
  );
}
