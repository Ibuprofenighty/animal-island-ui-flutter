import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalLoading`.
///
/// The same type customizes one loading indicator through its `style`
/// parameter (or `AnimalLoading.show(style: ...)`) and every indicator through
/// `AnimalIslandTheme.components.loading`. Each field is optional; a null
/// field falls through to the next layer and finally to a default derived
/// from the active theme tokens. The widget's own `color` and `barrierColor`
/// parameters win over the matching style fields.
@immutable
class AnimalLoadingStyle {
  /// Color of the spinner, snowflake or dots indicator.
  final Color? color;

  /// Space between the indicator and its tip.
  final double? tipGap;

  /// Padding inside the tip surface.
  final EdgeInsetsGeometry? tipPadding;

  /// Style of the tip text. Its color is resolved from [tipTextColor].
  final TextStyle? tipTextStyle;

  /// Color of the tip text.
  final Color? tipTextColor;

  /// Fill of the tip pill.
  final Color? tipBackgroundColor;

  /// Border of the tip pill.
  final Color? tipBorderColor;

  /// Width of the tip pill border.
  final double? tipBorderWidth;

  /// Corner radius of the tip pill.
  final BorderRadius? tipBorderRadius;

  /// Shadow under the tip pill.
  final BoxShadow? tipShadow;

  /// Color of the full-screen barrier behind the indicator.
  final Color? barrierColor;

  /// Color of the falling particles of a full-screen snowflake loading; its
  /// alpha scales each particle's own opacity.
  final Color? snowflakeColor;

  /// Creates a loading indicator style.
  ///
  /// Throws an [ArgumentError] if a given dimension, inset or corner radius is
  /// negative or not finite, or a given text style has a font size that is not
  /// finite and positive.
  AnimalLoadingStyle({
    this.color,
    this.tipGap,
    this.tipPadding,
    this.tipTextStyle,
    this.tipTextColor,
    this.tipBackgroundColor,
    this.tipBorderColor,
    this.tipBorderWidth,
    this.tipBorderRadius,
    this.tipShadow,
    this.barrierColor,
    this.snowflakeColor,
  }) {
    AnimalStyleValues.checkDimension('tipGap', tipGap);
    AnimalStyleValues.checkDimension('tipBorderWidth', tipBorderWidth);
    AnimalStyleValues.checkTextStyle('tipTextStyle', tipTextStyle);
    AnimalStyleValues.checkInsets('tipPadding', tipPadding);
    AnimalStyleValues.checkRadius('tipBorderRadius', tipBorderRadius);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalLoadingStyle copyWith({
    Color? color,
    double? tipGap,
    EdgeInsetsGeometry? tipPadding,
    TextStyle? tipTextStyle,
    Color? tipTextColor,
    Color? tipBackgroundColor,
    Color? tipBorderColor,
    double? tipBorderWidth,
    BorderRadius? tipBorderRadius,
    BoxShadow? tipShadow,
    Color? barrierColor,
    Color? snowflakeColor,
  }) => AnimalLoadingStyle(
    color: color ?? this.color,
    tipGap: tipGap ?? this.tipGap,
    tipPadding: tipPadding ?? this.tipPadding,
    tipTextStyle: tipTextStyle ?? this.tipTextStyle,
    tipTextColor: tipTextColor ?? this.tipTextColor,
    tipBackgroundColor: tipBackgroundColor ?? this.tipBackgroundColor,
    tipBorderColor: tipBorderColor ?? this.tipBorderColor,
    tipBorderWidth: tipBorderWidth ?? this.tipBorderWidth,
    tipBorderRadius: tipBorderRadius ?? this.tipBorderRadius,
    tipShadow: tipShadow ?? this.tipShadow,
    barrierColor: barrierColor ?? this.barrierColor,
    snowflakeColor: snowflakeColor ?? this.snowflakeColor,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// The tip text style merges field by field, so an override can change only
  /// the font size and keep the rest of the lower layer's style.
  AnimalLoadingStyle merge(AnimalLoadingStyle? other) {
    if (other == null) return this;
    return AnimalLoadingStyle(
      color: color ?? other.color,
      tipGap: tipGap ?? other.tipGap,
      tipPadding: tipPadding ?? other.tipPadding,
      tipTextStyle: other.tipTextStyle?.merge(tipTextStyle) ?? tipTextStyle,
      tipTextColor: tipTextColor ?? other.tipTextColor,
      tipBackgroundColor: tipBackgroundColor ?? other.tipBackgroundColor,
      tipBorderColor: tipBorderColor ?? other.tipBorderColor,
      tipBorderWidth: tipBorderWidth ?? other.tipBorderWidth,
      tipBorderRadius: tipBorderRadius ?? other.tipBorderRadius,
      tipShadow: tipShadow ?? other.tipShadow,
      barrierColor: barrierColor ?? other.barrierColor,
      snowflakeColor: snowflakeColor ?? other.snowflakeColor,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalLoadingStyle? lerp(
    AnimalLoadingStyle? a,
    AnimalLoadingStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalLoadingStyle(
      color: AnimalStyleValues.lerpColor(a?.color, b?.color, t),
      tipGap: AnimalStyleValues.lerpDimension(a?.tipGap, b?.tipGap, t),
      tipPadding: AnimalStyleValues.lerpInsets(a?.tipPadding, b?.tipPadding, t),
      tipTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.tipTextStyle,
        b?.tipTextStyle,
        t,
      ),
      tipTextColor: AnimalStyleValues.lerpColor(
        a?.tipTextColor,
        b?.tipTextColor,
        t,
      ),
      tipBackgroundColor: AnimalStyleValues.lerpColor(
        a?.tipBackgroundColor,
        b?.tipBackgroundColor,
        t,
      ),
      tipBorderColor: AnimalStyleValues.lerpColor(
        a?.tipBorderColor,
        b?.tipBorderColor,
        t,
      ),
      tipBorderWidth: AnimalStyleValues.lerpDimension(
        a?.tipBorderWidth,
        b?.tipBorderWidth,
        t,
      ),
      tipBorderRadius: AnimalStyleValues.lerpRadius(
        a?.tipBorderRadius,
        b?.tipBorderRadius,
        t,
      ),
      tipShadow: AnimalStyleValues.lerpShadow(a?.tipShadow, b?.tipShadow, t),
      barrierColor: AnimalStyleValues.lerpColor(
        a?.barrierColor,
        b?.barrierColor,
        t,
      ),
      snowflakeColor: AnimalStyleValues.lerpColor(
        a?.snowflakeColor,
        b?.snowflakeColor,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalLoadingStyle &&
          other.color == color &&
          other.tipGap == tipGap &&
          other.tipPadding == tipPadding &&
          other.tipTextStyle == tipTextStyle &&
          other.tipTextColor == tipTextColor &&
          other.tipBackgroundColor == tipBackgroundColor &&
          other.tipBorderColor == tipBorderColor &&
          other.tipBorderWidth == tipBorderWidth &&
          other.tipBorderRadius == tipBorderRadius &&
          other.tipShadow == tipShadow &&
          other.barrierColor == barrierColor &&
          other.snowflakeColor == snowflakeColor;

  @override
  int get hashCode => Object.hash(
    color,
    tipGap,
    tipPadding,
    tipTextStyle,
    tipTextColor,
    tipBackgroundColor,
    tipBorderColor,
    tipBorderWidth,
    tipBorderRadius,
    tipShadow,
    barrierColor,
    snowflakeColor,
  );
}
