import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'foundation_test.dart' show contrast;

/// Hosts a chart whose plot is about 640 wide.
Widget chartHost(
  Widget chart, {
  Brightness brightness = Brightness.light,
  bool reduced = false,
  double width = 683,
  Locale locale = const Locale('zh'),
}) => MaterialApp(
  locale: locale,
  supportedLocales: IslandLocalizations.supportedLocales,
  localizationsDelegates: IslandLocalizations.delegates,
  theme: IslandTheme.create(brightness: brightness),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Center(
        child: SizedBox(width: width, child: chart),
      ),
    ),
  ),
);

final chartCanvas = find
    .descendant(
      of: find.byType(IslandChart),
      matching: find.byType(CustomPaint),
    )
    .first;

/// Everything the plot painted, in local plot coordinates.
class Painted {
  final paths = <(Path, Paint)>[];
  final texts = <(ui.Paragraph, Offset)>[];
  final layers = <Paint>[];
  final ovals = <(Rect, Paint)>[];
  final rects = <(Rect, Paint)>[];

  List<Path> filled(Color color) => [
    for (final (path, paint) in paths)
      if (paint.style == PaintingStyle.fill &&
          paint.color.r == color.r &&
          paint.color.g == color.g &&
          paint.color.b == color.b)
        path,
  ];

  List<(Path, Paint)> stroked(double width) => [
    for (final (path, paint) in paths)
      if (paint.style == PaintingStyle.stroke && paint.strokeWidth == width)
        (path, paint),
  ];
}

Painted painted(WidgetTester t) {
  final p = Painted();
  expect(
    t.renderObject(chartCanvas),
    paints..everything((method, args) {
      switch (method) {
        case #drawPath:
          p.paths.add((args[0] as Path, args[1] as Paint));
        case #drawParagraph:
          p.texts.add((args[0] as ui.Paragraph, args[1] as Offset));
        case #saveLayer:
          p.layers.add(args[1] as Paint);
        case #drawOval:
          p.ovals.add((args[0] as Rect, args[1] as Paint));
        case #drawRect:
          p.rects.add((args[0] as Rect, args[1] as Paint));
      }
      return true;
    }),
  );
  return p;
}

Size plotSize(WidgetTester t) => t.getSize(chartCanvas);

/// A mark's accessible rectangle in plot coordinates.
Rect markRect(WidgetTester t, String label) {
  final origin = t.getTopLeft(chartCanvas);
  return t.getRect(find.bySemanticsLabel(label)).shift(-origin);
}

Offset plotPoint(WidgetTester t, Offset local) =>
    t.getTopLeft(chartCanvas) + local;

bool hasTooltip(String text) => find.textContaining(text).evaluate().isNotEmpty;

Future<TestGesture> mouse(WidgetTester t) async {
  final g = await t.createGesture(kind: PointerDeviceKind.mouse);
  await g.addPointer(location: Offset.zero);
  addTearDown(g.removePointer);
  return g;
}

Future<void> semanticTap(WidgetTester t, String label) async {
  t.semantics.tap(
    find.semantics.byPredicate(
      (node) =>
          node.label == label &&
          node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
    ),
  );
  await t.pump();
}

final basicSeries = IslandChartSeries.values('到访', const [12, null, 25]);

IslandChartData basicData(IslandChartType type) {
  final s = basicSeries;
  return switch (type) {
    IslandChartType.column => IslandChartData.column(series: [s]),
    IslandChartType.bar => IslandChartData.bar(series: [s]),
    IslandChartType.line => IslandChartData.line(series: [s]),
    IslandChartType.area => IslandChartData.area(series: [s]),
    IslandChartType.mount => IslandChartData.mount(series: [s]),
    IslandChartType.mix => IslandChartData.mix(series: [s]),
    IslandChartType.pie => IslandChartData.pie(series: s),
    IslandChartType.ring => IslandChartData.ring(series: s),
    IslandChartType.rose => IslandChartData.rose(series: s),
    IslandChartType.funnel => IslandChartData.funnel(series: s),
    IslandChartType.word => IslandChartData.word(series: s),
    _ => throw UnimplementedError(),
  };
}

