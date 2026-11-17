import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../foundation/icon.dart';
import '../foundation/localizations.dart';
import '../internal/content_scope.dart';
import '../internal/action_surface.dart';
import '../internal/viewport_overlay.dart';
import '../foundation/recipes/loading.dart';

/// Presentation form of [IslandLoading].
enum IslandLoadingType {
  /// Full-screen night snow; the snow fades out on close.
  snow,

  /// Night mask with a sailboat drifting on waves at the bottom right; on
  /// close a transparent circle grows from the centre and reveals the content
  /// below. It has no entry fade.
  circle,
}

/// The host owns activity and work; this root overlay owns display delay,
/// decoration and animation resources. Input is restored only after removal.
class IslandLoading extends StatefulWidget {
  IslandLoading({
    super.key,
    this.type = IslandLoadingType.snow,
    this.showBoat = true,
    this.active = true,
    this.tip,
    this.delay = Duration.zero,
    this.fadeDuration = const Duration(milliseconds: 600),
    this.semanticLabel,
  }) : assert(!delay.isNegative),
       assert(!fadeDuration.isNegative);

  /// Presentation form; the snow form is the default.
  final IslandLoadingType type;

  /// Whether the circle form shows its sailboat; false leaves only the mask.
  /// The snow form ignores it.
  final bool showBoat;
  final bool active;
  final Widget? tip;

  /// [fadeDuration] is the snow fade, or the circle-reveal length of the
  /// circle form.
  final Duration delay, fadeDuration;
  final String? semanticLabel;
  @override
  State<IslandLoading> createState() => _IslandLoadingState();
}

