import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'counter_audit_test.dart' show pixel;
import 'palette_contrast_test.dart' show host, foreground, fill, readable;

void main() {
  testWidgets(
    'Select dark empty panel supplies readable nested public actions',
    (t) async {
      var calls = 0;
      await t.pumpWidget(
        host(
          IslandSelect<int>(
            options: const [],
            value: null,
            onChanged: (_) {},
            notFound: IslandButton(
              variant: IslandButtonVariant.link,
              onPressed: () => calls++,
              child: const Text('Retry'),
            ),
          ),
          brightness: Brightness.dark,
        ),
      );
      await t.tap(find.byType(IslandSelect<int>));
      await t.pumpAndSettle();
      expect(find.text('Retry'), findsOneWidget);
      expect(fill(t, find.text('Retry')), const Color(0xffffeea0));
      readable(foreground(t, 'Retry'), fill(t, find.text('Retry')));
      await t.tap(find.text('Retry'));
      await t.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Retry'), findsOneWidget);
    },
  );

  testWidgets(
    'Colored Card surfaces supply readable default transparent child actions',
    (t) async {
      for (final c in [
        IslandColorway.brown,
        ...IslandColorway.values.where((x) => x != IslandColorway.brown),
      ]) {
        for (final brightness in Brightness.values) {
          await t.pumpWidget(
            host(
              IslandCard(
                colorway: c,
                child: IslandButton(
                  variant: IslandButtonVariant.link,
                  onPressed: () {},
                  child: const Text('Nested action'),
                ),
              ),
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
          readable(
            foreground(t, 'Nested action'),
            fill(t, find.text('Nested action')),
            reason: 'Card $c $brightness transparent default child',
          );
        }
      }
    },
  );

  testWidgets(
    'Filled Tag surfaces supply readable default transparent child actions',
    (t) async {
      for (final c in IslandColorway.values) {
        for (final variant in [IslandTagVariant.soft, IslandTagVariant.solid]) {
          for (final brightness in Brightness.values) {
            await t.pumpWidget(
              host(
                IslandTag(
                  colorway: c,
                  variant: variant,
                  child: IslandButton(
                    variant: IslandButtonVariant.link,
                    onPressed: () {},
                    child: const Text('Nested action'),
                  ),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            readable(
              foreground(t, 'Nested action'),
              fill(t, find.text('Nested action')),
              reason: 'Tag $c $variant $brightness transparent default child',
            );
          }
        }
      }
    },
  );

  testWidgets(
    'Title surfaces supply readable default transparent child actions',
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
                  child: IslandButton(
                    variant: IslandButtonVariant.link,
                    onPressed: () {},
                    child: const Text('Nested action'),
                  ),
                ),
              ),
              brightness: Brightness.dark,
            ),
          );
          await t.pumpAndSettle();
          final label = t.getRect(find.text('Nested action'));
          final background = await pixel(
            t,
            boundary,
            Offset(label.center.dx, label.top - 2),
          );
          readable(
            foreground(t, 'Nested action'),
            background,
            reason: 'Title $palette $variant transparent default child',
          );
        }
      }
    },
  );

  testWidgets('Required SVG menu stroke remains readable on dark paper', (
    t,
  ) async {
    final boundary = GlobalKey();
    await t.pumpWidget(
      host(
        RepaintBoundary(
          key: boundary,
          child: Container(
            decoration: BoxDecoration(color: IslandTokens.dark.paper),
            child: const IslandIcon(
              IslandGlyph.menu,
              size: 48,
              semanticLabel: 'Menu',
            ),
          ),
        ),
        brightness: Brightness.dark,
      ),
    );
    await t.pumpAndSettle();
    final top = t.getTopLeft(find.byType(IslandIcon));
    final stroke = await pixel(t, boundary, top + const Offset(24, 15));
    readable(
      stroke,
      IslandTokens.dark.paper,
      minimum: 3,
      reason:
          'Menu actual un-antialiased necessary stroke, not IconTheme metadata',
    );
  });
  registerMeasuredColorOracles();
}

// Reference values measured on their actual composited backgrounds
// (docs/DESIGN.md#measured-color-differences). Thresholds are the global
// budgets: text 4.5:1, necessary graphics 3:1.
const _lightPapers = [
  Color(0xffffffff),
  Color(0xfff8f8f0),
  Color(0xfffffdf7),
  Color(0xfff7f3df),
];
const _darkPapers = [Color(0xff243c33), Color(0xff172b26)];

