import 'dart:ui' as ui;
import 'dart:ui' show PointerDeviceKind;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const warm = Color(0xffe9c46a);
const dark = Color(0xff654c01);
const host = Color(0x6633aa77);

Color? seen(WidgetTester t, String key) =>
    DefaultSelectionStyle.of(t.element(find.byKey(ValueKey(key))))
        .selectionColor;

void main() {
  testWidgets('arrow paints the 32px rounded arrow with its tip at (8,5)', (
    t,
  ) async {
    final boundary = GlobalKey();
    await t.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: const MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.white,
            body: IslandCursor(child: SizedBox(width: 200, height: 200)),
          ),
        ),
      ),
    );
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(100, 100));
    await t.pumpAndSettle();
    Future<int> pixel(int x, int y) async => (await t.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      final i = (y * image.width + x) * 4;
      final rgb =
          bytes!.getUint8(i) << 16 |
          bytes.getUint8(i + 1) << 8 |
          bytes.getUint8(i + 2);
      image.dispose();
      return rgb;
    }))!;
    // Canvas origin is the pointer minus the (8,5) hotspot.
    expect(await pixel(92 + 9, 95 + 14), 0x794f27);
    expect(await pixel(92 + 13, 95 + 14), 0xfff7e6);
    expect(await pixel(92 + 4, 95 + 14), 0xffffff);
    await mouse.removePointer();
  });

  testWidgets('arrow sets the warm selection; raindrop restores the host', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          textSelectionTheme: const TextSelectionThemeData(
            selectionColor: host,
          ),
        ),
        home: const Scaffold(
          body: Column(
            children: [
              IslandCursor(
                child: Column(
                  children: [
                    SizedBox(key: ValueKey('arrow')),
                    SizedBox(width: 200, child: TextField()),
                    IslandCursor(
                      variant: IslandCursorVariant.raindrop,
                      child: Column(
                        children: [
                          SizedBox(key: ValueKey('nested drop')),
                          IslandCursor(child: SizedBox(key: ValueKey('deep'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IslandCursor(
                variant: IslandCursorVariant.raindrop,
                child: SizedBox(key: ValueKey('drop')),
              ),
            ],
          ),
        ),
      ),
    );
    expect(seen(t, 'arrow'), warm);
    await t.tap(find.byType(TextField));
    await t.pump();
    expect(
      t.widget<EditableText>(find.byType(EditableText)).selectionColor,
      warm,
    );
    expect(seen(t, 'nested drop'), host);
    expect(seen(t, 'deep'), warm);
    expect(seen(t, 'drop'), host);
  });

  testWidgets('a dark theme deepens the arrow highlight; nesting still wins', (
    t,
  ) async {
    late StateSetter rebuild;
    var brightness = Brightness.dark;
    await t.pumpWidget(
      StatefulBuilder(
        builder: (_, set) {
          rebuild = set;
          return MaterialApp(
            theme: ThemeData(
              brightness: brightness,
              textSelectionTheme: const TextSelectionThemeData(
                selectionColor: host,
              ),
            ),
            home: const Scaffold(
              body: IslandCursor(
                child: Column(
                  children: [
                    SizedBox(key: ValueKey('arrow')),
                    IslandCursor(
                      variant: IslandCursorVariant.raindrop,
                      child: Column(
                        children: [
                          SizedBox(key: ValueKey('nested drop')),
                          IslandCursor(child: SizedBox(key: ValueKey('deep'))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    await t.pumpAndSettle();
    expect(seen(t, 'arrow'), dark);
    expect(seen(t, 'nested drop'), host);
    expect(seen(t, 'deep'), dark);
    rebuild(() => brightness = Brightness.light);
    await t.pumpAndSettle();
    expect(seen(t, 'arrow'), warm);
    expect(seen(t, 'nested drop'), host);
    expect(seen(t, 'deep'), warm);
  });

  testWidgets('raindrop without a host selection colour keeps it unset', (
    t,
  ) async {
    await t.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Overlay.wrap(
          child: const IslandCursor(
            child: IslandCursor(
              variant: IslandCursorVariant.raindrop,
              child: SizedBox(key: ValueKey('drop')),
            ),
          ),
        ),
      ),
    );
    expect(seen(t, 'drop'), isNull);
  });
}
