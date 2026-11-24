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

  testWidgets(
    'the fill highlight is the reference inset 0 2px 0 shadow following the '
    'pill ends',
    (t) async {
      await t.pumpWidget(host(bar(45, color: peach)));
      await t.pump();
      // Track border 2px: the 20px fill (radius 10) starts at (2, 2). One
      // fill row below the 2px band (local y 3) is plain fill mid-bar, but on
      // the rounded left end it is still inside the pill and outside the pill
      // moved 2px down (local x 2.4-4.7), so the inset shadow lights it.
      final band = await pixel(t, 60, 2);
      final below = await pixel(t, 60, 5);
      final end = await pixel(t, 5, 5);
      for (var channel = 0; channel < 3; channel++) {
        expect(band[channel], greaterThan(below[channel]), reason: 'band');
        expect(
          end[channel],
          greaterThan(below[channel]),
          reason: 'rounded end',
        );
      }
    },
  );

  testWidgets(
    'on the default fill the highlight shows inside the 2px same-hue edge',
    (t) async {
      await t.pumpWidget(host(bar(45)));
      await t.pump();
      // Mid-bar column of the 24px bar: track border rows 0-1, the 20px fill
      // from row 2. The registered #039d91 edge keeps fill rows 0-1 (y 2-3);
      // the reference inset highlight (white .45 over #3dd4c6, #93e7df in the
      // reference capture) follows on fill rows 2-3 (y 4-5), as a CSS inset
      // shadow sits inside a border; the gradient continues below.
      for (final y in [2, 3]) {
        expect(await pixel(t, 60, y), [0x03, 0x9d, 0x91], reason: 'edge $y');
      }
      for (final y in [4, 5]) {
        final highlight = await pixel(t, 60, y);
        for (final (channel, value) in [(0, 0x93), (1, 0xe7), (2, 0xdf)]) {
          expect(
            highlight[channel],
            closeTo(value, 4),
            reason: 'highlight $y channel $channel',
          );
        }
      }
      final fill = await pixel(t, 60, 6);
      expect(fill[0], lessThan(0x60), reason: 'gradient below the highlight');
      // The edge still bounds the fill against the track at the far end.
      expect(await pixel(t, (2 + 296 * .45 - 1).floor(), 12), [
        0x03,
        0x9d,
        0x91,
      ]);
    },
  );

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

  testWidgets('track boundary is the reference hue deepened to 3:1', (t) async {
    // Reference @track-border #e2d6bd (1.3:1 on the #f8f8f0 track) moves
    // along OKLCH lightness to #9a8e77.
    await t.pumpWidget(host(bar(0)));
    await t.pump();
    expect(await pixel(t, 150, 1), [0x9a, 0x8e, 0x77]);
  });

  testWidgets('percentage takes the reference #725d42 on light papers', (
    t,
  ) async {
    Color ink() => t
        .widget<RichText>(
          find.descendant(
            of: find.byType(IslandProgress),
            matching: find.byType(RichText),
          ),
        )
        .text
        .style!
        .color!;
    const progress = SizedBox(
      width: 300,
      child: IslandProgress(percent: 40, label: 'p'),
    );
    await t.pumpWidget(host(progress));
    expect(ink(), const Color(0xff725d42));
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(brightness: Brightness.dark),
        home: const Scaffold(body: progress),
      ),
    );
    await t.pumpAndSettle();
    expect(ink(), IslandTokens.dark.ink, reason: 'dark keeps its ink role');
  });
}
