part of 'chart.dart';

/// Kinds that compare readings at the same category, time or dimension;
/// equal scatter/bubble x values are not the same category.
const _sharedTypes = {
  IslandChartType.column,
  IslandChartType.bar,
  IslandChartType.line,
  IslandChartType.area,
  IslandChartType.mount,
  IslandChartType.mix,
  IslandChartType.candle,
  IslandChartType.time,
  IslandChartType.radar,
};

/// Readings compared with [active]: the same timestamp for time charts,
/// otherwise the same data index.
List<_Mark> _relatedMarks(List<_Mark> marks, _Mark active, bool shared) {
  if (!shared) return [active];
  return [
    for (final mark in marks)
      if (active.point.type == IslandChartType.time
          ? mark.point.x == active.point.x
          : mark.point.dataIndex == active.point.dataIndex)
        mark,
  ];
}

/// Nearest mark to a plot position: by category column/row or radar angle
/// when shared, otherwise within 24px.
_Mark? _nearestMark(_Scene scene, double x, double y, bool shared) {
  final plot = scene.plot, polar = scene.polarPlot;
  if (polar != null) {
    if (math.sqrt(math.pow(x - polar.cx, 2) + math.pow(y - polar.cy, 2)) >
        polar.radius) {
      return null;
    }
  } else if (plot == null ||
      x < plot.left ||
      x > plot.right ||
      y < plot.top ||
      y > plot.bottom) {
    return null;
  }
  final angle = polar != null ? math.atan2(x - polar.cx, polar.cy - y) : 0.0;
  double hypot(_Mark m) =>
      math.sqrt(math.pow(x - m.x, 2) + math.pow(y - m.y, 2));
  _Mark? nearest;
  var distance = double.infinity;
  for (final mark in scene.marks) {
    var value = hypot(mark);
    if (shared && polar != null) {
      value =
          1 -
          math.cos(angle - math.pi * 2 * mark.point.dataIndex / polar.count);
    } else if (shared && plot != null) {
      value = ((plot.horizontal ? y : x) - (mark.axisPosition ?? mark.x)).abs();
    }
    if (value < distance ||
        (value == distance &&
            nearest != null &&
            hypot(mark) < hypot(nearest))) {
      nearest = mark;
      distance = value;
    }
  }
  return shared || distance <= 24 ? nearest : null;
}
