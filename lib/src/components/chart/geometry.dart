part of 'chart.dart';

const _itemTypes = {
  IslandChartType.pie,
  IslandChartType.ring,
  IslandChartType.rose,
  IslandChartType.funnel,
  IslandChartType.word,
  IslandChartType.map,
};

const _axisTypes = {
  IslandChartType.column,
  IslandChartType.bar,
  IslandChartType.line,
  IslandChartType.area,
  IslandChartType.mount,
  IslandChartType.mix,
  IslandChartType.scatter,
  IslandChartType.bubble,
  IslandChartType.candle,
  IslandChartType.time,
};

const _coordinateTypes = {
  IslandChartType.scatter,
  IslandChartType.bubble,
  IslandChartType.time,
};

bool _finite(double? value) => value != null && value.isFinite;

/// One input series in the shape every chart family shares.
class _Series {
  const _Series(this.name, this.color, this.mode, this.data);
  final String name;
  final Color? color;
  final IslandChartSeriesMode mode;
  final List<Object?> data;
}

List<_Series> _seriesOf(IslandChartData data) => [
  for (final s in data._values) _Series(s.name, s.color, s.mode, s.data),
  for (final s in data._points)
    _Series(s.name, s.color, IslandChartSeriesMode.column, s.data),
  for (final s in data._candles)
    _Series(s.name, s.color, IslandChartSeriesMode.column, s.data),
];

/// A valid, drawable datum; keeps its original indices for events and
/// category gaps.
class _Point {
  _Point({
    required this.type,
    required this.seriesIndex,
    required this.dataIndex,
    required this.seriesName,
    required this.name,
    required this.value,
    required this.datum,
    required this.color,
    required this.x,
    required this.size,
    this.candle,
  });
  final IslandChartType type;
  final int seriesIndex, dataIndex;
  final String seriesName, name;
  final double value, x, size;
  final Object datum;
  final Color color;
  final IslandChartCandle? candle;

  IslandChartDataEvent get event => IslandChartDataEvent(
    type: type,
    seriesIndex: seriesIndex,
    dataIndex: dataIndex,
    seriesName: seriesName,
    name: name,
    value: value,
    datum: datum,
  );
}

/// Port of the reference `normalize`: invalid data keeps its index but is
/// neither drawn nor counted in ranges.
List<_Point> _normalize(
  IslandChartData data,
  List<_Series> series,
  List<Color> palette,
) {
  final type = data.type;
  final categories = data._categories;
  final points = <_Point>[];
  final coordinate = _coordinateTypes.contains(type);
  final item = _itemTypes.contains(type);
  for (var s = 0; s < series.length; s++) {
    final entry = series[s];
    for (var i = 0; i < entry.data.length; i++) {
      final datum = entry.data[i];
      if (datum == null) continue;
      final candle = datum is IslandChartCandle ? datum : null;
      final point = datum is IslandChartPoint ? datum : null;
      final valueDatum = datum is IslandChartValue ? datum : null;
      final value = candle?.close ?? point?.y ?? valueDatum?.value;
      final x = point?.x ?? i.toDouble();
      if (!_finite(value) || !_finite(x)) continue;
      if (coordinate && point == null) continue;
      if (type == IslandChartType.time && _instant(x) == null) continue;
      if (type == IslandChartType.bubble &&
          point?.size != null &&
          (!_finite(point!.size) || point.size! <= 0)) {
        continue;
      }
      if (type == IslandChartType.candle &&
          (candle == null ||
              ![
                candle.open,
                candle.close,
                candle.low,
                candle.high,
              ].every(_finite) ||
              candle.low > math.min(candle.open, candle.close) ||
              candle.high < math.max(candle.open, candle.close))) {
        continue;
      }
      if (((item && type != IslandChartType.map) ||
              type == IslandChartType.radar) &&
          value! < 0) {
        continue;
      }
      final ownName = candle?.name ?? point?.name ?? valueDatum?.name;
      final ownColor = point?.color ?? valueDatum?.color;
      points.add(
        _Point(
          type: type,
          seriesIndex: s,
          dataIndex: i,
          seriesName: entry.name,
          name: ownName ?? (i < categories.length ? categories[i] : '${i + 1}'),
          value: value!,
          datum: datum,
          color:
              ownColor ??
              entry.color ??
              palette[(item ? i : s) % palette.length],
          x: x,
          size: _finite(point?.size) && point!.size! > 0 ? point.size! : 1,
          candle: candle,
        ),
      );
    }
  }
  return item ? points.where((p) => p.seriesIndex == 0).toList() : points;
}

