import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final radio in [false, true]) {
    testWidgets(
      '${radio ? 'Radio' : 'Checkbox'} keeps complete committed check during transient splash',
      (t) async {
        final boundary = GlobalKey();
        var checked = false;
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            home: Scaffold(
              body: RepaintBoundary(
                key: boundary,
                child: SizedBox(
                  width: 200,
                  height: 100,
                  child: ColoredBox(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: StatefulBuilder(
                        builder: (_, set) {
                          final options = [
                            const IslandOption(value: 1, label: 'Choice'),
                          ];
                          return radio
                              ? IslandRadioGroup(
                                  options: options,
                                  value: checked ? 1 : null,
                                  onChanged: (_) => set(() => checked = true),
                                )
                              : IslandCheckboxGroup(
                                  options: options,
                                  values: checked ? {1} : <int>{},
                                  onChanged: (v) =>
                                      set(() => checked = v.isNotEmpty),
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        Future<(int, int)> pixels() async => (await t.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage(pixelRatio: 1);
          final bytes = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          var mark = 0, splash = 0;
          for (var y = 0; y < 100; y++) {
            for (var x = 0; x < 68; x++) {
              final i = (y * image.width + x) * 4;
              final r = bytes.getUint8(i),
                  g = bytes.getUint8(i + 1),
                  b = bytes.getUint8(i + 2);
              if (x >= 45 &&
                  x < 58 &&
                  y >= 44 &&
                  y < 57 &&
                  // Reference white mark (registered exception in DESIGN).
                  r == 0xff &&
                  g == 0xff &&
                  b == 0xff)
                mark++;
              if ((x < 38 || y < 38 || y > 64) &&
                  g > 40 &&
                  g > r * 2 &&
                  b > r * 2)
                splash++;
            }
          }
          image.dispose();
          return (mark, splash);
        }))!;
        expect((await pixels()).$1, 0);
        await t.tap(find.text('Choice'));
        await t.pump();
        final initialMark = (await pixels()).$1;
        expect(initialMark, inInclusiveRange(10, 80));
        await t.pump(const Duration(milliseconds: 199));
        expect((await pixels()).$1, initialMark);
        await t.pump(const Duration(milliseconds: 41));
        await t.pump();
        expect((await pixels()).$2, greaterThan(0));
        await t.pump(const Duration(milliseconds: 300));
        final mark = (await pixels()).$1;
        expect(mark, inInclusiveRange(10, 80));
        await t.pump(const Duration(milliseconds: 60));
        expect((await pixels()).$2, 0);
        final paragraph = t.renderObject<RenderParagraph>(find.text('Choice'));
        final style = (paragraph.text as TextSpan).style!;
        expect(style.fontWeight, FontWeight.w500);
        expect(style.letterSpacing, .14);
        expect(style.height, 1.5);
        await t.pumpWidget(const SizedBox());
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'rejected proposals do not draw checks; decorative timeline is cancelled on disposal',
    (t) async {
      var requests = 0;
      late StateSetter update;
      var checked = false;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                update = set;
                return IslandCheckboxGroup(
                  options: [const IslandOption(value: 1, label: 'Choice')],
                  values: checked ? {1} : <int>{},
                  onChanged: (_) => requests++,
                );
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Choice'));
      await t.pump(const Duration(milliseconds: 600));
      expect(requests, 1);
      expect(t.hasRunningAnimations, isFalse);
      update(() => checked = true);
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 600));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('choice border eases over the reference 250ms on commit', (
    t,
  ) async {
    var value = 'a';
    late StateSetter update;
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandRadioGroup<String>(
                options: const [
                  IslandOption(value: 'a', label: 'A'),
                  IslandOption(value: 'b', label: 'B'),
                ],
                value: value,
                onChanged: (_) {},
              );
            },
          ),
        ),
      ),
    );
    Color border() {
      final box = t.widget<DecoratedBox>(
        find
            .descendant(
              of: find
                  .ancestor(of: find.text('B'), matching: find.byType(Row))
                  .first,
              matching: find.byWidgetPredicate(
                (w) => w is DecoratedBox && w.decoration is BoxDecoration,
              ),
            )
            .first,
      );
      return ((box.decoration as BoxDecoration).border! as Border).top.color;
    }

    // Reference #c4b89e / #50b9ab rings, deepened in hue to 3:1.
    const unchecked = Color(0xff978b73), checked = Color(0xff259689);
    expect(border(), unchecked);
    update(() => value = 'b');
    await t.pump();
    await t.pump(const Duration(milliseconds: 125));
    expect(border(), isNot(unchecked));
    expect(border(), isNot(checked));
    await t.pumpAndSettle();
    expect(border(), checked);
  });
}
