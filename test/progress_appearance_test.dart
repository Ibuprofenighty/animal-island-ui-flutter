import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  theme: IslandTheme.create(),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
      child: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  ),
);

final boundary = GlobalKey();

Widget bar(
  double percent, {
  Color? color,
  bool wave = false,
  bool animated = true,
  IslandScene? scene,
}) => RepaintBoundary(
  key: boundary,
  child: SizedBox(
    width: 300,
    child: IslandProgress(
      percent: percent,
      label: 'p',
      color: color,
      wave: wave,
      animated: animated,
      scene: scene,
      showInfo: false,
      duration: Duration.zero,
    ),
  ),
);

int get ticking => SchedulerBinding.instance.transientCallbackCount;

Future<List<int>> pixel(WidgetTester t, int x, int y) async =>
    (await t.runAsync(() async {
      final render =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await render.toImage(pixelRatio: 1);
      final ByteData data = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      final p = (y * image.width + x) * 4;
      return [data.getUint8(p), data.getUint8(p + 1), data.getUint8(p + 2)];
    }))!;

void main() {
  const peach = Color(0xffe59266);

  testWidgets('custom colour fills under the sheen and stays at 100%', (
    t,
  ) async {
    await t.pumpWidget(host(bar(45, color: peach)));
    await t.pump();
    // Middle of the fill height, inside the 2px track border.
    final partial = await pixel(t, 60, 12);
    for (final (channel, value) in [(0, 0xe5), (1, 0x92), (2, 0x66)]) {
      expect(partial[channel], closeTo(value, 12), reason: 'channel $channel');
    }
    await t.pumpWidget(host(bar(100, color: peach)));
    await t.pump();
    expect(await pixel(t, 60, 12), partial, reason: 'no mint completion');

    await t.pumpWidget(host(bar(45)));
    await t.pump();
    final mint = await pixel(t, 60, 12);
    expect(mint[1] > mint[0], isTrue, reason: 'default keeps the mint fill');
  });

  testWidgets('scene takes precedence over colour', (t) async {
    await t.pumpWidget(
      host(bar(45, color: peach, scene: IslandScene.forestGrove)),
    );
    await t.pump();
    expect(
      find.byWidgetPredicate((w) => w is ColoredBox && w.color == peach),
      findsNothing,
    );
  });

  testWidgets('wave plays strictly between 0% and 100% while animated', (
    t,
  ) async {
    for (final (percent, animated, reduced, expected) in [
      (45.0, true, false, true),
      (0.0, true, false, false),
      (100.0, true, false, false),
      (45.0, false, false, false),
      (45.0, true, true, false),
    ]) {
      await t.pumpWidget(
        host(bar(percent, wave: true, animated: animated), reduced: reduced),
      );
      await t.pump();
      expect(
        ticking > 0,
        expected,
        reason: 'percent $percent animated $animated reduced $reduced',
      );
    }
    await t.pumpWidget(host(bar(45)));
    await t.pump();
    expect(ticking, 0, reason: 'no wave by default');
    await t.pumpWidget(const SizedBox());
    expect(t.takeException(), isNull);
  });

  testWidgets('wave keeps a visible static shape inside the fill', (t) async {
    await t.pumpWidget(host(bar(80, animated: false)));
    await t.pump();
    final plain = await pixel(t, 60, 15);
    await t.pumpWidget(host(bar(80, wave: true, animated: false)));
    await t.pump();
    final waved = await pixel(t, 60, 15);
    expect(waved, isNot(plain));
    expect(waved[0] > plain[0], isTrue, reason: 'white foam lightens the fill');
  });

  testWidgets('track has no minimum width beside the info', (t) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 70,
          child: IslandProgress(percent: 50, label: 'narrow'),
        ),
      ),
    );
    await t.pump();
    expect(t.takeException(), isNull);
    expect(t.getSize(find.byType(IslandProgress)).width, 70);
  });

  testWidgets('progress.value still exposes name and clamped value', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          const SizedBox(
            width: 300,
            child: IslandProgress(
              percent: 150,
              label: 'Wave',
              wave: true,
              color: peach,
            ),
          ),
        ),
      );
      final node = t.getSemantics(find.byType(IslandProgress));
      expect(node.label, 'Wave');
      expect(node.value, '100%');
    } finally {
      h.dispose();
    }
  });
}
