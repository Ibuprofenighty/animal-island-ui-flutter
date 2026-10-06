import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

/// Shared validation and interpolation for component style values.
///
/// Component styles are value objects: every field is optional, and a field
/// that is present must be renderable. These helpers keep that rule in one
/// place instead of repeating it in every style class.
abstract final class AnimalStyleValues {
  /// Rejects a present dimension that is not finite or is below [minimum].
  static void checkDimension(String name, double? value, {double minimum = 0}) {
    if (value == null) return;
    if (!value.isFinite || value < minimum) {
      throw ArgumentError.value(
        value,
        name,
        'must be finite and at least $minimum',
      );
    }
  }

  /// Rejects a present text style without a finite, positive font size.
  static void checkTextStyle(String name, TextStyle? style) {
    if (style == null) return;
    final size = style.fontSize;
    if (size != null && (!size.isFinite || size <= 0)) {
      throw ArgumentError.value(
        size,
        name,
        'font size must be finite and positive',
      );
    }
  }

  /// Font size of a resolved style.
  ///
  /// A resolved component style starts from a theme typography role, and the
  /// typography constructor requires every role to carry a font size.
  static double fontSizeOf(TextStyle style) {
    final size = style.fontSize;
    if (size == null) {
      throw StateError('A resolved component text style lost its font size.');
    }
    return size;
  }

  // Interpolation of optional style fields.
  //
  // A null field means "use the lower layer", not zero. When only one side
  // sets a field there is no value to blend toward, so these helpers switch
  // at the midpoint instead of interpolating from 0 or transparent; a blend
  // from 0 would also violate validated floors such as the focus ring width.
  // Every style class interpolates through these helpers only.

  static double? lerpDimension(double? a, double? b, double t) =>
      a == null || b == null ? snap(a, b, t) : lerpDouble(a, b, t);

  static TextStyle? lerpTextStyle(TextStyle? a, TextStyle? b, double t) =>
      a == null || b == null ? snap(a, b, t) : TextStyle.lerp(a, b, t);

  static Color? lerpColor(Color? a, Color? b, double t) =>
      a == null || b == null ? snap(a, b, t) : Color.lerp(a, b, t);

  static WidgetStateProperty<Color?>? lerpColors(
    WidgetStateProperty<Color?>? a,
    WidgetStateProperty<Color?>? b,
    double t,
  ) => a == null || b == null
      ? snap(a, b, t)
      : WidgetStateProperty.lerp<Color?>(a, b, t, lerpColor);

  static BorderRadius? lerpRadius(BorderRadius? a, BorderRadius? b, double t) =>
      a == null || b == null ? snap(a, b, t) : BorderRadius.lerp(a, b, t);

  static EdgeInsetsGeometry? lerpInsets(
    EdgeInsetsGeometry? a,
    EdgeInsetsGeometry? b,
    double t,
  ) =>
      a == null || b == null ? snap(a, b, t) : EdgeInsetsGeometry.lerp(a, b, t);

  static BoxShadow? lerpShadow(BoxShadow? a, BoxShadow? b, double t) =>
      a == null || b == null ? snap(a, b, t) : BoxShadow.lerp(a, b, t);

  static Duration? lerpDuration(Duration? a, Duration? b, double t) =>
      a == null || b == null
      ? snap(a, b, t)
      : Duration(
          microseconds:
              (a.inMicroseconds + (b.inMicroseconds - a.inMicroseconds) * t)
                  .round(),
        );

  /// Interpolates by snapping, for values without a meaningful midpoint.
  static T? snap<T>(T? a, T? b, double t) => t < 0.5 ? a : b;
}
