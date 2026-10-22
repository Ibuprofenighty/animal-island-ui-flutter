import '../internal/surface_motion.dart';
import '../foundation/theme.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/size.dart';
import '../internal/content_scope.dart';
import '../internal/number_surface.dart';
import '../internal/number_plate.dart';

enum IslandCountUpVariant { normal, island }

@immutable
class IslandCountUpRepeat {
  const IslandCountUpRepeat({this.delay = Duration.zero, this.start});
  final Duration delay;
  final double? start;
}

/// Borrowed command handle. Each reset restarts the current target's timeline.
class IslandCountUpController extends ChangeNotifier {
  double? _start;
  void reset([double? start]) {
    assert(start == null || start.isFinite);
    _start = start;
    notifyListeners();
  }
}

class IslandCountUp extends StatefulWidget {
  const IslandCountUp({
    super.key,
    required this.end,
    this.start = 0,
    this.duration = const Duration(seconds: 2),
    this.isCounting = false,
    this.decimalPlaces,
    this.decimalSeparator = '.',
    this.thousandsSeparator = '',
    this.curve = Curves.easeOutCubic,
    this.updateInterval = Duration.zero,
    this.prefix,
    this.suffix,
    this.size = IslandSize.middle,
    this.variant = IslandCountUpVariant.normal,
    this.bordered = false,
    this.celebrate = false,
    this.celebration,
    this.onUpdate,
    this.onComplete,
    this.builder,
    this.controller,
    this.semanticLabel,
  }) : assert(
         decimalPlaces == null || (decimalPlaces >= 0 && decimalPlaces <= 20),
       );
  final double start, end;
  final Duration duration, updateInterval;
  final bool isCounting, bordered, celebrate;
  final int? decimalPlaces;
  final String decimalSeparator, thousandsSeparator;
  final Curve curve;
  final Widget? prefix, suffix, celebration;
  final IslandSize size;
  final IslandCountUpVariant variant;
  final ValueChanged<double>? onUpdate;
  final IslandCountUpRepeat? Function(Duration elapsed)? onComplete;
  final Widget Function(BuildContext context, double value)? builder;
  final IslandCountUpController? controller;
  final String? semanticLabel;
  @override
  State<IslandCountUp> createState() => _IslandCountUpState();
}

