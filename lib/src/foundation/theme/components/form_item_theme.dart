import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalFormItem`.
///
/// The same type customizes one AnimalFormItem through its `style` parameter and every
/// AnimalFormItem through `AnimalIslandTheme.components`. Each field is optional; a
/// null field falls through to the next layer and finally to a default derived
/// from the active theme tokens.
///
/// Text styles carry their own color; a partial text style keeps every field
/// it leaves unset from the lower layer.
@immutable
class AnimalFormItemStyle {
  /// Style of the text label, including its color.
  final TextStyle? labelTextStyle;

  /// Style of the required marker shown before the label, including its color.
  final TextStyle? requiredMarkTextStyle;

  /// Style of the help text, including its color.
  final TextStyle? helpTextStyle;

  /// Style of the validation message, including its color.
  final TextStyle? errorTextStyle;

  /// Vertical gap between the label and the field content.
  final double? labelGap;

  /// Vertical gap between the field content and its help or error text.
  final double? feedbackGap;

  /// Space below the item; the item's explicit `margin` parameter replaces it.
  final double? bottomMargin;

  /// Duration of the help/error feedback transition.
  final Duration? feedbackDuration;

  /// Creates a form item style.
  ///
  /// Throws an [ArgumentError] if a given dimension is negative or not finite,
  /// a given text style has a font size that is not finite and positive, or
  /// [feedbackDuration] is negative.
  AnimalFormItemStyle({
    this.labelTextStyle,
    this.requiredMarkTextStyle,
    this.helpTextStyle,
    this.errorTextStyle,
    this.labelGap,
    this.feedbackGap,
    this.bottomMargin,
    this.feedbackDuration,
  }) {
    AnimalStyleValues.checkTextStyle('labelTextStyle', labelTextStyle);
    AnimalStyleValues.checkTextStyle(
      'requiredMarkTextStyle',
      requiredMarkTextStyle,
    );
    AnimalStyleValues.checkTextStyle('helpTextStyle', helpTextStyle);
    AnimalStyleValues.checkTextStyle('errorTextStyle', errorTextStyle);
    AnimalStyleValues.checkDimension('labelGap', labelGap);
    AnimalStyleValues.checkDimension('feedbackGap', feedbackGap);
    AnimalStyleValues.checkDimension('bottomMargin', bottomMargin);
    final Duration? duration = feedbackDuration;
    if (duration != null && duration.isNegative) {
      throw ArgumentError.value(
        duration,
        'feedbackDuration',
        'must not be negative',
      );
    }
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalFormItemStyle copyWith({
    TextStyle? labelTextStyle,
    TextStyle? requiredMarkTextStyle,
    TextStyle? helpTextStyle,
    TextStyle? errorTextStyle,
    double? labelGap,
    double? feedbackGap,
    double? bottomMargin,
    Duration? feedbackDuration,
  }) => AnimalFormItemStyle(
    labelTextStyle: labelTextStyle ?? this.labelTextStyle,
    requiredMarkTextStyle: requiredMarkTextStyle ?? this.requiredMarkTextStyle,
    helpTextStyle: helpTextStyle ?? this.helpTextStyle,
    errorTextStyle: errorTextStyle ?? this.errorTextStyle,
    labelGap: labelGap ?? this.labelGap,
    feedbackGap: feedbackGap ?? this.feedbackGap,
    bottomMargin: bottomMargin ?? this.bottomMargin,
    feedbackDuration: feedbackDuration ?? this.feedbackDuration,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalFormItemStyle merge(AnimalFormItemStyle? other) {
    if (other == null) return this;
    return AnimalFormItemStyle(
      labelTextStyle:
          other.labelTextStyle?.merge(labelTextStyle) ?? labelTextStyle,
      requiredMarkTextStyle:
          other.requiredMarkTextStyle?.merge(requiredMarkTextStyle) ??
          requiredMarkTextStyle,
      helpTextStyle: other.helpTextStyle?.merge(helpTextStyle) ?? helpTextStyle,
      errorTextStyle:
          other.errorTextStyle?.merge(errorTextStyle) ?? errorTextStyle,
      labelGap: labelGap ?? other.labelGap,
      feedbackGap: feedbackGap ?? other.feedbackGap,
      bottomMargin: bottomMargin ?? other.bottomMargin,
      feedbackDuration: feedbackDuration ?? other.feedbackDuration,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalFormItemStyle? lerp(
    AnimalFormItemStyle? a,
    AnimalFormItemStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalFormItemStyle(
      labelTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.labelTextStyle,
        b?.labelTextStyle,
        t,
      ),
      requiredMarkTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.requiredMarkTextStyle,
        b?.requiredMarkTextStyle,
        t,
      ),
      helpTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.helpTextStyle,
        b?.helpTextStyle,
        t,
      ),
      errorTextStyle: AnimalStyleValues.lerpTextStyle(
        a?.errorTextStyle,
        b?.errorTextStyle,
        t,
      ),
      labelGap: AnimalStyleValues.lerpDimension(a?.labelGap, b?.labelGap, t),
      feedbackGap: AnimalStyleValues.lerpDimension(
        a?.feedbackGap,
        b?.feedbackGap,
        t,
      ),
      bottomMargin: AnimalStyleValues.lerpDimension(
        a?.bottomMargin,
        b?.bottomMargin,
        t,
      ),
      feedbackDuration: AnimalStyleValues.lerpDuration(
        a?.feedbackDuration,
        b?.feedbackDuration,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalFormItemStyle &&
          labelTextStyle == other.labelTextStyle &&
          requiredMarkTextStyle == other.requiredMarkTextStyle &&
          helpTextStyle == other.helpTextStyle &&
          errorTextStyle == other.errorTextStyle &&
          labelGap == other.labelGap &&
          feedbackGap == other.feedbackGap &&
          bottomMargin == other.bottomMargin &&
          feedbackDuration == other.feedbackDuration;

  @override
  int get hashCode => Object.hash(
    labelTextStyle,
    requiredMarkTextStyle,
    helpTextStyle,
    errorTextStyle,
    labelGap,
    feedbackGap,
    bottomMargin,
    feedbackDuration,
  );
}
