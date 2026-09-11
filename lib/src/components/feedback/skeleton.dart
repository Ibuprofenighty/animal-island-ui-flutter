import 'package:flutter/widgets.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';

/// Skeleton shape and composite variants.
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

/// SOTA Animal Island warm parchment Skeleton shimmer loader.
///
/// Supports declarative wrapper mode (`loading: bool, child: Widget`),
/// composite presets (`AnimalSkeleton.button`, `AnimalSkeleton.input`,
/// `AnimalSkeleton.avatar`, `AnimalSkeleton.paragraph`), and full dark mode adaptation.
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
  });

  /// Preset for button placeholder.
  factory AnimalSkeleton.button({
    Key? key,
    double? width = 100.0,
    double height = 44.0,
    bool active = true,
    BorderRadius? borderRadius,
  }) {
    return AnimalSkeleton(
      key: key,
      variant: AnimalSkeletonVariant.rect,
      width: width,
      height: height,
      borderRadius: borderRadius ?? AnimalRadii.pillBorder,
      active: active,
    );
  }

  /// Preset for form input placeholder.
  factory AnimalSkeleton.input({
    Key? key,
    double? width,
    double height = 44.0,
    bool active = true,
  }) {
    return AnimalSkeleton(
      key: key,
      variant: AnimalSkeletonVariant.rect,
      width: width,
      height: height,
      borderRadius: AnimalRadii.pillBorder,
      active: active,
    );
  }

  /// Preset for circular or rounded square avatar placeholder.
  factory AnimalSkeleton.avatar({
    Key? key,
    double size = 44.0,
    bool circle = true,
    bool active = true,
  }) {
    return AnimalSkeleton(
      key: key,
      variant: circle ? AnimalSkeletonVariant.circle : AnimalSkeletonVariant.rect,
      width: size,
      height: size,
      borderRadius: circle ? null : AnimalRadii.cardBorder,
      active: active,
    );
  }

  /// Preset for multi-line text paragraph placeholder.
  factory AnimalSkeleton.paragraph({
    Key? key,
    int rows = 3,
    List<double>? rowWidths,
    bool active = true,
  }) {
    return AnimalSkeleton(
      key: key,
      variant: AnimalSkeletonVariant.paragraph,
      rows: rows,
      rowWidths: rowWidths,
      active: active,
    );
  }

  @override
  State<AnimalSkeleton> createState() => _AnimalSkeletonState();
}

class _AnimalSkeletonState extends State<AnimalSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.active && widget.loading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimalSkeleton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && widget.loading) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      if (_controller.isAnimating) _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.loading && widget.child != null) {
      return widget.child!;
    }

    final theme = AnimalIslandTheme.of(context);
    final isDark = theme.isDark;

    final baseColor = isDark ? theme.surfaceHeader : AnimalColors.bgDisabled;
    final highlightColor = isDark ? theme.surfaceAlt : AnimalColors.bgInput;

    Widget buildBlock({
      double? w,
      double? h,
      BorderRadius? radius,
      BoxShape shape = BoxShape.rectangle,
    }) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final gradient = widget.active
              ? LinearGradient(
                  begin: Alignment(-2.5 + _controller.value * 5.0, 0),
                  end: Alignment(-0.5 + _controller.value * 5.0, 0),
                  colors: [baseColor, highlightColor, baseColor],
                )
              : null;

          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: widget.active ? null : baseColor,
              gradient: gradient,
              shape: shape,
              borderRadius: shape == BoxShape.rectangle ? radius : null,
            ),
          );
        },
      );
    }

    switch (widget.variant) {
      case AnimalSkeletonVariant.circle:
        final size = widget.width ?? widget.height ?? 44.0;
        return buildBlock(w: size, h: size, shape: BoxShape.circle);

      case AnimalSkeletonVariant.text:
        return buildBlock(
          w: widget.width,
          h: widget.height ?? 16.0,
          radius: widget.borderRadius ?? AnimalRadii.pillBorder,
        );

      case AnimalSkeletonVariant.rect:
        return buildBlock(
          w: widget.width,
          h: widget.height ?? 100.0,
          radius: widget.borderRadius ?? AnimalRadii.cardBorder,
        );

      case AnimalSkeletonVariant.paragraph:
        final defaultWidths = [1.0, 0.82, 0.60];
        return LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedWidth = constraints.hasBoundedWidth;
            final baseWidth = hasBoundedWidth ? constraints.maxWidth : (widget.width ?? 280.0);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(widget.rows, (index) {
                double ratio = 1.0;
                if (widget.rowWidths != null && index < widget.rowWidths!.length) {
                  ratio = widget.rowWidths![index];
                } else if (index < defaultWidths.length) {
                  ratio = defaultWidths[index];
                }

                return Padding(
                  padding: EdgeInsets.only(bottom: index == widget.rows - 1 ? 0 : 10.0),
                  child: hasBoundedWidth
                      ? FractionallySizedBox(
                          widthFactor: ratio.clamp(0.0, 1.0),
                          child: buildBlock(
                            h: 16.0,
                            radius: AnimalRadii.pillBorder,
                          ),
                        )
                      : buildBlock(
                          w: baseWidth * ratio.clamp(0.0, 1.0),
                          h: 16.0,
                          radius: AnimalRadii.pillBorder,
                        ),
                );
              }),
            );
          },
        );
    }
  }
}

