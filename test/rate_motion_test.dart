import 'dart:ui' as ui;
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Future<int> centerAlpha(WidgetTester t, int star) async {
  final paint = t
      .widgetList<CustomPaint>(
        find.descendant(
          of: find.bySemanticsLabel('$star 星'),
          matching: find.byType(CustomPaint),
        ),
      )
      .firstWhere((w) => w.size == const Size.square(26));
  final recorder = ui.PictureRecorder();
  paint.painter!.paint(Canvas(recorder), paint.size);
  final picture = recorder.endRecording();
  final alpha = (await t.runAsync(() async {
    final image = await picture.toImage(26, 26);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final alpha = bytes.getUint8((13 * 26 + 13) * 4 + 3);
    image.dispose();
    return alpha;
  }))!;
  picture.dispose();
  return alpha;
}

void main() {
  testWidgets('Rate pops only new stars with350ms duration and60ms stagger', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: IslandRate(initialValue: 2))),
      ),
    );
    double scale(int star) => t
        .widgetList<Transform>(
          find.descendant(
            of: find.bySemanticsLabel('$star 星'),
            matching: find.byType(Transform),
          ),
        )
        .last
        .transform
        .storage[0];
    await t.tap(find.bySemanticsLabel('5 星'));
    await t.pump();
    expect(scale(1), 1);
    expect(scale(2), 1);
    expect(scale(3), 1.0);
    expect(scale(4), 1.0);
    expect(scale(5), 1.0);
    await t.pump(const Duration(milliseconds: 60));
    expect(scale(3), greaterThan(1.0));
    expect(scale(4), 1.0);
    await t.pump(const Duration(milliseconds: 290));
    expect(scale(3), closeTo(1, .0001));
    expect(scale(4), greaterThan(1));
    await t.pump(const Duration(milliseconds: 120));
    expect(scale(5), closeTo(1, .0001));
    await t.pump(const Duration(milliseconds: 130));
    await t.tap(find.bySemanticsLabel('2 星'));
    await t.pump();
    expect(scale(1), 1);
    expect(scale(2), 1);
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
  });
  testWidgets('Rate clamps committed keyboard value and exposes one Tab stop', (
    t,
  ) async {
    final proposals = <int>[];
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextButton(
                autofocus: true,
                onPressed: () {},
                child: const Text('before'),
              ),
              IslandRate(initialValue: 3, onChanged: proposals.add),
              TextButton(onPressed: () {}, child: const Text('after')),
            ],
          ),
        ),
      ),
    );
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await t.pump();
    expect(proposals, [4]);
    await t.sendKeyEvent(LogicalKeyboardKey.end);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.pump();
    expect(proposals, [4, 5]);
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    expect(Focus.of(t.element(find.text('after'))).hasFocus, isTrue);
    await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.home);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await t.pump();
    expect(proposals, [4, 5, 1]);
    await t.pumpAndSettle();
  });
  testWidgets(
    'Rate hover translates only hovered star and clear removes preview',
    (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: IslandRate(initialValue: 3))),
        ),
      );
      final third = find.bySemanticsLabel('3 星');
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(third));
      await t.pump();
      await t.pump(const Duration(milliseconds: 250));
      final surface = t.widget<AnimatedContainer>(
        find.descendant(of: third, matching: find.byType(AnimatedContainer)),
      );
      expect(surface.transform!.storage[13], -1);
      await t.tap(third);
      await t.pumpAndSettle();
      for (var star = 1; star <= 5; star++) {
        expect(
          await centerAlpha(t, star),
          0,
          reason: 'clear removes actual selected fill',
        );
      }
      await mouse.removePointer();
      await t.pumpAndSettle();
    },
  );
}
