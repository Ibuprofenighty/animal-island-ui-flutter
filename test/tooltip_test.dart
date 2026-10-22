import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);
void main() {
  testWidgets(
    'hover tooltip preserves child activation and allows travel into bubble',
    (t) async {
      var taps = 0;
      await t.pumpWidget(
        host(
          IslandTooltip(
            message: 'Description',
            child: IslandButton(
              onPressed: () => taps++,
              child: const Text('Action'),
            ),
          ),
        ),
      );
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(find.text('Action')));
      await t.pumpAndSettle();
      expect(find.text('Description'), findsOneWidget);
      await t.tap(find.text('Action'));
      expect(taps, 1);
      await mouse.moveTo(t.getCenter(find.text('Description')));
      await t.pump(const Duration(milliseconds: 150));
      expect(find.text('Description'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await t.pump(const Duration(milliseconds: 110));
      await t.pumpAndSettle();
      expect(find.text('Description'), findsNothing);
      await mouse.removePointer();
    },
  );
  testWidgets(
    'click composes keyboard action once and Escape dismisses without losing focus',
    (t) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var calls = 0;
      await t.pumpWidget(
        host(
          IslandTooltip.click(
            message: 'Click hint',
            builder: (_, toggle) => IslandButton(
              focusNode: focus,
              onPressed: () {
                calls++;
                toggle();
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Click hint'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('Click hint'), findsNothing);
      expect(focus.hasFocus, isTrue);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('Click hint'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(calls, 3);
      expect(find.text('Click hint'), findsNothing);
    },
  );
  testWidgets(
    'focus tooltip retains edited child, borrowed focus and cancels teardown timers',
    (t) async {
      final focus = FocusNode(), next = FocusNode();
      final input = TextEditingController();
      addTearDown(() {
        focus.dispose();
        next.dispose();
        input.dispose();
      });
      await t.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IslandTooltip(
                message: 'Input hint',
                trigger: IslandTooltipTrigger.focus,
                child: SizedBox(
                  width: 200,
                  child: TextField(focusNode: focus, controller: input),
                ),
              ),
              TextButton(
                focusNode: next,
                onPressed: () {},
                child: const Text('Next'),
              ),
            ],
          ),
        ),
      );
      await t.enterText(find.byType(TextField), 'kept');
      await t.pumpAndSettle();
      expect(find.text('Input hint'), findsOneWidget);
      next.requestFocus();
      await t.pump(const Duration(milliseconds: 110));
      await t.pumpAndSettle();
      expect(find.text('Input hint'), findsNothing);
      expect(input.text, 'kept');
      focus.requestFocus();
      await t.pumpAndSettle();
      next.requestFocus();
      await t.pump();
      await t.pumpWidget(host(const SizedBox()));
      await t.pump(const Duration(seconds: 1));
      focus.requestFocus();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'all twelve placements use actual child geometry and retain rich styles',
    (t) async {
      for (final placement in IslandTooltipPlacement.values) {
        await t.pumpWidget(
          host(
            IslandTooltip.click(
              key: ValueKey(placement),
              message: 'Hint',
              placement: placement,
              variant: IslandTooltipVariant.island,
              content: const Text(
                'Rich hint',
                style: TextStyle(color: Colors.red),
              ),
              builder: (_, toggle) =>
                  IslandButton(onPressed: toggle, child: const Text('Anchor')),
            ),
          ),
        );
        await t.tap(find.text('Anchor'));
        await t.pumpAndSettle();
        final anchor = t.getRect(find.byType(IslandButton));
        final bubble = t.getRect(
          find.byWidgetPredicate(
            (w) =>
                w is CustomPaint &&
                w.painter?.runtimeType.toString() == '_BubblePainter',
          ),
        );
        switch (placement.index ~/ 3) {
          case 0:
            expect(bubble.bottom, closeTo(anchor.top - 10, .01));
          case 1:
            expect(bubble.top, closeTo(anchor.bottom + 10, .01));
          case 2:
            expect(bubble.right, closeTo(anchor.left - 10, .01));
          case 3:
            expect(bubble.left, closeTo(anchor.right + 10, .01));
        }
        expect(t.widget<Text>(find.text('Rich hint')).style!.color, Colors.red);
        expect(t.takeException(), isNull);
      }
    },
  );
}
