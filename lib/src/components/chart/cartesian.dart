part of 'chart.dart';

String _twoDigits(int n) => n.toString().padLeft(2, '0');

/// The local time [ms] milliseconds after the epoch; null outside the
/// ±8.64e15 ms that both `DateTime` and the reference's JS `Date` represent.
DateTime? _instant(double ms) => ms.isFinite && ms.abs() <= 8.64e15
    ? DateTime.fromMillisecondsSinceEpoch(ms.round())
    : null;

/// The reference dayjs text for a timestamp it cannot represent; only axis
/// ticks widened past the range reach it, since such data is invalid.
const _invalidDate = 'Invalid Date';

/// Local `HH:mm`, the reference default time axis label.
String _clock(double ms) {
  final t = _instant(ms);
  if (t == null) return _invalidDate;
  return '${_twoDigits(t.hour)}:${_twoDigits(t.minute)}';
}

/// Local `YYYY-MM-DD HH:mm:ss`, the reference default time reading.
String _timestamp(double ms) {
  final t = _instant(ms);
  if (t == null) return _invalidDate;
  return '${t.year.toString().padLeft(4, '0')}-${_twoDigits(t.month)}-'
      '${_twoDigits(t.day)} ${_twoDigits(t.hour)}:${_twoDigits(t.minute)}:'
      '${_twoDigits(t.second)}';
}

_PathShape _segment(
  Offset a,
  Offset b,
  _Ink ink, {
  double width = 1,
  List<double>? dash,
  bool round = false,
}) => _PathShape(
  Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy),
  stroke: _Tone.ink(ink),
  strokeWidth: width,
  dash: dash,
  round: round,
);

Path _roundedRect(double x, double y, double w, double h, double r) =>
    Path()..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, w, h),
        Radius.circular(math.max(0, math.min(r, math.min(w, h) / 2))),
      ),
    );

