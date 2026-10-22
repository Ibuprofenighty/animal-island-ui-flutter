import 'dart:ui' as ui;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'selected cursor paints at the pointer and removes its pixels on exit',
    (t) async {
      final boundaryKey = GlobalKey();
      await t.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: const MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.white,
              body: IslandCursor(
                variant: IslandCursorVariant.raindrop,
                child: SizedBox(width: 200, height: 200),
              ),
            ),
          ),
        ),
      );
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(100, 100));
      await t.pumpAndSettle();
      Future<int> pixel(int x, int y) async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        return (await t.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          final i = (y * image.width + x) * 4;
          final rgb =
              bytes!.getUint8(i) << 16 |
              bytes.getUint8(i + 1) << 8 |
              bytes.getUint8(i + 2);
          image.dispose();
          return rgb;
        }))!;
      }

      expect(await pixel(102, 116), 0x74ccff);
      // The painted overlay cannot intercept the region or erase its selection.
      await mouse.moveTo(const Offset(130, 100));
      await t.pumpAndSettle();
      expect(await pixel(132, 116), 0x74ccff);
      expect(await pixel(100, 116), 0xffffff);
      await mouse.moveTo(const Offset(300, 300));
      await t.pumpAndSettle();
      expect(await pixel(132, 116), 0xffffff);
      await mouse.removePointer();
    },
  );

  testWidgets(
    'forced cursor wins native descendants but nested scoped cursor retains child contract',
    (t) async {
      var calls = 0;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IslandCursor(
              child: Column(
                children: [
                  IslandButton(
                    onPressed: () => calls++,
                    child: const Text('Forced'),
                  ),
                  IslandCursor(
                    forceAll: false,
                    variant: IslandCursorVariant.raindrop,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 100,
                          height: 50,
                          child: Text('Inner background'),
                        ),
                        IslandButton(
                          onPressed: () => calls++,
                          child: const Text('Scoped'),
                        ),
                        const SizedBox(width: 200, child: TextField()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final mouse = await t.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 17,
      );
      await mouse.addPointer(location: Offset.zero);
      await t.pumpAndSettle();
      Future<String?> active(Finder finder) async {
        await mouse.moveTo(t.getCenter(finder));
        await t.pumpAndSettle();
        return RendererBinding.instance.mouseTracker
            .debugDeviceActiveCursor(1)
            ?.debugDescription;
      }

      expect(await active(find.text('Forced')), 'IslandCursor.arrow');
      await t.tap(find.text('Forced'));
      expect(calls, 1);
      expect(
        await active(find.text('Inner background')),
        'IslandCursor.raindrop',
      );
      expect(
        await active(find.text('Scoped')),
        SystemMouseCursors.click.debugDescription,
      );
      await t.tap(find.text('Scoped'));
      expect(calls, 2);
      expect(
        await active(find.byType(TextField)),
        SystemMouseCursors.text.debugDescription,
      );
      await mouse.removePointer();
      await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'scope removal restores native cursor and no touch-only session is created',
    (t) async {
      var custom = true;
      late StateSetter change;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, set) {
                change = set;
                final child = IslandButton(
                  onPressed: () {},
                  child: const Text('Button'),
                );
                return custom ? IslandCursor(child: child) : child;
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Button'));
      await t.pumpAndSettle();
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        isNull,
      );
      final mouse = await t.createGesture(
        kind: PointerDeviceKind.mouse,
        pointer: 21,
      );
      await mouse.addPointer(location: t.getCenter(find.text('Button')));
      await t.pumpAndSettle();
      expect(
        RendererBinding.instance.mouseTracker
            .debugDeviceActiveCursor(1)
            ?.debugDescription,
        'IslandCursor.arrow',
      );
      change(() => custom = false);
      await t.pumpAndSettle();
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.click,
      );
      await mouse.removePointer();
      await t.pumpAndSettle();
    },
  );
}
