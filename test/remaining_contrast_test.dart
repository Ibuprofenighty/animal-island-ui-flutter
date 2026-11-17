import 'dart:ui' show PointerDeviceKind;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      // Unselected: reference #c4b89e on dark paper, #978b73 on light.
      final idle = brightness == Brightness.light
          ? const Color(0xff978b73)
          : const Color(0xffc4b89e);
      expect(outlines.skip(3), everyElement(idle));
      for (final paper
          in brightness == Brightness.light ? _lightPapers : _darkPapers) {
        readable(selected, paper, minimum: 3);
        readable(idle, paper, minimum: 3);
      }
    }
  });

  testWidgets('Rate eyes are faint reference dots, not solid dark dots', (
    t,
  ) async {
    final boundary = GlobalKey();
    await t.pumpWidget(
      host(
        RepaintBoundary(
          key: boundary,
          child: const IslandRate(initialValue: 1, count: 1),
        ),
      ),
    );
    await t.pumpAndSettle();
    // 26px middle star on a 48-unit grid: left eye centre at (20, 22).
    final origin = t.getTopLeft(find.byType(IslandRate));
    final eye = await pixel(
      t,
      boundary,
      origin + const Offset(20 * 26 / 48, 22 * 26 / 48),
    );
    // The #dba90e stroke covers the #794f27 fill, as in the reference SVG.
    expect(eye.r * 255, closeTo(0xdb, 12));
    expect(eye.g * 255, closeTo(0xa9, 12));
    expect(eye.b * 255, closeTo(0x0e, 16));
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

  registerUpgradeColorOracles();
}

// Colours introduced by the reference 4.0.0 upgrade, measured under the same
// rule (docs/DESIGN.md#measured-color-differences).
const _capsule = Color(0xfffffbe7);
const _calendarPanel = Color(0xfffffdf7);
const _calendarCellHover = Color(0xfff4f0e4);
const _calendarSelectedCell = Color(0xffe6f9f6);
const _calendarAccent = Color(0xff19c8b9);
final _calendarDot = Color.alphaBlend(const Color(0x26c4b89e), _calendarPanel);
final _calendarCells = [
  _calendarPanel,
  _calendarDot,
  _calendarCellHover,
  _calendarSelectedCell,
];

Color _paragraphInk(WidgetTester t, Finder text) =>
    (t.renderObject<RenderParagraph>(text).text as TextSpan).style!.color!;

void registerUpgradeColorOracles() {
  DateTime june8() => DateTime(2026, 6, 8, 9, 30);

  testWidgets('Time clock ink is 4.5:1 on its card, capsule and host papers', (
    t,
  ) async {
    await t.pumpWidget(host(IslandTime(now: june8)));
    final card = foreground(t, '09');
    expect(card, const Color(0xff836b4e));
    readable(card, fill(t, find.text('09')));
    for (final brightness in Brightness.values) {
      await t.pumpWidget(
        host(
          IslandTime(now: june8, variant: IslandTimeVariant.game),
          brightness: brightness,
        ),
      );
      // Let the app theme finish its brightness transition.
      await t.pump(const Duration(milliseconds: 300));
      final hud = foreground(t, '09');
      expect(foreground(t, 'Jun 8'), hud);
      expect(
        hud,
        brightness == Brightness.light ? card : const Color(0xffb59c7c),
      );
      for (final paper
          in brightness == Brightness.light ? _lightPapers : _darkPapers) {
        readable(hud, paper, reason: 'game HUD on $paper');
      }
      expect(fill(t, find.text('Monday')), _capsule);
      expect(foreground(t, 'Monday'), card);
      readable(foreground(t, 'Monday'), _capsule);
    }
    await t.pumpWidget(const SizedBox());
  });

  test('Countdown default reminders are 4.5:1 on every number surface', () {
    // Plate gradient tops (default, island), shared bottom, island surface.
    const surfaces = [
      Color(0xffffffff),
      Color(0xfffffdf4),
      Color(0xfff8f8f0),
      Color(0xfff7f3df),
    ];
    expect(IslandCountdownReminder.defaults.map((r) => r.color), const [
      Color(0xffa55d05),
      Color(0xffc44043),
    ]);
    for (final reminder in IslandCountdownReminder.defaults) {
      for (final surface in surfaces) {
        readable(reminder.color, surface, reason: '${reminder.threshold}');
      }
    }
  });

  testWidgets('Upload background and card progress cues meet the budgets', (
    t,
  ) async {
    Widget upload(
      IslandUploadProgress progress, {
      IslandUploadListType listType = IslandUploadListType.text,
    }) => IslandUpload.uncontrolled(
      key: UniqueKey(),
      pickFiles: ({required multiple, required accept}) async => const [],
      request: (_) async => null,
      listType: listType,
      progress: progress,
      initialFiles: const [
        IslandUploadFile(
          id: 'a',
          name: 'a.png',
          size: 2048,
          status: IslandUploadStatus.uploading,
          percent: 46,
        ),
      ],
    );
    List<Color> edges() => t
        .widgetList<DecoratedBox>(
          find.descendant(
            of: find.byType(IslandUpload),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((b) => b.decoration)
        .whereType<BoxDecoration>()
        .map((d) => d.border)
        .whereType<BorderDirectional>()
        .map((b) => b.end.color)
        .toList();
    const row = Color(0xfffffdf7), rowHover = Color(0xffe6f9f6);
    Color filled(Color under) =>
        Color.alphaBlend(_calendarAccent.withValues(alpha: .28), under);
    // Size text over the .28 fill, at rest and hovered.
    await t.pumpWidget(
      host(
        SizedBox(
          width: 600,
          child: upload(
            const IslandUploadProgress(
              type: IslandUploadProgressType.background,
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    for (final under in [row, rowHover]) {
      readable(foreground(t, '2.0 KB'), filled(under));
      readable(foreground(t, '46%'), filled(under));
    }
    expect(edges(), isEmpty, reason: 'the percentage already states it');
    // Without the percentage the fill is the only cue: a 3:1 end edge.
    await t.pumpWidget(
      host(
        SizedBox(
          width: 600,
          child: upload(
            const IslandUploadProgress(
              type: IslandUploadProgressType.background,
              showInfo: false,
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final edge = edges().single;
    // Unfilled row, its hover tint, and the card mask over a black pixel.
    final cardMask = Color.alphaBlend(
      const Color(0xe0fffdf7),
      const Color(0xff000000),
    );
    for (final under in [row, rowHover, cardMask]) {
      readable(edge, under, minimum: 3, reason: 'edge on $under');
    }
    await t.pumpWidget(
      host(
        upload(
          const IslandUploadProgress(
            type: IslandUploadProgressType.background,
            showInfo: false,
          ),
          listType: IslandUploadListType.pictureCard,
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(edges(), [edge]);
    // A caller colour owns its own contrast: no library edge.
    await t.pumpWidget(
      host(
        SizedBox(
          width: 600,
          child: upload(
            const IslandUploadProgress(
              type: IslandUploadProgressType.background,
              color: Color(0xff7aa0e0),
              showInfo: false,
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(edges(), isEmpty);
    // Bar mode on a card: reference white percentage on the dark overlay,
    // 4.5:1 even over a white thumbnail pixel.
    await t.pumpWidget(
      host(
        upload(
          const IslandUploadProgress(),
          listType: IslandUploadListType.pictureCard,
        ),
      ),
    );
    await t.pumpAndSettle();
    final overlay = t
        .widget<ColoredBox>(
          find
              .ancestor(of: find.text('46%'), matching: find.byType(ColoredBox))
              .first,
        )
        .color;
    expect(foreground(t, '46%'), const Color(0xffffffff));
    for (final pixel in [const Color(0xffffffff), const Color(0xff000000)]) {
      readable(foreground(t, '46%'), Color.alphaBlend(overlay, pixel));
    }
  });

  testWidgets(
    'Calendar panel and header inks meet the budgets in both themes',
    (t) async {
      t.view.physicalSize = const Size(900, 2400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final events = [
        for (final (i, color) in IslandCalendarColor.values.indexed)
          IslandCalendarEvent(
            id: color,
            title: color.name,
            start: DateTime(2026, 11, 2 + i, 8 + i),
            color: color,
            showTime: true,
          ),
        for (final title in ['x', 'y', 'z'])
          IslandCalendarEvent(
            id: title,
            title: title,
            start: DateTime(2026, 11, 25),
          ),
      ];
      for (final brightness in Brightness.values) {
        await t.pumpWidget(
          host(
            SizedBox(
              width: 750,
              child: IslandCalendar(
                value: DateTime(2026, 11, 20),
                onChanged: (_) {},
                now: () => DateTime(2026, 11, 17, 9),
                events: events,
              ),
            ),
            brightness: brightness,
          ),
        );
        await t.pumpAndSettle();
        // Fixed light panel in every theme.
        for (final cell in _calendarCells) {
          readable(foreground(t, '日'), cell, reason: 'weekday on $cell');
          // November 2026 starts on Sunday: the trailing 12 is December's.
          readable(
            _paragraphInk(t, find.text('12').last),
            cell,
            reason: 'neighbouring month',
          );
          readable(foreground(t, '17'), cell, reason: 'today on $cell');
        }
        final todayRing =
            t
                    .widgetList<AnimatedContainer>(
                      find.ancestor(
                        of: find.text('17'),
                        matching: find.byType(AnimatedContainer),
                      ),
                    )
                    .map((c) => c.decoration)
                    .whereType<BoxDecoration>()
                    .firstWhere((d) => d.shape == BoxShape.circle)
                    .border!
                as Border;
        for (final cell in _calendarCells) {
          readable(todayRing.top.color, cell, minimum: 3);
        }
        // The selected disc keeps the reference accent; its digit is onLeaf.
        readable(foreground(t, '20'), _calendarAccent);
        for (final cell in _calendarCells) {
          readable(
            foreground(t, '+1'),
            Color.alphaBlend(const Color(0x2419c8b9), cell),
            reason: '+N on $cell',
          );
        }
        for (final (i, color) in IslandCalendarColor.values.indexed) {
          final bar = fill(t, find.text(color.name));
          readable(foreground(t, color.name), bar, reason: '$color title');
          readable(
            foreground(t, '${8 + i}:00'.padLeft(5, '0')),
            bar,
            reason: '$color time',
          );
        }
        // Header on the host paper, at rest and hovered.
        final papers = brightness == Brightness.light
            ? _lightPapers
            : _darkPapers;
        List<Color> arrows() => t
            .widgetList<IslandIcon>(
              find.byWidgetPredicate(
                (w) =>
                    w is IslandIcon &&
                    (w.glyph == IslandGlyph.chevronLeft ||
                        w.glyph == IslandGlyph.chevronRight),
              ),
            )
            .map((i) => i.color!)
            .toList();
        for (final paper in papers) {
          for (final arrow in arrows()) {
            readable(arrow, paper, minimum: 3, reason: 'arrow on $paper');
          }
          readable(foreground(t, '今天'), paper, reason: '今天 on $paper');
        }
        final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(t.getCenter(find.text('今天')));
        await t.pumpAndSettle();
        for (final paper in papers) {
          readable(
            foreground(t, '今天'),
            Color.alphaBlend(const Color(0x1a725d42), paper),
            reason: 'hovered 今天 on $paper',
          );
        }
        await mouse.moveTo(
          t.getCenter(
            find
                .byWidgetPredicate(
                  (w) => w is IslandIcon && w.glyph == IslandGlyph.chevronRight,
                )
                .first,
          ),
        );
        await t.pumpAndSettle();
        expect(arrows().toSet(), hasLength(2), reason: 'one arrow hovered');
        for (final paper in papers) {
          for (final arrow in arrows()) {
            readable(
              arrow,
              Color.alphaBlend(const Color(0x1a725d42), paper),
              minimum: 3,
              reason: 'hovered arrow on $paper',
            );
          }
        }
        await mouse.removePointer();
      }
    },
  );
}
