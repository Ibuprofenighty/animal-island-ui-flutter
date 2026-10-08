import 'package:flutter/material.dart';

/// Stable identity for the thirteen island accent swatches.
///
/// The swatch colors belong to [AnimalThemeColors], so changing a theme changes
/// every consumer of one of these identities.
enum AnimalTileColor {
  /// Neutral content-surface swatch; the default tile color.
  def,

  /// Pink app-tile swatch.
  appPink,

  /// Purple app-tile swatch.
  purple,

  /// Blue app-tile swatch.
  appBlue,

  /// Yellow app-tile swatch.
  appYellow,

  /// Orange app-tile swatch.
  appOrange,

  /// Teal app-tile swatch.
  appTeal,

  /// Green app-tile swatch.
  appGreen,

  /// Red app-tile swatch.
  appRed,

  /// Lime-green app-tile swatch.
  limeGreen,

  /// Yellow-green app-tile swatch.
  yellowGreen,

  /// Brown app-tile swatch.
  brown,

  /// Warm peach-pink app-tile swatch.
  warmPeachPink,
}

/// A foreground/background pair for a themed island tile.
@immutable
class AnimalTileColors {
  /// Fill color of the tile.
  final Color background;

  /// Text and icon color drawn on [background].
  final Color foreground;

  /// Creates a tile color pair.
  const AnimalTileColors({required this.background, required this.foreground});

  /// Returns a copy of this pair with the given fields replaced.
  AnimalTileColors copyWith({Color? background, Color? foreground}) =>
      AnimalTileColors(
        background: background ?? this.background,
        foreground: foreground ?? this.foreground,
      );

