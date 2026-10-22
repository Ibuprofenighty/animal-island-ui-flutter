import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets('focus preserves64px bounds and hover shadow interpolates300ms', (
    t,
  ) async {
    final controller = ScrollController();
    final focus = FocusNode();
    addTearDown(controller.dispose);
    addTearDown(focus.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              ListView(
                controller: controller,
                children: const [SizedBox(height: 3000)],
              ),
              IslandBackTop(controller: controller, focusNode: focus),
            ],
          ),
        ),
      ),
    );
    controller.jumpTo(500);
    await t.pumpAndSettle();
    final button = find.bySemanticsLabel('返回顶部');
    final before = t.getRect(button);
    expect(before.size, const Size(64, 64));
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    focus.requestFocus();
    await t.pumpAndSettle();
    expect(t.getRect(button), before);
    final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(t.getCenter(button));
    await t.pump();
    final filter = find.descendant(
      of: button,
      matching: find.byType(ColorFiltered),
    );
    ColorFilter shadow() => t.widget<ColorFiltered>(filter).colorFilter;
    expect(
      shadow(),
      const ColorFilter.mode(Color(0x385b4e1e), BlendMode.srcIn),
    );
    await t.pump(const Duration(milliseconds: 150));
    final half = const Cubic(.4, 0, .2, 1).transform(.5);
    expect(
      shadow(),
      ColorFilter.mode(
        Color.lerp(const Color(0x385b4e1e), const Color(0x525b4e1e), half)!,
        BlendMode.srcIn,
      ),
    );
    await t.pump(const Duration(milliseconds: 150));
    expect(
      shadow(),
      const ColorFilter.mode(Color(0x525b4e1e), BlendMode.srcIn),
    );
    await mouse.moveTo(Offset.zero);
    await t.pumpAndSettle();
    expect(
      shadow(),
      const ColorFilter.mode(Color(0x385b4e1e), BlendMode.srcIn),
    );
    await mouse.removePointer();
    await t.pumpWidget(const SizedBox());
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'strict threshold, keyboard scroll and controller replacement stay isolated',
    (tester) async {
      final first = ScrollController(), second = ScrollController();
      final focus = FocusNode();
      addTearDown(focus.dispose);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      var useSecond = false, clicks = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return Scaffold(
                body: Stack(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ListView(
                            controller: first,
                            children: const [SizedBox(height: 3000)],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: second,
                            children: const [SizedBox(height: 3000)],
                          ),
                        ),
                      ],
                    ),
                    IslandBackTop(
                      focusNode: focus,
                      controller: useSecond ? second : first,
                      onPressed: () => clicks++,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      bool hasButton() => tester.semantics
          .simulatedAccessibilityTraversal()
          .any((node) => node.label == '返回顶部');
      expect(hasButton(), isFalse);
      first.jumpTo(400);
      await tester.pumpAndSettle();
      expect(hasButton(), isFalse);
      first.jumpTo(401);
      await tester.pumpAndSettle();
      expect(hasButton(), isTrue);
      update(() => useSecond = true);
      await tester.pumpAndSettle();
      expect(hasButton(), isFalse);
      first.jumpTo(800);
      await tester.pumpAndSettle();
      expect(hasButton(), isFalse);
      second.jumpTo(900);
      await tester.pumpAndSettle();
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(second.offset, 0);
      expect(first.offset, 800);
      expect(clicks, 1);
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
      first.addListener(() {});
      second.addListener(() {});
      expect(tester.takeException(), isNull);
    },
  );
}
