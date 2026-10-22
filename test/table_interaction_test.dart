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