/// Readable range; negatives kept, constant data widened to a non-zero span.
(double, double) _extent(
  List<double> values, [
  double? min,
  double? max,
  bool zero = true,
]) {
  var low = zero || values.isEmpty ? 0.0 : values.first;
  var high = low;
  for (final v in values) {
    low = math.min(low, v);
    high = math.max(high, v);
  }
  if (_finite(min)) low = min!;
  if (_finite(max)) high = max!;
  if (high <= low) high = low + math.max(1, low.abs() * 0.1);
  return (low, high);
}

int _floorLog10(double value) {
  var e = (math.log(value) / math.ln10).floor();
  if (math.pow(10, e + 1) <= value) e++;
  if (math.pow(10, e) > value) e--;
  return e;
}

/// Automatic axes use 1/2/2.5/5 decimal steps; explicit bounds keep the
/// caller's range in four equal steps.
List<double> _axisTicks(List<double> values, [double? min, double? max]) {
  final (low, high) = _extent(values, min, max);
  if (_finite(min) || _finite(max)) {
    return [for (var i = 0; i < 5; i++) low + (high - low) * i / 4];
  }
  final target = (high - low) / 4;
  final magnitude = math.pow(10, _floorLog10(target)).toDouble();
  final multiple = [
    1,
    2,
    2.5,
    5,
    10,
  ].firstWhere((m) => m * magnitude >= target, orElse: () => 10);
  final step = multiple * magnitude;
  final start = (low / step).floor();
  final end = (high / step).ceil();
  return [
    for (var i = 0; i <= end - start; i++)
      double.parse(((start + i) * step).toStringAsPrecision(12)),
  ];
}

/// Truncates by code point; the full name stays in tooltips and semantics.
String _shortLabel(String text, [int max = 9]) {
  final letters = text.runes.toList();
  return letters.length > max
      ? '${String.fromCharCodes(letters.take(max))}…'
      : text;
}

/// Projects an angle measured clockwise from twelve o'clock.
Offset _polar(double cx, double cy, double radius, double angle) =>
    Offset(cx + radius * math.sin(angle), cy - radius * math.cos(angle));

/// Arc split at its midpoint so a full circle still draws.
Path _arc(double cx, double cy, double radius, double start, double end) {
  final r = Radius.circular(radius);
  final a = _polar(cx, cy, radius, start);
  final mid = _polar(cx, cy, radius, (start + end) / 2);
  final b = _polar(cx, cy, radius, end);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..arcToPoint(mid, radius: r)
    ..arcToPoint(b, radius: r);
}

/// Closed sector or ring sector; a single item may fill the whole circle.
Path _sector(
  double cx,
  double cy,
  double outer,
  double inner,
  double start,
  double end,
) {
  final path = _arc(cx, cy, outer, start, end);
  if (inner > 0) {
    final a = _polar(cx, cy, inner, end);
    final b = _polar(cx, cy, inner, (start + end) / 2);
    final c = _polar(cx, cy, inner, start);
    final r = Radius.circular(inner);
    path
      ..lineTo(a.dx, a.dy)
      ..arcToPoint(b, radius: r, clockwise: false)
      ..arcToPoint(c, radius: r, clockwise: false);
  } else {
    path.lineTo(cx, cy);
  }
  return path..close();
}

/// Straight or horizontal-control-point curve through [points].
Path _linePath(List<Offset> points, bool smooth, [Path? into]) {
  final path = into ?? Path();
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    if (i == 0) {
      path.moveTo(p.dx, p.dy);
    } else if (smooth) {
      final q = points[i - 1];
      final mx = (q.dx + p.dx) / 2;
      path.cubicTo(mx, q.dy, mx, p.dy, p.dx, p.dy);
    } else {
      path.lineTo(p.dx, p.dy);
    }
  }
  return path;
}

/// Colour roles a scene refers to; resolved from [ChartColors] when painting.
enum _Ink {
  grid,
  zero,
  axisText,
  valueText,
  centerText,
  surface,
  separator,
  track,
  gaugeTick,
  needle,
  candleRise,
  candleFall,
}

/// A colour that is either caller/palette data or a theme role.
class _Tone {
  const _Tone.data(Color this.color) : ink = null;
  const _Tone.ink(_Ink this.ink) : color = null;
  final Color? color;
  final _Ink? ink;
}

sealed class _Shape {
  const _Shape();
  Rect get bounds;
}

