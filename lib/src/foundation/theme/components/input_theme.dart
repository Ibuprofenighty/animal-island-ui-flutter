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

  /// Gap between the editable text and a prefix, suffix or clear action.
  final double? adornmentGap;

  /// Vertical padding inside a multiline field.
  final double? multilineVerticalPadding;

  /// Padding around the clear icon inside its 48 logical-pixel target.
  final EdgeInsetsGeometry? clearButtonPadding;

  /// Corner radius of the clear control's hover fill and focus ring.
  final BorderRadius? clearButtonBorderRadius;

  /// Fill behind the clear icon; resolves against WidgetState.hovered.
  final WidgetStateProperty<Color?>? clearButtonBackgroundColor;

  /// Style of the edited text. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  /// Style of the placeholder. Its color is resolved from [placeholderTextColor].
  final TextStyle? placeholderTextStyle;

  /// Field fill, resolved against [WidgetState.disabled], [WidgetState.focused]
  /// and [WidgetState.error].
  final WidgetStateProperty<Color?>? backgroundColor;

  /// Field border, resolved against the same states as [backgroundColor]; the
  /// warning status uses [warningColor] instead.
  final WidgetStateProperty<Color?>? borderColor;

  /// Color of the glow around a focused or invalid trigger, resolved against
  /// [WidgetState.focused] and [WidgetState.error].
  final WidgetStateProperty<Color?>? glowColor;

  /// Color of the edited text, resolved against the field states.
  final WidgetStateProperty<Color?>? textColor;

  /// Color of the placeholder, resolved against the field states.
  final WidgetStateProperty<Color?>? placeholderTextColor;

  /// Border and glow color for the warning status.
  final Color? warningColor;

  /// Color of the text cursor.
  final Color? cursorColor;

  /// Color of the clear icon.
  final Color? clearIconColor;

  /// Size of the clear icon.
  final double? clearIconSize;

  /// Width of the field border.
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
    this.adornmentGap,
    this.multilineVerticalPadding,
    this.clearButtonPadding,
    this.clearButtonBorderRadius,
    this.clearButtonBackgroundColor,
    this.textStyle,
    this.placeholderTextStyle,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.textColor,
    this.placeholderTextColor,
    this.warningColor,
    this.cursorColor,
    this.clearIconColor,
    this.clearIconSize,
    this.borderWidth,
    this.borderRadius,
    this.multilineBorderRadius,
    this.depthShadow,
  }) {
    AnimalStyleValues.checkDimension('minHeight', minHeight);
    AnimalStyleValues.checkDimension('horizontalPadding', horizontalPadding);
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
    AnimalStyleValues.checkDimension('clearIconSize', clearIconSize);
  }

  AnimalInputStyle copyWith({
    double? minHeight,
    double? horizontalPadding,
    double? adornmentGap,
    double? multilineVerticalPadding,
    EdgeInsetsGeometry? clearButtonPadding,
    BorderRadius? clearButtonBorderRadius,
    WidgetStateProperty<Color?>? clearButtonBackgroundColor,
    TextStyle? textStyle,
    TextStyle? placeholderTextStyle,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? glowColor,
    WidgetStateProperty<Color?>? textColor,
    WidgetStateProperty<Color?>? placeholderTextColor,
    Color? warningColor,
    Color? cursorColor,
    Color? clearIconColor,
    double? clearIconSize,
    double? borderWidth,
    BorderRadius? borderRadius,
    BorderRadius? multilineBorderRadius,
    BoxShadow? depthShadow,
  }) => AnimalInputStyle(
    minHeight: minHeight ?? this.minHeight,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    adornmentGap: adornmentGap ?? this.adornmentGap,
    multilineVerticalPadding:
        multilineVerticalPadding ?? this.multilineVerticalPadding,
    clearButtonPadding: clearButtonPadding ?? this.clearButtonPadding,
    clearButtonBorderRadius:
        clearButtonBorderRadius ?? this.clearButtonBorderRadius,
    clearButtonBackgroundColor:
        clearButtonBackgroundColor ?? this.clearButtonBackgroundColor,
    textStyle: textStyle ?? this.textStyle,
    placeholderTextStyle: placeholderTextStyle ?? this.placeholderTextStyle,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    glowColor: glowColor ?? this.glowColor,
    textColor: textColor ?? this.textColor,
    placeholderTextColor: placeholderTextColor ?? this.placeholderTextColor,
    warningColor: warningColor ?? this.warningColor,
    cursorColor: cursorColor ?? this.cursorColor,
    clearIconColor: clearIconColor ?? this.clearIconColor,
    clearIconSize: clearIconSize ?? this.clearIconSize,
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
      adornmentGap: adornmentGap ?? other.adornmentGap,
      multilineVerticalPadding:
          multilineVerticalPadding ?? other.multilineVerticalPadding,
      clearButtonPadding: clearButtonPadding ?? other.clearButtonPadding,
      clearButtonBorderRadius:
          clearButtonBorderRadius ?? other.clearButtonBorderRadius,
      clearButtonBackgroundColor:
          clearButtonBackgroundColor ?? other.clearButtonBackgroundColor,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      placeholderTextStyle:
          other.placeholderTextStyle?.merge(placeholderTextStyle) ??
          placeholderTextStyle,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      glowColor: glowColor ?? other.glowColor,
      textColor: textColor ?? other.textColor,
      placeholderTextColor: placeholderTextColor ?? other.placeholderTextColor,
      warningColor: warningColor ?? other.warningColor,
      cursorColor: cursorColor ?? other.cursorColor,
      clearIconColor: clearIconColor ?? other.clearIconColor,
      clearIconSize: clearIconSize ?? other.clearIconSize,
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
      clearButtonBorderRadius: AnimalStyleValues.lerpRadius(
        a?.clearButtonBorderRadius,
        b?.clearButtonBorderRadius,
        t,
      ),
      clearButtonBackgroundColor: AnimalStyleValues.lerpColors(
        a?.clearButtonBackgroundColor,
        b?.clearButtonBackgroundColor,
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
      glowColor: AnimalStyleValues.lerpColors(a?.glowColor, b?.glowColor, t),
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
      clearIconSize: AnimalStyleValues.lerpDimension(
        a?.clearIconSize,
        b?.clearIconSize,
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
          adornmentGap == other.adornmentGap &&
          multilineVerticalPadding == other.multilineVerticalPadding &&
          clearButtonPadding == other.clearButtonPadding &&
          clearButtonBorderRadius == other.clearButtonBorderRadius &&
          clearButtonBackgroundColor == other.clearButtonBackgroundColor &&
          textStyle == other.textStyle &&
          placeholderTextStyle == other.placeholderTextStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          glowColor == other.glowColor &&
          textColor == other.textColor &&
          placeholderTextColor == other.placeholderTextColor &&
          warningColor == other.warningColor &&
          cursorColor == other.cursorColor &&
          clearIconColor == other.clearIconColor &&
          clearIconSize == other.clearIconSize &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          multilineBorderRadius == other.multilineBorderRadius &&
          depthShadow == other.depthShadow;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    minHeight,
    horizontalPadding,
    adornmentGap,
    multilineVerticalPadding,
    clearButtonPadding,
    clearButtonBorderRadius,
    clearButtonBackgroundColor,
    textStyle,
    placeholderTextStyle,
    backgroundColor,
    borderColor,
    glowColor,
    textColor,
    placeholderTextColor,
    warningColor,
    cursorColor,
    clearIconColor,
    clearIconSize,
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
  /// Style applied to inputs of every size.
  final AnimalInputStyle? style;

  /// Style for small inputs; wins over [style].
  final AnimalInputStyle? smallStyle;

  /// Style for middle inputs; wins over [style].
  final AnimalInputStyle? middleStyle;

  /// Style for large inputs; wins over [style].
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
