import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;

Widget host(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: IslandTheme.create(brightness: brightness),
      home: Scaffold(
        backgroundColor: brightness == Brightness.light
            ? IslandTokens.light.paper
            : IslandTokens.dark.paper,
        body: Center(child: child),
      ),
    );
Color foreground(WidgetTester t, String text) =>
    (t.renderObject<RenderParagraph>(find.text(text)).text as TextSpan)
        .style!
        .color!;
Color fill(WidgetTester t, Finder descendant) {
  for (final e
      in find
          .ancestor(of: descendant, matching: find.byType(DecoratedBox))
          .evaluate()) {
    final d = (e.widget as DecoratedBox).decoration;
    final c = switch (d) {
      BoxDecoration() => d.color,
      ShapeDecoration() => d.color,
      _ => null,
    };
    if (c != null && c.a == 1) return c;
  }
  throw StateError('No owned opaque surface for $descendant');
}

void readable(
  Color fg,
  Color bg, {
  double minimum = 4.5,
  String? reason,
}) => expect(
  contrast(fg, bg),
  greaterThanOrEqualTo(minimum),
  reason:
      reason ??
      '${fg.toARGB32().toRadixString(16)} / ${bg.toARGB32().toRadixString(16)}',
);

void main() {
  test(
    'readable roles support actual brand and input surfaces in both modes',
    () {
      for (final t in [IslandTokens.light, IslandTokens.dark]) {
        for (final fg in [
          t.ink,
          t.muted,
          t.link,
          t.linkHover,
          t.linkPressed,
          t.dangerText,
          t.warning,
        ]) {
          for (final bg in [t.paper, t.inputSurface]) {
            readable(fg, bg);
          }
        }
        for (final bg in [t.leaf, t.leafHover, t.leafPressed]) {
          readable(t.onLeaf, bg);
        }
        for (final bg in [t.danger, t.dangerHover, t.dangerPressed]) {
          readable(t.onDanger, bg);
        }
        readable(t.onSun, t.sun);
        readable(t.outline, t.paper, minimum: 3);
        readable(t.focus, t.paper, minimum: 3);
      }
      final canvas = IslandTokens.light.canvas;
      final first = Color.alphaBlend(const Color(0x665aa069), canvas);
      final overlap = Color.alphaBlend(const Color(0x4d6eb47d), first);
      for (final bg in [
        canvas,
        first,
        overlap,
        const Color(0xffa2b0e7),
        const Color(0xffb7c6e5),
      ]) {
        readable(
          IslandTokens.light.onCanvas,
          bg,
          reason: 'Actual Gallery canvas/dot/wave/selection composite',
        );
      }
    },
  );
  testWidgets('all colorways use readable actual Tag Badge and Card surfaces', (
    t,
  ) async {
    for (final c in IslandColorway.values) {
      for (final variant in [IslandTagVariant.soft, IslandTagVariant.solid]) {
        await t.pumpWidget(
          host(
            IslandTag(colorway: c, variant: variant, child: const Text('Tag')),
          ),
        );
        await t.pumpAndSettle();
        readable(
          foreground(t, 'Tag'),
          fill(t, find.text('Tag')),
          reason: 'Tag ${c.name} ${variant.name}',
        );
      }
      await t.pumpWidget(host(IslandBadge(text: 'Badge', color: c)));
      await t.pumpAndSettle();
      readable(
        foreground(t, 'Badge'),
        fill(t, find.text('Badge')),
        reason: 'Badge ${c.name}',
      );
      await t.pumpWidget(
        host(IslandCard(colorway: c, child: const Text('Card'))),
      );
      await t.pumpAndSettle();
      readable(
        foreground(t, 'Card'),
        fill(t, find.text('Card')),
        reason: 'Card ${c.name}',
      );
    }
  });
  testWidgets(
    'changing Card and Tag palettes switches readable pairs atomically',
    (t) async {
      for (final card in [true, false]) {
        Widget sample(IslandColorway c) => card
            ? IslandCard(colorway: c, child: const Text('Pair'))
            : IslandTag(
                colorway: c,
                variant: IslandTagVariant.solid,
                child: const Text('Pair'),
              );
        await t.pumpWidget(host(sample(IslandColorway.brown)));
        await t.pumpAndSettle();
        for (final next in [
          IslandColorway.yellow,
          IslandColorway.brown,
          IslandColorway.purple,
        ]) {
          await t.pumpWidget(host(sample(next)));
          for (final ms in [0, 1, 50, 100, 150, 300]) {
            await t.pump(Duration(milliseconds: ms));
            readable(
              foreground(t, 'Pair'),
              fill(t, find.text('Pair')),
              reason: '${card ? 'Card' : 'Tag'} palette change $next frame $ms',
            );
          }
        }
      }
    },
  );
  testWidgets(
    'all Title palettes and variants keep actual default text readable',
    (t) async {
      final boundary = GlobalKey();
      for (final palette in IslandPalette.values) {
        for (final variant in IslandTitleVariant.values) {
          await t.pumpWidget(
            host(
              RepaintBoundary(
                key: boundary,
                child: IslandTitle(
                  palette: palette,
                  variant: variant,
                  child: const Text('Title'),
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          final paragraph = t.getRect(find.text('Title'));
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final point = render.globalToLocal(
            Offset(paragraph.center.dx, paragraph.top - 2),
          );
          final color = (await t.runAsync(() async {
            final image = await render.toImage();
            final bytes = (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!;
            final i = (point.dy.floor() * image.width + point.dx.floor()) * 4;
            final c = Color.fromARGB(
              bytes.getUint8(i + 3),
              bytes.getUint8(i),
              bytes.getUint8(i + 1),
              bytes.getUint8(i + 2),
            );
            image.dispose();
            return c;
          }))!;
          readable(
            foreground(t, 'Title'),
            color,
            reason: 'Title ${palette.name} ${variant.name}',
          );
        }
      }
    },
  );
  testWidgets(
    'actual Button states and reversal frames preserve contrast in both themes',
    (t) async {
      for (final brightness in Brightness.values) {
        final tokens = brightness == Brightness.light
            ? IslandTokens.light
            : IslandTokens.dark;
        for (final variant in IslandButtonVariant.values) {
          for (final danger in [false, true]) {
            await t.pumpWidget(
              host(
                IslandButton(
                  variant: variant,
                  danger: danger,
                  onPressed: () {},
                  child: const Text('Action'),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            final mouse = await t.createGesture(
              kind: ui.PointerDeviceKind.mouse,
            );
            await mouse.addPointer(location: Offset.zero);
            var isDown = false;
            for (final pressed in [false, true, false]) {
              if (pressed) {
                await mouse.down(t.getCenter(find.text('Action')));
              } else {
                if (isDown) await mouse.up();
                await mouse.moveTo(t.getCenter(find.text('Action')));
              }
              isDown = pressed;
              await t.pump();
              for (var frame = 0; frame < 6; frame++) {
                await t.pump(const Duration(milliseconds: 50));
                Color bg = tokens.paper;
                for (final e
                    in find
                        .descendant(
                          of: find.byType(IslandButton),
                          matching: find.byType(DecoratedBox),
                        )
                        .evaluate()) {
                  final d = (e.widget as DecoratedBox).decoration;
                  if (d is ShapeDecoration && d.color != null) {
                    bg = Color.alphaBlend(d.color!, tokens.paper);
                    break;
                  }
                }
                readable(
                  foreground(t, 'Action'),
                  bg,
                  reason:
                      'Button $brightness $variant danger=$danger pressed=$pressed frame=$frame',
                );
              }
            }
            await mouse.removePointer();
          }
        }
      }
    },
  );
  testWidgets(
    'transparent Tag uses its surface theme and respects opaque child overrides',
    (t) async {
      await t.pumpWidget(
        host(
          const IslandTag(
            variant: IslandTagVariant.outlined,
            child: Text('Tag'),
          ),
          brightness: Brightness.dark,
        ),
      );
      readable(foreground(t, 'Tag'), IslandTokens.dark.paper);
      await t.pumpWidget(
        host(
          const IslandCard(
            child: IslandTag(
              variant: IslandTagVariant.outlined,
              child: Text('Tag'),
            ),
          ),
          brightness: Brightness.dark,
        ),
      );
      await t.pumpAndSettle();
      readable(foreground(t, 'Tag'), fill(t, find.text('Tag')));
      await t.pumpWidget(
        host(
          const IslandTag(
            child: Text('Explicit', style: TextStyle(color: Colors.purple)),
          ),
        ),
      );
      expect(foreground(t, 'Explicit'), Colors.purple);
    },
  );
}
