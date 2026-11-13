import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);
void main() {
  testWidgets(
    'countdown uses deadline, finish once, replaces deadline and cancels disposal',
    (t) async {
      var now = DateTime(2026, 10, 13, 12);
      DateTime clock() => now;
      var deadline = now.add(const Duration(seconds: 2));
      var finishes = 0;
      final changes = <Duration>[];
      late StateSetter rebuild;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              rebuild = set;
              return IslandCountdown(
                value: deadline,
                now: clock,
                onChange: changes.add,
                onFinish: () => finishes++,
              );
            },
          ),
        ),
      );
      now = now.add(const Duration(seconds: 4));
      await t.pump(const Duration(milliseconds: 250));
      expect(finishes, 1);
      final after = changes.length;
      await t.pump(const Duration(seconds: 2));
      expect(changes.length, after);
      rebuild(() => deadline = now.add(const Duration(seconds: 1)));
      await t.pump();
      now = now.add(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 250));
      expect(finishes, 2);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 2));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('time updates from clock and cancels timer', (t) async {
    var now = DateTime(2026, 10, 13, 23, 59);
    await t.pumpWidget(host(IslandTime(now: () => now)));
    expect(find.text('23'), findsOneWidget);
    now = now.add(const Duration(minutes: 1));
    await t.pump(const Duration(seconds: 1));
    expect(find.text('WEDNESDAY'), findsOneWidget);
    expect(find.text('00'), findsNWidgets(2));
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'time-picker preview is discarded on Escape and host rejects confirmed value',
    (t) async {
      IslandTimeValue? proposal;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await t.pumpWidget(
        host(
          IslandTimePicker(
            value: const IslandTimeValue(9, 30),
            focusNode: focus,
            onChanged: (v) => proposal = v,
          ),
        ),
      );
      await t.tap(find.text('09:30:00'));
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel(RegExp(r'^1 秒')));
      await t.pump();
      expect(find.text('09:30:01'), findsOneWidget);
      expect(proposal, isNull);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('09:30:00'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel(RegExp(r'^1 秒')));
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(proposal, const IslandTimeValue(9, 30, 1));
      expect(find.text('09:30:00'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      focus.requestFocus();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'time-picker clear does not open parent and controlled open can reject',
    (t) async {
      var clears = 0;
      final requests = <bool>[];
      await t.pumpWidget(
        host(
          IslandTimePicker(
            value: const IslandTimeValue(9, 30),
            allowClear: true,
            open: false,
            onChanged: (v) {
              if (v == null) clears++;
            },
            onOpenChanged: requests.add,
          ),
        ),
      );
      await t.tap(find.bySemanticsLabel(RegExp(r'^清除时间')));
      await t.pumpAndSettle();
      expect(clears, 1);
      expect(requests, isEmpty);
      await t.tap(find.text('09:30:00'));
      await t.pumpAndSettle();
      expect(requests, [true]);
      expect(find.text('确定'), findsNothing);
    },
  );
  testWidgets(
    'time-picker value slot fills a fixed width and confirm hover is #796c5a',
    (t) async {
      await t.pumpWidget(
        host(
          SizedBox(
            width: 300,
            child: IslandTimePicker(
              value: const IslandTimeValue(9, 30),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      final box = t.getRect(find.byType(IslandTimePicker));
      final icon = t
          .widgetList<CustomPaint>(
            find.descendant(
              of: find.byType(IslandTimePicker),
              matching: find.byType(CustomPaint),
            ),
          )
          .map((w) => t.getRect(find.byWidget(w)))
          .firstWhere((r) => r.width == 14 && r.height == 14);
      expect(icon.right, closeTo(box.right - 18, .01));
      expect(t.getRect(find.text('09:30:00')).left, box.left + 18);
      await t.tap(find.text('09:30:00'));
      await t.pumpAndSettle();
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(t.getCenter(find.text('确定')));
      await t.pumpAndSettle();
      expect(
        find.ancestor(
          of: find.text('确定'),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                (w.decoration as BoxDecoration?)?.color ==
                    const Color(0xff796c5a),
          ),
        ),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'time colon blinks on the reference 1s step-end cycle; digits never dim',
    (t) async {
      await t.pumpWidget(
        host(IslandTime(now: () => DateTime(2026, 10, 13, 9, 5))),
      );
      double colon() => t
          .widget<Opacity>(
            find.ancestor(of: find.text(':'), matching: find.byType(Opacity)),
          )
          .opacity;
      bool digitsOpaque() => [find.text('09'), find.text('05')].every(
        (digit) => t
            .widgetList<Opacity>(
              find.ancestor(of: digit, matching: find.byType(Opacity)),
            )
            .every((o) => o.opacity == 1),
      );
      // Visible for the first half of each second, hidden for the second.
      final observed = <double>[colon()];
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(milliseconds: 500));
        observed.add(colon());
        expect(digitsOpaque(), isTrue);
      }
      expect(observed, [1, 0, 1, 0, 1]);
      // Semantics always carries the complete clock.
      expect(t.getSemantics(find.byType(IslandTime)).value, contains('09:05'));
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('reduced motion keeps the time colon steadily visible', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(
            body: IslandTime(now: () => DateTime(2026, 10, 13, 9, 5)),
          ),
        ),
      ),
    );
    for (var i = 0; i < 4; i++) {
      await t.pump(const Duration(milliseconds: 500));
      expect(
        t
            .widget<Opacity>(
              find.ancestor(of: find.text(':'), matching: find.byType(Opacity)),
            )
            .opacity,
        1,
      );
    }
    await t.pumpWidget(const SizedBox());
  });
  testWidgets('time entrance rises 4px on the reference .35s ease', (t) async {
    await t.pumpWidget(
      host(IslandTime(now: () => DateTime(2026, 10, 13, 9, 5))),
    );
    double top() => t.getTopLeft(find.text('05')).dy;
    final start = top();
    await t.pump(const Duration(milliseconds: 175));
    final mid = top();
    await t.pumpAndSettle();
    final settled = top();
    expect(start - settled, closeTo(4, .01));
    expect(
      mid - settled,
      closeTo(4 * (1 - const Cubic(.4, 0, .2, 1).transform(.5)), .01),
    );
    await t.pumpWidget(const SizedBox());
  });
  testWidgets(
    'countdown literals use reference .sep weight 700 and .colon 900 at digit size',
    (t) async {
      final now = DateTime(2026, 10, 13, 12);
      await t.pumpWidget(
        host(
          IslandCountdown(
            value: now.add(const Duration(days: 1, seconds: 5)),
            now: () => now,
            format: 'DD 天 HH:mm',
            bordered: true,
          ),
        ),
      );
      await t.pump();
      TextStyle style(String text) =>
          t.widget<Text>(find.text(text).first).style!;
      expect(style(' 天 ').fontWeight, FontWeight.w700);
      expect(style(' 天 ').fontSize, 14);
      expect(style(':').fontWeight, FontWeight.w900);
      expect(style(':').fontSize, 26);
      final plate = t.widget<Container>(
        find
            .ancestor(
              of: find.text('0').first,
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).gradient != null,
              ),
            )
            .first,
      );
      expect(
        ((plate.decoration! as BoxDecoration).border! as Border).top.width,
        1.5,
      );
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets('wrapped Countdown surface fills its width like fit-content', (
    t,
  ) async {
    final now = DateTime(2026, 1, 1);
    Widget at(double width) => host(
      SizedBox(
        width: width,
        child: Align(
          alignment: Alignment.topLeft,
          child: IslandCountdown(
            value: now.add(const Duration(seconds: 1)),
            now: () => now,
            prefix: const Text('商店关门还有'),
          ),
        ),
      ),
    );
    await t.pumpWidget(at(1000));
    final single = t.getSize(find.byType(IslandCountdown)).width;
    expect(single, lessThan(1000), reason: 'hugs its single run');
    // Below the single-run width the content wraps and the surface takes
    // the whole available width, as the reference max-width:100% does.
    await t.pumpWidget(at(single - 20));
    expect(t.getSize(find.byType(IslandCountdown)).width, single - 20);
    final prefix = t.getRect(find.text('商店关门还有'));
    final surface = t.getRect(find.byType(IslandCountdown));
    expect(prefix.center.dx, closeTo(surface.center.dx, 1), reason: 'centred');
    await t.pumpWidget(const SizedBox());
  });
}
