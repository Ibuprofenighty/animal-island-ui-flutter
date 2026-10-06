import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Typography tokens owned by one theme.
///
/// Colors stay in the color family; these styles define font metrics and weight.
/// Every style carries a finite, positive font size, so components can scale a
/// role with `TextStyle.apply(fontSizeFactor: ...)`.
/// The family has no dependency on the theme extension, so it cannot form a
/// reverse dependency cycle.
@immutable
class AnimalThemeTypography {
  final String fontFamily;
  final List<String> fontFamilyFallback;
  final TextStyle title;
  final TextStyle heading;
  final TextStyle subheading;
  final TextStyle button;
  final TextStyle body;
  final TextStyle secondary;
  final TextStyle caption;
  final TextStyle code;
  final TextStyle countdown;
  final TextStyle digitLarge;

  AnimalThemeTypography({
    required this.fontFamily,
    required List<String> fontFamilyFallback,
    required this.title,
    required this.heading,
    required this.subheading,
    required this.button,
    required this.body,
    required this.secondary,
    required this.caption,
    required this.code,
    required this.countdown,
    required this.digitLarge,
  }) : fontFamilyFallback = List<String>.unmodifiable(fontFamilyFallback) {
    if (fontFamily.trim().isEmpty ||
        this.fontFamilyFallback.any((family) => family.trim().isEmpty)) {
      throw ArgumentError('Font families must not be empty.');
    }
    for (final entry in <String, TextStyle>{
      'title': title,
      'heading': heading,
      'subheading': subheading,
      'button': button,
      'body': body,
      'secondary': secondary,
      'caption': caption,
      'code': code,
      'countdown': countdown,
      'digitLarge': digitLarge,
    }.entries) {
      final style = entry.value;
      final size = style.fontSize;
      if (size == null || !size.isFinite || size <= 0) {
        throw ArgumentError.value(
          size,
          entry.key,
          'font size must be present, finite and positive',
        );
      }
      if (style.height case final height?
          when !height.isFinite || height <= 0) {
        throw ArgumentError.value(
          height,
          entry.key,
          'line height must be finite and positive',
        );
      }
      if (style.letterSpacing case final spacing? when !spacing.isFinite) {
        throw ArgumentError.value(
          spacing,
          entry.key,
          'letter spacing must be finite',
        );
      }
      if (style.wordSpacing case final spacing? when !spacing.isFinite) {
        throw ArgumentError.value(
          spacing,
          entry.key,
          'word spacing must be finite',
        );
      }
    }
  }

  /// Bundled Nunito/Noto defaults, registered once by the library package.
  static final AnimalThemeTypography standard = AnimalThemeTypography(
    fontFamily: 'packages/animal_island_ui/Nunito',
    fontFamilyFallback: const <String>[
      'packages/animal_island_ui/Noto Sans SC',
      'sans-serif',
    ],
    title: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      height: 1.2,
    ),
    heading: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.3,
    ),
    subheading: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    button: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      height: 1.2,
    ),
    body: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5,
    ),
    secondary: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    caption: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.3,
    ),
    code: const TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    countdown: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w900,
      height: 1.0,
    ),
    digitLarge: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      height: 1.1,
    ),
  );

  /// Applies this family's registered/default font source to a token style.
  ///
  /// Explicit per-style font choices remain authoritative. Direct painters use
  /// this method too, so they do not rely on an ambient Material text default.
  TextStyle resolve(TextStyle style) => style.copyWith(
    fontFamily: style.fontFamily ?? fontFamily,
    fontFamilyFallback: style.fontFamilyFallback ?? fontFamilyFallback,
  );

  AnimalThemeTypography copyWith({
    String? fontFamily,
    List<String>? fontFamilyFallback,
    TextStyle? title,
    TextStyle? heading,
    TextStyle? subheading,
    TextStyle? button,
    TextStyle? body,
    TextStyle? secondary,
    TextStyle? caption,
    TextStyle? code,
    TextStyle? countdown,
    TextStyle? digitLarge,
  }) => AnimalThemeTypography(
    fontFamily: fontFamily ?? this.fontFamily,
    fontFamilyFallback: fontFamilyFallback ?? this.fontFamilyFallback,
    title: title ?? this.title,
    heading: heading ?? this.heading,
    subheading: subheading ?? this.subheading,
    button: button ?? this.button,
    body: body ?? this.body,
    secondary: secondary ?? this.secondary,
    caption: caption ?? this.caption,
    code: code ?? this.code,
    countdown: countdown ?? this.countdown,
    digitLarge: digitLarge ?? this.digitLarge,
  );

  AnimalThemeTypography lerp(AnimalThemeTypography other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalThemeTypography(
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      fontFamilyFallback: t < 0.5
          ? fontFamilyFallback
          : other.fontFamilyFallback,
      title: TextStyle.lerp(title, other.title, t)!,
      heading: TextStyle.lerp(heading, other.heading, t)!,
      subheading: TextStyle.lerp(subheading, other.subheading, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      secondary: TextStyle.lerp(secondary, other.secondary, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
      code: TextStyle.lerp(code, other.code, t)!,
      countdown: TextStyle.lerp(countdown, other.countdown, t)!,
      digitLarge: TextStyle.lerp(digitLarge, other.digitLarge, t)!,
    );
  }

  static bool _sameList(List<Object?> a, List<Object?> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalThemeTypography &&
          fontFamily == other.fontFamily &&
          _sameList(fontFamilyFallback, other.fontFamilyFallback) &&
          title == other.title &&
          heading == other.heading &&
          subheading == other.subheading &&
          button == other.button &&
          body == other.body &&
          secondary == other.secondary &&
          caption == other.caption &&
          code == other.code &&
          countdown == other.countdown &&
          digitLarge == other.digitLarge;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    fontFamily,
    ...fontFamilyFallback,
    title,
    heading,
    subheading,
    button,
    body,
    secondary,
    caption,
    code,
    countdown,
    digitLarge,
  ]);
}
