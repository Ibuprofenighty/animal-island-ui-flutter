import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for AnimalTable.
/// Instance fields take precedence over the matching component theme and tokens.
@immutable
class AnimalTableStyle {
  /// Table fill.
  final Color? backgroundColor;

  /// Header fill.
  final Color? headerBackgroundColor;

  /// Even row fill.
  final Color? evenRowBackgroundColor;

  /// Odd row fill.
  final Color? oddRowBackgroundColor;

  /// Table outline.
  final Color? borderColor;

  /// Table outline width.
  final double? borderWidth;

  /// Table corners.
  final BorderRadius? borderRadius;

  /// Row separator color.
  final Color? dividerColor;

  /// Row separator width.
  final double? dividerThickness;

  /// Shared header and body row insets.
  final EdgeInsetsGeometry? rowPadding;

  /// Minimum row height; rows grow to fit content.
  final double? minRowHeight;

  /// Minimum width per flex unit.
  final double? flexMinWidth;

  /// Header typography.
  final TextStyle? headerTextStyle;

  /// Body typography.
  final TextStyle? textStyle;

  /// Header foreground.
  final Color? headerTextColor;

  /// Body foreground.
  final Color? textColor;

  /// Empty label typography.
  final TextStyle? emptyTextStyle;

  /// Empty label and illustration foreground.
  final Color? emptyTextColor;

  /// Empty content insets.
  final EdgeInsetsGeometry? emptyPadding;

  /// Empty illustration size.
  final double? emptyIconSize;

  /// Space after the empty illustration.
  final double? emptyIconGap;

  /// Loading indicator size.
  final double? loadingSize;

  /// Creates overrides; null fields inherit the lower layer.
  /// Invalid dimensions, insets, radii, font sizes throw ArgumentError.
  AnimalTableStyle({
    this.backgroundColor,
    this.headerBackgroundColor,
    this.evenRowBackgroundColor,
    this.oddRowBackgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.dividerColor,
    this.dividerThickness,
    this.rowPadding,
    this.minRowHeight,
    this.flexMinWidth,
    this.headerTextStyle,
    this.textStyle,
    this.headerTextColor,
    this.textColor,
    this.emptyTextStyle,
    this.emptyTextColor,
    this.emptyPadding,
    this.emptyIconSize,
    this.emptyIconGap,
    this.loadingSize,
  }) {
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkDimension('dividerThickness', dividerThickness);
    AnimalStyleValues.checkInsets('rowPadding', rowPadding);
    AnimalStyleValues.checkDimension(
      'minRowHeight',
      minRowHeight,
      minimum: double.minPositive,
    );
    AnimalStyleValues.checkDimension(
      'flexMinWidth',
      flexMinWidth,
      minimum: double.minPositive,
    );
    AnimalStyleValues.checkTextStyle('headerTextStyle', headerTextStyle);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkTextStyle('emptyTextStyle', emptyTextStyle);
    AnimalStyleValues.checkInsets('emptyPadding', emptyPadding);
    AnimalStyleValues.checkDimension('emptyIconSize', emptyIconSize);
    AnimalStyleValues.checkDimension('emptyIconGap', emptyIconGap);
    AnimalStyleValues.checkDimension('loadingSize', loadingSize);
  }

