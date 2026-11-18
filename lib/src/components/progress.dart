import 'dart:math' as math;

import '../foundation/recipes/progress.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/size.dart';
import '../foundation/scene.dart';
import '../internal/wave.dart';

/// Pill progress bar with the percentage to its right.
class IslandProgress extends StatelessWidget {
  const IslandProgress({
    super.key,
    required this.percent,
    required this.label,
    this.size = IslandSize.middle,
    this.scene,
    this.color,
    this.wave = false,
    this.animated = true,
    this.showInfo = true,
    this.infoBuilder,
    this.semanticValue,
    this.duration = const Duration(milliseconds: 600),
  });

  /// Current percentage; clamped to 0–100, NaN reads as 0.
  final double percent;

  /// Accessible name of the bar.
  final String label;

  /// Track height: 14, 24 or 32.
  final IslandSize size;

  /// Scene picture revealed from the left; takes precedence over [color].
  final IslandScene? scene;

  /// Solid fill colour under the reference sheen and top highlight; it stays
  /// the same at 100%. Null keeps the mint gradient. Contrast of a caller
  /// colour against the track is the caller's responsibility.
  final Color? color;

  /// Overlays the double-layer ocean wave on the fill; combines with [color]
  /// or [scene].
  final bool wave;

  /// Whether the [wave] drifts. It is still at 0% and 100%, and plays only
  /// while visible and motion is enabled.
  final bool animated;

  /// Shows the percentage text to the right of the track.
  final bool showInfo;

  /// Replaces the default `N%` text; explicit text styles win.
  final Widget Function(double percent)? infoBuilder;

  /// Semantic value; defaults to `N%`.
  final String Function(double percent)? semanticValue;

  /// Fill width transition; zero disables it. The wave is controlled by
  /// [animated].
  final Duration duration;

  /// [percent] clamped to 0–100 with NaN as 0.
  double get safePercent => percent.isNaN ? 0 : percent.clamp(0, 100);
  @override
  Widget build(BuildContext context) {
    final value = safePercent;
    final height = switch (size) {
      IslandSize.small => 14.0,
      IslandSize.middle => 24.0,
      IslandSize.large => 32.0,
    };
    return Semantics(
      label: label,
      value: semanticValue?.call(value) ?? '${value.round()}%',
      child: ExcludeSemantics(
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  color: ProgressColors.track,
                  border: Border.all(
                    color: ProgressColors.trackBorder,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LayoutBuilder(
                    builder: (_, constraints) => CustomPaint(
                      painter: const _TrackDots(),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: value / 100),
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : duration,
                        curve: Curves.fastOutSlowIn,
                        builder: (_, fraction, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: constraints.maxWidth * fraction,
                            height: height,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (scene == null && color != null) ...[
                                    ColoredBox(color: color!),
                                    const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: ProgressColors.customSheen,
                                          stops: [0, .6, .6, 1],
                                        ),
                                      ),
                                    ),
                                  ] else if (scene == null)
                                    DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: value.round() == 100
                                              ? const [
                                                  ProgressColors.completeTop,
                                                  ProgressColors.completeBottom,
                                                ]
                                              : const [
                                                  ProgressColors.fillTop,
                                                  ProgressColors.fillMiddle,
                                                  ProgressColors.fillBottom,
                                                ],
                                          stops: value.round() == 100
                                              ? null
                                              : const [0, .6, 1],
                                        ),
                                      ),
                                    )
                                  else
                                    OverflowBox(
                                      alignment: Alignment.topLeft,
                                      minWidth: constraints.maxWidth,
                                      maxWidth: constraints.maxWidth,
                                      child: SvgPicture.asset(
                                        'assets/scenes/${scene!.assetName}.svg',
                                        package: 'animal_island_ui',
                                        width: constraints.maxWidth,
                                        fit: BoxFit.fitWidth,
                                        alignment: Alignment.topLeft,
                                      ),
                                    ),
                                  // Reference `box-shadow: inset 0 2px 0`:
                                  // a 2px band that follows the pill's
                                  // rounded ends, painted on the fill itself.
                                  const Positioned.fill(
                                    child: CustomPaint(
                                      painter: _InsetTopHighlight(
                                        ProgressColors.highlight,
                                      ),
                                    ),
                                  ),
                                  if (wave)
                                    OceanWave(
                                      color: ProgressColors.wave,
                                      animated:
                                          animated && value > 0 && value < 100,
                                    ),
                                  if (scene != null || color == null)
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          // Same-hue 3:1 edge beside the fill.
                                          border: Border.all(
                                            color: ProgressColors.fillEdge,
                                            width: 2,
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
                  ),
                ),
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44),
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: ProgressColors.info(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1,
                    letterSpacing: .32,
                  ),
                  textAlign: TextAlign.right,
                  child: infoBuilder?.call(value) ?? Text('${value.round()}%'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// CSS `box-shadow: inset 0 2px 0 <color>` on a `border-radius: 999px` box:
/// the box's rounded shape minus the same shape moved 2px down. CSS scales
/// the oversized radii to half the shorter side.
class _InsetTopHighlight extends CustomPainter {
  const _InsetTopHighlight(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(math.min(size.width, size.height) / 2),
    );
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRRect(shape),
        Path()..addRRect(shape.shift(const Offset(0, 2))),
      ),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_InsetTopHighlight old) => old.color != color;
}

class _TrackDots extends CustomPainter {
  const _TrackDots();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = ProgressColors.trackDot;
    for (double x = 0; x < size.width; x += 14) {
      for (double y = 0; y < size.height; y += 14) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_TrackDots old) => false;
}
