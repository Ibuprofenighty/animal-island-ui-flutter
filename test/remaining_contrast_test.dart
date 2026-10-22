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
}
