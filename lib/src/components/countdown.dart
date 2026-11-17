import 'package:flutter/rendering.dart';

import '../internal/content_scope.dart';
import '../foundation/theme.dart';
import '../internal/number_plate.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/recipes/number.dart';
import '../foundation/size.dart';
import '../internal/number_surface.dart';
import '../internal/rolling_digit.dart';

enum IslandCountdownVariant { normal, island }

/// A colour reminder: at or below [threshold] of displayed remaining time the
/// digits, separators and bordered plates take [color].
///
/// The displayed time is rounded up to whole seconds, so a 10-second
/// threshold starts when the countdown shows 10, never while it still shows
/// 11. When several reminders match, the smallest threshold wins; equal
/// thresholds keep the first. A negative threshold never matches.
@immutable
class IslandCountdownReminder {
  const IslandCountdownReminder({required this.threshold, required this.color});

  /// Remaining time at or below which this reminder applies.
  final Duration threshold;

  /// Colour of the digits, separators and bordered plate edges.
  final Color color;

  /// Reference default reminders: orange from 60 seconds, red from 10.
  static const List<IslandCountdownReminder> defaults = [
    IslandCountdownReminder(
      threshold: Duration(seconds: 60),
      color: NumberColors.reminderWarm,
    ),
    IslandCountdownReminder(
      threshold: Duration(seconds: 10),
      color: NumberColors.reminderUrgent,
    ),
  ];
}

/// The final-seconds shake of the countdown digit group.
///
/// Each period begins with a burst (left, right, left, right, rest over its
/// first 30%) and rests for the remaining 70%; the prefix, surface and
/// surrounding layout stay still. The urgent values replace the normal ones
/// at or below [urgentThreshold]. Thresholds compare with the displayed,
/// rounded-up seconds; a zero [threshold] disables the shake and a zero
/// [urgentThreshold] disables escalation. Reduced motion removes the shake.
@immutable
class IslandCountdownShake {
  const IslandCountdownShake({
    this.threshold = const Duration(seconds: 5),
    this.urgentThreshold = const Duration(seconds: 3),
    this.period = const Duration(milliseconds: 1000),
    this.urgentPeriod = const Duration(milliseconds: 650),
    this.distance = 1.5,
    this.urgentDistance = 2.5,
    this.rotation = .6,
    this.urgentRotation = .9,
    this.curve = const Cubic(.4, 0, .2, 1),
  }) : assert(distance >= 0 && urgentDistance >= 0),
       assert(rotation >= 0 && rotation <= 360),
       assert(urgentRotation >= 0 && urgentRotation <= 360);

  /// Remaining time at or below which the shake runs.
  final Duration threshold;

  /// Remaining time at or below which the urgent values apply.
  final Duration urgentThreshold;

  /// Normal and urgent cycle lengths; values below 16ms run at 16ms.
  final Duration period, urgentPeriod;

  /// Normal and urgent horizontal displacement in logical pixels.
  final double distance, urgentDistance;

  /// Normal and urgent rotation in degrees.
  final double rotation, urgentRotation;

  /// Easing of each keyframe segment of the burst.
  final Curve curve;
}

class IslandCountdown extends StatefulWidget {
  const IslandCountdown({
    super.key,
    required this.value,
    this.format = 'HH:mm:ss',
    this.prefix,
    this.size = IslandSize.middle,
    this.variant = IslandCountdownVariant.normal,
    this.bordered = false,
    this.reminders = const [],
    this.shake,
    this.onChange,
    this.onFinish,
    this.now,
  });
  final DateTime value;
  final String format;
  final Widget? prefix;
  final IslandSize size;
  final IslandCountdownVariant variant;
  final bool bordered;

  /// Colour reminders; empty keeps the normal colours. Pass
  /// [IslandCountdownReminder.defaults] for the reference 60/10-second set.
  final List<IslandCountdownReminder> reminders;

  /// Final-seconds shake of the digit group; null disables it.
  final IslandCountdownShake? shake;
  final ValueChanged<Duration>? onChange;
  final VoidCallback? onFinish;
  final DateTime Function()? now;
  @override
  State<IslandCountdown> createState() => _IslandCountdownState();
}

