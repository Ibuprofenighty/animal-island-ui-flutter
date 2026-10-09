import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalTime`.
///
/// The same type customizes one time card through its `style` parameter and
/// every one through `AnimalIslandTheme.components`. Each field is optional;
/// a null field falls through to the next layer and finally to a default
/// derived from the active theme tokens.
@immutable
class AnimalTimeStyle {
  /// Padding inside the card.
  final EdgeInsetsGeometry? padding;

  /// Fill of the card.
  final Color? backgroundColor;

  /// Border color of the card.
  final Color? borderColor;

  /// Width of the card border.
  final double? borderWidth;

  /// Corner radius of the card.
  final BorderRadius? borderRadius;

  /// Style of the time text. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  /// Color of the time text.
  final Color? textColor;

  /// Color of the clock icon.
  final Color? iconColor;

  /// Size of the clock icon.
  final double? iconSize;

  /// Space between the clock icon and the time text.
  final double? iconGap;

  /// Creates a time card style.
  ///
  /// Throws an [ArgumentError] if a given dimension, inset or corner radius is
  /// negative or not finite, or a given text style has a font size that is not
  /// finite and positive.
  AnimalTimeStyle({
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.textStyle,
    this.textColor,
    this.iconColor,
    this.iconSize,
    this.iconGap,
  }) {
    AnimalStyleValues.checkInsets('padding', padding);
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkDimension('iconGap', iconGap);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalTimeStyle copyWith({
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
    Color? textColor,
    Color? iconColor,
    double? iconSize,
    double? iconGap,
  }) => AnimalTimeStyle(
    padding: padding ?? this.padding,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    textStyle: textStyle ?? this.textStyle,
    textColor: textColor ?? this.textColor,
    iconColor: iconColor ?? this.iconColor,
    iconSize: iconSize ?? this.iconSize,
    iconGap: iconGap ?? this.iconGap,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalTimeStyle merge(AnimalTimeStyle? other) {
    if (other == null) return this;
    return AnimalTimeStyle(
      padding: padding ?? other.padding,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      textColor: textColor ?? other.textColor,
      iconColor: iconColor ?? other.iconColor,
      iconSize: iconSize ?? other.iconSize,
      iconGap: iconGap ?? other.iconGap,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalTimeStyle? lerp(
    AnimalTimeStyle? a,
    AnimalTimeStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalTimeStyle(
      padding: AnimalStyleValues.lerpInsets(a?.padding, b?.padding, t),
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
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      textColor: AnimalStyleValues.lerpColor(a?.textColor, b?.textColor, t),
      iconColor: AnimalStyleValues.lerpColor(a?.iconColor, b?.iconColor, t),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      iconGap: AnimalStyleValues.lerpDimension(a?.iconGap, b?.iconGap, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTimeStyle &&
          other.padding == padding &&
          other.backgroundColor == backgroundColor &&
          other.borderColor == borderColor &&
          other.borderWidth == borderWidth &&
          other.borderRadius == borderRadius &&
          other.textStyle == textStyle &&
          other.textColor == textColor &&
          other.iconColor == iconColor &&
          other.iconSize == iconSize &&
          other.iconGap == iconGap;

  @override
  int get hashCode => Object.hash(
    padding,
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    textStyle,
    textColor,
    iconColor,
    iconSize,
    iconGap,
  );
}
