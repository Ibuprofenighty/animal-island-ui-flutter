import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalSelect`.
///
/// The same type customizes one AnimalSelect through its `style` parameter and every
/// AnimalSelect through `AnimalIslandTheme.components`. Each field is optional; a
/// null field falls through to the next layer and finally to a default derived
/// from the active theme tokens.
///
/// Trigger colors resolve against [WidgetState.disabled],
/// [WidgetState.focused] (focused or menu open), [WidgetState.error] (error
/// status or a value that matches no option) and [WidgetState.selected] (the
/// value matches an option). Option colors resolve against
/// [WidgetState.disabled], [WidgetState.selected], [WidgetState.hovered] and
/// [WidgetState.focused].
@immutable
class AnimalSelectStyle {
  /// Style of the trigger label. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  final WidgetStateProperty<Color?>? textColor;
  final WidgetStateProperty<Color?>? backgroundColor;
  final WidgetStateProperty<Color?>? borderColor;

  /// Color of the glow drawn around a focused or invalid trigger.
  final WidgetStateProperty<Color?>? glowColor;

  final double? borderWidth;
  final BorderRadius? borderRadius;

  /// Horizontal padding inside the trigger border.
  final double? horizontalPadding;

  /// Size of the trigger's dropdown arrow.
  final double? arrowIconSize;
  final WidgetStateProperty<Color?>? arrowIconColor;

  /// Size of the clear icon shown when `allowClear` is set.
  final double? clearIconSize;
  final Color? clearIconColor;

  final Color? menuBackgroundColor;
  final Color? menuBorderColor;
  final double? menuBorderWidth;
  final BorderRadius? menuBorderRadius;
  final double? menuElevation;

  /// Vertical padding between the menu border and its first and last rows.
  final double? menuVerticalPadding;

  /// Upper bound of the menu width; the viewport may narrow it further.
  final double? menuMaxWidth;

  /// Upper bound of the menu list height; longer lists scroll.
  final double? menuMaxHeight;

  /// Style of every option label. Its color is resolved from
  /// [optionTextColor].
  final TextStyle? optionTextStyle;

  /// Merged over [optionTextStyle] for the selected option.
  final TextStyle? selectedOptionTextStyle;

  final WidgetStateProperty<Color?>? optionTextColor;
  final WidgetStateProperty<Color?>? optionBackgroundColor;
  final BorderRadius? optionBorderRadius;

  /// Padding inside each option row. The vertical padding also sizes the row.
  final EdgeInsetsGeometry? optionPadding;

  /// Gap between an option's icon and its label.
  final double? optionIconGap;

  /// Gap between the selected option's label and its check icon.
  final double? checkIconGap;
  final double? checkIconSize;
  final Color? checkIconColor;

  AnimalSelectStyle({
    this.textStyle,
    this.textColor,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.borderWidth,
    this.borderRadius,
    this.horizontalPadding,
    this.arrowIconSize,
    this.arrowIconColor,
    this.clearIconSize,
    this.clearIconColor,
    this.menuBackgroundColor,
    this.menuBorderColor,
    this.menuBorderWidth,
    this.menuBorderRadius,
    this.menuElevation,
    this.menuVerticalPadding,
    this.menuMaxWidth,
    this.menuMaxHeight,
    this.optionTextStyle,
    this.selectedOptionTextStyle,
    this.optionTextColor,
    this.optionBackgroundColor,
    this.optionBorderRadius,
    this.optionPadding,
    this.optionIconGap,
    this.checkIconGap,
    this.checkIconSize,
    this.checkIconColor,
  }) {
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkDimension('horizontalPadding', horizontalPadding);
    AnimalStyleValues.checkDimension('arrowIconSize', arrowIconSize);
    AnimalStyleValues.checkDimension('clearIconSize', clearIconSize);
    AnimalStyleValues.checkDimension('menuBorderWidth', menuBorderWidth);
    AnimalStyleValues.checkDimension('menuElevation', menuElevation);
    AnimalStyleValues.checkDimension(
      'menuVerticalPadding',
      menuVerticalPadding,
    );
    AnimalStyleValues.checkDimension('menuMaxWidth', menuMaxWidth);
    AnimalStyleValues.checkDimension('menuMaxHeight', menuMaxHeight);
    AnimalStyleValues.checkTextStyle('optionTextStyle', optionTextStyle);
    AnimalStyleValues.checkTextStyle(
      'selectedOptionTextStyle',
      selectedOptionTextStyle,
    );
    final EdgeInsetsGeometry? padding = optionPadding;
    if (padding != null &&
        (!padding.isNonNegative ||
            !padding.horizontal.isFinite ||
            !padding.vertical.isFinite)) {
      throw ArgumentError.value(
        padding,
        'optionPadding',
        'every side must be finite and at least 0',
      );
    }
    AnimalStyleValues.checkDimension('optionIconGap', optionIconGap);
    AnimalStyleValues.checkDimension('checkIconGap', checkIconGap);
    AnimalStyleValues.checkDimension('checkIconSize', checkIconSize);
  }

  AnimalSelectStyle copyWith({
    TextStyle? textStyle,
    WidgetStateProperty<Color?>? textColor,
    WidgetStateProperty<Color?>? backgroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? glowColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    double? horizontalPadding,
    double? arrowIconSize,
    WidgetStateProperty<Color?>? arrowIconColor,
    double? clearIconSize,
    Color? clearIconColor,
    Color? menuBackgroundColor,
    Color? menuBorderColor,
    double? menuBorderWidth,
    BorderRadius? menuBorderRadius,
    double? menuElevation,
    double? menuVerticalPadding,
    double? menuMaxWidth,
    double? menuMaxHeight,
    TextStyle? optionTextStyle,
    TextStyle? selectedOptionTextStyle,
    WidgetStateProperty<Color?>? optionTextColor,
    WidgetStateProperty<Color?>? optionBackgroundColor,
    BorderRadius? optionBorderRadius,
    EdgeInsetsGeometry? optionPadding,
    double? optionIconGap,
    double? checkIconGap,
    double? checkIconSize,
    Color? checkIconColor,
  }) => AnimalSelectStyle(
    textStyle: textStyle ?? this.textStyle,
    textColor: textColor ?? this.textColor,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    glowColor: glowColor ?? this.glowColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    horizontalPadding: horizontalPadding ?? this.horizontalPadding,
    arrowIconSize: arrowIconSize ?? this.arrowIconSize,
    arrowIconColor: arrowIconColor ?? this.arrowIconColor,
    clearIconSize: clearIconSize ?? this.clearIconSize,
    clearIconColor: clearIconColor ?? this.clearIconColor,
    menuBackgroundColor: menuBackgroundColor ?? this.menuBackgroundColor,
    menuBorderColor: menuBorderColor ?? this.menuBorderColor,
    menuBorderWidth: menuBorderWidth ?? this.menuBorderWidth,
    menuBorderRadius: menuBorderRadius ?? this.menuBorderRadius,
    menuElevation: menuElevation ?? this.menuElevation,
    menuVerticalPadding: menuVerticalPadding ?? this.menuVerticalPadding,
    menuMaxWidth: menuMaxWidth ?? this.menuMaxWidth,
    menuMaxHeight: menuMaxHeight ?? this.menuMaxHeight,
    optionTextStyle: optionTextStyle ?? this.optionTextStyle,
    selectedOptionTextStyle:
        selectedOptionTextStyle ?? this.selectedOptionTextStyle,
    optionTextColor: optionTextColor ?? this.optionTextColor,
    optionBackgroundColor: optionBackgroundColor ?? this.optionBackgroundColor,
    optionBorderRadius: optionBorderRadius ?? this.optionBorderRadius,
    optionPadding: optionPadding ?? this.optionPadding,
    optionIconGap: optionIconGap ?? this.optionIconGap,
    checkIconGap: checkIconGap ?? this.checkIconGap,
    checkIconSize: checkIconSize ?? this.checkIconSize,
    checkIconColor: checkIconColor ?? this.checkIconColor,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalSelectStyle merge(AnimalSelectStyle? other) {
    if (other == null) return this;
    return AnimalSelectStyle(
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      textColor: textColor ?? other.textColor,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      glowColor: glowColor ?? other.glowColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      horizontalPadding: horizontalPadding ?? other.horizontalPadding,
      arrowIconSize: arrowIconSize ?? other.arrowIconSize,
      arrowIconColor: arrowIconColor ?? other.arrowIconColor,
      clearIconSize: clearIconSize ?? other.clearIconSize,
      clearIconColor: clearIconColor ?? other.clearIconColor,
      menuBackgroundColor: menuBackgroundColor ?? other.menuBackgroundColor,
      menuBorderColor: menuBorderColor ?? other.menuBorderColor,
      menuBorderWidth: menuBorderWidth ?? other.menuBorderWidth,
      menuBorderRadius: menuBorderRadius ?? other.menuBorderRadius,
      menuElevation: menuElevation ?? other.menuElevation,
      menuVerticalPadding: menuVerticalPadding ?? other.menuVerticalPadding,
      menuMaxWidth: menuMaxWidth ?? other.menuMaxWidth,
      menuMaxHeight: menuMaxHeight ?? other.menuMaxHeight,
      optionTextStyle:
          other.optionTextStyle?.merge(optionTextStyle) ?? optionTextStyle,
      selectedOptionTextStyle:
          other.selectedOptionTextStyle?.merge(selectedOptionTextStyle) ??
          selectedOptionTextStyle,
      optionTextColor: optionTextColor ?? other.optionTextColor,
      optionBackgroundColor:
          optionBackgroundColor ?? other.optionBackgroundColor,
      optionBorderRadius: optionBorderRadius ?? other.optionBorderRadius,
      optionPadding: optionPadding ?? other.optionPadding,
      optionIconGap: optionIconGap ?? other.optionIconGap,
      checkIconGap: checkIconGap ?? other.checkIconGap,
      checkIconSize: checkIconSize ?? other.checkIconSize,
      checkIconColor: checkIconColor ?? other.checkIconColor,
    );
  }

  static AnimalSelectStyle? lerp(
    AnimalSelectStyle? a,
    AnimalSelectStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    double? dim(double? x, double? y) =>
        AnimalStyleValues.lerpDimension(x, y, t);
    return AnimalSelectStyle(
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      textColor: AnimalStyleValues.lerpColors(a?.textColor, b?.textColor, t),
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
      borderWidth: dim(a?.borderWidth, b?.borderWidth),
      borderRadius: AnimalStyleValues.lerpRadius(
        a?.borderRadius,
        b?.borderRadius,
        t,
      ),
      horizontalPadding: dim(a?.horizontalPadding, b?.horizontalPadding),
      arrowIconSize: dim(a?.arrowIconSize, b?.arrowIconSize),
      arrowIconColor: AnimalStyleValues.lerpColors(
        a?.arrowIconColor,
        b?.arrowIconColor,
        t,
      ),
      clearIconSize: dim(a?.clearIconSize, b?.clearIconSize),
      clearIconColor: AnimalStyleValues.lerpColor(
        a?.clearIconColor,
        b?.clearIconColor,
        t,
      ),
      menuBackgroundColor: AnimalStyleValues.lerpColor(
        a?.menuBackgroundColor,
        b?.menuBackgroundColor,
        t,
      ),
      menuBorderColor: AnimalStyleValues.lerpColor(
        a?.menuBorderColor,
        b?.menuBorderColor,
        t,
      ),
      menuBorderWidth: dim(a?.menuBorderWidth, b?.menuBorderWidth),
      menuBorderRadius: AnimalStyleValues.lerpRadius(
        a?.menuBorderRadius,
        b?.menuBorderRadius,
        t,
      ),
      menuElevation: dim(a?.menuElevation, b?.menuElevation),
      menuVerticalPadding: dim(a?.menuVerticalPadding, b?.menuVerticalPadding),
      menuMaxWidth: dim(a?.menuMaxWidth, b?.menuMaxWidth),
      menuMaxHeight: dim(a?.menuMaxHeight, b?.menuMaxHeight),
      optionTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.optionTextStyle,
        b?.optionTextStyle,
        t,
      ),
      selectedOptionTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.selectedOptionTextStyle,
        b?.selectedOptionTextStyle,
        t,
      ),
      optionTextColor: AnimalStyleValues.lerpColors(
        a?.optionTextColor,
        b?.optionTextColor,
        t,
      ),
      optionBackgroundColor: AnimalStyleValues.lerpColors(
        a?.optionBackgroundColor,
        b?.optionBackgroundColor,
        t,
      ),
      optionBorderRadius: AnimalStyleValues.lerpRadius(
        a?.optionBorderRadius,
        b?.optionBorderRadius,
        t,
      ),
      optionPadding: AnimalStyleValues.lerpInsets(
        a?.optionPadding,
        b?.optionPadding,
        t,
      ),
      optionIconGap: dim(a?.optionIconGap, b?.optionIconGap),
      checkIconGap: dim(a?.checkIconGap, b?.checkIconGap),
      checkIconSize: dim(a?.checkIconSize, b?.checkIconSize),
      checkIconColor: AnimalStyleValues.lerpColor(
        a?.checkIconColor,
        b?.checkIconColor,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalSelectStyle &&
          textStyle == other.textStyle &&
          textColor == other.textColor &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          glowColor == other.glowColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          horizontalPadding == other.horizontalPadding &&
          arrowIconSize == other.arrowIconSize &&
          arrowIconColor == other.arrowIconColor &&
          clearIconSize == other.clearIconSize &&
          clearIconColor == other.clearIconColor &&
          menuBackgroundColor == other.menuBackgroundColor &&
          menuBorderColor == other.menuBorderColor &&
          menuBorderWidth == other.menuBorderWidth &&
          menuBorderRadius == other.menuBorderRadius &&
          menuElevation == other.menuElevation &&
          menuVerticalPadding == other.menuVerticalPadding &&
          menuMaxWidth == other.menuMaxWidth &&
          menuMaxHeight == other.menuMaxHeight &&
          optionTextStyle == other.optionTextStyle &&
          selectedOptionTextStyle == other.selectedOptionTextStyle &&
          optionTextColor == other.optionTextColor &&
          optionBackgroundColor == other.optionBackgroundColor &&
          optionBorderRadius == other.optionBorderRadius &&
          optionPadding == other.optionPadding &&
          optionIconGap == other.optionIconGap &&
          checkIconGap == other.checkIconGap &&
          checkIconSize == other.checkIconSize &&
          checkIconColor == other.checkIconColor;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    textStyle,
    textColor,
    backgroundColor,
    borderColor,
    glowColor,
    borderWidth,
    borderRadius,
    horizontalPadding,
    arrowIconSize,
    arrowIconColor,
    clearIconSize,
    clearIconColor,
    menuBackgroundColor,
    menuBorderColor,
    menuBorderWidth,
    menuBorderRadius,
    menuElevation,
    menuVerticalPadding,
    menuMaxWidth,
    menuMaxHeight,
    optionTextStyle,
    selectedOptionTextStyle,
    optionTextColor,
    optionBackgroundColor,
    optionBorderRadius,
    optionPadding,
    optionIconGap,
    checkIconGap,
    checkIconSize,
    checkIconColor,
  ]);
}
