import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalModal`.
///
/// The same type customizes one modal through its `style` parameter (or the
/// `style` argument of `AnimalModal.confirm`, `AnimalModal.showDialogue` and
/// `AnimalModal.show`) and every modal through
/// `AnimalIslandTheme.components.modal`. Each field is optional; a null field
/// falls through to the next layer and finally to a default derived from the
/// active theme tokens.
///
/// [closeButtonBackgroundColor] resolves against [WidgetState.hovered].
@immutable
class AnimalModalStyle {
  /// Fill of the blob surface.
  final Color? backgroundColor;

  /// Stroke of the blob outline.
  final Color? borderColor;

  /// Width of the blob outline.
  final double? borderWidth;

  /// Shadow under the surface; replaces the theme modal shadow list.
  final BoxShadow? shadow;

  /// Padding inside the blob surface.
  final EdgeInsetsGeometry? padding;

  /// Smallest space between the surface and each side of the screen.
  final double? horizontalMargin;

  /// Style of the title. Its color is resolved from [titleTextColor].
  final TextStyle? titleTextStyle;

  /// Color of the title.
  final Color? titleTextColor;

  /// Style of the body. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  /// Color of the body text.
  final Color? textColor;

  /// Style of a failed confirmation message. Its color is resolved from
  /// [errorTextColor].
  final TextStyle? errorTextStyle;

  /// Color of a failed confirmation message.
  final Color? errorTextColor;

  /// Space between the header and the body.
  final double? headerGap;

  /// Space between the body and a confirmation error.
  final double? errorGap;

  /// Space between the body and the footer.
  final double? footerGap;

  /// Space between the cancel and confirm actions.
  final double? actionGap;

  /// Space between a dialogue avatar and its text.
  final double? avatarGap;

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

  /// Color of the mask behind the modal.
  final Color? barrierColor;

  /// Blur applied behind the modal while the mask is shown.
  final double? barrierBlurSigma;

  AnimalModalStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.shadow,
    this.padding,
    this.horizontalMargin,
    this.titleTextStyle,
    this.titleTextColor,
    this.textStyle,
    this.textColor,
    this.errorTextStyle,
    this.errorTextColor,
    this.headerGap,
    this.errorGap,
    this.footerGap,
    this.actionGap,
    this.avatarGap,
    this.closeIconColor,
    this.closeIconSize,
    this.closeButtonPadding,
    this.closeButtonBorderRadius,
    this.closeButtonBackgroundColor,
    this.barrierColor,
    this.barrierBlurSigma,
  }) {
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkDimension('horizontalMargin', horizontalMargin);
    AnimalStyleValues.checkTextStyle('titleTextStyle', titleTextStyle);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkTextStyle('errorTextStyle', errorTextStyle);
    AnimalStyleValues.checkDimension('headerGap', headerGap);
    AnimalStyleValues.checkDimension('errorGap', errorGap);
    AnimalStyleValues.checkDimension('footerGap', footerGap);
    AnimalStyleValues.checkDimension('actionGap', actionGap);
    AnimalStyleValues.checkDimension('avatarGap', avatarGap);
    AnimalStyleValues.checkDimension('closeIconSize', closeIconSize);
    AnimalStyleValues.checkDimension('barrierBlurSigma', barrierBlurSigma);
  }

  AnimalModalStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BoxShadow? shadow,
    EdgeInsetsGeometry? padding,
    double? horizontalMargin,
    TextStyle? titleTextStyle,
    Color? titleTextColor,
    TextStyle? textStyle,
    Color? textColor,
    TextStyle? errorTextStyle,
    Color? errorTextColor,
    double? headerGap,
    double? errorGap,
    double? footerGap,
    double? actionGap,
    double? avatarGap,
    Color? closeIconColor,
    double? closeIconSize,
    EdgeInsetsGeometry? closeButtonPadding,
    BorderRadius? closeButtonBorderRadius,
    WidgetStateProperty<Color?>? closeButtonBackgroundColor,
    Color? barrierColor,
    double? barrierBlurSigma,
  }) => AnimalModalStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    shadow: shadow ?? this.shadow,
    padding: padding ?? this.padding,
    horizontalMargin: horizontalMargin ?? this.horizontalMargin,
    titleTextStyle: titleTextStyle ?? this.titleTextStyle,
    titleTextColor: titleTextColor ?? this.titleTextColor,
    textStyle: textStyle ?? this.textStyle,
    textColor: textColor ?? this.textColor,
    errorTextStyle: errorTextStyle ?? this.errorTextStyle,
    errorTextColor: errorTextColor ?? this.errorTextColor,
    headerGap: headerGap ?? this.headerGap,
    errorGap: errorGap ?? this.errorGap,
    footerGap: footerGap ?? this.footerGap,
    actionGap: actionGap ?? this.actionGap,
    avatarGap: avatarGap ?? this.avatarGap,
    closeIconColor: closeIconColor ?? this.closeIconColor,
    closeIconSize: closeIconSize ?? this.closeIconSize,
    closeButtonPadding: closeButtonPadding ?? this.closeButtonPadding,
    closeButtonBorderRadius:
        closeButtonBorderRadius ?? this.closeButtonBorderRadius,
    closeButtonBackgroundColor:
        closeButtonBackgroundColor ?? this.closeButtonBackgroundColor,
    barrierColor: barrierColor ?? this.barrierColor,
    barrierBlurSigma: barrierBlurSigma ?? this.barrierBlurSigma,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalModalStyle merge(AnimalModalStyle? other) {
    if (other == null) return this;
    return AnimalModalStyle(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      shadow: shadow ?? other.shadow,
      padding: padding ?? other.padding,
      horizontalMargin: horizontalMargin ?? other.horizontalMargin,
      titleTextStyle:
          other.titleTextStyle?.merge(titleTextStyle) ?? titleTextStyle,
      titleTextColor: titleTextColor ?? other.titleTextColor,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      textColor: textColor ?? other.textColor,
      errorTextStyle:
          other.errorTextStyle?.merge(errorTextStyle) ?? errorTextStyle,
      errorTextColor: errorTextColor ?? other.errorTextColor,
      headerGap: headerGap ?? other.headerGap,
      errorGap: errorGap ?? other.errorGap,
      footerGap: footerGap ?? other.footerGap,
      actionGap: actionGap ?? other.actionGap,
      avatarGap: avatarGap ?? other.avatarGap,
      closeIconColor: closeIconColor ?? other.closeIconColor,
      closeIconSize: closeIconSize ?? other.closeIconSize,
      closeButtonPadding: closeButtonPadding ?? other.closeButtonPadding,
      closeButtonBorderRadius:
          closeButtonBorderRadius ?? other.closeButtonBorderRadius,
      closeButtonBackgroundColor:
          closeButtonBackgroundColor ?? other.closeButtonBackgroundColor,
      barrierColor: barrierColor ?? other.barrierColor,
      barrierBlurSigma: barrierBlurSigma ?? other.barrierBlurSigma,
    );
  }

  static AnimalModalStyle? lerp(
    AnimalModalStyle? a,
    AnimalModalStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalModalStyle(
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
      shadow: AnimalStyleValues.lerpShadow(a?.shadow, b?.shadow, t),
      padding: AnimalStyleValues.lerpInsets(a?.padding, b?.padding, t),
      horizontalMargin: AnimalStyleValues.lerpDimension(
        a?.horizontalMargin,
        b?.horizontalMargin,
        t,
      ),
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
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      textColor: AnimalStyleValues.lerpColor(a?.textColor, b?.textColor, t),
      errorTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.errorTextStyle,
        b?.errorTextStyle,
        t,
      ),
      errorTextColor: AnimalStyleValues.lerpColor(
        a?.errorTextColor,
        b?.errorTextColor,
        t,
      ),
      headerGap: AnimalStyleValues.lerpDimension(a?.headerGap, b?.headerGap, t),
      errorGap: AnimalStyleValues.lerpDimension(a?.errorGap, b?.errorGap, t),
      footerGap: AnimalStyleValues.lerpDimension(a?.footerGap, b?.footerGap, t),
      actionGap: AnimalStyleValues.lerpDimension(a?.actionGap, b?.actionGap, t),
      avatarGap: AnimalStyleValues.lerpDimension(a?.avatarGap, b?.avatarGap, t),
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
      barrierBlurSigma: AnimalStyleValues.lerpDimension(
        a?.barrierBlurSigma,
        b?.barrierBlurSigma,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalModalStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          shadow == other.shadow &&
          padding == other.padding &&
          horizontalMargin == other.horizontalMargin &&
          titleTextStyle == other.titleTextStyle &&
          titleTextColor == other.titleTextColor &&
          textStyle == other.textStyle &&
          textColor == other.textColor &&
          errorTextStyle == other.errorTextStyle &&
          errorTextColor == other.errorTextColor &&
          headerGap == other.headerGap &&
          errorGap == other.errorGap &&
          footerGap == other.footerGap &&
          actionGap == other.actionGap &&
          avatarGap == other.avatarGap &&
          closeIconColor == other.closeIconColor &&
          closeIconSize == other.closeIconSize &&
          closeButtonPadding == other.closeButtonPadding &&
          closeButtonBorderRadius == other.closeButtonBorderRadius &&
          closeButtonBackgroundColor == other.closeButtonBackgroundColor &&
          barrierColor == other.barrierColor &&
          barrierBlurSigma == other.barrierBlurSigma;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    backgroundColor,
    borderColor,
    borderWidth,
    shadow,
    padding,
    horizontalMargin,
    titleTextStyle,
    titleTextColor,
    textStyle,
    textColor,
    errorTextStyle,
    errorTextColor,
    headerGap,
    errorGap,
    footerGap,
    actionGap,
    avatarGap,
    closeIconColor,
    closeIconSize,
    closeButtonPadding,
    closeButtonBorderRadius,
    closeButtonBackgroundColor,
    barrierColor,
    barrierBlurSigma,
  ]);
}
