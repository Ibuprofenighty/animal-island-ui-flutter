part of 'chart.dart';

/// Pie, ring and rose share one sector model; zero values draw nothing
/// (reference `Polar.tsx` `pieScene`).
_Scene _pieScene(_SceneContext c) {
  final type = c.data.type;
  final data = [
    for (final p in c.points)
      if (p.value > 0) p,
  ];
  final total = data.fold<double>(0, (sum, p) => sum + p.value);
  final radius = math.max(20.0, math.min(c.width / 2 - 70, c.height / 2 - 26));
  final cx = c.width / 2, cy = c.height / 2;
  var angle = 0.0;
  var max = data.fold<double>(0, (largest, p) => math.max(largest, p.value));
  if (max == 0) max = 1;
  final marks = <_Mark>[];
  for (final p in data) {
    final end =
        angle +
        math.pi *
            2 *
            (type == IslandChartType.rose ? 1 / data.length : p.value / total);
    final outer = type == IslandChartType.rose
        ? radius * math.sqrt(p.value / max)
        : radius;
    final inner = type == IslandChartType.ring ? radius * 0.66 : 0.0;
    final center = (angle + end) / 2;
    final anchor = _polar(cx, cy, (inner + outer) / 2, center);
    final label = _polar(cx, cy, outer + 15, center);
    marks.add(
      _Mark(
        key: 'slice-${p.dataIndex}',
        point: p,
        x: anchor.dx,
        y: anchor.dy,
        shapes: [
          _PathShape(
            _sector(cx, cy, outer, math.min(inner, outer * 0.9), angle, end),
            fill: _Tone.data(p.color),
            stroke: const _Tone.ink(_Ink.separator),
            strokeWidth: 3,
            round: true,
          ),
          if (c.showLabels)
            _TextShape(
              _shortLabel(p.name, 7),
              label,
              role: _TextRole.value,
              anchor: label.dx < cx ? _Anchor.end : _Anchor.start,
            ),
        ],
      ),
    );
    angle = end;
  }
  return _Scene(
    marks: marks,
    background: type == IslandChartType.ring && total > 0
        ? [
            _TextShape(
              _shortLabel(c.format(total), 12),
              Offset(cx, cy - 8),
              role: _TextRole.centerValue,
              central: true,
            ),
            _TextShape(
              '合计',
              Offset(cx, cy + 16),
              role: _TextRole.center,
              central: true,
            ),
          ]
        : const [],
  );
}

/// Radar on one shared range; an incomplete series draws only its points
/// (reference `radarScene`).
_Scene _radarScene(_SceneContext c) {
  final categories = c.data._categories;
  final count = [
    categories.length,
    for (final s in c.series) s.data.length,
  ].fold<int>(0, math.max);
  if (count < 3) return _Scene();
  final cx = c.width / 2, cy = c.height / 2;
  final radius = math.min(c.width / 2 - 72, c.height / 2 - 40);
  final (low, high) = _extent(
    [for (final p in c.points) p.value],
    c.data._min ?? 0,
    c.data._max,
  );
  Offset at(int index, double value) => _polar(
    cx,
    cy,
    radius * ((value - low) / (high - low)).clamp(0.0, 1.0),
    math.pi * 2 * index / count,
  );
  final background = <_Shape>[];
  for (var level = 1; level <= 4; level++) {
    final ring = Path()
      ..addPolygon([
        for (var i = 0; i < count; i++)
          _polar(cx, cy, radius * level / 4, math.pi * 2 * i / count),
      ], true);
    background.add(
      _PathShape(
        ring,
        fill: const _Tone.ink(_Ink.surface),
        fillOpacity: 0.3,
        stroke: const _Tone.ink(_Ink.grid),
        strokeWidth: 1,
      ),
    );
  }
  for (var i = 0; i < count; i++) {
    final end = _polar(cx, cy, radius, math.pi * 2 * i / count);
    final label = _polar(cx, cy, radius + 20, math.pi * 2 * i / count);
    background
      ..add(_segment(Offset(cx, cy), end, _Ink.grid))
      ..add(
        _TextShape(
          _shortLabel(
            i < categories.length
                ? categories[i]
                : c.points.where((p) => p.dataIndex == i).firstOrNull?.name ??
                      '${i + 1}',
            7,
          ),
          Offset(label.dx, label.dy + 4),
          role: _TextRole.axis,
        ),
      );
  }
  final layers = <_Layer>[];
  for (final seriesIndex in {for (final p in c.points) p.seriesIndex}) {
    final data = [
      for (final p in c.points)
        if (p.seriesIndex == seriesIndex) p,
    ];
    if (data.length == count) {
      final tone = _Tone.data(data.first.color);
      layers.add(
        _Layer(seriesIndex, [
          _PathShape(
            Path()..addPolygon([
              for (final p in data) at(p.dataIndex, p.value),
            ], true),
            fill: tone,
            fillOpacity: 0.16,
            stroke: tone,
            strokeWidth: 2.5,
          ),
        ]),
      );
    }
  }
  return _Scene(
    background: background,
    layers: layers,
    polarPlot: _PolarPlot(cx, cy, radius, count),
    marks: [
      for (final p in c.points)
        if (at(p.dataIndex, p.value) case final o)
          _Mark(
            key: '${p.seriesIndex}-${p.dataIndex}',
            point: p,
            x: o.dx,
            y: o.dy,
            shapes: [
              _PathShape(
                Path()..addOval(Rect.fromCircle(center: o, radius: 5)),
                fill: _Tone.data(p.color),
                stroke: const _Tone.ink(_Ink.separator),
                strokeWidth: 2,
              ),
            ],
          ),
    ],
  );
}