class _PathShape extends _Shape {
  const _PathShape(
    this.path, {
    this.fill,
    this.fillOpacity = 1,
    this.stroke,
    this.strokeWidth = 0,
    this.round = false,
    this.dash,
    this.evenOdd = false,
  });
  final Path path;
  final _Tone? fill, stroke;
  final double fillOpacity, strokeWidth;
  final bool round, evenOdd;
  final List<double>? dash;
  @override
  Rect get bounds =>
      path.getBounds().inflate(stroke == null ? 0 : strokeWidth / 2);
}

enum _Anchor { start, middle, end }

enum _TextRole { axis, value, center, centerValue, word }

class _TextShape extends _Shape {
  const _TextShape(
    this.text,
    this.at, {
    required this.role,
    this.anchor = _Anchor.middle,
    this.central = false,
    this.color,
    this.fontSize,
  });
  final String text;
  final Offset at;
  final _TextRole role;
  final _Anchor anchor;
  final bool central;
  final Color? color;
  final double? fontSize;

  double get size =>
      fontSize ??
      switch (role) {
        _TextRole.axis => 11,
        _TextRole.value || _TextRole.center => 12,
        _TextRole.centerValue => 24,
        _TextRole.word => 12,
      };

  /// Layout-free estimate used for hit areas and focus bounds only.
  @override
  Rect get bounds {
    final width = text.runes.fold<double>(
      0,
      (sum, c) => sum + (c > 127 ? 1 : 0.6) * size,
    );
    final height = size * 1.2;
    final left = switch (anchor) {
      _Anchor.start => at.dx,
      _Anchor.middle => at.dx - width / 2,
      _Anchor.end => at.dx - width,
    };
    final top = central ? at.dy - height / 2 : at.dy - size * 0.9;
    return Rect.fromLTWH(left, top, width, height);
  }
}

/// A focusable data mark with its tooltip anchor.
class _Mark {
  _Mark({
    required this.key,
    required this.point,
    required this.x,
    required this.y,
    required this.shapes,
    this.axisPosition,
  });
  final String key;
  final _Point point;
  final double x, y;
  final double? axisPosition;
  final List<_Shape> shapes;

  /// Transparent 12px target around small marks and zeros (reference).
  bool hitHalo = false;

  late final String identity = jsonEncode([
    point.type.name,
    point.seriesName,
    point.name,
    key,
  ]);

  Rect get bounds {
    var rect = shapes.isEmpty
        ? Rect.fromCircle(center: Offset(x, y), radius: 1)
        : shapes.map((s) => s.bounds).reduce((a, b) => a.expandToInclude(b));
    if (hitHalo) {
      rect = rect.expandToInclude(
        Rect.fromCircle(center: Offset(x, y), radius: 12),
      );
    }
    return rect;
  }

  /// SVG hit testing of the reference mark: a fill hits inside its path, a
  /// stroke within half its width of the path (fill="none" paths hit on the
  /// stroke only), text on its box; value labels never hit
  /// (`.chart-value-label { pointer-events: none }`).
  bool hit(Offset at) {
    if (hitHalo && (at - Offset(x, y)).distance <= 12) return true;
    for (final s in shapes) {
      final inside = switch (s) {
        _TextShape(role: _TextRole.value) => false,
        _TextShape() => s.bounds.contains(at),
        _PathShape() =>
          s.bounds.contains(at) &&
              ((s.fill != null && s.path.contains(at)) ||
                  (s.stroke != null &&
                      _nearStroke(s.path, at, s.strokeWidth / 2, s.round))),
      };
      if (inside) return true;
    }
    return false;
  }
}

/// Whether [at] lies within [halfWidth] of [path]'s outline. Butt caps end
/// flush with an open subpath; round caps and joins extend by [halfWidth].
bool _nearStroke(Path path, Offset at, double halfWidth, bool round) {
  for (final metric in path.computeMetrics()) {
    final steps = math.max(1, (metric.length / 2).ceil());
    Offset point(int i) =>
        metric.getTangentForOffset(metric.length * i / steps)!.position;
    var previous = point(0);
    for (var i = 1; i <= steps; i++) {
      final next = point(i);
      final segment = next - previous;
      final lengthSquared = segment.distanceSquared;
      final t = lengthSquared == 0
          ? 0.0
          : ((at - previous).dx * segment.dx +
                    (at - previous).dy * segment.dy) /
                lengthSquared;
      final butt = !round && !metric.isClosed;
      final outside = (i == 1 && t < 0) || (i == steps && t > 1);
      if (!(butt && outside) &&
          (at - (previous + segment * t.clamp(0.0, 1.0))).distance <=
              halfWidth) {
        return true;
      }
      previous = next;
    }
  }
  return false;
}

