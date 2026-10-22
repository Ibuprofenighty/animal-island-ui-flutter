import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  theme: IslandTheme.create(),
  home: Scaffold(body: SizedBox(width: 720, child: child)),
);

void main() {
  testWidgets(
    'keyboard focus paints a clipped 1px inset without moving content',
    (t) async {
      final boundary = GlobalKey();
      await t.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: host(
            const Align(
              alignment: Alignment.topLeft,
              child: IslandCollapse.uncontrolled(
                question: Text('Question'),
                answer: Text('Answer'),
              ),
            ),
          ),
        ),
      );
      final card = t.getRect(find.byType(IslandCollapse));
      final question = t.getRect(find.text('Question'));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(t.getRect(find.text('Question')), question);
      expect(t.getRect(find.byType(IslandCollapse)), card);
      await t.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        List<int> pixel(int x, int y) {
          final index =
              ((card.top.toInt() + y) * image.width + card.left.toInt() + x) *
              4;
          return List.generate(3, (n) => bytes!.getUint8(index + n));
        }

        expect(pixel(100, 2), [0, 86, 79]);
        expect(pixel(100, 3), isNot([0, 86, 79]));
        expect(pixel(2, 25), [0, 86, 79]);
        expect(pixel(3, 25), isNot([0, 86, 79]));
        // The rectangular stroke is clipped, not redrawn as a rounded ring.
        expect(pixel(5, 5), isNot([0, 86, 79]));
        image.dispose();
      });
    },
  );
  testWidgets('opaque slot typography and taller content remain caller-owned', (
    t,
  ) async {
    for (final scale in [1.0, 2.0]) {
      await t.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(
              body: SizedBox(
                width: 320,
                child: IslandCollapse.uncontrolled(
                  initialExpanded: true,
                  question: Text(
                    'A\nB',
                    style: TextStyle(fontSize: 30, height: 2),
                    strutStyle: StrutStyle(
                      fontSize: 30,
                      height: 2,
                      forceStrutHeight: true,
                    ),
                  ),
                  answer: SizedBox(
                    key: ValueKey('tall-answer'),
                    height: 130,
                    child: Text('Opaque'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(t.getSize(find.text('A\nB')).height, 120 * scale);
      expect(t.getSize(find.byKey(const ValueKey('tall-answer'))).height, 130);
      expect(t.takeException(), isNull);
    }
  });

  testWidgets(
    'controlled rejection preserves expansion; hidden answer retains state and releases focus',
    (tester) async {
      var expanded = false;
      final proposals = <bool>[];
      final header = FocusNode();
      final field = FocusNode();
      final controller = TextEditingController(text: 'island');
      addTearDown(header.dispose);
      addTearDown(field.dispose);
      addTearDown(controller.dispose);
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandCollapse(
                question: const Text('Question'),
                expanded: expanded,
                onExpandedChanged: proposals.add,
                focusNode: header,
                answer: TextField(focusNode: field, controller: controller),
              );
            },
          ),
        ),
      );
      final originalField = tester.state(find.byType(TextField));
      await tester.tap(find.text('Question'));
      await tester.pumpAndSettle();
      expect(proposals, [true]);
      expect(tester.getSize(find.byType(SizeTransition)).height, 0);
      update(() => expanded = true);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(SizeTransition)).height,
        greaterThan(24),
      );
      await tester.enterText(find.byType(TextField), 'resident');
      expect(field.hasFocus, isTrue);
      update(() => expanded = false);
      await tester.pumpAndSettle();
      expect(field.hasFocus, isFalse);
      expect(header.hasFocus, isTrue);
      expect(tester.state(find.byType(TextField)), same(originalField));
      expect(controller.text, 'resident');
      await tester.pumpWidget(const SizedBox());
      header.requestFocus(); // Borrowed resources remain usable after removal.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'independent disclosures keep keyed state through reorder and honor explicit slot style',
    (tester) async {
      var reverse = false;
      late StateSetter update;
      var nested = 0;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              final children = [
                IslandCollapse.uncontrolled(
                  key: const ValueKey('one'),
                  question: const Text(
                    'One',
                    style: TextStyle(color: Colors.red),
                  ),
                  answer: TextButton(
                    onPressed: () => nested++,
                    child: const Text('Answer action'),
                  ),
                ),
                const IslandCollapse.uncontrolled(
                  key: ValueKey('two'),
                  question: Text('Two'),
                  answer: Text('Disabled answer'),
                  disabled: true,
                ),
              ];
              return Column(
                children: reverse ? children.reversed.toList() : children,
              );
            },
          ),
        ),
      );
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Answer action'));
      expect(nested, 1);
      expect(
        tester.getTopLeft(find.byType(TextButton)).dx,
        tester.getTopLeft(find.byKey(const ValueKey('one'))).dx + 26,
      );
      update(() => reverse = true);
      await tester.pumpAndSettle();
      final one = find.byKey(const ValueKey('one'));
      final two = find.byKey(const ValueKey('two'));
      expect(
        tester
            .getSize(
              find.descendant(of: one, matching: find.byType(SizeTransition)),
            )
            .height,
        greaterThan(0),
      );
      expect(
        tester
            .getSize(
              find.descendant(of: two, matching: find.byType(SizeTransition)),
            )
            .height,
        0,
      );
      expect(tester.widget<Text>(find.text('One')).style!.color, Colors.red);
      await tester.tap(find.text('Two'));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSize(
              find.descendant(of: two, matching: find.byType(SizeTransition)),
            )
            .height,
        0,
      );
      await tester.tap(find.text('One'));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pumpAndSettle();
      expect(
        tester
            .getSize(
              find.descendant(of: one, matching: find.byType(SizeTransition)),
            )
            .height,
        greaterThan(0),
      );
    },
  );
  testWidgets(
    '250ms details finish before the 300ms reveal and reverse continuously',
    (t) async {
      await t.pumpWidget(
        host(
          const IslandCollapse.uncontrolled(
            question: Text('Motion'),
            answer: SizedBox(height: 100),
          ),
        ),
      );
      final reveal = find.byType(SizeTransition);
      await t.tap(find.text('Motion'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 250));
      final height = t.getSize(reveal).height;
      expect(height, inExclusiveRange(120, 124));
      final iconTransform = t.widget<Transform>(
        find
            .ancestor(of: find.text('−'), matching: find.byType(Transform))
            .first,
      );
      expect(iconTransform.transform.entry(0, 0), closeTo(-1, .00001));
      await t.pump(const Duration(milliseconds: 50));
      expect(t.getSize(reveal).height, 124);
      await t.tap(find.text('Motion'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      final closingHeight = t.getSize(reveal).height;
      expect(closingHeight, inExclusiveRange(0, 124));
      await t.tap(find.text('Motion'));
      await t.pump();
      expect(t.getSize(reveal).height, closingHeight);
      await t.pump(const Duration(milliseconds: 30));
      expect(t.getSize(reveal).height, greaterThan(closingHeight));
      await t.pumpAndSettle();
      expect(t.getSize(reveal).height, 124);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('short answers retain the CSS grid padding floor during reveal', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        const IslandCollapse.uncontrolled(
          question: Text('Tiny'),
          answer: SizedBox(height: 1),
        ),
      ),
    );
    await t.tap(find.text('Tiny'));
    await t.pump();
    await t.pump(const Duration(milliseconds: 125));
    // 250ms cubic(.4,0,.2,1) at half time is .77556; the grid
    // cannot shrink below the animated 24px padding even for a 1px slot.
    expect(
      t.getSize(find.byType(SizeTransition)).height,
      closeTo(18.6134, .02),
    );
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(SizeTransition)).height, 25);
  });
  testWidgets(
    'reduced motion synchronizes reveal and details without a ticker',
    (t) async {
      await t.pumpWidget(
        host(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: IslandCollapse.uncontrolled(
              question: Text('Immediate'),
              answer: SizedBox(height: 100),
            ),
          ),
        ),
      );
      await t.tap(find.text('Immediate'));
      await t.pump();
      expect(t.getSize(find.byType(SizeTransition)).height, 124);
      await t.tap(find.text('Immediate'));
      await t.pump();
      expect(t.getSize(find.byType(SizeTransition)).height, 0);
      expect(t.hasRunningAnimations, isFalse);
    },
  );
}