class _IslandCountUpState extends State<IslandCountUp>
    with TickerProviderStateMixin {
  late final timeline = AnimationController(
    vsync: this,
    duration: widget.duration,
    animationBehavior: AnimationBehavior.preserve,
  );
  late final celebration = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  late double from = widget.start;
  late double display = widget.start;
  bool finished = false;
  int generation = 0;
  Timer? repeat, celebrationRemoval;
  bool celebrating = false;
  @override
  void initState() {
    super.initState();
    assert(widget.start.isFinite && widget.end.isFinite);
    timeline.addListener(tick);
    widget.controller?.addListener(resetFromController);
    scheduleStart();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) celebration.value = 1;
  }

  void scheduleStart() {
    final token = generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && token == generation && widget.isCounting && !finished)
        play();
    });
  }

  void resetFromController() => reset(widget.controller?._start);
  void reset([double? value]) {
    generation++;
    repeat?.cancel();
    repeat = null;
    timeline.stop();
    celebrationRemoval?.cancel();
    celebrating = false;
    celebration.stop();
    celebration.value = 0;
    finished = false;
    from = value ?? widget.start;
    // Resetting value invokes listeners: guard against treating it as a frame.
    timeline.removeListener(tick);
    timeline.value = 0;
    timeline.addListener(tick);
    setState(() => display = from);
    scheduleStart();
  }

  void play() {
    if (widget.duration <= Duration.zero) {
      finish();
      return;
    }
    timeline.forward();
  }

  @override
  void didUpdateWidget(IslandCountUp old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?.removeListener(resetFromController);
      widget.controller?.addListener(resetFromController);
    }
    if (old.start != widget.start ||
        old.end != widget.end ||
        old.duration != widget.duration) {
      timeline.duration = widget.duration;
      reset();
    } else if (old.isCounting != widget.isCounting) {
      if (widget.isCounting) {
        scheduleStart();
      } else {
        timeline.stop();
        repeat?.cancel();
        repeat = null;
      }
    }
  }

  void tick() {
    if (!mounted || finished) return;
    if (timeline.value >= 1) {
      finish();
      return;
    }
    final micros = timeline.value * widget.duration.inMicroseconds;
    final interval = widget.updateInterval.inMicroseconds;
    final elapsed = interval > 0
        ? (micros / interval).floor() * interval
        : micros;
    final progress = (elapsed / widget.duration.inMicroseconds).clamp(0.0, 1.0);
    final next = from + (widget.end - from) * widget.curve.transform(progress);
    if (next != display) setState(() => display = next);
    widget.onUpdate?.call(next);
  }

  void finish() {
    if (finished || !mounted) return;
    final token = generation;
    finished = true;
    timeline.stop();
    setState(() => display = widget.end);
    if (widget.celebrate || widget.celebration != null) {
      setState(() => celebrating = true);
      celebrationRemoval?.cancel();
      celebrationRemoval = Timer(const Duration(milliseconds: 900), () {
        if (mounted && token == generation) setState(() => celebrating = false);
      });
      if (MediaQuery.disableAnimationsOf(context)) {
        celebration.value = 1;
      } else {
        celebration.forward(from: 0);
      }
    }
    widget.onUpdate?.call(widget.end);
    if (!mounted || token != generation) return;
    final result = widget.onComplete?.call(widget.duration);
    if (!mounted || token != generation || result == null || !widget.isCounting)
      return;
    repeat = Timer(result.delay.isNegative ? Duration.zero : result.delay, () {
      repeat = null;
      if (mounted && token == generation && widget.isCounting)
        reset(result.start);
    });
  }

  @override
  void dispose() {
    generation++;
    repeat?.cancel();
    celebrationRemoval?.cancel();
    widget.controller?.removeListener(resetFromController);
    timeline.dispose();
    celebration.dispose();
    super.dispose();
  }

  int decimals(double v) {
    final text = v.toString();
    final parts = text.toLowerCase().split('e');
    final fraction = parts[0].contains('.')
        ? parts[0].split('.').last.replaceAll(RegExp(r'0+$'), '').length
        : 0;
    final exponent = parts.length == 2 ? int.parse(parts[1]) : 0;
    return (fraction - exponent).clamp(0, 20);
  }

  String format(double v) {
    final places =
        widget.decimalPlaces ??
        math.max(decimals(widget.start), decimals(widget.end));
    final parts = v.toStringAsFixed(places).split('.');
    final integer = parts[0].replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => widget.thousandsSeparator,
    );
    return places == 0
        ? integer
        : '$integer${widget.decimalSeparator}${parts[1]}';
  }

  @override
  Widget build(BuildContext context) {
    final font = switch (widget.size) {
      IslandSize.small => 20.0,
      IslandSize.middle => 26.0,
      IslandSize.large => 34.0,
    };
    final body = switch (widget.size) {
      IslandSize.small => 13.0,
      IslandSize.middle => 14.0,
      IslandSize.large => 16.0,
    };
    final island = widget.variant == IslandCountUpVariant.island;
    Widget affix(Widget child) => ContentScope(
      textStyle: TextStyle(
        color: IslandTokens.light.muted,
        fontWeight: FontWeight.w800,
        fontSize: body * .62,
        height: 1.2,
      ),
      child: child,
    );
    final plate = NumberPlate(
      island: island,
      bordered: widget.bordered,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        spacing: 2,
        children: [
          if (widget.prefix != null) affix(widget.prefix!),
          ContentScope(
            textStyle: TextStyle(
              color: IslandTokens.light.ink,
              fontWeight: FontWeight.w900,
              fontSize: font,
              height: 1.2,
              letterSpacing: font * .01,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            child:
                widget.builder?.call(context, display) ?? Text(format(display)),
          ),
          if (widget.suffix != null) affix(widget.suffix!),
        ],
      ),
    );
    return Semantics(
      container: true,
      liveRegion: !timeline.isAnimating,
      label: widget.semanticLabel,
      value: timeline.isAnimating ? '' : format(display),
      child: ExcludeSemantics(
        child: ExcludeFocus(
          child: NumberSurface(
            island: island,
            child: AnimatedBuilder(
              animation: celebration,
              builder: (context, child) {
                final t = celebration.value;
                final active = celebrating;
                final reduce = MediaQuery.disableAnimationsOf(context);
                final progress = (t * 900 / 700).clamp(0.0, 1.0);
                final (scale, angle) = pop(progress);
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (active && !reduce)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: CustomPaint(painter: _CelebrationPainter(t)),
                        ),
                      ),
                    Transform.rotate(
                      key: const ValueKey('count-up-number'),
                      angle: active && !reduce ? angle * math.pi / 180 : 0,
                      child: Transform.scale(
                        scale: active && !reduce ? scale : 1,
                        child: child,
                      ),
                    ),
                    if (active && widget.celebration != null)
                      Positioned(
                        bottom: 0,
                        child: FractionalTranslation(
                          translation: const Offset(0, -1.5),
                          child: Transform.scale(
                            scale: reduce
                                ? 1
                                : SurfaceMotion.bounce(
                                    (t * 900 / 500).clamp(0.0, 1.0),
                                  ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xffffe08a),
                                    Color(0xfff7cd67),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xffe0b800),
                                ),
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x2e3d3428),
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: ContentScope(
                                textStyle: TextStyle(
                                  color: IslandTokens.light.onSun,
                                  fontSize: body - 1,
                                  fontWeight: FontWeight.w800,
                                  height: 1.4,
                                  letterSpacing: .04 * (body - 1),
                                ),
                                child: widget.celebration!,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
              child: plate,
            ),
          ),
        ),
      ),
    );
  }

  (double, double) pop(double t) {
    const frames = [
      (0.0, 1.0, 0.0),
      (.16, 1.14, -2.0),
      (.34, .98, 0.0),
      (.52, 1.08, 1.6),
      (.72, .99, -.8),
      (1.0, 1.0, 0.0),
    ];
    final i = frames.indexWhere((frame) => t <= frame.$1, 1);
    final a = frames[i - 1], b = frames[i];
    final p = Curves.easeInOut.transform((t - a.$1) / (b.$1 - a.$1));
    return (a.$2 + (b.$2 - a.$2) * p, a.$3 + (b.$3 - a.$3) * p);
  }
}

