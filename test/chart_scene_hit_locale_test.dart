import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_test.dart';

IslandChartData twoSeries() => IslandChartData.column(
  categories: const ['一月', '二月', '三月'],
  series: [
    IslandChartSeries.values('甲', const [12, 30, 18]),
    IslandChartSeries.values('乙', const [20, 8, 26]),
  ],
);

Set<Color> fills(WidgetTester t) => {
  for (final (_, paint) in painted(t).paths)
    if (paint.style == PaintingStyle.fill) paint.color,
};

String reading(WidgetTester t) {
  final label = t
      .getSemantics(find.bySemanticsLabel(RegExp('^值，1，')))
      .getSemanticsData()
      .label;
  return label.substring('值，1，'.length);
}

void main() {
  timePoints();
  testWidgets('hover and legend hover repaint without re-laying out the scene; '
      'data, legend and theme changes still rebuild it', (t) async {
    var calls = 0;
    String format(double v) {
      calls++;
      return v.toStringAsFixed(1);
    }

    final data = twoSeries();
    Widget chart(IslandChartData data, {Brightness b = Brightness.light}) =>
        chartHost(
          IslandChart(data: data, tooltip: null, valueFormatter: format),
          brightness: b,
        );
    await t.pumpWidget(chart(data));
    await t.pumpAndSettle();
    final settled = calls;
    expect(settled, greaterThan(0));

    final g = await mouse(t);
    for (final name in ['甲，一月，12.0', '乙，二月，8.0', '甲，三月，18.0']) {
      await g.moveTo(t.getCenter(find.bySemanticsLabel(name)));
      await t.pumpAndSettle();
    }
    await g.moveTo(t.getCenter(find.text('乙')));
    await t.pumpAndSettle();
    await g.moveTo(Offset.zero);
    await t.pumpAndSettle();
    expect(calls, settled, reason: 'pointer changes must not re-run layout');

    await t.tap(find.text('乙').first);
    await t.pumpAndSettle();
    expect(calls, greaterThan(settled), reason: 'hiding a series re-lays out');
    expect(find.bySemanticsLabel(RegExp('^乙，')), findsNothing);

    final hidden = calls;
    await t.pumpWidget(chart(twoSeries()));
    await t.pumpAndSettle();
    expect(calls, greaterThan(hidden), reason: 'new data re-lays out');

    final light = fills(t);
    await t.pumpWidget(chart(data, b: Brightness.dark));
    await t.pumpAndSettle();
    expect(fills(t), isNot(light), reason: 'the theme palette re-colours');
  });

  testWidgets('value labels are not hit targets', (t) async {
    final events = <IslandChartDataEvent>[];
    await t.pumpWidget(
      chartHost(
        IslandChart(
          showLabels: true,
          tooltip: null,
          onDataActivate: events.add,
          data: IslandChartData.column(
            categories: const ['一月'],
            series: [
              IslandChartSeries.values('甲', const [40]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final column = markRect(t, '甲，一月，40');
    await t.tapAt(plotPoint(t, column.topCenter + const Offset(0, 6)));
    await t.pumpAndSettle();
    expect(events, isEmpty);
    await t.tapAt(plotPoint(t, column.center + const Offset(0, 10)));
    await t.pumpAndSettle();
    expect(events, hasLength(1));
  });

  testWidgets('stroke-only gauge arcs and needles hit on the stroke only', (
    t,
  ) async {
    final events = <IslandChartDataEvent>[];
    await t.pumpWidget(
      chartHost(
        IslandChart(
          tooltip: null,
          onDataActivate: events.add,
          data: IslandChartData.gauge(
            series: [
              IslandChartSeries.values('完成度', const [100]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final dial = markRect(t, '完成度，1，100');
    // The arc's twelve o'clock band is 18 wide, from the top of the mark.
    await t.tapAt(plotPoint(t, dial.topCenter + const Offset(0, 40)));
    await t.pumpAndSettle();
    expect(events, isEmpty, reason: 'inside the arc, away from every stroke');
    await t.tapAt(plotPoint(t, dial.topCenter + const Offset(0, 9)));
    await t.pumpAndSettle();
    expect(events, hasLength(1), reason: 'on the arc stroke');
  });

  testWidgets('the default format rounds before choosing 万/亿/万亿', (t) async {
    for (final (value, text) in [
      (9999.0, '9,999'),
      (123456.0, '12.35万'),
      (99995000.0, '9999.5万'),
      (99999999.0, '1亿'),
      (-99999999.0, '-1亿'),
      (999999999999.0, '1万亿'),
      (1e16, '10000万亿'),
    ]) {
      await t.pumpWidget(
        chartHost(
          IslandChart(
            legend: false,
            data: IslandChartData.column(
              series: [
                IslandChartSeries.values('值', [value]),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(reading(t), text, reason: '$value');
    }
  });

  testWidgets('time readings outside the Date range are invalid data and '
      'never throw', (t) async {
    await t.pumpWidget(
      chartHost(
        const IslandChart(
          data: IslandChartData.time(
            series: [
              IslandChartPointSeries(
                name: '甲',
                data: [
                  IslandChartPoint(x: 1e16, y: 3),
                  IslandChartPoint(x: 0, y: 5),
                  IslandChartPoint(x: -8.64e15 - 1, y: 4),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.text('查看数据（1）'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^甲，2，')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('^甲，[13]，')), findsNothing);

    await t.pumpWidget(
      chartHost(
        const IslandChart(
          data: IslandChartData.time(
            series: [
              IslandChartPointSeries(
                name: '甲',
                data: [IslandChartPoint(x: 8.64e15, y: 3)],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.bySemanticsLabel(RegExp('^甲，1，')), findsOneWidget);
  });

  testWidgets('English chrome comes from IslandLocalizations', (t) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(data: twoSeries(), legend: true),
        locale: const Locale('en'),
      ),
    );
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel('Chart'), findsWidgets);
    expect(find.bySemanticsLabel('Legend'), findsOneWidget);
    expect(find.bySemanticsLabel('甲, 一月, 12'), findsOneWidget);
    await t.tap(find.text('View data (6)'));
    await t.pumpAndSettle();
    expect(find.text('Chart data'), findsOneWidget);
    for (final header in ['Series', 'Item', 'Value']) {
      expect(find.text(header), findsOneWidget);
    }
    await t.tap(find.text('甲').first);
    await t.pumpAndSettle();
    await t.tap(find.text('乙').first);
    await t.pumpAndSettle();
    expect(find.text('All legend entries are hidden'), findsOneWidget);
    expect(find.text('Show all legend entries'), findsOneWidget);
    expect(find.textContaining('图例'), findsNothing);
    expect(find.textContaining('查看数据'), findsNothing);
  });
}

void timePoints() {
  testWidgets('IslandChartPoint.time places a DateTime by its instant', (
    t,
  ) async {
    final local = DateTime(2026, 11, 17, 9, 30);
    final point = IslandChartPoint.time(local, y: 5, name: '早');
    expect(point.x, local.millisecondsSinceEpoch.toDouble());
    expect(point.size, isNull);
    expect(IslandChartPoint.time(local.toUtc(), y: 5).x, point.x);
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.time(
            series: [
              IslandChartPointSeries(name: '甲', data: [point]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(
      find.bySemanticsLabel('甲，早，2026-11-17 09:30:00 · 5'),
      findsOneWidget,
    );
  });
}
