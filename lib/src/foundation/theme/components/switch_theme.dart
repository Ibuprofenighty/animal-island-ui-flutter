import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalSwitch`.
///
/// The same type customizes one switch through its `style` parameter and every
/// switch through [AnimalSwitchThemeData]. Each field is optional; a null field
/// falls through to the next layer and finally to a default derived from the
/// active theme tokens.
///
/// Color properties resolve against [WidgetState.selected] (the switch is on)
/// and [WidgetState.disabled] (disabled, loading, or without a callback outside
/// read-only mode).
@immutable
class AnimalSwitchStyle {
  /// Minimum track width; labels may widen the track beyond it.
  final double? width;

  /// Minimum track height; wrapped labels may grow the track beyond it.
  final double? height;

  /// Thumb diameter. The thumb inset at either end of the track is half the
  /// difference between [height] and [thumbSize].
  final double? thumbSize;

  /// Gap between the thumb rail and an in-track label.
  final double? labelGap;

  /// Stroke width of the track border.
  final double? trackBorderWidth;

  /// Stroke width of the thumb border.
  final double? thumbBorderWidth;

  /// Stroke width of the focus outline drawn around the track.
  final double? focusBorderWidth;

  /// Stroke width of the loading indicator inside the thumb.
  final double? loadingStrokeWidth;

  /// Corner radius of the track and its focus outline.
  final BorderRadius? borderRadius;

  /// Style of the in-track labels. Its color is resolved from [labelTextColor].
  final TextStyle? labelTextStyle;

  /// Fill of the track.
  final WidgetStateProperty<Color?>? trackColor;

  /// Border color of the track.
  final WidgetStateProperty<Color?>? trackBorderColor;

  /// Fill of the thumb.
  final WidgetStateProperty<Color?>? thumbColor;

  /// Border color of the thumb.
  final WidgetStateProperty<Color?>? thumbBorderColor;

  /// Label color. The checked label resolves with [WidgetState.selected].
  final WidgetStateProperty<Color?>? labelTextColor;

  /// Color of the loading indicator inside the thumb.
  final WidgetStateProperty<Color?>? loadingIndicatorColor;

  /// Shadow painted inside the track, under its border.
  final BoxShadow? trackInsetShadow;

  /// Creates a switch style.
  ///
  /// Throws an [ArgumentError] if a given dimension or corner radius is
  /// negative or not finite, or a given text style has a font size that is not
  /// finite and positive.
  AnimalSwitchStyle({
    this.width,
    this.height,
    this.thumbSize,
    this.labelGap,
    this.trackBorderWidth,
    this.thumbBorderWidth,
    this.focusBorderWidth,
    this.loadingStrokeWidth,
    this.borderRadius,
    this.labelTextStyle,
    this.trackColor,
    this.trackBorderColor,
    this.thumbColor,
    this.thumbBorderColor,
    this.labelTextColor,
    this.loadingIndicatorColor,
    this.trackInsetShadow,
  }) {
    AnimalStyleValues.checkDimension('width', width);
    AnimalStyleValues.checkDimension('height', height);
    AnimalStyleValues.checkDimension('thumbSize', thumbSize);
    AnimalStyleValues.checkDimension('labelGap', labelGap);
    AnimalStyleValues.checkDimension('trackBorderWidth', trackBorderWidth);
    AnimalStyleValues.checkDimension('thumbBorderWidth', thumbBorderWidth);
    AnimalStyleValues.checkDimension('focusBorderWidth', focusBorderWidth);
    AnimalStyleValues.checkDimension('loadingStrokeWidth', loadingStrokeWidth);
    AnimalStyleValues.checkTextStyle('labelTextStyle', labelTextStyle);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalSwitchStyle copyWith({
    double? width,
    double? height,
    double? thumbSize,
    double? labelGap,
    double? trackBorderWidth,
    double? thumbBorderWidth,
    double? focusBorderWidth,
    double? loadingStrokeWidth,
    BorderRadius? borderRadius,
    TextStyle? labelTextStyle,
    WidgetStateProperty<Color?>? trackColor,
    WidgetStateProperty<Color?>? trackBorderColor,
    WidgetStateProperty<Color?>? thumbColor,
    WidgetStateProperty<Color?>? thumbBorderColor,
    WidgetStateProperty<Color?>? labelTextColor,
    WidgetStateProperty<Color?>? loadingIndicatorColor,
    BoxShadow? trackInsetShadow,
  }) => AnimalSwitchStyle(
    width: width ?? this.width,
    height: height ?? this.height,
    thumbSize: thumbSize ?? this.thumbSize,
    labelGap: labelGap ?? this.labelGap,
    trackBorderWidth: trackBorderWidth ?? this.trackBorderWidth,
    thumbBorderWidth: thumbBorderWidth ?? this.thumbBorderWidth,
    focusBorderWidth: focusBorderWidth ?? this.focusBorderWidth,
    loadingStrokeWidth: loadingStrokeWidth ?? this.loadingStrokeWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    trackColor: trackColor ?? this.trackColor,
    trackBorderColor: trackBorderColor ?? this.trackBorderColor,
    thumbColor: thumbColor ?? this.thumbColor,
    thumbBorderColor: thumbBorderColor ?? this.thumbBorderColor,
    labelTextColor: labelTextColor ?? this.labelTextColor,
    loadingIndicatorColor: loadingIndicatorColor ?? this.loadingIndicatorColor,
    trackInsetShadow: trackInsetShadow ?? this.trackInsetShadow,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalSwitchStyle merge(AnimalSwitchStyle? other) {
    if (other == null) return this;
    return AnimalSwitchStyle(
      width: width ?? other.width,
      height: height ?? other.height,
      thumbSize: thumbSize ?? other.thumbSize,
      labelGap: labelGap ?? other.labelGap,
      trackBorderWidth: trackBorderWidth ?? other.trackBorderWidth,
      thumbBorderWidth: thumbBorderWidth ?? other.thumbBorderWidth,
      focusBorderWidth: focusBorderWidth ?? other.focusBorderWidth,
      loadingStrokeWidth: loadingStrokeWidth ?? other.loadingStrokeWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      labelTextStyle:
          other.labelTextStyle?.merge(labelTextStyle) ?? labelTextStyle,
      trackColor: trackColor ?? other.trackColor,
      trackBorderColor: trackBorderColor ?? other.trackBorderColor,
      thumbColor: thumbColor ?? other.thumbColor,
      thumbBorderColor: thumbBorderColor ?? other.thumbBorderColor,
      labelTextColor: labelTextColor ?? other.labelTextColor,
      loadingIndicatorColor:
          loadingIndicatorColor ?? other.loadingIndicatorColor,
      trackInsetShadow: trackInsetShadow ?? other.trackInsetShadow,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalSwitchStyle? lerp(
    AnimalSwitchStyle? a,
    AnimalSwitchStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalSwitchStyle(
      width: AnimalStyleValues.lerpDimension(a?.width, b?.width, t),
      height: AnimalStyleValues.lerpDimension(a?.height, b?.height, t),
      thumbSize: AnimalStyleValues.lerpDimension(a?.thumbSize, b?.thumbSize, t),
      labelGap: AnimalStyleValues.lerpDimension(a?.labelGap, b?.labelGap, t),
      trackBorderWidth: AnimalStyleValues.lerpDimension(
        a?.trackBorderWidth,
        b?.trackBorderWidth,
        t,
      ),
      thumbBorderWidth: AnimalStyleValues.lerpDimension(
        a?.thumbBorderWidth,
        b?.thumbBorderWidth,
        t,
      ),
      focusBorderWidth: AnimalStyleValues.lerpDimension(
        a?.focusBorderWidth,
        b?.focusBorderWidth,
        t,
      ),
      loadingStrokeWidth: AnimalStyleValues.lerpDimension(
        a?.loadingStrokeWidth,
        b?.loadingStrokeWidth,
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
      trackColor: AnimalStyleValues.lerpColors(a?.trackColor, b?.trackColor, t),
      trackBorderColor: AnimalStyleValues.lerpColors(
        a?.trackBorderColor,
        b?.trackBorderColor,
        t,
      ),
      thumbColor: AnimalStyleValues.lerpColors(a?.thumbColor, b?.thumbColor, t),
      thumbBorderColor: AnimalStyleValues.lerpColors(
        a?.thumbBorderColor,
        b?.thumbBorderColor,
        t,
      ),
      labelTextColor: AnimalStyleValues.lerpColors(
        a?.labelTextColor,
        b?.labelTextColor,
        t,
      ),
      loadingIndicatorColor: AnimalStyleValues.lerpColors(
        a?.loadingIndicatorColor,
        b?.loadingIndicatorColor,
        t,
      ),
      trackInsetShadow: AnimalStyleValues.lerpShadow(
        a?.trackInsetShadow,
        b?.trackInsetShadow,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalSwitchStyle &&
          width == other.width &&
          height == other.height &&
          thumbSize == other.thumbSize &&
          labelGap == other.labelGap &&
          trackBorderWidth == other.trackBorderWidth &&
          thumbBorderWidth == other.thumbBorderWidth &&
          focusBorderWidth == other.focusBorderWidth &&
          loadingStrokeWidth == other.loadingStrokeWidth &&
          borderRadius == other.borderRadius &&
          labelTextStyle == other.labelTextStyle &&
          trackColor == other.trackColor &&
          trackBorderColor == other.trackBorderColor &&
          thumbColor == other.thumbColor &&
          thumbBorderColor == other.thumbBorderColor &&
          labelTextColor == other.labelTextColor &&
          loadingIndicatorColor == other.loadingIndicatorColor &&
          trackInsetShadow == other.trackInsetShadow;

  @override
  int get hashCode => Object.hash(
    width,
    height,
    thumbSize,
    labelGap,
    trackBorderWidth,
    thumbBorderWidth,
    focusBorderWidth,
    loadingStrokeWidth,
    borderRadius,
    labelTextStyle,
    trackColor,
    trackBorderColor,
    thumbColor,
    thumbBorderColor,
    labelTextColor,
    loadingIndicatorColor,
    trackInsetShadow,
  );
}

/// Theme-wide switch overrides.
///
/// [style] applies to every size; a size-specific style takes precedence over
/// it for switches of that size. A switch's own `style` parameter takes
/// precedence over both.
@immutable
class AnimalSwitchThemeData {
  /// Style applied to switches of every size.
  final AnimalSwitchStyle? style;

  /// Style for small switches; wins over [style].
  final AnimalSwitchStyle? smallStyle;

  /// Style for default-size switches; wins over [style].
  final AnimalSwitchStyle? defaultSizeStyle;

  /// Creates theme-wide switch overrides; every style defaults to null.
  const AnimalSwitchThemeData({
    this.style,
    this.smallStyle,
    this.defaultSizeStyle,
  });

  /// Returns a copy of this theme data with the given fields replaced.
  AnimalSwitchThemeData copyWith({
    AnimalSwitchStyle? style,
    AnimalSwitchStyle? smallStyle,
    AnimalSwitchStyle? defaultSizeStyle,
  }) => AnimalSwitchThemeData(
    style: style ?? this.style,
    smallStyle: smallStyle ?? this.smallStyle,
    defaultSizeStyle: defaultSizeStyle ?? this.defaultSizeStyle,
  );

  /// Linearly interpolates between two theme data values, style by style.
  static AnimalSwitchThemeData? lerp(
    AnimalSwitchThemeData? a,
    AnimalSwitchThemeData? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalSwitchThemeData(
      style: AnimalSwitchStyle.lerp(a?.style, b?.style, t),
      smallStyle: AnimalSwitchStyle.lerp(a?.smallStyle, b?.smallStyle, t),
      defaultSizeStyle: AnimalSwitchStyle.lerp(
        a?.defaultSizeStyle,
        b?.defaultSizeStyle,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalSwitchThemeData &&
          style == other.style &&
          smallStyle == other.smallStyle &&
          defaultSizeStyle == other.defaultSizeStyle;

  @override
  int get hashCode => Object.hash(style, smallStyle, defaultSizeStyle);
}
