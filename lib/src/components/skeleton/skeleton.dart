import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
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

enum _AnimalSkeletonRadius { variant, pill }

/// SOTA Animal Island warm parchment Skeleton shimmer loader (C26).
///
/// Features:
/// - Declarative wrapper mode (`loading: bool, child: Widget`).
/// - Static mode optimization: strictly skips [AnimationController] and Ticker
///   allocation when `active == false` or `loading == false`.
/// - Dark and light surfaces come from the active theme color family.
/// - Preset constructors: [AnimalSkeleton.button], [AnimalSkeleton.input],
///   [AnimalSkeleton.avatar], [AnimalSkeleton.paragraph].
class AnimalSkeleton extends StatefulWidget {
  /// Whether the skeleton is in loading state. If false, renders [child].
  final bool loading;

  /// Skeleton shape variant.
  final AnimalSkeletonVariant variant;

  /// Whether the shimmer animation is active.
  final bool active;

  /// Explicit width in logical pixels.
  final double? width;

  /// Explicit height in logical pixels.
  final double? height;

  /// Border radius of the skeleton element.
  final BorderRadius? borderRadius;

  /// Number of lines when [variant] is [AnimalSkeletonVariant.paragraph].
  final int rows;

  /// Proportional or absolute line widths for paragraph lines.
  /// If null, defaults to staggered widths: 100%, 85%, 60%.
  final List<double>? rowWidths;

  /// Child widget rendered when [loading] is false.
  final Widget? child;
  final _AnimalSkeletonRadius _defaultRadius;

  /// Creates a skeleton placeholder shown while [loading] is true.
  const AnimalSkeleton({
    super.key,
    this.loading = true,
    this.variant = AnimalSkeletonVariant.rect,
    this.active = true,
    this.width,
    this.height,
    this.borderRadius,
    this.rows = 3,
    this.rowWidths,
    this.child,
  }) : _defaultRadius = _AnimalSkeletonRadius.variant;

  const AnimalSkeleton._preset({
    super.key,
    this.variant = AnimalSkeletonVariant.rect,
    this.active = true,
    this.width,
    this.height,
    this.borderRadius,
    this.rows = 3,
    this.rowWidths,
    required this._defaultRadius,
  }) : loading = true,
       child = null;

  /// Preset for button placeholder.
  factory AnimalSkeleton.button({
    Key? key,
    double? width = 100.0,
    double height = 44.0,
    bool active = true,
    BorderRadius? borderRadius,
  }) {
    return AnimalSkeleton._preset(
      key: key,
      variant: AnimalSkeletonVariant.rect,
      width: width,
      height: height,
      borderRadius: borderRadius,
      active: active,
      defaultRadius: _AnimalSkeletonRadius.pill,
    );
  }

  /// Preset for form input placeholder.
  factory AnimalSkeleton.input({
    Key? key,
    double? width,
    double height = 44.0,
    bool active = true,
  }) {
    return AnimalSkeleton._preset(
      key: key,
      variant: AnimalSkeletonVariant.rect,
      width: width,
      height: height,
      active: active,
      defaultRadius: _AnimalSkeletonRadius.pill,
    );
  }

  /// Preset for avatar or round icon placeholder.
  factory AnimalSkeleton.avatar({
    Key? key,
    double size = 44.0,
    bool active = true,
  }) {
    return AnimalSkeleton._preset(
      key: key,
      variant: AnimalSkeletonVariant.circle,
      width: size,
      height: size,
      active: active,
      defaultRadius: _AnimalSkeletonRadius.variant,
    );
  }

  /// Preset for multi-line paragraph block.
  factory AnimalSkeleton.paragraph({
    Key? key,
    int rows = 3,
    List<double>? rowWidths,
    bool active = true,
  }) {
    return AnimalSkeleton._preset(
      key: key,
      variant: AnimalSkeletonVariant.paragraph,
      rows: rows,
      rowWidths: rowWidths,
      active: active,
      defaultRadius: _AnimalSkeletonRadius.pill,
    );
  }

  @override
  State<AnimalSkeleton> createState() => _AnimalSkeletonState();
}