  /// Linearly interpolates between two tile color pairs.
  ///
  /// Returns [a] when `t == 0` and [b] when `t == 1`.
  static AnimalTileColors lerp(
    AnimalTileColors a,
    AnimalTileColors b,
    double t,
  ) {
    if (t == 0) return a;
    if (t == 1) return b;
    return AnimalTileColors(
      background: Color.lerp(a.background, b.background, t)!,
      foreground: Color.lerp(a.foreground, b.foreground, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalTileColors &&
          background == other.background &&
          foreground == other.foreground;

  @override
  int get hashCode => Object.hash(background, foreground);
}

/// Semantic color values owned by one [AnimalIslandTheme].
///
/// This is the only owner of component and tile colors. The swatch map is
/// copied and frozen at construction, and must contain every [AnimalTileColor].
@immutable
class AnimalThemeColors {
  /// Whether this palette is meant for light or dark surfaces.
  final Brightness brightness;

  /// Brand accent used to fill primary surfaces and controls.
  final Color primary;

  /// Pressed or selected variant of [primary].
  final Color primaryActive;

  /// Tinted background for primary-toned surfaces.
  final Color primaryBg;

  /// Foreground drawn on a [primary] fill.
  final Color onPrimary;

  /// Primary-toned text and icons on ordinary surfaces.
  final Color primaryText;

  /// Fill color for success states.
  final Color success;

  /// Tinted background for success-toned surfaces.
  final Color successBg;

  /// Foreground drawn on a [success] fill.
  final Color onSuccess;

  /// Success-toned text and icons on ordinary surfaces.
  final Color successText;

  /// Fill color for warning states.
  final Color warning;

  /// Tinted background for warning-toned surfaces.
  final Color warningBg;

  /// Foreground drawn on a [warning] fill.
  final Color onWarning;

  /// Warning-toned text and icons on ordinary surfaces.
  ///
  /// The input warning stroke also uses this color.
  final Color warningText;

  /// Fill color for error and danger states.
  final Color error;

  /// Tinted background for error-toned surfaces.
  final Color errorBg;

  /// Foreground drawn on an [error] fill.
  final Color onError;

  /// Error-toned text and icons on ordinary surfaces.
  final Color errorText;

  /// Fill color for informational states.
  final Color info;

  /// Tinted background for informational surfaces.
  final Color infoBg;

  /// Informational text and icons on ordinary surfaces.
  final Color infoText;

  /// Strongest text color, used for headings and emphasized labels.
  final Color text;

  /// Body text color.
  final Color textBody;

  /// Secondary text color for supporting labels.
  final Color textSecondary;

  /// Muted text color for low-emphasis captions.
  final Color textMuted;

  /// Text color for disabled or unavailable content.
  final Color textDisabled;

  /// Page background color.
  final Color bg;

  /// Background of raised content surfaces such as cards.
  final Color bgContent;

  /// Background of enabled input fields.
  final Color bgInput;

  /// Secondary background for alternate regions and inactive tracks.
  final Color bgSecondary;

  /// Background of disabled controls.
  final Color bgDisabled;

  /// Background of disabled input fields.
  final Color bgInputDisabled;

  /// Default border and outline color.
  final Color border;

  /// Lighter border color for subtle separators and outlines.
  final Color borderLight;

  /// Focus-indicator color used by focus rings.
  final Color focusYellow;

  /// Surface color for headers and title bars.
  final Color surfaceHeader;

  /// Alternate surface color for secondary panels and controls.
  final Color surfaceAlt;

  /// Low-contrast surface color, used for example by the footer.
  final Color surfaceSubtle;

  /// Tile swatches keyed by identity.
  ///
  /// The map is unmodifiable and contains every [AnimalTileColor].
  final Map<AnimalTileColor, AnimalTileColors> tileColors;

  /// Creates a palette.
  ///
  /// Throws an [ArgumentError] unless `tileColors` defines every
  /// [AnimalTileColor] exactly once.
  AnimalThemeColors({
    required this.brightness,
    required this.primary,
    required this.primaryActive,
    required this.primaryBg,
    required this.onPrimary,
    required this.primaryText,
    required this.success,
    required this.successBg,
    required this.onSuccess,
    required this.successText,
    required this.warning,
    required this.warningBg,
    required this.onWarning,
    required this.warningText,
    required this.error,
    required this.errorBg,
    required this.onError,
    required this.errorText,
    required this.info,
    required this.infoBg,
    required this.infoText,
    required this.text,
    required this.textBody,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.bg,
    required this.bgContent,
    required this.bgInput,
    required this.bgSecondary,
    required this.bgDisabled,
    required this.bgInputDisabled,
    required this.border,
    required this.borderLight,
    required this.focusYellow,
    required this.surfaceHeader,
    required this.surfaceAlt,
    required this.surfaceSubtle,
    required Map<AnimalTileColor, AnimalTileColors> tileColors,
  }) : tileColors = Map<AnimalTileColor, AnimalTileColors>.unmodifiable(
         tileColors,
       ) {
    if (tileColors.length != AnimalTileColor.values.length ||
        AnimalTileColor.values.any((color) => !tileColors.containsKey(color))) {
      throw ArgumentError.value(
        tileColors.keys,
        'tileColors',
        'must define each AnimalTileColor exactly once',
      );
    }
  }

  /// Canonical light palette. Components read it through the active theme.
  static final AnimalThemeColors light = AnimalThemeColors(
    brightness: Brightness.light,
    primary: const Color(0xFF19C8B9),
    primaryActive: const Color(0xFF11A89B),
    primaryBg: const Color(0xFFE6F9F6),
    onPrimary: const Color(0xFF21170F),
    primaryText: const Color(0xFF08766B),
    success: const Color(0xFF6FBA2C),
    successBg: const Color(0xFFEDF8E5),
    onSuccess: const Color(0xFF10250C),
    successText: const Color(0xFF3D700B),
    warning: const Color(0xFFF5C31C),
    warningBg: const Color(0xFFFFF9E5),
    onWarning: const Color(0xFF4A3500),
    warningText: const Color(0xFF705200),
    error: const Color(0xFFE05A5A),
    errorBg: const Color(0xFFFFECEC),
    onError: const Color(0xFF260707),
    errorText: const Color(0xFFB43D3D),
    info: const Color(0xFF19C8B9),
    infoBg: const Color(0xFFE6F7F5),
    infoText: const Color(0xFF08766B),
    text: const Color(0xFF794F27),
    textBody: const Color(0xFF725D42),
    textSecondary: const Color(0xFF75654F),
    textMuted: const Color(0xFF685A47),
    textDisabled: const Color(0xFF645B4F),
    bg: const Color(0xFFF8F8F0),
    bgContent: const Color(0xFFF7F3DF),
    bgInput: const Color(0xFFFFFBE7),
    bgSecondary: const Color(0xFFF0E8D8),
    bgDisabled: const Color(0xFFF0ECE2),
    bgInputDisabled: const Color(0xFFECE8DC),
    border: const Color(0xFF9F927D),
    borderLight: const Color(0xFFC4B89E),
    focusYellow: const Color(0xFF997700),
    surfaceHeader: const Color(0xFFF0E8D8),
    surfaceAlt: const Color(0xFFFFFBE7),
    surfaceSubtle: const Color(0xFFF0ECE2),
    tileColors: <AnimalTileColor, AnimalTileColors>{
      AnimalTileColor.def: AnimalTileColors(
        background: const Color(0xFFF7F3DF),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appPink: AnimalTileColors(
        background: const Color(0xFFF8A6B2),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.purple: AnimalTileColors(
        background: const Color(0xFFB77DEE),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appBlue: AnimalTileColors(
        background: const Color(0xFF889DF0),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appYellow: AnimalTileColors(
        background: const Color(0xFFF7CD67),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appOrange: AnimalTileColors(
        background: const Color(0xFFE59266),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appTeal: AnimalTileColors(
        background: const Color(0xFF82D5BB),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appGreen: AnimalTileColors(
        background: const Color(0xFF8AC68A),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.appRed: AnimalTileColors(
        background: const Color(0xFFFC736D),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.limeGreen: AnimalTileColors(
        background: const Color(0xFFD1DA49),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.yellowGreen: AnimalTileColors(
        background: const Color(0xFFECDF52),
        foreground: const Color(0xFF21170F),
      ),
      AnimalTileColor.brown: AnimalTileColors(
        background: const Color(0xFF9A835A),
        foreground: const Color(0xFF120F0B),
      ),
      AnimalTileColor.warmPeachPink: AnimalTileColors(
        background: const Color(0xFFE18C6F),
        foreground: const Color(0xFF21170F),
      ),
    },
  );

  /// Canonical dark palette, including readable variants of all tile swatches.
  static final AnimalThemeColors dark = AnimalThemeColors(
    brightness: Brightness.dark,
    primary: const Color(0xFF26D7C8),
    primaryActive: const Color(0xFF1CB7AA),
    primaryBg: const Color(0xFF1E3532),
    onPrimary: const Color(0xFF1A2C29),
    primaryText: const Color(0xFF26D7C8),
    success: const Color(0xFF7ECC36),
    successBg: const Color(0xFF233516),
    onSuccess: const Color(0xFF1D2A12),
    successText: const Color(0xFF7ECC36),
    warning: const Color(0xFFFFD438),
    warningBg: const Color(0xFF383015),
    onWarning: const Color(0xFF322700),
    warningText: const Color(0xFFFFD438),
    error: const Color(0xFFEB6B6B),
    errorBg: const Color(0xFF381F1F),
    onError: const Color(0xFF210A09),
    errorText: const Color(0xFFEB6B6B),
    info: const Color(0xFF26D7C8),
    infoBg: const Color(0xFF1A3330),
    infoText: const Color(0xFF26D7C8),
    text: const Color(0xFFF3E9D9),
    textBody: const Color(0xFFDDD2C0),
    textSecondary: const Color(0xFFBFB29E),
    textMuted: const Color(0xFFAFA18D),
    textDisabled: const Color(0xFF9A8E7C),
    bg: const Color(0xFF1E1A16),
    bgContent: const Color(0xFF28221C),
    bgInput: const Color(0xFF221C17),
    bgSecondary: const Color(0xFF322B23),
    bgDisabled: const Color(0xFF251E18),
    bgInputDisabled: const Color(0xFF2A231C),
    border: const Color(0xFF6D5E4D),
    borderLight: const Color(0xFF4A4035),
    focusYellow: const Color(0xFFFFD700),
    surfaceHeader: const Color(0xFF322B23),
    surfaceAlt: const Color(0xFF2A231C),
    surfaceSubtle: const Color(0xFF251E18),
    tileColors: <AnimalTileColor, AnimalTileColors>{
      AnimalTileColor.def: AnimalTileColors(
        background: const Color(0xFF443B2D),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appPink: AnimalTileColors(
        background: const Color(0xFF603A43),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.purple: AnimalTileColors(
        background: const Color(0xFF51376A),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appBlue: AnimalTileColors(
        background: const Color(0xFF394875),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appYellow: AnimalTileColors(
        background: const Color(0xFF5B481D),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appOrange: AnimalTileColors(
        background: const Color(0xFF653E2A),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appTeal: AnimalTileColors(
        background: const Color(0xFF205044),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appGreen: AnimalTileColors(
        background: const Color(0xFF355539),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.appRed: AnimalTileColors(
        background: const Color(0xFF6A302D),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.limeGreen: AnimalTileColors(
        background: const Color(0xFF484D1B),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.yellowGreen: AnimalTileColors(
        background: const Color(0xFF58501D),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.brown: AnimalTileColors(
        background: const Color(0xFF51432F),
        foreground: const Color(0xFFFFF8E7),
      ),
      AnimalTileColor.warmPeachPink: AnimalTileColors(
        background: const Color(0xFF693F32),
        foreground: const Color(0xFFFFF8E7),
      ),
    },
  );

  /// Returns the swatch for [color].
  AnimalTileColors tile(AnimalTileColor color) => tileColors[color]!;

  /// Returns a copy of this palette with the given fields replaced.
  AnimalThemeColors copyWith({
    Brightness? brightness,
    Color? primary,
    Color? primaryActive,
    Color? primaryBg,
    Color? onPrimary,
    Color? primaryText,
    Color? success,
    Color? successBg,
    Color? onSuccess,
    Color? successText,
    Color? warning,
    Color? warningBg,
    Color? onWarning,
    Color? warningText,
    Color? error,
    Color? errorBg,
    Color? onError,
    Color? errorText,
    Color? info,
    Color? infoBg,
    Color? infoText,
    Color? text,
    Color? textBody,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? bg,
    Color? bgContent,
    Color? bgInput,
    Color? bgSecondary,
    Color? bgDisabled,
    Color? bgInputDisabled,
    Color? border,
    Color? borderLight,
    Color? focusYellow,
    Color? surfaceHeader,
    Color? surfaceAlt,
    Color? surfaceSubtle,
    Map<AnimalTileColor, AnimalTileColors>? tileColors,
  }) => AnimalThemeColors(
    brightness: brightness ?? this.brightness,
    primary: primary ?? this.primary,
    primaryActive: primaryActive ?? this.primaryActive,
    primaryBg: primaryBg ?? this.primaryBg,
    onPrimary: onPrimary ?? this.onPrimary,
    primaryText: primaryText ?? this.primaryText,
    success: success ?? this.success,
    successBg: successBg ?? this.successBg,
    onSuccess: onSuccess ?? this.onSuccess,
    successText: successText ?? this.successText,
    warning: warning ?? this.warning,
    warningBg: warningBg ?? this.warningBg,
    onWarning: onWarning ?? this.onWarning,
    warningText: warningText ?? this.warningText,
    error: error ?? this.error,
    errorBg: errorBg ?? this.errorBg,
    onError: onError ?? this.onError,
    errorText: errorText ?? this.errorText,
    info: info ?? this.info,
    infoBg: infoBg ?? this.infoBg,
    infoText: infoText ?? this.infoText,
    text: text ?? this.text,
    textBody: textBody ?? this.textBody,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    textDisabled: textDisabled ?? this.textDisabled,
    bg: bg ?? this.bg,
    bgContent: bgContent ?? this.bgContent,
    bgInput: bgInput ?? this.bgInput,
    bgSecondary: bgSecondary ?? this.bgSecondary,
    bgDisabled: bgDisabled ?? this.bgDisabled,
    bgInputDisabled: bgInputDisabled ?? this.bgInputDisabled,
    border: border ?? this.border,
    borderLight: borderLight ?? this.borderLight,
    focusYellow: focusYellow ?? this.focusYellow,
    surfaceHeader: surfaceHeader ?? this.surfaceHeader,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
    tileColors: tileColors ?? this.tileColors,
  );

  /// Linearly interpolates between this palette and [other].
  ///
  /// Colors and tile swatches interpolate; [brightness] switches at `t == 0.5`.
  AnimalThemeColors lerp(AnimalThemeColors other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalThemeColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t)!,
      primaryBg: Color.lerp(primaryBg, other.primaryBg, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      success: Color.lerp(success, other.success, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      error: Color.lerp(error, other.error, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      onError: Color.lerp(onError, other.onError, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      text: Color.lerp(text, other.text, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      bg: Color.lerp(bg, other.bg, t)!,
      bgContent: Color.lerp(bgContent, other.bgContent, t)!,
      bgInput: Color.lerp(bgInput, other.bgInput, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgDisabled: Color.lerp(bgDisabled, other.bgDisabled, t)!,
      bgInputDisabled: Color.lerp(bgInputDisabled, other.bgInputDisabled, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      focusYellow: Color.lerp(focusYellow, other.focusYellow, t)!,
      surfaceHeader: Color.lerp(surfaceHeader, other.surfaceHeader, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t)!,
      tileColors: <AnimalTileColor, AnimalTileColors>{
        for (final color in AnimalTileColor.values)
          color: AnimalTileColors.lerp(
            tileColors[color]!,
            other.tileColors[color]!,
            t,
          ),
      },
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AnimalThemeColors ||
        brightness != other.brightness ||
        primary != other.primary ||
        primaryActive != other.primaryActive ||
        primaryBg != other.primaryBg ||
        onPrimary != other.onPrimary ||
        primaryText != other.primaryText ||
        success != other.success ||
        successBg != other.successBg ||
        onSuccess != other.onSuccess ||
        successText != other.successText ||
        warning != other.warning ||
        warningBg != other.warningBg ||
        onWarning != other.onWarning ||
        warningText != other.warningText ||
        error != other.error ||
        errorBg != other.errorBg ||
        onError != other.onError ||
        errorText != other.errorText ||
        info != other.info ||
        infoBg != other.infoBg ||
        infoText != other.infoText ||
        text != other.text ||
        textBody != other.textBody ||
        textSecondary != other.textSecondary ||
        textMuted != other.textMuted ||
        textDisabled != other.textDisabled ||
        bg != other.bg ||
        bgContent != other.bgContent ||
        bgInput != other.bgInput ||
        bgSecondary != other.bgSecondary ||
        bgDisabled != other.bgDisabled ||
        bgInputDisabled != other.bgInputDisabled ||
        border != other.border ||
        borderLight != other.borderLight ||
        focusYellow != other.focusYellow ||
        surfaceHeader != other.surfaceHeader ||
        surfaceAlt != other.surfaceAlt ||
        surfaceSubtle != other.surfaceSubtle ||
        tileColors.length != other.tileColors.length) {
      return false;
    }
    return AnimalTileColor.values.every(
      (color) => tileColors[color] == other.tileColors[color],
    );
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
    brightness,
    primary,
    primaryActive,
    primaryBg,
    onPrimary,
    primaryText,
    success,
    successBg,
    onSuccess,
    successText,
    warning,
    warningBg,
    onWarning,
    warningText,
    error,
    errorBg,
    onError,
    errorText,
    info,
    infoBg,
    infoText,
    text,
    textBody,
    textSecondary,
    textMuted,
    textDisabled,
    bg,
    bgContent,
    bgInput,
    bgSecondary,
    bgDisabled,
    bgInputDisabled,
    border,
    borderLight,
    focusYellow,
    surfaceHeader,
    surfaceAlt,
    surfaceSubtle,
    for (final color in AnimalTileColor.values)
      Object.hash(color, tileColors[color]),
  ]);
}
