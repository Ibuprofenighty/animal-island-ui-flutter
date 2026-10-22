import '../internal/content_scope.dart';
import '../foundation/theme.dart';
import '../internal/managed_image.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/size.dart';
import '../foundation/icon.dart';
import '../internal/overlapping_row.dart';

enum IslandAvatarShape { circle, square }

class IslandAvatar extends StatefulWidget {
  const IslandAvatar({
    super.key,
    this.child,
    this.icon,
    this.image,
    this.semanticLabel,
    this.size,
    this.dimension,
    this.shape,
    this.gap = 4,
    this.onImageError,
  }) : assert(dimension == null || dimension > 0),
       assert(gap >= 0),
       assert(size == null || dimension == null);
  final Widget? child, icon;
  final ImageProvider? image;
  final String? semanticLabel;
  final IslandSize? size;
  final double? dimension;
  final IslandAvatarShape? shape;
  final double gap;

  /// Return false to leave the image area empty instead of using fallback content.
  final bool Function(Object error, StackTrace? stack)? onImageError;
  @override
  State<IslandAvatar> createState() => _IslandAvatarState();
}

class _IslandAvatarState extends State<IslandAvatar> {
  @override
  Widget build(BuildContext context) {
    final defaults = context
        .dependOnInheritedWidgetOfExactType<_AvatarDefaults>();
    final preset =
        widget.size ??
        (widget.dimension == null ? defaults?.size : null) ??
        IslandSize.middle;
    final dimension =
        widget.dimension ?? (widget.size == null ? defaults?.dimension : null);
    final px =
        dimension ??
        switch (preset) {
          IslandSize.small => 32.0,
          IslandSize.middle => 40.0,
          IslandSize.large => 48.0,
        };
    final font = dimension != null
        ? math.max(12.0, (px * .4).roundToDouble())
        : switch (preset) {
            IslandSize.small => 14.0,
            IslandSize.middle => 16.0,
            IslandSize.large => 20.0,
          };
    final shape = widget.shape ?? defaults?.shape ?? IslandAvatarShape.circle;
    final radius = BorderRadius.circular(
      shape == IslandAvatarShape.circle ? px / 2 : 8,
    );
    Widget fallback() => DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xfff8f8f0), width: 2),
        borderRadius: radius,
      ),
      child: Padding(
        padding: EdgeInsets.all(widget.gap),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ContentScope(
              textStyle: TextStyle(
                color: const Color(0xff794f27),
                fontSize: font,
                height: 1,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
              child:
                  widget.icon ??
                  widget.child ??
                  IslandIcon(IslandGlyph.user, size: (px * .5).roundToDouble()),
            ),
          ),
        ),
      ),
    );
    Widget content = fallback();
    if (widget.image != null) {
      content = ManagedImage(
        image: widget.image!,
        fit: BoxFit.cover,
        width: px,
        height: px,
        onError: widget.onImageError,
        errorBuilder: (_, error, stack, allow) =>
            allow ? fallback() : const SizedBox.expand(),
      );
    }
    Widget visual = Container(
      width: px,
      height: px,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xffe6f9f6),
        borderRadius: radius,
      ),
      foregroundDecoration: defaults == null
          ? null
          : BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: const Color(0xfff8f8f0), width: 2),
            ),
      child: content,
    );
    if (widget.semanticLabel != null)
      visual = Semantics(
        image: true,
        label: widget.semanticLabel,
        child: ExcludeSemantics(child: visual),
      );
    return visual;
  }
}

class IslandAvatarGroup extends StatelessWidget {
  IslandAvatarGroup({
    super.key,
    required List<Widget> children,
    this.maxCount,
    this.size,
    this.dimension,
    this.shape,
    this.overlap = 8,
    this.moreBuilder,
  }) : children = List.unmodifiable(children),
       assert(maxCount == null || maxCount > 0),
       assert(overlap >= 0),
       assert(dimension == null || dimension > 0),
       assert(size == null || dimension == null);
  final List<Widget> children;
  final int? maxCount;
  final IslandSize? size;
  final double? dimension;
  final IslandAvatarShape? shape;
  final double overlap;
  final Widget Function(int hiddenCount)? moreBuilder;
  @override
  Widget build(BuildContext context) {
    final count = math.min(maxCount ?? children.length, children.length);
    final rest = children.length - count;
    return _AvatarDefaults(
      size: size,
      dimension: dimension,
      shape: shape,
      child: OverlappingRow(
        overlap: overlap,
        children: [
          ...children.take(count),
          if (rest > 0)
            moreBuilder?.call(rest) ??
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xffe6f9f6),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xfff8f8f0),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    '+$rest',
                    style: TextStyle(
                      fontSize: 14,
                      height: 19 / 14,
                      color: IslandTokens.light.link,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _AvatarDefaults extends InheritedWidget {
  const _AvatarDefaults({
    required this.size,
    required this.dimension,
    required this.shape,
    required super.child,
  });
  final IslandSize? size;
  final double? dimension;
  final IslandAvatarShape? shape;
  @override
  bool updateShouldNotify(_AvatarDefaults old) =>
      old.size != size || old.dimension != dimension || old.shape != shape;
}