Color _borderOf(WidgetTester t, Finder of) {
  for (final e
      in find
          .descendant(of: of, matching: find.byType(DecoratedBox))
          .evaluate()) {
    final d = (e.widget as DecoratedBox).decoration;
    if (d is ShapeDecoration && d.shape is StadiumBorder) {
      final side = (d.shape as StadiumBorder).side;
      if (side != BorderSide.none) return side.color;
    }
  }
  final dashed = t
      .widgetList<CustomPaint>(
        find.descendant(of: of, matching: find.byType(CustomPaint)),
      )
      .map((p) => p.foregroundPainter)
      .whereType<IslandDashedBorderPainter>();
  return dashed.first.color;
}

void registerMeasuredColorOracles() {
  testWidgets(
    'transparent Tags keep a distinct readable hue per colorway in both themes',
    (t) async {
      for (final brightness in Brightness.values) {
        final papers = brightness == Brightness.light
            ? _lightPapers
            : _darkPapers;
        final inks = <Color>{};
        for (final c in IslandColorway.values) {
          for (final variant in [
            IslandTagVariant.outlined,
            IslandTagVariant.dashed,
          ]) {
            await t.pumpWidget(
              host(
                IslandTag(
                  colorway: c,
                  variant: variant,
                  onClose: () {},
                  child: const Text('Tag'),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            final ink = foreground(t, 'Tag');
            inks.add(ink);
            for (final paper in papers) {
              readable(ink, paper, reason: '$brightness $c $variant on $paper');
              // Resting close glyph over its 8% disc on the same paper.
              readable(
                foreground(t, '×'),
                Color.alphaBlend(const Color(0x14958f8f), paper),
                minimum: 3,
                reason: '$brightness $c $variant close',
              );
            }
            // Decorative reference contour: the accent (neutral #c4b89e).
            expect(
              _borderOf(t, find.byType(IslandTag)),
              c == IslandColorway.neutral ? const Color(0xffc4b89e) : c.accent,
            );
          }
          // Light Cards keep their known light paper inside dark hosts.
          await t.pumpWidget(
            host(
              IslandCard(
                child: IslandTag(
                  colorway: c,
                  variant: IslandTagVariant.outlined,
                  child: const Text('Tag'),
                ),
              ),
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
          readable(foreground(t, 'Tag'), fill(t, find.text('Tag')));
        }
        expect(inks, hasLength(IslandColorway.values.length));
      }
      // Hues whose reference already passes are kept unchanged.
      await t.pumpWidget(
        host(
          const IslandTag(
            colorway: IslandColorway.pink,
            variant: IslandTagVariant.outlined,
            child: Text('Tag'),
          ),
          brightness: Brightness.dark,
        ),
      );
      await t.pumpAndSettle();
      expect(foreground(t, 'Tag'), const Color(0xfff8a6b2));
    },
  );

  testWidgets('solid Tag borders equal their reference fill', (t) async {
    for (final c in IslandColorway.values) {
      await t.pumpWidget(
        host(
          IslandTag(
            colorway: c,
            variant: IslandTagVariant.solid,
            child: const Text('Tag'),
          ),
        ),
      );
      expect(
        _borderOf(t, find.byType(IslandTag)),
        c == IslandColorway.neutral ? const Color(0xffd4c4a8) : c.accent,
      );
    }
  });

  testWidgets(
    'Badge dot is a same-hue 3:1 graphic with the reference cream ring',
    (t) async {
      BoxDecoration dot() => t
          .widgetList<Container>(
            find.descendant(
              of: find.byType(IslandBadge),
              matching: find.byType(Container),
            ),
          )
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.borderRadius != null);
      final fills = <Color>{};
      for (final c in IslandColorway.values) {
        for (final attached in [false, true]) {
          await t.pumpWidget(
            host(
              IslandBadge(
                dot: true,
                color: c,
                child: attached ? const Text('消息') : null,
              ),
            ),
          );
          final d = dot();
          final ring = (d.border! as Border).top.color;
          fills.add(d.color!);
          expect(ring, attached ? const Color(0xfff8f8f0) : Colors.transparent);
          for (final bg in [
            const Color(0xfff8f8f0),
            ..._lightPapers,
            ..._darkPapers,
          ]) {
            readable(d.color!, bg, minimum: 3, reason: '$c dot on $bg');
          }
        }
      }
      expect(fills, hasLength(IslandColorway.values.length));
    },
  );

  testWidgets('Progress fill edge is a same-hue 3:1 boundary on its track', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        const SizedBox(
          width: 300,
          child: IslandProgress(percent: 40, label: 'p'),
        ),
      ),
    );
    await t.pumpAndSettle();
    final edges = t
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(IslandProgress),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null && d.color == null)
        .map((d) => (d.border! as Border).top.color)
        .toList();
    expect(edges, [const Color(0xff039d91)]);
    readable(edges.single, const Color(0xfff8f8f0), minimum: 3);
  });

  testWidgets('Avatar fallback icons use the reference #2A2A2A icon ink', (
    t,
  ) async {
    await t.pumpWidget(host(const IslandAvatar()));
    final icon = find.descendant(
      of: find.byType(IslandAvatar),
      matching: find.byType(IslandIcon),
    );
    final color = IconTheme.of(t.element(icon)).color!;
    expect(color, const Color(0xff2a2a2a));
    readable(color, const Color(0xffe6f9f6), minimum: 3);
  });

  testWidgets(
    'Checkbox restores reference fill and label pair; every frame stays readable',
    (t) async {
      var value = false;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandCheckbox(
                label: 'Choice',
                value: value,
                onChanged: (v) => set(() => value = v),
              );
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(foreground(t, 'Choice'), const Color(0xff725d42));
      update(() => value = true);
      for (final ms in [0, 16, 75, 150]) {
        await t.pump(Duration(milliseconds: ms));
        for (final paper in _lightPapers) {
          readable(foreground(t, 'Choice'), paper, reason: 'frame $ms');
        }
      }
      await t.pumpAndSettle();
      expect(foreground(t, 'Choice'), const Color(0xff794f27));
      // Customized and dark palettes keep their own ink.
      await t.pumpWidget(
        host(
          IslandCheckbox(label: 'Choice', value: false, onChanged: (_) {}),
          brightness: Brightness.dark,
        ),
      );
      await t.pumpAndSettle();
      expect(foreground(t, 'Choice'), IslandTokens.dark.ink);
    },
  );

  testWidgets('Rate selected stroke keeps 3:1 on its paper in both themes', (
    t,
  ) async {
    for (final brightness in Brightness.values) {
      await t.pumpWidget(
        host(const IslandRate(initialValue: 3), brightness: brightness),
      );
      await t.pumpAndSettle();
      final outlines = t
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(IslandRate),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((p) => p.painter)
          .where((p) => p.runtimeType.toString() == '_StarPainter')
          .map((p) => (p as dynamic).outline as Color)
          .toList();
      final selected = brightness == Brightness.light
          ? const Color(0xffaf8600)
          : const Color(0xffdba90e);
      expect(outlines.take(3), everyElement(selected));
      for (final paper
          in brightness == Brightness.light ? _lightPapers : _darkPapers) {
        readable(selected, paper, minimum: 3);
      }
    }
  });

  testWidgets(
    'Switch rest boundary is 3:1 and busy keeps in-track text opaque and readable',
    (t) async {
      for (final brightness in Brightness.values) {
        await t.pumpWidget(
          host(
            IslandSwitch(
              label: 'S',
              value: false,
              showLabel: false,
              onChanged: (_) {},
            ),
            brightness: brightness,
          ),
        );
        await t.pumpAndSettle();
        for (final paper
            in brightness == Brightness.light ? _lightPapers : _darkPapers) {
          readable(const Color(0xff978b73), paper, minimum: 3);
        }
        await t.pumpWidget(
          host(
            IslandSwitch(
              label: 'S',
              value: true,
              busy: true,
              checkedLabel: '开',
              showLabel: false,
              onChanged: (_) {},
            ),
            brightness: brightness,
          ),
        );
        await t.pump();
        final dims = t
            .widgetList<Opacity>(
              find.ancestor(of: find.text('开'), matching: find.byType(Opacity)),
            )
            .map((o) => o.opacity);
        expect(dims, everyElement(1.0));
        // Busy track: reference fill at .7 over the owned #f8f8f0 base.
        final busyFill = Color.alphaBlend(
          const Color(0xff86d67a).withValues(alpha: .7),
          const Color(0xfff8f8f0),
        );
        readable(foreground(t, '开'), busyFill);
      }
    },
  );

  testWidgets('disabled field text uses the reference #c4b89e', (t) async {
    final disabledText = TextEditingController(text: 'Value');
    addTearDown(disabledText.dispose);
    await t.pumpWidget(
      host(
        SizedBox(
          width: 240,
          child: IslandTextField(
            label: 'Field',
            controller: disabledText,
            enabled: false,
          ),
        ),
      ),
    );
    expect(
      t.widget<EditableText>(find.byType(EditableText)).style.color,
      const Color(0xffc4b89e),
    );
    await t.pumpWidget(
      host(
        IslandTimePicker(
          value: const IslandTimeValue(9, 30),
          disabled: true,
          onChanged: (_) {},
        ),
      ),
    );
    expect(foreground(t, '09:30:00'), const Color(0xffc4b89e));
  });
}
