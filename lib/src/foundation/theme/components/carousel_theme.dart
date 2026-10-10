import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for AnimalCarousel.
/// Instance fields take precedence over the matching component theme and tokens.
@immutable
class AnimalCarouselStyle {
  /// Carousel height.
  final double? height;

  /// Empty carousel fill.
  final Color? backgroundColor;

  /// Empty carousel outline.
  final Color? borderColor;

  /// Empty carousel outline width.
  final double? borderWidth;

  /// Slide corners.
  final BorderRadius? borderRadius;

  /// Corner radius of the dot rail
  final BorderRadius? dotBorderRadius;

  /// Arrow foreground.
  final Color? arrowColor;

  /// Arrow fill.
  final Color? arrowBackgroundColor;

  /// Arrow icon size.
  final double? arrowIconSize;

  /// Distance of controls from the slide edge.
  final double? controlInset;

  /// Arrow insets.
  final EdgeInsetsGeometry? controlPadding;

  /// Unselected dot fill.
  final Color? dotColor;

  /// Selected dot fill.
  final Color? activeDotColor;

  /// Dot height and unselected width.
  final double? dotSize;

  /// Selected dot width.
  final double? activeDotWidth;

  /// Space between dot hit areas.
  final double? dotGap;

  /// Indicator rail insets.
  final EdgeInsetsGeometry? dotPadding;

  /// Indicator rail fill.
  final Color? dotBackgroundColor;

  /// Indicator rail elevation.
  final BoxShadow? shadow;

  /// Slide and dot transition duration.
  final Duration? duration;

  /// Dot transition duration
  final Duration? dotDuration;

  /// Slide and dot transition curve.
  final Curve? curve;

  /// Creates overrides; null fields inherit the lower layer.
  /// Invalid dimensions, insets, radii and durations throw ArgumentError.
  AnimalCarouselStyle({
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.dotBorderRadius,
    this.arrowColor,
    this.arrowBackgroundColor,
    this.arrowIconSize,
    this.controlInset,
    this.controlPadding,
    this.dotColor,
    this.activeDotColor,
    this.dotSize,
    this.activeDotWidth,
    this.dotGap,
    this.dotPadding,
    this.dotBackgroundColor,
    this.shadow,
    this.duration,
    this.dotDuration,
    this.curve,
  }) {
    if (dotDuration != null && dotDuration! < Duration.zero) {
      throw ArgumentError.value(
        dotDuration,
        'dotDuration',
        'must be non-negative',
      );
    }
    AnimalStyleValues.checkDimension(
      'height',
      height,
      minimum: double.minPositive,
    );
    AnimalStyleValues.checkDimension('borderWidth', borderWidth);
    AnimalStyleValues.checkRadius('borderRadius', borderRadius);
    AnimalStyleValues.checkRadius('dotBorderRadius', dotBorderRadius);
    AnimalStyleValues.checkDimension('arrowIconSize', arrowIconSize);
    AnimalStyleValues.checkDimension('controlInset', controlInset);
    AnimalStyleValues.checkInsets('controlPadding', controlPadding);
    AnimalStyleValues.checkDimension('dotSize', dotSize);
    AnimalStyleValues.checkDimension('activeDotWidth', activeDotWidth);
    AnimalStyleValues.checkDimension('dotGap', dotGap);
    AnimalStyleValues.checkInsets('dotPadding', dotPadding);
    if (duration != null && duration! < Duration.zero) {
      throw ArgumentError.value(duration, 'duration', 'must be non-negative');
    }
  }

  /// Returns a copy with the given fields replaced.
  AnimalCarouselStyle copyWith({
    double? height,
    Color? backgroundColor,
    Color? borderColor,
    double? borderWidth,
    BorderRadius? borderRadius,
    BorderRadius? dotBorderRadius,
    Color? arrowColor,
    Color? arrowBackgroundColor,
    double? arrowIconSize,
    double? controlInset,
    EdgeInsetsGeometry? controlPadding,
    Color? dotColor,
    Color? activeDotColor,
    double? dotSize,
    double? activeDotWidth,
    double? dotGap,
    EdgeInsetsGeometry? dotPadding,
    Color? dotBackgroundColor,
    BoxShadow? shadow,
    Duration? duration,
    Duration? dotDuration,
    Curve? curve,
  }) => AnimalCarouselStyle(
    height: height ?? this.height,
    backgroundColor: backgroundColor ?? this.backgroundColor,
    borderColor: borderColor ?? this.borderColor,
    borderWidth: borderWidth ?? this.borderWidth,
    borderRadius: borderRadius ?? this.borderRadius,
    dotBorderRadius: dotBorderRadius ?? this.dotBorderRadius,
    arrowColor: arrowColor ?? this.arrowColor,
    arrowBackgroundColor: arrowBackgroundColor ?? this.arrowBackgroundColor,
    arrowIconSize: arrowIconSize ?? this.arrowIconSize,
    controlInset: controlInset ?? this.controlInset,
    controlPadding: controlPadding ?? this.controlPadding,
    dotColor: dotColor ?? this.dotColor,
    activeDotColor: activeDotColor ?? this.activeDotColor,
    dotSize: dotSize ?? this.dotSize,
    activeDotWidth: activeDotWidth ?? this.activeDotWidth,
    dotGap: dotGap ?? this.dotGap,
    dotPadding: dotPadding ?? this.dotPadding,
    dotBackgroundColor: dotBackgroundColor ?? this.dotBackgroundColor,
    shadow: shadow ?? this.shadow,
    duration: duration ?? this.duration,
    dotDuration: dotDuration ?? this.dotDuration,
    curve: curve ?? this.curve,
  );

