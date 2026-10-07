import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalDrawer`.
///
/// The same type customizes one drawer through its `style` parameter (or the
/// `style` argument of `AnimalDrawer.show`) and every drawer through
/// `AnimalIslandTheme.components.drawer`. Each field is optional; a null field
/// falls through to the next layer and finally to a default derived from the
/// active theme tokens.
///
/// [closeButtonBackgroundColor] resolves against [WidgetState.hovered].
@immutable
class AnimalDrawerStyle {
  /// Fill of the drawer sheet.
  final Color? backgroundColor;

  /// Stroke around the sheet.
  final Color? borderColor;

  /// Width of the sheet border.
  final double? borderWidth;

  /// Corner radius of the sheet. By default only the corners facing into the
  /// screen are rounded.
  final BorderRadius? borderRadius;

  /// Shadow under the sheet; replaces the theme modal shadow list.
  final BoxShadow? shadow;

  /// Style of the title. Its color is resolved from [titleTextColor].
  final TextStyle? titleTextStyle;

  /// Color of the title.
  final Color? titleTextColor;

  /// Padding around the title row.
  final EdgeInsetsGeometry? headerPadding;

  /// Padding around the body.
  final EdgeInsetsGeometry? bodyPadding;

  /// Padding around the footer.
  final EdgeInsetsGeometry? footerPadding;

  /// Color of the rules below the header and above the footer.
  final Color? dividerColor;

  /// Thickness of the rules around the body.
  final double? dividerThickness;

  /// Color of the close icon.
  final Color? closeIconColor;

  /// Size of the close icon.
  final double? closeIconSize;

  /// Padding around the close icon inside its 48 logical-pixel target.
  final EdgeInsetsGeometry? closeButtonPadding;

  /// Corner radius of the close control's hover fill and focus ring.
  final BorderRadius? closeButtonBorderRadius;

  /// Fill behind the close icon.
  final WidgetStateProperty<Color?>? closeButtonBackgroundColor;

  /// Color of the mask behind the drawer.
  final Color? barrierColor;

  AnimalDrawerStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadow,
    this.titleTextStyle,
    this.titleTextColor,
    this.headerPadding,
    this.bodyPadding,
    this.footerPadding,
    this.dividerColor,
    this.dividerThickness,
    this.closeIconColor,
    this.closeIconSize,
    this.closeButtonPadding,
    this.closeButtonBorderRadius,
    this.closeButtonBackgroundColor,
    this.barrierColor,
  }) {
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkTextStyle('titleTextStyle', titleTextStyle);
    AnimalStyleValues.checkDimension('dividerThickness', dividerThickness);
    AnimalStyleValues.checkDimension('closeIconSize', closeIconSize);
  }

  AnimalDrawerStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
    TextStyle? titleTextStyle,
    Color? titleTextColor,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? bodyPadding,
    EdgeInsetsGeometry? footerPadding,
    Color? dividerColor,
    double? dividerThickness,
    Color? closeIconColor,
    double? closeIconSize,
    EdgeInsetsGeometry? closeButtonPadding,
    BorderRadius? closeButtonBorderRadius,
    WidgetStateProperty<Color?>? closeButtonBackgroundColor,
    Color? barrierColor,
  }) => AnimalDrawerStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    shadow: shadow ?? this.shadow,
    titleTextStyle: titleTextStyle ?? this.titleTextStyle,
    titleTextColor: titleTextColor ?? this.titleTextColor,
    headerPadding: headerPadding ?? this.headerPadding,
    bodyPadding: bodyPadding ?? this.bodyPadding,
    footerPadding: footerPadding ?? this.footerPadding,
    dividerColor: dividerColor ?? this.dividerColor,
    dividerThickness: dividerThickness ?? this.dividerThickness,
    closeIconColor: closeIconColor ?? this.closeIconColor,
    closeIconSize: closeIconSize ?? this.closeIconSize,
    closeButtonPadding: closeButtonPadding ?? this.closeButtonPadding,
    closeButtonBorderRadius:
        closeButtonBorderRadius ?? this.closeButtonBorderRadius,
    closeButtonBackgroundColor:
        closeButtonBackgroundColor ?? this.closeButtonBackgroundColor,
    barrierColor: barrierColor ?? this.barrierColor,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalDrawerStyle merge(AnimalDrawerStyle? other) {
    if (other == null) return this;
    return AnimalDrawerStyle(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      shadow: shadow ?? other.shadow,
      titleTextStyle:
          other.titleTextStyle?.merge(titleTextStyle) ?? titleTextStyle,
      titleTextColor: titleTextColor ?? other.titleTextColor,
      headerPadding: headerPadding ?? other.headerPadding,
      bodyPadding: bodyPadding ?? other.bodyPadding,
      footerPadding: footerPadding ?? other.footerPadding,
      dividerColor: dividerColor ?? other.dividerColor,
      dividerThickness: dividerThickness ?? other.dividerThickness,
      closeIconColor: closeIconColor ?? other.closeIconColor,
      closeIconSize: closeIconSize ?? other.closeIconSize,
      closeButtonPadding: closeButtonPadding ?? other.closeButtonPadding,
      closeButtonBorderRadius:
          closeButtonBorderRadius ?? other.closeButtonBorderRadius,
      closeButtonBackgroundColor:
          closeButtonBackgroundColor ?? other.closeButtonBackgroundColor,
      barrierColor: barrierColor ?? other.barrierColor,
    );
  }

  static AnimalDrawerStyle? lerp(
    AnimalDrawerStyle? a,
    AnimalDrawerStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalDrawerStyle(
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
      titleTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.titleTextStyle,
        b?.titleTextStyle,
        t,
      ),
      titleTextColor: AnimalStyleValues.lerpColor(
        a?.titleTextColor,
        b?.titleTextColor,
        t,
      ),
      headerPadding: AnimalStyleValues.lerpInsets(
        a?.headerPadding,
        b?.headerPadding,
        t,
      ),
      bodyPadding: AnimalStyleValues.lerpInsets(
        a?.bodyPadding,
        b?.bodyPadding,
        t,
      ),
      footerPadding: AnimalStyleValues.lerpInsets(
        a?.footerPadding,
        b?.footerPadding,
        t,
      ),
      dividerColor: AnimalStyleValues.lerpColor(
        a?.dividerColor,
        b?.dividerColor,
        t,
      ),
      dividerThickness: AnimalStyleValues.lerpDimension(
        a?.dividerThickness,
        b?.dividerThickness,
        t,
      ),
      closeIconColor: AnimalStyleValues.lerpColor(
        a?.closeIconColor,
        b?.closeIconColor,
        t,
      ),
      closeIconSize: AnimalStyleValues.lerpDimension(
        a?.closeIconSize,
        b?.closeIconSize,
        t,
      ),
      closeButtonPadding: AnimalStyleValues.lerpInsets(
        a?.closeButtonPadding,
        b?.closeButtonPadding,
        t,
      ),
      closeButtonBorderRadius: AnimalStyleValues.lerpRadius(
        a?.closeButtonBorderRadius,
        b?.closeButtonBorderRadius,
        t,
      ),
      closeButtonBackgroundColor: AnimalStyleValues.lerpColors(
        a?.closeButtonBackgroundColor,
        b?.closeButtonBackgroundColor,
        t,
      ),
      barrierColor: AnimalStyleValues.lerpColor(
        a?.barrierColor,
        b?.barrierColor,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalDrawerStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          shadow == other.shadow &&
          titleTextStyle == other.titleTextStyle &&
          titleTextColor == other.titleTextColor &&
          headerPadding == other.headerPadding &&
          bodyPadding == other.bodyPadding &&
          footerPadding == other.footerPadding &&
          dividerColor == other.dividerColor &&
          dividerThickness == other.dividerThickness &&
          closeIconColor == other.closeIconColor &&
          closeIconSize == other.closeIconSize &&
          closeButtonPadding == other.closeButtonPadding &&
          closeButtonBorderRadius == other.closeButtonBorderRadius &&
          closeButtonBackgroundColor == other.closeButtonBackgroundColor &&
          barrierColor == other.barrierColor;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    shadow,
    titleTextStyle,
    titleTextColor,
    headerPadding,
    bodyPadding,
    footerPadding,
    dividerColor,
    dividerThickness,
    closeIconColor,
    closeIconSize,
    closeButtonPadding,
    closeButtonBorderRadius,
    closeButtonBackgroundColor,
    barrierColor,
  ]);
}
