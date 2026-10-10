import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for AnimalTabs.
/// Instance fields take precedence over the matching component theme and tokens.
@immutable
class AnimalTabsStyle {
  /// Bar fill.
  final Color? backgroundColor;

  /// Bar outline.
  final Color? borderColor;

  /// Bar outline width.
  final double? borderWidth;

  /// Bar and indicator corners.
  final BorderRadius? borderRadius;

  /// Bar insets.
  final EdgeInsetsGeometry? padding;

  /// Tab insets.
  final EdgeInsetsGeometry? tabPadding;

  /// Space before the label.
  final double? iconGap;

  /// Tab icon size.
  final double? iconSize;

  /// Tab label typography.
  final TextStyle? textStyle;

  /// Label foreground by selection and disabled state.
  final WidgetStateProperty<Color?>? textColor;

  /// Selected pill fill.
  final Color? indicatorColor;

  /// Selected pill elevation.
  final BoxShadow? shadow;

  /// Indicator and scroll transition duration.
  final Duration? duration;

  /// Indicator and scroll transition curve.
  final Curve? curve;

  /// Creates overrides; null fields inherit the lower layer.
  /// Invalid dimensions, insets, radii, font sizes and durations throw ArgumentError.
  AnimalTabsStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.padding,
    this.tabPadding,
    this.iconGap,
    this.iconSize,
    this.textStyle,
    this.textColor,
    this.indicatorColor,
    this.shadow,
    this.duration,
    this.curve,
  }) {
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkInsets('padding', padding);
    AnimalStyleValues.checkInsets('tabPadding', tabPadding);
    AnimalStyleValues.checkDimension('iconGap', iconGap);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    if (duration != null && duration! < Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be non-negative');
    }
  }

  /// Returns a copy with the given fields replaced.
  AnimalTabsStyle copyWith({
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? tabPadding,
    double? iconGap,
    double? iconSize,
    TextStyle? textStyle,
    WidgetStateProperty<Color?>? textColor,
    Color? indicatorColor,
    BoxShadow? shadow,
    Duration? duration,
    Curve? curve,
  }) => AnimalTabsStyle(
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    padding: padding ?? this.padding,
    tabPadding: tabPadding ?? this.tabPadding,
    iconGap: iconGap ?? this.iconGap,
    iconSize: iconSize ?? this.iconSize,
    textStyle: textStyle ?? this.textStyle,
    textColor: textColor ?? this.textColor,
    indicatorColor: indicatorColor ?? this.indicatorColor,
    shadow: shadow ?? this.shadow,
    duration: duration ?? this.duration,
    curve: curve ?? this.curve,
  );

  /// Fills absent fields from [other]; text styles merge field by field.
  AnimalTabsStyle merge(AnimalTabsStyle? other) {
    if (other == null) return this;
    return AnimalTabsStyle(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      padding: padding ?? other.padding,
      tabPadding: tabPadding ?? other.tabPadding,
      iconGap: iconGap ?? other.iconGap,
      iconSize: iconSize ?? other.iconSize,
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      textColor: textColor ?? other.textColor,
      indicatorColor: indicatorColor ?? other.indicatorColor,
      shadow: shadow ?? other.shadow,
      duration: duration ?? other.duration,
      curve: curve ?? other.curve,
    );
  }

  /// Interpolates fields within the endpoints; absent fields switch at halfway.
  static AnimalTabsStyle? lerp(
    AnimalTabsStyle? a,
    AnimalTabsStyle? b,
    double t,
  ) {
    t = t.clamp(0.0, 1.0);
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalTabsStyle(
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
      padding: AnimalStyleValues.lerpInsets(a?.padding, b?.padding, t),
      tabPadding: AnimalStyleValues.lerpInsets(a?.tabPadding, b?.tabPadding, t),
      iconGap: AnimalStyleValues.lerpDimension(a?.iconGap, b?.iconGap, t),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      textColor: AnimalStyleValues.lerpColors(a?.textColor, b?.textColor, t),
      indicatorColor: AnimalStyleValues.lerpColor(
        a?.indicatorColor,
        b?.indicatorColor,
        t,
      ),
      shadow: AnimalStyleValues.lerpShadow(a?.shadow, b?.shadow, t),
      duration: AnimalStyleValues.lerpDuration(a?.duration, b?.duration, t),
      curve: AnimalStyleValues.snap(a?.curve, b?.curve, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTabsStyle &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          tabPadding == other.tabPadding &&
          iconGap == other.iconGap &&
          iconSize == other.iconSize &&
          textStyle == other.textStyle &&
          textColor == other.textColor &&
          indicatorColor == other.indicatorColor &&
          shadow == other.shadow &&
          duration == other.duration &&
          curve == other.curve;

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    padding,
    tabPadding,
    iconGap,
    iconSize,
    textStyle,
    textColor,
    indicatorColor,
    shadow,
    duration,
    curve,
  ]);
}
