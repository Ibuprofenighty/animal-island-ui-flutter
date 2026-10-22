import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show host, readable;
import 'counter_audit_test.dart' show pixel;

void main() {
  testWidgets(
    'all colorway Card focus strokes use their real owned fill in both hosts',
    (t) async {
      final semantics = t.ensureSemantics();
      for (final brightness in Brightness.values) {
        for (final color in IslandColorway.values) {
          for (final variant in IslandCardVariant.values) {
            final boundary = GlobalKey();
            var calls = 0;
            await t.pumpWidget(
              host(
                RepaintBoundary(
                  key: boundary,
                  child: SizedBox(
                    width: 260,
                    child: IslandCard(
                      colorway: color,
                      variant: variant,
                      onTap: () => calls++,
                      child: const Text('Focus pair'),
                    ),
                  ),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            await t.sendKeyEvent(LogicalKeyboardKey.tab);
            await t.pumpAndSettle();
            expect(
              t
                  .getSemantics(find.byType(IslandCard))
                  .getSemanticsData()
                  .flagsCollection
                  .isFocused,
              ui.Tristate.isTrue,
            );
            final rect = t.getRect(find.byType(IslandCard));
            final stroke = await pixel(
              t,
              boundary,
              Offset(rect.center.dx, rect.top + 1),
            );
            final backing = await pixel(
              t,
              boundary,
              Offset(rect.center.dx, rect.top + 5),
            );
            readable(
              stroke,
              backing,
              minimum: 3,
              reason: '${color.name}/$brightness/$variant actual Card focus',
            );
            if (color == IslandColorway.yellowGreen)
              expect(stroke, const Color(0xff625a11));
            expect(calls, 0);
            await t.pumpWidget(const SizedBox());
          }
        }
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'all colorway Badge dot outlines retain required contrast on actual fills',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final color in IslandColorway.values) {
          for (final size in IslandBadgeSize.values) {
            final boundary = GlobalKey();
            await t.pumpWidget(
              host(
                RepaintBoundary(
                  key: boundary,
                  child: IslandBadge(dot: true, color: color, size: size),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            final rect = t.getRect(find.byType(IslandBadge));
            final stroke = await pixel(
              t,
              boundary,
              Offset(rect.left + 1, rect.center.dy),
            );
            final backing = await pixel(t, boundary, rect.center);
            readable(
              stroke,
              backing,
              minimum: 3,
              reason: '${color.name}/$brightness/$size actual dot border',
            );
            if (color == IslandColorway.yellowGreen)
              expect(stroke, const Color(0xff625a11));
          }
        }
      }
    },
  );
}
