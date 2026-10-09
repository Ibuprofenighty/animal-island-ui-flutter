import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalCountdown`.
///
/// The same type customizes one countdown through its `style` parameter and
/// every one through `AnimalIslandTheme.components`. Each field is optional;
/// a null field falls through to the next layer and finally to a default
/// derived from the active theme tokens.
@immutable
class AnimalCountdownStyle {
  /// Minimum width of each digit tile; a tile grows to fit its digits.
  final double? width;

  /// Minimum height of each digit tile; a tile grows to fit its digits.
  final double? height;

  /// Fill of each digit tile.
  final Color? backgroundColor;

  /// Border color of a bordered digit tile.
  final Color? borderColor;

  /// Width of the border of a bordered digit tile.
  final double? borderWidth;

  /// Corner radius of each digit tile.
  final BorderRadius? borderRadius;

  /// Shadow under each digit tile.
  final BoxShadow? shadow;

  /// Style of the digits and separators. Its color is resolved from
  /// [digitTextColor].
  final TextStyle? digitTextStyle;

  /// Color of the digits and separators.
  final Color? digitTextColor;

  /// Style of the unit label under each tile. Its color is resolved from
  /// [labelTextColor].
  final TextStyle? labelTextStyle;

  /// Color of the unit label under each tile.
  final Color? labelTextColor;

  /// Space between a tile and its unit label.
  final double? labelGap;

  /// Padding around each separator.
  final EdgeInsetsGeometry? separatorPadding;

  /// Space between the prefix and the first tile.
  final double? prefixGap;

  /// Creates a countdown style.
  ///
  /// Throws an [ArgumentError] if a given dimension, inset or corner radius is
  /// negative or not finite, or a given text style has a font size that is not
  /// finite and positive.
  AnimalCountdownStyle({
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadow,
    this.digitTextStyle,
    this.digitTextColor,
    this.labelTextStyle,
    this.labelTextColor,
    this.labelGap,
    this.separatorPadding,
    this.prefixGap,
  }) {
    AnimalStyleValues.checkDimension('width', width);
    AnimalStyleValues.checkDimension('height', height);
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkTextStyle('digitTextStyle', digitTextStyle);
    AnimalStyleValues.checkTextStyle('labelTextStyle', labelTextStyle);
    AnimalStyleValues.checkDimension('labelGap', labelGap);
    AnimalStyleValues.checkInsets('separatorPadding', separatorPadding);
    AnimalStyleValues.checkDimension('prefixGap', prefixGap);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalCountdownStyle copyWith({
    double? width,
    double? height,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
    TextStyle? digitTextStyle,
    Color? digitTextColor,
    TextStyle? labelTextStyle,
    Color? labelTextColor,
    double? labelGap,
    EdgeInsetsGeometry? separatorPadding,
    double? prefixGap,
  }) => AnimalCountdownStyle(
    width: width ?? this.width,
    height: height ?? this.height,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    shadow: shadow ?? this.shadow,
    digitTextStyle: digitTextStyle ?? this.digitTextStyle,
    digitTextColor: digitTextColor ?? this.digitTextColor,
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    labelTextColor: labelTextColor ?? this.labelTextColor,
    labelGap: labelGap ?? this.labelGap,
    separatorPadding: separatorPadding ?? this.separatorPadding,
    prefixGap: prefixGap ?? this.prefixGap,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalCountdownStyle merge(AnimalCountdownStyle? other) {
    if (other == null) return this;
    return AnimalCountdownStyle(
      width: width ?? other.width,
      height: height ?? other.height,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      shadow: shadow ?? other.shadow,
      digitTextStyle:
          other.digitTextStyle?.merge(digitTextStyle) ?? digitTextStyle,
      digitTextColor: digitTextColor ?? other.digitTextColor,
      labelTextStyle:
          other.labelTextStyle?.merge(labelTextStyle) ?? labelTextStyle,
      labelTextColor: labelTextColor ?? other.labelTextColor,
      labelGap: labelGap ?? other.labelGap,
      separatorPadding: separatorPadding ?? other.separatorPadding,
      prefixGap: prefixGap ?? other.prefixGap,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalCountdownStyle? lerp(
    AnimalCountdownStyle? a,
    AnimalCountdownStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalCountdownStyle(
      width: AnimalStyleValues.lerpDimension(a?.width, b?.width, t),
      height: AnimalStyleValues.lerpDimension(a?.height, b?.height, t),
      backgroundColor: AnimalStyleValues.lerpColor(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
      ),
      borderColor: AnimalStyleValues.lerpColor(
        a?.borderColor,
        b?.borderColor,
        t,
      ),
      borderWidth: AnimalStyleValues.lerpDimension(
        a?.borderWidth,
        b?.borderWidth,
        t,
      ),
      borderRadius: AnimalStyleValues.lerpRadius(
        a?.borderRadius,
        b?.borderRadius,
        t,
      ),
      shadow: AnimalStyleValues.lerpShadow(a?.shadow, b?.shadow, t),
      digitTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.digitTextStyle,
        b?.digitTextStyle,
        t,
      ),
      digitTextColor: AnimalStyleValues.lerpColor(
        a?.digitTextColor,
        b?.digitTextColor,
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
      labelGap: AnimalStyleValues.lerpDimension(a?.labelGap, b?.labelGap, t),
      separatorPadding: AnimalStyleValues.lerpInsets(
        a?.separatorPadding,
        b?.separatorPadding,
        t,
      ),
      prefixGap: AnimalStyleValues.lerpDimension(a?.prefixGap, b?.prefixGap, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalCountdownStyle &&
          other.width == width &&
          other.height == height &&
          other.backgroundColor == backgroundColor &&
          other.borderColor == borderColor &&
          other.borderWidth == borderWidth &&
          other.borderRadius == borderRadius &&
          other.shadow == shadow &&
          other.digitTextStyle == digitTextStyle &&
          other.digitTextColor == digitTextColor &&
          other.labelTextStyle == labelTextStyle &&
          other.labelTextColor == labelTextColor &&
          other.labelGap == labelGap &&
          other.separatorPadding == separatorPadding &&
          other.prefixGap == prefixGap;

  @override
  int get hashCode => Object.hash(
    width,
    height,
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    shadow,
    digitTextStyle,
    digitTextColor,
    labelTextStyle,
    labelTextColor,
    labelGap,
    separatorPadding,
    prefixGap,
  );
}

/// Theme-wide AnimalCountdown overrides.
///
/// [style] applies to every size; a size-specific style takes precedence over
/// it. A component's own `style` parameter takes precedence over both.
@immutable
class AnimalCountdownThemeData {
  /// Style applied to every size.
  final AnimalCountdownStyle? style;

  /// Style for the small size; wins over [style].
  final AnimalCountdownStyle? smallStyle;

  /// Style for the middle size; wins over [style].
  final AnimalCountdownStyle? middleStyle;

  /// Style for the large size; wins over [style].
  final AnimalCountdownStyle? largeStyle;

  /// Creates theme-wide overrides; every style defaults to null.
  const AnimalCountdownThemeData({
    this.style,
    this.smallStyle,
    this.middleStyle,
    this.largeStyle,
  });

  /// Returns a copy of this theme data with the given fields replaced.
  AnimalCountdownThemeData copyWith({
    AnimalCountdownStyle? style,
    AnimalCountdownStyle? smallStyle,
    AnimalCountdownStyle? middleStyle,
    AnimalCountdownStyle? largeStyle,
  }) => AnimalCountdownThemeData(
    style: style ?? this.style,
    smallStyle: smallStyle ?? this.smallStyle,
    middleStyle: middleStyle ?? this.middleStyle,
    largeStyle: largeStyle ?? this.largeStyle,
  );

  /// Linearly interpolates between two theme data values, style by style.
  static AnimalCountdownThemeData? lerp(
    AnimalCountdownThemeData? a,
    AnimalCountdownThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalCountdownThemeData(
      style: AnimalCountdownStyle.lerp(a?.style, b?.style, t),
      smallStyle: AnimalCountdownStyle.lerp(a?.smallStyle, b?.smallStyle, t),
      middleStyle: AnimalCountdownStyle.lerp(a?.middleStyle, b?.middleStyle, t),
      largeStyle: AnimalCountdownStyle.lerp(a?.largeStyle, b?.largeStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalCountdownThemeData &&
          style == other.style &&
          smallStyle == other.smallStyle &&
          middleStyle == other.middleStyle &&
          largeStyle == other.largeStyle;

  @override
  int get hashCode => Object.hash(style, smallStyle, middleStyle, largeStyle);
}
