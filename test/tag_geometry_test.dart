import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Tag defaults to observed soft colors and preserves border geometry',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      Widget host(Widget child) => MaterialApp(
        home: Scaffold(body: Center(child: child)),
      );
      await t.pumpWidget(
        host(
          const IslandTag(colorway: IslandColorway.blue, child: Text('Tag')),
        ),
      );
      expect(
        t.widget<IslandTag>(find.byType(IslandTag)).variant,
        IslandTagVariant.soft,
      );
      final surface = t.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(IslandTag),
          matching: find.byWidgetPredicate(
            (w) =>
                w is DecoratedBox &&
                w.decoration is ShapeDecoration &&
                (w.decoration as ShapeDecoration).color != null,
          ),
        ),
      );
      expect(
        (surface.decoration as ShapeDecoration).color,
        const Color(0xffe6f0ff),
      );
      expect(
        DefaultTextStyle.of(t.element(find.text('Tag'))).style.color,
        const Color(0xff1565c0),
      );
      final size = t.getSize(find.byType(IslandTag));
      await t.pumpWidget(
        host(
          const IslandTag(variant: IslandTagVariant.dashed, child: Text('Tag')),
        ),
      );
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(IslandTag)), size);
      await t.pumpWidget(
        host(IslandTag(onClose: () {}, child: const Text('Tag'))),
      );
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(IslandTag)).width, size.width + 18);
      expect(t.getSize(find.bySemanticsLabel('close')), const Size(16, 16));
    },
  );
}