  /// Fills absent fields from [other].
  AnimalCarouselStyle merge(AnimalCarouselStyle? other) {
    if (other == null) return this;
    return AnimalCarouselStyle(
      height: height ?? other.height,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      dotBorderRadius: dotBorderRadius ?? other.dotBorderRadius,
      arrowColor: arrowColor ?? other.arrowColor,
      arrowBackgroundColor: arrowBackgroundColor ?? other.arrowBackgroundColor,
      arrowIconSize: arrowIconSize ?? other.arrowIconSize,
      controlInset: controlInset ?? other.controlInset,
      controlPadding: controlPadding ?? other.controlPadding,
      dotColor: dotColor ?? other.dotColor,
      activeDotColor: activeDotColor ?? other.activeDotColor,
      dotSize: dotSize ?? other.dotSize,
      activeDotWidth: activeDotWidth ?? other.activeDotWidth,
      dotGap: dotGap ?? other.dotGap,
      dotPadding: dotPadding ?? other.dotPadding,
      dotBackgroundColor: dotBackgroundColor ?? other.dotBackgroundColor,
      shadow: shadow ?? other.shadow,
      duration: duration ?? other.duration,
      dotDuration: dotDuration ?? other.dotDuration,
      curve: curve ?? other.curve,
    );
  }

  /// Interpolates fields within the endpoints; absent fields switch at halfway.
  static AnimalCarouselStyle? lerp(
    AnimalCarouselStyle? a,
    AnimalCarouselStyle? b,
    double t,
  ) {
    t = t.clamp(0.0, 1.0);
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalCarouselStyle(
      height: AnimalStyleValues.lerpDimension(a?.height, b?.height, t),
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
      dotBorderRadius: AnimalStyleValues.lerpRadius(
        a?.dotBorderRadius,
        b?.dotBorderRadius,
        t,
      ),
      arrowColor: AnimalStyleValues.lerpColor(a?.arrowColor, b?.arrowColor, t),
      arrowBackgroundColor: AnimalStyleValues.lerpColor(
        a?.arrowBackgroundColor,
        b?.arrowBackgroundColor,
        t,
      ),
      arrowIconSize: AnimalStyleValues.lerpDimension(
        a?.arrowIconSize,
        b?.arrowIconSize,
        t,
      ),
      controlInset: AnimalStyleValues.lerpDimension(
        a?.controlInset,
        b?.controlInset,
        t,
      ),
      controlPadding: AnimalStyleValues.lerpInsets(
        a?.controlPadding,
        b?.controlPadding,
        t,
      ),
      dotColor: AnimalStyleValues.lerpColor(a?.dotColor, b?.dotColor, t),
      activeDotColor: AnimalStyleValues.lerpColor(
        a?.activeDotColor,
        b?.activeDotColor,
        t,
      ),
      dotSize: AnimalStyleValues.lerpDimension(a?.dotSize, b?.dotSize, t),
      activeDotWidth: AnimalStyleValues.lerpDimension(
        a?.activeDotWidth,
        b?.activeDotWidth,
        t,
      ),
      dotGap: AnimalStyleValues.lerpDimension(a?.dotGap, b?.dotGap, t),
      dotPadding: AnimalStyleValues.lerpInsets(a?.dotPadding, b?.dotPadding, t),
      dotBackgroundColor: AnimalStyleValues.lerpColor(
        a?.dotBackgroundColor,
        b?.dotBackgroundColor,
        t,
      ),
      shadow: AnimalStyleValues.lerpShadow(a?.shadow, b?.shadow, t),
      duration: AnimalStyleValues.lerpDuration(a?.duration, b?.duration, t),
      dotDuration: AnimalStyleValues.lerpDuration(
        a?.dotDuration,
        b?.dotDuration,
        t,
      ),
      curve: AnimalStyleValues.snap(a?.curve, b?.curve, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalCarouselStyle &&
          height == other.height &&
          backgroundColor == other.backgroundColor &&
          borderColor == other.borderColor &&
          borderWidth == other.borderWidth &&
          borderRadius == other.borderRadius &&
          dotBorderRadius == other.dotBorderRadius &&
          arrowColor == other.arrowColor &&
          arrowBackgroundColor == other.arrowBackgroundColor &&
          arrowIconSize == other.arrowIconSize &&
          controlInset == other.controlInset &&
          controlPadding == other.controlPadding &&
          dotColor == other.dotColor &&
          activeDotColor == other.activeDotColor &&
          dotSize == other.dotSize &&
          activeDotWidth == other.activeDotWidth &&
          dotGap == other.dotGap &&
          dotPadding == other.dotPadding &&
          dotBackgroundColor == other.dotBackgroundColor &&
          shadow == other.shadow &&
          duration == other.duration &&
          dotDuration == other.dotDuration &&
          curve == other.curve;

  @override
  int get hashCode => Object.hashAll([
    height,
    backgroundColor,
    borderColor,
    borderWidth,
    borderRadius,
    dotBorderRadius,
    arrowColor,
    arrowBackgroundColor,
    arrowIconSize,
    controlInset,
    controlPadding,
    dotColor,
    activeDotColor,
    dotSize,
    activeDotWidth,
    dotGap,
    dotPadding,
    dotBackgroundColor,
    shadow,
    duration,
    dotDuration,
    curve,
  ]);
}
