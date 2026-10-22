import 'dart:ui' show PointerDeviceKind;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final variant in IslandTitleVariant.values) {
    testWidgets(
      'Title $variant keeps an intrinsic single line in a narrow host',
      (t) async {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 100,
                child: IslandTitle(
                  variant: variant,
                  child: const Text('A long island heading'),
                ),
              ),
            ),
          ),
        );
        final text = t.renderObject<RenderBox>(
          find.text('A long island heading'),
        );
        expect(text.size.width, greaterThan(100));
        expect(t.getSize(find.byType(IslandTitle)).height, lessThan(60));
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Title retains an explicitly sized opaque child across variants',
    (t) async {
      late StateSetter update;
      var variant = IslandTitleVariant.ribbon;
      final childKey = GlobalKey();
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                update = set;
                return SizedBox(
                  width: 100,
                  child: IslandTitle(
                    variant: variant,
                    child: SizedBox(
                      width: 150,
                      height: 90,
                      child: TextField(key: childKey),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      final state = childKey.currentState;
      expect(t.getSize(find.byKey(childKey)), const Size(150, 90));
      update(() => variant = IslandTitleVariant.tab);
      await t.pump();
      expect(childKey.currentState, same(state));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('variant padding and optical offsets follow the live reference', (
    t,
  ) async {
    for (final variant in IslandTitleVariant.values) {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: IslandTitle(
                variant: variant,
                child: const SizedBox(
                  key: ValueKey('slot'),
                  width: 80,
                  height: 20,
                ),
              ),
            ),
          ),
        ),
      );
      final paint = find.descendant(
        of: find.byType(IslandTitle),
        matching: find.byType(CustomPaint),
      );
      final rect = t.getRect(paint);
      final slot = t.getRect(find.byKey(const ValueKey('slot')));
      final (width, height, left, top) = switch (variant) {
        IslandTitleVariant.ribbon => (144.0, 40.0, 32.0, 11.1),
        IslandTitleVariant.layer => (142.0, 42.0, 31.0, 11.0),
        IslandTitleVariant.tab => (148.0, 40.0, 38.0, 10.0),
      };
      expect(rect.size, Size(width, height));
      expect(slot.left - rect.left, closeTo(left, .001));
      expect(slot.top - rect.top, closeTo(top, .001));
    }
  });
  testWidgets(
    'layer and tab hover animate without layout or child-state changes',
    (t) async {
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(700, 500));
      addTearDown(mouse.removePointer);
      for (final variant in IslandTitleVariant.values) {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: IslandTitle(
                  key: ValueKey(variant),
                  variant: variant,
                  child: const SizedBox(
                    key: ValueKey('slot'),
                    width: 80,
                    height: 20,
                  ),
                ),
              ),
            ),
          ),
        );
        final title = t.getRect(find.byType(IslandTitle));
        final slot = find.byKey(const ValueKey('slot'));
        final original = t.getRect(slot);
        await mouse.moveTo(original.center);
        await t.pump();
        await t.pump(const Duration(milliseconds: 100));
        final factor = variant == IslandTitleVariant.ribbon ? 1.0 : 1.04814;
        expect(t.getRect(slot).width / original.width, closeTo(factor, .0001));
        expect(t.getRect(find.byType(IslandTitle)), title);
        await t.pump(const Duration(milliseconds: 100));
        expect(
          t.getRect(slot).width / original.width,
          closeTo(variant == IslandTitleVariant.ribbon ? 1 : 1.06, .0001),
        );
        await mouse.moveTo(const Offset(700, 500));
        await t.pumpAndSettle();
        expect(t.getRect(slot), original);
      }
    },
  );
  testWidgets(
    'reduced motion applies hover immediately and explicit text style wins',
    (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: IslandTitle(
                  variant: IslandTitleVariant.tab,
                  child: Text('Opaque', style: TextStyle(color: Colors.purple)),
                ),
              ),
            ),
          ),
        ),
      );
      final text = find.text('Opaque');
      final original = t.getRect(text);
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(700, 500));
      addTearDown(mouse.removePointer);
      await mouse.moveTo(original.center);
      await t.pump();
      await t.pump();
      expect(t.getRect(text).width / original.width, closeTo(1.06, .0001));
      expect(
        (t.renderObject<RenderParagraph>(text).text as TextSpan).style!.color,
        Colors.purple,
      );
      expect(t.hasRunningAnimations, isFalse);
    },
  );
}
