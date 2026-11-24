import 'package:flutter/widgets.dart';

import 'viewport_presence.dart';

/// Decorative double-layer ocean wave shared by Divider, Progress and Upload.
///
/// It fills its parent, takes [color] from its owner and is excluded from
/// semantics and hit testing. It plays only while [animated], motion is
/// enabled and some of it lies inside the screen and every ancestor scroll
/// viewport; muted tickers (offstage routes, hidden application) also stop it.
/// When it does not play it keeps a static wave: pausing freezes the current
/// phase, reduced motion settles phase zero.
class OceanWave extends StatefulWidget {
  const OceanWave({super.key, required this.color, required this.animated});
  final Color color;
  final bool animated;
  @override
  State<OceanWave> createState() => _OceanWaveState();
}

/// One timeline drives both layers: the 6s and 9s drifts repeat exactly
/// within 18s.
const _cycle = Duration(seconds: 18);

/// Wave period in logical pixels; equal to the drift distance, so the loop
/// has no seam at any width.
const _period = 128.0;

class _OceanWaveState extends State<OceanWave>
    with SingleTickerProviderStateMixin, ViewportPresence {
  late final controller = AnimationController(vsync: this, duration: _cycle);
  bool reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reduced = MediaQuery.disableAnimationsOf(context);
    sync();
  }

  @override
  void didUpdateWidget(OceanWave old) {
    super.didUpdateWidget(old);
    sync();
  }

  @override
  void viewportPresenceChanged() => sync();

  void sync() {
    watchViewport(widget.animated && !reduced);
    if (reduced) {
      controller.value = 0;
    } else if (widget.animated && inViewport) {
      if (!controller.isAnimating) controller.repeat();
    } else {
      controller.stop();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          size: Size.infinite,
          painter: _OceanWavePainter(controller, widget.color),
        ),
      ),
    );
  }
}

class _OceanWavePainter extends CustomPainter {
  _OceanWavePainter(this.phase, this.color) : super(repaint: phase);
  final Animation<double> phase;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = phase.value;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    // Back layer: full height, .28, drifts left once per 6s.
    _layer(canvas, size, 0, size.height, -_period * ((t * 3) % 1), .28);
    // Front layer: lower 80%, .48, starts 32px into the tile and drifts right
    // once per 9s (the reference reverse direction).
    _layer(
      canvas,
      size,
      size.height * .2,
      size.height * .8,
      -32 - _period * (1 - (t * 2) % 1),
      .48,
    );
    canvas.restore();
  }

  void _layer(
    Canvas canvas,
    Size size,
    double top,
    double height,
    double shift,
    double opacity,
  ) {
    final k = height / 24;
    final bottom = top + height;
    var x = shift % _period - _period;
    final path = Path()
      ..moveTo(x, bottom)
      ..lineTo(x, top + 12 * k);
    for (; x < size.width; x += _period) {
      path
        ..cubicTo(
          x + 16,
          top + 4 * k,
          x + 48,
          top + 4 * k,
          x + 64,
          top + 12 * k,
        )
        ..cubicTo(
          x + 80,
          top + 20 * k,
          x + 112,
          top + 20 * k,
          x + 128,
          top + 12 * k,
        );
    }
    path
      ..lineTo(x, bottom)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = color.withValues(alpha: color.a * opacity),
    );
  }

  @override
  bool shouldRepaint(_OceanWavePainter old) =>
      old.phase != phase || old.color != color;
}
