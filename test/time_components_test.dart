import 'package:flutter/material.dart';
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
}
