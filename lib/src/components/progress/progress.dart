import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';
import 'progress_painter.dart';

export 'progress_painter.dart';

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

/// Cozy Animal Island Pill Progress Bar with signature 45° candy-cane stripes (C24).
///
/// Supports standard horizontal bar progress and circular progress ring ([AnimalProgress.circle]).
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

  /// Factory constructor for a cozy circular progress ring.
  const factory AnimalProgress.circle({
    Key? key,
    required double percent,
    double size,
    double strokeWidth,
    AnimalProgressStatus status,
    Color? color,
    Color? trackColor,
    bool showInfo,
    String Function(double percent)? format,
  }) = _AnimalCircularProgress;

  @override
  State<AnimalProgress> createState() => _AnimalProgressState();
}

class _AnimalProgressState extends State<AnimalProgress>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  bool _tickerModeEnabled = true;
  Duration? _stripeDuration;

  @override
  void initState() {
    super.initState();
  }

  bool get _shouldAnimate =>
      widget.animated &&
      widget.striped &&
      widget.status == AnimalProgressStatus.active &&
      _tickerModeEnabled;

  void _syncAnimation() {
    if (_animationController != null) {
      _animationController!.duration = _stripeDuration!;
    }
    if (_shouldAnimate) {
      _animationController ??= AnimationController(
        vsync: this,
        duration: _stripeDuration!,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _stripeDuration = AnimalIslandTheme.of(context).motion.slow * (1400 / 350);
    final enabled = AnimalMotionPolicy.shouldAnimate(context);
    _tickerModeEnabled = enabled;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant AnimalProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated ||
        oldWidget.striped != widget.striped ||
        oldWidget.status != widget.status) {
      _syncAnimation();
    }
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
        return theme.colors.success;
      case AnimalProgressStatus.exception:
        return theme.colors.error;
      case AnimalProgressStatus.normal:
      case AnimalProgressStatus.active:
        return theme.colors.primary;
    }
  }

  Color _resolveOnFillColor(AnimalIslandTheme theme) => switch (widget.status) {
    AnimalProgressStatus.success => theme.colors.onSuccess,
    AnimalProgressStatus.exception => theme.colors.onError,
    AnimalProgressStatus.normal ||
    AnimalProgressStatus.active => theme.colors.onPrimary,
  };

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
    final trackColor =
        widget.trackColor ??
        (theme.colors.brightness == Brightness.dark
            ? theme.colors.surfaceAlt
            : theme.colors.bgDisabled);
    final borderColor = theme.colors.brightness == Brightness.dark
        ? theme.colors.border
        : theme.colors.borderLight;

    final infoText = _formatText(clamped);

    Widget barCore = Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: theme.radii.pillBorder,
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
                      painter: AnimalCandyStripePainter(
                        fillColor: fillColor,
                        striped: widget.striped,
                        phase: _animationController!.value,
                        radius: theme.radii.pill,
                      ),
                    );
                  },
                )
              else
                CustomPaint(
                  size: Size(barWidth, barHeight),
                  painter: AnimalCandyStripePainter(
                    fillColor: fillColor,
                    striped: widget.striped,
                    phase: 0.0,
                    radius: theme.radii.pill,
                  ),
                ),
              if (widget.infoPosition == AnimalProgressInfoPosition.inside &&
                  barHeight >= 14.0 &&
                  barWidth > 38.0)
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: theme.spacing.sm),
                      child: Text(
                        infoText,
                        style: theme.typography.button.copyWith(
                          fontSize: theme.typography.button.fontSize! * 0.8,
                          color: _resolveOnFillColor(theme),
                          shadows: <Shadow>[
                            Shadow(
                              color: theme.shadows.softElevation.color,
                              offset: theme.shadows.softElevation.offset,
                              blurRadius:
                                  theme.shadows.softElevation.blurRadius,
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
                style: theme.typography.caption.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colors.text,
                ),
              ),
            ],
          ),
          SizedBox(height: theme.spacing.xs + theme.spacing.xxs),
          barCore,
        ],
      );
    } else {
      // Default: infoPosition == right
      content = Row(
        children: [
          Expanded(child: barCore),
          SizedBox(width: theme.spacing.md),
          Text(
            infoText,
            style: theme.typography.caption.copyWith(
              fontWeight: FontWeight.w800,
              color: theme.colors.text,
            ),
          ),
        ],
      );
    }

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: AnimalLocalizations.of(context)!.progressLabel,
      value: infoText,
      child: content,
    );
  }
}

class _AnimalCircularProgress extends AnimalProgress {
  final double circleSize;
  final double strokeWidth;
  final bool showInfo;

  const _AnimalCircularProgress({
    super.key,
    required super.percent,
    double size = 120.0,
    this.strokeWidth = 10.0,
    super.status = AnimalProgressStatus.normal,
    super.color,
    super.trackColor,
    this.showInfo = true,
    super.format,
  }) : circleSize = size,
       super(striped: false, animated: false);

  @override
  State<AnimalProgress> createState() => _AnimalCircularProgressState();
}

class _AnimalCircularProgressState extends State<_AnimalCircularProgress> {
  @override
  Widget build(BuildContext context) {
    final localizations = AnimalLocalizations.of(context)!;
    final theme = AnimalIslandTheme.of(context);
    final clamped = widget.percent.clamp(0.0, 1.0);
    final fillColor =
        widget.color ??
        (widget.status == AnimalProgressStatus.success
            ? theme.colors.success
            : (widget.status == AnimalProgressStatus.exception
                  ? theme.colors.error
                  : theme.colors.primary));
    final trackColor =
        widget.trackColor ??
        (theme.colors.brightness == Brightness.dark
            ? theme.colors.surfaceAlt
            : theme.colors.bgDisabled);
    final infoText = widget.format != null
        ? widget.format!(clamped)
        : '${(clamped * 100).toInt()}%';

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: localizations.circularProgressLabel,
      value: infoText,
      child: SizedBox(
        width: widget.circleSize,
        height: widget.circleSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(widget.circleSize, widget.circleSize),
              painter: AnimalCircularProgressPainter(
                percent: clamped,
                strokeWidth: widget.strokeWidth,
                fillColor: fillColor,
                trackColor: trackColor,
              ),
            ),
            if (widget.showInfo)
              Text(
                infoText,
                style: theme.typography.digitLarge.copyWith(
                  fontSize:
                      theme.typography.digitLarge.fontSize! *
                      (widget.circleSize / 180),
                  color: theme.colors.text,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