/// Arcbar and gauge clamp the drawing to the range while readings keep the
/// real value (reference `gaugeScene`).
_Scene _gaugeScene(_SceneContext c) {
  final gauge = c.data.type == IslandChartType.gauge;
  final seen = <int>{};
  var data = [
    for (final p in c.points)
      if (seen.add(p.seriesIndex)) p,
  ];
  if (gauge) data = data.take(1).toList();
  final (low, high) = _extent(const [], c.data._min ?? 0, c.data._max ?? 100);
  final background = <_Shape>[];
  final marks = <_Mark>[];
  const start = -math.pi * 0.75, end = math.pi * 0.75;
  final width = gauge ? 18.0 : 14.0;
  for (var i = 0; i < data.length; i++) {
    final p = data[i];
    final space = c.width / math.max(1, data.length);
    final cx = space * (i + 0.5), cy = c.height / 2 + 20;
    final radius = math.max(20.0, math.min(space / 2 - 22, c.height / 2 - 38));
    final fraction = ((p.value - low) / (high - low)).clamp(0.0, 1.0);
    background.add(
      _PathShape(
        _arc(cx, cy, radius, start, end),
        stroke: const _Tone.ink(_Ink.track),
        strokeWidth: width,
        round: true,
      ),
    );
    if (gauge) {
      for (var tick = 0; tick <= 8; tick++) {
        final angle = start + (end - start) * tick / 8;
        background.add(
          _segment(
            _polar(cx, cy, radius - 20, angle),
            _polar(cx, cy, radius - 27, angle),
            _Ink.gaugeTick,
            width: 2,
          ),
        );
      }
      final scale = [low, (low + high) / 2, high];
      for (var index = 0; index < 3; index++) {
        final o = _polar(
          cx,
          cy,
          radius + 16,
          start + (end - start) * index / 2,
        );
        background.add(
          _TextShape(
            _shortLabel(c.format(scale[index]), 8),
            Offset(o.dx, o.dy + 4),
            role: _TextRole.axis,
          ),
        );
      }
    }
    final needle = _polar(
      cx,
      cy,
      radius - 34,
      start + fraction * (end - start),
    );
    marks.add(
      _Mark(
        key: 'gauge-${p.seriesIndex}',
        point: p,
        x: cx,
        y: cy,
        shapes: [
          if (fraction > 0)
            _PathShape(
              _arc(cx, cy, radius, start, start + fraction * (end - start)),
              stroke: _Tone.data(p.color),
              strokeWidth: width,
              round: true,
            ),
          if (gauge) ...[
            _segment(
              Offset(cx, cy),
              needle,
              _Ink.needle,
              width: 4,
              round: true,
            ),
            _PathShape(
              Path()
                ..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: 7)),
              fill: const _Tone.ink(_Ink.needle),
            ),
          ],
          _TextShape(
            _shortLabel(c.format(p.value), 10),
            Offset(cx, cy + (gauge ? 38 : 0)),
            role: _TextRole.centerValue,
          ),
          _TextShape(
            _shortLabel(p.seriesName, 12),
            Offset(cx, cy + (gauge ? 59 : 26)),
            role: _TextRole.axis,
          ),
        ],
      ),
    );
  }
  return _Scene(background: background, marks: marks);
}
