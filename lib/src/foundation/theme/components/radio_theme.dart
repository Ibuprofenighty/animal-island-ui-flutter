import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalRadio` and `AnimalRadioGroup`.
///
/// The same type customizes one radio through its `style` parameter and
/// every radio through [AnimalRadioThemeData]. Each field is optional; a
/// null field falls through to the next layer and finally to a default derived
/// from the active theme tokens.
///
/// Color properties resolve against [WidgetState.selected],
/// [WidgetState.disabled] and [WidgetState.focused].
@immutable
class AnimalRadioStyle {
  /// Edge length of the radio control.
  final double? boxSize;

  /// Size of the selected check glyph.
  final double? iconSize;

  /// Border stroke of the radio control.
  final double? borderWidth;

  /// Gap between the radio control and the label.
  final double? labelGap;

  /// Gap between items of a group along its direction.
  final double? groupGap;

  /// Gap between wrapped runs of a group.
  final double? groupRunGap;

  /// Corner radius of the radio control.
  final BorderRadius? borderRadius;

  /// Style of the label. Its color is resolved from [labelTextColor].
  final TextStyle? labelTextStyle;

  final WidgetStateProperty<Color?>? fillColor;
  final WidgetStateProperty<Color?>? borderColor;

  /// Color of the selected check glyph.
  final WidgetStateProperty<Color?>? checkColor;

  final WidgetStateProperty<Color?>? labelTextColor;

  /// Elevation shadow of an enabled radio control.
  final BoxShadow? shadow;

  AnimalRadioStyle({
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

  AnimalRadioStyle copyWith({
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
  }) => AnimalRadioStyle(
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
  AnimalRadioStyle merge(AnimalRadioStyle? other) {
    if (other == null) return this;
    return AnimalRadioStyle(
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

  static AnimalRadioStyle? lerp(
    AnimalRadioStyle? a,
    AnimalRadioStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalRadioStyle(
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
      other is AnimalRadioStyle &&
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

/// Theme-wide AnimalRadio overrides.
///
/// [style] applies to every size; a size-specific style takes precedence over
/// it. A component's own `style` parameter takes precedence over both.
@immutable
class AnimalRadioThemeData {
  final AnimalRadioStyle? style;
  final AnimalRadioStyle? smallStyle;
  final AnimalRadioStyle? middleStyle;
  final AnimalRadioStyle? largeStyle;

  const AnimalRadioThemeData({
    this.style,
    this.smallStyle,
    this.middleStyle,
    this.largeStyle,
  });

  AnimalRadioThemeData copyWith({
    AnimalRadioStyle? style,
    AnimalRadioStyle? smallStyle,
    AnimalRadioStyle? middleStyle,
    AnimalRadioStyle? largeStyle,
  }) => AnimalRadioThemeData(
    style: style ?? this.style,
    smallStyle: smallStyle ?? this.smallStyle,
    middleStyle: middleStyle ?? this.middleStyle,
    largeStyle: largeStyle ?? this.largeStyle,
  );

  static AnimalRadioThemeData? lerp(
    AnimalRadioThemeData? a,
    AnimalRadioThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalRadioThemeData(
      style: AnimalRadioStyle.lerp(a?.style, b?.style, t),
      smallStyle: AnimalRadioStyle.lerp(a?.smallStyle, b?.smallStyle, t),
      middleStyle: AnimalRadioStyle.lerp(a?.middleStyle, b?.middleStyle, t),
      largeStyle: AnimalRadioStyle.lerp(a?.largeStyle, b?.largeStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalRadioThemeData &&
          style == other.style &&
          smallStyle == other.smallStyle &&
          middleStyle == other.middleStyle &&
          largeStyle == other.largeStyle;

  @override
  int get hashCode => Object.hash(style, smallStyle, middleStyle, largeStyle);
}
