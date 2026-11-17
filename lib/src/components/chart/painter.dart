part of 'chart.dart';

/// Per-mark emphasis read while painting.
abstract interface class _Emphasis {
  double markOpacity(String identity);
  double markShadow(String identity);
  double layerOpacity(int seriesIndex);
}

/// Paints one scene: background, series layers, crosshair, marks,
/// indicators and the keyboard focus outline, in reference SVG order.
class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.scene,
    required this.colors,
    required this.textStyle,
    required this.showBackground,
    required this.emphasis,
    required this.crosshair,
    required this.indicators,
    required this.focused,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final _Scene scene;
  final ChartColors colors;
  final TextStyle textStyle;
  final bool showBackground;
  final _Emphasis emphasis;

  /// Guide lines (start, end), already in plot coordinates.
  final List<(Offset, Offset)> crosshair;

  /// Active reading indicators.
  final List<_Mark> indicators;

  /// Mark showing a keyboard focus outline.
  final _Mark? focused;

  Color _ink(_Ink ink) => switch (ink) {
    _Ink.grid => colors.grid,
    _Ink.zero => colors.zero,
    _Ink.axisText => colors.secondaryInk,
    _Ink.valueText => colors.ink,
    _Ink.centerText => colors.secondaryInk,
    _Ink.surface => colors.surface,
    _Ink.separator => ChartColors.separator,
    _Ink.track => ChartColors.track,
    _Ink.gaugeTick => ChartColors.gaugeTick,
    _Ink.needle => colors.needle,
    _Ink.candleRise => colors.candleRise,
    _Ink.candleFall => colors.candleFall,
  };

  Color _tone(_Tone tone) => tone.color ?? _ink(tone.ink!);

  @override
  void paint(Canvas canvas, Size size) {
    if (showBackground) {
      for (final shape in scene.background) {
        _shape(canvas, shape);
      }
    }
    for (final layer in scene.layers) {
      _group(
        canvas,
        emphasis.layerOpacity(layer.seriesIndex),
        () => layer.shapes.forEach((s) => _shape(canvas, s)),
      );
    }
    for (final (a, b) in crosshair) {
      _stroke(
        canvas,
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy),
        Paint()
          ..color = colors.crosshair.withValues(alpha: 0.55)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
        const [4, 5],
      );
    }
    for (final mark in scene.marks) {
      final shadow = emphasis.markShadow(mark.identity);
      _group(canvas, emphasis.markOpacity(mark.identity), () {
        if (shadow > 0) _shadow(canvas, mark, shadow);
        for (final s in mark.shapes) {
          _shape(canvas, s);
        }
      });
    }
    for (final mark in indicators) {
      final circle = Rect.fromCircle(center: Offset(mark.x, mark.y), radius: 7);
      canvas
        ..drawOval(circle, Paint()..color = colors.surface)
        ..drawOval(
          circle,
          Paint()
            ..color = mark.point.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
    }
    if (focused case final mark?) {
      canvas.drawRect(
        mark.bounds.inflate(5),
        Paint()
          ..color = colors.focus
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  void _group(Canvas canvas, double opacity, VoidCallback draw) {
    if (opacity >= 1) {
      draw();
      return;
    }
    canvas.saveLayer(
      null,
      Paint()..color = colors.surface.withValues(alpha: opacity),
    );
    draw();
    canvas.restore();
  }

  void _shadow(Canvas canvas, _Mark mark, double strength) {
    final paint = Paint()
      ..color = ChartColors.activeShadow.withValues(
        alpha: ChartColors.activeShadow.a * strength,
      )
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    canvas
      ..save()
      ..translate(0, 2);
    for (final s in mark.shapes) {
      if (s is _PathShape) {
        if (s.fill != null) canvas.drawPath(s.path, paint);
        if (s.stroke != null) {
          canvas.drawPath(
            s.path,
            Paint()
              ..color = paint.color
              ..maskFilter = paint.maskFilter
              ..style = PaintingStyle.stroke
              ..strokeWidth = s.strokeWidth
              ..strokeCap = s.round ? StrokeCap.round : StrokeCap.butt,
          );
        }
      }
    }
    canvas.restore();
  }

  void _shape(Canvas canvas, _Shape shape) {
    switch (shape) {
      case _PathShape():
        if (shape.fill case final fill?) {
          final path = shape.evenOdd
              ? (Path.from(shape.path)..fillType = PathFillType.evenOdd)
              : shape.path;
          final color = _tone(fill);
          canvas.drawPath(
            path,
            Paint()
              ..color = color.withValues(alpha: color.a * shape.fillOpacity),
          );
        }
        if (shape.stroke case final stroke?) {
          _stroke(
            canvas,
            shape.path,
            Paint()
              ..color = _tone(stroke)
              ..style = PaintingStyle.stroke
              ..strokeWidth = shape.strokeWidth
              ..strokeCap = shape.round ? StrokeCap.round : StrokeCap.butt
              ..strokeJoin = shape.round ? StrokeJoin.round : StrokeJoin.miter,
            shape.dash,
          );
        }
      case _TextShape():
        _text(canvas, shape);
    }
  }

  void _stroke(Canvas canvas, Path path, Paint paint, List<double>? dash) {
    if (dash == null) {
      canvas.drawPath(path, paint);
      return;
    }
    final dashed = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      var i = 0;
      while (distance < metric.length) {
        final length = dash[i % dash.length];
        if (i.isEven) {
          dashed.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        i++;
      }
    }
    canvas.drawPath(dashed, paint);
  }

  void _text(Canvas canvas, _TextShape shape) {
    final (color, weight) = switch (shape.role) {
      _TextRole.axis => (colors.secondaryInk, FontWeight.w600),
      _TextRole.value => (colors.ink, FontWeight.w700),
      _TextRole.center => (colors.secondaryInk, FontWeight.w600),
      _TextRole.centerValue => (colors.secondaryInk, FontWeight.w900),
      _TextRole.word => (shape.color ?? colors.ink, FontWeight.w800),
    };
    final painter = TextPainter(
      text: TextSpan(
        text: shape.text,
        style: textStyle.copyWith(
          color: color,
          fontSize: shape.size,
          fontWeight: weight,
          height: 1,
          decoration: TextDecoration.none,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final dx = switch (shape.anchor) {
      _Anchor.start => 0.0,
      _Anchor.middle => painter.width / 2,
      _Anchor.end => painter.width,
    };
    final dy = shape.central
        ? painter.height / 2
        : painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    painter
      ..paint(canvas, shape.at - Offset(dx, dy))
      ..dispose();
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => true;
}