  /// Returns a copy with the given fields replaced.
  AnimalTableStyle copyWith({
    Color? backgroundColor,
    Color? headerBackgroundColor,
    Color? evenRowBackgroundColor,
    Color? oddRowBackgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    Color? dividerColor,
    double? dividerThickness,
    EdgeInsetsGeometry? rowPadding,
    double? minRowHeight,
    double? flexMinWidth,
    TextStyle? headerTextStyle,
    TextStyle? textStyle,
    Color? headerTextColor,
    Color? textColor,
    TextStyle? emptyTextStyle,
    Color? emptyTextColor,
    EdgeInsetsGeometry? emptyPadding,
    double? emptyIconSize,
    double? emptyIconGap,
    double? loadingSize,
  }) => AnimalTableStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    headerBackgroundColor: headerBackgroundColor ?? this.headerBackgroundColor,
    evenRowBackgroundColor:
        evenRowBackgroundColor ?? this.evenRowBackgroundColor,
    oddRowBackgroundColor: oddRowBackgroundColor ?? this.oddRowBackgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    dividerColor: dividerColor ?? this.dividerColor,
    dividerThickness: dividerThickness ?? this.dividerThickness,
    rowPadding: rowPadding ?? this.rowPadding,
    minRowHeight: minRowHeight ?? this.minRowHeight,
    flexMinWidth: flexMinWidth ?? this.flexMinWidth,
    headerTextStyle: headerTextStyle ?? this.headerTextStyle,
    textStyle: textStyle ?? this.textStyle,
    headerTextColor: headerTextColor ?? this.headerTextColor,
    textColor: textColor ?? this.textColor,
    emptyTextStyle: emptyTextStyle ?? this.emptyTextStyle,
    emptyTextColor: emptyTextColor ?? this.emptyTextColor,
    emptyPadding: emptyPadding ?? this.emptyPadding,
    emptyIconSize: emptyIconSize ?? this.emptyIconSize,
    emptyIconGap: emptyIconGap ?? this.emptyIconGap,
    loadingSize: loadingSize ?? this.loadingSize,
  );

  /// Fills absent fields from [other]; text styles merge field by field.
  AnimalTableStyle merge(AnimalTableStyle? other) {
    if (other == null) return this;
    return AnimalTableStyle(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      headerBackgroundColor:
          headerBackgroundColor ?? other.headerBackgroundColor,
      evenRowBackgroundColor:
          evenRowBackgroundColor ?? other.evenRowBackgroundColor,
      oddRowBackgroundColor:
          oddRowBackgroundColor ?? other.oddRowBackgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      dividerColor: dividerColor ?? other.dividerColor,
      dividerThickness: dividerThickness ?? other.dividerThickness,
      rowPadding: rowPadding ?? other.rowPadding,
      minRowHeight: minRowHeight ?? other.minRowHeight,
      flexMinWidth: flexMinWidth ?? other.flexMinWidth,
      headerTextStyle:
          other.headerTextStyle?.merge(headerTextStyle) ?? headerTextStyle,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      headerTextColor: headerTextColor ?? other.headerTextColor,
      textColor: textColor ?? other.textColor,
      emptyTextStyle:
          other.emptyTextStyle?.merge(emptyTextStyle) ?? emptyTextStyle,
      emptyTextColor: emptyTextColor ?? other.emptyTextColor,
      emptyPadding: emptyPadding ?? other.emptyPadding,
      emptyIconSize: emptyIconSize ?? other.emptyIconSize,
      emptyIconGap: emptyIconGap ?? other.emptyIconGap,
      loadingSize: loadingSize ?? other.loadingSize,
    );
  }

  /// Interpolates fields within the endpoints; absent fields switch at halfway.
  static AnimalTableStyle? lerp(
    AnimalTableStyle? a,
    AnimalTableStyle? b,
    double t,
  ) {
    t = t.clamp(0.0, 1.0);
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalTableStyle(
      backgroundColor: AnimalStyleValues.lerpColor(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
      ),
      headerBackgroundColor: AnimalStyleValues.lerpColor(
        a?.headerBackgroundColor,
        b?.headerBackgroundColor,
        t,
      ),
      evenRowBackgroundColor: AnimalStyleValues.lerpColor(
        a?.evenRowBackgroundColor,
        b?.evenRowBackgroundColor,
        t,
      ),
      oddRowBackgroundColor: AnimalStyleValues.lerpColor(
        a?.oddRowBackgroundColor,
        b?.oddRowBackgroundColor,
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
      rowPadding: AnimalStyleValues.lerpInsets(a?.rowPadding, b?.rowPadding, t),
      minRowHeight: AnimalStyleValues.lerpDimension(
        a?.minRowHeight,
        b?.minRowHeight,
        t,
      ),
      flexMinWidth: AnimalStyleValues.lerpDimension(
        a?.flexMinWidth,
        b?.flexMinWidth,
        t,
      ),
      headerTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.headerTextStyle,
        b?.headerTextStyle,
        t,
      ),
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      headerTextColor: AnimalStyleValues.lerpColor(
        a?.headerTextColor,
        b?.headerTextColor,
        t,
      ),
      textColor: AnimalStyleValues.lerpColor(a?.textColor, b?.textColor, t),
      emptyTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.emptyTextStyle,
        b?.emptyTextStyle,
        t,
      ),
      emptyTextColor: AnimalStyleValues.lerpColor(
        a?.emptyTextColor,
        b?.emptyTextColor,
        t,
      ),
      emptyPadding: AnimalStyleValues.lerpInsets(
        a?.emptyPadding,
        b?.emptyPadding,
        t,
      ),
      emptyIconSize: AnimalStyleValues.lerpDimension(
        a?.emptyIconSize,
        b?.emptyIconSize,
        t,
      ),
      emptyIconGap: AnimalStyleValues.lerpDimension(
        a?.emptyIconGap,
        b?.emptyIconGap,
        t,
      ),
      loadingSize: AnimalStyleValues.lerpDimension(
        a?.loadingSize,
        b?.loadingSize,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTableStyle &&
          backgroundColor == other.backgroundColor &&
          headerBackgroundColor == other.headerBackgroundColor &&
          evenRowBackgroundColor == other.evenRowBackgroundColor &&
          oddRowBackgroundColor == other.oddRowBackgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          dividerColor == other.dividerColor &&
          dividerThickness == other.dividerThickness &&
          rowPadding == other.rowPadding &&
          minRowHeight == other.minRowHeight &&
          flexMinWidth == other.flexMinWidth &&
          headerTextStyle == other.headerTextStyle &&
          textStyle == other.textStyle &&
          headerTextColor == other.headerTextColor &&
          textColor == other.textColor &&
          emptyTextStyle == other.emptyTextStyle &&
          emptyTextColor == other.emptyTextColor &&
          emptyPadding == other.emptyPadding &&
          emptyIconSize == other.emptyIconSize &&
          emptyIconGap == other.emptyIconGap &&
          loadingSize == other.loadingSize;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    headerBackgroundColor,
    evenRowBackgroundColor,
    oddRowBackgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    dividerColor,
    dividerThickness,
    rowPadding,
    minRowHeight,
    flexMinWidth,
    headerTextStyle,
    textStyle,
    headerTextColor,
    textColor,
    emptyTextStyle,
    emptyTextColor,
    emptyPadding,
    emptyIconSize,
    emptyIconGap,
    loadingSize,
  ]);
}
