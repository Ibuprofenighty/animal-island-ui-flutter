import 'dart:convert';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;

// All16 assets have no filled internal region. Every geometric stroke is
// necessary to distinguish the glyph except spinner's pale decorative track.
// Filled multicolor assets require their own adjacency audit and are excluded.
const transparentGlyphs = [
  IslandGlyph.checkCircle,
  IslandGlyph.checkSquare,
  IslandGlyph.chevronDown,
  IslandGlyph.chevronLeft,
  IslandGlyph.chevronRight,
  IslandGlyph.chevronUp,
  IslandGlyph.code,
  IslandGlyph.externalLink,
  IslandGlyph.link,
  IslandGlyph.menu,
  IslandGlyph.paperclip,
  IslandGlyph.spinner,
  IslandGlyph.unlink,
  IslandGlyph.xCircle,
  IslandGlyph.zoomIn,
  IslandGlyph.zoomOut,
];

void main() {
  testWidgets(
    '512 transparent glyph contexts measure every necessary core stroke on its actual backing',
    (t) async {
      final failures = <Map<String, Object?>>[],
          observations = <Map<String, Object?>>[];
      for (final glyph in transparentGlyphs) {
        final svg = await rootBundle.loadString(
          'packages/animal_island_ui/assets/icons/${glyph.assetName}.svg',
        );
        expect(
          RegExp(r'fill="(?!none|transparent)[^"]+"').hasMatch(svg),
          isFalse,
          reason: '${glyph.name} fixture must have no internal painted backing',
        );
        final strokes = <String>{};
        for (final node in RegExp(
          r'<(?:path|rect|circle|line|ellipse|polyline|polygon)\b[^>]*>',
        ).allMatches(svg)) {
          final value =
              RegExp(r'stroke="([^"]+)"').firstMatch(node[0]!)?.group(1) ??
              'currentColor';
          if (glyph == IslandGlyph.spinner && value.toUpperCase() == '#FAEDCD')
            continue;
          strokes.add(value);
        }
        for (final size in [24.0, 48.0]) {
          for (final context in [
            'white-gallery',
            'light-paper',
            'dark-paper',
            ...IslandColorway.values.map((v) => 'card-${v.name}'),
          ]) {
            final boundary = GlobalKey();
            final dark = context == 'dark-paper';
            final data = IslandTheme.create(
              brightness: dark ? Brightness.dark : Brightness.light,
            );
            Widget body = IslandIcon(
              glyph,
              size: size,
              semanticLabel: glyph.name,
            );
            if (context.startsWith('card-')) {
              body = IslandCard(
                colorway: IslandColorway.values.firstWhere(
                  (v) => 'card-${v.name}' == context,
                ),
                child: body,
              );
            } else {
              body = Container(
                decoration: BoxDecoration(
                  color: context == 'white-gallery'
                      ? Colors.white
                      : dark
                      ? IslandTokens.dark.paper
                      : IslandTokens.light.paper,
                ),
                padding: const EdgeInsets.all(16),
                child: body,
              );
            }
            await t.pumpWidget(
              MaterialApp(
                theme: data,
                home: Scaffold(
                  body: Center(
                    child: RepaintBoundary(key: boundary, child: body),
                  ),
                ),
              ),
            );
            await t.pumpAndSettle();
            final icon = find.byType(IslandIcon),
                inherited = IconTheme.of(t.element(find.byType(IslandIcon)))
                    .color!;
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final rect = t
                .getRect(icon)
                .shift(-render.localToGlobal(Offset.zero));
            final pixels = (await t.runAsync(() async {
              final image = await render.toImage();
              final bytes = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              final counts = <int, int>{};
              int argb(int x, int y) {
                final i = (y * image.width + x) * 4;
                return bytes.getUint8(i + 3) << 24 |
                    bytes.getUint8(i) << 16 |
                    bytes.getUint8(i + 1) << 8 |
                    bytes.getUint8(i + 2);
              }

              final bg = argb(rect.left.floor(), rect.top.floor());
              for (var y = rect.top.ceil(); y < rect.bottom.floor(); y++) {
                for (var x = rect.left.ceil(); x < rect.right.floor(); x++) {
                  counts.update(argb(x, y), (n) => n + 1, ifAbsent: () => 1);
                }
              }
              image.dispose();
              return (bg, counts);
            }))!;
            final background = Color(pixels.$1);
            for (final stroke in strokes) {
              final color = stroke == 'currentColor'
                  ? inherited
                  : Color(
                      0xff000000 | int.parse(stroke.substring(1), radix: 16),
                    );
              final count = pixels.$2[color.toARGB32()] ?? 0;
              Color measured = color;
              if (size == 48) {
                expect(
                  count,
                  greaterThan(0),
                  reason:
                      '$glyph $context $stroke must be observed in exact reference-size core pixels',
                );
              } else {
                // At default24px, a diagonal may have no fully covered pixel.
                // Measure its most covered actual raster pixel, retaining the
                // same3.0 threshold; never substitute the declared token value.
                final paints = pixels.$2.keys
                    .where((v) => v != background.toARGB32())
                    .toList();
                expect(paints, isNotEmpty);
                int distance(int value) {
                  final d = Color(value);
                  return ((d.r - color.r) * (d.r - color.r) * 65025 +
                          (d.g - color.g) * (d.g - color.g) * 65025 +
                          (d.b - color.b) * (d.b - color.b) * 65025)
                      .round();
                }

                paints.sort((a, b) => distance(a).compareTo(distance(b)));
                measured = Color(paints.first);
              }
              final ratio = contrast(measured, background);
              final row = <String, Object?>{
                'glyph': glyph.assetName,
                'context': context,
                'size': size,
                'stroke': stroke,
                'actual_core_pixels': count,
                'declared_foreground': color.toARGB32().toRadixString(16),
                'foreground': measured.toARGB32().toRadixString(16),
                'actual_background': background.toARGB32().toRadixString(16),
                'ratio': ratio,
              };
              observations.add(row);
              if (ratio < 3) failures.add(row);
            }
          }
        }
      }
      debugPrint(
        'TRANSPARENT_GLYPH_OBSERVATIONS=${jsonEncode(observations)}',
        wrapWidth: 1000000,
      );
      debugPrint(
        'TRANSPARENT_GLYPH_FAILURES=${jsonEncode(failures)}',
        wrapWidth: 1000000,
      );
      expect(
        observations
            .map((v) => '${v['glyph']}/${v['context']}/${v['size']}')
            .toSet()
            .length,
        512,
      );
      expect(
        failures,
        isEmpty,
        reason: 'Necessary core stroke3.0 on the actual backing, no rounding or antialias-edge substitution',
      );
    },
  );
}
