import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

DateTime fixedNow() => DateTime(2026, 11, 17, 9, 30);

Future<void> pump(
  WidgetTester t,
  Widget calendar, {
  double width = 750,
  bool reduceMotion = false,
  Locale locale = const Locale('zh'),
  TextScaler textScaler = TextScaler.noScaling,
}) async {
  t.view.physicalSize = Size(width + 100, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: IslandLocalizations.supportedLocales,
      localizationsDelegates: IslandLocalizations.delegates,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width + 100, 2400),
          disableAnimations: reduceMotion,
          textScaler: textScaler,
        ),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(40),
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: width, child: calendar),
            ),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

Finder cell(String date) => find.bySemanticsLabel(
  RegExp(
    r'^\d+ 日，'
    '${RegExp.escape(date)}'
    r'(?: |$)',
  ),
);
String label(WidgetTester t, String date) =>
    t.getSemantics(cell(date)).getSemanticsData().label;
bool selected(WidgetTester t, String date) =>
    t.getSemantics(cell(date)).flagsCollection.isSelected == Tristate.isTrue;
bool focused(WidgetTester t, Finder finder) =>
    t.getSemantics(finder).flagsCollection.isFocused == Tristate.isTrue;
Finder bars(String title) =>
    find.ancestor(of: find.text(title), matching: find.byType(Positioned));
Finder get preview => find.byWidgetPredicate(
  (w) => w is CustomPaint && w.foregroundPainter is IslandDashedBorderPainter,
);
List<String> selectedCells(WidgetTester t) => [
  for (final node
      in t
          .widgetList<Semantics>(find.byType(Semantics))
          .map((w) => w.properties.label)
          .whereType<String>()
          .where((l) => RegExp(r'^\d+ 日，\d{4}-\d{2}-\d{2}').hasMatch(l))
          .toSet())
    if (selected(t, node.split('，')[1].substring(0, 10)))
      node.split('，')[1].substring(0, 10),
];

/// Tabs from the first header action into the grid; returns the day cell
/// that received focus and whether the next Tab left the grid, then returns
/// focus to that cell.
Future<(String?, bool)> tabStop(WidgetTester t, List<String> days) async {
  for (var i = 0; i < 6; i++) {
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
  }
  String? stop;
  for (final day in days) {
    if (focused(t, cell(day))) stop = day;
  }
  await t.sendKeyEvent(LogicalKeyboardKey.tab);
  await t.pump();
  final left = days.every((day) => !focused(t, cell(day)));
  await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await t.sendKeyEvent(LogicalKeyboardKey.tab);
  await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await t.pump();
  return (stop, left);
}

List<String> month(int year, int month, {int from = 1, int to = 31}) => [
  for (var d = from; d <= to; d++)
    if (DateTime(year, month, d).month == month)
      '$year-${month.toString().padLeft(2, '0')}-${d.toString().padLeft(2, '0')}',
];

Future<void> drag(
  WidgetTester t,
  List<Finder> path, {
  int buttons = kPrimaryMouseButton,
  Finder? releaseOver,
  Offset? releaseAt,
}) async {
  final gesture = await t.startGesture(
    t.getCenter(path.first),
    kind: PointerDeviceKind.mouse,
    buttons: buttons,
  );
  for (final step in path.skip(1)) {
    await gesture.moveTo(t.getCenter(step));
    await t.pump();
  }
  if (releaseOver != null) await gesture.moveTo(t.getCenter(releaseOver));
  if (releaseAt != null) await gesture.moveTo(releaseAt);
  await t.pump();
  await gesture.up();
  await t.pumpAndSettle();
}

