import 'package:flutter/material.dart';
import 'colors.dart';
import 'radii.dart';

/// Comprehensive enterprise-grade theme extension providing Animal Island tokens to Flutter widgets.
class AnimalIslandTheme extends ThemeExtension<AnimalIslandTheme> {
  final Color primary;
  final Color primaryHover;
  final Color primaryActive;
  final Color primaryBg;

  // Semantic Status Tokens
  final Color success;
  final Color successActive;
  final Color successBg;

  final Color warning;
  final Color warningActive;
  final Color warningBg;

  final Color error;
  final Color errorActive;
  final Color errorBg;

  final Color info;
  final Color infoBg;

  // Typography & Content Colors
  final Color text;
  final Color textBody;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;

  // Surface & Layout Colors
  final Color bg;
  final Color bgContent;
  final Color bgInput;
  final Color border;
  final Color borderLight;
  final Color focusYellow;

  // Governed Dark Surfaces (replaces magic 0xFF2C241D, 0xFF383028, 0xFF1E1A16)
  final Color surfaceHeader;
  final Color surfaceAlt;
  final Color surfaceSubtle;
  final Color depthColor;

  final double radiusPill;
  final double radiusCard;
  final double radiusSm;

  final bool isDark;

  const AnimalIslandTheme({
    this.primary = AnimalColors.primary,
    this.primaryHover = AnimalColors.primaryHover,
    this.primaryActive = AnimalColors.primaryActive,
    this.primaryBg = AnimalColors.primaryBg,
    this.success = AnimalColors.success,
    this.successActive = AnimalColors.successActive,
    this.successBg = const Color(0xFFEDF8E5),
    this.warning = AnimalColors.warning,
    this.warningActive = AnimalColors.warningActive,
    this.warningBg = const Color(0xFFFFF9E5),
    this.error = AnimalColors.error,
    this.errorActive = AnimalColors.errorActive,
    this.errorBg = const Color(0xFFFFECEC),
    this.info = AnimalColors.primary,
    this.infoBg = const Color(0xFFE6F7F5),
    this.text = AnimalColors.text,
    this.textBody = AnimalColors.textBody,
    this.textSecondary = AnimalColors.textSecondary,
    this.textMuted = AnimalColors.textMuted,
    this.textDisabled = AnimalColors.textDisabled,
    this.bg = AnimalColors.bg,
    this.bgContent = AnimalColors.bgContent,
    this.bgInput = AnimalColors.bgInput,
    this.border = AnimalColors.border,
    this.borderLight = AnimalColors.borderLight,
    this.focusYellow = AnimalColors.focusYellow,
    this.surfaceHeader = AnimalColors.bgSecondary,
    this.surfaceAlt = AnimalColors.bgInput,
    this.surfaceSubtle = AnimalColors.bgDisabled,
    this.depthColor = const Color(0xFFD4C9B4),
    this.radiusPill = AnimalRadii.pill,
    this.radiusCard = AnimalRadii.card,
    this.radiusSm = AnimalRadii.sm,
    this.isDark = false,
  });

  /// Resolves the current theme from BuildContext.
  ///
  /// If an [AnimalIslandTheme] is registered as a [ThemeExtension] on [ThemeData],
  /// it is returned directly. Otherwise, it automatically adapts to the host app's
  /// [ThemeData.brightness], returning [AnimalIslandTheme.dark] for dark mode and
  /// [AnimalIslandTheme.light] for light mode.
  static AnimalIslandTheme of(BuildContext context) {
    final extension = Theme.of(context).extension<AnimalIslandTheme>();
    if (extension != null) return extension;
    return Theme.of(context).brightness == Brightness.dark
        ? AnimalIslandTheme.dark
        : AnimalIslandTheme.light;
  }

  /// Default light parchment theme (canonical Animal Crossing island aesthetic)
  static const AnimalIslandTheme light = AnimalIslandTheme(
    isDark: false,
  );

  /// Cozy dark theme (warm campfire night mode, avoiding harsh pure black)
  static const AnimalIslandTheme dark = AnimalIslandTheme(
    primary: Color(0xFF23D5C5),
    primaryHover: Color(0xFF3FE2D3),
    primaryActive: Color(0xFF16B5A7),
    primaryBg: Color(0xFF1B3835),
    success: Color(0xFF81C784),
    successActive: Color(0xFF66BB6A),
    successBg: Color(0xFF1E3A24),
    warning: Color(0xFFFFB74D),
    warningActive: Color(0xFFFFA726),
    warningBg: Color(0xFF3D2C15),
    error: Color(0xFFE57373),
    errorActive: Color(0xFFEF5350),
    errorBg: Color(0xFF3B1E1E),
    info: Color(0xFF4DD0E1),
    infoBg: Color(0xFF163238),
    text: Color(0xFFF3E7D3),
    textBody: Color(0xFFE2D4BD),
    textSecondary: Color(0xFFB5A790),
    textMuted: Color(0xFF9E8E76),
    textDisabled: Color(0xFF6B6050),
    bg: Color(0xFF26211C),
    bgContent: Color(0xFF332C25),
    bgInput: Color(0xFF3E362E),
    border: Color(0xFF66594A),
    borderLight: Color(0xFF4D4236),
    focusYellow: Color(0xFFFFD533),
    surfaceHeader: Color(0xFF2C241D),
    surfaceAlt: Color(0xFF383028),
    surfaceSubtle: Color(0xFF1E1A16),
    depthColor: Color(0xFF1C1712),
    isDark: true,
  );

