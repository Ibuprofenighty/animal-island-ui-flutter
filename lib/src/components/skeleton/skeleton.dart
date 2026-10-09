import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/skeleton_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';

/// Skeleton shape and composite variants for [AnimalSkeleton] (C26).
enum AnimalSkeletonVariant {
  /// Single line of text with pill radius.
  text,

  /// Circular shape for avatars or icon placeholders.
  circle,

  /// Rectangular box for cards or images.
  rect,

  /// Multi-line paragraph with staggered line widths.
  paragraph,
}

/// Animal Island warm parchment skeleton placeholder (C26).
///
/// While [loading] is true it shows placeholder blocks; when [loading] is
/// false it shows [child] instead, or the placeholder when there is no child.
/// The placeholder is announced as loading and exposes no fake text or
/// controls.
///
/// A shimmer sweeps across the blocks while [active] is true. It rests, and
/// the blocks show their plain fill, under a disabled [TickerMode], with
/// reduced motion and while the app is in the background.
class AnimalSkeleton extends StatefulWidget {
  /// Whether the skeleton is in loading state. If false, renders [child].
  final bool loading;

  /// Skeleton shape variant.
  final AnimalSkeletonVariant variant;

  /// Whether the shimmer animation runs.
  final bool active;

  /// Width in logical pixels; text and rectangle blocks fill the available
  /// width when null. For a paragraph it is the width used when the
  /// available width is unbounded.
  final double? width;

  /// Height in logical pixels of a text, rectangle or circle block.
  final double? height;

  /// Number of rows when [variant] is [AnimalSkeletonVariant.paragraph].
  final int rows;

  /// Width of each paragraph row as a fraction of the paragraph width, from 0
  /// to 1. Rows without an entry use 1, 0.82 and 0.6 for the first three
  /// rows and 1 after them.
  final List<double>? rowWidths;

  /// Visual overrides for this skeleton. They win over
  /// `AnimalIslandTheme.components.skeleton`.
  final AnimalSkeletonStyle? style;

  /// Child widget rendered when [loading] is false.
  final Widget? child;

  /// Whether a rectangle uses the pill radius by default instead of the card
  /// radius.
  final bool _pillRectangle;

  /// Creates a skeleton placeholder shown while [loading] is true.
  ///
  /// Throws an [ArgumentError] when [width] or [height] is negative or not
  /// finite, [rows] is less than 1, or an entry of [rowWidths] is not between
  /// 0 and 1.
  AnimalSkeleton({
    super.key,
    this.loading = true,
    this.variant = AnimalSkeletonVariant.rect,
    this.active = true,
    double? width,
    double? height,
    int rows = 3,
    List<double>? rowWidths,
    this.style,
    this.child,
  }) : width = _checkExtent('width', width),
       height = _checkExtent('height', height),
       rows = _checkRows(rows),
       rowWidths = _checkRowWidths(rowWidths),
       _pillRectangle = false;

  AnimalSkeleton._preset({
    super.key,
    required this.variant,
    required this.active,
    required this.style,
    double? width,
    double? height,
    int rows = 3,
    List<double>? rowWidths,
  }) : width = _checkExtent('width', width),
       height = _checkExtent('height', height),
       rows = _checkRows(rows),
       rowWidths = _checkRowWidths(rowWidths),
       loading = true,
       child = null,
       _pillRectangle = true;

  /// Preset for a button placeholder.
  ///
  /// Throws an [ArgumentError] when [width] or [height] is negative or not
  /// finite.
  factory AnimalSkeleton.button({
    Key? key,
    double? width = 100.0,
    double height = 44.0,
    bool active = true,
    AnimalSkeletonStyle? style,
  }) => AnimalSkeleton._preset(
    key: key,
    variant: AnimalSkeletonVariant.rect,
    width: width,
    height: height,
    active: active,
    style: style,
  );

