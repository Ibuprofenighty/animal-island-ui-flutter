import 'dart:convert';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;

// Membership is every packaged glyph whose SVG source paints a fill; only the
// glyphs below are held out, each kept with upstream paint by owner rule O7
// (docs/icon-paint-roles.json import_v1_14.settled gives the measured reason).
// The host contour oracle does not certify interior
// semantic details: those have separately named actual-backing probes below and
// in the existing oracle.
const hostContourHeld = <String, String>{
  'barcode': 'coloured fill silhouette; upstream paint kept by owner rule O7',
  'bolt': 'coloured fill silhouette; upstream paint kept by owner rule O7',
  'grip': 'coloured fill silhouette; upstream paint kept by owner rule O7',
  'sparkles': 'coloured fill silhouette; upstream paint kept by owner rule O7',
};
const filledGlyphCount = 659;

// Glyphs per rendered page: below flutter_svg's 100-picture cache, so one
// frame never evicts pictures it is still drawing.
const svgCachePage = 90;

void main() => filledGlyphRoleOracle();

void filledGlyphRoleOracle() {
  for (final size in [24.0, 48.0]) {
    for (final group in ['host', 'solid', 'pattern']) {
      testWidgets(
        'All filled glyph host contours and named semantic roles use actual backing pixels at ${size.toInt()}px on $group surfaces',
        (t) async {
          t.view.physicalSize = const Size(1200, 1000);
          t.view.devicePixelRatio = 1;
          addTearDown(t.view.resetPhysicalSize);
          addTearDown(t.view.resetDevicePixelRatio);
          final failures = <Map<String, Object?>>[];
          final rows = <Map<String, Object?>>[];
          final filled = <IslandGlyph>[];
          for (final glyph in IslandGlyph.values) {
            final svg = await rootBundle.loadString(
              'packages/animal_island_ui/assets/icons/${glyph.assetName}.svg',
              cache: false,
            );
            if (RegExp(r'fill="(?!none|transparent)[^"]+"').hasMatch(svg)) {
              filled.add(glyph);
            }
          }
          expect(
            filled.length,
            filledGlyphCount,
            reason: 'Filled membership is bound to actual packaged SVG source',
          );
          expect(
            hostContourHeld.keys.toSet().difference(
              filled.map((g) => g.assetName).toSet(),
            ),
            isEmpty,
          );
          final glyphs = [
            for (final g in filled)
              if (!hostContourHeld.containsKey(g.assetName)) g,
          ];
          final pages = [
            for (var i = 0; i < glyphs.length; i += svgCachePage)
              glyphs.sublist(
                i,
                i + svgCachePage > glyphs.length
                    ? glyphs.length
                    : i + svgCachePage,
              ),
          ];
          await t.binding.setSurfaceSize(const Size(1200, 1000));
          addTearDown(() => t.binding.setSurfaceSize(null));
          final contexts = [
            if (group == 'host') ...[
              'light-canvas',
              'light-paper',
              'dark-canvas',
              'dark-paper',
            ],
            for (final c in IslandColorway.values)
              if (group != 'host') '$group-${c.name}',
          ];

          for (final context in contexts) {
            for (final page in pages) {
              final dark = context.startsWith('dark');
              final tokens = dark ? IslandTokens.dark : IslandTokens.light;
              final key = GlobalKey();
              late StateSetter setFixture;
              var visible = true;
              Widget panel(Widget grid) {
                if (context.startsWith('solid-') ||
                    context.startsWith('pattern-')) {
                  final c = IslandColorway.values.firstWhere(
                    (c) => context.endsWith('-${c.name}'),
                  );
                  return IslandCard(
                    colorway: c,
                    pattern: context.startsWith('pattern-') ? c : null,
                    padding: const EdgeInsets.all(16),
                    child: grid,
                  );
                }
                return ColoredBox(
                  color: context.endsWith('paper')
                      ? tokens.paper
                      : tokens.canvas,
                  child: grid,
                );
              }

              await t.pumpWidget(
                MaterialApp(
                  theme: IslandTheme.create(
                    brightness: dark ? Brightness.dark : Brightness.light,
                  ),
                  home: Scaffold(
                    body: RepaintBoundary(
                      key: key,
                      child: SizedBox(
                        width: 1120,
                        child: StatefulBuilder(
                          builder: (context, update) {
                            setFixture = update;
                            return panel(
                              Wrap(
                                children: [
                                  for (final g in page)
                                    SizedBox(
                                      width: 72,
                                      height: 60,
                                      child: Center(
                                        child: visible
                                            ? IslandIcon(
                                                g,
                                                key: ValueKey(g),
                                                size: size,
                                              )
                                            : SizedBox.square(dimension: size),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
              await t.pumpAndSettle();
              final boundary =
                  key.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final origins = <String, Offset>{};
              final inks = <String, Color>{};
              for (final g in page) {
                final finder = find.byKey(ValueKey(g));
                origins[g.assetName] = boundary.globalToLocal(
                  t.getTopLeft(finder),
                );
                inks[g.assetName] = IconTheme.of(t.element(finder)).color!;
              }
              Future<(ui.Image, ByteData)> capture() async {
                final image = (await t.runAsync(() => boundary.toImage()))!;
                final bytes = (await t.runAsync(
                  () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
                ))!;
                return (image, bytes);
              }

              final painted = await capture();
              setFixture(() => visible = false);
              await t.pumpAndSettle();
              final bare = await capture();
              int raw((ui.Image, ByteData) frame, int x, int y) =>
                  frame.$2.getUint32((y * frame.$1.width + x) * 4);
              Color pixel((ui.Image, ByteData) frame, int x, int y) {
                final i = (y * frame.$1.width + x) * 4;
                return Color.fromARGB(
                  frame.$2.getUint8(i + 3),
                  frame.$2.getUint8(i),
                  frame.$2.getUint8(i + 1),
                  frame.$2.getUint8(i + 2),
                );
              }

              for (final g in page) {
                final origin = origins[g.assetName]!;
                final ink = inks[g.assetName]!;
                final inkRaw =
                    (ink.toARGB32() << 8 | ink.toARGB32() >>> 24) & 0xffffffff;
                var count = 0;
                var worst = 100.0;
                for (
                  var y = origin.dy.ceil();
                  y < (origin.dy + size).floor();
                  y++
                ) {
                  for (
                    var x = origin.dx.ceil();
                    x < (origin.dx + size).floor();
                    x++
                  ) {
                    if (raw(painted, x, y) != inkRaw) continue;
                    var touchesHost = false;
                    for (final (dx, dy) in [(0, -2), (0, 2), (-2, 0), (2, 0)]) {
                      if (raw(painted, x + dx, y + dy) ==
                          raw(bare, x + dx, y + dy))
                        touchesHost = true;
                    }
                    if (!touchesHost) continue;
                    count++;
                    final ratio = contrast(
                      pixel(painted, x, y),
                      pixel(bare, x, y),
                    );
                    if (ratio < worst) worst = ratio;
                  }
                }
                final row = <String, Object?>{
                  'glyph': g.assetName,
                  'role': 'host-facing contextual contour',
                  'context': context,
                  'size': size,
                  'core_pixels': count,
                  'minimum_ratio': worst,
                };
                rows.add(row);
                if (count == 0 && fixedSilhouettes.containsKey(g.assetName)) {
                  final paints = fixedSilhouettes[g.assetName]!;
                  var best = 0.0;
                  for (
                    var y = origin.dy.ceil();
                    y < (origin.dy + size).floor();
                    y++
                  ) {
                    for (
                      var x = origin.dx.ceil();
                      x < (origin.dx + size).floor();
                      x++
                    ) {
                      final color = pixel(painted, x, y);
                      if (!paints.contains(color)) continue;
                      final ratio = contrast(color, pixel(bare, x, y));
                      if (ratio > best) best = ratio;
                    }
                  }
                  row['fixed_silhouette_ratio'] = best;
                  row['qualification'] = 'Original fixed contour or opaque closed silhouette; interior marks remain independently required';
                  if (best < 3) failures.add(row);
                } else if (count == 0 || worst < 3) {
                  failures.add(row);
                }
                if (size == 48) {
                  for (final probe in semanticProbes.where(
                    (p) => p.glyph == g.assetName,
                  )) {
                    final bp = origin + probe.background;
                    final bg = pixel(
                      probe.host ? bare : painted,
                      bp.dx.floor(),
                      bp.dy.floor(),
                    );
                    final candidates = <(Color, Color, double)>[];
                    for (var dy = -1; dy <= 1; dy++) {
                      for (var dx = -1; dx <= 1; dx++) {
                        final p =
                            origin +
                            probe.foreground +
                            Offset(dx.toDouble(), dy.toDouble());
                        final color = pixel(
                          painted,
                          p.dx.floor(),
                          p.dy.floor(),
                        );
                        if (probe.foregrounds.contains(color) ||
                            (probe.host && color == ink))
                          candidates.add((
                            color,
                            probe.host
                                ? pixel(bare, p.dx.floor(), p.dy.floor())
                                : bg,
                            contrast(
                              color,
                              probe.host
                                  ? pixel(bare, p.dx.floor(), p.dy.floor())
                                  : bg,
                            ),
                          ));
                      }
                    }
                    candidates.sort((a, b) => b.$3.compareTo(a.$3));
                    final ratio = candidates.isEmpty
                        ? 0.0
                        : candidates.first.$3;
                    final sr = <String, Object?>{
                      'glyph': g.assetName,
                      'role': probe.role,
                      'context': context,
                      'size': size,
                      'foreground': candidates.isEmpty
                          ? null
                          : candidates.first.$1.toARGB32().toRadixString(16),
                      'background':
                          (candidates.isEmpty ? bg : candidates.first.$2)
                              .toARGB32()
                              .toRadixString(16),
                      'minimum': 3,
                      'ratio': ratio,
                      'core_candidates': candidates.length,
                    };
                    rows.add(sr);
                    if ((!probe.host && bg != probe.expectedBackground) ||
                        ratio < 3)
                      failures.add(sr);
                  }
                }
              }
              painted.$1.dispose();
              bare.$1.dispose();
              expect(t.takeException(), isNull);
            }
          }

          debugPrint(
            'FILLED_GLYPH_ROLE_OBSERVATIONS=${jsonEncode(rows)}',
            wrapWidth: 1000000,
          );
          debugPrint(
            'FILLED_GLYPH_ROLE_FAILURES=${jsonEncode(failures)}',
            wrapWidth: 1000000,
          );
          expect(
            rows
                .where((r) => r['role'] == 'host-facing contextual contour')
                .length,
            (filledGlyphCount - hostContourHeld.length) * contexts.length,
          );
          expect(
            failures,
            isEmpty,
            reason: 'Every named role needs an actual painted core and actual backing at3.0; host contour coverage does not exempt interior roles.',
          );
        },
      );
    }
  }
}

class SemanticProbe {
  const SemanticProbe(
    this.glyph,
    this.role,
    this.foreground,
    this.background,
    this.foregrounds,
    this.expectedBackground, {
    this.host = false,
  });
  final String glyph, role;
  final Offset foreground, background;
  final List<Color> foregrounds;
  final Color? expectedBackground;
  final bool host;
}

const darkFace = [Color(0xff2a2a2a), Color(0xff000000)];
const hostPaints = [
  Color(0xff2a2a2a),
  Color(0xff8b5e3c),
  Color(0xffb03038),
  Color(0xfffaedcd),
  Color(0xff2b2118),
  Color(0xffe05a5a),
  Color(0xff000000),
];
const fixedSilhouettes = <String, List<Color>>{
  'alert-triangle': [Color(0xff2a2a2a), Color(0xffe9c46a)],
  'copy': [Color(0xff2a2a2a), Color(0xffffffff), Color(0xfffaedcd)],
  'inbox': [Color(0xff2a2a2a), Color(0xff2a9d8f)],
};
const semanticProbes = <SemanticProbe>[
  SemanticProbe(
    'apple',
    'fruit stem',
    Offset(25, 9),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'balloon',
    'string',
    Offset(24, 39),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'badge-check',
    'approval check',
    Offset(22, 24),
    Offset(24, 14),
    [Color(0xffe9c46a)],
    Color(0xff264653),
  ),
  SemanticProbe('basketball', 'ball seams', Offset(24, 20), Offset(20, 20), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('bee', 'body stripe', Offset(19, 29), Offset(22, 29), [
    Color(0xff2a2a2a),
  ], Color(0xffe9c46a)),
  SemanticProbe('bulb', 'left eye', Offset(20, 18), Offset(24, 14), [
    Color(0xff2a2a2a),
  ], Color(0xffe9c46a)),
  SemanticProbe('bulb', 'right eye', Offset(28, 18), Offset(24, 14), [
    Color(0xff2a2a2a),
  ], Color(0xffe9c46a)),
  SemanticProbe('cactus', 'left eye', Offset(23, 20), Offset(24, 29), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('cactus', 'right eye', Offset(26, 20), Offset(24, 29), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('camera', 'lens core', Offset(24, 28), Offset(10, 28), [
    Color(0xffe76f51),
  ], Color(0xff264653)),
  SemanticProbe('compass', 'direction needle', Offset(26, 24), Offset(14, 24), [
    Color(0xffe76f51),
  ], Color(0xff264653)),
  SemanticProbe(
    'credit-card',
    'number stripe',
    Offset(28, 32),
    Offset(37, 31),
    [Color(0xffffffff)],
    Color(0xff2a9d8f),
  ),
  SemanticProbe('save', 'label writing', Offset(23, 31), Offset(24, 28), [
    Color(0xff2a2a2a),
  ], Color(0xfffaedcd)),
  SemanticProbe('apple', 'left eye', Offset(20, 26), Offset(24, 22), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('apple', 'right eye', Offset(28, 26), Offset(24, 22), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('balloon', 'left eye', Offset(20, 19), Offset(24, 12), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('balloon', 'right eye', Offset(28, 19), Offset(24, 12), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('cat', 'left eye', Offset(18, 26), Offset(24, 23), [
    Color(0xff2a2a2a),
    Color(0xffffffff),
  ], Color(0xff264653)),
  SemanticProbe('cat', 'right eye', Offset(30, 26), Offset(24, 23), [
    Color(0xff2a2a2a),
    Color(0xffffffff),
  ], Color(0xff264653)),
  SemanticProbe('fish', 'eye', Offset(11, 22), Offset(20, 22), [
    Color(0xff2a2a2a),
  ], Color(0xff2a9d8f)),
  SemanticProbe('fox', 'left eye', Offset(18, 22), Offset(24, 20), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('fox', 'right eye', Offset(30, 22), Offset(24, 20), [
    Color(0xff2a2a2a),
  ], Color(0xffe76f51)),
  SemanticProbe('frog', 'left eye', Offset(14, 15), Offset(24, 26), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('frog', 'right eye', Offset(34, 15), Offset(24, 26), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('rabbit', 'left eye', Offset(19, 29), Offset(24, 27), [
    Color(0xff2a2a2a),
  ], Color(0xfffaedcd)),
  SemanticProbe('rabbit', 'right eye', Offset(29, 29), Offset(24, 27), [
    Color(0xff2a2a2a),
  ], Color(0xfffaedcd)),
  SemanticProbe('tree', 'left eye', Offset(20, 16), Offset(24, 12), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('tree', 'right eye', Offset(28, 16), Offset(24, 12), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('plus', 'vertical sign', Offset(24, 19), Offset(20, 18), [
    Color(0xff2a2a2a),
  ], Color(0xffe9c46a)),
  SemanticProbe('plus', 'horizontal sign', Offset(19, 24), Offset(20, 18), [
    Color(0xff2a2a2a),
  ], Color(0xffe9c46a)),
  SemanticProbe('minus', 'minus sign', Offset(24, 24), Offset(24, 17), [
    Color(0xff2a2a2a),
  ], Color(0xffe9c46a)),
  SemanticProbe(
    'shield',
    'shield approval mark',
    Offset(22, 29),
    Offset(24, 15),
    [Color(0xffe9c46a)],
    Color(0xff264653),
  ),
  SemanticProbe('check', 'check sign', Offset(21, 30), Offset(24, 13), [
    Color(0xffffffff),
  ], Color(0xff588157)),
  SemanticProbe('close', 'close sign', Offset(24, 24), Offset(14, 24), [
    Color(0xffb03038),
  ], Color(0xfffaedcd)),
  SemanticProbe('clock', 'clock hand', Offset(24, 15), Offset(18, 18), [
    Color(0xffffffff),
  ], Color(0xff2a9d8f)),
  SemanticProbe('file', 'document writing', Offset(24, 26), Offset(24, 29), [
    Color(0xff2a2a2a),
  ], Color(0xfffaedcd)),
  SemanticProbe('leaf', 'leaf vein', Offset(24, 24), Offset(24, 20), [
    Color(0xff2a2a2a),
  ], Color(0xff588157)),
  SemanticProbe('globe', 'meridian/equator', Offset(18, 21), Offset(24, 17), [
    Color(0xff2a2a2a),
  ], Color(0xff2a9d8f)),
  SemanticProbe('penguin', 'left eye rim', Offset(19, 16), Offset(24, 16), [
    Color(0xff2a2a2a),
    Color(0xffffffff),
  ], Color(0xff264653)),
  SemanticProbe('penguin', 'right eye rim', Offset(29, 16), Offset(24, 16), [
    Color(0xff2a2a2a),
    Color(0xffffffff),
  ], Color(0xff264653)),
  SemanticProbe('penguin', 'beak', Offset(24, 24), Offset(24, 13), [
    Color(0xff2a2a2a),
    Color(0xffe76f51),
  ], Color(0xff264653)),
  SemanticProbe('owl', 'left eye rim', Offset(18, 16), Offset(24, 14), [
    Color(0xff2a2a2a),
    Color(0xffffffff),
  ], Color(0xff264653)),
  SemanticProbe('owl', 'right eye rim', Offset(30, 16), Offset(24, 14), [
    Color(0xff2a2a2a),
    Color(0xffffffff),
  ], Color(0xff264653)),
  SemanticProbe('owl', 'beak', Offset(24, 29), Offset(24, 34), [
    Color(0xff2a2a2a),
    Color(0xffe9c46a),
  ], Color(0xff264653)),
  SemanticProbe(
    'snail',
    'left eye stalk',
    Offset(9, 18),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'snail',
    'right eye stalk',
    Offset(17, 18),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'bell-off',
    'inside cream slash',
    Offset(24, 25),
    Offset(24, 29),
    [Color(0xffb03038), Color(0xffe05a5a)],
    Color(0xfffaedcd),
  ),
  SemanticProbe(
    'eye-off',
    'inside pupil slash',
    Offset(24, 24),
    Offset(20, 26),
    [Color(0xffb03038), Color(0xffe05a5a), Color(0xffe76f51)],
    Color(0xff264653),
  ),
  SemanticProbe(
    'bear',
    'left eye',
    Offset(18, 24),
    Offset(24, 20),
    darkFace,
    Color(0xff8b5e3c),
  ),
  SemanticProbe(
    'bear',
    'right eye',
    Offset(30, 24),
    Offset(24, 20),
    darkFace,
    Color(0xff8b5e3c),
  ),
  SemanticProbe(
    'dog',
    'left eye',
    Offset(18, 24),
    Offset(24, 20),
    darkFace,
    Color(0xff8b5e3c),
  ),
  SemanticProbe(
    'dog',
    'right eye',
    Offset(30, 24),
    Offset(24, 20),
    darkFace,
    Color(0xff8b5e3c),
  ),
  SemanticProbe(
    'dog',
    'nose',
    Offset(24, 32),
    Offset(31, 32),
    darkFace,
    Color(0xff8b5e3c),
  ),
  SemanticProbe(
    'coffee',
    'steam-left',
    Offset(18, 14),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'coffee',
    'steam-middle',
    Offset(24, 14),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'coffee',
    'steam-right',
    Offset(30, 14),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'coffee-cup',
    'steam-left',
    Offset(20, 6),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'coffee-cup',
    'steam-right',
    Offset(27, 6),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe('coffee-cup', 'heart emblem', Offset(24, 27), Offset(20, 27), [
    Color(0xfffaedcd),
    Color(0xfffffdf7),
  ], Color(0xffe76f51)),
  SemanticProbe(
    'cherry',
    'left connector',
    Offset(19, 15),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'cherry',
    'right connector',
    Offset(32, 20),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'bell-off',
    'outside lower slash',
    Offset(10, 39),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'bell-off',
    'outside upper slash',
    Offset(38, 11),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'eye-off',
    'outside upper slash',
    Offset(8, 8),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
  SemanticProbe(
    'eye-off',
    'outside lower slash',
    Offset(40, 40),
    Offset(1, 1),
    hostPaints,
    null,
    host: true,
  ),
];
