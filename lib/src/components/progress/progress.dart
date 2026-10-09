import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/progress_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';
import 'progress_painter.dart';

/// Preset sizes for a linear [AnimalProgress].
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

/// Label text placement relative to a linear progress bar.
enum AnimalProgressInfoPosition {
  /// Placed on the right of the bar (default).
  right,

  /// Placed inside the progress fill when the bar is at least 14 logical
  /// pixels high and the fill is wider than 38; otherwise not shown.
  inside,

  /// Placed above the progress bar.
  top,

  /// No progress info text is displayed.
  none,
}

/// Cozy Animal Island pill progress bar with signature 45° candy-cane stripes
/// (C24), or a circular ring through [AnimalProgress.circle].
///
/// [percent] is the completed fraction. Values below 0 or above 1 show as 0
/// or 1; the label shows the shown fraction rounded down to a whole percent.
/// Screen readers read the label as the progress value without live
/// announcements.
///
/// The stripes of an [AnimalProgressStatus.active] bar move unless
/// [animated] is false; they rest while the bar is hidden by [TickerMode],
/// with reduced motion and while the app is in the background.
class AnimalProgress extends StatefulWidget {
  /// Completed fraction, where 1 is complete.
  final double percent;

  /// Status that colors the fill and enables moving stripes.
  final AnimalProgressStatus status;

  /// Formats the shown fraction (0 to 1) as the label text.
  final String Function(double percent)? format;

  /// Visual overrides for this indicator. They win over
  /// `AnimalIslandTheme.components.progress`.
  final AnimalProgressStyle? style;

  /// Size preset of a linear bar.
  final AnimalProgressSize size;

  /// Position of the label of a linear bar.
  final AnimalProgressInfoPosition infoPosition;

  /// Whether a linear bar paints diagonal candy-cane stripes over its fill.
  final bool striped;

  /// Whether the stripes of an active linear bar move.
  final bool animated;

  /// Diameter of a circular ring.
  final double diameter;

  /// Whether a circular ring shows its label in the center.
  final bool showInfo;

  final bool _circle;

  /// Creates a linear progress bar showing [percent].
  ///
  /// Throws an [ArgumentError] when [percent] is not finite.
  AnimalProgress({
    super.key,
    required double percent,
    this.size = AnimalProgressSize.middle,
    this.status = AnimalProgressStatus.normal,
    this.infoPosition = AnimalProgressInfoPosition.right,
    this.striped = true,
    this.animated = true,
    this.format,
    this.style,
  }) : percent = _checkPercent(percent),
       diameter = 0,
       showInfo = false,
       _circle = false;

  /// Creates a circular progress ring showing [percent].
  ///
  /// Throws an [ArgumentError] when [percent] is not finite or [diameter] is
  /// negative or not finite.
  AnimalProgress.circle({
    super.key,
    required double percent,
    double diameter = 120,
    this.status = AnimalProgressStatus.normal,
    this.showInfo = true,
    this.format,
    this.style,
  }) : percent = _checkPercent(percent),
       diameter = _checkDiameter(diameter),
       size = AnimalProgressSize.middle,
       infoPosition = AnimalProgressInfoPosition.none,
       striped = false,
       animated = false,
       _circle = true;

  static double _checkPercent(double percent) {
    if (!percent.isFinite) {
      throw ArgumentError.value(percent, 'percent', 'must be finite');
    }
    return percent;
  }

  static double _checkDiameter(double diameter) {
    if (!diameter.isFinite || diameter < 0) {
      throw ArgumentError.value(
        diameter,
        'diameter',
        'must be finite and non-negative',
      );
    }
    return diameter;
  }

  @override
  State<AnimalProgress> createState() => _AnimalProgressState();
}

/// The shown fraction and its label, shared by the bar and the ring.
({double fraction, String label}) _progressValue(AnimalProgress widget) {
  final double fraction = widget.percent.clamp(0.0, 1.0);
  final String Function(double)? format = widget.format;
  // The small offset absorbs binary noise such as 0.29 * 100 = 28.99….
  // It also shows a fraction within 1e-11 of complete as 100%.
  return (
    fraction: fraction,
    label: format != null
        ? format(fraction)
        : '${(fraction * 100 + 1e-9).floor()}%',
  );
}