void main() {
  testWidgets('shared tooltip aggregates series; a lock survives hover; '
      'arrows unlock and move; Escape closes', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(
            categories: const ['周一', '周二'],
            series: [
              IslandChartSeries.values('本周', const [10, 20]),
              IslandChartSeries.values('上周', const [8, 16]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final monday = markRect(t, '本周，周一，10');
    final tuesday = markRect(t, '本周，周二，20');
    await t.tapAt(plotPoint(t, monday.center));
    await t.pumpAndSettle();
    expect(hasTooltip('上周'), isTrue);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('已锁定'), findsOneWidget);
    expect(find.text('已锁定：周一'), findsOneWidget);
    final g = await mouse(t);
    await g.moveTo(plotPoint(t, tuesday.center));
    await t.pumpAndSettle();
    expect(find.text('周一'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.pumpAndSettle();
    expect(find.text('周二'), findsOneWidget);
    expect(find.text('已锁定'), findsNothing);
    expect(
      t.getSemantics(find.bySemanticsLabel('本周，周一，10')),
      matchesSemantics(
        label: '本周，周一，10',
        isButton: true,
        hasToggledState: true,
        isToggled: false,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    expect(
      t
          .getSemantics(find.bySemanticsLabel('本周，周二，20'))
          .flagsCollection
          .isFocused,
      ui.Tristate.isTrue,
    );
    final focusRing =
        (paints..rect(
              color: const Color(0xff04a195),
              style: PaintingStyle.stroke,
              strokeWidth: 2,
            ))
            as Matcher;
    bool ring() => find
        .descendant(
          of: find.byType(IslandChart),
          matching: find.byType(CustomPaint),
        )
        .evaluate()
        .any((e) => focusRing.matches(e.renderObject, {}));
    expect(ring(), isTrue);
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('周二'), findsNothing);
    expect(find.text('点击锁定读数'), findsNothing);
    // Reference: Escape closes the reading; the mark keeps focus and its
    // focus-visible ring, and the next arrow goes on from it.
    expect(ring(), isTrue);
    expect(
      t
          .getSemantics(find.bySemanticsLabel('本周，周二，20'))
          .flagsCollection
          .isFocused,
      ui.Tristate.isTrue,
    );
    await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await t.pumpAndSettle();
    expect(find.text('周一'), findsOneWidget);
    expect(ring(), isTrue);
    semantics.dispose();
  });

  testWidgets('a pointer press on the restore control leaves no legend '
      'entry focused', (t) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(
            categories: const ['周一', '周二'],
            series: [
              IslandChartSeries.values('本周', const [10, 20]),
              IslandChartSeries.values('上周', const [8, 16]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('上周'));
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, isNot(isA<FocusScopeNode>()));
    await t.tap(find.text('恢复全部图例'));
    await t.pumpAndSettle();
    expect(find.text('恢复全部图例'), findsNothing);
    // The reference leaves focus on the document: no entry stays focused, so
    // no series stays highlighted once the pointer has left.
    expect(FocusManager.instance.primaryFocus, isA<FocusScopeNode>());
    expect(t.takeException(), isNull);
  });

  testWidgets('ring shares follow visible items; legends restore; custom '
      'and disabled tooltips', (t) async {
    final semantics = t.ensureSemantics();
    const series = IslandChartSeries(
      name: '区域',
      data: [
        IslandChartValue(30, name: '果园'),
        IslandChartValue(70, name: '海岸'),
      ],
    );
    Widget ring({
      IslandChartTooltip? tooltip = const IslandChartTooltip(),
      bool selectable = true,
    }) => chartHost(
      IslandChart(
        data: IslandChartData.ring(series: series),
        tooltip: tooltip,
        selectable: selectable,
      ),
    );
    await t.pumpWidget(ring());
    await t.pumpAndSettle();
    await semanticTap(t, '区域，果园，30');
    expect(find.text('占比 30%'), findsOneWidget);
    await semanticTap(t, '海岸');
    await t.pumpAndSettle();
    await semanticTap(t, '区域，果园，30');
    expect(find.text('占比 100%'), findsOneWidget);
    await semanticTap(t, '果园');
    await t.pumpAndSettle();
    expect(find.text('所有图例已隐藏'), findsOneWidget);
    expect(find.text('恢复图例后，即可继续查看统计。'), findsOneWidget);
    await t.tap(find.text('恢复全部图例'));
    await t.pumpAndSettle();
    expect(
      t.getSemantics(find.bySemanticsLabel('海岸')),
      matchesSemantics(
        label: '海岸',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    await t.pumpWidget(
      ring(
        selectable: false,
        tooltip: IslandChartTooltip(
          builder: (context, tip) => Text('自定义：${tip.items.first.percentage}%'),
        ),
      ),
    );
    await semanticTap(t, '区域，海岸，70');
    expect(find.text('自定义：70.0%'), findsOneWidget);
    await t.pumpWidget(ring(tooltip: null));
    await semanticTap(t, '区域，海岸，70');
    expect(find.textContaining('自定义'), findsNothing);
    expect(find.text('点击锁定读数'), findsNothing);
    semantics.dispose();
  });

  testWidgets('funnel tooltips rate against the first and previous stage', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.funnel(
            series: const IslandChartSeries(
              name: '转化',
              data: [
                IslandChartValue(200, name: '到访'),
                IslandChartValue(100, name: '咨询'),
                IslandChartValue(50, name: '下单'),
              ],
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await semanticTap(t, '转化，下单，50');
    expect(find.text('较首阶段 25%'), findsOneWidget);
    expect(find.text('较上阶段 50%'), findsOneWidget);
    semantics.dispose();
  });

  for (final type in [
    IslandChartType.column,
    IslandChartType.bar,
    IslandChartType.line,
    IslandChartType.area,
    IslandChartType.mount,
    IslandChartType.mix,
    IslandChartType.pie,
    IslandChartType.ring,
    IslandChartType.rose,
    IslandChartType.funnel,
    IslandChartType.word,
  ]) {
    testWidgets('$type keeps valid data and original indices', (t) async {
      final semantics = t.ensureSemantics();
      final events = <IslandChartDataEvent>[];
      await t.pumpWidget(
        chartHost(
          IslandChart(
            title: '到访统计',
            data: basicData(type),
            onDataActivate: events.add,
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.semantics.byLabel(RegExp('^到访，')), findsNWidgets(2));
      await semanticTap(t, '到访，3，25');
      expect(events.single.type, type);
      expect(events.single.dataIndex, 2);
      expect(events.single.value, 25);
      expect(events.single.datum, isA<IslandChartValue>());
      semantics.dispose();
    });
  }

  testWidgets('hiding every legend shows a restorable state; the data table '
      'remains', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          title: '到访统计',
          data: IslandChartData.column(series: [basicSeries]),
        ),
      ),
    );
    await t.pumpAndSettle();
    await semanticTap(t, '到访');
    await t.pumpAndSettle();
    expect(
      t.getSemantics(find.bySemanticsLabel('到访')).flagsCollection.isToggled,
      ui.Tristate.isFalse,
    );
    expect(find.text('所有图例已隐藏'), findsOneWidget);
    expect(find.text('查看数据（2）'), findsOneWidget);
    expect(find.semantics.byLabel(RegExp('^到访，')), findsNothing);
    await semanticTap(t, '到访');
    await t.pumpAndSettle();
    expect(find.semantics.byLabel(RegExp('^到访，')), findsNWidgets(2));
    semantics.dispose();
  });

  testWidgets('Tab enters at one stop; Home/End; Enter and Space activate; '
      'Escape closes', (t) async {
    final events = <IslandChartDataEvent>[];
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(
            series: [
              IslandChartSeries.values('目标', const [42]),
            ],
          ),
          onDataActivate: events.add,
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.home);
    await t.sendKeyEvent(LogicalKeyboardKey.end);
    await t.pumpAndSettle();
    expect(find.text('42'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pump();
    expect(find.text('已锁定'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pump();
    expect(find.text('已锁定'), findsNothing);
    expect(events, hasLength(2));
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.text('42'), findsNothing);
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(
      FocusManager.instance.primaryFocus?.debugLabel,
      isNot(contains('目标')),
      reason: 'Tab leaves the plot after the single roving stop',
    );
  });

  testWidgets('loading and custom empty states leave no marks', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(series: [basicSeries]),
          loading: true,
        ),
      ),
    );
    expect(find.text('正在整理数据…'), findsOneWidget);
    expect(find.semantics.byLabel(RegExp('^到访，')), findsNothing);
    expect(find.text('查看数据（2）'), findsNothing);
    await t.pumpWidget(
      chartHost(const IslandChart(data: IslandChartData.column(series: []))),
    );
    await t.pumpAndSettle();
    expect(find.text('暂无数据'), findsOneWidget);
    await t.pumpWidget(
      chartHost(
        const IslandChart(
          data: IslandChartData.column(series: []),
          empty: Text('自定义完整空态'),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('自定义完整空态'), findsOneWidget);
    expect(find.byType(IslandNoData), findsNothing);
    semantics.dispose();
  });

  testWidgets('invalid values and weights are omitted, zero is kept', (
    t,
  ) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(
            series: [
              IslandChartSeries.values('测量', const [
                null,
                double.nan,
                double.infinity,
                0,
                -4,
              ]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('查看数据（2）'));
    await t.pumpAndSettle();
    expect(find.text('统计图表数据明细'), findsOneWidget);
    expect(find.text('系列'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('-4'), findsOneWidget);
    await t.pumpWidget(
      chartHost(
        const IslandChart(
          data: IslandChartData.bubble(
            series: [
              IslandChartPointSeries(
                name: '测量',
                data: [
                  IslandChartPoint(x: 1, y: double.nan),
                  IslandChartPoint(x: 1, y: 2, size: 0),
                  IslandChartPoint(x: 3, y: 4, size: 9),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('查看数据（1）'), findsOneWidget);
  });

  testWidgets('the data summary is a Blink line-height: normal line box', (
    t,
  ) async {
    // Reference `.data summary`: 12px, `padding: 4px`, inheriting
    // `line-height: normal` like `.title`, at the bottom of the 20px
    // `.chart` padding. At 1.3x the test font is 15.6px: ascent 11.7 -> 12,
    // descent 3.9 -> 4, a 16px line box, not the 1.5 ambient line (23.4).
    await t.pumpWidget(
      chartHost(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: IslandChart(
              title: '到访统计',
              data: IslandChartData.column(series: [basicSeries]),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final chart = find.byType(IslandChart);
    final border = IslandTheme.borderWidth(t.element(chart), 1.5);
    final summary = t.getRect(find.text('查看数据（2）'));
    expect(
      t.getRect(chart).bottom - summary.center.dy,
      moreOrLessEquals(16 / 2 + 4 + 20 + border, epsilon: 0.01),
    );
  });

  testWidgets('scatter readings keep both coordinates and formatters', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          valueFormatter: (v) => '${v.round()}人',
          data: IslandChartData.scatter(
            xFormatter: (v) => '${v.round()}天',
            series: const [
              IslandChartPointSeries(
                name: '访客',
                data: [IslandChartPoint(x: 3, y: 8)],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await semanticTap(t, '访客，1，3天 · 8人');
    expect(find.text('3天 · 8人'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a zero-valued pie shows the empty state', (t) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.pie(
            series: IslandChartSeries.values('人数', const [0, -4]),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('暂无数据'), findsOneWidget);
  });

  for (final gauge in [false, true]) {
    testWidgets('${gauge ? 'gauge' : 'arcbar'} clamps the arc but reads the '
        'real value', (t) async {
      final semantics = t.ensureSemantics();
      final series = [
        IslandChartSeries.values('目标', const [150]),
      ];
      await t.pumpWidget(
        chartHost(
          IslandChart(
            data: gauge
                ? IslandChartData.gauge(series: series)
                : IslandChartData.arcbar(series: series),
          ),
        ),
      );
      await t.pumpAndSettle();
      await semanticTap(t, '目标，1，150');
      expect(find.text('150'), findsOneWidget);
      semantics.dispose();
    });
  }

  testWidgets('candle readings list all four values; invalid ranges are '
      'omitted', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        const IslandChart(
          data: IslandChartData.candle(
            series: [
              IslandChartCandleSeries(
                name: '集市',
                data: [
                  IslandChartCandle(open: 4, close: 6, low: 3, high: 8),
                  IslandChartCandle(open: 10, close: 6, low: 3, high: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.semantics.byLabel(RegExp('^集市，')), findsOneWidget);
    await semanticTap(t, '集市，1，开 4 / 收 6 / 低 3 / 高 8');
    expect(find.text('开 4 / 收 6 / 低 3 / 高 8'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('map regions match data by name, not order', (t) async {
    final semantics = t.ensureSemantics();
    final events = <IslandChartDataEvent>[];
    await t.pumpWidget(
      chartHost(
        IslandChart(
          onDataActivate: events.add,
          data: IslandChartData.map(
            series: const IslandChartSeries(
              name: '人数',
              data: [
                IslandChartValue(8, name: '乙'),
                IslandChartValue(4, name: '甲'),
              ],
            ),
            regions: const [
              IslandChartRegion(
                name: '甲',
                polygons: [
                  [Offset(0, 0), Offset(1, 0), Offset(1, 1)],
                ],
              ),
              IslandChartRegion(
                name: '乙',
                polygons: [
                  [Offset(1, 0), Offset(2, 0), Offset(2, 1)],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await semanticTap(t, '人数，甲，4');
    expect(events.single.name, '甲');
    expect(events.single.dataIndex, 1);
    expect(events.single.value, 4);
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.map(
            series: IslandChartSeries.values('人数', const [1]),
            regions: const [],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.text('请提供地图区域轮廓'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('time charts compare equal timestamps; empty space outside the '
      'plot shows nothing', (t) async {
    await t.pumpWidget(
      chartHost(
        const IslandChart(
          legend: false,
          data: IslandChartData.time(
            xFormatter: _seconds,
            series: [
              IslandChartPointSeries(
                name: '甲',
                data: [
                  IslandChartPoint(x: 1000, y: 10),
                  IslandChartPoint(x: 2000, y: 20),
                ],
              ),
              IslandChartPointSeries(
                name: '乙',
                data: [IslandChartPoint(x: 2000, y: 30)],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final size = plotSize(t);
    final g = await mouse(t);
    await g.moveTo(plotPoint(t, const Offset(62 + 1, 29)));
    await t.pumpAndSettle();
    expect(find.text('1s'), findsOneWidget);
    expect(find.text('乙'), findsNothing);
    await g.moveTo(plotPoint(t, Offset(size.width - 24 - 1, 29)));
    await t.pumpAndSettle();
    expect(find.text('2s'), findsOneWidget);
    expect(find.text('甲'), findsOneWidget);
    expect(find.text('乙'), findsOneWidget);
    await g.moveTo(plotPoint(t, const Offset(10, 10)));
    await t.pumpAndSettle();
    expect(find.text('2s'), findsNothing);
  });

  testWidgets('radar hover resolves the dimension by angle, zeros included', (
    t,
  ) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.radar(
            categories: const ['甲', '乙', '丙', '丁'],
            max: 100,
            series: [
              IslandChartSeries.values('本期', const [0, 60, null, 50]),
              IslandChartSeries.values('上期', const [0, 70, 40, 55]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final size = plotSize(t);
    final cx = size.width / 2, cy = size.height / 2;
    final radius = [
      size.width / 2 - 72,
      size.height / 2 - 40,
    ].reduce((a, b) => a < b ? a : b);
    final g = await mouse(t);
    // Just left of twelve o'clock: dimension 0 (甲) with two zero readings.
    await g.moveTo(plotPoint(t, Offset(cx - 3, cy - radius * 0.9)));
    await t.pumpAndSettle();
    expect(find.text('甲'), findsOneWidget);
    // Three o'clock: dimension 1 compares 60 and 70.
    await g.moveTo(plotPoint(t, Offset(cx + radius * 0.95, cy)));
    await t.pumpAndSettle();
    expect(find.text('乙'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('70'), findsOneWidget);
    // Outside the circle.
    await g.moveTo(plotPoint(t, Offset(cx + radius + 2, cy)));
    await t.pumpAndSettle();
    expect(find.text('乙'), findsNothing);
  });

  testWidgets('legend hover dims other series; reduced motion settles at '
      'once', (t) async {
    final data = IslandChartData.column(
      series: [
        IslandChartSeries.values('甲', const [10]),
        IslandChartSeries.values('乙', const [20]),
      ],
    );
    final g = await mouse(t);
    for (final reduced in [false, true]) {
      await g.moveTo(Offset.zero);
      await t.pumpWidget(chartHost(IslandChart(data: data), reduced: reduced));
      final fade = t.widget<FadeTransition>(
        find.descendant(
          of: find.byType(IslandChart),
          matching: find.byType(FadeTransition),
        ),
      );
      expect(fade.opacity.value, reduced ? 1 : 0);
      await t.pumpAndSettle();
      expect(fade.opacity.value, 1);
      await g.moveTo(t.getCenter(find.text('甲')));
      await t.pump();
      if (!reduced) {
        await t.pump(const Duration(milliseconds: 100));
        final mid = painted(t).layers.single.color.a;
        expect(mid, inExclusiveRange(0.24, 1));
        await t.pump(const Duration(milliseconds: 150));
      }
      expect(painted(t).layers.single.color.a, closeTo(0.24, 1e-6));
      await g.moveTo(Offset.zero);
      await t.pumpAndSettle();
      expect(painted(t).layers, isEmpty);
    }
  });

  testWidgets('chrome follows the theme with readable text', (t) async {
    for (final brightness in Brightness.values) {
      await t.pumpWidget(
        chartHost(
          IslandChart(
            title: '到访统计',
            description: '本周与上周',
            data: IslandChartData.column(
              series: [
                IslandChartSeries.values('甲', const [10]),
                IslandChartSeries.values('乙', const [20]),
              ],
            ),
          ),
          brightness: brightness,
        ),
      );
      await t.pumpAndSettle();
      final tokens = brightness == Brightness.dark
          ? IslandTokens.dark
          : IslandTokens.light;
      final box = t.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(IslandChart),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final surface = (box.decoration as BoxDecoration).color!;
      expect(surface, tokens.paper);
      Color ink(String text) =>
          (t.renderObject<RenderParagraph>(find.text(text)).text as TextSpan)
              .style!
              .color ??
          t
              .widget<DefaultTextStyle>(
                find
                    .ancestor(
                      of: find.text(text),
                      matching: find.byType(DefaultTextStyle),
                    )
                    .first,
              )
              .style
              .color!;
      for (final text in ['到访统计', '本周与上周', '查看数据（2）']) {
        expect(
          contrast(ink(text), surface),
          greaterThanOrEqualTo(4.5),
          reason: '$text $brightness',
        );
      }
      await semanticTapLegend(t, '甲');
      expect(contrast(ink('甲'), surface), greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('disposal after interaction leaves no tickers or errors', (
    t,
  ) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.line(
            series: [
              IslandChartSeries.values('甲', const [1, 2, 3]),
            ],
          ),
        ),
      ),
    );
    final g = await mouse(t);
    await g.moveTo(plotPoint(t, const Offset(200, 100)));
    await t.pump(const Duration(milliseconds: 50));
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 1));
    expect(t.takeException(), isNull);
  });
  testWidgets('caller surface colours replace only the container', (t) async {
    final fill = IslandTokens.light.inputSurface;
    final edge = IslandTokens.light.outline;
    await t.pumpWidget(
      chartHost(
        IslandChart(
          backgroundColor: fill,
          borderColor: edge,
          data: IslandChartData.column(series: [basicSeries]),
        ),
      ),
    );
    final box = t.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(IslandChart),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = box.decoration as BoxDecoration;
    expect(decoration.color, fill);
    expect((decoration.border! as Border).top.color, edge);
  });

  testWidgets('keyboard focus draws an outline; pointer focus does not', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(
            series: [
              IslandChartSeries.values('甲', const [10, 20]),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tapAt(plotPoint(t, markRect(t, '甲，2，20').center));
    await t.pumpAndSettle();
    expect(painted(t).rects, isEmpty);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await t.pumpAndSettle();
    final outline = painted(t).rects.single;
    expect(outline.$2.strokeWidth, 2);
    expect(
      outline.$1,
      rectMoreOrLessEquals(markRect(t, '甲，1，10').inflate(5), epsilon: 1e-6),
    );
    expect(
      contrast(outline.$2.color, IslandTokens.light.paper),
      greaterThanOrEqualTo(3),
    );
    semantics.dispose();
  });

  testWidgets('a plot wider than its parent shows the reference thin '
      'scrollbar; a fitting plot shows none', (t) async {
    final chart = IslandChart(
      data: IslandChartData.column(
        series: [
          IslandChartSeries.values('甲', const [10, 20]),
        ],
      ),
    );
    // Reference `.viewport` thumb `--animal-text-color-disabled` #c4b89e,
    // 4px thick over a transparent track at the bottom of the plot.
    const thumb = Color(0xffc4b89e);
    final scrollbar = find.descendant(
      of: find.byType(IslandChart),
      matching: find.byType(RawScrollbar),
    );
    await t.pumpWidget(chartHost(chart, width: 260));
    await t.pumpAndSettle();
    final viewport = t.getRect(scrollbar);
    expect(viewport.width, lessThan(280));
    expect(
      t.renderObject(scrollbar),
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          Rect.fromLTWH(
            0,
            viewport.height - 4,
            viewport.width * viewport.width / 280,
            4,
          ),
          Radius.zero,
        ),
        color: thumb,
      ),
    );
    await t.pumpWidget(chartHost(chart));
    await t.pumpAndSettle();
    expect(t.renderObject(scrollbar), isNot(paints..rrect(color: thumb)));
  });

  testWidgets('a title or description mixing Latin and CJK keeps the line '
      'height of an all-CJK one', (t) async {
    Future<Size> header(String title, String description) async {
      await t.pumpWidget(
        chartHost(
          IslandChart(
            title: title,
            description: description,
            data: IslandChartData.column(
              series: [
                IslandChartSeries.values('甲', const [10]),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      return Size(
        t.getSize(find.text(title)).height,
        t.getSize(find.text(description)).height,
      );
    }

    final cjk = await header('岛屿柱状图', '每种水果独立配色，直接标注采收数量。');
    final mixed = await header('彩色单柱 · Fruit 2026', '将量程设为 0–5，适配 Latin 数据。');
    expect(mixed, cjk);
    // Reference `.description` fixed `line-height: 1.7` at 12px: the
    // paragraph's own strut line; its CSS box is checked below.
    expect(cjk.height, closeTo(12 * 1.7, 0.5));
  });

  testWidgets('a wrapped description keeps the CSS 20.390625px line pitch', (
    t,
  ) async {
    final description = List.filled(40, 'island').join(' ');
    Future<double> height(double width) async {
      await t.pumpWidget(
        chartHost(
          IslandChart(
            description: description,
            data: IslandChartData.column(
              series: [
                IslandChartSeries.values('a', const [10]),
              ],
            ),
          ),
          width: width,
        ),
      );
      await t.pumpAndSettle();
      return t.getSize(find.text(description)).height;
    }

    final lines = <int>{};
    for (final width in [683.0, 420.0, 300.0]) {
      final paragraph = await height(width);
      // The paragraph itself keeps whole 20px lines; its box is CSS lines.
      expect(paragraph % 20, 0, reason: '$width');
      final count = paragraph ~/ 20;
      lines.add(count);
      final box = t.getSize(
        find
            .ancestor(
              of: find.text(description),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(box.height, 6 + count * 20.390625, reason: '$width');
    }
    expect(lines.length, 3);
    expect(lines.reduce((a, b) => a < b ? a : b), greaterThan(1));
    expect(t.takeException(), isNull);
  });

  testWidgets('a map region without data names itself 暂无数据 on hover and '
      'for assistive technology; it is not a reading', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.map(
            series: const IslandChartSeries(
              name: '人数',
              data: [IslandChartValue(4, name: '甲')],
            ),
            regions: const [
              IslandChartRegion(
                name: '甲',
                polygons: [
                  [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)],
                ],
              ),
              IslandChartRegion(
                name: '星沙岛',
                polygons: [
                  [Offset(2, 0), Offset(3, 0), Offset(3, 1), Offset(2, 1)],
                ],
              ),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final region = find.bySemanticsLabel('星沙岛：暂无数据');
    expect(region, findsOneWidget);
    expect(
      t
          .getSemantics(region)
          .getSemanticsData()
          .hasAction(ui.SemanticsAction.tap),
      isFalse,
    );
    expect(find.text('星沙岛：暂无数据'), findsNothing);
    final g = await mouse(t);
    await g.moveTo(t.getCenter(region));
    await t.pumpAndSettle();
    expect(find.text('星沙岛：暂无数据'), findsOneWidget);
    // The region with data is a reading and shows its own tooltip instead.
    await g.moveTo(t.getCenter(find.bySemanticsLabel('人数，甲，4')));
    await t.pumpAndSettle();
    expect(hasTooltip('星沙岛：暂无数据'), isFalse);
    semantics.dispose();
  });
}

String _seconds(double ms) => '${(ms / 1000).round()}s';

Future<void> semanticTapLegend(WidgetTester t, String label) async {
  await t.tap(find.text(label));
  await t.pumpAndSettle();
}
