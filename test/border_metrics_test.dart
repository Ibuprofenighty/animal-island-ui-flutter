import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'border metric follows local DPR and preserves positive hairlines',
    (t) async {
      // Literal physical-grid expectations, including the minimum-pixel case.
      for (final row in <(double, double, double)>[
        (.5, 2, 2),
        (1, 1, 2),
        (1.25, .8, 2.4),
        (2, 1.5, 2.5),
        (3, 4 / 3, 7 / 3),
      ]) {
        final widths = <double>[];
        await t.pumpWidget(
          MediaQuery(
            data: MediaQueryData(devicePixelRatio: row.$1),
            child: Builder(
              builder: (context) {
                widths.addAll([
                  for (final width in [-1.0, 0.0, .01, 1.5, 2.5])
                    IslandTheme.borderWidth(context, width),
                ]);
                return const SizedBox();
              },
            ),
          ),
        );
        expect(widths, [0, 0, 1 / row.$1, row.$2, row.$3]);
      }
    },
  );
  testWidgets('Tag and Switch consume the theme metric after DPR changes', (
    t,
  ) async {
    for (final row in <(double, double, double)>[
      (.5, 2, 2),
      (1, 1, 2),
      (2, 1.5, 2.5),
    ]) {
      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(devicePixelRatio: row.$1),
            child: Column(
              children: [
                const IslandTag(
                  variant: IslandTagVariant.outlined,
                  child: Text('Tag'),
                ),
                IslandSwitch(
                  label: 'Switch',
                  value: false,
                  onChanged: (_) {},
                  showLabel: false,
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final tag = t.widget<Container>(
        find
            .descendant(
              of: find.byType(IslandTag),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is ShapeDecoration &&
                    (w.decoration! as ShapeDecoration).color != null,
              ),
            )
            .first,
      );
      expect(
        ((tag.decoration! as ShapeDecoration).shape as StadiumBorder)
            .side
            .width,
        row.$2,
      );
      final track = t.widget<Container>(
        find
            .descendant(
              of: find.byType(IslandSwitch),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).border != null,
              ),
            )
            .first,
      );
      expect(
        ((track.decoration! as BoxDecoration).border! as Border).top.width,
        row.$3,
      );
      expect(t.takeException(), isNull);
    }
  });
}
