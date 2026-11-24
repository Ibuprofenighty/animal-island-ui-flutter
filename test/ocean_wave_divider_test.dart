import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool reduced = false, bool ticking = true}) =>
    MaterialApp(
      theme: IslandTheme.create(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: TickerMode(
            enabled: ticking,
            child: Scaffold(
              backgroundColor: const Color(0xffffffff),
              body: Align(alignment: Alignment.topLeft, child: child),
            ),
          ),
        ),
      ),
    );

final boundary = GlobalKey();

Widget wave({bool animated = true}) => RepaintBoundary(
  key: boundary,
  child: ColoredBox(
    color: const Color(0xffffffff),
    child: SizedBox(
      width: 300,
      child: IslandDivider(
        variant: IslandDividerVariant.oceanWave,
        animated: animated,
      ),
    ),
  ),
);

int get ticking => SchedulerBinding.instance.transientCallbackCount;

Future<ByteData> capture(WidgetTester t) async => (await t.runAsync(() async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await render.toImage(pixelRatio: 1);
  return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
}))!;

List<int> rgb(ByteData data, int x, int y) {
  final p = (y * 300 + x) * 4;
  return [data.getUint8(p), data.getUint8(p + 1), data.getUint8(p + 2)];
}

int semanticsNodes(WidgetTester t) {
  var count = 0;
  bool visit(SemanticsNode node) {
    count++;
    node.visitChildren(visit);
    return true;
  }

  visit(t.getSemantics(find.byType(Scaffold)));
  return count;
}

void main() {
  testWidgets(
    'divider.ocean-wave is a 24px static mint wave without semantics',
    (t) async {
      await t.pumpWidget(host(wave(animated: false)));
      await t.pump();
      expect(t.getSize(find.byType(IslandDivider)), const Size(300, 24));
      expect(ticking, 0);
      final image = await capture(t);
      for (final x in [0, 64, 150, 299]) {
        expect(rgb(image, x, 1), [255, 255, 255], reason: 'above the crest');
        final trough = rgb(image, x, 23);
        expect(trough, isNot([255, 255, 255]), reason: 'wave body at $x');
        expect(trough[1] > trough[0], isTrue, reason: 'mint tint at $x');
      }

      final h = t.ensureSemantics();
      try {
        await t.pumpWidget(
          host(const Column(children: [Text('Before'), Text('After')])),
        );
        final without = semanticsNodes(t);
        await t.pumpWidget(
          host(
            const Column(
              children: [
                Text('Before'),
                IslandDivider(variant: IslandDividerVariant.oceanWave),
                Text('After'),
              ],
            ),
          ),
        );
        expect(semanticsNodes(t), without);
      } finally {
        h.dispose();
      }
    },
  );

  testWidgets('ocean wave drifts only while animated and motion is enabled', (
    t,
  ) async {
    await t.pumpWidget(host(wave(animated: false)));
    await t.pump();
    final still = await capture(t);

    await t.pumpWidget(host(wave()));
    await t.pump();
    expect(ticking, greaterThan(0));
    await t.pump(const Duration(seconds: 1));
    final moved = await capture(t);
    expect(
      moved.buffer.asUint8List(),
      isNot(still.buffer.asUint8List()),
      reason: 'playing changes the phase',
    );

    await t.pumpWidget(host(wave(animated: false)));
    await t.pump();
    expect(ticking, 0);
    final paused = await capture(t);
    await t.pump(const Duration(seconds: 2));
    expect(
      (await capture(t)).buffer.asUint8List(),
      paused.buffer.asUint8List(),
      reason: 'pausing freezes the current wave',
    );
    expect(
      paused.buffer.asUint8List(),
      moved.buffer.asUint8List(),
      reason: 'pausing keeps the reached phase',
    );

    await t.pumpWidget(host(wave(), reduced: true));
    await t.pump();
    expect(ticking, 0);
    expect(
      (await capture(t)).buffer.asUint8List(),
      still.buffer.asUint8List(),
      reason: 'reduced motion settles the static phase',
    );

    await t.pumpWidget(host(wave(), ticking: false));
    await t.pump();
    expect(ticking, 0, reason: 'muted tickers stop the wave');

    await t.pumpWidget(const SizedBox());
    expect(ticking, 0);
    expect(t.takeException(), isNull);
  });

  testWidgets('ocean wave plays only while inside the scroll viewport', (
    t,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      host(
        SizedBox(
          height: 400,
          child: ListView(
            controller: controller,
            children: [
              const SizedBox(height: 1000),
              wave(),
              const SizedBox(height: 1000),
            ],
          ),
        ),
      ),
    );
    await t.pump();
    expect(ticking, 0, reason: 'below the viewport');

    controller.jumpTo(800);
    await t.pump();
    await t.pump();
    expect(ticking, greaterThan(0), reason: 'scrolled into view');

    controller.jumpTo(1600);
    await t.pump();
    await t.pump();
    expect(ticking, 0, reason: 'scrolled out of view');

    await t.pumpWidget(const SizedBox());
    expect(t.takeException(), isNull);
  });
}