class _CelebrationPainter extends CustomPainter {
  const _CelebrationPainter(this.progress);
  final double progress;
  @override
  void paint(Canvas c, Size s) {
    for (final delay in [0.0, 120.0]) {
      final t = ((progress * 900 - delay) / 700).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final scale = 1 + Curves.easeInOut.transform(t) * .5;
      final rect = Rect.fromCenter(
        center: s.center(Offset.zero),
        width: s.width * scale,
        height: s.height * scale,
      );
      c.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()
          ..color = const Color(0xfff7cd67).withValues(alpha: (1 - t) * .9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var i = 0; i < 4; i++) {
      final t = ((progress * 900 - i * 60) / 720).clamp(0.0, 1.0);
      if (t <= 0 || t >= 1) continue;
      final right = i.isOdd, bottom = i >= 2;
      final position = Offset(
        (right ? s.width - 5 : 5) + (right ? 16 : -16) * t,
        (bottom ? s.height - 5 : 5) + (bottom ? 14 : -14) * t,
      );
      final alpha = t < .35 ? t / .35 : (1 - t) / .65;
      c.save();
      c.translate(position.dx, position.dy);
      c.rotate(t * math.pi / 2);
      c.scale(.4 + .6 * t);
      final path = Path()
        ..moveTo(0, -5)
        ..lineTo(1.1, -1.1)
        ..lineTo(5, 0)
        ..lineTo(1.1, 1.1)
        ..lineTo(0, 5)
        ..lineTo(-1.1, 1.1)
        ..lineTo(-5, 0)
        ..lineTo(-1.1, -1.1)
        ..close();
      c.drawPath(
        path,
        Paint()..color = const Color(0xfff7cd67).withValues(alpha: alpha),
      );
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_CelebrationPainter old) => old.progress != progress;
}
