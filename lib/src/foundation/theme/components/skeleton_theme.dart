import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalSkeleton`.
///
/// The same type customizes one skeleton through its `style` parameter and
/// every one through `AnimalIslandTheme.components`. Each field is optional;
/// a null field falls through to the next layer and finally to a default
/// derived from the active theme tokens.
@immutable
class AnimalSkeletonStyle {
  /// Fill of every placeholder block at rest.
  final Color? color;

  /// Color of the shimmer band that sweeps across the blocks.
  final Color? highlightColor;

  /// Corner radius of text and rectangle blocks; paragraph rows stay
  /// pill-shaped and circles stay round.
  final BorderRadius? borderRadius;

  /// Height of a text line and of each paragraph row.
  final double? rowHeight;

  /// Space between paragraph rows.
  final double? rowGap;

  /// Creates a skeleton style.
  ///
  /// Throws an [ArgumentError] if a given dimension or corner radius is
  /// negative or not finite.
  AnimalSkeletonStyle({
    this.color,
    this.highlightColor,
    this.borderRadius,
    this.rowHeight,
    this.rowGap,
  }) {
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkDimension('rowHeight', rowHeight);
    AnimalStyleValues.checkDimension('rowGap', rowGap);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalSkeletonStyle copyWith({
    Color? color,
    Color? highlightColor,
    BorderRadius? borderRadius,
    double? rowHeight,
    double? rowGap,
  }) => AnimalSkeletonStyle(
    color: color ?? this.color,
    highlightColor: highlightColor ?? this.highlightColor,
    borderRadius: borderRadius ?? this.borderRadius,
    rowHeight: rowHeight ?? this.rowHeight,
    rowGap: rowGap ?? this.rowGap,
  );

  /// Returns this style with its null fields taken from [other].
  AnimalSkeletonStyle merge(AnimalSkeletonStyle? other) {
    if (other == null) return this;
    return AnimalSkeletonStyle(
      color: color ?? other.color,
      highlightColor: highlightColor ?? other.highlightColor,
      borderRadius: borderRadius ?? other.borderRadius,
      rowHeight: rowHeight ?? other.rowHeight,
      rowGap: rowGap ?? other.rowGap,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalSkeletonStyle? lerp(
    AnimalSkeletonStyle? a,
    AnimalSkeletonStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalSkeletonStyle(
      color: AnimalStyleValues.lerpColor(a?.color, b?.color, t),
      highlightColor: AnimalStyleValues.lerpColor(
        a?.highlightColor,
        b?.highlightColor,
        t,
      ),
      borderRadius: AnimalStyleValues.lerpRadius(
        a?.borderRadius,
        b?.borderRadius,
        t,
      ),
      rowHeight: AnimalStyleValues.lerpDimension(a?.rowHeight, b?.rowHeight, t),
      rowGap: AnimalStyleValues.lerpDimension(a?.rowGap, b?.rowGap, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalSkeletonStyle &&
          other.color == color &&
          other.highlightColor == highlightColor &&
          other.borderRadius == borderRadius &&
          other.rowHeight == rowHeight &&
          other.rowGap == rowGap;

  @override
  int get hashCode =>
      Object.hash(color, highlightColor, borderRadius, rowHeight, rowGap);
}
