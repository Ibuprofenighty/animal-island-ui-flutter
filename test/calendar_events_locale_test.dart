import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'calendar_test.dart' show cell, fixedNow, label, preview, pump;

Color? cellFill(WidgetTester t, String date) {
  final container = t.widget<AnimatedContainer>(
    find
        .descendant(of: cell(date), matching: find.byType(AnimatedContainer))
        .first,
  );
  return (container.decoration as BoxDecoration?)?.color;
}

void main() {
  testWidgets(
    'an event bar lets taps, hover and the drag cursor reach its day',
    (t) async {
      final changes = <DateTime>[];
      await pump(
        t,
        IslandCalendar.uncontrolled(
          month: DateTime(2026, 8),
          now: fixedNow,
          onChanged: changes.add,
          onCreateEvent: (_) {},
          events: [
            IslandCalendarEvent(
              id: 1,
              title: '集市',
              start: DateTime(2026, 8, 12),
            ),
          ],
        ),
      );
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(
        t.getTopLeft(cell('2026-08-13')) + const Offset(60, 20),
      );
      await t.pumpAndSettle();
      final hoverFill = cellFill(t, '2026-08-13');
      expect(hoverFill, isNotNull);

      await mouse.moveTo(t.getCenter(find.text('集市')));
      await t.pumpAndSettle();
      expect(cellFill(t, '2026-08-12'), hoverFill);
      expect(cellFill(t, '2026-08-13'), isNull);
      expect(
        RendererBinding.instance.mouseTracker.debugDeviceActiveCursor(1),
        SystemMouseCursors.precise,
      );

      await t.tap(find.text('集市'), kind: PointerDeviceKind.mouse);
      await t.pumpAndSettle();
      expect(changes, [DateTime(2026, 8, 12)]);
    },
  );

  testWidgets('a pointer cancel during a drag discards the range', (t) async {
    final created = <DateTimeRange>[];
    await pump(
      t,
      IslandCalendar.uncontrolled(
        month: DateTime(2026, 8),
        now: fixedNow,
        onCreateEvent: created.add,
      ),
    );
    final gesture = await t.startGesture(
      t.getCenter(cell('2026-08-10')),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveTo(t.getCenter(cell('2026-08-12')));
    await t.pump();
    expect(preview, findsOneWidget);
    await gesture.cancel();
    await t.pumpAndSettle();
    expect(created, isEmpty);
    expect(preview, findsNothing);
  });

  testWidgets('events bucket by their own calendar fields, UTC included', (
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
            id: 1,
            title: '晚班',
            start: DateTime.utc(2026, 8, 12, 23, 30),
            end: DateTime.utc(2026, 8, 13, 1),
            showTime: true,
          ),
        ],
      ),
    );
    expect(label(t, '2026-08-12'), '12 日，2026-08-12 1 项事项：晚班');
    expect(label(t, '2026-08-13'), '13 日，2026-08-13 1 项事项：晚班');
    expect(label(t, '2026-08-14'), '14 日，2026-08-14');
    expect(find.text('23:30'), findsOneWidget);
  });

  testWidgets('English chrome comes from IslandLocalizations', (t) async {
    await pump(
      t,
      IslandCalendar(
        value: DateTime(2026, 8, 12),
        onChanged: (_) {},
        now: fixedNow,
        events: [
          IslandCalendarEvent(
            id: 1,
            title: 'Market',
            start: DateTime(2026, 8, 12),
          ),
          IslandCalendarEvent(
            id: 2,
            title: 'Market',
            start: DateTime(2026, 8, 12),
          ),
          IslandCalendarEvent(
            id: 3,
            title: 'Swim',
            start: DateTime(2026, 8, 13),
          ),
        ],
      ),
      locale: const Locale('en'),
    );
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    for (final name in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']) {
      expect(find.text(name), findsOneWidget);
    }
    for (final name in [
      'Previous year',
      'Previous month',
      'Next month',
      'Next year',
    ]) {
      expect(find.bySemanticsLabel(name), findsOneWidget);
    }
    String english(String date) => t
        .getSemantics(find.bySemanticsLabel(RegExp('^\\d+, $date(?:,|\$)')))
        .getSemanticsData()
        .label;
    expect(english('2026-08-12'), '12, 2026-08-12, 2 events: Market and more');
    expect(english('2026-08-13'), '13, 2026-08-13, 1 event: Swim');
    expect(english('2026-08-14'), '14, 2026-08-14');
    expect(find.text('今天'), findsNothing);
    expect(find.text('2026年8月'), findsNothing);
  });
}
