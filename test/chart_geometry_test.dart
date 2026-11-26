import 'dart:math' as math;
import 'dart:ui';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_test.dart';
import 'foundation_test.dart' show contrast;

// Every expected value below is derived from the reference 4.0.0 formulas in
// src/components/Chart (Cartesian.tsx, Polar.tsx, Specialty.tsx, geometry.ts)
// for the measured plot width W and the default height 300, never from the
// Flutter implementation's own output.

const _top = 28.0, _bottom = 256.0;
const _height = 300.0;

Offset _polar(double cx, double cy, double r, double a) =>
    Offset(cx + r * math.sin(a), cy - r * math.cos(a));

void _rect(Rect actual, Rect expected) {
  expect(actual.left, closeTo(expected.left, 0.01), reason: 'left');
  expect(actual.top, closeTo(expected.top, 0.01), reason: 'top');
  expect(actual.right, closeTo(expected.right, 0.01), reason: 'right');
  expect(actual.bottom, closeTo(expected.bottom, 0.01), reason: 'bottom');
}

void _point(Offset actual, Offset expected) {
  expect(actual.dx, closeTo(expected.dx, 0.01), reason: 'x');
  expect(actual.dy, closeTo(expected.dy, 0.01), reason: 'y');
}

Offset _end(Path path) {
  final metric = path.computeMetrics().last;
  return metric.getTangentForOffset(metric.length)!.position;
}

Future<double> _pump(WidgetTester t, IslandChart chart) async {
  await t.pumpWidget(chartHost(chart));
  await t.pumpAndSettle();
  return plotSize(t).width;
}