class _IslandCountdownState extends State<IslandCountdown>
    with SingleTickerProviderStateMixin {
  final shakeClock = _ShakeClock();
  late final shakeTicker = createTicker(shakeClock.tick);
  Timer? timer;
  int generation = 0;
  bool finished = false;
  late int remaining = read();
  int read() => math.max(
    0,
    widget.value
        .difference(widget.now?.call() ?? DateTime.now())
        .inMilliseconds,
  );
  @override
  void initState() {
    super.initState();
    restart();
  }

  @override
  void didUpdateWidget(IslandCountdown old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value || old.now != widget.now) restart();
  }

  void restart() {
    timer?.cancel();
    final token = ++generation;
    finished = false;
    remaining = read();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || token != generation) return;
      update();
      if (mounted && token == generation && !finished) {
        timer = Timer.periodic(
          const Duration(milliseconds: 250),
          (_) => update(),
        );
      }
    });
  }

  void update() {
    final token = generation;
    final next = read();
    if (next != remaining) setState(() => remaining = next);
    final completes = next == 0 && !finished;
    if (completes) {
      finished = true;
      timer?.cancel();
    }
    widget.onChange?.call(Duration(milliseconds: next));
    if (!mounted || token != generation) return;
    if (completes) widget.onFinish?.call();
  }

  @override
  void dispose() {
    generation++;
    timer?.cancel();
    shakeTicker.dispose();
    shakeClock.dispose();
    super.dispose();
  }

  /// Runs the shake ticker exactly while [active]; a new run starts at rest.
  void driveShake(bool active) {
    if (active == shakeTicker.isActive) return;
    shakeClock.elapsed = Duration.zero;
    if (active) {
      shakeTicker.start();
    } else {
      shakeTicker.stop();
    }
  }

  static const _burst = [0.0, -1.0, 1.0, -1.0, 1.0, 0.0];

  /// Reference keyframes 0/6/12/18/24/30%: displacement factor at [phase].
  static double burst(double phase, Curve curve) {
    if (phase >= .3) return 0;
    final step = phase / .06;
    final index = step.floor();
    return _burst[index] +
        (_burst[index + 1] - _burst[index]) * curve.transform(step - index);
  }

  @override
  Widget build(BuildContext context) {
    final seconds = (remaining / 1000).ceil();
    final shown = Duration(seconds: seconds);
    IslandCountdownReminder? reminder;
    for (final rule in widget.reminders) {
      if (shown <= rule.threshold &&
          (reminder == null || rule.threshold < reminder.threshold)) {
        reminder = rule;
      }
    }
    final shake = widget.shake;
    final shaking = shake != null && seconds > 0 && shown <= shake.threshold;
    final urgent = shaking && shown <= shake.urgentThreshold;
    final reduced = MediaQuery.disableAnimationsOf(context);
    driveShake(shaking && !reduced);
    final values = <String, int>{
      'DD': seconds ~/ 86400,
      'HH': widget.format.contains('DD')
          ? (seconds % 86400) ~/ 3600
          : seconds ~/ 3600,
      'mm': (seconds % 3600) ~/ 60,
      'ss': seconds % 60,
    };
    final parts = <(bool, String)>[];
    var end = 0;
    for (final match in RegExp('DD|HH|mm|ss').allMatches(widget.format)) {
      if (match.start > end)
        parts.add((false, widget.format.substring(end, match.start)));
      parts.add((true, values[match[0]]!.toString().padLeft(2, '0')));
      end = match.end;
    }
    if (end < widget.format.length)
      parts.add((false, widget.format.substring(end)));
    final font = switch (widget.size) {
      IslandSize.small => 20.0,
      IslandSize.middle => 26.0,
      IslandSize.large => 34.0,
    };
    final bodyFont = switch (widget.size) {
      IslandSize.small => 13.0,
      IslandSize.middle => 14.0,
      IslandSize.large => 16.0,
    };
    final island = widget.variant == IslandCountdownVariant.island;
    final ink = reminder?.color ?? IslandTokens.light.ink;
    final baseStyle = DefaultTextStyle.of(context).style.copyWith(
      fontSize: font,
      height: 1.2,
      letterSpacing: 0,
      fontWeight: FontWeight.w900,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    Widget digits(Color? color) {
      final digitStyle = baseStyle.copyWith(color: color);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < parts.length; index++) ...[
            if (index != 0) const SizedBox(width: 6),
            if (parts[index].$1)
              NumberPlate(
                island: island,
                bordered: widget.bordered,
                borderColor: reminder?.color,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var d = 0; d < parts[index].$2.length; d++) ...[
                      if (d != 0) const SizedBox(width: 3),
                      RollingDigit(
                        key: ValueKey((index, d)),
                        digit: int.parse(parts[index].$2[d]),
                        style: digitStyle,
                      ),
                    ],
                  ],
                ),
              )
            else
              Transform.translate(
                offset: Offset(
                  0,
                  parts[index].$2.contains(RegExp('[:：]')) ? -font * .08 : 0,
                ),
                // Reference `.colon` keeps 900 at the digit size; other
                // literals are `.sep` at weight 700 and the body size.
                child: Text(
                  parts[index].$2,
                  style: parts[index].$2.contains(RegExp('[:：]'))
                      ? digitStyle
                      : digitStyle.copyWith(
                          fontSize: bodyFont,
                          fontWeight: FontWeight.w700,
                        ),
                ),
              ),
          ],
        ],
      );
    }

    final period = urgent ? shake.urgentPeriod : shake?.period;
    final distance = urgent ? shake.urgentDistance : shake?.distance ?? 0;
    final rotation = urgent ? shake.urgentRotation : shake?.rotation ?? 0;
    Widget group = OverflowBox(
      minWidth: 0,
      maxWidth: double.infinity,
      fit: OverflowBoxFit.deferToChild,
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: shakeClock,
        builder: (_, child) {
          final cycle = math.max(period?.inMicroseconds ?? 0, 16000);
          final offset = shakeTicker.isActive
              ? burst(
                  shakeClock.elapsed.inMicroseconds % cycle / cycle,
                  shake?.curve ?? Curves.linear,
                )
              : 0.0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.translationValues(offset * distance, 0, 0)
              ..rotateZ(offset * rotation * math.pi / 180),
            child: child,
          );
        },
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: ink),
          duration: reduced ? Duration.zero : const Duration(milliseconds: 200),
          curve: const Cubic(.4, 0, .2, 1),
          builder: (_, color, _) => digits(color),
        ),
      ),
    );
    group = Semantics(
      value: parts.map((p) => p.$2).join(),
      child: ExcludeSemantics(child: group),
    );
    return _FitContent(
      child: NumberSurface(
        island: island,
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (widget.prefix != null)
              ContentScope(
                textStyle: TextStyle(
                  color: IslandTokens.light.muted,
                  fontSize: bodyFont,
                  fontWeight: FontWeight.w600,
                ),
                child: widget.prefix!,
              ),
            group,
          ],
        ),
      ),
    );
  }
}

