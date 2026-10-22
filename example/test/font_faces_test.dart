import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('IslandGallerySans');
    for (final weight in [400, 500, 900]) {
      loader.addFont(
        rootBundle.load('assets/fonts/IslandGallerySans-$weight.ttf'),
      );
    }
    await loader.load();
  });
  testWidgets(
    'CJK400/500 stay distinct and600..900 use reference bold without synthesis',
    (t) async {
      Future<Uint8List> raster(FontWeight weight) async {
        await t.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Center(
              child: RepaintBoundary(
                key: const ValueKey('glyph'),
                child: SizedBox(
                  width: 280,
                  height: 60,
                  child: Text(
                    '双层纸飘带类型',
                    style: TextStyle(
                      fontFamily: 'IslandGallerySans',
                      fontSize: 28,
                      fontWeight: weight,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.pump();
        final boundary = t.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('glyph')),
        );
        final image = await t.runAsync(() => boundary.toImage());
        final data = await t.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
        );
        image!.dispose();
        return data!.buffer.asUint8List();
      }

      final regular = await raster(FontWeight.w400);
      final medium = await raster(FontWeight.w500);
      final bold = await raster(FontWeight.w700);
      expect(medium, isNot(orderedEquals(regular)));
      expect(bold, isNot(orderedEquals(medium)));
      expect(await raster(FontWeight.w600), orderedEquals(bold));
      expect(await raster(FontWeight.w800), orderedEquals(bold));
      expect(await raster(FontWeight.w900), orderedEquals(bold));
    },
  );
}
