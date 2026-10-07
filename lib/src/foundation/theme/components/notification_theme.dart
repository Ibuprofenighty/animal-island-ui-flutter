import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalNotification`.
///
/// The same type customizes one notification through the `style` argument of
/// `AnimalNotification.open` and every notification through
/// `AnimalIslandTheme.components`. Each field is optional; a null field falls
/// through to the next layer and finally to a default derived from the active
/// theme tokens.
///
/// The default colors depend on the notification type (info, success, warning
/// or error). A color set here replaces the type color for every type, so pass
/// a per-notification `style` for a type-specific color.
///
/// [closeButtonBackgroundColor] resolves against [WidgetState.hovered].
@immutable
class AnimalNotificationStyle {
  /// Largest width of one notification card; narrower hosts shrink it.
  final double? maxWidth;

  /// Space below each card in its placement stack.
  final double? gap;

  /// Padding around the icon, message and description.
  final EdgeInsetsGeometry? padding;

  /// Padding around the type icon, inside [padding].
  final EdgeInsetsGeometry? iconPadding;

  /// Size of the default type icon.
  final double? iconSize;

  /// Space between the icon and the text column.
  final double? iconGap;

  /// Space between the message and the description.
  final double? descriptionGap;

  /// Space between the text column and the close button.
  final double? closeButtonGap;

  /// Space around the close button, outside its circle.
  final EdgeInsetsGeometry? closeButtonMargin;

  /// Padding inside the close button circle.
  final EdgeInsetsGeometry? closeButtonPadding;

  /// Size of the close icon.
  final double? closeIconSize;

  /// Corner radius of the close control's hover fill and focus ring.
  final BorderRadius? closeButtonBorderRadius;

  /// Style of the message. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  /// Style of the description. Its color is resolved from
  /// [descriptionTextColor].
  final TextStyle? descriptionTextStyle;

  /// Card fill.
  final Color? backgroundColor;

  /// Card border.
  final Color? borderColor;

  /// Message color.
  final Color? textColor;

  /// Description color.
  final Color? descriptionTextColor;

  /// Color of the default type icon.
  final Color? iconColor;

  /// Color of the close icon.
  final Color? closeIconColor;

  /// Fill of the close button circle; resolves [WidgetState.hovered].
  final WidgetStateProperty<Color?>? closeButtonBackgroundColor;

  /// Width of the card border.
  final double? borderWidth;

  /// Corner radius of the card.
  final BorderRadius? borderRadius;

  /// Card shadow.
  final BoxShadow? shadow;

  AnimalNotificationStyle({
    this.maxWidth,
    this.gap,
    this.padding,
    this.iconPadding,
    this.iconSize,
    this.iconGap,
    this.descriptionGap,
    this.closeButtonGap,
    this.closeButtonMargin,
    this.closeButtonPadding,
    this.closeIconSize,
    this.closeButtonBorderRadius,
    this.textStyle,
    this.descriptionTextStyle,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.descriptionTextColor,
    this.iconColor,
    this.closeIconColor,
    this.closeButtonBackgroundColor,
    this.borderWidth,
    this.borderRadius,
    this.shadow,
  }) {
    AnimalStyleValues.checkDimension('maxWidth', maxWidth);
    AnimalStyleValues.checkDimension('gap', gap);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkDimension('iconGap', iconGap);
    AnimalStyleValues.checkDimension('descriptionGap', descriptionGap);
    AnimalStyleValues.checkDimension('closeButtonGap', closeButtonGap);
    AnimalStyleValues.checkDimension('closeIconSize', closeIconSize);
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkTextStyle(
      'descriptionTextStyle',
      descriptionTextStyle,
    );
  }

  AnimalNotificationStyle copyWith({
    double? maxWidth,
    double? gap,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? iconPadding,
    double? iconSize,
    double? iconGap,
    double? descriptionGap,
    double? closeButtonGap,
    EdgeInsetsGeometry? closeButtonMargin,
    EdgeInsetsGeometry? closeButtonPadding,
    double? closeIconSize,
    BorderRadius? closeButtonBorderRadius,
    TextStyle? textStyle,
    TextStyle? descriptionTextStyle,
    Color? backgroundColor,
    Color? borderColor,
    Color? textColor,
    Color? descriptionTextColor,
    Color? iconColor,
    Color? closeIconColor,
    WidgetStateProperty<Color?>? closeButtonBackgroundColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
  }) => AnimalNotificationStyle(
    maxWidth: maxWidth ?? this.maxWidth,
    gap: gap ?? this.gap,
    padding: padding ?? this.padding,
    iconPadding: iconPadding ?? this.iconPadding,
    iconSize: iconSize ?? this.iconSize,
    iconGap: iconGap ?? this.iconGap,
    descriptionGap: descriptionGap ?? this.descriptionGap,
    closeButtonGap: closeButtonGap ?? this.closeButtonGap,
    closeButtonMargin: closeButtonMargin ?? this.closeButtonMargin,
    closeButtonPadding: closeButtonPadding ?? this.closeButtonPadding,
    closeIconSize: closeIconSize ?? this.closeIconSize,
    closeButtonBorderRadius:
        closeButtonBorderRadius ?? this.closeButtonBorderRadius,
    textStyle: textStyle ?? this.textStyle,
    descriptionTextStyle: descriptionTextStyle ?? this.descriptionTextStyle,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    textColor: textColor ?? this.textColor,
    descriptionTextColor: descriptionTextColor ?? this.descriptionTextColor,
    iconColor: iconColor ?? this.iconColor,
    closeIconColor: closeIconColor ?? this.closeIconColor,
    closeButtonBackgroundColor:
        closeButtonBackgroundColor ?? this.closeButtonBackgroundColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    shadow: shadow ?? this.shadow,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalNotificationStyle merge(AnimalNotificationStyle? other) {
    if (other == null) return this;
    return AnimalNotificationStyle(
      maxWidth: maxWidth ?? other.maxWidth,
      gap: gap ?? other.gap,
      padding: padding ?? other.padding,
      iconPadding: iconPadding ?? other.iconPadding,
      iconSize: iconSize ?? other.iconSize,
      iconGap: iconGap ?? other.iconGap,
      descriptionGap: descriptionGap ?? other.descriptionGap,
      closeButtonGap: closeButtonGap ?? other.closeButtonGap,
      closeButtonMargin: closeButtonMargin ?? other.closeButtonMargin,
      closeButtonPadding: closeButtonPadding ?? other.closeButtonPadding,
      closeIconSize: closeIconSize ?? other.closeIconSize,
      closeButtonBorderRadius:
          closeButtonBorderRadius ?? other.closeButtonBorderRadius,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      descriptionTextStyle:
          other.descriptionTextStyle?.merge(descriptionTextStyle) ??
          descriptionTextStyle,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      textColor: textColor ?? other.textColor,
      descriptionTextColor: descriptionTextColor ?? other.descriptionTextColor,
      iconColor: iconColor ?? other.iconColor,
      closeIconColor: closeIconColor ?? other.closeIconColor,
      closeButtonBackgroundColor:
          closeButtonBackgroundColor ?? other.closeButtonBackgroundColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      shadow: shadow ?? other.shadow,
    );
  }

  static AnimalNotificationStyle? lerp(
    AnimalNotificationStyle? a,
    AnimalNotificationStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalNotificationStyle(
      maxWidth: AnimalStyleValues.lerpDimension(a?.maxWidth, b?.maxWidth, t),
      gap: AnimalStyleValues.lerpDimension(a?.gap, b?.gap, t),
      padding: AnimalStyleValues.lerpInsets(a?.padding, b?.padding, t),
      iconPadding: AnimalStyleValues.lerpInsets(
        a?.iconPadding,
        b?.iconPadding,
        t,
      ),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      iconGap: AnimalStyleValues.lerpDimension(a?.iconGap, b?.iconGap, t),
      descriptionGap: AnimalStyleValues.lerpDimension(
        a?.descriptionGap,
        b?.descriptionGap,
        t,
      ),
      closeButtonGap: AnimalStyleValues.lerpDimension(
        a?.closeButtonGap,
        b?.closeButtonGap,
        t,
      ),
      closeButtonMargin: AnimalStyleValues.lerpInsets(
        a?.closeButtonMargin,
        b?.closeButtonMargin,
        t,
      ),
      closeButtonPadding: AnimalStyleValues.lerpInsets(
        a?.closeButtonPadding,
        b?.closeButtonPadding,
        t,
      ),
      closeIconSize: AnimalStyleValues.lerpDimension(
        a?.closeIconSize,
        b?.closeIconSize,
        t,
      ),
      closeButtonBorderRadius: AnimalStyleValues.lerpRadius(
        a?.closeButtonBorderRadius,
        b?.closeButtonBorderRadius,
        t,
      ),
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      descriptionTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.descriptionTextStyle,
        b?.descriptionTextStyle,
        t,
      ),
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
      textColor: AnimalStyleValues.lerpColor(a?.textColor, b?.textColor, t),
      descriptionTextColor: AnimalStyleValues.lerpColor(
        a?.descriptionTextColor,
        b?.descriptionTextColor,
        t,
      ),
      iconColor: AnimalStyleValues.lerpColor(a?.iconColor, b?.iconColor, t),
      closeIconColor: AnimalStyleValues.lerpColor(
        a?.closeIconColor,
        b?.closeIconColor,
        t,
      ),
      closeButtonBackgroundColor: AnimalStyleValues.lerpColors(
        a?.closeButtonBackgroundColor,
        b?.closeButtonBackgroundColor,
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
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalNotificationStyle &&
          maxWidth == other.maxWidth &&
          gap == other.gap &&
          padding == other.padding &&
          iconPadding == other.iconPadding &&
          iconSize == other.iconSize &&
          iconGap == other.iconGap &&
          descriptionGap == other.descriptionGap &&
          closeButtonGap == other.closeButtonGap &&
          closeButtonMargin == other.closeButtonMargin &&
          closeButtonPadding == other.closeButtonPadding &&
          closeIconSize == other.closeIconSize &&
          closeButtonBorderRadius == other.closeButtonBorderRadius &&
          textStyle == other.textStyle &&
          descriptionTextStyle == other.descriptionTextStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          textColor == other.textColor &&
          descriptionTextColor == other.descriptionTextColor &&
          iconColor == other.iconColor &&
          closeIconColor == other.closeIconColor &&
          closeButtonBackgroundColor == other.closeButtonBackgroundColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          shadow == other.shadow;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    maxWidth,
    gap,
    padding,
    iconPadding,
    iconSize,
    iconGap,
    descriptionGap,
    closeButtonGap,
    closeButtonMargin,
    closeButtonPadding,
    closeIconSize,
    closeButtonBorderRadius,
    textStyle,
    descriptionTextStyle,
    backgroundColor,
    borderColor,
    textColor,
    descriptionTextColor,
    iconColor,
    closeIconColor,
    closeButtonBackgroundColor,
    borderWidth,
    borderRadius,
    shadow,
  ]);
}
