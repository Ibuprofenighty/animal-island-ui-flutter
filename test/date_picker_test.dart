import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);
Future<void> choose(WidgetTester t, String label) async {
  await t.tap(
    find
        .bySemanticsLabel(RegExp('^${RegExp.escape(label)}(?:\\n|\u0024)'))
        .first,
  );
  await t.pumpAndSettle();
}

void main() {
  testWidgets('popup uses overlay bounds rather than trigger MediaQuery size', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: MediaQuery(
              data: const MediaQueryData(size: Size(320, 300)),
              child: Align(
                alignment: Alignment.topLeft,
                child: IslandDatePicker.uncontrolled(
                  initialValue: DateTime(2026, 8, 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    final trigger = t.getRect(find.byType(IslandDatePicker));
    await choose(t, '选择日期');
    final confirm = t.getRect(find.text('确定'));
    expect(confirm.top, greaterThan(trigger.top + 40));
    expect(confirm.bottom, lessThanOrEqualTo(600));
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'single preview, cancellation, rejected controlled commit and independent clear',
    (t) async {
      final values = <DateTime?>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await t.pumpWidget(
        host(
          IslandDatePicker(
            value: DateTime(2026, 8, 10),
            onChanged: values.add,
            focusNode: focus,
            allowClear: true,
          ),
        ),
      );
      await choose(t, '选择日期');
      await choose(t, '2026年8月12日');
      expect(find.text('2026-08-12'), findsOneWidget);
      expect(values, isEmpty);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('2026-08-10'), findsOneWidget);
      await choose(t, '选择日期');
      await choose(t, '2026年8月13日');
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(values, [DateTime(2026, 8, 13)]);
      expect(find.text('2026-08-10'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      await choose(t, '清除日期');
      expect(values.last, isNull);
      expect(find.text('确定'), findsNothing);
      expect(find.text('2026-08-10'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(host(TextField(focusNode: focus)));
      focus.requestFocus(); // Borrower did not dispose it.
      await t.pump();
      expect(focus.hasFocus, isTrue);
    },
  );
  testWidgets(
    'range previews endpoints, incomplete confirmation does not emit, earlier date replaces start',
    (t) async {
      final values = <DateTimeRange?>[];
      await t.pumpWidget(
        host(
          IslandDatePicker.rangeUncontrolled(
            initialValue: DateTimeRange(
              start: DateTime(2026, 8, 10),
              end: DateTime(2026, 8, 20),
            ),
            onChanged: values.add,
          ),
        ),
      );
      await choose(t, '选择日期');
      await choose(t, '2026年8月12日');
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(values, isEmpty);
      await choose(t, '选择日期');
      await choose(t, '2026年8月12日');
      await choose(t, '2026年8月10日');
      await choose(t, '2026年8月18日');
      expect(values, isEmpty);
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(
        values.single,
        DateTimeRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 18)),
      );
      expect(find.text('2026-08-18'), findsOneWidget);
    },
  );
  testWidgets(
    'disabled dates and Today cannot commit; controlled open rejection remains visible',
    (t) async {
      final values = <DateTime?>[], opens = <bool>[];
      await t.pumpWidget(
        host(
          IslandDatePicker(
            value: null,
            onChanged: values.add,
            open: true,
            onOpenChanged: opens.add,
            now: () => DateTime(2026, 8, 1),
            disabledDate: (d) => d.weekday == 6 || d.weekday == 7,
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('今天'));
      await t.pumpAndSettle();
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(values, isEmpty);
      expect(opens, [false]);
      expect(find.text('确定'), findsOneWidget);
      await choose(t, '2026年8月3日');
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(values, [DateTime(2026, 8, 3)]);
      expect(find.text('确定'), findsOneWidget);
    },
  );
  testWidgets(
    'year to month to leap-day navigation and keyboard selection are calendar based',
    (t) async {
      final values = <DateTime?>[];
      await t.pumpWidget(
        host(
          IslandDatePicker.uncontrolled(
            initialValue: DateTime(2024, 2, 28),
            onChanged: values.add,
          ),
        ),
      );
      await choose(t, '选择日期');
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(find.text('2024-02-29'), findsOneWidget);
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(values.single, DateTime(2024, 2, 29));
      await choose(t, '选择日期');
      await t.tap(find.text('2024年2月'));
      await t.pumpAndSettle();
      await choose(t, '2025年');
      await choose(t, '3月');
      expect(find.text('2025年3月'), findsOneWidget);
      await t.tapAt(const Offset(700, 500));
      await t.pumpAndSettle();
      expect(find.text('确定'), findsNothing);
    },
  );
  testWidgets(
    'month preview normalizes day and formatter does not replace output twice',
    (t) async {
      final values = <DateTime?>[];
      await t.pumpWidget(
        host(
          IslandDatePicker.uncontrolled(
            initialValue: DateTime(2026, 8, 15),
            mode: IslandDatePickerMode.month,
            format: 'YYYY/MM/M/DD/D',
            onChanged: values.add,
          ),
        ),
      );
      await choose(t, '选择日期');
      await choose(t, '9月');
      expect(values, isEmpty);
      expect(find.text('2026/09/9/01/1'), findsOneWidget);
      await t.tap(find.text('确定'));
      await t.pumpAndSettle();
      expect(values.single, DateTime(2026, 9));
    },
  );
}
