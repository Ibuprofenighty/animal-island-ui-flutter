import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: child),
  ),
);
const options = [
  IslandOption(value: 'a', label: 'Apple'),
  IslandOption(value: 'b', label: 'Berry'),
  IslandOption(value: 'c', label: 'Cherry', disabled: true),
];
void main() {
  testWidgets(
    'Select keyboard skips disabled and rejected proposals preserve parent value',
    (t) async {
      String? requested;
      await t.pumpWidget(
        host(
          IslandSelect<String>(
            options: options,
            value: 'a',
            onChanged: (v) => requested = v,
            label: 'Fruit',
          ),
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pumpAndSettle();
      expect(find.text('Berry'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(requested, 'b');
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Berry'), findsNothing);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.end);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(requested, 'b');
    },
  );
  testWidgets(
    'Select search, empty result and outside close reset query once',
    (t) async {
      final searches = <String>[];
      await t.pumpWidget(
        host(
          Column(
            children: [
              IslandSelect<String>(
                options: options,
                value: 'a',
                onChanged: (_) {},
                showSearch: true,
                onSearch: searches.add,
              ),
              const SizedBox(height: 200),
              const Text('Outside'),
            ],
          ),
        ),
      );
      await t.enterText(find.byType(TextField), 'zz');
      await t.pumpAndSettle();
      expect(find.text('暂无数据'), findsOneWidget);
      expect(searches, ['zz']);
      await t.tap(find.text('Outside'));
      await t.pumpAndSettle();
      expect(searches, ['zz', '']);
      expect(find.text('暂无数据'), findsNothing);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Apple',
      );
    },
  );
  testWidgets(
    'Select follows stable option values across reorder and borrows focus',
    (t) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var list = options;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandSelect<String>(
                options: list,
                value: 'b',
                onChanged: (_) {},
                focusNode: focus,
                allowClear: true,
              );
            },
          ),
        ),
      );
      await t.tap(find.text('Berry'));
      await t.pumpAndSettle();
      update(() => list = [options[2], options[1], options[0]]);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('Berry'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      await t.pumpWidget(const SizedBox());
      focus.requestFocus();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Select clear dispatches once and retains an open option panel', (
    t,
  ) async {
    final requests = <String?>[];
    var cleared = 0;
    await t.pumpWidget(
      host(
        IslandSelect<String>(
          options: options,
          value: 'a',
          onChanged: requests.add,
          allowClear: true,
          onClear: () => cleared++,
        ),
      ),
    );
    await t.tap(find.text('Apple'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('清除'));
    await t.pumpAndSettle();
    expect(requests, [null]);
    expect(cleared, 1);
    expect(find.text('Berry'), findsOneWidget);
    expect(find.text('Apple'), findsNWidgets(2));
  });
  testWidgets(
    'Selected option has no extra ring; the active ring is keyboard-only',
    (t) async {
      await t.pumpWidget(
        host(
          IslandSelect<String>(options: options, value: 'a', onChanged: (_) {}),
        ),
      );
      Finder ring(String label) => find.descendant(
        of: find
            .ancestor(of: find.text(label).last, matching: find.byType(Stack))
            .first,
        matching: find.byWidgetPredicate(
          (w) => w is DecoratedBox && w.decoration is! BoxDecoration,
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pumpAndSettle();
      expect(ring('Apple'), findsNothing);
      expect(ring('Berry'), findsNothing);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      expect(ring('Berry'), findsOneWidget);
      expect(ring('Apple'), findsNothing);
    },
  );
  testWidgets('Select trigger hover darkens its border', (t) async {
    await t.pumpWidget(
      host(
        IslandSelect<String>(options: options, value: 'a', onChanged: (_) {}),
      ),
    );
    Color border() =>
        ((t
                            .widget<AnimatedContainer>(
                              find
                                  .descendant(
                                    of: find.byType(IslandSelect<String>),
                                    matching: find.byType(AnimatedContainer),
                                  )
                                  .first,
                            )
                            .decoration!
                        as BoxDecoration)
                    .border!
                as Border)
            .top
            .color;
    expect(border(), IslandTokens.light.outline);
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(t.getCenter(find.text('Apple')));
    await t.pumpAndSettle();
    expect(border(), IslandTokens.light.muted);
  });
  testWidgets('Select clear hover fills its 20px circle', (t) async {
    await t.pumpWidget(
      host(
        IslandSelect<String>(
          options: options,
          value: 'a',
          onChanged: (_) {},
          allowClear: true,
        ),
      ),
    );
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(t.getCenter(find.text('Apple')));
    await t.pumpAndSettle();
    final clear = find.bySemanticsLabel('清除');
    BoxDecoration circle() =>
        t
                .widget<AnimatedContainer>(
                  find.descendant(
                    of: clear,
                    matching: find.byType(AnimatedContainer),
                  ),
                )
                .decoration!
            as BoxDecoration;
    expect(
      t.getSize(
        find.descendant(of: clear, matching: find.byType(AnimatedContainer)),
      ),
      const Size(20, 20),
    );
    expect(circle().color!.a, 0);
    await mouse.moveTo(t.getCenter(clear));
    await t.pumpAndSettle();
    expect(circle().color, const Color(0xff725d42).withValues(alpha: .1));
  });

  testWidgets('Select clear glyph turns the reference #725d42 on hover', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        IslandSelect<String>(
          options: options,
          value: 'a',
          onChanged: (_) {},
          allowClear: true,
        ),
      ),
    );
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(t.getCenter(find.byType(IslandSelect<String>)));
    await t.pumpAndSettle();
    final glyph = find.byWidgetPredicate(
      (w) => w is IslandIcon && w.glyph == IslandGlyph.close,
    );
    await mouse.moveTo(t.getCenter(glyph));
    await t.pumpAndSettle();
    expect(t.widget<IslandIcon>(glyph).color, const Color(0xff725d42));
  });
}
