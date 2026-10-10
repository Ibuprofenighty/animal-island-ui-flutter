import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for AnimalCollapse.
/// Instance fields take precedence over the matching component theme and tokens.
@immutable
class AnimalCollapseStyle {
  /// Card fill.
  final Color? backgroundColor;

  /// Card outline.
  final Color? borderColor;

  /// Card outline width.
  final double? borderWidth;

  /// Card corners.
  final BorderRadius? borderRadius;

  /// Card elevation.
  final BoxShadow? shadow;

  /// Header insets.
  final EdgeInsetsGeometry? headerPadding;

  /// Expanded content insets.
  final EdgeInsetsGeometry? contentPadding;

  /// Space between cards.
  final double? gap;

  /// Space before the disclosure icon.
  final double? iconGap;

  /// Disclosure icon size.
  final double? iconSize;

  /// Disclosure icon color.
  final Color? iconColor;

  /// Header fill by interaction state.
  final WidgetStateProperty<Color?>? headerBackgroundColor;

  /// Header and content typography.
  final TextStyle? textStyle;

  /// Header foreground by interaction state.
  final WidgetStateProperty<Color?>? textColor;

  /// Expanded content fill.
  final Color? contentBackgroundColor;

  /// Expanded content foreground.
  final Color? contentTextColor;

  /// Expansion transition duration.
  final Duration? duration;

  /// Expansion transition curve.
  final Curve? curve;

  /// Creates overrides; null fields inherit the lower layer.
  /// Invalid dimensions, insets, radii, font sizes and durations throw ArgumentError.
  AnimalCollapseStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.shadow,
    this.headerPadding,
    this.contentPadding,
    this.gap,
    this.iconGap,
    this.iconSize,
    this.iconColor,
    this.headerBackgroundColor,
    this.textStyle,
    this.textColor,
    this.contentBackgroundColor,
    this.contentTextColor,
    this.duration,
    this.curve,
  }) {
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkInsets('headerPadding', headerPadding);
    AnimalStyleValues.checkInsets('contentPadding', contentPadding);
    AnimalStyleValues.checkDimension('gap', gap);
    AnimalStyleValues.checkDimension('iconGap', iconGap);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    if (duration != null && duration! < Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be non-negative');
    }
  }

  /// Returns a copy with the given fields replaced.
  AnimalCollapseStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BoxShadow? shadow,
    EdgeInsetsGeometry? headerPadding,
    EdgeInsetsGeometry? contentPadding,
    double? gap,
    double? iconGap,
    double? iconSize,
    Color? iconColor,
    WidgetStateProperty<Color?>? headerBackgroundColor,
    TextStyle? textStyle,
    WidgetStateProperty<Color?>? textColor,
    Color? contentBackgroundColor,
    Color? contentTextColor,
    Duration? duration,
    Curve? curve,
  }) => AnimalCollapseStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    shadow: shadow ?? this.shadow,
    headerPadding: headerPadding ?? this.headerPadding,
    contentPadding: contentPadding ?? this.contentPadding,
    gap: gap ?? this.gap,
    iconGap: iconGap ?? this.iconGap,
    iconSize: iconSize ?? this.iconSize,
    iconColor: iconColor ?? this.iconColor,
    headerBackgroundColor: headerBackgroundColor ?? this.headerBackgroundColor,
    textStyle: textStyle ?? this.textStyle,
    textColor: textColor ?? this.textColor,
    contentBackgroundColor:
        contentBackgroundColor ?? this.contentBackgroundColor,
    contentTextColor: contentTextColor ?? this.contentTextColor,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );

  /// Fills absent fields from [other]; text styles merge field by field.
  AnimalCollapseStyle merge(AnimalCollapseStyle? other) {
    if (other == null) return this;
    return AnimalCollapseStyle(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      shadow: shadow ?? other.shadow,
      headerPadding: headerPadding ?? other.headerPadding,
      contentPadding: contentPadding ?? other.contentPadding,
      gap: gap ?? other.gap,
      iconGap: iconGap ?? other.iconGap,
      iconSize: iconSize ?? other.iconSize,
      iconColor: iconColor ?? other.iconColor,
      headerBackgroundColor:
          headerBackgroundColor ?? other.headerBackgroundColor,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      textColor: textColor ?? other.textColor,
      contentBackgroundColor:
          contentBackgroundColor ?? other.contentBackgroundColor,
      contentTextColor: contentTextColor ?? other.contentTextColor,
      duration: duration ?? other.duration,
      curve: curve ?? other.curve,
    );
  }

  /// Interpolates fields within the endpoints; absent fields switch at halfway.
  static AnimalCollapseStyle? lerp(
    AnimalCollapseStyle? a,
    AnimalCollapseStyle? b,
    double t,
  ) {
    t = t.clamp(0.0, 1.0);
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalCollapseStyle(
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
      headerPadding: AnimalStyleValues.lerpInsets(
        a?.headerPadding,
        b?.headerPadding,
        t,
      ),
      contentPadding: AnimalStyleValues.lerpInsets(
        a?.contentPadding,
        b?.contentPadding,
        t,
      ),
      gap: AnimalStyleValues.lerpDimension(a?.gap, b?.gap, t),
      iconGap: AnimalStyleValues.lerpDimension(a?.iconGap, b?.iconGap, t),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      iconColor: AnimalStyleValues.lerpColor(a?.iconColor, b?.iconColor, t),
      headerBackgroundColor: AnimalStyleValues.lerpColors(
        a?.headerBackgroundColor,
        b?.headerBackgroundColor,
        t,
      ),
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      textColor: AnimalStyleValues.lerpColors(a?.textColor, b?.textColor, t),
      contentBackgroundColor: AnimalStyleValues.lerpColor(
        a?.contentBackgroundColor,
        b?.contentBackgroundColor,
        t,
      ),
      contentTextColor: AnimalStyleValues.lerpColor(
        a?.contentTextColor,
        b?.contentTextColor,
        t,
      ),
      duration: AnimalStyleValues.lerpDuration(a?.duration, b?.duration, t),
      curve: AnimalStyleValues.snap(a?.curve, b?.curve, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalCollapseStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          shadow == other.shadow &&
          headerPadding == other.headerPadding &&
          contentPadding == other.contentPadding &&
          gap == other.gap &&
          iconGap == other.iconGap &&
          iconSize == other.iconSize &&
          iconColor == other.iconColor &&
          headerBackgroundColor == other.headerBackgroundColor &&
          textStyle == other.textStyle &&
          textColor == other.textColor &&
          contentBackgroundColor == other.contentBackgroundColor &&
          contentTextColor == other.contentTextColor &&
          duration == other.duration &&
          curve == other.curve;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    shadow,
    headerPadding,
    contentPadding,
    gap,
    iconGap,
    iconSize,
    iconColor,
    headerBackgroundColor,
    textStyle,
    textColor,
    contentBackgroundColor,
    contentTextColor,
    duration,
    curve,
  ]);
}
