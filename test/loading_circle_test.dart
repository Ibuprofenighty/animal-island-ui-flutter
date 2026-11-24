import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

final _sailboat = find.byWidgetPredicate(
  (w) => w is IslandIcon && w.glyph == IslandGlyph.sailboat,
);

class _Host {
  _Host(this.t);
  final WidgetTester t;
  var active = true, reduced = false, showBoat = true;
  var type = IslandLoadingType.circle;
  var taps = 0;
  late StateSetter update;

  Future<void> mount() => t.pumpWidget(
    MaterialApp(
      home: StatefulBuilder(
        builder: (_, set) {
          update = set;
          return MediaQuery(
            data: MediaQueryData(
              size: const Size(800, 600),
              disableAnimations: reduced,
            ),
            child: Scaffold(
              body: Stack(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () => taps++,
                      child: const Text('below'),
                    ),
                  ),
                  IslandLoading(
                    type: type,
                    showBoat: showBoat,
                    active: active,
                    tip: const Text('sailing'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Path clip() {
    final clip = t.widget<ClipPath>(
      find
          .ancestor(of: find.text('sailing'), matching: find.byType(ClipPath))
          .first,
    );
    return clip.clipper!.getClip(const Size(800, 600));
  }

  Future<void> tapBelow() => t.tapAt(const Offset(400, 300));
}

void main() {
  testWidgets(
    'an immediately active loading is built with its first frame, before any reconcile frame',
    (t) async {
      for (final type in IslandLoadingType.values) {
        final h = _Host(t)..type = type;
        await h.mount();
        // The overlay entry is inserted after the first frame and painted by
        // the next one; no further show frame is needed.
        await t.pump();
        expect(find.text('sailing'), findsOneWidget, reason: '$type');
        await t.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets(
    'circle form shows the sailboat 20px from the right and 30px from the bottom; snow and showBoat false do not',
    (t) async {
      t.view.physicalSize = const Size(800, 600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final h = _Host(t);
      await h.mount();
      await t.pump();
      expect(_sailboat, findsWidgets);
      final scene = t.getRect(
        find.ancestor(of: _sailboat.first, matching: find.byType(AspectRatio)),
      );
      expect(
        scene,
        const Rect.fromLTWH(800 - 20 - 120, 600 - 30 - 120, 120, 120),
      );
      expect(
        t.widget<IslandIcon>(_sailboat.first).color,
        const Color(0xff2a2a2a),
      );
      h.update(() => h.showBoat = false);
      await t.pump();
      expect(_sailboat, findsNothing);
      expect(find.text('sailing'), findsOneWidget);
      h.update(() {
        h.showBoat = true;
        h.type = IslandLoadingType.snow;
      });
      await t.pump();
      expect(_sailboat, findsNothing);
      expect(find.text('sailing'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'boat bobs and water scrolls while animating; reduced motion keeps them at rest and settles',
    (t) async {
      final h = _Host(t);
      await h.mount();
      await t.pump();
      List<Matrix4> transforms() => [
        for (final w in t.widgetList<Transform>(
          find.ancestor(of: _sailboat.first, matching: find.byType(Transform)),
        ))
          w.transform.clone(),
      ];
      final before = transforms();
      await t.pump(const Duration(milliseconds: 500));
      expect(transforms(), isNot(equals(before)));
      h.update(() => h.reduced = true);
      await t.pumpAndSettle();
      final rest = transforms();
      await t.pump(const Duration(milliseconds: 700));
      expect(transforms(), equals(rest));
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'closing opens a linear centre circle over fadeDuration while background input stays blocked until removal',
    (t) async {
      t.view.physicalSize = const Size(800, 600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final h = _Host(t);
      await h.mount();
      await t.pump();
      expect(h.clip().contains(const Offset(400, 300)), isTrue);
      h.update(() => h.active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      // Full radius: ceil(hypot(800, 600) / 2) + 50 = 550; half way: 275.
      final half = h.clip();
      expect(half.contains(const Offset(400, 300)), isFalse);
      expect(half.contains(const Offset(400 + 270, 300)), isFalse);
      expect(half.contains(const Offset(400 + 280, 300)), isTrue);
      expect(half.contains(const Offset(5, 5)), isTrue);
      await h.tapBelow();
      expect(h.taps, 0, reason: 'the exiting layer still blocks input');
      // Reactivation closes the circle at once.
      h.update(() => h.active = true);
      await t.pump();
      await t.pump();
      expect(h.clip().contains(const Offset(400, 300)), isTrue);
      expect(find.text('sailing'), findsOneWidget);
      h.update(() => h.active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 590));
      expect(h.clip().contains(const Offset(5, 5)), isFalse);
      await t.pump(const Duration(milliseconds: 20));
      await t.pump();
      expect(find.text('sailing'), findsNothing);
      await h.tapBelow();
      expect(h.taps, 1);
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('reduced motion removes the circle form immediately on close', (
    t,
  ) async {
    final h = _Host(t)..reduced = true;
    await h.mount();
    await t.pumpAndSettle();
    expect(find.text('sailing'), findsOneWidget);
    h.update(() => h.active = false);
    await t.pump();
    await t.pump();
    await t.pump();
    expect(find.text('sailing'), findsNothing);
    await h.tapBelow();
    expect(h.taps, 1);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets(
    'sailboat water is the reference 1.9 stroke and scrolls one wave period without a seam',
    (t) async {
      final h = _Host(t);
      await h.mount();
      await t.pump();
      final scene = find
          .ancestor(of: _sailboat.first, matching: find.byType(AspectRatio))
          .first;
      // Vertical water coverage and centre per device column across the reference
      // window (x 9.63..38.37 of 48), in glyph units, below the hull.
      Future<(List<double>, List<double>)> water() async {
        final rect = t.getRect(scene);
        RenderObject node = t.renderObject(scene);
        while (!node.isRepaintBoundary) {
          node = node.parent!;
        }
        final dpr = t.view.devicePixelRatio;
        final unit = rect.width / 48 * dpr;
        // The scene paints into the root view layer, which already carries
        // the device pixel ratio.
        final box = node is RenderBox ? node : null;
        final origin = box == null
            ? rect.topLeft * dpr
            : box.globalToLocal(rect.topLeft) * dpr;
        final image = await t.runAsync(
          () => (node.debugLayer! as OffsetLayer).toImage(
            box == null ? node.paintBounds : Offset.zero & box.size,
            pixelRatio: box == null ? 1 : dpr,
          ),
        );
        final data = (await t.runAsync(
          () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
        ))!;
        List<int> at(int x, int y) {
          final p = (y * image!.width + x) * 4;
          return [data.getUint8(p), data.getUint8(p + 1), data.getUint8(p + 2)];
        }

        const ink = [0x2a, 0x9d, 0x8f];
        final thickness = <double>[], centre = <double>[];
        for (
          var x = (origin.dx + 10 * unit).ceil();
          x < origin.dx + 38 * unit;
          x++
        ) {
          final bg = at(x, (origin.dy + 41.4 * unit).round());
          final span = [for (var c = 0; c < 3; c++) ink[c] - bg[c]];
          final norm = span.fold<int>(0, (a, v) => a + v * v);
          var sum = 0.0, moment = 0.0;
          for (
            var y = (origin.dy + 41.4 * unit).round();
            y < origin.dy + 47.5 * unit;
            y++
          ) {
            final px = at(x, y);
            var dot = 0;
            for (var c = 0; c < 3; c++) {
              dot += (px[c] - bg[c]) * span[c];
            }
            final weight = (dot / norm).clamp(0.0, 1.0);
            sum += weight;
            moment += weight * (y - origin.dy);
          }
          thickness.add(sum / unit);
          centre.add(moment / sum / unit);
        }
        return (thickness, centre);
      }

      final (thickness, start) = await water();
      final mean = thickness.reduce((a, b) => a + b) / thickness.length;
      // Thickness: 1.9 across a gently sloped curve reads about 2.0 units;
      // the glyph's own 2.5 stroke would read about 2.6.
      expect(mean, closeTo(2.0, .15));
      // One wave period (9.575 of the 28.74 window per 4s) later, across the
      // 4s restart too, the water line centre is where it was.
      for (var k = 1; k <= 3; k++) {
        await t.pump(const Duration(microseconds: 1332638));
        final (_, later) = await water();
        var drift = 0.0;
        for (var i = 0; i < start.length; i++) {
          drift = math.max(drift, (later[i] - start[i]).abs());
        }
        expect(drift, lessThan(.05), reason: 'period $k');
      }
      await t.pumpWidget(const SizedBox());
    },
  );
}
