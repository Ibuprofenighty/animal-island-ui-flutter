import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalInput`.
///
/// The same type customizes one input through its `style` parameter and every
/// input through [AnimalInputThemeData]. Each field is optional; a null field
/// falls through to the next layer and finally to a default derived from the
/// active theme tokens.
///
/// Color properties resolve against [WidgetState.disabled],
/// [WidgetState.focused] and [WidgetState.error]. The warning status has no
/// Flutter widget state, so it uses [warningColor].
@immutable
class AnimalInputStyle {
  /// Minimum height of a single-line field; content may grow beyond it.
  final double? minHeight;

  /// Horizontal padding inside the field border.
  final double? horizontalPadding;

  /// Size of the clear icon.
  final double? iconSize;

  /// Gap between the editable text and a prefix, suffix or clear action.
  final double? adornmentGap;

  /// Vertical padding inside a multiline field.
  final double? multilineVerticalPadding;

  /// Padding around the clear icon inside its 48 logical-pixel target.
  final EdgeInsetsGeometry? clearButtonPadding;

  /// Style of the edited text. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  /// Style of the placeholder. Its color is resolved from [placeholderTextColor].
  final TextStyle? placeholderTextStyle;

  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? borderColor;
  final WidgetStateProperty<Color?>? textColor;
  final WidgetStateProperty<Color?>? placeholderTextColor;

  /// Border and glow color for the warning status.
  final Color? warningColor;

  final Color? cursorColor;
  final Color? clearIconColor;
  final double? borderWidth;

  /// Corner radius of a single-line field.
  final BorderRadius? borderRadius;

  /// Corner radius of a multiline field.
  final BorderRadius? multilineBorderRadius;

  /// Depth shadow drawn when the input's `shadow` flag is set.
  final BoxShadow? depthShadow;

  AnimalInputStyle({
    this.minHeight,
    this.horizontalPadding,
    this.iconSize,
    this.adornmentGap,
    this.multilineVerticalPadding,
    this.clearButtonPadding,
    this.textStyle,
    this.placeholderTextStyle,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.placeholderTextColor,
    this.warningColor,
    this.cursorColor,
    this.clearIconColor,
    this.borderWidth,
    this.borderRadius,
    this.multilineBorderRadius,
    this.depthShadow,
  }) {
    AnimalStyleValues.checkDimension('minHeight', minHeight);
    AnimalStyleValues.checkDimension('horizontalPadding', horizontalPadding);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkDimension('adornmentGap', adornmentGap);
    AnimalStyleValues.checkDimension(
      'multilineVerticalPadding',
      multilineVerticalPadding,
    );
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkTextStyle(
      'placeholderTextStyle',
      placeholderTextStyle,
    );
  }

  AnimalInputStyle copyWith({
    double? minHeight,
    double? horizontalPadding,
    double? iconSize,
    double? adornmentGap,
    double? multilineVerticalPadding,
    EdgeInsetsGeometry? clearButtonPadding,
    TextStyle? textStyle,
    TextStyle? placeholderTextStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? textColor,
    WidgetStateProperty<Color?>? placeholderTextColor,
    Color? warningColor,
    Color? cursorColor,
    Color? clearIconColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BorderRadius? multilineBorderRadius,
    BoxShadow? depthShadow,
  }) => AnimalInputStyle(
    minHeight: minHeight ?? this.minHeight,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    iconSize: iconSize ?? this.iconSize,
    adornmentGap: adornmentGap ?? this.adornmentGap,
    multilineVerticalPadding:
        multilineVerticalPadding ?? this.multilineVerticalPadding,
    clearButtonPadding: clearButtonPadding ?? this.clearButtonPadding,
    textStyle: textStyle ?? this.textStyle,
    placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    textColor: textColor ?? this.textColor,
    placeholderTextColor: placeholderTextColor ?? this.placeholderTextColor,
    warningColor: warningColor ?? this.warningColor,
    cursorColor: cursorColor ?? this.cursorColor,
    clearIconColor: clearIconColor ?? this.clearIconColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    multilineBorderRadius: multilineBorderRadius ?? this.multilineBorderRadius,
    depthShadow: depthShadow ?? this.depthShadow,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalInputStyle merge(AnimalInputStyle? other) {
    if (other == null) return this;
    return AnimalInputStyle(
      minHeight: minHeight ?? other.minHeight,
      horizontalPadding: horizontalPadding ?? other.horizontalPadding,
      iconSize: iconSize ?? other.iconSize,
      adornmentGap: adornmentGap ?? other.adornmentGap,
      multilineVerticalPadding:
          multilineVerticalPadding ?? other.multilineVerticalPadding,
      clearButtonPadding: clearButtonPadding ?? other.clearButtonPadding,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      placeholderTextStyle:
          other.placeholderTextStyle?.merge(placeholderTextStyle) ??
          placeholderTextStyle,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      textColor: textColor ?? other.textColor,
      placeholderTextColor: placeholderTextColor ?? other.placeholderTextColor,
      warningColor: warningColor ?? other.warningColor,
      cursorColor: cursorColor ?? other.cursorColor,
      clearIconColor: clearIconColor ?? other.clearIconColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      multilineBorderRadius:
          multilineBorderRadius ?? other.multilineBorderRadius,
      depthShadow: depthShadow ?? other.depthShadow,
    );
  }

  static AnimalInputStyle? lerp(
    AnimalInputStyle? a,
    AnimalInputStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalInputStyle(
      minHeight: AnimalStyleValues.lerpDimension(a?.minHeight, b?.minHeight, t),
      horizontalPadding: AnimalStyleValues.lerpDimension(
        a?.horizontalPadding,
        b?.horizontalPadding,
        t,
      ),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      adornmentGap: AnimalStyleValues.lerpDimension(
        a?.adornmentGap,
        b?.adornmentGap,
        t,
      ),
      multilineVerticalPadding: AnimalStyleValues.lerpDimension(
        a?.multilineVerticalPadding,
        b?.multilineVerticalPadding,
        t,
      ),
      clearButtonPadding: AnimalStyleValues.lerpInsets(
        a?.clearButtonPadding,
        b?.clearButtonPadding,
        t,
      ),
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      placeholderTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.placeholderTextStyle,
        b?.placeholderTextStyle,
        t,
      ),
      backgroundColor: AnimalStyleValues.lerpColors(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
      ),
      borderColor: AnimalStyleValues.lerpColors(
        a?.borderColor,
        b?.borderColor,
        t,
      ),
      textColor: AnimalStyleValues.lerpColors(a?.textColor, b?.textColor, t),
      placeholderTextColor: AnimalStyleValues.lerpColors(
        a?.placeholderTextColor,
        b?.placeholderTextColor,
        t,
      ),
      warningColor: AnimalStyleValues.lerpColor(
        a?.warningColor,
        b?.warningColor,
        t,
      ),
      cursorColor: AnimalStyleValues.lerpColor(
        a?.cursorColor,
        b?.cursorColor,
        t,
      ),
      clearIconColor: AnimalStyleValues.lerpColor(
        a?.clearIconColor,
        b?.clearIconColor,
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
      multilineBorderRadius: AnimalStyleValues.lerpRadius(
        a?.multilineBorderRadius,
        b?.multilineBorderRadius,
        t,
      ),
      depthShadow: AnimalStyleValues.lerpShadow(
        a?.depthShadow,
        b?.depthShadow,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalInputStyle &&
          minHeight == other.minHeight &&
          horizontalPadding == other.horizontalPadding &&
          iconSize == other.iconSize &&
          adornmentGap == other.adornmentGap &&
          multilineVerticalPadding == other.multilineVerticalPadding &&
          clearButtonPadding == other.clearButtonPadding &&
          textStyle == other.textStyle &&
          placeholderTextStyle == other.placeholderTextStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          textColor == other.textColor &&
          placeholderTextColor == other.placeholderTextColor &&
          warningColor == other.warningColor &&
          cursorColor == other.cursorColor &&
          clearIconColor == other.clearIconColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          multilineBorderRadius == other.multilineBorderRadius &&
          depthShadow == other.depthShadow;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    minHeight,
    horizontalPadding,
    iconSize,
    adornmentGap,
    multilineVerticalPadding,
    clearButtonPadding,
    textStyle,
    placeholderTextStyle,
    backgroundColor,
    borderColor,
    textColor,
    placeholderTextColor,
    warningColor,
    cursorColor,
    clearIconColor,
    borderWidth,
    borderRadius,
    multilineBorderRadius,
    depthShadow,
  ]);
}

/// Theme-wide input overrides.
///
/// [style] applies to every size; a size-specific style takes precedence over
/// it for inputs of that size. An input's own `style` parameter takes
/// precedence over both.
@immutable
class AnimalInputThemeData {
  final AnimalInputStyle? style;
  final AnimalInputStyle? smallStyle;
  final AnimalInputStyle? middleStyle;
  final AnimalInputStyle? largeStyle;

  const AnimalInputThemeData({
    this.style,
    this.smallStyle,
    this.middleStyle,
    this.largeStyle,
  });

  AnimalInputThemeData copyWith({
    AnimalInputStyle? style,
    AnimalInputStyle? smallStyle,
    AnimalInputStyle? middleStyle,
    AnimalInputStyle? largeStyle,
  }) => AnimalInputThemeData(
    style: style ?? this.style,
    smallStyle: smallStyle ?? this.smallStyle,
    middleStyle: middleStyle ?? this.middleStyle,
    largeStyle: largeStyle ?? this.largeStyle,
  );

  static AnimalInputThemeData? lerp(
    AnimalInputThemeData? a,
    AnimalInputThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalInputThemeData(
      style: AnimalInputStyle.lerp(a?.style, b?.style, t),
      smallStyle: AnimalInputStyle.lerp(a?.smallStyle, b?.smallStyle, t),
      middleStyle: AnimalInputStyle.lerp(a?.middleStyle, b?.middleStyle, t),
      largeStyle: AnimalInputStyle.lerp(a?.largeStyle, b?.largeStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalInputThemeData &&
          style == other.style &&
          smallStyle == other.smallStyle &&
          middleStyle == other.middleStyle &&
          largeStyle == other.largeStyle;

  @override
  int get hashCode => Object.hash(style, smallStyle, middleStyle, largeStyle);
}