/// One state for both shapes: a widget can change shape at the same place
/// in the tree, and only a striped bar runs its controller.
class _AnimalProgressState extends State<AnimalProgress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _stripes = AnimationController(vsync: this);
  late final AnimalMotionScheduler _scheduler = AnimalMotionScheduler();
  late final AnimalMotionRegistration _motion = _scheduler.scheduleAnimation(
    _stripes,
    eligible: false,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Duration cycle = AnimalIslandTheme.of(context).motion.slow * 4;
    if (_stripes.duration != cycle) {
      _stripes.duration = cycle;
      _motion.restart();
    }
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant AnimalProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  void _syncMotion() {
    _motion.setEligible(
      widget.animated &&
          widget.striped &&
          widget.status == AnimalProgressStatus.active &&
          AnimalMotionPolicy.decorativeContextEligible(context),
    );
  }

  @override
  void dispose() {
    _scheduler.dispose();
    _stripes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget._circle ? _buildRing(context) : _buildBar(context);

  Widget _buildBar(BuildContext context) {
    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final _ResolvedProgressStyle s = _ResolvedProgressStyle.resolve(
      theme: theme,
      style: widget.style,
      size: widget.size,
      status: widget.status,
      infoPosition: widget.infoPosition,
      diameter: null,
    );
    final value = _progressValue(widget);

    final Widget bar = Container(
      height: s.height,
      decoration: BoxDecoration(
        color: s.trackColor,
        borderRadius: theme.radii.pillBorder,
        border: Border.all(
          color: s.trackBorderColor,
          width: s.trackBorderWidth,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double fillWidth = constraints.maxWidth * value.fraction;
          return Stack(
            children: [
              CustomPaint(
                size: Size(fillWidth, s.height),
                painter: AnimalCandyStripePainter(
                  fillColor: s.fillColor,
                  stripeColor: widget.striped ? s.stripeColor : null,
                  phase: _stripes,
                  radius: theme.radii.pill,
                ),
              ),
              // The label sits at the end of the fill, over the fill color.
              if (widget.infoPosition == AnimalProgressInfoPosition.inside &&
                  s.height >= 14 &&
                  fillWidth > 38)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  width: fillWidth,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        end: theme.spacing.sm,
                      ),
                      child: Text(value.label, style: s.insideLabelTextStyle),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );

    final Widget content = switch (widget.infoPosition) {
      AnimalProgressInfoPosition.none ||
      AnimalProgressInfoPosition.inside => bar,
      AnimalProgressInfoPosition.top => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Text(value.label, style: s.labelTextStyle),
          ),
          SizedBox(height: s.labelGap),
          bar,
        ],
      ),
      AnimalProgressInfoPosition.right => Row(
        children: [
          Expanded(child: bar),
          SizedBox(width: s.labelGap),
          Text(value.label, style: s.labelTextStyle),
        ],
      ),
    };

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: AnimalLocalizations.of(context)!.progressLabel,
      value: value.label,
      child: content,
    );
  }

  Widget _buildRing(BuildContext context) {
    final _ResolvedProgressStyle s = _ResolvedProgressStyle.resolve(
      theme: AnimalIslandTheme.of(context),
      style: widget.style,
      size: null,
      status: widget.status,
      infoPosition: AnimalProgressInfoPosition.none,
      diameter: widget.diameter,
    );
    final value = _progressValue(widget);

    return Semantics(
      container: true,
      excludeSemantics: true,
      label: AnimalLocalizations.of(context)!.circularProgressLabel,
      value: value.label,
      child: SizedBox.square(
        dimension: widget.diameter,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size.square(widget.diameter),
              painter: AnimalCircularProgressPainter(
                percent: value.fraction,
                strokeWidth: s.strokeWidth,
                fillColor: s.fillColor,
                trackColor: s.trackColor,
              ),
            ),
            if (widget.showInfo) Text(value.label, style: s.labelTextStyle),
          ],
        ),
      ),
    );
  }
}