  /// Preset for a form input placeholder.
  ///
  /// Throws an [ArgumentError] when [width] or [height] is negative or not
  /// finite.
  factory AnimalSkeleton.input({
    Key? key,
    double? width,
    double height = 44.0,
    bool active = true,
    AnimalSkeletonStyle? style,
  }) => AnimalSkeleton._preset(
    key: key,
    variant: AnimalSkeletonVariant.rect,
    width: width,
    height: height,
    active: active,
    style: style,
  );

  /// Preset for an avatar or round icon placeholder.
  ///
  /// Throws an [ArgumentError] when [size] is negative or not finite.
  factory AnimalSkeleton.avatar({
    Key? key,
    double size = 44.0,
    bool active = true,
    AnimalSkeletonStyle? style,
  }) => AnimalSkeleton._preset(
    key: key,
    variant: AnimalSkeletonVariant.circle,
    width: size,
    height: size,
    active: active,
    style: style,
  );

  /// Preset for a multi-line paragraph block.
  ///
  /// Throws an [ArgumentError] when [rows] is less than 1 or an entry of
  /// [rowWidths] is not between 0 and 1.
  factory AnimalSkeleton.paragraph({
    Key? key,
    int rows = 3,
    List<double>? rowWidths,
    bool active = true,
    AnimalSkeletonStyle? style,
  }) => AnimalSkeleton._preset(
    key: key,
    variant: AnimalSkeletonVariant.paragraph,
    rows: rows,
    rowWidths: rowWidths,
    active: active,
    style: style,
  );

  static double? _checkExtent(String name, double? value) {
    if (value != null && (!value.isFinite || value < 0)) {
      throw ArgumentError.value(value, name, 'must be finite and non-negative');
    }
    return value;
  }

  static int _checkRows(int rows) {
    if (rows < 1) throw ArgumentError.value(rows, 'rows', 'must be at least 1');
    return rows;
  }

  static List<double>? _checkRowWidths(List<double>? rowWidths) {
    if (rowWidths == null) return null;
    for (final double fraction in rowWidths) {
      if (!(fraction >= 0 && fraction <= 1)) {
        throw ArgumentError.value(
          rowWidths,
          'rowWidths',
          'every entry must be between 0 and 1',
        );
      }
    }
    return List<double>.unmodifiable(rowWidths);
  }

  @override
  State<AnimalSkeleton> createState() => _AnimalSkeletonState();
}

/// Default paragraph row widths, as fractions of the paragraph width.
const List<double> _defaultRowWidths = <double>[1.0, 0.82, 0.60];