class _AnimalSkeletonState extends State<AnimalSkeleton>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  bool _tickerModeEnabled = true;
  Duration? _shimmerDuration;

  bool get _usesPillRadius =>
      widget._defaultRadius == _AnimalSkeletonRadius.pill;

  @override
  void initState() {
    super.initState();
  }

  bool get _shouldAnimate =>
      widget.loading && widget.active && _tickerModeEnabled;

  void _syncAnimation() {
    _controller?.duration = _shimmerDuration!;
    if (_shouldAnimate) {
      _controller ??= AnimationController(
        vsync: this,
        duration: _shimmerDuration!,
      );
      if (!_controller!.isAnimating) {
        _controller!.repeat();
      }
    } else {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _shimmerDuration = AnimalIslandTheme.of(context).motion.slow * (1400 / 350);
    final enabled = AnimalMotionPolicy.shouldAnimate(context);
    _tickerModeEnabled = enabled;
    _syncAnimation();
  }

  @override
  void didUpdateWidget(AnimalSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.loading != widget.loading) {
      _syncAnimation();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading && widget.child != null) {
      return widget.child!;
    }

    final theme = AnimalIslandTheme.of(context);
    final isDark = theme.colors.brightness == Brightness.dark;

    final baseColor = isDark
        ? theme.colors.surfaceHeader
        : theme.colors.bgDisabled;
    final highlightColor = isDark
        ? theme.colors.surfaceAlt
        : theme.colors.bgInput;

    Widget buildBlock({
      double? w,
      double? h,
      BorderRadius? radius,
      BoxShape shape = BoxShape.rectangle,
    }) {
      if (_controller != null) {
        return AnimatedBuilder(
          animation: _controller!,
          builder: (context, _) {
            final gradient = LinearGradient(
              begin: Alignment(-2.5 + _controller!.value * 5.0, 0),
              end: Alignment(-0.5 + _controller!.value * 5.0, 0),
              colors: [baseColor, highlightColor, baseColor],
            );

            return Container(
              width: w,
              height: h,
              decoration: BoxDecoration(
                gradient: gradient,
                shape: shape,
                borderRadius: shape == BoxShape.rectangle ? radius : null,
              ),
            );
          },
        );
      }

      // Static mode: 0 frame scheduler overhead
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: baseColor,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle ? radius : null,
        ),
      );
    }

    Widget content;

    switch (widget.variant) {
      case AnimalSkeletonVariant.circle:
        final size = widget.width ?? widget.height ?? 44.0;
        content = buildBlock(w: size, h: size, shape: BoxShape.circle);
        break;

      case AnimalSkeletonVariant.text:
        content = buildBlock(
          w: widget.width,
          h: widget.height ?? 16.0,
          radius: widget.borderRadius ?? theme.radii.pillBorder,
        );
        break;

      case AnimalSkeletonVariant.rect:
        content = buildBlock(
          w: widget.width,
          h: widget.height ?? 100.0,
          radius:
              widget.borderRadius ??
              (_usesPillRadius
                  ? theme.radii.pillBorder
                  : theme.radii.cardBorder),
        );
        break;

      case AnimalSkeletonVariant.paragraph:
        const defaultWidths = [1.0, 0.82, 0.60];
        content = LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedWidth = constraints.hasBoundedWidth;
            final baseWidth = hasBoundedWidth
                ? constraints.maxWidth
                : (widget.width ?? 280.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.rows, (index) {
                double ratio = 1.0;
                if (widget.rowWidths != null &&
                    index < widget.rowWidths!.length) {
                  ratio = widget.rowWidths![index];
                } else if (index < defaultWidths.length) {
                  ratio = defaultWidths[index];
                }

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == widget.rows - 1
                        ? 0
                        : theme.spacing.md - theme.spacing.xxs,
                  ),
                  child: hasBoundedWidth
                      ? FractionallySizedBox(
                          widthFactor: ratio.clamp(0.0, 1.0),
                          child: buildBlock(
                            h: 16.0,
                            radius: theme.radii.pillBorder,
                          ),
                        )
                      : buildBlock(
                          w: baseWidth * ratio.clamp(0.0, 1.0),
                          h: 16.0,
                          radius: theme.radii.pillBorder,
                        ),
                );
              }),
            );
          },
        );
        break;
    }

    return Semantics(
      label: AnimalLocalizations.of(context)!.loading,
      child: content,
    );
  }
}
