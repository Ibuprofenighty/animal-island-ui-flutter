import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for AnimalPagination.
/// Instance fields take precedence over the matching component theme and tokens.
@immutable
class AnimalPaginationStyle {
  /// Enabled control fill.
  final Color? backgroundColor;

  /// Current page fill.
  final Color? selectedBackgroundColor;

  /// Disabled control fill.
  final Color? disabledBackgroundColor;

  /// Control corners.
  final BorderRadius? borderRadius;

  /// Control insets.
  final EdgeInsetsGeometry? padding;

  /// Space between controls.
  final double? gap;

  /// Page typography.
  final TextStyle? textStyle;

  /// Ellipsis typography
  final TextStyle? ellipsisTextStyle;

  /// Enabled foreground.
  final Color? textColor;

  /// Ellipsis foreground
  final Color? ellipsisTextColor;

  /// Current page foreground.
  final Color? selectedTextColor;

  /// Disabled foreground.
  final Color? disabledTextColor;

  /// Navigation icon size.
  final double? iconSize;

  /// Raised control elevation.
  final BoxShadow? shadow;

  /// Raised control travel.
  final double? depth;

  /// Creates overrides; null fields inherit the lower layer.
  /// Invalid dimensions, insets, radii, font sizes throw ArgumentError.
  AnimalPaginationStyle({
    this.backgroundColor,
    this.selectedBackgroundColor,
    this.disabledBackgroundColor,
    this.borderRadius,
    this.padding,
    this.gap,
    this.textStyle,
    this.ellipsisTextStyle,
    this.textColor,
    this.ellipsisTextColor,
    this.selectedTextColor,
    this.disabledTextColor,
    this.iconSize,
    this.shadow,
    this.depth,
  }) {
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkInsets('padding', padding);
    AnimalStyleValues.checkDimension('gap', gap);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkDimension('depth', depth);
    AnimalStyleValues.checkTextStyle('ellipsisTextStyle', ellipsisTextStyle);
  }

  /// Returns a copy with the given fields replaced.
  AnimalPaginationStyle copyWith({
    Color? backgroundColor,
    Color? selectedBackgroundColor,
    Color? disabledBackgroundColor,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    double? gap,
    TextStyle? textStyle,
    TextStyle? ellipsisTextStyle,
    Color? textColor,
    Color? ellipsisTextColor,
    Color? selectedTextColor,
    Color? disabledTextColor,
    double? iconSize,
    BoxShadow? shadow,
    double? depth,
  }) => AnimalPaginationStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    selectedBackgroundColor:
        selectedBackgroundColor ?? this.selectedBackgroundColor,
    disabledBackgroundColor:
        disabledBackgroundColor ?? this.disabledBackgroundColor,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    gap: gap ?? this.gap,
    textStyle: textStyle ?? this.textStyle,
    ellipsisTextStyle: ellipsisTextStyle ?? this.ellipsisTextStyle,
    textColor: textColor ?? this.textColor,
    ellipsisTextColor: ellipsisTextColor ?? this.ellipsisTextColor,
    selectedTextColor: selectedTextColor ?? this.selectedTextColor,
    disabledTextColor: disabledTextColor ?? this.disabledTextColor,
    iconSize: iconSize ?? this.iconSize,
    shadow: shadow ?? this.shadow,
    depth: depth ?? this.depth,
  );

  /// Fills absent fields from [other]; text styles merge field by field.
  AnimalPaginationStyle merge(AnimalPaginationStyle? other) {
    if (other == null) return this;
    return AnimalPaginationStyle(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      selectedBackgroundColor:
          selectedBackgroundColor ?? other.selectedBackgroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? other.disabledBackgroundColor,
      borderRadius: borderRadius ?? other.borderRadius,
      padding: padding ?? other.padding,
      gap: gap ?? other.gap,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      ellipsisTextStyle:
          other.ellipsisTextStyle?.merge(ellipsisTextStyle) ??
          ellipsisTextStyle,
      textColor: textColor ?? other.textColor,
      ellipsisTextColor: ellipsisTextColor ?? other.ellipsisTextColor,
      selectedTextColor: selectedTextColor ?? other.selectedTextColor,
      disabledTextColor: disabledTextColor ?? other.disabledTextColor,
      iconSize: iconSize ?? other.iconSize,
      shadow: shadow ?? other.shadow,
      depth: depth ?? other.depth,
    );
  }

  /// Interpolates fields within the endpoints; absent fields switch at halfway.
  static AnimalPaginationStyle? lerp(
    AnimalPaginationStyle? a,
    AnimalPaginationStyle? b,
    double t,
  ) {
    t = t.clamp(0.0, 1.0);
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalPaginationStyle(
      backgroundColor: AnimalStyleValues.lerpColor(
        a?.backgroundColor,
        b?.backgroundColor,
        t,
      ),
      selectedBackgroundColor: AnimalStyleValues.lerpColor(
        a?.selectedBackgroundColor,
        b?.selectedBackgroundColor,
        t,
      ),
      disabledBackgroundColor: AnimalStyleValues.lerpColor(
        a?.disabledBackgroundColor,
        b?.disabledBackgroundColor,
        t,
      ),
      borderRadius: AnimalStyleValues.lerpRadius(
        a?.borderRadius,
        b?.borderRadius,
        t,
      ),
      padding: AnimalStyleValues.lerpInsets(a?.padding, b?.padding, t),
      gap: AnimalStyleValues.lerpDimension(a?.gap, b?.gap, t),
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      ellipsisTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.ellipsisTextStyle,
        b?.ellipsisTextStyle,
        t,
      ),
      textColor: AnimalStyleValues.lerpColor(a?.textColor, b?.textColor, t),
      ellipsisTextColor: AnimalStyleValues.lerpColor(
        a?.ellipsisTextColor,
        b?.ellipsisTextColor,
        t,
      ),
      selectedTextColor: AnimalStyleValues.lerpColor(
        a?.selectedTextColor,
        b?.selectedTextColor,
        t,
      ),
      disabledTextColor: AnimalStyleValues.lerpColor(
        a?.disabledTextColor,
        b?.disabledTextColor,
        t,
      ),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      shadow: AnimalStyleValues.lerpShadow(a?.shadow, b?.shadow, t),
      depth: AnimalStyleValues.lerpDimension(a?.depth, b?.depth, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalPaginationStyle &&
          backgroundColor == other.backgroundColor &&
          selectedBackgroundColor == other.selectedBackgroundColor &&
          disabledBackgroundColor == other.disabledBackgroundColor &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          gap == other.gap &&
          textStyle == other.textStyle &&
          ellipsisTextStyle == other.ellipsisTextStyle &&
          textColor == other.textColor &&
          ellipsisTextColor == other.ellipsisTextColor &&
          selectedTextColor == other.selectedTextColor &&
          disabledTextColor == other.disabledTextColor &&
          iconSize == other.iconSize &&
          shadow == other.shadow &&
          depth == other.depth;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    selectedBackgroundColor,
    disabledBackgroundColor,
    borderRadius,
    padding,
    gap,
    textStyle,
    ellipsisTextStyle,
    textColor,
    ellipsisTextColor,
    selectedTextColor,
    disabledTextColor,
    iconSize,
    shadow,
    depth,
  ]);
}
