import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;

void main() {
  testWidgets(
    'Necessary transparent SVG strokes survive actual host and Card backgrounds',
    (t) async {
      final failures = <String>[];
      final glyphs = [
        for (final name in {
          ...contextualGlyphSamples.keys,
          ...filledGlyphSamples.keys,
        })
          IslandGlyph.values.firstWhere((g) => g.assetName == name),
      ];
      final contexts = [
        'light-canvas',
        'light-paper',
        'dark-canvas',
        'dark-paper',
        for (final c in IslandColorway.values) ...[
          'pattern-${c.name}',
          'solid-${c.name}',
        ],
      ];
      for (final context in contexts) {
        final dark = context.startsWith('dark');
        final tokens = dark ? IslandTokens.dark : IslandTokens.light;
        final key = GlobalKey();
        Widget content = Wrap(
          children: [
            for (final g in glyphs)
              SizedBox(
                width: 72,
                height: 60,
                child: Center(child: IslandIcon(g, key: ValueKey(g), size: 48)),
              ),
          ],
        );
        if (context.startsWith('pattern-') || context.startsWith('solid-')) {
          final c = IslandColorway.values.firstWhere(
            (c) => context.endsWith('-${c.name}'),
          );
          content = IslandCard(
            colorway: c,
            pattern: context.startsWith('pattern-') ? c : null,
            padding: const EdgeInsets.all(16),
            child: content,
          );
        } else {
          content = ColoredBox(
            color: context.endsWith('paper') ? tokens.paper : tokens.canvas,
            child: content,
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
                child: SizedBox(width: 720, child: content),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = (await t.runAsync(() => boundary.toImage()))!;
        final bytes = (await t.runAsync(
          () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
        ))!;
        Color sample(Offset point) {
          final i = (point.dy.floor() * image.width + point.dx.floor()) * 4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        }

        for (final g in glyphs) {
          final origin = boundary.globalToLocal(
            t.getTopLeft(find.byKey(ValueKey(g))),
          );
          final backing = sample(origin + const Offset(1, 1));
          for (final point
              in contextualGlyphSamples[g.assetName] ?? const <Offset>[]) {
            final actual = sample(origin + point);
            final ratio = contrast(actual, backing);
            if (ratio < 3)
              failures.add(
                '$context ${g.assetName} $point: $actual/$backing=$ratio',
              );
          }
          for (final (inkPoint, backingPoint, expectedBacking)
              in filledGlyphSamples[g.assetName] ??
                  const <(Offset, Offset, Color)>[]) {
            final ownBacking = sample(origin + backingPoint);
            final actualInk = sample(origin + inkPoint);
            if (ownBacking != expectedBacking) {
              failures.add(
                '$context ${g.assetName} wrong own backing at$backingPoint: $ownBacking, expected$expectedBacking',
              );
            }
            final ratio = contrast(actualInk, ownBacking);
            if (ratio < 3) {
              failures.add(
                '$context ${g.assetName} own backing $inkPoint/$backingPoint: $actualInk/$ownBacking=$ratio',
              );
            }
          }
        }
        image.dispose();
        expect(t.takeException(), isNull);
      }
      expect(failures, isEmpty, reason: failures.join('\n'));
    },
  );
  testWidgets(
    'Mouse wheel boundary contrasts with its actual tiny coral backing',
    (t) async {
      // At48px the2px-high rounded inner fill has no fully covered pixel for
      // every fractional origin.96px preserves geometry and measures an opaque
      // coral core, rather than substituting a declared color for actual paint.
      for (final dark in [false, true]) {
        final boundaryKey = GlobalKey();
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            home: Scaffold(
              body: RepaintBoundary(
                key: boundaryKey,
                child: const SizedBox(
                  width: 128,
                  height: 128,
                  child: Center(child: IslandIcon(IslandGlyph.mouse, size: 96)),
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = (await t.runAsync(() => boundary.toImage()))!;
        final bytes = (await t.runAsync(
          () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
        ))!;
        final origin = boundary.globalToLocal(
          t.getTopLeft(find.byType(IslandIcon)),
        );
        Color pixel(Offset p) {
          final i =
              ((origin.dy + p.dy).floor() * image.width +
                  (origin.dx + p.dx).floor()) *
              4;
          return Color.fromARGB(
            bytes.getUint8(i + 3),
            bytes.getUint8(i),
            bytes.getUint8(i + 1),
            bytes.getUint8(i + 2),
          );
        }

        final backing = pixel(const Offset(48, 28));
        final ink = pixel(const Offset(48, 22));
        expect(backing, const Color(0xffe76f51));
        expect(contrast(ink, backing), greaterThanOrEqualTo(3));
        image.dispose();
        expect(t.takeException(), isNull);
      }
    },
  );
}

const contextualGlyphSamples = <String, List<Offset>>{
  'alert-circle': [Offset(24, 7), Offset(24, 20), Offset(24, 33)],
  'help-circle': [Offset(24, 7), Offset(19, 19), Offset(24, 33)],
  'info': [Offset(24, 7), Offset(24, 15.5), Offset(24, 28)],
  'arrow-down': [Offset(24, 15)],
  'arrow-left': [Offset(34, 24)],
  'arrow-right': [Offset(14, 24)],
  'arrow-up': [Offset(24, 33)],
  'arrow-up-right': [Offset(23, 25), Offset(34, 17)],
  'bicycle': [Offset(5, 33), Offset(43, 33), Offset(18.5, 24)],
  'headphones': [Offset(24, 14.5)],
  'list': [Offset(30, 14), Offset(30, 24), Offset(30, 34)],
  'maximize': [Offset(6, 11), Offset(37, 6), Offset(42, 37), Offset(11, 42)],
  'mic': [Offset(24, 33), Offset(24, 37), Offset(24, 42)],
  'music': [Offset(30, 12.2), Offset(40, 20)],
  'redo': [Offset(10, 24)],
  'undo': [Offset(38, 24)],
  'search': [Offset(37, 37)],
  'share': [Offset(23, 18.15), Offset(23, 29.85)],
  'sliders': [Offset(10, 15), Offset(10, 24), Offset(10, 33)],
  'sun': [
    Offset(24, 6),
    Offset(24, 42),
    Offset(6, 24),
    Offset(42, 24),
    Offset(11, 11),
    Offset(37, 37),
    Offset(11, 37),
    Offset(37, 11),
  ],
  'lock': [Offset(24, 9)],
  'lock-open': [Offset(24, 9)],
  'key': [Offset(38, 24), Offset(30, 28), Offset(36, 28)],
  'flag': [Offset(12, 37)],
  'download': [Offset(24, 12)],
  'upload': [Offset(24, 32)],
  'globe': [Offset(24, 37), Offset(24, 42)],
  'lamp': [Offset(24, 32)],
  'shopping-bag': [Offset(24, 10.25)],
  'trophy': [Offset(8, 17), Offset(40, 17), Offset(24, 33)],
  'dumbbell': [Offset(24, 24)],
  'sort': [Offset(15, 35), Offset(33, 13)],
  'refresh': [Offset(24, 9), Offset(24, 39)],
  'volume': [Offset(31, 24), Offset(39, 24)],
  'volume-x': [Offset(32.5, 23)],
  'wifi': [Offset(24, 13.67), Offset(24, 24)],
  'rainbow': [Offset(24, 17)],
  'umbrella': [Offset(24, 36), Offset(27, 42)],
  'user-plus': [Offset(37, 28), Offset(42, 33)],
  'penguin': [Offset(8.8, 32), Offset(39.2, 32)],
  'water-cup': [Offset(30.5, 6)],
  'snowflake': [Offset(24, 5), Offset(24, 43), Offset(24, 24)],
  'scooter': [Offset(36, 43), Offset(10, 43), Offset(19.5, 9)],
};

// Each tuple binds a necessary painted identity mark to its actual opaque
// artwork backing. A wrong backing is a fixture failure, never a contrast pass.
// Static facial flourishes/highlights are preserved art, outside this claim.
const filledGlyphSamples = <String, List<(Offset, Offset, Color)>>{
  'alert-triangle': [(Offset(24, 35), Offset(30, 30), Color(0xffe9c46a))],
  'calendar': [(Offset(24, 28), Offset(24, 35), Color(0xfffaedcd))],
  'chat': [(Offset(24, 21), Offset(24, 28), Color(0xffe9c46a))],
  'keyboard': [(Offset(13, 21), Offset(24, 18), Color(0xffe9c46a))],
  'eye': [(Offset(18, 24), Offset(13, 24), Color(0xfffaedcd))],
  'donut': [(Offset(18, 24), Offset(24, 24), Color(0xffffffff))],
  'location': [(Offset(18, 22), Offset(24, 22), Color(0xfffaedcd))],
  'lock': [(Offset(24, 29), Offset(16, 29), Color(0xffe9c46a))],
  'lock-open': [(Offset(24, 29), Offset(16, 29), Color(0xffe9c46a))],
  'smile': [(Offset(18, 20), Offset(24, 20), Color(0xffe9c46a))],
  'thermometer': [(Offset(23, 25), Offset(24, 14), Color(0xfffaedcd))],
  'home': [(Offset(20, 35), Offset(16, 35), Color(0xffe9c46a))],
  'tag': [(Offset(31, 14), Offset(26, 20), Color(0xfff4a6a4))],
  'image': [(Offset(16, 17), Offset(24, 16), Color(0xfffaedcd))],
  'star': [(Offset(20, 22), Offset(24, 17), Color(0xffe9c46a))],
  'monitor': [(Offset(18, 17), Offset(24, 17), Color(0xff2a9d8f))],
  'charger': [(Offset(24, 21), Offset(14, 27), Color(0xffe76f51))],
  'map': [(Offset(32, 12), Offset(34, 22), Color(0xfffaedcd))],
  'mouse': [(Offset(24, 20), Offset(24, 27), Color(0xff2a9d8f))],
  'trophy': [(Offset(24, 14), Offset(18, 22), Color(0xffe9c46a))],
};
