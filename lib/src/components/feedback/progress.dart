import 'package:flutter/widgets.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';

/// Preset sizes for [AnimalProgress].
enum AnimalProgressSize {
  /// Compact 8px height.
  small,

  /// Standard 14px height.
  middle,

  /// Bold 22px height with inside text capability.
  large,
}

/// Status of the progress bar.
enum AnimalProgressStatus {
  /// Standard theme primary color.
  normal,

  /// Active animated barber-pole motion.
  active,

  /// Completed successfully (leaf green).
  success,

  /// Exception or error state (coral danger).
  exception,
}

/// Label text placement relative to the progress bar.
enum AnimalProgressInfoPosition {
  /// Placed on the right of the bar (default).
  right,

  /// Placed inside the progress bar pill (ideal for middle and large).
  inside,

  /// Placed above the progress bar.
  top,

  /// No progress info text is displayed.
  none,
}

/// Cozy Animal Island Pill Progress Bar with signature 45° candy-cane stripes.
class AnimalProgress extends StatefulWidget {
  /// Progress percentage between 0.0 and 1.0 (e.g. 0.75 for 75%).
  final double percent;

  /// Preset size variant.
  final AnimalProgressSize size;

  /// Explicit height override in logical pixels.
  final double? height;

  /// Primary fill color override.
  final Color? color;

  /// Custom background track color override.
  final Color? trackColor;

  /// Status of the progress bar.
  final AnimalProgressStatus status;

  /// Position of the percentage text label.
  final AnimalProgressInfoPosition infoPosition;

  /// Whether to render signature 45° diagonal candy-cane stripes.
  final bool striped;

  /// Whether the diagonal stripes animate (barber-pole motion).
  final bool animated;

  /// Custom formatter for percentage text.
  final String Function(double percent)? format;

  const AnimalProgress({
    super.key,
    required this.percent,
    this.size = AnimalProgressSize.middle,
    this.height,
    this.color,
    this.trackColor,
    this.status = AnimalProgressStatus.normal,
    this.infoPosition = AnimalProgressInfoPosition.right,
    this.striped = true,
    this.animated = true,
    this.format,
  });

  @override
  State<AnimalProgress> createState() => _AnimalProgressState();
}

class _AnimalProgressState extends State<AnimalProgress>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _syncAnimation();
  }

  bool get _shouldAnimate =>
      widget.animated &&
      widget.striped &&
      widget.status == AnimalProgressStatus.active;

  void _syncAnimation() {
    if (_shouldAnimate) {
      _animationController ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1400),
      );
      if (!_animationController!.isAnimating) {
        _animationController!.repeat();
      }
    } else {
      _animationController?.dispose();
      _animationController = null;
    }
  }

  @override
  void didUpdateWidget(AnimalProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  double _resolveHeight() {
    if (widget.height != null) return widget.height!;
    switch (widget.size) {
      case AnimalProgressSize.small:
        return 8.0;
      case AnimalProgressSize.middle:
        return 14.0;
      case AnimalProgressSize.large:
        return 22.0;
    }
  }

  Color _resolveFillColor(AnimalIslandTheme theme) {
    if (widget.color != null) return widget.color!;
    switch (widget.status) {
      case AnimalProgressStatus.success:
        return theme.success;
      case AnimalProgressStatus.exception:
        return theme.error;
      case AnimalProgressStatus.normal:
      case AnimalProgressStatus.active:
        return theme.primary;
    }
  }

  String _formatText(double clamped) {
    if (widget.format != null) {
      return widget.format!(clamped);
    }
    return '${(clamped * 100).toInt()}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final clamped = widget.percent.clamp(0.0, 1.0);
    final barHeight = _resolveHeight();
    final fillColor = _resolveFillColor(theme);
    final trackColor = widget.trackColor ??
        (theme.isDark ? theme.surfaceAlt : AnimalColors.bgDisabled);
    final borderColor =
        theme.isDark ? theme.border : AnimalColors.borderLight;

    final infoText = _formatText(clamped);

    Widget barCore = Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: AnimalRadii.pillBorder,
        border: Border.all(color: borderColor, width: 1.2),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final barWidth = constraints.maxWidth * clamped;
          return Stack(
            children: [
              if (_animationController != null)
                AnimatedBuilder(
                  animation: _animationController!,
                  builder: (context, _) {
                    return CustomPaint(
                      size: Size(barWidth, barHeight),
                      painter: _CandyStripePainter(
                        fillColor: fillColor,
                        striped: widget.striped,
                        phase: _animationController!.value,
                      ),
                    );
                  },
                )
              else
                CustomPaint(
                  size: Size(barWidth, barHeight),
                  painter: _CandyStripePainter(
                    fillColor: fillColor,
                    striped: widget.striped,
                    phase: 0.0,
                  ),
                ),
              if (widget.infoPosition == AnimalProgressInfoPosition.inside &&
                  barHeight >= 14.0 &&
                  barWidth > 38.0)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        infoText,
                        style: TextStyle(
                          fontSize: barHeight * 0.55,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFFFFFFFF),
                          shadows: const [
                            Shadow(
                              color: Color(0x66000000),
                              offset: Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    final Widget content;
    if (widget.infoPosition == AnimalProgressInfoPosition.none ||
        widget.infoPosition == AnimalProgressInfoPosition.inside) {
      content = barCore;
    } else if (widget.infoPosition == AnimalProgressInfoPosition.top) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Text(
                infoText,
                style: AnimalTypography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          barCore,
        ],
      );
    } else {
      // Default: infoPosition == right
      content = Row(
        children: [
          Expanded(child: barCore),
          const SizedBox(width: 12.0),
          Text(
            infoText,
            style: AnimalTypography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.text,
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: '进度',
      value: infoText,
      child: content,
    );
  }
}

class _CandyStripePainter extends CustomPainter {
  final Color fillColor;
  final bool striped;
  final double phase;

  const _CandyStripePainter({
    required this.fillColor,
    required this.striped,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(50.0));

    // Clip to rounded pill
    canvas.save();
    canvas.clipRRect(rrect);

    // 1. Draw solid background
    final bgPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, bgPaint);

    // 2. Draw 45-degree candy-cane stripes if enabled
    if (striped) {
      final stripePaint = Paint()
        ..color = const Color(0x38FFFFFF)
        ..style = PaintingStyle.fill;

      const stripeWidth = 14.0;
      final period = stripeWidth * 2;
      final shift = phase * period;

      final path = Path();
      // Draw diagonal parallel quadrilaterals spanning from -height to width + height
      for (double x = -size.height - period + shift; x < size.width + period; x += period) {
        path.moveTo(x, size.height);
        path.lineTo(x + stripeWidth, size.height);
        path.lineTo(x + stripeWidth + size.height, 0);
        path.lineTo(x + size.height, 0);
        path.close();
      }

      canvas.drawPath(path, stripePaint);
    }

    // 3. Subtle glossy top highlight
    final highlightPaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.4),
      highlightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CandyStripePainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.striped != striped ||
        oldDelegate.phase != phase;
  }
}

