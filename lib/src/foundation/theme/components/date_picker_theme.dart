import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalDatePicker` and its popover.
///
/// The same type customizes one date picker through its `style` parameter and
/// every date picker through `AnimalIslandTheme.components.datePicker`. Each
/// field is optional; a null field falls through to the next layer and finally
/// to a default derived from the active theme tokens.
///
/// Color properties resolve against [WidgetState.selected],
/// [WidgetState.disabled], [WidgetState.focused] and [WidgetState.error] as
/// documented on each field. Range endpoints use [rangeBackgroundColor] and
/// [rangeTextColor]; days outside the visible month use
/// [outsideMonthTextColor]; the popover warning status has no Flutter widget
/// state, so it uses [warningColor].
@immutable
class AnimalDatePickerStyle {
  /// Preferred panel width. A narrower parent constraint still wins.
  final double? width;

  /// Padding inside the panel border.
  final EdgeInsetsGeometry? padding;

  /// Width of the panel, popover menu and popover trigger borders.
  final double? borderWidth;

  /// Corner radius of the panel and popover menu.
  final BorderRadius? borderRadius;

  /// Inset between a date cell's 48dp target and its selection fill.
  final double? cellInset;

  /// Corner radius of the fill behind days inside a range.
  final BorderRadius? rangeBorderRadius;

  /// Border width of month-mode cells.
  final double? monthBorderWidth;

  /// Corner radius of month-mode cells.
  final BorderRadius? monthBorderRadius;

  /// Size of the previous/next month icons; year icons use 18/20 of it.
  final double? navigationIconSize;

  /// Size of the popover trigger's calendar and clear icons.
  final double? triggerIconSize;

  /// Corner radius of the popover trigger.
  final BorderRadius? triggerBorderRadius;

  /// Horizontal padding inside the popover trigger.
  final double? triggerHorizontalPadding;

  /// Gap between the trigger icon and its text.
  final double? triggerIconGap;

  /// Gap between the header, the grid and the footer divider.
  final double? sectionGap;

  /// Gap between the footer divider and the Today and Clear actions.
  final double? footerGap;

  /// Gap between month cells, between date rows and below the weekdays.
  final double? cellGap;

  /// Horizontal padding inside the Today and Clear actions.
  final double? actionHorizontalPadding;

  /// Style of the month or year heading. Its color is [headerTextColor].
  final TextStyle? headerTextStyle;

  /// Style of the weekday labels. Its color is [weekdayTextColor].
  final TextStyle? weekdayTextStyle;

  /// Style of day and month cell labels. Selected cells and today are bold.
  final TextStyle? cellTextStyle;

  /// Style of the Today and Clear footer actions.
  final TextStyle? actionTextStyle;

  /// Style of the popover trigger text.
  final TextStyle? triggerTextStyle;

  /// Panel and popover menu surface.
  final Color? backgroundColor;

  /// Panel, divider and trigger border. The trigger resolves it against
  /// [WidgetState.focused], [WidgetState.error] and [WidgetState.disabled].
  final WidgetStateProperty<Color?>? borderColor;

  /// Color of the glow around a focused or invalid trigger, resolved against
  /// [WidgetState.focused] and [WidgetState.error].
  final WidgetStateProperty<Color?>? glowColor;

  /// Trigger border and glow for the warning status.
  final Color? warningColor;

  /// Heading text and navigation icons; [WidgetState.disabled] when inert.
  final WidgetStateProperty<Color?>? headerTextColor;

  /// Weekday label text.
  final Color? weekdayTextColor;

  /// Day and month labels, against [WidgetState.selected] and
  /// [WidgetState.disabled].
  final WidgetStateProperty<Color?>? cellTextColor;

  /// Labels of days that belong to the previous or next month.
  final Color? outsideMonthTextColor;

  /// Fill of the selected day or month.
  final Color? selectedBackgroundColor;

  /// Fill of range endpoints; days inside the range use it at 18% opacity.
  final Color? rangeBackgroundColor;

  /// Label color of range endpoints.
  final Color? rangeTextColor;

  /// Month cell border, against [WidgetState.selected].
  final WidgetStateProperty<Color?>? monthBorderColor;

  /// Today action, against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? todayTextColor;

  /// Clear action, against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? clearTextColor;

  /// Popover trigger surface, against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? triggerBackgroundColor;

  /// Popover trigger text when a value is selected, against
  /// [WidgetState.disabled].
  final WidgetStateProperty<Color?>? triggerTextColor;

  /// Popover trigger text when nothing is selected.
  final Color? placeholderTextColor;

  /// Popover calendar and clear icons, against [WidgetState.disabled].
  final WidgetStateProperty<Color?>? triggerIconColor;

  /// Padding around the clear icon inside its 48 logical-pixel target.
  final EdgeInsetsGeometry? triggerClearButtonPadding;

  /// Corner radius of the clear control's hover fill and focus ring.
  final BorderRadius? triggerClearButtonBorderRadius;

  /// Fill behind the clear icon, resolved against [WidgetState.hovered].
  final WidgetStateProperty<Color?>? triggerClearButtonBackgroundColor;

  AnimalDatePickerStyle({
    this.width,
    this.padding,
    this.borderWidth,
    this.borderRadius,
    this.cellInset,
    this.rangeBorderRadius,
    this.monthBorderWidth,
    this.monthBorderRadius,
    this.navigationIconSize,
    this.triggerIconSize,
    this.triggerBorderRadius,
    this.triggerHorizontalPadding,
    this.triggerIconGap,
    this.sectionGap,
    this.footerGap,
    this.cellGap,
    this.actionHorizontalPadding,
    this.headerTextStyle,
    this.weekdayTextStyle,
    this.cellTextStyle,
    this.actionTextStyle,
    this.triggerTextStyle,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.warningColor,
    this.headerTextColor,
    this.weekdayTextColor,
    this.cellTextColor,
    this.outsideMonthTextColor,
    this.selectedBackgroundColor,
    this.rangeBackgroundColor,
    this.rangeTextColor,
    this.monthBorderColor,
    this.todayTextColor,
    this.clearTextColor,
    this.triggerBackgroundColor,
    this.triggerTextColor,
    this.placeholderTextColor,
    this.triggerIconColor,
    this.triggerClearButtonPadding,
    this.triggerClearButtonBorderRadius,
    this.triggerClearButtonBackgroundColor,
  }) {
    AnimalStyleValues.checkDimension('width', width);
    // Resolving covers start/end insets as well as left/right ones.
    final EdgeInsets? insets = padding?.resolve(TextDirection.ltr);
    if (insets != null) {
      AnimalStyleValues.checkDimension('padding.left', insets.left);
      AnimalStyleValues.checkDimension('padding.top', insets.top);
      AnimalStyleValues.checkDimension('padding.right', insets.right);
      AnimalStyleValues.checkDimension('padding.bottom', insets.bottom);
    }
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkDimension('cellInset', cellInset);
    AnimalStyleValues.checkDimension('monthBorderWidth', monthBorderWidth);
    AnimalStyleValues.checkDimension('navigationIconSize', navigationIconSize);
    AnimalStyleValues.checkDimension('triggerIconSize', triggerIconSize);
    AnimalStyleValues.checkDimension(
      'triggerHorizontalPadding',
      triggerHorizontalPadding,
    );
    AnimalStyleValues.checkDimension('triggerIconGap', triggerIconGap);
    AnimalStyleValues.checkDimension('sectionGap', sectionGap);
    AnimalStyleValues.checkDimension('footerGap', footerGap);
    AnimalStyleValues.checkDimension('cellGap', cellGap);
    AnimalStyleValues.checkDimension(
      'actionHorizontalPadding',
      actionHorizontalPadding,
    );
    AnimalStyleValues.checkTextStyle('headerTextStyle', headerTextStyle);
    AnimalStyleValues.checkTextStyle('weekdayTextStyle', weekdayTextStyle);
    AnimalStyleValues.checkTextStyle('cellTextStyle', cellTextStyle);
    AnimalStyleValues.checkTextStyle('actionTextStyle', actionTextStyle);
    AnimalStyleValues.checkTextStyle('triggerTextStyle', triggerTextStyle);
  }

  AnimalDatePickerStyle copyWith({
    double? width,
    EdgeInsetsGeometry? padding,
    double? borderWidth,
    BorderRadius? borderRadius,
    double? cellInset,
    BorderRadius? rangeBorderRadius,
    double? monthBorderWidth,
    BorderRadius? monthBorderRadius,
    double? navigationIconSize,
    double? triggerIconSize,
    BorderRadius? triggerBorderRadius,
    double? triggerHorizontalPadding,
    double? triggerIconGap,
    double? sectionGap,
    double? footerGap,
    double? cellGap,
    double? actionHorizontalPadding,
    TextStyle? headerTextStyle,
    TextStyle? weekdayTextStyle,
    TextStyle? cellTextStyle,
    TextStyle? actionTextStyle,
    TextStyle? triggerTextStyle,
    Color? backgroundColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? glowColor,
    Color? warningColor,
    WidgetStateProperty<Color?>? headerTextColor,
    Color? weekdayTextColor,
    WidgetStateProperty<Color?>? cellTextColor,
    Color? outsideMonthTextColor,
    Color? selectedBackgroundColor,
    Color? rangeBackgroundColor,
    Color? rangeTextColor,
    WidgetStateProperty<Color?>? monthBorderColor,
    WidgetStateProperty<Color?>? todayTextColor,
    WidgetStateProperty<Color?>? clearTextColor,
    WidgetStateProperty<Color?>? triggerBackgroundColor,
    WidgetStateProperty<Color?>? triggerTextColor,
    Color? placeholderTextColor,
    WidgetStateProperty<Color?>? triggerIconColor,
    EdgeInsetsGeometry? triggerClearButtonPadding,
    BorderRadius? triggerClearButtonBorderRadius,
    WidgetStateProperty<Color?>? triggerClearButtonBackgroundColor,
  }) => AnimalDatePickerStyle(
    width: width ?? this.width,
    padding: padding ?? this.padding,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    cellInset: cellInset ?? this.cellInset,
    rangeBorderRadius: rangeBorderRadius ?? this.rangeBorderRadius,
    monthBorderWidth: monthBorderWidth ?? this.monthBorderWidth,
    monthBorderRadius: monthBorderRadius ?? this.monthBorderRadius,
    navigationIconSize: navigationIconSize ?? this.navigationIconSize,
    triggerIconSize: triggerIconSize ?? this.triggerIconSize,
    triggerBorderRadius: triggerBorderRadius ?? this.triggerBorderRadius,
    triggerHorizontalPadding:
        triggerHorizontalPadding ?? this.triggerHorizontalPadding,
    triggerIconGap: triggerIconGap ?? this.triggerIconGap,
    sectionGap: sectionGap ?? this.sectionGap,
    footerGap: footerGap ?? this.footerGap,
    cellGap: cellGap ?? this.cellGap,
    actionHorizontalPadding:
        actionHorizontalPadding ?? this.actionHorizontalPadding,
    headerTextStyle: headerTextStyle ?? this.headerTextStyle,
    weekdayTextStyle: weekdayTextStyle ?? this.weekdayTextStyle,
    cellTextStyle: cellTextStyle ?? this.cellTextStyle,
    actionTextStyle: actionTextStyle ?? this.actionTextStyle,
    triggerTextStyle: triggerTextStyle ?? this.triggerTextStyle,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    glowColor: glowColor ?? this.glowColor,
    warningColor: warningColor ?? this.warningColor,
    headerTextColor: headerTextColor ?? this.headerTextColor,
    weekdayTextColor: weekdayTextColor ?? this.weekdayTextColor,
    cellTextColor: cellTextColor ?? this.cellTextColor,
    outsideMonthTextColor: outsideMonthTextColor ?? this.outsideMonthTextColor,
    selectedBackgroundColor:
        selectedBackgroundColor ?? this.selectedBackgroundColor,
    rangeBackgroundColor: rangeBackgroundColor ?? this.rangeBackgroundColor,
    rangeTextColor: rangeTextColor ?? this.rangeTextColor,
    monthBorderColor: monthBorderColor ?? this.monthBorderColor,
    todayTextColor: todayTextColor ?? this.todayTextColor,
    clearTextColor: clearTextColor ?? this.clearTextColor,
    triggerBackgroundColor:
        triggerBackgroundColor ?? this.triggerBackgroundColor,
    triggerTextColor: triggerTextColor ?? this.triggerTextColor,
    placeholderTextColor: placeholderTextColor ?? this.placeholderTextColor,
    triggerIconColor: triggerIconColor ?? this.triggerIconColor,
    triggerClearButtonPadding:
        triggerClearButtonPadding ?? this.triggerClearButtonPadding,
    triggerClearButtonBorderRadius:
        triggerClearButtonBorderRadius ?? this.triggerClearButtonBorderRadius,
    triggerClearButtonBackgroundColor:
        triggerClearButtonBackgroundColor ??
        this.triggerClearButtonBackgroundColor,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalDatePickerStyle merge(AnimalDatePickerStyle? other) {
    if (other == null) return this;
    return AnimalDatePickerStyle(
      width: width ?? other.width,
      padding: padding ?? other.padding,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      cellInset: cellInset ?? other.cellInset,
      rangeBorderRadius: rangeBorderRadius ?? other.rangeBorderRadius,
      monthBorderWidth: monthBorderWidth ?? other.monthBorderWidth,
      monthBorderRadius: monthBorderRadius ?? other.monthBorderRadius,
      navigationIconSize: navigationIconSize ?? other.navigationIconSize,
      triggerIconSize: triggerIconSize ?? other.triggerIconSize,
      triggerBorderRadius: triggerBorderRadius ?? other.triggerBorderRadius,
      triggerHorizontalPadding:
          triggerHorizontalPadding ?? other.triggerHorizontalPadding,
      triggerIconGap: triggerIconGap ?? other.triggerIconGap,
      sectionGap: sectionGap ?? other.sectionGap,
      footerGap: footerGap ?? other.footerGap,
      cellGap: cellGap ?? other.cellGap,
      actionHorizontalPadding:
          actionHorizontalPadding ?? other.actionHorizontalPadding,
      headerTextStyle:
          other.headerTextStyle?.merge(headerTextStyle) ?? headerTextStyle,
      weekdayTextStyle:
          other.weekdayTextStyle?.merge(weekdayTextStyle) ?? weekdayTextStyle,
      cellTextStyle: other.cellTextStyle?.merge(cellTextStyle) ?? cellTextStyle,
      actionTextStyle:
          other.actionTextStyle?.merge(actionTextStyle) ?? actionTextStyle,
      triggerTextStyle:
          other.triggerTextStyle?.merge(triggerTextStyle) ?? triggerTextStyle,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      glowColor: glowColor ?? other.glowColor,
      warningColor: warningColor ?? other.warningColor,
      headerTextColor: headerTextColor ?? other.headerTextColor,
      weekdayTextColor: weekdayTextColor ?? other.weekdayTextColor,
      cellTextColor: cellTextColor ?? other.cellTextColor,
      outsideMonthTextColor:
          outsideMonthTextColor ?? other.outsideMonthTextColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? other.selectedBackgroundColor,
      rangeBackgroundColor: rangeBackgroundColor ?? other.rangeBackgroundColor,
      rangeTextColor: rangeTextColor ?? other.rangeTextColor,
      monthBorderColor: monthBorderColor ?? other.monthBorderColor,
      todayTextColor: todayTextColor ?? other.todayTextColor,
      clearTextColor: clearTextColor ?? other.clearTextColor,
      triggerBackgroundColor:
          triggerBackgroundColor ?? other.triggerBackgroundColor,
      triggerTextColor: triggerTextColor ?? other.triggerTextColor,
      placeholderTextColor: placeholderTextColor ?? other.placeholderTextColor,
      triggerIconColor: triggerIconColor ?? other.triggerIconColor,
      triggerClearButtonPadding:
          triggerClearButtonPadding ?? other.triggerClearButtonPadding,
      triggerClearButtonBorderRadius:
          triggerClearButtonBorderRadius ??
          other.triggerClearButtonBorderRadius,
      triggerClearButtonBackgroundColor:
          triggerClearButtonBackgroundColor ??
          other.triggerClearButtonBackgroundColor,
    );
  }

  static AnimalDatePickerStyle? lerp(
    AnimalDatePickerStyle? a,
    AnimalDatePickerStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    double? dimension(double? x, double? y) =>
        AnimalStyleValues.lerpDimension(x, y, t);
    BorderRadius? radius(BorderRadius? x, BorderRadius? y) =>
        AnimalStyleValues.lerpRadius(x, y, t);
    TextStyle? text(TextStyle? x, TextStyle? y) =>
        AnimalStyleValues.lerpTextStyle(x, y, t);
    WidgetStateProperty<Color?>? colors(
      WidgetStateProperty<Color?>? x,
      WidgetStateProperty<Color?>? y,
    ) => AnimalStyleValues.lerpColors(x, y, t);
    Color? color(Color? x, Color? y) => AnimalStyleValues.lerpColor(x, y, t);
    return AnimalDatePickerStyle(
      width: dimension(a?.width, b?.width),
      padding: AnimalStyleValues.lerpInsets(a?.padding, b?.padding, t),
      borderWidth: dimension(a?.borderWidth, b?.borderWidth),
      borderRadius: radius(a?.borderRadius, b?.borderRadius),
      cellInset: dimension(a?.cellInset, b?.cellInset),
      rangeBorderRadius: radius(a?.rangeBorderRadius, b?.rangeBorderRadius),
      monthBorderWidth: dimension(a?.monthBorderWidth, b?.monthBorderWidth),
      monthBorderRadius: radius(a?.monthBorderRadius, b?.monthBorderRadius),
      navigationIconSize: dimension(
        a?.navigationIconSize,
        b?.navigationIconSize,
      ),
      triggerIconSize: dimension(a?.triggerIconSize, b?.triggerIconSize),
      triggerBorderRadius: radius(
        a?.triggerBorderRadius,
        b?.triggerBorderRadius,
      ),
      triggerHorizontalPadding: dimension(
        a?.triggerHorizontalPadding,
        b?.triggerHorizontalPadding,
      ),
      triggerIconGap: dimension(a?.triggerIconGap, b?.triggerIconGap),
      sectionGap: dimension(a?.sectionGap, b?.sectionGap),
      footerGap: dimension(a?.footerGap, b?.footerGap),
      cellGap: dimension(a?.cellGap, b?.cellGap),
      actionHorizontalPadding: dimension(
        a?.actionHorizontalPadding,
        b?.actionHorizontalPadding,
      ),
      headerTextStyle: text(a?.headerTextStyle, b?.headerTextStyle),
      weekdayTextStyle: text(a?.weekdayTextStyle, b?.weekdayTextStyle),
      cellTextStyle: text(a?.cellTextStyle, b?.cellTextStyle),
      actionTextStyle: text(a?.actionTextStyle, b?.actionTextStyle),
      triggerTextStyle: text(a?.triggerTextStyle, b?.triggerTextStyle),
      backgroundColor: color(a?.backgroundColor, b?.backgroundColor),
      borderColor: colors(a?.borderColor, b?.borderColor),
      glowColor: colors(a?.glowColor, b?.glowColor),
      warningColor: color(a?.warningColor, b?.warningColor),
      headerTextColor: colors(a?.headerTextColor, b?.headerTextColor),
      weekdayTextColor: color(a?.weekdayTextColor, b?.weekdayTextColor),
      cellTextColor: colors(a?.cellTextColor, b?.cellTextColor),
      outsideMonthTextColor: color(
        a?.outsideMonthTextColor,
        b?.outsideMonthTextColor,
      ),
      selectedBackgroundColor: color(
        a?.selectedBackgroundColor,
        b?.selectedBackgroundColor,
      ),
      rangeBackgroundColor: color(
        a?.rangeBackgroundColor,
        b?.rangeBackgroundColor,
      ),
      rangeTextColor: color(a?.rangeTextColor, b?.rangeTextColor),
      monthBorderColor: colors(a?.monthBorderColor, b?.monthBorderColor),
      todayTextColor: colors(a?.todayTextColor, b?.todayTextColor),
      clearTextColor: colors(a?.clearTextColor, b?.clearTextColor),
      triggerBackgroundColor: colors(
        a?.triggerBackgroundColor,
        b?.triggerBackgroundColor,
      ),
      triggerTextColor: colors(a?.triggerTextColor, b?.triggerTextColor),
      placeholderTextColor: color(
        a?.placeholderTextColor,
        b?.placeholderTextColor,
      ),
      triggerIconColor: colors(a?.triggerIconColor, b?.triggerIconColor),
      triggerClearButtonPadding: AnimalStyleValues.lerpInsets(
        a?.triggerClearButtonPadding,
        b?.triggerClearButtonPadding,
        t,
      ),
      triggerClearButtonBorderRadius: radius(
        a?.triggerClearButtonBorderRadius,
        b?.triggerClearButtonBorderRadius,
      ),
      triggerClearButtonBackgroundColor: colors(
        a?.triggerClearButtonBackgroundColor,
        b?.triggerClearButtonBackgroundColor,
      ),
    );
  }

  List<Object?> get _props => <Object?>[
    width,
    padding,
    borderWidth,
    borderRadius,
    cellInset,
    rangeBorderRadius,
    monthBorderWidth,
    monthBorderRadius,
    navigationIconSize,
    triggerIconSize,
    triggerBorderRadius,
    triggerHorizontalPadding,
    triggerIconGap,
    sectionGap,
    footerGap,
    cellGap,
    actionHorizontalPadding,
    headerTextStyle,
    weekdayTextStyle,
    cellTextStyle,
    actionTextStyle,
    triggerTextStyle,
    backgroundColor,
    borderColor,
    glowColor,
    warningColor,
    headerTextColor,
    weekdayTextColor,
    cellTextColor,
    outsideMonthTextColor,
    selectedBackgroundColor,
    rangeBackgroundColor,
    rangeTextColor,
    monthBorderColor,
    todayTextColor,
    clearTextColor,
    triggerBackgroundColor,
    triggerTextColor,
    placeholderTextColor,
    triggerIconColor,
    triggerClearButtonPadding,
    triggerClearButtonBorderRadius,
    triggerClearButtonBackgroundColor,
  ];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimalDatePickerStyle) return false;
    final List<Object?> mine = _props;
    final List<Object?> theirs = other._props;
    for (var i = 0; i < mine.length; i++) {
      if (mine[i] != theirs[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(_props);
}
