import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalCheckbox` and `AnimalCheckboxGroup`.
///
/// The same type customizes one checkbox through its `style` parameter and
/// every checkbox through [AnimalCheckboxThemeData]. Each field is optional; a
/// null field falls through to the next layer and finally to a default derived
/// from the active theme tokens.
///
/// Color properties resolve against [WidgetState.selected] (checked or
/// indeterminate), [WidgetState.disabled] and [WidgetState.focused].
@immutable
class AnimalCheckboxStyle {
  /// Edge length of the square check surface.
  final double? boxSize;

  /// Size of the check glyph; the indeterminate bar is 70% of it.
  final double? iconSize;

  /// Border stroke of the check surface.
  final double? borderWidth;

  /// Gap between the check surface and the label.
  final double? labelGap;

  /// Gap between items of a group along its direction.
  final double? groupGap;

  /// Gap between wrapped runs of a group.
  final double? groupRunGap;

  /// Corner radius of the check surface.
  final BorderRadius? borderRadius;

  /// Style of the label. Its color is resolved from [labelTextColor].
  final TextStyle? labelTextStyle;

  final WidgetStateProperty<Color?>? fillColor;
  final WidgetStateProperty<Color?>? borderColor;

  /// Color of the check glyph and the indeterminate bar.
  final WidgetStateProperty<Color?>? checkColor;

  final WidgetStateProperty<Color?>? labelTextColor;

  /// Elevation shadow of an enabled check surface.
  final BoxShadow? shadow;

  AnimalCheckboxStyle({
    this.boxSize,
    this.iconSize,
    this.borderWidth,
    this.labelGap,
    this.groupGap,
    this.groupRunGap,
    this.borderRadius,
    this.labelTextStyle,
    this.fillColor,
    this.borderColor,
    this.checkColor,
    this.labelTextColor,
    this.shadow,
  }) {
    AnimalStyleValues.checkDimension('boxSize', boxSize);
    AnimalStyleValues.checkDimension('iconSize', iconSize);
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkDimension('labelGap', labelGap);
    AnimalStyleValues.checkDimension('groupGap', groupGap);
    AnimalStyleValues.checkDimension('groupRunGap', groupRunGap);
    AnimalStyleValues.checkTextStyle('labelTextStyle', labelTextStyle);
  }

  AnimalCheckboxStyle copyWith({
    double? boxSize,
    double? iconSize,
    double? borderWidth,
    double? labelGap,
    double? groupGap,
    double? groupRunGap,
    BorderRadius? borderRadius,
    TextStyle? labelTextStyle,
    WidgetStateProperty<Color?>? fillColor,
    WidgetStateProperty<Color?>? borderColor,
    WidgetStateProperty<Color?>? checkColor,
    WidgetStateProperty<Color?>? labelTextColor,
    BoxShadow? shadow,
  }) => AnimalCheckboxStyle(
    boxSize: boxSize ?? this.boxSize,
    iconSize: iconSize ?? this.iconSize,
    borderWidth: borderWidth ?? this.borderWidth,
    labelGap: labelGap ?? this.labelGap,
    groupGap: groupGap ?? this.groupGap,
    groupRunGap: groupRunGap ?? this.groupRunGap,
    borderRadius: borderRadius ?? this.borderRadius,
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    fillColor: fillColor ?? this.fillColor,
    borderColor: borderColor ?? this.borderColor,
    checkColor: checkColor ?? this.checkColor,
    labelTextColor: labelTextColor ?? this.labelTextColor,
    shadow: shadow ?? this.shadow,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font weight and keep the rest of the lower layer's style.
  AnimalCheckboxStyle merge(AnimalCheckboxStyle? other) {
    if (other == null) return this;
    return AnimalCheckboxStyle(
      boxSize: boxSize ?? other.boxSize,
      iconSize: iconSize ?? other.iconSize,
      borderWidth: borderWidth ?? other.borderWidth,
      labelGap: labelGap ?? other.labelGap,
      groupGap: groupGap ?? other.groupGap,
      groupRunGap: groupRunGap ?? other.groupRunGap,
      borderRadius: borderRadius ?? other.borderRadius,
      labelTextStyle:
          other.labelTextStyle?.merge(labelTextStyle) ?? labelTextStyle,
      fillColor: fillColor ?? other.fillColor,
      borderColor: borderColor ?? other.borderColor,
      checkColor: checkColor ?? other.checkColor,
      labelTextColor: labelTextColor ?? other.labelTextColor,
      shadow: shadow ?? other.shadow,
    );
  }

  static AnimalCheckboxStyle? lerp(
    AnimalCheckboxStyle? a,
    AnimalCheckboxStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalCheckboxStyle(
      boxSize: AnimalStyleValues.lerpDimension(a?.boxSize, b?.boxSize, t),
      iconSize: AnimalStyleValues.lerpDimension(a?.iconSize, b?.iconSize, t),
      borderWidth: AnimalStyleValues.lerpDimension(
        a?.borderWidth,
        b?.borderWidth,
        t,
      ),
      labelGap: AnimalStyleValues.lerpDimension(a?.labelGap, b?.labelGap, t),
      groupGap: AnimalStyleValues.lerpDimension(a?.groupGap, b?.groupGap, t),
      groupRunGap: AnimalStyleValues.lerpDimension(
        a?.groupRunGap,
        b?.groupRunGap,
        t,
      ),
      borderRadius: AnimalStyleValues.lerpRadius(
        a?.borderRadius,
        b?.borderRadius,
        t,
      ),
      labelTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
      ),
      fillColor: AnimalStyleValues.lerpColors(a?.fillColor, b?.fillColor, t),
      borderColor: AnimalStyleValues.lerpColors(
        a?.borderColor,
        b?.borderColor,
        t,
      ),
      checkColor: AnimalStyleValues.lerpColors(a?.checkColor, b?.checkColor, t),
      labelTextColor: AnimalStyleValues.lerpColors(
        a?.labelTextColor,
        b?.labelTextColor,
        t,
      ),
      shadow: AnimalStyleValues.lerpShadow(a?.shadow, b?.shadow, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalCheckboxStyle &&
          boxSize == other.boxSize &&
          iconSize == other.iconSize &&
          borderWidth == other.borderWidth &&
          labelGap == other.labelGap &&
          groupGap == other.groupGap &&
          groupRunGap == other.groupRunGap &&
          borderRadius == other.borderRadius &&
          labelTextStyle == other.labelTextStyle &&
          fillColor == other.fillColor &&
          borderColor == other.borderColor &&
          checkColor == other.checkColor &&
          labelTextColor == other.labelTextColor &&
          shadow == other.shadow;

  @override
  int get hashCode => Object.hash(
    boxSize,
    iconSize,
    borderWidth,
    labelGap,
    groupGap,
    groupRunGap,
    borderRadius,
    labelTextStyle,
    fillColor,
    borderColor,
    checkColor,
    labelTextColor,
    shadow,
  );
}

/// Theme-wide AnimalCheckbox overrides.
///
/// [style] applies to every size; a size-specific style takes precedence over
/// it. A component's own `style` parameter takes precedence over both.
@immutable
class AnimalCheckboxThemeData {
  final AnimalCheckboxStyle? style;
  final AnimalCheckboxStyle? smallStyle;
  final AnimalCheckboxStyle? middleStyle;
  final AnimalCheckboxStyle? largeStyle;

  const AnimalCheckboxThemeData({
    this.style,
    this.smallStyle,
    this.middleStyle,
    this.largeStyle,
  });

  AnimalCheckboxThemeData copyWith({
    AnimalCheckboxStyle? style,
    AnimalCheckboxStyle? smallStyle,
    AnimalCheckboxStyle? middleStyle,
    AnimalCheckboxStyle? largeStyle,
  }) => AnimalCheckboxThemeData(
    style: style ?? this.style,
    smallStyle: smallStyle ?? this.smallStyle,
    middleStyle: middleStyle ?? this.middleStyle,
    largeStyle: largeStyle ?? this.largeStyle,
  );

  static AnimalCheckboxThemeData? lerp(
    AnimalCheckboxThemeData? a,
    AnimalCheckboxThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalCheckboxThemeData(
      style: AnimalCheckboxStyle.lerp(a?.style, b?.style, t),
      smallStyle: AnimalCheckboxStyle.lerp(a?.smallStyle, b?.smallStyle, t),
      middleStyle: AnimalCheckboxStyle.lerp(a?.middleStyle, b?.middleStyle, t),
      largeStyle: AnimalCheckboxStyle.lerp(a?.largeStyle, b?.largeStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalCheckboxThemeData &&
          style == other.style &&
          smallStyle == other.smallStyle &&
          middleStyle == other.middleStyle &&
          largeStyle == other.largeStyle;

  @override
  int get hashCode => Object.hash(style, smallStyle, middleStyle, largeStyle);
}
