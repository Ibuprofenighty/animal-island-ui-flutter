import 'package:flutter/widgets.dart';

import 'style_values.dart';

/// Visual overrides for `AnimalTypewriter`.
///
/// The same type customizes one typewriter through its `style` parameter and
/// every one through `AnimalIslandTheme.components`. Each field is optional;
/// a null field falls through to the next layer and finally to a default
/// derived from the active theme tokens.
@immutable
class AnimalTypewriterStyle {
  /// Style of the text. Its color is resolved from [textColor].
  final TextStyle? textStyle;

  /// Color of the revealed text.
  final Color? textColor;

  /// Color of the typing cursor.
  final Color? cursorColor;

  /// Width of the typing cursor.
  final double? cursorWidth;

  /// Creates a typewriter style.
  ///
  /// Throws an [ArgumentError] if a given dimension is negative or not finite,
  /// or a given text style has a font size that is not finite and positive.
  AnimalTypewriterStyle({
    this.textStyle,
    this.textColor,
    this.cursorColor,
    this.cursorWidth,
  }) {
    AnimalStyleValues.checkTextStyle('textStyle', textStyle);
    AnimalStyleValues.checkDimension('cursorWidth', cursorWidth);
  }

  /// Returns a copy of this style with the given fields replaced.
  AnimalTypewriterStyle copyWith({
    TextStyle? textStyle,
    Color? textColor,
    Color? cursorColor,
    double? cursorWidth,
  }) => AnimalTypewriterStyle(
    textStyle: textStyle ?? this.textStyle,
    textColor: textColor ?? this.textColor,
    cursorColor: cursorColor ?? this.cursorColor,
    cursorWidth: cursorWidth ?? this.cursorWidth,
  );

  /// Returns this style with its null fields taken from [other].
  ///
  /// Text styles merge field by field, so an override can change only the
  /// font size and keep the rest of the lower layer's style.
  AnimalTypewriterStyle merge(AnimalTypewriterStyle? other) {
    if (other == null) return this;
    return AnimalTypewriterStyle(
      textStyle: other.textStyle?.merge(textStyle) ?? textStyle,
      textColor: textColor ?? other.textColor,
      cursorColor: cursorColor ?? other.cursorColor,
      cursorWidth: cursorWidth ?? other.cursorWidth,
    );
  }

  /// Linearly interpolates between two styles.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`. A field set on only one
  /// side switches at `t == 0.5` instead of blending from a default.
  /// `t` is clamped to 0..1, so an overshooting curve stays between [a]
  /// and [b].
  static AnimalTypewriterStyle? lerp(
    AnimalTypewriterStyle? a,
    AnimalTypewriterStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalTypewriterStyle(
      textStyle: AnimalStyleValues.lerpTextStyle(a?.textStyle, b?.textStyle, t),
      textColor: AnimalStyleValues.lerpColor(a?.textColor, b?.textColor, t),
      cursorColor: AnimalStyleValues.lerpColor(
        a?.cursorColor,
        b?.cursorColor,
        t,
      ),
      cursorWidth: AnimalStyleValues.lerpDimension(
        a?.cursorWidth,
        b?.cursorWidth,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTypewriterStyle &&
          other.textStyle == textStyle &&
          other.textColor == textColor &&
          other.cursorColor == cursorColor &&
          other.cursorWidth == cursorWidth;

  @override
  int get hashCode =>
      Object.hash(textStyle, textColor, cursorColor, cursorWidth);
}