void main() {
  void geo(String description, Future<void> Function(WidgetTester t) body) =>
      testWidgets(description, (t) async {
        final handle = t.ensureSemantics();
        await body(t);
        handle.dispose();
      });

  geo('column: slot centres, 0.7 slot breadth capped at 42, value '
      'heights on the automatic 0..40 axis', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.column(
          categories: const ['A', 'B', 'C'],
          series: [
            IslandChartSeries.values('甲', const [10, 20, 40]),
          ],
        ),
      ),
    );
    // axisTicks([10,20,40]): target 10, step 10 → 0..40.
    final pw = w - 24 - 62, ph = _bottom - _top;
    final breadth = math.min(42.0, pw / 3 * 0.7);
    for (final (i, v) in [(0, 10.0), (1, 20.0), (2, 40.0)]) {
      final x = 62 + (i + 0.5) / 3 * pw;
      _rect(
        markRect(t, '甲，${'ABC'[i]}，${v.round()}'),
        Rect.fromLTWH(
          x - breadth * 0.43,
          _bottom - v / 40 * ph,
          breadth * 0.86,
          v / 40 * ph,
        ),
      );
    }
  });

  geo('bar: 90px label gutter, rows of plotHeight / count', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.bar(
          categories: const ['A', 'B', 'C'],
          series: [
            IslandChartSeries.values('甲', const [10, 20, 40]),
          ],
        ),
      ),
    );
    final pw = w - 24 - 90, slot = (_bottom - _top) / 3;
    final breadth = math.min(42.0, slot * 0.7);
    for (final (i, v) in [(0, 10.0), (1, 20.0), (2, 40.0)]) {
      final y = _top + (i + 0.5) * slot;
      _rect(
        markRect(t, '甲，${'ABC'[i]}，${v.round()}'),
        Rect.fromLTWH(90, y - breadth * 0.43, v / 40 * pw, breadth * 0.86),
      );
    }
  });

  geo('stacked columns accumulate each sign from zero', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.column(
          stacked: true,
          min: -20,
          max: 20,
          series: [
            IslandChartSeries.values('甲', const [10, -5]),
            IslandChartSeries.values('乙', const [5, -10]),
          ],
        ),
      ),
    );
    final pw = w - 86, ph = _bottom - _top;
    double y(double v) => _bottom - (v + 20) / 40 * ph;
    final breadth = math.min(42.0, pw / 2 * 0.7);
    final x0 = 62 + 0.5 / 2 * pw, x1 = 62 + 1.5 / 2 * pw;
    _rect(
      markRect(t, '乙，1，5'),
      Rect.fromLTRB(x0 - breadth * .43, y(15), x0 + breadth * .43, y(10)),
    );
    _rect(
      markRect(t, '乙，2，-10'),
      Rect.fromLTRB(x1 - breadth * .43, y(-5), x1 + breadth * .43, y(-15)),
    );
  });

  geo('automatic and explicit value axes', (t) async {
    var w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.column(
          series: [
            IslandChartSeries.values('甲', const [32, 79]),
          ],
        ),
      ),
    );
    // axisTicks([32,79]) = [0,20,40,60,80].
    expect(markRect(t, '甲，2，79').top, closeTo(_bottom - 79 / 80 * 228, .01));
    expect(
      painted(t).stroked(1).where((e) => e.$2.color.a > .9).length,
      greaterThanOrEqualTo(5),
    );
    w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.column(
          min: 10,
          max: 70,
          series: [
            IslandChartSeries.values('甲', const [32, 79]),
          ],
        ),
      ),
    );
    expect(markRect(t, '甲，1，32').height, closeTo((32 - 10) / 60 * 228, .01));
    expect(markRect(t, '甲，2，79').top, closeTo(_top, .01));
    await _pump(
      t,
      IslandChart(
        data: IslandChartData.column(
          series: [
            IslandChartSeries.values('甲', const [-12, 26]),
          ],
        ),
      ),
    );
    // axisTicks([-12,26]): target 9.5, step 10 → -20..30; zero line at 0.
    final zero = painted(t).stroked(1.5).single.$1.getBounds();
    expect(zero.top, closeTo(_bottom - 20 / 50 * 228, .01));
    expect(zero.left, closeTo(62, .01));
    expect(zero.right, closeTo(w - 24, .01));
  });

  geo('line: category centres, 12px targets, a gap at missing data', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        showAxes: false,
        data: IslandChartData.line(
          series: [
            IslandChartSeries.values('测量', const [4, 6, null, 0, 8]),
          ],
        ),
      ),
    );
    final pw = w - 86;
    // axisTicks([4,6,0,8]) = 0..8.
    for (final (i, v) in [(0, 4.0), (1, 6.0), (3, 0.0), (4, 8.0)]) {
      final r = markRect(t, '测量，${i + 1}，${v.round()}');
      _point(r.center, Offset(62 + (i + .5) / 5 * pw, _bottom - v / 8 * 228));
      expect(r.width, closeTo(24, .01));
    }
    expect(painted(t).stroked(3), hasLength(2));
  });

  geo('area: fill to the zero baseline at 0.18', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        showAxes: false,
        data: IslandChartData.area(
          series: [
            IslandChartSeries.values('测量', const [4, 6, null, 0, 8]),
          ],
        ),
      ),
    );
    final pw = w - 86;
    final fills = [
      for (final (path, paint) in painted(t).paths)
        if (paint.style == PaintingStyle.fill &&
            (paint.color.a - .18).abs() < .01)
          path.getBounds(),
    ];
    expect(fills, hasLength(2));
    _rect(
      fills.first,
      Rect.fromLTRB(
        62 + .5 / 5 * pw,
        _bottom - 6 / 8 * 228,
        62 + 1.5 / 5 * pw,
        _bottom,
      ),
    );
  });

  geo('mount: hills 0.43 slot wide at the base, summit at the value', (
    t,
  ) async {
    for (final smooth in [false, true]) {
      final w = await _pump(
        t,
        IslandChart(
          showAxes: false,
          data: IslandChartData.mount(
            smooth: smooth,
            series: [
              IslandChartSeries.values('高度', const [10, 20]),
            ],
          ),
        ),
      );
      final pw = w - 86, half = pw / 2 * .43;
      final x = 62 + 1.5 / 2 * pw;
      // axisTicks([10,20]): target 5 → 0..20; stroke 2 adds 1 on each side.
      _rect(
        markRect(t, '高度，2，20'),
        Rect.fromLTRB(x - half, _top, x + half, _bottom).inflate(1),
      );
    }
  });

  geo('mix: only column series share the slot; lines use the same '
      'axis', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        showAxes: false,
        data: IslandChartData.mix(
          categories: const ['A', 'B'],
          series: [
            IslandChartSeries.values('本周', const [10, 20]),
            IslandChartSeries.values('上周', const [
              5,
              15,
            ], mode: IslandChartSeriesMode.line),
          ],
        ),
      ),
    );
    final pw = w - 86, b = math.min(42.0, pw / 2 * .7);
    final x = 62 + 1.5 / 2 * pw;
    // mix marks carry the reference 12px target around their anchor.
    _rect(
      markRect(t, '本周，B，20'),
      Rect.fromLTRB(x - b * .43, _top - 12, x + b * .43, _bottom),
    );
    _point(markRect(t, '上周，B，15').center, Offset(x, _bottom - 15 / 20 * 228));
  });

  geo('scatter, bubble and time keep real x spacing', (t) async {
    var w = await _pump(
      t,
      const IslandChart(
        data: IslandChartData.scatter(
          series: [
            IslandChartPointSeries(
              name: '点',
              data: [
                IslandChartPoint(x: 2, y: 10),
                IslandChartPoint(x: 6, y: 30),
                IslandChartPoint(x: 10, y: 20),
              ],
            ),
          ],
        ),
      ),
    );
    // x extent without zero: 2..10; axisTicks([10,30,20]) = 0..30.
    final pw = w - 86;
    _point(
      markRect(t, '点，2，6 · 30').center,
      Offset(62 + 4 / 8 * pw, _bottom - 30 / 30 * 228),
    );
    w = await _pump(
      t,
      const IslandChart(
        data: IslandChartData.bubble(
          series: [
            IslandChartPointSeries(
              name: '活动',
              data: [
                IslandChartPoint(x: 0, y: 5, size: 1),
                IslandChartPoint(x: 10, y: 6, size: 4),
              ],
            ),
          ],
        ),
      ),
    );
    // Radii sqrt(size / max) × 22 = 11 and 22, plus the 1px stroke half.
    expect(markRect(t, '活动，1，0 · 5 · 权重 1').width, closeTo(24, .01));
    expect(markRect(t, '活动，2，10 · 6 · 权重 4').width, closeTo(46, .01));
    await _pump(
      t,
      IslandChart(
        data: IslandChartData.time(
          xFormatter: (x) => '${x.round()}',
          series: const [
            IslandChartPointSeries(
              name: '到访',
              data: [
                IslandChartPoint(x: 1000, y: 2),
                IslandChartPoint(x: 2000, y: 3),
                IslandChartPoint(x: 5000, y: 4),
              ],
            ),
          ],
        ),
      ),
    );
    final xs = [
      markRect(t, '到访，1，1000 · 2').center.dx,
      markRect(t, '到访，2，2000 · 3').center.dx,
      markRect(t, '到访，3，5000 · 4').center.dx,
    ];
    expect((xs[2] - xs[1]) / (xs[1] - xs[0]), closeTo(3, 1e-9));
    expect(xs.first, closeTo(62, .01));
  });

  geo('candle: body and wick on one axis; rise and fall colours are '
      'distinct and visible', (t) async {
    final w = await _pump(
      t,
      const IslandChart(
        data: IslandChartData.candle(
          series: [
            IslandChartCandleSeries(
              name: '集市',
              data: [
                IslandChartCandle(open: 4, close: 6, low: 3, high: 8),
                IslandChartCandle(open: 6, close: 5, low: 4, high: 7),
              ],
            ),
          ],
        ),
      ),
    );
    // Values [3,8,4,7] → 0..8; breadth max(2, min(24, slot × 0.6)).
    final pw = w - 86, b = math.max(2.0, math.min(24.0, pw / 2 * .6));
    final x = 62 + .5 / 2 * pw;
    double y(double v) => _bottom - v / 8 * 228;
    _rect(
      markRect(t, '集市，1，开 4 / 收 6 / 低 3 / 高 8'),
      // The 2px wick adds half its width above and below.
      Rect.fromLTRB(x - b / 2, y(8) - 1, x + b / 2, y(3) + 1),
    );
    final fills = {
      for (final (_, paint) in painted(t).paths)
        if (paint.style == PaintingStyle.fill) paint.color,
    };
    expect(fills, hasLength(2));
    for (final c in fills) {
      expect(contrast(c, IslandTokens.light.paper), greaterThanOrEqualTo(3));
    }
  });

  geo('pie, ring and rose sectors', (t) async {
    var w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.pie(
          series: const IslandChartSeries(
            name: '区域',
            data: [
              IslandChartValue(30, name: '果园'),
              IslandChartValue(70, name: '海岸'),
            ],
          ),
        ),
      ),
    );
    var cx = w / 2;
    const cy = _height / 2;
    // radius max(20, min(W/2 − 70, H/2 − 26)).
    var r = math.max(20.0, math.min(w / 2 - 70, cy - 26));
    var sectors = [
      for (final (path, paint) in painted(t).paths)
        if (paint.style == PaintingStyle.fill) path,
    ];
    expect(sectors, hasLength(2));
    final orchard = _polar(cx, cy, r / 2, .3 * math.pi);
    final coast = _polar(cx, cy, r / 2, .6 * math.pi + .7 * math.pi);
    expect(sectors[0].contains(orchard), isTrue);
    expect(sectors[0].contains(coast), isFalse);
    expect(sectors[1].contains(coast), isTrue);
    expect(sectors[1].contains(_polar(cx, cy, r + 3, .3 * math.pi)), isFalse);

    w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.ring(
          series: IslandChartSeries.values('人数', const [12]),
        ),
      ),
    );
    cx = w / 2;
    r = math.max(20.0, math.min(w / 2 - 70, cy - 26));
    final ring = painted(t).paths
        .firstWhere((e) => e.$2.style == PaintingStyle.fill)
        .$1;
    for (var a = 0.0; a < 2 * math.pi; a += math.pi / 4) {
      expect(ring.contains(_polar(cx, cy, r * .83, a)), isTrue, reason: '$a');
      expect(ring.contains(_polar(cx, cy, r * .5, a)), isFalse, reason: '$a');
    }
    expect(painted(t).texts, hasLength(2), reason: 'total and 合计');

    w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.rose(
          series: IslandChartSeries.values('人数', const [10, 40]),
        ),
      ),
    );
    cx = w / 2;
    r = math.max(20.0, math.min(w / 2 - 70, cy - 26));
    sectors = [
      for (final (path, paint) in painted(t).paths)
        if (paint.style == PaintingStyle.fill) path,
    ];
    // Equal angles; outer radius r × sqrt(value / max) = r/2 and r.
    expect(sectors[0].contains(_polar(cx, cy, r * .45, math.pi / 2)), isTrue);
    expect(sectors[0].contains(_polar(cx, cy, r * .55, math.pi / 2)), isFalse);
    expect(sectors[1].contains(_polar(cx, cy, r * .95, 1.5 * math.pi)), isTrue);
  });

  geo('radar: dimensions clockwise from twelve o’clock on one range', (
    t,
  ) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.radar(
          categories: const ['甲', '乙', '丙'],
          max: 100,
          series: [
            IslandChartSeries.values('本期', const [50, 100, 0]),
            IslandChartSeries.values('残缺', const [30, null, 60]),
          ],
        ),
      ),
    );
    final cx = w / 2;
    const cy = _height / 2;
    final r = math.min(w / 2 - 72, cy - 40);
    _point(markRect(t, '本期，甲，50').center, _polar(cx, cy, r / 2, 0));
    _point(markRect(t, '本期，乙，100').center, _polar(cx, cy, r, 2 * math.pi / 3));
    _point(markRect(t, '本期，丙，0').center, Offset(cx, cy));
    expect(painted(t).stroked(2.5), hasLength(1), reason: 'incomplete series');
  });

  geo('arcbar and gauge: 270° arcs from −135°, clamped fractions, '
      'needle r − 34', (t) async {
    var w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.arcbar(
          series: [
            IslandChartSeries.values('植树', const [72]),
            IslandChartSeries.values('超额', const [150]),
          ],
        ),
      ),
    );
    const start = -.75 * math.pi, sweep = 1.5 * math.pi;
    var space = w / 2;
    const cy = _height / 2 + 20;
    var r = math.max(20.0, math.min(space / 2 - 22, _height / 2 - 38));
    final arcs = painted(t).stroked(14);
    expect(arcs, hasLength(4));
    _point(_end(arcs[2].$1), _polar(space * .5, cy, r, start + .72 * sweep));
    _point(_end(arcs[3].$1), _polar(space * 1.5, cy, r, start + sweep));

    w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.gauge(
          series: [
            IslandChartSeries.values('舒适度', const [72]),
          ],
        ),
      ),
    );
    space = w;
    r = math.max(20.0, math.min(space / 2 - 22, _height / 2 - 38));
    final cx = w / 2;
    expect(painted(t).stroked(18), hasLength(2));
    expect(painted(t).stroked(2), hasLength(9), reason: 'nine ticks');
    final needle = painted(t).stroked(4).single.$1;
    _point(_end(needle), _polar(cx, cy, r - 34, start + .72 * sweep));
  });

  geo('funnel: stage bands of (H − 40) / n, widths value / max × 0.7W', (
    t,
  ) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.funnel(
          series: IslandChartSeries.values('转化', const [200, 100, 50]),
        ),
      ),
    );
    final step = (_height - 40) / 3, span = w * .7, cx = w / 2;
    final bands = [
      for (final (path, paint) in painted(t).paths)
        if (paint.style == PaintingStyle.fill) path.getBounds(),
    ];
    _rect(
      bands[0],
      Rect.fromLTRB(cx - span / 2, 20, cx + span / 2, 20 + step - 5),
    );
    // The last stage narrows to 0.75 of its own width.
    final last = 50 / 200 * span;
    _rect(
      bands[2],
      Rect.fromLTRB(
        cx - last / 2,
        20 + 2 * step,
        cx + last / 2,
        20 + 3 * step - 5,
      ),
    );
  });

  geo('word: deterministic spiral placement', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.word(
          series: const IslandChartSeries(
            name: '提及',
            data: [
              IslandChartValue(40, name: '海风'),
              IslandChartValue(10, name: '露营'),
            ],
          ),
        ),
      ),
    );
    // First word: size min(44, 14 + 30, (W − 30) / 2) = 44 at i = 0 → centre.
    _point(markRect(t, '提及，海风，40').center, Offset(w / 2, _height / 2));
    // Second word: size 14 + sqrt(1/4) × 30 = 29; reference spiral search.
    final first = Rect.fromCenter(
      center: Offset(w / 2, _height / 2),
      width: 2 * 44 + 12,
      height: 44 * 1.5,
    );
    const ww = 2 * 29 + 12, hh = 29 * 1.5;
    Offset? centre;
    for (var i = 0; i < 1200 && centre == null; i++) {
      final angle = i * .55, radius = 4.2 * math.sqrt(i);
      final x = w / 2 + math.cos(angle) * radius * 2 - ww / 2;
      final y = _height / 2 + math.sin(angle) * radius - hh / 2;
      if (x < 10 || x + ww > w - 10 || y < 10 || y + hh > _height - 10) {
        continue;
      }
      if (x < first.right &&
          x + ww > first.left &&
          y < first.bottom &&
          y + hh > first.top) {
        continue;
      }
      centre = Offset(x + ww / 2, y + hh / 2);
    }
    _point(markRect(t, '提及，露营，10').center, centre!);
  });

  geo('map: equal-scale fit with y up; opacity 0.3 + 0.65 × share', (t) async {
    final w = await _pump(
      t,
      IslandChart(
        data: IslandChartData.map(
          series: const IslandChartSeries(
            name: '人数',
            data: [
              IslandChartValue(4, name: '甲'),
              IslandChartValue(8, name: '乙'),
            ],
          ),
          regions: const [
            IslandChartRegion(
              name: '甲',
              polygons: [
                [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)],
              ],
            ),
            IslandChartRegion(
              name: '乙',
              polygons: [
                [Offset(1, 0), Offset(2, 0), Offset(2, 1), Offset(1, 1)],
              ],
            ),
            IslandChartRegion(
              name: '丙',
              polygons: [
                [Offset(0, 1), Offset(2, 1), Offset(1, 1.0001)],
              ],
            ),
          ],
        ),
      ),
    );
    // Bounds x 0..2, y 0..1.0001.
    const yMax = 1.0001;
    final scale = math.min((w - 48) / 2, (_height - 40) / yMax);
    Offset project(double x, double y) =>
        Offset(w / 2 + (x - 1) * scale, _height / 2 - (y - yMax / 2) * scale);
    final fills = [
      for (final (path, paint) in painted(t).paths)
        if (paint.style == PaintingStyle.fill)
          (path.getBounds(), paint.color.a),
    ];
    // The region without data paints first, in the background.
    expect(fills, hasLength(3));
    _rect(fills[1].$1, Rect.fromPoints(project(0, 0), project(1, 1)));
    expect(fills[1].$2, closeTo(.3 + 4 / 8 * .65, .01));
    expect(fills[2].$2, closeTo(.95, .01));
    _point(
      markRect(t, '人数，甲，4').center,
      Offset(
        project(0, 0).dx + scale / 2,
        (project(0, 0).dy + project(0, 1).dy) / 2,
      ),
    );
  });

  geo('default series colours are visible graphics in both themes', (t) async {
    for (final brightness in Brightness.values) {
      await t.pumpWidget(
        chartHost(
          IslandChart(
            data: IslandChartData.column(
              series: [
                for (var i = 0; i < 8; i++)
                  IslandChartSeries.values('$i', [i + 1.0]),
              ],
            ),
          ),
          brightness: brightness,
        ),
      );
      await t.pumpAndSettle();
      final surface = brightness == Brightness.dark
          ? IslandTokens.dark.paper
          : IslandTokens.light.paper;
      final colours = {
        for (final (_, paint) in painted(t).paths)
          if (paint.style == PaintingStyle.fill) paint.color,
      };
      expect(colours, hasLength(8));
      for (final c in colours) {
        expect(contrast(c, surface), greaterThanOrEqualTo(3), reason: '$c');
      }
    }
  });
}