  @override
  AnimalIslandTheme copyWith({
    Color? primary,
    Color? primaryHover,
    Color? primaryActive,
    Color? primaryBg,
    Color? success,
    Color? successActive,
    Color? successBg,
    Color? warning,
    Color? warningActive,
    Color? warningBg,
    Color? error,
    Color? errorActive,
    Color? errorBg,
    Color? info,
    Color? infoBg,
    Color? text,
    Color? textBody,
    Color? textSecondary,
    Color? textMuted,
    Color? textDisabled,
    Color? bg,
    Color? bgContent,
    Color? bgInput,
    Color? border,
    Color? borderLight,
    Color? focusYellow,
    Color? surfaceHeader,
    Color? surfaceAlt,
    Color? surfaceSubtle,
    Color? depthColor,
    double? radiusPill,
    double? radiusCard,
    double? radiusSm,
    bool? isDark,
  }) {
    return AnimalIslandTheme(
      primary: primary ?? this.primary,
      primaryHover: primaryHover ?? this.primaryHover,
      primaryActive: primaryActive ?? this.primaryActive,
      primaryBg: primaryBg ?? this.primaryBg,
      success: success ?? this.success,
      successActive: successActive ?? this.successActive,
      successBg: successBg ?? this.successBg,
      warning: warning ?? this.warning,
      warningActive: warningActive ?? this.warningActive,
      warningBg: warningBg ?? this.warningBg,
      error: error ?? this.error,
      errorActive: errorActive ?? this.errorActive,
      errorBg: errorBg ?? this.errorBg,
      info: info ?? this.info,
      infoBg: infoBg ?? this.infoBg,
      text: text ?? this.text,
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textDisabled: textDisabled ?? this.textDisabled,
      bg: bg ?? this.bg,
      bgContent: bgContent ?? this.bgContent,
      bgInput: bgInput ?? this.bgInput,
      border: border ?? this.border,
      borderLight: borderLight ?? this.borderLight,
      focusYellow: focusYellow ?? this.focusYellow,
      surfaceHeader: surfaceHeader ?? this.surfaceHeader,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      surfaceSubtle: surfaceSubtle ?? this.surfaceSubtle,
      depthColor: depthColor ?? this.depthColor,
      radiusPill: radiusPill ?? this.radiusPill,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusSm: radiusSm ?? this.radiusSm,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AnimalIslandTheme lerp(ThemeExtension<AnimalIslandTheme>? other, double t) {
    if (other is! AnimalIslandTheme) return this;
    return AnimalIslandTheme(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t) ?? primaryHover,
      primaryActive: Color.lerp(primaryActive, other.primaryActive, t) ?? primaryActive,
      primaryBg: Color.lerp(primaryBg, other.primaryBg, t) ?? primaryBg,
      success: Color.lerp(success, other.success, t) ?? success,
      successActive: Color.lerp(successActive, other.successActive, t) ?? successActive,
      successBg: Color.lerp(successBg, other.successBg, t) ?? successBg,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningActive: Color.lerp(warningActive, other.warningActive, t) ?? warningActive,
      warningBg: Color.lerp(warningBg, other.warningBg, t) ?? warningBg,
      error: Color.lerp(error, other.error, t) ?? error,
      errorActive: Color.lerp(errorActive, other.errorActive, t) ?? errorActive,
      errorBg: Color.lerp(errorBg, other.errorBg, t) ?? errorBg,
      info: Color.lerp(info, other.info, t) ?? info,
      infoBg: Color.lerp(infoBg, other.infoBg, t) ?? infoBg,
      text: Color.lerp(text, other.text, t) ?? text,
      textBody: Color.lerp(textBody, other.textBody, t) ?? textBody,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      textMuted: Color.lerp(textMuted, other.textMuted, t) ?? textMuted,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t) ?? textDisabled,
      bg: Color.lerp(bg, other.bg, t) ?? bg,
      bgContent: Color.lerp(bgContent, other.bgContent, t) ?? bgContent,
      bgInput: Color.lerp(bgInput, other.bgInput, t) ?? bgInput,
      border: Color.lerp(border, other.border, t) ?? border,
      borderLight: Color.lerp(borderLight, other.borderLight, t) ?? borderLight,
      focusYellow: Color.lerp(focusYellow, other.focusYellow, t) ?? focusYellow,
      surfaceHeader: Color.lerp(surfaceHeader, other.surfaceHeader, t) ?? surfaceHeader,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t) ?? surfaceAlt,
      surfaceSubtle: Color.lerp(surfaceSubtle, other.surfaceSubtle, t) ?? surfaceSubtle,
      depthColor: Color.lerp(depthColor, other.depthColor, t) ?? depthColor,
      radiusPill: (radiusPill + (other.radiusPill - radiusPill) * t),
      radiusCard: (radiusCard + (other.radiusCard - radiusCard) * t),
      radiusSm: (radiusSm + (other.radiusSm - radiusSm) * t),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }

  /// Converts this [AnimalIslandTheme] into a complete Flutter [ThemeData]
  /// configured with cohesive ColorScheme, scaffold color, card color, and extension registration.
  ThemeData toThemeData() {
    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: focusYellow,
      onSecondary: const Color(0xFF4A3E3D),
      error: error,
      onError: Colors.white,
      surface: bgContent,
      onSurface: text,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      cardColor: bgContent,
      dividerColor: border,
      extensions: <ThemeExtension<dynamic>>[
        this,
      ],
    );
  }
}

/// Syntactic sugar extension for convenient access in BuildContext
extension AnimalIslandThemeContext on BuildContext {
  AnimalIslandTheme get animalTheme => AnimalIslandTheme.of(this);
}