void main() {
  group('rendering', () {
    testWidgets('month label, weekday header and a full 42-day grid', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 8, 10),
          now: fixedNow,
        ),
      );
      expect(find.text('2026年8月'), findsOneWidget);
      for (final name in ['日', '一', '二', '三', '四', '五', '六']) {
        expect(find.text(name), findsOneWidget);
      }
      expect(
        find.bySemanticsLabel(RegExp(r'^\d+ 日，\d{4}-\d{2}-\d{2}')),
        findsNWidgets(42),
      );
      expect(cell('2026-07-26'), findsOneWidget);
      expect(cell('2026-09-05'), findsOneWidget);
      expect(cell('2026-07-25'), findsNothing);
      expect(cell('2026-09-06'), findsNothing);
    });

    testWidgets('a month starting on Sunday has no previous-month days', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 3),
          now: fixedNow,
        ),
      );
      expect(cell('2026-02-28'), findsNothing);
      expect(cell('2026-03-01'), findsOneWidget);
      expect(cell('2026-04-11'), findsOneWidget);
      expect(
        t.getRect(cell('2026-03-01')).topLeft,
        t
            .getRect(find.bySemanticsLabel(RegExp(r'^\d+ 日，\d{4}-\d{2}-\d{2}')).first)
            .topLeft,
      );
    });

    testWidgets('uncontrolled default selects today and opens on it', (
      t,
    ) async {
      await pump(t, const IslandCalendar.uncontrolled(now: fixedNow));
      expect(find.text('2026年11月'), findsOneWidget);
      expect(selected(t, '2026-11-17'), isTrue);
      expect(selectedCells(t), ['2026-11-17']);
    });

    testWidgets('initialValue and controlled value drive selection', (t) async {
      await pump(
        t,
        IslandCalendar.uncontrolled(
          initialValue: DateTime(2026, 8, 10),
          month: DateTime(2026, 8),
          now: fixedNow,
        ),
      );
      expect(selectedCells(t), ['2026-08-10']);
      await pump(
        t,
        IslandCalendar(
          value: DateTime(2026, 8, 20),
          onChanged: null,
          month: DateTime(2026, 8),
          now: fixedNow,
        ),
      );
      expect(selectedCells(t), ['2026-08-20']);
    });

    testWidgets('the rhythm scales with width / 750, clamped to 0.6..2', (
      t,
    ) async {
      for (final (width, scale) in [
        (750.0, 1.0),
        (1125.0, 1.5),
        (320.0, 0.6),
        (4000.0, 2.0),
      ]) {
        await pump(
          t,
          IslandCalendar(
            value: null,
            onChanged: null,
            month: DateTime(2026, 8),
            now: fixedNow,
          ),
          width: width,
        );
        expect(
          t.getSize(cell('2026-08-10')).height,
          closeTo(104 * scale, 0.01),
          reason: '$width',
        );
        expect(
          t.getRect(cell('2026-08-02')).top - t.getRect(cell('2026-07-26')).top,
          closeTo(104 * scale, 0.01),
        );
      }
    });

    testWidgets(
      'width sets the panel width and the rhythm, within the parent',
      (t) async {
        for (final (width, actual) in [(600.0, 600.0), (900.0, 750.0)]) {
          await pump(
            t,
            IslandCalendar(
              value: null,
              onChanged: null,
              month: DateTime(2026, 8),
              width: width,
              now: fixedNow,
            ),
          );
          // Seven columns inside the border (1.5px snaps to one device pixel
          // at DPR 1) and the 8px padding.
          expect(
            t.getSize(cell('2026-08-10')).width,
            closeTo((actual - 18) / 7, 0.01),
          );
          expect(
            t.getSize(cell('2026-08-10')).height,
            closeTo(104 * actual / 750, 0.01),
            reason: '$width',
          );
        }
      },
    );

    testWidgets('the header row is the reference line-height: normal chip', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 8),
          now: fixedNow,
        ),
      );
      final chip = find
          .ancestor(of: find.text('2026年8月'), matching: find.byType(Container))
          .first;
      // padding 4 + one 15px line at the font's own metrics (1 em in the
      // test font), not the inherited body line height.
      final line = t.getSize(find.text('2026年8月')).height;
      expect(line, closeTo(15, 0.01));
      // The 16px month icon is taller than one test-font line.
      final chipHeight = 8 + (line > 16 ? line : 16);
      expect(t.getSize(chip).height, closeTo(chipHeight, 0.01));
      // Header row (the taller of the chip and the 28px arrows), 8px gap,
      // panel border (1px at DPR 1) and padding, week header.
      expect(
        t.getTopLeft(cell('2026-07-26')).dy -
            t.getTopLeft(find.byType(IslandCalendar)).dy,
        closeTo((chipHeight > 28 ? chipHeight : 28) + 8 + 1 + 8 + 32, 0.01),
      );
    });

    testWidgets(
      'the month chip line box rounds ascent and descent like Blink',
      (t) async {
        // 15px x 1.3 = 19.5px test font: ascent 14.625 -> 15 and descent
        // 4.875 -> 5, so the CSS line box is 20px (not 19.5) and the chip
        // 28px, the same rule that makes the reference zh chip 30px.
        await pump(
          t,
          IslandCalendar(
            value: null,
            onChanged: null,
            month: DateTime(2026, 8),
            now: fixedNow,
          ),
          textScaler: const TextScaler.linear(1.3),
        );
        final chip = find
            .ancestor(
              of: find.text('2026年8月'),
              matching: find.byType(Container),
            )
            .first;
        expect(t.getSize(chip).height, 8 + 20);
        // The text keeps its own line, centred in the line box, unclipped.
        expect(t.getSize(find.text('2026年8月')).height, closeTo(19.5, 0.51));
        expect(
          t.getRect(find.text('2026年8月')).center.dy,
          closeTo(t.getRect(chip).center.dy, 0.01),
        );
      },
    );

    testWidgets('event bars centre under the number band, two rows per week', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 8),
          now: fixedNow,
          events: [
            IslandCalendarEvent(
              id: 0,
              title: '晨会',
              start: DateTime(2026, 7, 26),
            ),
            IslandCalendarEvent(id: 1, title: 'A', start: DateTime(2026, 8, 3)),
            IslandCalendarEvent(id: 2, title: 'B', start: DateTime(2026, 8, 3)),
          ],
        ),
      );
      final week0 = t.getRect(cell('2026-07-26')).top;
      final week1 = t.getRect(cell('2026-08-03')).top;
      expect(t.getRect(bars('晨会')).center.dy - week0, closeTo(42 + 22, 0.01));
      expect(t.getRect(bars('A')).center.dy - week1, closeTo(42 + 22, 0.01));
      expect(t.getRect(bars('B')).center.dy - week1, closeTo(42 + 44, 0.01));
      expect(t.getRect(bars('B')).height, closeTo(17, 0.01));
      expect(t.getRect(bars('B')).bottom, lessThan(week1 + 104));
    });

    testWidgets('header actions are named and always shown', (t) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 8),
          now: fixedNow,
        ),
      );
      for (final name in ['上一年', '上个月', '下个月', '下一年', '今天']) {
        expect(find.bySemanticsLabel(name), findsOneWidget);
      }
    });

    testWidgets(
      'an overflowing header shrinks the chip and 今天 like the reference flex row',
      (t) async {
        // 300px panel in the 1em-square test font: the max-content row
        // (58 + 152 + 112 + 2 x 8 gaps = 338) overflows, the min-content row
        // (58 + 106.6 + 99 + 16 = 279.6) fits, so the reference flex row
        // shrinks instead of wrapping (as at 375 in the Gallery).
        final h = t.ensureSemantics();
        await pump(
          t,
          IslandCalendar(
            value: null,
            onChanged: null,
            month: DateTime(2026, 8),
            now: fixedNow,
          ),
          width: 300,
        );
        final actions = [
          for (final name in ['上一年', '上个月', '今天', '下个月', '下一年'])
            t.getRect(find.bySemanticsLabel(name)),
        ];
        // One toolbar row: every action is centred on the same line.
        for (final rect in actions) {
          expect(rect.center.dy, closeTo(actions.first.center.dy, 0.01));
        }
        expect(actions.last.right, closeTo(40 + 300.0, 0.01));
        // The arrow group (58) keeps its width and the 今天 group freezes at
        // its min-content (12 + 13.5 + 12 + 4 + 58 = 99.5: one 13px glyph
        // plus the host's ambient 0.5px letter spacing); the chip takes the
        // rest of the 284px after the gaps.
        final chip = find
            .ancestor(
              of: find.bySemanticsLabel('2026年8月'),
              matching: find.byType(Container),
            )
            .first;
        expect(t.getSize(chip).width, closeTo(284 - 58 - 99.5, 0.01));
        // Both texts wrap, each line in its own CSS line box (15px and 13px
        // test-font lines: ascent and descent rounded, 11 + 4 and 10 + 3).
        final chipLines = find.descendant(
          of: chip,
          matching: find.byType(Text),
        );
        expect(chipLines, findsNWidgets(2));
        expect(
          [for (final e in chipLines.evaluate()) (e.widget as Text).data]
              .join(),
          '2026年8月',
        );
        expect(find.text('今'), findsOneWidget);
        expect(find.text('天'), findsOneWidget);
        expect(t.getSize(chip).height, closeTo(8 + 15 + 15, 0.01));
        expect(actions[2].height, closeTo(8 + 13 + 13, 0.01));
        // The chip is the tallest item, so it sets the header height; the
        // week header is 32 x the scale (300 / 750 clamped to 0.6).
        expect(
          t.getTopLeft(cell('2026-07-26')).dy -
              t.getTopLeft(find.byType(IslandCalendar)).dy,
          closeTo(38 + 8 + 1 + 8 + 32 * 0.6, 0.01),
        );
        expect(t.takeException(), isNull);
        h.dispose();
      },
    );

    testWidgets('a narrow panel wraps its header instead of overflowing', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 8),
          now: fixedNow,
        ),
        width: 240,
      );
      expect(t.takeException(), isNull);
      expect(
        t.getRect(find.bySemanticsLabel('下一年')).right,
        lessThanOrEqualTo(40 + 240.0),
      );
    });
  });

  group('events', () {
    Future<void> events(
      WidgetTester t,
      List<IslandCalendarEvent> list, {
      bool showEventTime = true,
    }) => pump(
      t,
      IslandCalendar(
        value: null,
        onChanged: null,
        month: DateTime(2026, 8),
        now: fixedNow,
        showEventTime: showEventTime,
        events: list,
      ),
    );

    testWidgets('same-day events render and name the cell', (t) async {
      await events(t, [
        IslandCalendarEvent(id: 0, title: '晨会', start: DateTime(2026, 8, 10)),
        IslandCalendarEvent(id: 1, title: '评审', start: DateTime(2026, 8, 10)),
      ]);
      expect(find.text('晨会'), findsOneWidget);
      expect(find.text('评审'), findsOneWidget);
      expect(label(t, '2026-08-10'), '10 日，2026-08-10 2 项事项：晨会，评审');
      expect(label(t, '2026-08-11'), '11 日，2026-08-11');
    });

    testWidgets('a multi-day event spans columns with a seam gutter', (
      t,
    ) async {
      await events(t, [
        IslandCalendarEvent(
          id: 0,
          title: '海岛团建',
          start: DateTime(2026, 8, 12),
          end: DateTime(2026, 8, 18),
          color: IslandCalendarColor.amber,
        ),
      ]);
      final column = t.getSize(cell('2026-08-12')).width;
      final weekStart = t.getRect(cell('2026-08-09')).left;
      final first = t.getRect(bars('海岛团建').first);
      expect(first.left - weekStart, closeTo(column * 3 + 5 + 1, 0.01));
      expect(first.width, closeTo(column * 4 - 10, 0.01));
    });

    testWidgets('bars break at week boundaries and end flush at week edges', (
      t,
    ) async {
      await events(t, [
        IslandCalendarEvent(
          id: 0,
          title: '长假',
          start: DateTime(2026, 8, 5),
          end: DateTime(2026, 8, 18),
        ),
      ]);
      final rects = [
        for (final e in bars('长假').evaluate())
          t.getRect(find.byWidget(e.widget)),
      ]..sort((a, b) => a.top.compareTo(b.top));
      final column = t.getSize(cell('2026-08-10')).width;
      final left = t.getRect(cell('2026-08-09')).left;
      expect(rects, hasLength(3));
      expect(rects[0].left - left, closeTo(column * 3 + 5 + 1, 0.01));
      expect(rects[0].width, closeTo(column * 4 - 10, 0.01));
      expect(rects[1].left - left, closeTo(5, 0.01));
      expect(rects[1].width, closeTo(column * 7 - 10, 0.01));
      expect(rects[2].left - left, closeTo(5, 0.01));
      expect(rects[2].width, closeTo(column * 3 - 10, 0.01));
    });

    testWidgets('a third same-day event folds into +N', (t) async {
      await events(t, [
        for (final (i, title) in ['A', 'B', 'C', 'D'].indexed)
          IslandCalendarEvent(
            id: i,
            title: title,
            start: DateTime(2026, 8, 13),
          ),
      ]);
      expect(find.text('+2'), findsOneWidget);
      expect(
        t.getRect(cell('2026-08-13')).contains(t.getCenter(find.text('+2'))),
        isTrue,
      );
      expect(find.text('C'), findsNothing);
      expect(label(t, '2026-08-13'), '13 日，2026-08-13 4 项事项：A，B，C，D');
    });

    testWidgets('showTime prefixes HH:mm unless showEventTime is false', (
      t,
    ) async {
      final list = [
        IslandCalendarEvent(
          id: 0,
          title: '晨会',
          start: DateTime(2026, 8, 10, 9, 30),
          showTime: true,
        ),
      ];
      await events(t, list);
      expect(find.text('09:30'), findsOneWidget);
      expect(find.text('晨会'), findsOneWidget);
      await events(t, list, showEventTime: false);
      expect(find.text('09:30'), findsNothing);
      expect(find.text('晨会'), findsOneWidget);
    });

    testWidgets('only the first segment of a cross-week event shows its time', (
      t,
    ) async {
      await events(t, [
        IslandCalendarEvent(
          id: 0,
          title: '团建',
          start: DateTime(2026, 8, 5, 8),
          end: DateTime(2026, 8, 18),
          showTime: true,
        ),
      ]);
      expect(find.text('团建'), findsNWidgets(3));
      expect(find.text('08:00'), findsOneWidget);
      expect(
        find.ancestor(
          of: find.text('08:00'),
          matching: find.byType(Positioned),
        ),
        findsOneWidget,
      );
      expect(
        t.getRect(find.text('08:00')).top,
        lessThan(t.getRect(cell('2026-08-09')).top),
      );
    });

    testWidgets('a multi-day event does not fold a same-week day', (t) async {
      await events(t, [
        IslandCalendarEvent(
          id: 0,
          title: '团建',
          start: DateTime(2026, 8, 12),
          end: DateTime(2026, 8, 18),
        ),
        IslandCalendarEvent(id: 1, title: '晨会', start: DateTime(2026, 8, 13)),
      ]);
      expect(find.text('晨会'), findsOneWidget);
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('labels skip empty titles and mark collapsed duplicates', (
      t,
    ) async {
      await events(t, [
        IslandCalendarEvent(id: 0, title: '0', start: DateTime(2026, 8, 10)),
        IslandCalendarEvent(id: 1, title: '周会', start: DateTime(2026, 8, 11)),
        IslandCalendarEvent(id: 2, title: '周会', start: DateTime(2026, 8, 11)),
        IslandCalendarEvent(id: 3, title: '', start: DateTime(2026, 8, 12)),
      ]);
      expect(label(t, '2026-08-10'), '10 日，2026-08-10 1 项事项：0');
      expect(label(t, '2026-08-11'), '11 日，2026-08-11 2 项事项：周会 等');
      expect(label(t, '2026-08-12'), '12 日，2026-08-12 1 项事项');
    });

    testWidgets('bars keep their identity when an event is inserted first', (
      t,
    ) async {
      final keep = IslandCalendarEvent(
        id: 'keep',
        title: 'KEEP',
        start: DateTime(2026, 8, 20),
      );
      await events(t, [keep]);
      final before = t.renderObject(find.text('KEEP'));
      await events(t, [
        IslandCalendarEvent(
          id: 'new',
          title: 'NEW',
          start: DateTime(2026, 8, 2),
        ),
        keep,
      ]);
      expect(find.text('NEW'), findsOneWidget);
      expect(identical(t.renderObject(find.text('KEEP')), before), isTrue);
    });

    testWidgets('events outside the 42 days are neither drawn nor counted', (
      t,
    ) async {
      await events(t, [
        IslandCalendarEvent(
          id: 0,
          title: '上季度总结',
          start: DateTime(2026, 5, 4),
          end: DateTime(2026, 5, 6),
        ),
        IslandCalendarEvent(
          id: 1,
          title: '下季度规划',
          start: DateTime(2026, 11, 2),
        ),
        IslandCalendarEvent(
          id: 2,
          title: '跨过整月',
          start: DateTime(2026, 7, 1),
          end: DateTime(2026, 9, 30),
        ),
      ]);
      expect(find.text('上季度总结'), findsNothing);
      expect(find.text('下季度规划'), findsNothing);
      expect(find.text('跨过整月'), findsNWidgets(6));
      expect(label(t, '2026-07-26'), '26 日，2026-07-26 1 项事项：跨过整月');
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('an end before the start is a one-day event', (t) async {
      await events(t, [
        IslandCalendarEvent(
          id: 0,
          title: '倒置',
          start: DateTime(2026, 8, 12),
          end: DateTime(2026, 8, 3),
        ),
      ]);
      expect(find.text('倒置'), findsOneWidget);
      expect(label(t, '2026-08-12'), '12 日，2026-08-12 1 项事项：倒置');
      expect(label(t, '2026-08-11'), '11 日，2026-08-11');
    });
  });

  group('interaction', () {
    testWidgets('tapping a day reports it and updates uncontrolled selection', (
      t,
    ) async {
      final changes = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          month: DateTime(2026, 8),
          onChanged: changes.add,
          now: fixedNow,
        ),
      );
      await t.tap(cell('2026-08-10'));
      await t.pumpAndSettle();
      expect(changes, [DateTime(2026, 8, 10)]);
      expect(selectedCells(t), ['2026-08-10']);
    });

    testWidgets('controlled value waits for the parent', (t) async {
      final changes = <DateTime>[];
      var value = DateTime(2026, 8, 10);
      await pump(
        t,
        StatefulBuilder(
          builder: (context, setState) => IslandCalendar(
            value: value,
            month: DateTime(2026, 8),
            now: fixedNow,
            onChanged: (next) {
              changes.add(next);
              if (next.day != 21) setState(() => value = next);
            },
          ),
        ),
      );
      await t.tap(cell('2026-08-20'));
      await t.pumpAndSettle();
      expect(selectedCells(t), ['2026-08-20']);
      await t.tap(cell('2026-08-21'));
      await t.pumpAndSettle();
      expect(changes, [DateTime(2026, 8, 20), DateTime(2026, 8, 21)]);
      expect(selectedCells(t), ['2026-08-20']);
    });

    testWidgets('今天 selects today and follows it with an uncontrolled month', (
      t,
    ) async {
      final changes = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          initialMonth: DateTime(2020, 1),
          onChanged: changes.add,
          now: fixedNow,
        ),
      );
      await t.tap(find.text('今天'));
      await t.pumpAndSettle();
      expect(changes, [DateTime(2026, 11, 17)]);
      expect(find.text('2026年11月'), findsOneWidget);
      expect(selectedCells(t), ['2026-11-17']);
    });

    testWidgets('a controlled month only receives the 今天 month request', (
      t,
    ) async {
      final months = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          month: DateTime(2020, 1),
          onMonthChanged: months.add,
          now: fixedNow,
        ),
      );
      await t.tap(find.text('今天'));
      await t.pumpAndSettle();
      expect(months, [DateTime(2026, 11)]);
      expect(find.text('2020年1月'), findsOneWidget);
    });

    testWidgets('uncontrolled month arrows change month and year', (t) async {
      await pump(
        t,
        IslandCalendar.uncontrolled(
          initialMonth: DateTime(2026, 8),
          initialValue: DateTime(2026, 8, 10),
          now: fixedNow,
        ),
      );
      for (final (action, shown) in [
        ('下个月', '2026年9月'),
        ('下一年', '2027年9月'),
        ('上个月', '2027年8月'),
        ('上一年', '2026年8月'),
      ]) {
        await t.tap(find.bySemanticsLabel(action));
        await t.pumpAndSettle();
        expect(find.text(shown), findsOneWidget, reason: action);
      }
      expect(selectedCells(t), ['2026-08-10']);
    });

    testWidgets('controlled month arrows request months from the parent', (
      t,
    ) async {
      final months = <DateTime>[];
      var month = DateTime(2026, 8);
      await pump(
        t,
        StatefulBuilder(
          builder: (context, setState) => IslandCalendar.uncontrolled(
            month: month,
            now: fixedNow,
            onMonthChanged: (next) {
              months.add(next);
              setState(() => month = next);
            },
          ),
        ),
      );
      for (final (action, shown) in [
        ('下个月', '2026年9月'),
        ('上个月', '2026年8月'),
        ('下一年', '2027年8月'),
        ('上一年', '2026年8月'),
      ]) {
        await t.tap(find.bySemanticsLabel(action));
        await t.pumpAndSettle();
        expect(find.text(shown), findsOneWidget, reason: action);
      }
      expect(months, [
        DateTime(2026, 9),
        DateTime(2026, 8),
        DateTime(2027, 8),
        DateTime(2026, 8),
      ]);
    });

    testWidgets('selecting a neighbouring-month day requests that month', (
      t,
    ) async {
      final months = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          month: DateTime(2026, 8),
          onMonthChanged: months.add,
          now: fixedNow,
        ),
      );
      await t.tap(cell('2026-09-01'));
      await t.pumpAndSettle();
      expect(months, [DateTime(2026, 9)]);
    });

    testWidgets(
      'an uncontrolled month follows a neighbouring-month selection',
      (t) async {
        await pump(
          t,
          IslandCalendar.uncontrolled(
            initialMonth: DateTime(2026, 8),
            now: fixedNow,
          ),
        );
        await t.tap(cell('2026-07-28'));
        await t.pumpAndSettle();
        expect(find.text('2026年7月'), findsOneWidget);
        expect(selectedCells(t), ['2026-07-28']);
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump();
        final (stop, left) = await tabStop(t, month(2026, 7));
        expect(stop, '2026-07-28');
        expect(left, isTrue);
      },
    );

    testWidgets('hover outranks the today and neighbouring-month digits', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: DateTime(2026, 11, 20),
          onChanged: (_) {},
          month: DateTime(2026, 11),
          now: fixedNow,
        ),
        reduceMotion: true,
      );
      TextStyle digit(String date) => t
          .widget<RichText>(
            find.descendant(of: cell(date), matching: find.byType(RichText)),
          )
          .text
          .style!;
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      for (final (date, idle, idleWeight) in [
        ('2026-11-17', IslandTokens.light.link, FontWeight.w700),
        ('2026-12-05', IslandTokens.light.muted, FontWeight.w400),
        ('2026-11-10', const Color(0xff725d42), FontWeight.w500),
      ]) {
        await mouse.moveTo(Offset.zero);
        await t.pump();
        expect(digit(date).color, idle, reason: date);
        expect(digit(date).fontWeight, idleWeight, reason: date);
        await mouse.moveTo(t.getCenter(cell(date)));
        await t.pump();
        // Reference `.cell:hover .dayNumber` #5a4530 / 700.
        expect(digit(date).color, const Color(0xff5a4530), reason: date);
        expect(digit(date).fontWeight, FontWeight.w700, reason: date);
      }
      // The selected digit outranks hover.
      await mouse.moveTo(t.getCenter(cell('2026-11-20')));
      await t.pump();
      expect(digit('2026-11-20').color, IslandTokens.light.onLeaf);
    });

    testWidgets('reduced motion settles hover without scheduling frames', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: null,
          onChanged: null,
          month: DateTime(2026, 8),
          now: fixedNow,
        ),
        reduceMotion: true,
      );
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: t.getCenter(cell('2026-08-10')));
      await t.pump();
      await t.pump();
      expect(t.binding.hasScheduledFrame, isFalse);
    });
  });

  group('keyboard', () {
    testWidgets('a controlled value outside the panel clamps to one tab stop', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: DateTime(2026, 5, 10),
          onChanged: null,
          initialMonth: DateTime(2026, 3),
          now: fixedNow,
        ),
      );
      final (stop, left) = await tabStop(t, [
        ...month(2026, 3),
        ...month(2026, 4, to: 11),
      ]);
      expect(stop, '2026-04-11');
      expect(left, isTrue);
      expect(selectedCells(t), ['2026-04-11']);
    });

    testWidgets('without initialMonth a controlled value picks the month', (
      t,
    ) async {
      await pump(
        t,
        IslandCalendar(
          value: DateTime(2026, 12, 31),
          onChanged: null,
          now: fixedNow,
        ),
      );
      expect(find.text('2026年12月'), findsOneWidget);
      final (stop, _) = await tabStop(t, month(2026, 12));
      expect(stop, '2026-12-31');
    });

    testWidgets('a controlled value moved outside the grid keeps one stop', (
      t,
    ) async {
      Widget at(DateTime value) => IslandCalendar(
        value: value,
        onChanged: null,
        month: DateTime(2026, 10),
        now: fixedNow,
      );
      await pump(t, at(DateTime(2026, 10, 15)));
      expect(selectedCells(t), ['2026-10-15']);
      await pump(t, at(DateTime(2026, 12, 31)));
      expect(selectedCells(t), ['2026-11-07']);
      final (stop, left) = await tabStop(t, [
        ...month(2026, 10),
        ...month(2026, 11, to: 7),
      ]);
      expect(stop, '2026-11-07');
      expect(left, isTrue);
    });

    testWidgets('an ignored month request keeps a single tab stop', (t) async {
      final months = <DateTime>[];
      await pump(
        t,
        IslandCalendar(
          value: DateTime(2026, 10, 28),
          onChanged: null,
          month: DateTime(2026, 10),
          onMonthChanged: months.add,
          now: fixedNow,
        ),
      );
      final days = [...month(2026, 10), ...month(2026, 11, to: 7)];
      final (stop, _) = await tabStop(t, days);
      expect(stop, '2026-10-28');
      for (var i = 0; i < 12; i++) {
        await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await t.pump();
      }
      await t.pump();
      expect(months, isNotEmpty);
      expect(focused(t, cell('2026-11-07')), isTrue);
      final (again, left) = await tabStop(t, days);
      expect(again, '2026-11-07');
      expect(left, isTrue);
    });

    testWidgets('arrows move focus with the cursor; Enter selects it once', (
      t,
    ) async {
      final changes = <DateTime>[];
      final months = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          initialValue: DateTime(2026, 8, 10),
          month: DateTime(2026, 8),
          onChanged: changes.add,
          onMonthChanged: months.add,
          now: fixedNow,
        ),
      );
      final (stop, _) = await tabStop(t, month(2026, 8));
      expect(stop, '2026-08-10');
      for (final (key, day) in [
        (LogicalKeyboardKey.arrowRight, '2026-08-11'),
        (LogicalKeyboardKey.arrowDown, '2026-08-18'),
        (LogicalKeyboardKey.arrowUp, '2026-08-11'),
        (LogicalKeyboardKey.arrowLeft, '2026-08-10'),
        (LogicalKeyboardKey.arrowRight, '2026-08-11'),
      ]) {
        await t.sendKeyEvent(key);
        await t.pumpAndSettle();
        expect(focused(t, cell(day)), isTrue, reason: day);
      }
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(changes, [DateTime(2026, 8, 11)]);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect(changes, [DateTime(2026, 8, 11), DateTime(2026, 8, 12)]);
      expect(months, isEmpty);
    });

    testWidgets('leaving the month by keyboard requests the next month', (
      t,
    ) async {
      final months = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          initialValue: DateTime(2026, 8, 31),
          month: DateTime(2026, 8),
          onMonthChanged: months.add,
          now: fixedNow,
        ),
      );
      await tabStop(t, month(2026, 8));
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pumpAndSettle();
      expect(months, [DateTime(2026, 9)]);
    });

    testWidgets('PageUp and PageDown change month', (t) async {
      final months = <DateTime>[];
      var month0 = DateTime(2026, 8);
      await pump(
        t,
        StatefulBuilder(
          builder: (context, setState) => IslandCalendar.uncontrolled(
            initialValue: DateTime(2026, 8, 10),
            month: month0,
            now: fixedNow,
            onMonthChanged: (next) {
              months.add(next);
              setState(() => month0 = next);
            },
          ),
        ),
      );
      await tabStop(t, month(2026, 8));
      await t.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await t.pumpAndSettle();
      expect(find.text('2026年9月'), findsOneWidget);
      expect(focused(t, cell('2026-09-10')), isTrue);
      await t.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await t.pumpAndSettle();
      expect(find.text('2026年8月'), findsOneWidget);
      expect(months, [DateTime(2026, 9), DateTime(2026, 8)]);
    });
  });

  group('drag to create', () {
    Future<List<DateTimeRange>> creating(
      WidgetTester t, {
      List<IslandCalendarEvent> events = const [],
      ValueChanged<DateTime>? onChanged,
    }) async {
      final created = <DateTimeRange>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          month: DateTime(2026, 8),
          now: fixedNow,
          events: events,
          onChanged: onChanged,
          onCreateEvent: created.add,
        ),
      );
      return created;
    }

    testWidgets('without onCreateEvent a drag shows no preview', (t) async {
      await pump(
        t,
        IslandCalendar.uncontrolled(month: DateTime(2026, 8), now: fixedNow),
      );
      final gesture = await t.startGesture(
        t.getCenter(cell('2026-08-10')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveTo(t.getCenter(cell('2026-08-13')));
      await t.pump();
      expect(preview, findsNothing);
      await gesture.up();
    });

    testWidgets('a drag reports the ordered range on release', (t) async {
      final created = await creating(t);
      await drag(t, [
        cell('2026-08-10'),
        cell('2026-08-11'),
        cell('2026-08-12'),
      ]);
      await drag(t, [cell('2026-08-14'), cell('2026-08-11')]);
      expect(created, [
        DateTimeRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 12)),
        DateTimeRange(start: DateTime(2026, 8, 11), end: DateTime(2026, 8, 14)),
      ]);
      expect(preview, findsNothing);
    });

    testWidgets('the preview is a dashed bar', (t) async {
      await creating(t);
      final gesture = await t.startGesture(
        t.getCenter(cell('2026-08-10')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveTo(t.getCenter(cell('2026-08-12')));
      await t.pump();
      expect(preview, findsOneWidget);
      await gesture.up();
      await t.pumpAndSettle();
    });

    testWidgets('a click only selects', (t) async {
      final changes = <DateTime>[];
      final created = await creating(t, onChanged: changes.add);
      await t.tap(cell('2026-08-10'), kind: PointerDeviceKind.mouse);
      await t.pumpAndSettle();
      expect(created, isEmpty);
      expect(changes, [DateTime(2026, 8, 10)]);
    });

    testWidgets('a secondary-button drag never starts', (t) async {
      final created = await creating(t);
      final gesture = await t.startGesture(
        t.getCenter(cell('2026-08-10')),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await gesture.moveTo(t.getCenter(cell('2026-08-12')));
      await t.pump();
      expect(preview, findsNothing);
      await gesture.up();
      await t.pumpAndSettle();
      expect(created, isEmpty);
    });

    testWidgets('releasing over the month header still creates', (t) async {
      final created = await creating(t);
      await drag(t, [
        cell('2026-08-10'),
        cell('2026-08-12'),
      ], releaseOver: find.text('2026年8月'));
      expect(created, [
        DateTimeRange(start: DateTime(2026, 8, 10), end: DateTime(2026, 8, 12)),
      ]);
    });

    testWidgets('releasing outside the panel cancels', (t) async {
      final created = await creating(t);
      await drag(t, [
        cell('2026-08-10'),
        cell('2026-08-12'),
      ], releaseAt: const Offset(10, 10));
      expect(created, isEmpty);
      expect(preview, findsNothing);
    });

    testWidgets('the preview never folds into +N', (t) async {
      await creating(
        t,
        events: [
          IslandCalendarEvent(
            id: 1,
            title: 'E1',
            start: DateTime(2026, 8, 10),
            end: DateTime(2026, 8, 16),
          ),
          IslandCalendarEvent(
            id: 2,
            title: 'E2',
            start: DateTime(2026, 8, 10),
            end: DateTime(2026, 8, 16),
          ),
        ],
      );
      expect(find.textContaining('+'), findsNothing);
      final gesture = await t.startGesture(
        t.getCenter(cell('2026-08-12')),
        kind: PointerDeviceKind.mouse,
      );
      await gesture.moveTo(t.getCenter(cell('2026-08-13')));
      await t.pump();
      await gesture.moveTo(
        t.getRect(cell('2026-09-05')).bottomRight + const Offset(-20, 30),
      );
      await t.pump();
      expect(find.textContaining('+'), findsNothing);
      await gesture.up();
      await t.pumpAndSettle();
    });
  });
}
