import 'dart:ui' as ui;
import 'dart:convert';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'counter_audit_test.dart' show pixel;
import 'palette_contrast_test.dart' show host, foreground, fill;
import 'readable_motion_test.dart' show opaque;
import 'foundation_test.dart' show contrast;

Widget surface(String kind, int palette, Widget child) => switch (kind) {
  'card' => IslandCard(colorway: IslandColorway.values[palette], child: child),
  'pattern' => IslandCard(
    pattern: IslandColorway.values[palette],
    child: child,
  ),
  'soft' => IslandTag(colorway: IslandColorway.values[palette], child: child),
  'solid' => IslandTag(
    colorway: IslandColorway.values[palette],
    variant: IslandTagVariant.solid,
    child: child,
  ),
  _ => IslandTitle(
    palette: IslandPalette.values[palette],
    variant: IslandTitleVariant.values.firstWhere((v) => v.name == kind),
    child: child,
  ),
};

// The Button owns the first painted fill, including its translucent ghost hover.
// Compose that fill with the actual parent backplane rather than dropping alpha.
Color actionBacking(WidgetTester t, Color parent) {
  for (final e
      in find
          .ancestor(
            of: find.text('Nested action'),
            matching: find.byType(DecoratedBox),
          )
          .evaluate()) {
    final d = (e.widget as DecoratedBox).decoration;
    final c = switch (d) {
      BoxDecoration() => d.color,
      ShapeDecoration() => d.color,
      _ => null,
    };
    if (c != null) return Color.alphaBlend(c, parent);
  }
  return parent;
}

void main() {
  testWidgets(
    '1092 nested surface recipes preserve readable default hover pressed reverse and focus states',
    (t) async {
      var combinations = 0;
      final failures = <String>[];
      for (final kind in [
        'card',
        'pattern',
        'soft',
        'solid',
        'ribbon',
        'layer',
        'tab',
      ]) {
        for (var palette = 0; palette < 13; palette++) {
          for (final brightness in Brightness.values) {
            for (final recipe in ['link', 'text', 'ghost']) {
              for (final danger in [false, true]) {
                final boundary = GlobalKey(), focus = FocusNode();
                var calls = 0;
                await t.pumpWidget(
                  host(
                    RepaintBoundary(
                      key: boundary,
                      child: surface(
                        kind,
                        palette,
                        IslandButton(
                          variant: recipe == 'link'
                              ? IslandButtonVariant.link
                              : recipe == 'text'
                              ? IslandButtonVariant.text
                              : IslandButtonVariant.primary,
                          ghost: recipe == 'ghost',
                          danger: danger,
                          focusNode: focus,
                          onPressed: () => calls++,
                          child: const Text('Nested action'),
                        ),
                      ),
                    ),
                    brightness: brightness,
                  ),
                );
                await t.pumpAndSettle();
                final label = find.text('Nested action');
                late Color parent;
                if (['ribbon', 'layer', 'tab'].contains(kind)) {
                  final rect = t.getRect(label);
                  parent = await pixel(
                    t,
                    boundary,
                    Offset(rect.center.dx, rect.top - 2),
                  );
                } else {
                  parent = fill(t, label);
                }
                void check(String state) {
                  opaque(t, label);
                  final fg = foreground(t, 'Nested action');
                  final bg = actionBacking(t, parent);
                  final ratio = contrast(fg, bg);
                  if (ratio < 4.5)
                    failures.add(
                      '$kind palette=$palette $brightness $recipe danger=$danger $state ${fg.toARGB32().toRadixString(16)}/${bg.toARGB32().toRadixString(16)} = $ratio',
                    );
                }

                check('default');
                final mouse = await t.createGesture(
                  kind: ui.PointerDeviceKind.mouse,
                );
                await mouse.addPointer(location: Offset.zero);
                await mouse.moveTo(t.getCenter(label));
                for (final ms in [0, 60, 140]) {
                  await t.pump(Duration(milliseconds: ms));
                  check('hover +$ms');
                }
                await mouse.down(t.getCenter(label));
                await t.pump();
                check('pressed');
                await mouse.up();
                await mouse.moveTo(Offset.zero);
                await t.pump(const Duration(milliseconds: 60));
                check('reverse');
                await mouse.moveTo(t.getCenter(label));
                await t.pump();
                check('interrupted reverse');
                await mouse.removePointer();
                focus.requestFocus();
                await t.pump();
                check('keyboard focus');
                expect(focus.hasPrimaryFocus, isTrue);
                expect(calls, 1);
                await t.pumpWidget(const SizedBox());
                focus.dispose();
                combinations++;
              }
            }
          }
        }
      }
      expect(combinations, 1092);
      if (failures.isNotEmpty)
        debugPrint(jsonEncode(failures), wrapWidth: 200000);
      expect(failures, isEmpty);
    },
  );

  testWidgets(
    'paired semantic changes retain opaque child state explicit styles and borrowed focus',
    (t) async {
      for (final kind in ['card', 'pattern', 'soft', 'ribbon']) {
        var palette = 0, transparent = false;
        late StateSetter update;
        final edit = TextEditingController(text: 'retained'),
            focus = FocusNode();
        final key = GlobalKey();
        const extension = IslandButtonTheme(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(7)),
          ),
        );
        IslandButtonTheme? observed;
        await t.pumpWidget(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              final data =
                  IslandTheme.create(
                    brightness: palette.isEven
                        ? Brightness.dark
                        : Brightness.light,
                  ).copyWith(
                    extensions: [
                      palette.isEven ? IslandTokens.dark : IslandTokens.light,
                      extension,
                    ],
                  );
              Widget child = Builder(
                builder: (context) {
                  observed = Theme.of(context).extension<IslandButtonTheme>();
                  return SizedBox(
                    width: 180,
                    child: TextField(
                      key: key,
                      controller: edit,
                      focusNode: focus,
                      style: const TextStyle(color: Colors.purple),
                    ),
                  );
                },
              );
              child = kind == 'soft'
                  ? IslandTag(
                      colorway: IslandColorway.values[palette],
                      variant: transparent
                          ? IslandTagVariant.outlined
                          : IslandTagVariant.soft,
                      child: child,
                    )
                  : surface(kind, palette, child);
              return MaterialApp(
                theme: data,
                home: Scaffold(
                  body: IslandThemeHost(
                    data: data,
                    child: Center(child: child),
                  ),
                ),
              );
            },
          ),
        );
        await t.pumpAndSettle();
        final identity = t.state(find.byType(EditableText));
        focus.requestFocus();
        await t.pump();
        for (final index in [11, 3, 0, 8]) {
          update(() {
            palette = index;
            transparent = !transparent;
          });
          for (final ms in [0, 16, 100, 200]) {
            await t.pump(Duration(milliseconds: ms));
            expect(t.state(find.byType(EditableText)), same(identity));
            expect(focus.hasPrimaryFocus, isTrue);
            expect(edit.text, 'retained');
            expect(
              t.widget<EditableText>(find.byType(EditableText)).style.color,
              Colors.purple,
            );
            expect(observed, same(extension));
          }
        }
        await t.pumpWidget(const SizedBox());
        edit.dispose();
        focus.dispose();
        expect(t.takeException(), isNull);
      }
    },
  );
}
