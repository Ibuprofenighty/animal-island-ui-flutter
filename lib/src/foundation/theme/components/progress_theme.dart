import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalProgress`.
///
/// The same type customizes one progress indicator through its `style` parameter and
/// every one through `AnimalIslandTheme.components`. Each field is optional;
/// a null field falls through to the next layer and finally to a default
/// derived from the active theme tokens.
@immutable
class AnimalProgressStyle {
  /// Fill of the completed part. When null the fill follows the status:
  /// primary, success or error.
  final Color? color;

  /// Fill of the remaining track.
  final Color? trackColor;

  /// Border color of the linear track.
  final Color? trackBorderColor;

  /// Width of the linear track border.
  final double? trackBorderWidth;

  /// Height of the linear bar.
  final double? height;

  /// Stroke width of the circular ring.
  final double? strokeWidth;

  /// Color of the diagonal stripes painted over a striped fill.
  final Color? stripeColor;

  /// Style of the percentage label beside, above or inside a ring. Its
  /// color is resolved from [labelTextColor].
  final TextStyle? labelTextStyle;

  /// Color of the percentage label beside, above or inside a ring.
  final Color? labelTextColor;

  /// Style of the percentage label drawn inside the linear fill. Its color
  /// is resolved from [insideLabelTextColor].
  final TextStyle? insideLabelTextStyle;

  /// Color of the percentage label drawn inside the linear fill.
  final Color? insideLabelTextColor;

  /// Space between the linear bar and a label beside or above it.
  final double? labelGap;

  /// Creates a progress style.
  ///
  /// Throws an [ArgumentError] if a given dimension is negative or not finite,
  /// or a given text style has a font size that is not finite and positive.
  AnimalProgressStyle({
    this.color,
    this.trackColor,
    this.trackBorderColor,
    this.trackBorderWidth,
    this.height,
    this.strokeWidth,
    this.stripeColor,
    this.labelTextStyle,
    this.labelTextColor,
    this.insideLabelTextStyle,
    this.insideLabelTextColor,
    this.labelGap,
  }) {
    AnimalStyleValues.checkDimension('trackBorderWidth', trackBorderWidth);
    AnimalStyleValues.checkDimension('height', height);
    AnimalStyleValues.checkDimension('strokeWidth', strokeWidth);
    AnimalStyleValues.checkTextStyle('labelTextStyle', labelTextStyle);
    AnimalStyleValues.checkTextStyle(
      'insideLabelTextStyle',
      insideLabelTextStyle,
    );
    AnimalStyleValues.checkDimension('labelGap', labelGap);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalProgressStyle copyWith({
    Color? color,
    Color? trackColor,
    Color? trackBorderColor,
    double? trackBorderWidth,
    double? height,
    double? strokeWidth,
    Color? stripeColor,
    TextStyle? labelTextStyle,
    Color? labelTextColor,
    TextStyle? insideLabelTextStyle,
    Color? insideLabelTextColor,
    double? labelGap,
  }) => AnimalProgressStyle(
    color: color ?? this.color,
    trackColor: trackColor ?? this.trackColor,
    trackBorderColor: trackBorderColor ?? this.trackBorderColor,
    trackBorderWidth: trackBorderWidth ?? this.trackBorderWidth,
    height: height ?? this.height,
    strokeWidth: strokeWidth ?? this.strokeWidth,
    stripeColor: stripeColor ?? this.stripeColor,
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    labelTextColor: labelTextColor ?? this.labelTextColor,
    insideLabelTextStyle: insideLabelTextStyle ?? this.insideLabelTextStyle,
    insideLabelTextColor: insideLabelTextColor ?? this.insideLabelTextColor,
    labelGap: labelGap ?? this.labelGap,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalProgressStyle merge(AnimalProgressStyle? other) {
    if (other == null) return this;
    return AnimalProgressStyle(
      color: color ?? other.color,
      trackColor: trackColor ?? other.trackColor,
      trackBorderColor: trackBorderColor ?? other.trackBorderColor,
      trackBorderWidth: trackBorderWidth ?? other.trackBorderWidth,
      height: height ?? other.height,
      strokeWidth: strokeWidth ?? other.strokeWidth,
      stripeColor: stripeColor ?? other.stripeColor,
      labelTextStyle:
          other.labelTextStyle?.merge(labelTextStyle) ?? labelTextStyle,
      labelTextColor: labelTextColor ?? other.labelTextColor,
      insideLabelTextStyle:
          other.insideLabelTextStyle?.merge(insideLabelTextStyle) ??
          insideLabelTextStyle,
      insideLabelTextColor: insideLabelTextColor ?? other.insideLabelTextColor,
      labelGap: labelGap ?? other.labelGap,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalProgressStyle? lerp(
    AnimalProgressStyle? a,
    AnimalProgressStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalProgressStyle(
      color: AnimalStyleValues.lerpColor(a?.color, b?.color, t),
      trackColor: AnimalStyleValues.lerpColor(a?.trackColor, b?.trackColor, t),
      trackBorderColor: AnimalStyleValues.lerpColor(
        a?.trackBorderColor,
        b?.trackBorderColor,
        t,
      ),
      trackBorderWidth: AnimalStyleValues.lerpDimension(
        a?.trackBorderWidth,
        b?.trackBorderWidth,
        t,
      ),
      height: AnimalStyleValues.lerpDimension(a?.height, b?.height, t),
      strokeWidth: AnimalStyleValues.lerpDimension(
        a?.strokeWidth,
        b?.strokeWidth,
        t,
      ),
      stripeColor: AnimalStyleValues.lerpColor(
        a?.stripeColor,
        b?.stripeColor,
        t,
      ),
      labelTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
      ),
      labelTextColor: AnimalStyleValues.lerpColor(
        a?.labelTextColor,
        b?.labelTextColor,
        t,
      ),
      insideLabelTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.insideLabelTextStyle,
        b?.insideLabelTextStyle,
        t,
      ),
      insideLabelTextColor: AnimalStyleValues.lerpColor(
        a?.insideLabelTextColor,
        b?.insideLabelTextColor,
        t,
      ),
      labelGap: AnimalStyleValues.lerpDimension(a?.labelGap, b?.labelGap, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalProgressStyle &&
          other.color == color &&
          other.trackColor == trackColor &&
          other.trackBorderColor == trackBorderColor &&
          other.trackBorderWidth == trackBorderWidth &&
          other.height == height &&
          other.strokeWidth == strokeWidth &&
          other.stripeColor == stripeColor &&
          other.labelTextStyle == labelTextStyle &&
          other.labelTextColor == labelTextColor &&
          other.insideLabelTextStyle == insideLabelTextStyle &&
          other.insideLabelTextColor == insideLabelTextColor &&
          other.labelGap == labelGap;

  @override
  int get hashCode => Object.hash(
    color,
    trackColor,
    trackBorderColor,
    trackBorderWidth,
    height,
    strokeWidth,
    stripeColor,
    labelTextStyle,
    labelTextColor,
    insideLabelTextStyle,
    insideLabelTextColor,
    labelGap,
  );
}

/// Theme-wide AnimalProgress overrides.
///
/// [style] applies to every size; a size-specific style takes precedence over
/// it. A component's own `style` parameter takes precedence over both.
@immutable
class AnimalProgressThemeData {
  /// Style applied to every size.
  final AnimalProgressStyle? style;

  /// Style for the small size; wins over [style].
  final AnimalProgressStyle? smallStyle;

  /// Style for the middle size; wins over [style].
  final AnimalProgressStyle? middleStyle;

  /// Style for the large size; wins over [style].
  final AnimalProgressStyle? largeStyle;

  /// Creates theme-wide overrides; every style defaults to null.
  const AnimalProgressThemeData({
    this.style,
    this.smallStyle,
    this.middleStyle,
    this.largeStyle,
  });

  /// Returns a copy of this theme data with the given fields replaced.
  AnimalProgressThemeData copyWith({
    AnimalProgressStyle? style,
    AnimalProgressStyle? smallStyle,
    AnimalProgressStyle? middleStyle,
    AnimalProgressStyle? largeStyle,
  }) => AnimalProgressThemeData(
    style: style ?? this.style,
    smallStyle: smallStyle ?? this.smallStyle,
    middleStyle: middleStyle ?? this.middleStyle,
    largeStyle: largeStyle ?? this.largeStyle,
  );

  /// Linearly interpolates between two theme data values, style by style.
  static AnimalProgressThemeData? lerp(
    AnimalProgressThemeData? a,
    AnimalProgressThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalProgressThemeData(
      style: AnimalProgressStyle.lerp(a?.style, b?.style, t),
      smallStyle: AnimalProgressStyle.lerp(a?.smallStyle, b?.smallStyle, t),
      middleStyle: AnimalProgressStyle.lerp(a?.middleStyle, b?.middleStyle, t),
      largeStyle: AnimalProgressStyle.lerp(a?.largeStyle, b?.largeStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalProgressThemeData &&
          style == other.style &&
          smallStyle == other.smallStyle &&
          middleStyle == other.middleStyle &&
          largeStyle == other.largeStyle;

  @override
  int get hashCode => Object.hash(style, smallStyle, middleStyle, largeStyle);
}
