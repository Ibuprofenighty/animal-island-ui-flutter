import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalTimePicker`, its panel and its popover trigger.
///
/// The same type customizes one picker through its `style` parameter and every
/// picker through `AnimalIslandTheme.components.timePicker`. Each field is
/// optional; a null field falls through to the theme style and finally to a
/// default derived from the active theme tokens.
///
/// Panel colors resolve against [WidgetState.disabled]; wheel labels also
/// against [WidgetState.selected]. The popover trigger border resolves against
/// [WidgetState.focused] and [WidgetState.error]; the warning status has no
/// Flutter widget state, so it uses [warningColor].
@immutable
class AnimalTimePickerStyle {
  /// Panel width with hour and minute wheels.
  final double? width;

  /// Panel width when the format shows a seconds wheel.
  final double? widthWithSeconds;

  /// Padding inside the panel border.
  final EdgeInsetsGeometry? padding;

  /// Panel surface color.
  final Color? backgroundColor;

  /// Panel border color.
  final Color? borderColor;

  /// Panel border width.
  final double? borderWidth;

  /// Panel corner radius.
  final BorderRadius? borderRadius;

  /// Size of the clock icon in the panel header.
  final double? headerIconSize;

  /// Color of the clock icon in the panel header.
  final Color? headerIconColor;

  /// Gap between the header icon and the title.
  final double? headerGap;

  /// Style of the panel title. Its color is resolved from [titleTextColor].
  final TextStyle? titleTextStyle;

  /// Title color; resolves against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? titleTextColor;

  /// Gap between the header and the wheels.
  final double? wheelGap;

  /// Minimum height of the wheel viewport; it grows to show at least three items.
  final double? wheelHeight;

  /// Minimum height of one wheel item and of the selection band.
  ///
  /// The resolved extent grows with the rendered label height, including the
  /// ambient text scaler, so wheel labels never clip.
  final double? minItemExtent;

  /// Style of unselected wheel labels. Its color is resolved from [itemTextColor].
  final TextStyle? itemTextStyle;

  /// Style of the selected wheel label. Its color is resolved from [itemTextColor].
  final TextStyle? selectedItemTextStyle;

  /// Wheel label color; resolves against [WidgetState.selected] and
  /// [WidgetState.disabled].
  final WidgetStateProperty<Color?>? itemTextColor;

  /// Style of the colon between wheels. Its color is [separatorTextColor].
  final TextStyle? separatorTextStyle;

  /// Color of the colon between wheels.
  final Color? separatorTextColor;

  /// Fill of the selection band behind the selected items.
  final Color? selectionBackgroundColor;

  /// Border color of the selection band.
  final Color? selectionBorderColor;

  /// Border width of the selection band.
  final double? selectionBorderWidth;

  /// Corner radius of the selection band.
  final BorderRadius? selectionBorderRadius;

  /// Horizontal inset of the selection band from the panel content edges.
  final double? selectionInset;

  /// Color of the divider above the footer actions.
  final Color? dividerColor;

  /// Thickness of the divider above the footer actions.
  final double? dividerThickness;

  /// Space above and below the footer divider.
  final EdgeInsetsGeometry? dividerPadding;

  /// Padding inside the Now and Clear actions.
  final EdgeInsetsGeometry? actionPadding;

  /// Style of the Now action label. Its color is resolved from [nowTextColor].
  final TextStyle? nowTextStyle;

  /// Now label color; resolves against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? nowTextColor;

  /// Style of the Clear action label. Its color is resolved from [clearTextColor].
  final TextStyle? clearTextStyle;

  /// Clear label color; resolves against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? clearTextColor;

  /// Popover trigger surface; resolves against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? triggerBackgroundColor;

  /// Popover trigger and menu border; resolves against
  /// [WidgetState.disabled], [WidgetState.focused] (also while the menu is
  /// open) and [WidgetState.error].
  final WidgetStateProperty<Color?>? triggerBorderColor;

  /// Color of the glow around a focused or invalid trigger, resolved against
  /// [WidgetState.focused] and [WidgetState.error].
  final WidgetStateProperty<Color?>? triggerGlowColor;

  /// Popover trigger border and glow color for the warning status.
  final Color? warningColor;

  /// Popover trigger border width.
  final double? triggerBorderWidth;

  /// Popover trigger corner radius.
  final BorderRadius? triggerBorderRadius;

  /// Padding inside the popover trigger.
  final EdgeInsetsGeometry? triggerPadding;

  /// Style of the popover trigger text. Its color is resolved from
  /// [triggerTextColor] or [placeholderTextColor].
  final TextStyle? triggerTextStyle;

  /// Color of the shown time in the trigger; resolves against
  /// [WidgetState.disabled].
  final WidgetStateProperty<Color?>? triggerTextColor;

  /// Color of the trigger placeholder.
  final Color? placeholderTextColor;

  /// Size of the trigger clock icon and clear icon.
  final double? triggerIconSize;

  /// Color of the trigger clock icon and clear icon; resolves against
  /// [WidgetState.disabled].
  final WidgetStateProperty<Color?>? triggerIconColor;

  /// Padding around the clear icon inside its 48 logical-pixel target.
  final EdgeInsetsGeometry? triggerClearButtonPadding;

  /// Corner radius of the clear control's hover fill and focus ring.
  final BorderRadius? triggerClearButtonBorderRadius;

  /// Fill behind the clear icon, resolved against [WidgetState.hovered].
  final WidgetStateProperty<Color?>? triggerClearButtonBackgroundColor;

  /// Gap between the trigger icon and its text.
  final double? triggerIconGap;

  AnimalTimePickerStyle({
    this.width,
    this.widthWithSeconds,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.headerIconSize,
    this.headerIconColor,
    this.headerGap,
    this.titleTextStyle,
    this.titleTextColor,
    this.wheelGap,
    this.wheelHeight,
    this.minItemExtent,
    this.itemTextStyle,
    this.selectedItemTextStyle,
    this.itemTextColor,
    this.separatorTextStyle,
    this.separatorTextColor,
    this.selectionBackgroundColor,
    this.selectionBorderColor,
    this.selectionBorderWidth,
    this.selectionBorderRadius,
    this.selectionInset,
    this.dividerColor,
    this.dividerThickness,
    this.dividerPadding,
    this.actionPadding,
    this.nowTextStyle,
    this.nowTextColor,
    this.clearTextStyle,
    this.clearTextColor,
    this.triggerBackgroundColor,
    this.triggerBorderColor,
    this.triggerGlowColor,
    this.warningColor,
    this.triggerBorderWidth,
    this.triggerBorderRadius,
    this.triggerPadding,
    this.triggerTextStyle,
    this.triggerTextColor,
    this.placeholderTextColor,
    this.triggerIconSize,
    this.triggerIconColor,
    this.triggerClearButtonPadding,
    this.triggerClearButtonBorderRadius,
    this.triggerClearButtonBackgroundColor,
    this.triggerIconGap,
  }) {
    AnimalStyleValues.checkDimension('width', width);
    AnimalStyleValues.checkDimension('widthWithSeconds', widthWithSeconds);
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkDimension('headerIconSize', headerIconSize);
    AnimalStyleValues.checkDimension('headerGap', headerGap);
    AnimalStyleValues.checkDimension('wheelGap', wheelGap);
    AnimalStyleValues.checkDimension('wheelHeight', wheelHeight);
    AnimalStyleValues.checkDimension('minItemExtent', minItemExtent);
    AnimalStyleValues.checkDimension(
      'selectionBorderWidth',
      selectionBorderWidth,
    );
    AnimalStyleValues.checkDimension('selectionInset', selectionInset);
    AnimalStyleValues.checkDimension('dividerThickness', dividerThickness);
    AnimalStyleValues.checkDimension('triggerBorderWidth', triggerBorderWidth);
    AnimalStyleValues.checkDimension('triggerIconSize', triggerIconSize);
    AnimalStyleValues.checkDimension('triggerIconGap', triggerIconGap);
    AnimalStyleValues.checkTextStyle('titleTextStyle', titleTextStyle);
    AnimalStyleValues.checkTextStyle('itemTextStyle', itemTextStyle);
    AnimalStyleValues.checkTextStyle(
      'selectedItemTextStyle',
      selectedItemTextStyle,
    );
    AnimalStyleValues.checkTextStyle('separatorTextStyle', separatorTextStyle);
    AnimalStyleValues.checkTextStyle('nowTextStyle', nowTextStyle);
    AnimalStyleValues.checkTextStyle('clearTextStyle', clearTextStyle);
    AnimalStyleValues.checkTextStyle('triggerTextStyle', triggerTextStyle);
  }

  AnimalTimePickerStyle copyWith({
    double? width,
    double? widthWithSeconds,
    EdgeInsetsGeometry? padding,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    double? headerIconSize,
    Color? headerIconColor,
    double? headerGap,
    TextStyle? titleTextStyle,
    WidgetStateProperty<Color?>? titleTextColor,
    double? wheelGap,
    double? wheelHeight,
    double? minItemExtent,
    TextStyle? itemTextStyle,
    TextStyle? selectedItemTextStyle,
    WidgetStateProperty<Color?>? itemTextColor,
    TextStyle? separatorTextStyle,
    Color? separatorTextColor,
    Color? selectionBackgroundColor,
    Color? selectionBorderColor,
    double? selectionBorderWidth,
    BorderRadius? selectionBorderRadius,
    double? selectionInset,
    Color? dividerColor,
    double? dividerThickness,
    EdgeInsetsGeometry? dividerPadding,
    EdgeInsetsGeometry? actionPadding,
    TextStyle? nowTextStyle,
    WidgetStateProperty<Color?>? nowTextColor,
    TextStyle? clearTextStyle,
    WidgetStateProperty<Color?>? clearTextColor,
    WidgetStateProperty<Color?>? triggerBackgroundColor,
    WidgetStateProperty<Color?>? triggerBorderColor,
    WidgetStateProperty<Color?>? triggerGlowColor,
    Color? warningColor,
    double? triggerBorderWidth,
    BorderRadius? triggerBorderRadius,
    EdgeInsetsGeometry? triggerPadding,
    TextStyle? triggerTextStyle,
    WidgetStateProperty<Color?>? triggerTextColor,
    Color? placeholderTextColor,
    double? triggerIconSize,
    WidgetStateProperty<Color?>? triggerIconColor,
    EdgeInsetsGeometry? triggerClearButtonPadding,
    BorderRadius? triggerClearButtonBorderRadius,
    WidgetStateProperty<Color?>? triggerClearButtonBackgroundColor,
    double? triggerIconGap,
  }) => AnimalTimePickerStyle(
    width: width ?? this.width,
    widthWithSeconds: widthWithSeconds ?? this.widthWithSeconds,
    padding: padding ?? this.padding,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    headerIconSize: headerIconSize ?? this.headerIconSize,
    headerIconColor: headerIconColor ?? this.headerIconColor,
    headerGap: headerGap ?? this.headerGap,
    titleTextStyle: titleTextStyle ?? this.titleTextStyle,
    titleTextColor: titleTextColor ?? this.titleTextColor,
    wheelGap: wheelGap ?? this.wheelGap,
    wheelHeight: wheelHeight ?? this.wheelHeight,
    minItemExtent: minItemExtent ?? this.minItemExtent,
    itemTextStyle: itemTextStyle ?? this.itemTextStyle,
    selectedItemTextStyle: selectedItemTextStyle ?? this.selectedItemTextStyle,
    itemTextColor: itemTextColor ?? this.itemTextColor,
    separatorTextStyle: separatorTextStyle ?? this.separatorTextStyle,
    separatorTextColor: separatorTextColor ?? this.separatorTextColor,
    selectionBackgroundColor:
        selectionBackgroundColor ?? this.selectionBackgroundColor,
    selectionBorderColor: selectionBorderColor ?? this.selectionBorderColor,
    selectionBorderWidth: selectionBorderWidth ?? this.selectionBorderWidth,
    selectionBorderRadius: selectionBorderRadius ?? this.selectionBorderRadius,
    selectionInset: selectionInset ?? this.selectionInset,
    dividerColor: dividerColor ?? this.dividerColor,
    dividerThickness: dividerThickness ?? this.dividerThickness,
    dividerPadding: dividerPadding ?? this.dividerPadding,
    actionPadding: actionPadding ?? this.actionPadding,
    nowTextStyle: nowTextStyle ?? this.nowTextStyle,
    nowTextColor: nowTextColor ?? this.nowTextColor,
    clearTextStyle: clearTextStyle ?? this.clearTextStyle,
    clearTextColor: clearTextColor ?? this.clearTextColor,
    triggerBackgroundColor:
        triggerBackgroundColor ?? this.triggerBackgroundColor,
    triggerBorderColor: triggerBorderColor ?? this.triggerBorderColor,
    triggerGlowColor: triggerGlowColor ?? this.triggerGlowColor,
    warningColor: warningColor ?? this.warningColor,
    triggerBorderWidth: triggerBorderWidth ?? this.triggerBorderWidth,
    triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
    triggerPadding: triggerPadding ?? this.triggerPadding,
    triggerTextStyle: triggerTextStyle ?? this.triggerTextStyle,
    triggerTextColor: triggerTextColor ?? this.triggerTextColor,
    placeholderTextColor: placeholderTextColor ?? this.placeholderTextColor,
    triggerIconSize: triggerIconSize ?? this.triggerIconSize,
    triggerIconColor: triggerIconColor ?? this.triggerIconColor,
    triggerClearButtonPadding:
        triggerClearButtonPadding ?? this.triggerClearButtonPadding,
    triggerClearButtonBorderRadius:
        triggerClearButtonBorderRadius ?? this.triggerClearButtonBorderRadius,
    triggerClearButtonBackgroundColor:
        triggerClearButtonBackgroundColor ??
        this.triggerClearButtonBackgroundColor,
    triggerIconGap: triggerIconGap ?? this.triggerIconGap,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalTimePickerStyle merge(AnimalTimePickerStyle? other) {
    if (other == null) return this;
    return AnimalTimePickerStyle(
      width: width ?? other.width,
      widthWithSeconds: widthWithSeconds ?? other.widthWithSeconds,
      padding: padding ?? other.padding,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      headerIconSize: headerIconSize ?? other.headerIconSize,
      headerIconColor: headerIconColor ?? other.headerIconColor,
      headerGap: headerGap ?? other.headerGap,
      titleTextStyle:
          other.titleTextStyle?.merge(titleTextStyle) ?? titleTextStyle,
      titleTextColor: titleTextColor ?? other.titleTextColor,
      wheelGap: wheelGap ?? other.wheelGap,
      wheelHeight: wheelHeight ?? other.wheelHeight,
      minItemExtent: minItemExtent ?? other.minItemExtent,
      itemTextStyle: other.itemTextStyle?.merge(itemTextStyle) ?? itemTextStyle,
      selectedItemTextStyle:
          other.selectedItemTextStyle?.merge(selectedItemTextStyle) ??
          selectedItemTextStyle,
      itemTextColor: itemTextColor ?? other.itemTextColor,
      separatorTextStyle:
          other.separatorTextStyle?.merge(separatorTextStyle) ??
          separatorTextStyle,
      separatorTextColor: separatorTextColor ?? other.separatorTextColor,
      selectionBackgroundColor:
          selectionBackgroundColor ?? other.selectionBackgroundColor,
      selectionBorderColor: selectionBorderColor ?? other.selectionBorderColor,
      selectionBorderWidth: selectionBorderWidth ?? other.selectionBorderWidth,
      selectionBorderRadius:
          selectionBorderRadius ?? other.selectionBorderRadius,
      selectionInset: selectionInset ?? other.selectionInset,
      dividerColor: dividerColor ?? other.dividerColor,
      dividerThickness: dividerThickness ?? other.dividerThickness,
      dividerPadding: dividerPadding ?? other.dividerPadding,
      actionPadding: actionPadding ?? other.actionPadding,
      nowTextStyle: other.nowTextStyle?.merge(nowTextStyle) ?? nowTextStyle,
      nowTextColor: nowTextColor ?? other.nowTextColor,
      clearTextStyle:
          other.clearTextStyle?.merge(clearTextStyle) ?? clearTextStyle,
      clearTextColor: clearTextColor ?? other.clearTextColor,
      triggerBackgroundColor:
          triggerBackgroundColor ?? other.triggerBackgroundColor,
      triggerBorderColor: triggerBorderColor ?? other.triggerBorderColor,
      triggerGlowColor: triggerGlowColor ?? other.triggerGlowColor,
      warningColor: warningColor ?? other.warningColor,
      triggerBorderWidth: triggerBorderWidth ?? other.triggerBorderWidth,
      triggerBorderRadius: triggerBorderRadius ?? other.triggerBorderRadius,
      triggerPadding: triggerPadding ?? other.triggerPadding,
      triggerTextStyle:
          other.triggerTextStyle?.merge(triggerTextStyle) ?? triggerTextStyle,
      triggerTextColor: triggerTextColor ?? other.triggerTextColor,
      placeholderTextColor: placeholderTextColor ?? other.placeholderTextColor,
      triggerIconSize: triggerIconSize ?? other.triggerIconSize,
      triggerIconColor: triggerIconColor ?? other.triggerIconColor,
      triggerClearButtonPadding:
          triggerClearButtonPadding ?? other.triggerClearButtonPadding,
      triggerClearButtonBorderRadius:
          triggerClearButtonBorderRadius ??
          other.triggerClearButtonBorderRadius,
      triggerClearButtonBackgroundColor:
          triggerClearButtonBackgroundColor ??
          other.triggerClearButtonBackgroundColor,
      triggerIconGap: triggerIconGap ?? other.triggerIconGap,
    );
  }

  static AnimalTimePickerStyle? lerp(
    AnimalTimePickerStyle? a,
    AnimalTimePickerStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalTimePickerStyle(
      width: AnimalStyleValues.lerpDimension(a?.width, b?.width, t),
      widthWithSeconds: AnimalStyleValues.lerpDimension(
        a?.widthWithSeconds,
        b?.widthWithSeconds,
        t,
      ),
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
      headerIconSize: AnimalStyleValues.lerpDimension(
        a?.headerIconSize,
        b?.headerIconSize,
        t,
      ),
      headerIconColor: AnimalStyleValues.lerpColor(
        a?.headerIconColor,
        b?.headerIconColor,
        t,
      ),
      headerGap: AnimalStyleValues.lerpDimension(a?.headerGap, b?.headerGap, t),
      titleTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.titleTextStyle,
        b?.titleTextStyle,
        t,
      ),
      titleTextColor: AnimalStyleValues.lerpColors(
        a?.titleTextColor,
        b?.titleTextColor,
        t,
      ),
      wheelGap: AnimalStyleValues.lerpDimension(a?.wheelGap, b?.wheelGap, t),
      wheelHeight: AnimalStyleValues.lerpDimension(
        a?.wheelHeight,
        b?.wheelHeight,
        t,
      ),
      minItemExtent: AnimalStyleValues.lerpDimension(
        a?.minItemExtent,
        b?.minItemExtent,
        t,
      ),
      itemTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.itemTextStyle,
        b?.itemTextStyle,
        t,
      ),
      selectedItemTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.selectedItemTextStyle,
        b?.selectedItemTextStyle,
        t,
      ),
      itemTextColor: AnimalStyleValues.lerpColors(
        a?.itemTextColor,
        b?.itemTextColor,
        t,
      ),
      separatorTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.separatorTextStyle,
        b?.separatorTextStyle,
        t,
      ),
      separatorTextColor: AnimalStyleValues.lerpColor(
        a?.separatorTextColor,
        b?.separatorTextColor,
        t,
      ),
      selectionBackgroundColor: AnimalStyleValues.lerpColor(
        a?.selectionBackgroundColor,
        b?.selectionBackgroundColor,
        t,
      ),
      selectionBorderColor: AnimalStyleValues.lerpColor(
        a?.selectionBorderColor,
        b?.selectionBorderColor,
        t,
      ),
      selectionBorderWidth: AnimalStyleValues.lerpDimension(
        a?.selectionBorderWidth,
        b?.selectionBorderWidth,
        t,
      ),
      selectionBorderRadius: AnimalStyleValues.lerpRadius(
        a?.selectionBorderRadius,
        b?.selectionBorderRadius,
        t,
      ),
      selectionInset: AnimalStyleValues.lerpDimension(
        a?.selectionInset,
        b?.selectionInset,
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
      dividerPadding: AnimalStyleValues.lerpInsets(
        a?.dividerPadding,
        b?.dividerPadding,
        t,
      ),
      actionPadding: AnimalStyleValues.lerpInsets(
        a?.actionPadding,
        b?.actionPadding,
        t,
      ),
      nowTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.nowTextStyle,
        b?.nowTextStyle,
        t,
      ),
      nowTextColor: AnimalStyleValues.lerpColors(
        a?.nowTextColor,
        b?.nowTextColor,
        t,
      ),
      clearTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.clearTextStyle,
        b?.clearTextStyle,
        t,
      ),
      clearTextColor: AnimalStyleValues.lerpColors(
        a?.clearTextColor,
        b?.clearTextColor,
        t,
      ),
      triggerBackgroundColor: AnimalStyleValues.lerpColors(
        a?.triggerBackgroundColor,
        b?.triggerBackgroundColor,
        t,
      ),
      triggerBorderColor: AnimalStyleValues.lerpColors(
        a?.triggerBorderColor,
        b?.triggerBorderColor,
        t,
      ),
      triggerGlowColor: AnimalStyleValues.lerpColors(
        a?.triggerGlowColor,
        b?.triggerGlowColor,
        t,
      ),
      warningColor: AnimalStyleValues.lerpColor(
        a?.warningColor,
        b?.warningColor,
        t,
      ),
      triggerBorderWidth: AnimalStyleValues.lerpDimension(
        a?.triggerBorderWidth,
        b?.triggerBorderWidth,
        t,
      ),
      triggerBorderRadius: AnimalStyleValues.lerpRadius(
        a?.triggerBorderRadius,
        b?.triggerBorderRadius,
        t,
      ),
      triggerPadding: AnimalStyleValues.lerpInsets(
        a?.triggerPadding,
        b?.triggerPadding,
        t,
      ),
      triggerTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.triggerTextStyle,
        b?.triggerTextStyle,
        t,
      ),
      triggerTextColor: AnimalStyleValues.lerpColors(
        a?.triggerTextColor,
        b?.triggerTextColor,
        t,
      ),
      placeholderTextColor: AnimalStyleValues.lerpColor(
        a?.placeholderTextColor,
        b?.placeholderTextColor,
        t,
      ),
      triggerIconSize: AnimalStyleValues.lerpDimension(
        a?.triggerIconSize,
        b?.triggerIconSize,
        t,
      ),
      triggerIconColor: AnimalStyleValues.lerpColors(
        a?.triggerIconColor,
        b?.triggerIconColor,
        t,
      ),
      triggerClearButtonPadding: AnimalStyleValues.lerpInsets(
        a?.triggerClearButtonPadding,
        b?.triggerClearButtonPadding,
        t,
      ),
      triggerClearButtonBorderRadius: AnimalStyleValues.lerpRadius(
        a?.triggerClearButtonBorderRadius,
        b?.triggerClearButtonBorderRadius,
        t,
      ),
      triggerClearButtonBackgroundColor: AnimalStyleValues.lerpColors(
        a?.triggerClearButtonBackgroundColor,
        b?.triggerClearButtonBackgroundColor,
        t,
      ),
      triggerIconGap: AnimalStyleValues.lerpDimension(
        a?.triggerIconGap,
        b?.triggerIconGap,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTimePickerStyle &&
          width == other.width &&
          widthWithSeconds == other.widthWithSeconds &&
          padding == other.padding &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          headerIconSize == other.headerIconSize &&
          headerIconColor == other.headerIconColor &&
          headerGap == other.headerGap &&
          titleTextStyle == other.titleTextStyle &&
          titleTextColor == other.titleTextColor &&
          wheelGap == other.wheelGap &&
          wheelHeight == other.wheelHeight &&
          minItemExtent == other.minItemExtent &&
          itemTextStyle == other.itemTextStyle &&
          selectedItemTextStyle == other.selectedItemTextStyle &&
          itemTextColor == other.itemTextColor &&
          separatorTextStyle == other.separatorTextStyle &&
          separatorTextColor == other.separatorTextColor &&
          selectionBackgroundColor == other.selectionBackgroundColor &&
          selectionBorderColor == other.selectionBorderColor &&
          selectionBorderWidth == other.selectionBorderWidth &&
          selectionBorderRadius == other.selectionBorderRadius &&
          selectionInset == other.selectionInset &&
          dividerColor == other.dividerColor &&
          dividerThickness == other.dividerThickness &&
          dividerPadding == other.dividerPadding &&
          actionPadding == other.actionPadding &&
          nowTextStyle == other.nowTextStyle &&
          nowTextColor == other.nowTextColor &&
          clearTextStyle == other.clearTextStyle &&
          clearTextColor == other.clearTextColor &&
          triggerBackgroundColor == other.triggerBackgroundColor &&
          triggerBorderColor == other.triggerBorderColor &&
          triggerGlowColor == other.triggerGlowColor &&
          warningColor == other.warningColor &&
          triggerBorderWidth == other.triggerBorderWidth &&
          triggerBorderRadius == other.triggerBorderRadius &&
          triggerPadding == other.triggerPadding &&
          triggerTextStyle == other.triggerTextStyle &&
          triggerTextColor == other.triggerTextColor &&
          placeholderTextColor == other.placeholderTextColor &&
          triggerIconSize == other.triggerIconSize &&
          triggerIconColor == other.triggerIconColor &&
          triggerClearButtonPadding == other.triggerClearButtonPadding &&
          triggerClearButtonBorderRadius ==
              other.triggerClearButtonBorderRadius &&
          triggerClearButtonBackgroundColor ==
              other.triggerClearButtonBackgroundColor &&
          triggerIconGap == other.triggerIconGap;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    width,
    widthWithSeconds,
    padding,
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    headerIconSize,
    headerIconColor,
    headerGap,
    titleTextStyle,
    titleTextColor,
    wheelGap,
    wheelHeight,
    minItemExtent,
    itemTextStyle,
    selectedItemTextStyle,
    itemTextColor,
    separatorTextStyle,
    separatorTextColor,
    selectionBackgroundColor,
    selectionBorderColor,
    selectionBorderWidth,
    selectionBorderRadius,
    selectionInset,
    dividerColor,
    dividerThickness,
    dividerPadding,
    actionPadding,
    nowTextStyle,
    nowTextColor,
    clearTextStyle,
    clearTextColor,
    triggerBackgroundColor,
    triggerBorderColor,
    triggerGlowColor,
    warningColor,
    triggerBorderWidth,
    triggerBorderRadius,
    triggerPadding,
    triggerTextStyle,
    triggerTextColor,
    placeholderTextColor,
    triggerIconSize,
    triggerIconColor,
    triggerClearButtonPadding,
    triggerClearButtonBorderRadius,
    triggerClearButtonBackgroundColor,
    triggerIconGap,
  ]);
}