/// Shared category/value axes, zero baseline, gaps at missing data and
/// sign-separated stacking (reference `Cartesian.tsx`).
_Scene _cartesianScene(_SceneContext c) {
  final data = c.data;
  final type = data.type;
  final categories = data._categories;
  final series = c.series;
  final points = c.points;
  final format = c.format;
  final stacked = data._stacked;
  final smooth = data._smooth;
  final horizontal = type == IslandChartType.bar;
  final numericX = _coordinateTypes.contains(type);
  final left = horizontal ? 90.0 : 62.0;
  final right = c.width - 24;
  const top = 28.0;
  final bottom = c.height - 44;
  final plotWidth = right - left, plotHeight = bottom - top;
  final groups = <int>{for (final p in points) p.seriesIndex}.toList();
  final count = [
    categories.length,
    for (final s in series) s.data.length,
    1,
  ].reduce(math.max);
  final sums = <int, List<double>>{};
  final stackedBars =
      stacked &&
      (type == IslandChartType.column || type == IslandChartType.bar);
  for (final p in points) {
    final sum = sums.putIfAbsent(p.dataIndex, () => [0, 0]);
    sum[p.value < 0 ? 0 : 1] += p.value;
  }
  final values = stackedBars
      ? [for (final s in sums.values) ...s]
      : [
          for (final p in points)
            if (p.candle case final candle?) ...[
              candle.low,
              candle.high,
            ] else
              p.value,
        ];
  final ticks = _axisTicks(values, data._min, data._max);
  final low = ticks.first, high = ticks.last;
  final maxBubbleSize = points.fold<double>(
    double.minPositive,
    (largest, p) => math.max(largest, p.size),
  );
  final (xLow, xHigh) = _extent(
    [for (final p in points) p.x],
    null,
    null,
    false,
  );
  double ratio(double v) => ((v - low) / (high - low)).clamp(0.0, 1.0);
  double xAt(_Point p) => numericX
      ? left + (p.x - xLow) / (xHigh - xLow) * plotWidth
      : left + (p.dataIndex + 0.5) / count * plotWidth;
  double yAt(double v) => bottom - ratio(v) * plotHeight;
  double barX(double v) => left + ratio(v) * plotWidth;
  final base = yAt(0);
  final background = <_Shape>[];
  final marks = <_Mark>[];
  final layers = <_Layer>[];
  if (c.showAxes) {
    for (final value in ticks) {
      final x = left + ratio(value) * plotWidth, y = yAt(value);
      background
        ..add(
          _segment(
            Offset(horizontal ? x : left, horizontal ? top : y),
            Offset(horizontal ? x : right, horizontal ? bottom : y),
            _Ink.grid,
            dash: const [3, 6],
          ),
        )
        ..add(
          _TextShape(
            _shortLabel(format(value), 10),
            Offset(
              horizontal ? x : left - 10,
              horizontal ? bottom + 23 : y + 4,
            ),
            role: _TextRole.axis,
            anchor: horizontal ? _Anchor.middle : _Anchor.end,
          ),
        );
    }
    if (low < 0 && high > 0) {
      background.add(
        _segment(
          Offset(horizontal ? barX(0) : left, horizontal ? top : base),
          Offset(horizontal ? barX(0) : right, horizontal ? bottom : base),
          _Ink.zero,
          width: 1.5,
        ),
      );
    }
    if (numericX) {
      for (var i = 0; i <= 4; i++) {
        final value = xLow + (xHigh - xLow) * i / 4;
        final label =
            data._xFormatter?.call(value) ??
            (type == IslandChartType.time ? _clock(value) : format(value));
        background.add(
          _TextShape(
            _shortLabel(label, 10),
            Offset(left + plotWidth * i / 4, bottom + 24),
            role: _TextRole.axis,
          ),
        );
      }
    } else {
      final step = math.max(
        1,
        (count /
                math.max(
                  2,
                  ((horizontal ? plotHeight : plotWidth) /
                          (horizontal ? 30 : 70))
                      .floor(),
                ))
            .ceil(),
      );
      for (var i = 0; i < count; i += step) {
        final label = i < categories.length
            ? categories[i]
            : points.where((p) => p.dataIndex == i).firstOrNull?.name ??
                  '${i + 1}';
        background.add(
          _TextShape(
            _shortLabel(label, horizontal ? 7 : 8),
            Offset(
              horizontal ? left - 12 : left + (i + 0.5) * plotWidth / count,
              horizontal
                  ? top + (i + 0.5) * plotHeight / count + 4
                  : bottom + 24,
            ),
            role: _TextRole.axis,
            anchor: horizontal ? _Anchor.end : _Anchor.middle,
          ),
        );
      }
    }
  }
  final accumulated = <int, List<double>>{};
  final columnGroups = [
    for (final i in groups)
      if (type != IslandChartType.mix ||
          series[i].mode == IslandChartSeriesMode.column)
        i,
  ];
  for (final seriesIndex in groups) {
    final layer = <_Shape>[];
    final mode = type == IslandChartType.mix
        ? switch (series[seriesIndex].mode) {
            IslandChartSeriesMode.column => IslandChartType.column,
            IslandChartSeriesMode.line => IslandChartType.line,
            IslandChartSeriesMode.area => IslandChartType.area,
          }
        : type;
    final seriesPoints = [
      for (final p in points)
        if (p.seriesIndex == seriesIndex) p,
    ];
    if (numericX) {
      mergeSort(seriesPoints, compare: (a, b) => a.x.compareTo(b.x));
    } else {
      mergeSort(
        seriesPoints,
        compare: (a, b) => a.dataIndex.compareTo(b.dataIndex),
      );
    }
    if (mode == IslandChartType.line ||
        mode == IslandChartType.area ||
        mode == IslandChartType.time) {
      final segments = <List<_Point>>[];
      for (final p in seriesPoints) {
        if (segments.isEmpty ||
            (!numericX && p.dataIndex != segments.last.last.dataIndex + 1)) {
          segments.add([p]);
        } else {
          segments.last.add(p);
        }
      }
      final color = _Tone.data(seriesPoints.first.color);
      for (final segment in segments) {
        final coords = [for (final p in segment) Offset(xAt(p), yAt(p.value))];
        if (mode == IslandChartType.area) {
          final area = _linePath(coords, smooth)
            ..lineTo(coords.last.dx, base)
            ..lineTo(coords.first.dx, base)
            ..close();
          layer.add(_PathShape(area, fill: color, fillOpacity: 0.18));
        }
        layer.add(
          _PathShape(
            _linePath(coords, smooth),
            stroke: color,
            strokeWidth: 3,
            round: true,
          ),
        );
      }
    }
    if (layer.isNotEmpty) layers.add(_Layer(seriesIndex, layer));
    for (final p in seriesPoints) {
      final x = xAt(p), y = yAt(p.value);
      var anchorX = x, anchorY = y;
      final shapes = <_Shape>[];
      final tone = _Tone.data(p.color);
      if (mode == IslandChartType.column || mode == IslandChartType.bar) {
        final slot = (horizontal ? plotHeight : plotWidth) / count;
        final groupCount = stackedBars
            ? 1
            : math.max(
                1,
                type == IslandChartType.mix
                    ? columnGroups.length
                    : groups.length,
              );
        final groupIndex = stackedBars
            ? 0
            : (type == IslandChartType.mix ? columnGroups : groups).indexOf(
                seriesIndex,
              );
        final breadth = math.max(1.0, math.min(42.0, slot * 0.7 / groupCount));
        final before = accumulated.putIfAbsent(p.dataIndex, () => [0, 0]);
        final side = p.value < 0 ? 0 : 1;
        final start = stackedBars ? before[side] : 0.0;
        final end = start + p.value;
        before[side] = end;
        final offset = (groupIndex - (groupCount - 1) / 2) * breadth;
        final radius = stackedBars ? 2.0 : math.min(9.0, breadth / 2);
        if (horizontal) {
          anchorX = barX(end);
          anchorY = top + (p.dataIndex + 0.5) * slot + offset;
          shapes.add(
            _PathShape(
              _roundedRect(
                math.min(barX(start), anchorX),
                anchorY - breadth * 0.43,
                (anchorX - barX(start)).abs(),
                breadth * 0.86,
                radius,
              ),
              fill: tone,
            ),
          );
        } else {
          anchorX = x + offset;
          anchorY = yAt(end);
          shapes.add(
            _PathShape(
              _roundedRect(
                anchorX - breadth * 0.43,
                math.min(yAt(start), anchorY),
                breadth * 0.86,
                (yAt(start) - anchorY).abs(),
                radius,
              ),
              fill: tone,
            ),
          );
        }
      } else if (mode == IslandChartType.mount) {
        final half = plotWidth / count * 0.43;
        final outline = Path()..moveTo(x - half, base);
        if (smooth) {
          outline
            ..cubicTo(x - half * 0.5, base, x - half * 0.5, y, x, y)
            ..cubicTo(x + half * 0.5, y, x + half * 0.5, base, x + half, base);
        } else {
          outline
            ..quadraticBezierTo(x - half * 0.4, base, x, y)
            ..quadraticBezierTo(x + half * 0.4, base, x + half, base);
        }
        outline.close();
        shapes.add(
          _PathShape(
            outline,
            fill: tone,
            fillOpacity: 0.75,
            stroke: tone,
            strokeWidth: 2,
          ),
        );
      } else if (mode == IslandChartType.candle && p.candle != null) {
        final candle = p.candle!;
        final breadth = math.max(
          2.0,
          math.min(24.0, plotWidth / count / groups.length * 0.6),
        );
        anchorX +=
            (groups.indexOf(seriesIndex) - (groups.length - 1) / 2) * breadth;
        final ink = candle.close >= candle.open
            ? _Ink.candleRise
            : _Ink.candleFall;
        shapes
          ..add(
            _segment(
              Offset(anchorX, yAt(candle.high)),
              Offset(anchorX, yAt(candle.low)),
              ink,
              width: 2,
            ),
          )
          ..add(
            _PathShape(
              _roundedRect(
                anchorX - breadth / 2,
                math.min(yAt(candle.open), yAt(candle.close)),
                breadth,
                math.max(2, (yAt(candle.open) - yAt(candle.close)).abs()),
                2,
              ),
              fill: _Tone.ink(ink),
            ),
          );
      } else {
        final radius = mode == IslandChartType.bubble
            ? math.sqrt(p.size / maxBubbleSize) * 22
            : mode == IslandChartType.scatter
            ? 6.0
            : 4.0;
        shapes.add(
          _PathShape(
            Path()
              ..addOval(Rect.fromCircle(center: Offset(x, y), radius: radius)),
            fill: tone,
            fillOpacity: mode == IslandChartType.bubble ? 0.55 : 1,
            stroke: mode == IslandChartType.bubble
                ? tone
                : const _Tone.ink(_Ink.separator),
            strokeWidth: 2,
          ),
        );
      }
      if (c.showLabels) {
        shapes.add(
          _TextShape(
            _shortLabel(format(p.value)),
            Offset(anchorX, anchorY - 12),
            role: _TextRole.value,
          ),
        );
      }
      marks.add(
        _Mark(
          key: '$seriesIndex-${p.dataIndex}',
          point: p,
          x: anchorX,
          y: anchorY,
          axisPosition: horizontal
              ? top + (p.dataIndex + 0.5) * plotHeight / count
              : x,
          shapes: shapes,
        ),
      );
    }
  }
  return _Scene(
    background: background,
    marks: marks,
    layers: layers,
    plot: _Plot(left, right, top, bottom, horizontal),
  );
}
