import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

Finder label(String text) =>
    find.bySemanticsLabel(RegExp('^${RegExp.escape(text)}(?:\\n|\$)'));

// Monday 2026-06-08 09:30, the reference Time test clock.
DateTime monday() => DateTime(2026, 6, 8, 9, 30);

Color? ink(WidgetTester t, String text) => t
    .widget<RichText>(
      find.descendant(of: find.text(text), matching: find.byType(RichText)),
    )
    .text
    .style
    ?.color;

void main() {
  test('time value formats core tokens on the 2000-01-01 anchor', () {
    const afternoon = IslandTimeValue(13, 5, 9);
    expect(afternoon.format(), '13:05:09');
    expect(afternoon.format('hh:mm:ss a'), '01:05:09 pm');
    expect(afternoon.format('H:m:s'), '13:5:9');
    expect(afternoon.format('[HH] HH'), 'HH 13');
    expect(afternoon.format('YYYY-MM-DD ddd'), '2000-01-01 Sat');
    expect(const IslandTimeValue(0, 0).format('h A'), '12 AM');
    expect(const IslandTimeValue(9, 8, 7).format('h:mm A'), '9:08 AM');
    expect(const IslandTimeValue(9, 8, 7).format('Q Do'), 'Q 1o');
  });

  testWidgets('date-picker format expands core tokens with English names', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        IslandDatePicker(
          value: DateTime(2026, 8, 10),
          onChanged: null,
          format: 'ddd, YYYY/MM/DD HH:mm',
        ),
      ),
    );
    expect(find.text('Mon, 2026/08/10 00:00'), findsOneWidget);
    await t.pumpWidget(
      host(
        IslandDatePicker(
          value: DateTime(2026, 8, 10),
          onChanged: null,
          format: '[YYYY] YYYY年M月D日 dddd MMM Q',
        ),
      ),
    );
    expect(find.text('YYYY 2026年8月10日 Monday Aug Q'), findsOneWidget);
  });

  testWidgets('a month starting on Sunday has no previous-month days', (
    t,
  ) async {
    await t.pumpWidget(
      host(IslandDatePicker(value: DateTime(2026, 2, 15), onChanged: null)),
    );
    await t.tap(find.text('2026-02-15'));
    await t.pumpAndSettle();
    expect(label('2026年2月1日'), findsWidgets);
    expect(label('2026年1月31日'), findsNothing);
    expect(label('2026年3月14日'), findsWidgets);
  });

  testWidgets('time-picker format renders tokens and escaped literals', (
    t,
  ) async {
    for (final (format, text) in [
      ('h:mm A', '9:08 AM'),
      ('[此刻] HH:mm', '此刻 09:08'),
    ]) {
      await t.pumpWidget(
        host(
          IslandTimePicker(
            value: const IslandTimeValue(9, 8, 7),
            onChanged: (_) {},
            format: format,
          ),
        ),
      );
      expect(find.text(text), findsOneWidget);
    }
  });

  testWidgets('an escaped ss does not show the seconds column', (t) async {
    for (final (format, seconds) in [
      ('HH:mm:ss', true),
      ('HH:mm [ss]', false),
    ]) {
      await t.pumpWidget(
        host(
          IslandTimePicker(
            key: ValueKey(format),
            value: const IslandTimeValue(9, 8, 7),
            onChanged: (_) {},
            format: format,
          ),
        ),
      );
      await t.tap(find.textContaining('09:08'));
      await t.pumpAndSettle();
      expect(find.text('时'), findsOneWidget, reason: format);
      expect(
        find.text('秒'),
        seconds ? findsOneWidget : findsNothing,
        reason: format,
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    }
  });

  testWidgets('time weekday and date follow formats and locale', (t) async {
    Future<void> show(IslandTime time) async {
      await t.pumpWidget(host(time));
      await t.pump();
    }

    await show(const IslandTime(now: monday));
    expect(find.text('MONDAY'), findsOneWidget);
    expect(find.text('Jun 8'), findsOneWidget);
    await show(const IslandTime(now: monday, locale: IslandTimeLocale.zhCn));
    expect(find.text('星期一'), findsOneWidget);
    expect(find.text('6月8日'), findsOneWidget);
    await show(
      const IslandTime(
        now: monday,
        weekdayFormat: 'ddd',
        dateFormat: 'YYYY/MM/DD',
      ),
    );
    expect(find.text('MON'), findsOneWidget);
    expect(find.text('2026/06/08'), findsOneWidget);
    await show(
      const IslandTime(
        now: monday,
        locale: IslandTimeLocale.zhCn,
        dateFormat: 'YYYY年M月D日',
      ),
    );
    expect(find.text('2026年6月8日'), findsOneWidget);
    await show(
      const IslandTime(
        now: monday,
        variant: IslandTimeVariant.game,
        locale: IslandTimeLocale.zhCn,
        weekdayFormat: 'ddd',
        dateFormat: 'YYYY/MM/DD',
      ),
    );
    expect(find.text('周一'), findsOneWidget);
    expect(find.text('2026/06/08'), findsOneWidget);
    expect(
      t.getSemantics(find.byType(IslandTime)).value,
      '09:30 周一 2026/06/08',
    );
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('both clocks use the reference 4.0.0 #8b7355 ink', (t) async {
    for (final variant in IslandTimeVariant.values) {
      await t.pumpWidget(host(IslandTime(now: monday, variant: variant)));
      expect(ink(t, '09'), const Color(0xff8b7355), reason: '$variant');
      expect(ink(t, '30'), const Color(0xff8b7355), reason: '$variant');
    }
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('game variant is the reference vertical HUD', (t) async {
    await t.pumpWidget(
      host(const IslandTime(now: monday, variant: IslandTimeVariant.game)),
    );
    await t.pumpAndSettle();
    final root = t.getRect(find.byType(IslandTime));
    final hour = t.getRect(find.text('09'));
    final monthDay = t.getRect(find.text('Jun 8'));
    final weekday = find.text('Monday');
    expect(weekday, findsOneWidget, reason: 'not upper-cased');
    final pill = find.ancestor(
      of: weekday,
      matching: find.byWidgetPredicate(
        (w) =>
            w is Container &&
            (w.decoration as BoxDecoration?)?.color == const Color(0xfffffbe7),
      ),
    );
    final pillRect = t.getRect(pill);
    final rule = find.descendant(
      of: find.byType(IslandTime),
      matching: find.byWidgetPredicate(
        (w) =>
            w is CustomPaint && w.painter.runtimeType.toString() == '_GameRule',
      ),
    );
    final ruleRect = t.getRect(rule);

    // No card: 50px padding around content, no surface decoration.
    expect(
      find.descendant(
        of: find.byType(IslandTime),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Container &&
              (w.decoration as BoxDecoration?)?.boxShadow != null,
        ),
      ),
      findsNothing,
    );
    expect(hour.top - root.top, 50);
    expect(
      root.bottom -
          (monthDay.bottom > pillRect.bottom
              ? monthDay.bottom
              : pillRect.bottom),
      50,
    );
    expect(ruleRect.width, root.width - 100);
    expect(ruleRect.left - root.left, 50);
    // Clock 40px, 8px gap, 2px rule, 5px gap, then the date row.
    expect(hour.height, 40);
    expect(ruleRect.top - hour.bottom, 8);
    expect(ruleRect.height, 2);
    expect(
      (monthDay.top < pillRect.top ? monthDay.top : pillRect.top) -
          ruleRect.bottom,
      5,
    );
    expect(pillRect.height, 27);
    expect(pillRect.left - monthDay.right, 20);
    expect(monthDay.center.dy, closeTo(pillRect.center.dy, .01));
    expect(t.widget<Text>(find.text('Jun 8')).style!.fontSize, 22);
    expect(t.widget<Text>(weekday).style!.fontSize, 15);
    expect(ink(t, 'Jun 8'), const Color(0xff8b7355));
    expect(ink(t, 'Monday'), const Color(0xff8b7355));
    // The decorative rule overhangs the content by 2.5px on each side.
    expect(
      rule,
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          Rect.fromLTWH(-2.5, 0, ruleRect.width + 5, 2),
          const Radius.circular(2),
        ),
        color: const Color(0x599f927d),
      ),
    );

    await t.pumpWidget(host(const IslandTime(now: monday)));
    expect(rule, findsNothing);
    await t.pumpWidget(const SizedBox());
  });
}
