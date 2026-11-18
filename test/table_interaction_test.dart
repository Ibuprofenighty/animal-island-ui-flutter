import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 600, child: child)),
);
Finder rows() => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.role == ui.SemanticsRole.row,
);

void main() {
  testWidgets(
    'a narrow table keeps every header unwrapped and scrolls sideways',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 300,
                child: IslandTable<int>(
                  columns: [
                    IslandTableColumn(
                      id: 'name',
                      title: const Text('岛民'),
                      preferredWidth: 120,
                      cellBuilder: (_, row, _) => Text('Mochi $row'),
                    ),
                    IslandTableColumn(
                      id: 'age',
                      title: const Text('年龄'),
                      preferredWidth: 80,
                      cellBuilder: (_, row, _) => Text('$row'),
                    ),
                    IslandTableColumn(
                      id: 'island',
                      title: const Text('岛屿'),
                      cellBuilder: (_, _, _) => const Text('彩虹岛'),
                    ),
                    IslandTableColumn(
                      id: 'fruit',
                      title: const Text('喜欢的水果'),
                      cellBuilder: (_, _, _) => const Text('苹果'),
                    ),
                  ],
                  rows: const [1, 2],
                  rowKey: (row) => row,
                ),
              ),
            ),
          ),
        ),
      );
      // Reference `.headerCell { white-space: nowrap }`: the header text is
      // the column's min-content, so the title is laid out whole.
      final title = t.renderObject<RenderParagraph>(
        find.descendant(
          of: find.text('喜欢的水果'),
          matching: find.byType(RichText),
        ),
      );
      expect(title.size.width, title.getMaxIntrinsicWidth(double.infinity));
      expect(title.didExceedMaxLines, isFalse);
      final cell = find
          .ancestor(
            of: find.text('喜欢的水果'),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.role == ui.SemanticsRole.columnHeader,
            ),
          )
          .first;
      expect(
        t.getSize(cell).width,
        greaterThanOrEqualTo(title.size.width + 40),
      );
      // The overflow scrolls inside the table instead of clipping a header.
      final scroll = t.state<ScrollableState>(
        find.ancestor(of: cell, matching: find.byType(Scrollable)).first,
      );
      expect(scroll.position.axis, Axis.horizontal);
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'an overflowing table runs to the wrapper edge and is cut square there',
    (t) async {
      final boundaryKey = GlobalKey();
      Future<void> pump(double width) => t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: boundaryKey,
                child: ColoredBox(
                  color: Colors.white,
                  child: SizedBox(
                    width: width,
                    child: IslandTable<int>(
                      columns: [
                        for (final id in ['岛民', '年龄', '岛屿', '喜欢的水果'])
                          IslandTableColumn(
                            id: id,
                            title: Text(id),
                            cellBuilder: (_, row, _) => Text('$row'),
                          ),
                      ],
                      rows: const [1, 2],
                      rowKey: (row) => row,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      Future<int> pixel(Offset at) async => (await t.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final i = (at.dy.floor() * image.width + at.dx.floor()) * 4;
        final rgb =
            bytes!.getUint8(i) << 16 |
            bytes.getUint8(i + 1) << 8 |
            bytes.getUint8(i + 2);
        image.dispose();
        return rgb;
      }))!;
      Finder header(String title) => find
          .ancestor(
            of: find.text(title),
            matching: find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.role == ui.SemanticsRole.columnHeader,
            ),
          )
          .first;

      // Reference `.wrapper` (no `scroll`) does not clip: the table starts
      // inside the 6px padding and runs past the wrapper's right edge, where
      // only the outer edge cuts it, square, over the rounded corner.
      await pump(300);
      final table = t.getRect(find.byType(IslandTable<int>));
      final viewport = t.getRect(find.byType(Scrollable).first);
      expect(viewport.left, table.left);
      expect(viewport.right, table.right);
      expect(t.getRect(header('岛民')).left, table.left + 6);
      expect(t.getRect(header('喜欢的水果')).right, greaterThan(table.right));
      expect(await pixel(const Offset(298, 10)), 0xf7f3df);
      expect(await pixel(const Offset(0, 0)), 0xffffff);
      // Scrolled to the end, the last column keeps the wrapper's 6px padding.
      final scroll = t.state<ScrollableState>(find.byType(Scrollable).first);
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await t.pump();
      expect(t.getRect(header('喜欢的水果')).right, table.right - 6);

      // A table that fits keeps every column inside the padding and all four
      // rounded corners.
      await pump(600);
      final wide = t.getRect(find.byType(IslandTable<int>));
      expect(t.getRect(header('岛民')).left, wide.left + 6);
      expect(t.getRect(header('喜欢的水果')).right, wide.right - 6);
      expect(await pixel(const Offset(599, 8)), 0xffffff);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'row focus preserves opaque cell state and geometry; child activation stays local',
    (t) async {
      var parent = 0;
      await t.pumpWidget(
        host(
          IslandTable<int>(
            columns: [
              IslandTableColumn(
                id: 'cell',
                title: const Text('Header'),
                cellBuilder: (_, row, index) => const _Counter(),
              ),
            ],
            rows: const [1],
            rowKey: (row) => row,
            onRowPressed: (_) => parent++,
          ),
        ),
      );
      final original = t.state(find.byType(_Counter));
      final bounds = t.getRect(rows().at(1));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(t.state(find.byType(_Counter)), same(original));
      expect(t.getRect(rows().at(1)), bounds);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(parent, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(find.text('Child 1'), findsOneWidget);
      expect(parent, 1);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await t.pumpAndSettle();
      expect(t.state(find.byType(_Counter)), same(original));
      expect(find.text('Child 1'), findsOneWidget);
      expect(t.getRect(rows().at(1)), bounds);
      await t.tap(find.text('Child 1'));
      await t.pumpAndSettle();
      expect(find.text('Child 2'), findsOneWidget);
      expect(parent, 1);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'row hover paints immediately and restores stripes without moving content',
    (t) async {
      final boundaryKey = GlobalKey();
      await t.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: host(
            IslandTable<int>(
              columns: [
                IslandTableColumn(
                  id: 'cell',
                  title: const SizedBox(),
                  cellBuilder: (_, row, index) =>
                      const SizedBox(width: 20, height: 20),
                ),
              ],
              rows: const [1, 2],
              rowKey: (row) => row,
            ),
          ),
        ),
      );
      final bounds = t.getRect(rows().at(2));
      Future<int> pixel() async => (await t.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final i =
            (bounds.center.dy.floor() * image.width +
                bounds.center.dx.floor()) *
            4;
        final rgb =
            bytes!.getUint8(i) << 16 |
            bytes.getUint8(i + 1) << 8 |
            bytes.getUint8(i + 2);
        image.dispose();
        return rgb;
      }))!;
      final resting = await pixel();
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(700, 400));
      await mouse.moveTo(bounds.center);
      await t.pump();
      expect(await pixel(), 0xd6f0ea);
      expect(t.getRect(rows().at(2)), bounds);
      await mouse.moveTo(const Offset(700, 400));
      await t.pump();
      expect(await pixel(), resting);
      expect(t.getRect(rows().at(2)), bounds);
      await mouse.removePointer();
      expect(t.takeException(), isNull);
    },
  );
}

class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) => IslandButton(
    onPressed: () => setState(() => count++),
    child: Text('Child $count'),
  );
}
