import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const drawingInk = Color(0xff2a2a2a);

void main() {
  for (final variant in IslandButtonVariant.values) {
    testWidgets('$variant busy donut keeps its drawing ink under any style', (
      t,
    ) async {
      for (final style in [
        null,
        ButtonStyle(
          foregroundColor: WidgetStateProperty.all(const Color(0xffcc0000)),
        ),
      ]) {
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            home: Scaffold(
              body: IslandButton(
                variant: variant,
                busy: true,
                style: style,
                onPressed: () {},
                child: const Text('Saving'),
              ),
            ),
          ),
        );
        final donut = t.widget<IslandIcon>(
          find.byWidgetPredicate(
            (w) => w is IslandIcon && w.glyph == IslandGlyph.donut,
          ),
        );
        expect(donut.color, drawingInk);
      }
    });
  }
}