class _AnimalSkeletonState extends State<AnimalSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer = AnimationController(vsync: this);
  late final AnimalMotionScheduler _scheduler = AnimalMotionScheduler();
  late final AnimalMotionRegistration _motion = _scheduler.scheduleAnimation(
    _shimmer,
    eligible: false,
  );
  bool _shimmering = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Duration cycle = AnimalIslandTheme.of(context).motion.slow * 4;
    if (_shimmer.duration != cycle) {
      _shimmer.duration = cycle;
      _motion.restart();
    }
    _syncMotion();
  }

  @override
  void didUpdateWidget(AnimalSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncMotion();
  }

  void _syncMotion() {
    _shimmering =
        widget.loading &&
        widget.active &&
        AnimalMotionPolicy.decorativeContextEligible(context);
    _motion.setEligible(_shimmering);
  }

  @override
  void dispose() {
    _scheduler.dispose();
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? child = widget.child;
    if (!widget.loading && child != null) return child;

    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final _ResolvedSkeletonStyle s = _ResolvedSkeletonStyle.resolve(
      theme: theme,
      style: widget.style,
      pillRectangle: widget._pillRectangle,
    );

    Widget block({
      double? width,
      double? height,
      BorderRadius? radius,
      BoxShape shape = BoxShape.rectangle,
    }) {
      BoxDecoration decoration(Gradient? gradient) => BoxDecoration(
        color: gradient == null ? s.color : null,
        gradient: gradient,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? radius : null,
      );
      if (!_shimmering) {
        return Container(
          width: width,
          height: height,
          decoration: decoration(null),
        );
      }
      return AnimatedBuilder(
        animation: _shimmer,
        builder: (context, _) {
          // At rest (0) and at the end (1) the highlight is off the block, so
          // a stopped shimmer shows the plain fill.
          final double sweep = _shimmer.value * 5.0;
          return Container(
            width: width,
            height: height,
            decoration: decoration(
              LinearGradient(
                begin: Alignment(-3 + sweep, 0),
                end: Alignment(-1 + sweep, 0),
                colors: [s.color, s.highlightColor, s.color],
              ),
            ),
          );
        },
      );
    }

    final Widget content = switch (widget.variant) {
      AnimalSkeletonVariant.circle => block(
        width: widget.width ?? widget.height ?? 44.0,
        height: widget.width ?? widget.height ?? 44.0,
        shape: BoxShape.circle,
      ),
      AnimalSkeletonVariant.text => block(
        width: widget.width,
        height: widget.height ?? s.rowHeight,
        radius: s.textBorderRadius,
      ),
      AnimalSkeletonVariant.rect => block(
        width: widget.width,
        height: widget.height ?? 100.0,
        radius: s.rectBorderRadius,
      ),
      AnimalSkeletonVariant.paragraph => LayoutBuilder(
        builder: (context, constraints) {
          final bool bounded = constraints.hasBoundedWidth;
          final double paragraphWidth = bounded
              ? constraints.maxWidth
              : (widget.width ?? 280.0);
          final List<double>? rowWidths = widget.rowWidths;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int index = 0; index < widget.rows; index++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.rows - 1 ? 0 : s.rowGap,
                  ),
                  child: block(
                    width:
                        paragraphWidth *
                        (rowWidths != null && index < rowWidths.length
                            ? rowWidths[index]
                            : index < _defaultRowWidths.length
                            ? _defaultRowWidths[index]
                            : 1.0),
                    height: s.rowHeight,
                    radius: theme.radii.pillBorder,
                  ),
                ),
            ],
          );
        },
      ),
    };

    return Semantics(
      label: AnimalLocalizations.of(context)!.loading,
      child: content,
    );
  }
}

/// The one resolution of [AnimalSkeleton] visuals: instance style, then the
/// component theme, then token defaults.
class _ResolvedSkeletonStyle {
  final Color color;
  final Color highlightColor;

  final BorderRadius textBorderRadius;
  final BorderRadius rectBorderRadius;
  final double rowHeight;
  final double rowGap;

  const _ResolvedSkeletonStyle._({
    required this.color,
    required this.highlightColor,
    required this.textBorderRadius,
    required this.rectBorderRadius,
    required this.rowHeight,
    required this.rowGap,
  });

  static _ResolvedSkeletonStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalSkeletonStyle? style,
    required bool pillRectangle,
  }) {
    final AnimalSkeletonStyle merged = (style ?? AnimalSkeletonStyle()).merge(
      theme.components.skeleton,
    );
    final colors = theme.colors;
    final bool dark = colors.brightness == Brightness.dark;
    return _ResolvedSkeletonStyle._(
      color: merged.color ?? (dark ? colors.surfaceHeader : colors.bgDisabled),
      highlightColor:
          merged.highlightColor ?? (dark ? colors.surfaceAlt : colors.bgInput),
      textBorderRadius: merged.borderRadius ?? theme.radii.pillBorder,
      rectBorderRadius:
          merged.borderRadius ??
          (pillRectangle ? theme.radii.pillBorder : theme.radii.cardBorder),
      rowHeight: merged.rowHeight ?? 16.0,
      rowGap: merged.rowGap ?? theme.spacing.md - theme.spacing.xxs,
    );
  }
}
