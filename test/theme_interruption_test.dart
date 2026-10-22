import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'counter_audit_test.dart' show pixel;
import 'palette_contrast_test.dart' show foreground, readable;
import 'readable_motion_test.dart' show opaque;

void main() {
  testWidgets(
    'target host switches complete pairs while upstream theme animates and retains input state',
    (t) async {
      final light = IslandTheme.create(),
          dark = IslandTheme.create(brightness: Brightness.dark);
      var data = light;
      final boundary = GlobalKey(),
          controller = TextEditingController(text: 'island'),
          focus = FocusNode();
      late StateSetter update;
      await t.pumpWidget(
        StatefulBuilder(
          builder: (_, set) {
            update = set;
            return MaterialApp(
              theme: data,
              home: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: boundary,
                    child: IslandThemeHost(
                      data: data,
                      child: SizedBox(
                        width: 320,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Default ink'),
                            const Icon(Icons.star),
                            const Text(
                              'Explicit',
                              style: TextStyle(color: Colors.purple),
                            ),
                            IslandTextField(
                              label: 'Name',
                              controller: controller,
                              focusNode: focus,
                              helper: 'Helper',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      focus.requestFocus();
      await t.pumpAndSettle();
      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 4,
      );
      final identity = t.state(find.byType(EditableText));
      for (final target in [dark, light, dark, light]) {
        update(() => data = target);
        for (final ms in [0, 1, 16, 33]) {
          await t.pump(Duration(milliseconds: ms));
          final token = target.extension<IslandTokens>()!;
          final textRect = t.getRect(find.text('Default ink'));
          final background = await pixel(
            t,
            boundary,
            Offset(
              t.getRect(find.byType(IslandThemeHost)).left + 1,
              textRect.center.dy,
            ),
          );
          expect(background, token.paper);
          readable(foreground(t, 'Default ink'), background);
          expect(IconTheme.of(t.element(find.byType(Icon))).color, token.ink);
          expect(foreground(t, 'Explicit'), Colors.purple);
          final rect = t.getRect(find.byType(TextField));
          final border = await pixel(
            t,
            boundary,
            Offset(rect.center.dx, rect.top + .5),
          );
          final fill = await pixel(
            t,
            boundary,
            Offset(rect.right - 30, rect.center.dy),
          );
          readable(border, fill, minimum: 3);
          expect(t.state(find.byType(EditableText)), same(identity));
          expect(focus.hasFocus, isTrue);
          expect(
            controller.selection,
            const TextSelection(baseOffset: 1, extentOffset: 4),
          );
        }
      }
      await t.pumpWidget(const SizedBox());
      controller.dispose();
      focus.dispose();
    },
  );

  testWidgets(
    'validation replaces helper atomically and keeps one field through reset and controller replacement',
    (t) async {
      final form = GlobalKey<FormState>();
      final first = TextEditingController(),
          second = TextEditingController(text: 'replacement');
      var controller = first;
      final focus = FocusNode();
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create(),
          home: Scaffold(
            body: IslandThemeHost(
              data: IslandTheme.create(),
              child: StatefulBuilder(
                builder: (_, set) {
                  update = set;
                  return Form(
                    key: form,
                    child: IslandTextField(
                      label: 'Name',
                      hint: 'Enter',
                      helper: 'Helper',
                      controller: controller,
                      focusNode: focus,
                      validator: (s) => s!.isEmpty ? 'Required' : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      final identity = t.state(find.byType(EditableText));
      focus.requestFocus();
      await t.pumpAndSettle();
      for (var pass = 0; pass < 2; pass++) {
        expect(form.currentState!.validate(), isFalse);
        for (final ms in [0, 1, 40, 84, 167]) {
          await t.pump(Duration(milliseconds: ms));
          expect(find.text('Required'), findsOneWidget);
          expect(find.text('Helper'), findsNothing);
          opaque(t, find.text('Required'));
          readable(foreground(t, 'Required'), IslandTokens.light.paper);
        }
        controller.text = 'valid';
        expect(form.currentState!.validate(), isTrue);
        await t.pump();
        expect(find.text('Required'), findsNothing);
        expect(find.text('Helper'), findsOneWidget);
        form.currentState!.reset();
        await t.pump();
        expect(controller.text, '');
        expect(t.state(find.byType(EditableText)), same(identity));
        expect(focus.hasFocus, isTrue);
      }
      update(() => controller = second);
      await t.pump();
      expect(find.text('replacement'), findsOneWidget);
      second.text = 'external';
      await t.pump();
      expect(find.text('external'), findsOneWidget);
      expect(t.state(find.byType(EditableText)), same(identity));
      await t.pumpWidget(const SizedBox());
      first.dispose();
      second.dispose();
      focus.dispose();
    },
  );

  testWidgets(
    'countdown reduced motion settles interruption and cannot resume old digits',
    (t) async {
      var now = DateTime(2026, 10, 15), reduced = false;
      final deadline = now.add(const Duration(seconds: 10));
      DateTime clock() => now;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: Scaffold(
                  body: IslandCountdown(
                    value: deadline,
                    now: clock,
                    format: 'ss',
                  ),
                ),
              );
            },
          ),
        ),
      );
      await t.pump();
      final identity = t.state(find.byType(IslandCountdown));
      now = now.add(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 250));
      await t.pump(const Duration(milliseconds: 50));
      update(() => reduced = true);
      await t.pump();
      List<Rect> rectangles() => find
          .descendant(
            of: find.byType(IslandCountdown),
            matching: find.byType(Text),
          )
          .evaluate()
          .map(
            (e) =>
                (e.renderObject! as RenderBox).localToGlobal(Offset.zero) &
                (e.renderObject! as RenderBox).size,
          )
          .toList();
      final stable = rectangles();
      update(() => reduced = false);
      await t.pump();
      expect(rectangles(), stable);
      await t.pump(const Duration(milliseconds: 80));
      expect(rectangles(), stable);
      expect(t.state(find.byType(IslandCountdown)), same(identity));
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
}