class _IslandLoadingState extends State<IslandLoading>
    with TickerProviderStateMixin {
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  static const motionCurve = Cubic(.4, 0, .2, 1);
  late final scene = _SceneClock(createTicker);
  bool get circle => widget.type == IslandLoadingType.circle;

  /// The snow and the boat are the only endless decorations.
  bool get animates => !circle || widget.showBoat;
  void driveScene() {
    if (shown && !reduced && animates) {
      scene.start();
    } else {
      scene.stop();
    }
  }

  Timer? pending, removal;
  bool shown = false, reduced = false;
  int generation = 0;
  final scope = FocusScopeNode(
    traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
  );
  FocusNode? returnFocus;

  void removeSurface() {
    final token = generation;
    final ownedFocus = scope.hasFocus;
    final previous = FocusManager.instance.primaryFocus;
    final target = returnFocus;
    setState(() => shown = false);
    scene.stop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          token != generation ||
          shown ||
          !ownedFocus ||
          target?.context == null ||
          !target!.canRequestFocus)
        return;
      final current = FocusManager.instance.primaryFocus;
      if (current == previous ||
          current == scope ||
          current == null ||
          current == target)
        target.requestFocus();
    });
  }

  @override
  void initState() {
    super.initState();
    // An immediately active surface is present from the first build, so the
    // content below never shows before the mask.
    if (widget.active && widget.delay == Duration.zero) {
      generation++;
      present();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) reconcile();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MediaQuery.disableAnimationsOf(context);
    final changed = next != reduced;
    reduced = next;
    driveScene();
    if (changed && reduced) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !reduced || !shown) return;
        if (widget.active) {
          motion.value = 1;
        } else {
          reconcile();
        }
      });
    }
  }

  void show() {
    if (!mounted || !widget.active) return;
    setState(present);
  }

  void present() {
    scene.reset();
    returnFocus = FocusManager.instance.primaryFocus;
    shown = true;
    final token = generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && token == generation && shown) scope.requestFocus();
      });
      WidgetsBinding.instance.scheduleFrame();
    });
    driveScene();
    if (reduced || circle) {
      motion.value = 1;
    } else {
      motion.animateTo(
        1,
        duration: const Duration(milliseconds: 200),
        curve: motionCurve,
      );
    }
  }

  void reconcile() {
    pending?.cancel();
    pending = null;
    removal?.cancel();
    removal = null;
    final request = ++generation;
    if (widget.active) {
      if (shown) {
        // Reactivation closes the circle at once, as the reference drops
        // its mask class.
        if (reduced || circle) {
          motion.value = 1;
          return;
        }
        motion.animateTo(
          1,
          duration: Duration(
            microseconds: (250000 * (1 - motion.value)).round(),
          ),
          curve: motionCurve,
        );
      } else if (widget.delay == Duration.zero) {
        show();
      } else {
        pending = Timer(widget.delay, () {
          if (mounted && request == generation) show();
        });
      }
    } else if (shown) {
      if (reduced || widget.fadeDuration == Duration.zero) {
        motion.value = 0;
        removeSurface();
        return;
      }
      motion.animateBack(
        0,
        duration: Duration(
          microseconds: (widget.fadeDuration.inMicroseconds * motion.value)
              .round(),
        ),
        curve: circle ? Curves.linear : motionCurve,
      );
      removal = Timer(widget.fadeDuration, () {
        if (!mounted || request != generation || widget.active) return;
        removeSurface();
      });
    }
  }

  @override
  void didUpdateWidget(IslandLoading old) {
    super.didUpdateWidget(old);
    if (old.type != widget.type || old.showBoat != widget.showBoat) {
      driveScene();
    }
    if (old.active != widget.active ||
        old.delay != widget.delay ||
        old.fadeDuration != widget.fadeDuration) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) reconcile();
      });
    }
  }

  @override
  void dispose() {
    generation++;
    pending?.cancel();
    removal?.cancel();
    motion.dispose();
    scene.dispose();
    scope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ViewportOverlay(
    visible: shown,
    blocksBackgroundSemantics: true,
    builder: (context) => Positioned.fill(
      child: FocusScope(
        node: scope,
        autofocus: true,
        child: ClosedLoopTraversal(
          child: Semantics(
            liveRegion: true,
            label:
                widget.semanticLabel ??
                (widget.tip == null
                    ? IslandLocalizations.of(context).loading
                    : null),
            // The blocker stays outside the reveal clip: background input
            // remains unavailable through the opening circle until removal.
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    excludeFromSemantics: true,
                    behavior: HitTestBehavior.opaque,
                    onTap: () {},
                  ),
                ),
                ClipPath(
                  clipper: _RevealClipper(motion, circle: circle),
                  clipBehavior: circle ? Clip.antiAlias : Clip.none,
                  child: CustomPaint(
                    painter: _LoadingPainter(scene, motion, snow: !circle),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (circle && widget.showBoat)
                          Positioned(
                            right: 20,
                            bottom: 30,
                            width: math.min(
                              120,
                              MediaQuery.sizeOf(context).width * .4,
                            ),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: _Sailboat(scene),
                            ),
                          ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ColoredBox(
                              color: LoadingColors.night,
                              child: ContentScope(
                                textStyle: const TextStyle(
                                  color: LoadingColors.text,
                                  fontSize: 18,
                                  height: 1.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: .72,
                                  shadows: [
                                    Shadow(
                                      color: LoadingColors.textShadow,
                                      offset: Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: widget.tip ?? const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _SceneClock extends ChangeNotifier {
  _SceneClock(Ticker Function(TickerCallback) factory) {
    ticker = factory((elapsed) {
      seconds = base + elapsed.inMicroseconds / Duration.microsecondsPerSecond;
      notifyListeners();
    });
    final random = math.Random();
    flakes = List.generate(
      50,
      (_) => (
        1 + random.nextDouble() * 5,
        random.nextDouble(),
        6 + random.nextDouble() * 6,
        random.nextDouble(),
      ),
    );
  }
  late final Ticker ticker;
  late final List<(double, double, double, double)> flakes;
  double seconds = 0, base = 0;
  void reset() {
    stop();
    seconds = base = 0;
  }

  void start() {
    if (!ticker.isActive) ticker.start();
  }

  void stop() {
    if (ticker.isActive) {
      base = seconds;
      ticker.stop();
    }
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }
}

/// Night backing; the snow form adds the flakes and the vignette.
class _LoadingPainter extends CustomPainter {
  _LoadingPainter(this.clock, this.motion, {required this.snow})
    : super(repaint: snow ? Listenable.merge([clock, motion]) : null);
  final Animation<double> motion;
  final _SceneClock clock;
  final bool snow;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = LoadingColors.night);
    if (!snow) return;
    final brush = Paint()
      ..color = LoadingColors.snow.withValues(alpha: motion.value);
    for (final flake in clock.flakes) {
      final phase = (clock.seconds / flake.$3 + flake.$4) % 1;
      canvas.drawCircle(
        Offset(
          flake.$2 * size.width + flake.$1 / 2,
          phase * (size.height + 60) - 30 + flake.$1 / 2,
        ),
        flake.$1 / 2,
        brush,
      );
    }
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(size.width / 2, size.height / 2);
    canvas.drawRect(
      const Rect.fromLTRB(-1, -1, 1, 1),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset.zero,
          math.sqrt2,
          const [LoadingColors.vignetteInner, LoadingColors.vignetteOuter],
          const [.55, 1],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LoadingPainter old) =>
      old.clock != clock || old.motion != motion || old.snow != snow;
}

/// Circle-form exit: a transparent circle grows linearly from the centre to
/// half the diagonal plus 50px while the motion runs from 1 back to 0.
class _RevealClipper extends CustomClipper<Path> {
  _RevealClipper(this.motion, {required this.circle}) : super(reclip: motion);
  final Animation<double> motion;
  final bool circle;
  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Offset.zero & size);
    final opened = circle ? 1 - motion.value : 0.0;
    if (opened <= 0) return path;
    final full =
        (math.sqrt(size.width * size.width + size.height * size.height) / 2)
            .ceil() +
        50;
    final radius = opened * full;
    return path
      ..addOval(
        Rect.fromCircle(center: size.center(Offset.zero), radius: radius),
      )
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(_RevealClipper old) =>
      old.motion != motion || old.circle != circle;
}

/// The pinned naive-icons `sailboat` glyph composed as two layers of the same
/// asset in its 48-unit space: the boat above the water line, scaled 0.8 about
/// its keel and bobbing (1s ease-in-out alternate: up 2 units, 1 degree), and
/// the water line repeated at its 40-unit tile, scrolled one 30-unit window
/// per 4s and shown through that centred window, 1.2 units lower.
class _Sailboat extends StatelessWidget {
  const _Sailboat(this.clock);
  final _SceneClock clock;

  /// Separates the hull stroke (to 41.75) from the wave stroke (from 42.1).
  static const waterLine = 41.9;
  static const keel = Offset(24, 40);
  static const window = 30.0, windowLeft = 9.0, tile = 40.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final extent = constraints.maxWidth;
      final unit = extent / 48;
      Widget glyph(double top, double bottom) => ClipRect(
        clipper: _Band(top * unit, bottom * unit),
        child: IslandIcon(
          IslandGlyph.sailboat,
          size: extent,
          color: LoadingColors.boatInk,
        ),
      );
      final boat = glyph(0, waterLine);
      final water = glyph(waterLine, 48);
      return AnimatedBuilder(
        animation: clock,
        builder: (context, _) {
          final still = MediaQuery.disableAnimationsOf(context);
          final seconds = still ? 0.0 : clock.seconds;
          final swing = seconds % 2;
          final bob = Curves.easeInOut.transform(swing < 1 ? swing : 2 - swing);
          final scroll = (seconds % 4) / 4 * window;
          final boatTransform = Matrix4.diagonal3Values(unit, unit, 1)
            ..translateByDouble(keel.dx, keel.dy, 0, 1)
            ..scaleByDouble(.8, .8, 1, 1)
            ..translateByDouble(-keel.dx, -keel.dy - 2 * bob, 0, 1)
            ..rotateZ(bob * math.pi / 180)
            ..scaleByDouble(1 / unit, 1 / unit, 1, 1);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: Transform(transform: boatTransform, child: boat),
              ),
              Positioned.fill(
                child: ClipRect(
                  clipper: _Band.horizontal(
                    windowLeft * unit,
                    (windowLeft + window) * unit,
                  ),
                  child: Transform.translate(
                    offset: Offset(scroll * unit, 1.2 * unit),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final shift in const [-tile, 0.0])
                          Positioned(
                            left: shift * unit,
                            top: 0,
                            width: extent,
                            height: extent,
                            child: water,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

/// A clip band across the child: vertical [start]..[end] by default, or
/// horizontal with [_Band.horizontal].
class _Band extends CustomClipper<Rect> {
  const _Band(this.start, this.end) : horizontal = false;
  const _Band.horizontal(this.start, this.end) : horizontal = true;
  final double start, end;
  final bool horizontal;
  @override
  Rect getClip(Size size) => horizontal
      ? Rect.fromLTRB(start, 0, end, size.height)
      : Rect.fromLTRB(0, start, size.width, end);

  @override
  bool shouldReclip(_Band old) =>
      old.start != start || old.end != end || old.horizontal != horizontal;
}