/// The one resolution of [AnimalProgress] visuals: instance style, then the
/// size style (linear bars only) and general style of the component theme,
/// then token defaults.
class _ResolvedProgressStyle {
  final Color fillColor;
  final Color trackColor;
  final Color trackBorderColor;
  final double trackBorderWidth;
  final double height;
  final double strokeWidth;
  final Color stripeColor;
  final TextStyle labelTextStyle;
  final TextStyle insideLabelTextStyle;
  final double labelGap;

  const _ResolvedProgressStyle._({
    required this.fillColor,
    required this.trackColor,
    required this.trackBorderColor,
    required this.trackBorderWidth,
    required this.height,
    required this.strokeWidth,
    required this.stripeColor,
    required this.labelTextStyle,
    required this.insideLabelTextStyle,
    required this.labelGap,
  });

  /// [size] is null for a ring, whose label scales with [diameter].
  static _ResolvedProgressStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalProgressStyle? style,
    required AnimalProgressSize? size,
    required AnimalProgressStatus status,
    required AnimalProgressInfoPosition infoPosition,
    required double? diameter,
  }) {
    final AnimalProgressThemeData? themed = theme.components.progress;
    final AnimalProgressStyle? sized = switch (size) {
      AnimalProgressSize.small => themed?.smallStyle,
      AnimalProgressSize.middle => themed?.middleStyle,
      AnimalProgressSize.large => themed?.largeStyle,
      null => null,
    };
    final AnimalProgressStyle merged = (style ?? AnimalProgressStyle())
        .merge(sized)
        .merge(themed?.style);

    final colors = theme.colors;
    final spacing = theme.spacing;
    final typography = theme.typography;
    final bool dark = colors.brightness == Brightness.dark;
    final (Color statusFill, Color onStatus) = switch (status) {
      AnimalProgressStatus.success => (colors.success, colors.onSuccess),
      AnimalProgressStatus.exception => (colors.error, colors.onError),
      AnimalProgressStatus.normal ||
      AnimalProgressStatus.active => (colors.primary, colors.onPrimary),
    };
    final TextStyle labelBase = diameter == null
        ? typography.caption.copyWith(fontWeight: FontWeight.w800)
        : typography.digitLarge.apply(fontSizeFactor: diameter / 180);
    final BoxShadow glow = theme.shadows.softElevation;

    return _ResolvedProgressStyle._(
      fillColor: merged.color ?? statusFill,
      trackColor:
          merged.trackColor ?? (dark ? colors.surfaceAlt : colors.bgDisabled),
      trackBorderColor:
          merged.trackBorderColor ??
          (dark ? colors.border : colors.borderLight),
      trackBorderWidth: merged.trackBorderWidth ?? 1.2,
      height:
          merged.height ??
          switch (size) {
            AnimalProgressSize.small => 8,
            AnimalProgressSize.large => 22,
            AnimalProgressSize.middle || null => 14,
          },
      strokeWidth: merged.strokeWidth ?? 10,
      stripeColor: merged.stripeColor ?? const Color(0x38FFFFFF),
      labelTextStyle: typography
          .resolve(labelBase.merge(merged.labelTextStyle))
          .copyWith(color: merged.labelTextColor ?? colors.text),
      insideLabelTextStyle: typography
          .resolve(
            typography.button
                .apply(fontSizeFactor: 0.8)
                .copyWith(
                  shadows: <Shadow>[
                    Shadow(
                      color: glow.color,
                      offset: glow.offset,
                      blurRadius: glow.blurRadius,
                    ),
                  ],
                )
                .merge(merged.insideLabelTextStyle),
          )
          .copyWith(color: merged.insideLabelTextColor ?? onStatus),
      labelGap:
          merged.labelGap ??
          (infoPosition == AnimalProgressInfoPosition.top
              ? spacing.xs + spacing.xxs
              : spacing.md),
    );
  }
}
