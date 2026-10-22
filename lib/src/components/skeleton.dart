import 'package:flutter/material.dart';

import '../foundation/size.dart';

enum IslandSkeletonVariant { text, circle, rect, paragraph }

class IslandSkeleton extends StatelessWidget {
  const IslandSkeleton({
    super.key,
    this.loading = true,
    this.active = true,
    this.variant = IslandSkeletonVariant.text,
    this.width,
    this.height,
    this.rows = 3,
    this.rowWidths,
    this.child,
    this.radius,
  }) : assert(rows > 0),
       assert(width == null || width > 0),
       assert(height == null || height > 0);
  final bool loading, active;
  final IslandSkeletonVariant variant;
  final double? width, height, radius;
  final int rows;

  /// Fractions in (0, 1]. Missing rows repeat the last supplied fraction;
  /// an empty list uses full width. Null uses the reference default sequence.
  final List<double>? rowWidths;
  final Widget? child;
  @override
  Widget build(BuildContext context) {
    if (!loading && child != null) return child!;
    if (rowWidths?.any((v) => v <= 0 || v > 1) ?? false) {
      throw ArgumentError.value(
        rowWidths,
        'rowWidths',
        'Expected fractions in (0, 1].',
      );
    }
    Widget bar(
      double? w,
      double h,
      double r, {
      Color color = const Color(0xffeae5db),
    }) =>
        _Shimmer(width: w, height: h, radius: r, active: active, color: color);
    final widths = rowWidths ?? const [1.0, .92, .84, .76, .68];
    return ExcludeSemantics(
      child: switch (variant) {
        IslandSkeletonVariant.paragraph => _Shimmer(
          width: width,
          height: rows * (height ?? 14) + (rows - 1) * 10,
          radius: 0,
          active: active,
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < rows; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                FractionallySizedBox(
                  widthFactor: widths.isEmpty
                      ? 1
                      : widths[i.clamp(0, widths.length - 1)],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius ?? 12),
                    child: SizedBox(
                      height: height ?? 14,
                      child: const ColoredBox(color: Color(0xffdfd9ce)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        IslandSkeletonVariant.text => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: bar(width, height ?? 16, radius ?? 12),
        ),
        IslandSkeletonVariant.circle => bar(
          width ?? height ?? 44,
          width ?? height ?? 44,
          radius ?? 999,
        ),
        IslandSkeletonVariant.rect => bar(width, height ?? 120, radius ?? 18),
      },
    );
  }
}

class IslandSkeletonButton extends StatelessWidget {
  const IslandSkeletonButton({
    super.key,
    this.size = IslandSize.middle,
    this.active = true,
  });
  final IslandSize size;
  final bool active;
  @override
  Widget build(BuildContext context) => IslandSkeleton(
    variant: IslandSkeletonVariant.rect,
    active: active,
    width: size == IslandSize.small
        ? 80
        : size == IslandSize.large
        ? 130
        : 100,
    height: size == IslandSize.small
        ? 32
        : size == IslandSize.large
        ? 48
        : 45,
    radius: 50,
  );
}

class IslandSkeletonInput extends StatelessWidget {
  const IslandSkeletonInput({
    super.key,
    this.size = IslandSize.middle,
    this.active = true,
    this.width,
  });
  final IslandSize size;
  final bool active;
  final double? width;
  @override
  Widget build(BuildContext context) => IslandSkeleton(
    variant: IslandSkeletonVariant.rect,
    active: active,
    width:
        width ??
        (size == IslandSize.small
            ? 160
            : size == IslandSize.large
            ? 240
            : 200),
    height: size == IslandSize.small
        ? 32
        : size == IslandSize.large
        ? 48
        : 40,
    radius: 50,
  );
}

class IslandSkeletonAvatar extends StatelessWidget {
  const IslandSkeletonAvatar({
    super.key,
    this.size = IslandSize.middle,
    this.active = true,
    this.square = false,
  });
  final IslandSize size;
  final bool active, square;
  @override
  Widget build(BuildContext context) => IslandSkeleton(
    radius: square ? 12 : 999,
    variant: IslandSkeletonVariant.circle,
    active: active,
    width: size == IslandSize.small
        ? 32
        : size == IslandSize.large
        ? 56
        : 44,
  );
}

class _Shimmer extends StatefulWidget {
  const _Shimmer({
    this.width,
    required this.height,
    required this.radius,
    required this.active,
    required this.color,
    this.child,
  });
  final double? width;
  final double height, radius;
  final bool active;
  final Color color;
  final Widget? child;
  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(_Shimmer old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final animate = widget.active && !MediaQuery.disableAnimationsOf(context);
    if (animate && !controller.isAnimating) controller.repeat();
    if (!animate) controller.stop();
    if (!widget.active) controller.reset();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(widget.radius),
    child: SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: widget.color, child: widget.child),
          if (widget.active && !MediaQuery.disableAnimationsOf(context))
            LayoutBuilder(
              builder: (_, constraints) => AnimatedBuilder(
                animation: controller,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    (Curves.easeInOut.transform(controller.value) * 2 - 1) *
                        constraints.maxWidth,
                    0,
                  ),
                  child: child,
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x2efffaeb),
                        Color(0x8cfffcf2),
                        Color(0x2efffaeb),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
