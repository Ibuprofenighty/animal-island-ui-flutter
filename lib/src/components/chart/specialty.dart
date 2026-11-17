part of 'chart.dart';

/// Funnel stages keep input order; width follows the value (reference
/// `Specialty.tsx` `funnelScene`).
_Scene _funnelScene(_SceneContext c) {
  final points = c.points;
  final max = points.fold<double>(0, (m, p) => math.max(m, p.value));
  if (max == 0) return _Scene();
  final step = (c.height - 40) / math.max(1, points.length);
  final span = c.width * 0.7;
  final cx = c.width / 2;
  final marks = <_Mark>[];
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    final upper = p.value / max * span;
    final next = i + 1 < points.length ? points[i + 1].value : p.value * 0.75;
    final lower = p.value == 0 ? 0.0 : next / max * span;
    final y = 20 + i * step;
    marks.add(
      _Mark(
        key: 'funnel-${p.dataIndex}',
        point: p,
        x: cx,
        y: y + step / 2,
        shapes: [
          _PathShape(
            Path()
              ..moveTo(cx - upper / 2, y)
              ..lineTo(cx + upper / 2, y)
              ..lineTo(cx + lower / 2, y + step - 5)
              ..lineTo(cx - lower / 2, y + step - 5)
              ..close(),
            fill: _Tone.data(p.color),
            fillOpacity: 0.55,
            stroke: _Tone.data(p.color),
            strokeWidth: 1.5,
            round: true,
          ),
          _TextShape(
            '${_shortLabel(p.name, 12)}'
            '${c.showLabels ? ' · ${c.format(p.value)}' : ''}',
            Offset(cx, y + step / 2 + 4),
            role: _TextRole.value,
          ),
        ],
      ),
    );
  }
  return _Scene(marks: marks);
}

/// Deterministic spiral placement with rectangle collision avoidance
/// (reference `wordScene`).
_Scene _wordScene(_SceneContext c) {
  final width = c.width, height = c.height;
  final boxes = <Rect>[];
  final max = c.points.fold<double>(1, (m, p) => math.max(m, p.value));
  final marks = <_Mark>[];
  final words = [
    for (final p in c.points)
      if (p.value > 0) p,
  ];
  mergeSort(words, compare: (a, b) => b.value.compareTo(a.value));
  for (final p in words) {
    final text = _shortLabel(p.name, 16);
    final units = text.runes.fold<double>(
      0,
      (sum, ch) => sum + (ch > 127 ? 1 : 0.7),
    );
    var fontSize = [
      44.0,
      14 + math.sqrt(p.value / max) * 30,
      (width - 30) / math.max(1, units),
    ].reduce(math.min);
    Rect? box;
    while (fontSize >= 12 && box == null) {
      final w = units * fontSize + 12, h = fontSize * 1.5;
      for (var i = 0; i < 1200; i++) {
        final angle = i * 0.55, radius = 4.2 * math.sqrt(i);
        final x = width / 2 + math.cos(angle) * radius * 2 - w / 2;
        final y = height / 2 + math.sin(angle) * radius - h / 2;
        if (x < 10 || x + w > width - 10 || y < 10 || y + h > height - 10) {
          continue;
        }
        if (boxes.any(
          (b) => x < b.right && x + w > b.left && y < b.bottom && y + h > b.top,
        )) {
          continue;
        }
        box = Rect.fromLTWH(x, y, w, h);
        break;
      }
      if (box == null) fontSize -= 3;
    }
    if (box == null) continue;
    boxes.add(box);
    marks.add(
      _Mark(
        key: 'word-${p.dataIndex}',
        point: p,
        x: box.center.dx,
        y: box.center.dy,
        shapes: [
          _TextShape(
            text,
            box.center,
            role: _TextRole.word,
            central: true,
            color: p.color,
            fontSize: fontSize,
          ),
        ],
      ),
    );
  }
  return _Scene(marks: marks);
}

/// Fits caller planar outlines at one scale; y points up (reference
/// `mapScene`).
_Scene _mapScene(_SceneContext c) {
  final width = c.width, height = c.height;
  final regions = [
    for (final region in c.data._regions)
      if ([
            for (final ring in region.polygons)
              if (ring.length >= 3 &&
                  ring.every((o) => o.dx.isFinite && o.dy.isFinite))
                ring,
          ]
          case final rings when rings.isNotEmpty)
        (region.name, rings),
  ];
  final coordinates = [
    for (final (_, rings) in regions)
      for (final ring in rings) ...ring,
  ];
  if (coordinates.isEmpty) return _Scene();
  final (xMin, xMax) = _extent(
    [for (final o in coordinates) o.dx],
    null,
    null,
    false,
  );
  final (yMin, yMax) = _extent(
    [for (final o in coordinates) o.dy],
    null,
    null,
    false,
  );
  final scale = math.min(
    (width - 48) / (xMax - xMin),
    (height - 40) / (yMax - yMin),
  );
  Offset project(Offset o) => Offset(
    width / 2 + (o.dx - (xMin + xMax) / 2) * scale,
    height / 2 - (o.dy - (yMin + yMax) / 2) * scale,
  );
  final (low, high) = _extent([for (final p in c.points) p.value]);
  final background = <_Shape>[];
  final marks = <_Mark>[];
  for (var i = 0; i < regions.length; i++) {
    final (name, rings) = regions[i];
    final projected = [
      for (final ring in rings) [for (final o in ring) project(o)],
    ];
    final path = Path()..fillType = PathFillType.evenOdd;
    for (final ring in projected) {
      path.addPolygon(ring, true);
    }
    final vertices = [for (final ring in projected) ...ring];
    final x = vertices.fold<double>(0, (s, o) => s + o.dx) / vertices.length;
    final y = vertices.fold<double>(0, (s, o) => s + o.dy) / vertices.length;
    final point = c.points.where((p) => p.name == name).firstOrNull;
    final shapes = <_Shape>[
      _PathShape(
        path,
        fill: point == null
            ? const _Tone.ink(_Ink.track)
            : _Tone.data(point.color),
        fillOpacity: point == null
            ? 1
            : 0.3 + ((point.value - low) / (high - low)).clamp(0.0, 1.0) * 0.65,
        stroke: const _Tone.ink(_Ink.separator),
        strokeWidth: 3,
        round: true,
        evenOdd: true,
      ),
      if (c.showLabels)
        _TextShape(_shortLabel(name, 8), Offset(x, y), role: _TextRole.value),
    ];
    if (point != null) {
      marks.add(
        _Mark(key: 'region-$i', point: point, x: x, y: y, shapes: shapes),
      );
    } else {
      background.addAll(shapes);
    }
  }
  return _Scene(background: background, marks: marks);
}