class _Plot {
  const _Plot(this.left, this.right, this.top, this.bottom, this.horizontal);
  final double left, right, top, bottom;
  final bool horizontal;
}

class _PolarPlot {
  const _PolarPlot(this.cx, this.cy, this.radius, this.count);
  final double cx, cy, radius;
  final int count;
}

class _Layer {
  const _Layer(this.seriesIndex, this.shapes);
  final int seriesIndex;
  final List<_Shape> shapes;
}

class _Scene {
  _Scene({
    this.background = const [],
    this.marks = const [],
    this.layers = const [],
    this.emptyRegions = const [],
    this.plot,
    this.polarPlot,
  });
  final List<_Shape> background;

  /// Map regions without data, by outline and name: the reference wraps each
  /// in a `<g>` with `<title>{name}：暂无数据</title>` (hover text and
  /// accessible name).
  final List<(Path, String)> emptyRegions;
  final List<_Mark> marks;
  final List<_Layer> layers;
  final _Plot? plot;
  final _PolarPlot? polarPlot;
}

class _SceneContext {
  const _SceneContext({
    required this.data,
    required this.series,
    required this.points,
    required this.width,
    required this.height,
    required this.format,
    required this.showAxes,
    required this.showLabels,
    required this.strings,
  });
  final IslandChartData data;
  final List<_Series> series;
  final List<_Point> points;
  final double width, height;
  final String Function(double) format;
  final bool showAxes, showLabels;
  final IslandLocalizations strings;
}

/// Legend identity: type and series name, plus index and name for item
/// legends, so hidden entries survive data updates but not a kind change.
String _legendKey(
  IslandChartData data,
  List<_Series> series,
  int seriesIndex,
  String name, [
  int? index,
]) =>
    '${data.type.name}:'
    '${seriesIndex < series.length ? series[seriesIndex].name : ''}:'
    '${_itemTypes.contains(data.type) ? '$index:$name' : 'series'}';

/// Everything that shapes the scene. [data] compares by identity (it is
/// immutable by contract); [palette] and [hidden] by content; [format] like
/// any function value; [strings] by locale.
@immutable
class _SceneInputs {
  const _SceneInputs({
    required this.data,
    required this.palette,
    required this.hidden,
    required this.width,
    required this.height,
    required this.format,
    required this.showAxes,
    required this.showLabels,
    required this.strings,
  });
  final IslandChartData data;
  final List<Color> palette;
  final Set<String> hidden;
  final double width, height;
  final String Function(double) format;
  final bool showAxes, showLabels;
  final IslandLocalizations strings;

  @override
  bool operator ==(Object other) =>
      other is _SceneInputs &&
      identical(other.data, data) &&
      listEquals(other.palette, palette) &&
      setEquals(other.hidden, hidden) &&
      other.width == width &&
      other.height == height &&
      other.format == format &&
      other.showAxes == showAxes &&
      other.showLabels == showLabels &&
      other.strings.locale == strings.locale;

  @override
  int get hashCode => Object.hash(
    identityHashCode(data),
    Object.hashAll(palette),
    Object.hashAllUnordered(hidden),
    width,
    height,
    format,
    showAxes,
    showLabels,
    strings.locale,
  );
}

/// The normalised data, scene, reading names and data table rows of one
/// [_SceneInputs].
class _Derived {
  const _Derived({
    required this.inputs,
    required this.all,
    required this.visible,
    required this.scene,
    required this.labels,
    required this.rows,
  });
  final _SceneInputs inputs;
  final List<_Point> all, visible;
  final _Scene scene;

  /// Accessible name per scene mark, in mark order.
  final List<String> labels;

  /// Data table rows per valid datum, hidden ones included.
  final List<(String, String, String)> rows;
}

_Scene _buildScene(_SceneContext c) => switch (c.data.type) {
  final t when _axisTypes.contains(t) => _cartesianScene(c),
  IslandChartType.pie ||
  IslandChartType.ring ||
  IslandChartType.rose => _pieScene(c),
  IslandChartType.radar => _radarScene(c),
  IslandChartType.gauge || IslandChartType.arcbar => _gaugeScene(c),
  IslandChartType.funnel => _funnelScene(c),
  IslandChartType.word => _wordScene(c),
  _ => _mapScene(c),
};