/// Shake ticker time; restarting resets it silently before the first tick.
class _ShakeClock extends ChangeNotifier {
  Duration elapsed = Duration.zero;
  void tick(Duration value) {
    elapsed = value;
    notifyListeners();
  }
}

/// CSS `width: fit-content` for the reference `.countdown` surface: it hugs
/// its single-run content, and once that run no longer fits (so the narrow
/// `flex-wrap: wrap` applies) it takes the full available width, with the
/// wrapped runs centred inside it.
class _FitContent extends SingleChildRenderObjectWidget {
  const _FitContent({required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFitContent();
}

class _RenderFitContent extends RenderProxyBox {
  BoxConstraints _resolve(
    BoxConstraints constraints,
    Size Function(BoxConstraints) measure,
  ) {
    if (!constraints.hasBoundedWidth) return constraints;
    final single = measure(
      constraints.copyWith(minWidth: 0, maxWidth: double.infinity),
    );
    return single.width > constraints.maxWidth
        ? constraints.tighten(width: constraints.maxWidth)
        : constraints;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final box = child!;
    return constraints.constrain(
      box.getDryLayout(_resolve(constraints, box.getDryLayout)),
    );
  }

  @override
  void performLayout() {
    final box = child!;
    final resolved = _resolve(constraints, (c) {
      box.layout(c, parentUsesSize: true);
      return box.size;
    });
    box.layout(resolved, parentUsesSize: true);
    size = constraints.constrain(box.size);
  }
}
