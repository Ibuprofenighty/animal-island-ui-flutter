import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'style_values.dart';

/// Appearance of the shared keyboard focus ring.
///
/// Every focusable component draws the same ring, so this style is themed once
/// for the whole library. The ring may be made wider but never narrower than
/// [minimumWidth], which keeps the focus indicator visible.
@immutable
class AnimalFocusRingStyle {
  /// The narrowest ring width this library will draw.
  static const double minimumWidth = 2;

  /// Stroke width of the ring; at least [minimumWidth]. Defaults to 2.5.
  final double? width;

  /// Gap between the component edge and the ring.
  final double? offset;

  /// Ring color. Choose one with at least 3:1 contrast against its surface.
  final Color? color;

  /// Creates a focus ring style.
  ///
  /// Throws an [ArgumentError] if [width] is not finite or is below
  /// [minimumWidth], or if [offset] is negative or not finite.
  AnimalFocusRingStyle({this.width, this.offset, this.color}) {
    AnimalStyleValues.checkDimension('width', width, minimum: minimumWidth);
    AnimalStyleValues.checkDimension('offset', offset);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalFocusRingStyle copyWith({
    double? width,
    double? offset,
    Color? color,
  }) => AnimalFocusRingStyle(
    width: width ?? this.width,
    offset: offset ?? this.offset,
    color: color ?? this.color,
  );

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalFocusRingStyle? lerp(
    AnimalFocusRingStyle? a,
    AnimalFocusRingStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalFocusRingStyle(
      width: AnimalStyleValues.lerpDimension(a?.width, b?.width, t),
      offset: AnimalStyleValues.lerpDimension(a?.offset, b?.offset, t),
      color: AnimalStyleValues.lerpColor(a?.color, b?.color, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalFocusRingStyle &&
          width == other.width &&
          offset == other.offset &&
          color == other.color;

  @override
  int get hashCode => Object.hash(width, offset, color);
}
