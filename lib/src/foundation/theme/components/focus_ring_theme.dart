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

  final double? width;

  /// Gap between the component edge and the ring.
  final double? offset;

  /// Ring color. Choose one with at least 3:1 contrast against its surface.
  final Color? color;

  AnimalFocusRingStyle({this.width, this.offset, this.color}) {
    AnimalStyleValues.checkDimension('width', width, minimum: minimumWidth);
    AnimalStyleValues.checkDimension('offset', offset);
  }

  AnimalFocusRingStyle copyWith({
    double? width,
    double? offset,
    Color? color,
  }) => AnimalFocusRingStyle(
    width: width ?? this.width,
    offset: offset ?? this.offset,
    color: color ?? this.color,
  );

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
