import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import '../motion.dart' show lerpAnimalDuration;

/// Shared validation and interpolation for component style values.
///
/// Component styles are value objects: every field is optional, and a field
/// that is present must be renderable. These helpers keep that rule in one
/// place instead of repeating it in every style class.
///
/// Interpolation stays between its endpoints: every lerp clamps `t` to
/// 0..1, so an overshooting theme animation curve never produces a value the
/// style constructors reject.
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

  /// Rejects present insets with a negative or non-finite side.
  static void checkInsets(String name, EdgeInsetsGeometry? insets) {
    if (insets == null) return;
    final EdgeInsets probe = insets.resolve(TextDirection.ltr);
    final bool finite = <double>[
      probe.left,
      probe.top,
      probe.right,
      probe.bottom,
    ].every((double side) => side.isFinite);
    if (!finite || !insets.isNonNegative) {
      throw ArgumentError.value(
        insets,
        name,
        'every side must be finite and non-negative',
      );
    }
  }

  /// Rejects a present border radius with a negative or non-finite corner.
  static void checkRadius(String name, BorderRadius? radius) {
    if (radius == null) return;
    final bool valid = <Radius>[
      radius.topLeft,
      radius.topRight,
      radius.bottomLeft,
      radius.bottomRight,
    ].every((Radius r) => r.x.isFinite && r.y.isFinite && r.x >= 0 && r.y >= 0);
    if (!valid) {
      throw ArgumentError.value(
        radius,
        name,
        'every corner must be finite and non-negative',
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

  /// Interpolates two optional dimensions; snaps when either is null.
  static double? lerpDimension(double? a, double? b, double t) =>
      a == null || b == null ? snap(a, b, t) : lerpDouble(a, b, _unit(t));

  /// Interpolates two optional text styles; snaps when either is null.
  static TextStyle? lerpTextStyle(TextStyle? a, TextStyle? b, double t) =>
      a == null || b == null ? snap(a, b, t) : TextStyle.lerp(a, b, _unit(t));

  /// Interpolates two optional colors; snaps when either is null.
  static Color? lerpColor(Color? a, Color? b, double t) =>
      a == null || b == null ? snap(a, b, t) : Color.lerp(a, b, _unit(t));

  /// Interpolates two optional state-dependent colors; snaps when either is
  /// null.
  static WidgetStateProperty<Color?>? lerpColors(
    WidgetStateProperty<Color?>? a,
    WidgetStateProperty<Color?>? b,
    double t,
  ) => a == null || b == null
      ? snap(a, b, t)
      : WidgetStateProperty.lerp<Color?>(a, b, _unit(t), lerpColor);

  /// Interpolates two optional border radii; snaps when either is null.
  static BorderRadius? lerpRadius(BorderRadius? a, BorderRadius? b, double t) =>
      a == null || b == null
      ? snap(a, b, t)
      : BorderRadius.lerp(a, b, _unit(t));

  /// Interpolates two optional insets; snaps when either is null.
  static EdgeInsetsGeometry? lerpInsets(
    EdgeInsetsGeometry? a,
    EdgeInsetsGeometry? b,
    double t,
  ) => a == null || b == null
      ? snap(a, b, t)
      : EdgeInsetsGeometry.lerp(a, b, _unit(t));

  /// Interpolates two optional shadows; snaps when either is null.
  static BoxShadow? lerpShadow(BoxShadow? a, BoxShadow? b, double t) =>
      a == null || b == null ? snap(a, b, t) : BoxShadow.lerp(a, b, _unit(t));

  /// Interpolates two optional durations; snaps when either is null.
  static Duration? lerpDuration(Duration? a, Duration? b, double t) =>
      a == null || b == null
      ? snap(a, b, t)
      : lerpAnimalDuration(a, b, _unit(t));

  /// Interpolates by snapping, for values without a meaningful midpoint.
  static T? snap<T>(T? a, T? b, double t) => t < 0.5 ? a : b;

  static double _unit(double t) => t.clamp(0.0, 1.0);
}
