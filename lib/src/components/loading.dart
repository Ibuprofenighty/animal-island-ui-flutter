import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../foundation/localizations.dart';
import '../internal/content_scope.dart';
import '../internal/action_surface.dart';
import '../internal/viewport_overlay.dart';

/// The host owns activity and work; this root overlay owns display delay,
/// decoration and animation resources. Input is restored only after removal.
class IslandLoading extends StatefulWidget {
  IslandLoading({
    super.key,
    this.active = true,
    this.tip,
    this.delay = Duration.zero,
    this.fadeDuration = const Duration(milliseconds: 600),
    this.semanticLabel,
  }) : assert(!delay.isNegative),
       assert(!fadeDuration.isNegative);
  final bool active;
  final Widget? tip;
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
  late final snow = _SnowClock(createTicker);
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
    snow.stop();
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) reconcile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MediaQuery.disableAnimationsOf(context);
    final changed = next != reduced;
    reduced = next;
    if (shown && !reduced) {
      snow.start();
    } else {
      snow.stop();
    }
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
    snow.reset();
    returnFocus = FocusManager.instance.primaryFocus;
    setState(() => shown = true);
    final token = generation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && token == generation && shown) scope.requestFocus();
      });
      WidgetsBinding.instance.scheduleFrame();
    });
    if (!reduced) snow.start();
    if (reduced) {
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
        if (reduced) {
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
        curve: motionCurve,
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
    snow.dispose();
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
            child: CustomPaint(
              painter: _SnowPainter(snow, motion),
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
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ColoredBox(
                        color: const Color(0xff0b101a),
                        child: ContentScope(
                          textStyle: const TextStyle(
                            color: Color(0xfff8f8f0),
                            fontSize: 18,
                            height: 1.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .72,
                            shadows: [
                              Shadow(
                                color: Color(0x99000000),
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
        ),
      ),
    ),
  );
}

class _SnowClock extends ChangeNotifier {
  _SnowClock(Ticker Function(TickerCallback) factory) {
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

class _SnowPainter extends CustomPainter {
  _SnowPainter(this.clock, this.motion)
    : super(repaint: Listenable.merge([clock, motion]));
  final Animation<double> motion;
  final _SnowClock clock;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xff0b101a),
    );
    final brush = Paint()..color = Colors.white.withValues(alpha: motion.value);
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
          const [Color(0x00050a14), Color(0x99050a14)],
          const [.55, 1],
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SnowPainter old) =>
      old.clock != clock || old.motion != motion;
}
