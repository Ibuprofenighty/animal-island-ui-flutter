import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

/// One non-default consumer theme shared by component rendering tests.
///
/// Every family uses values distinct from both presets so each component test
/// can prove its rendered property comes from the active theme.
AnimalIslandTheme thirdAnimalIslandTheme() {
  final base = AnimalIslandTheme.light;
  return base.copyWith(
    colors: base.colors.copyWith(
      primary: const Color(0xFF31566F),
      primaryActive: const Color(0xFFB8E6A5),
      primaryBg: const Color(0xFFDCEAF2),
      onPrimary: const Color(0xFFFFFFFF),
      primaryText: const Color(0xFF183B53),
      success: const Color(0xFF276044),
      successBg: const Color(0xFFDCEFE4),
      onSuccess: const Color(0xFFFFFFFF),
      successText: const Color(0xFF17452E),
      warning: const Color(0xFF73530A),
      warningBg: const Color(0xFFF3E8C8),
      onWarning: const Color(0xFFFFFFFF),
      warningText: const Color(0xFF4D3908),
      error: const Color(0xFF8C3540),
      errorBg: const Color(0xFFF3DDE0),
      onError: const Color(0xFFFFFFFF),
      errorText: const Color(0xFF70242D),
      info: const Color(0xFF31566F),
      infoBg: const Color(0xFFDCEAF2),
      infoText: const Color(0xFF183B53),
      text: const Color(0xFF29243D),
      textBody: const Color(0xFF39344D),
      textSecondary: const Color(0xFF514C64),
      textMuted: const Color(0xFF575268),
      textDisabled: const Color(0xFF5A5669),
      bg: const Color(0xFFF3F2FA),
      bgContent: const Color(0xFFE9E8F3),
      bgInput: const Color(0xFFFAF9FF),
      bgSecondary: const Color(0xFFDEDFEC),
      bgDisabled: const Color(0xFFE2E1EB),
      bgInputDisabled: const Color(0xFFDAD9E5),
      border: const Color(0xFF77768B),
      borderLight: const Color(0xFF9796A8),
      focusYellow: const Color(0xFF7D3E82),
      surfaceHeader: const Color(0xFFDEDFEC),
      surfaceAlt: const Color(0xFFDAD9E5),
      surfaceSubtle: const Color(0xFFE2E1EB),
      tileColors: <AnimalTileColor, AnimalTileColors>{
        AnimalTileColor.def: AnimalTileColors(
          background: const Color(0xFF324A68),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appPink: AnimalTileColors(
          background: const Color(0xFF743D59),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.purple: AnimalTileColors(
          background: const Color(0xFF514078),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appBlue: AnimalTileColors(
          background: const Color(0xFF31566F),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appYellow: AnimalTileColors(
          background: const Color(0xFF71530F),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appOrange: AnimalTileColors(
          background: const Color(0xFF78472D),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appTeal: AnimalTileColors(
          background: const Color(0xFF285B56),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appGreen: AnimalTileColors(
          background: const Color(0xFF315A3B),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.appRed: AnimalTileColors(
          background: const Color(0xFF823A3D),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.limeGreen: AnimalTileColors(
          background: const Color(0xFF4D581E),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.yellowGreen: AnimalTileColors(
          background: const Color(0xFF5B531E),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.brown: AnimalTileColors(
          background: const Color(0xFF574635),
          foreground: const Color(0xFFFFFFFF),
        ),
        AnimalTileColor.warmPeachPink: AnimalTileColors(
          background: const Color(0xFF774337),
          foreground: const Color(0xFFFFFFFF),
        ),
      },
    ),
    typography: base.typography.copyWith(
      fontFamily: 'packages/animal_island_ui/Noto Sans SC',
      fontFamilyFallback: const <String>[
        'packages/animal_island_ui/Nunito',
        'sans-serif',
      ],
      title: base.typography.title.copyWith(
        fontSize: 28.3,
        letterSpacing: 0.37,
      ),
      heading: base.typography.heading.copyWith(
        fontSize: 23.7,
        letterSpacing: 0.29,
      ),
      subheading: base.typography.subheading.copyWith(
        fontSize: 18.4,
        wordSpacing: 0.43,
      ),
      button: base.typography.button.copyWith(
        fontSize: 16.8,
        wordSpacing: 0.31,
      ),
      body: base.typography.body.copyWith(
        fontSize: 16.2,
        letterSpacing: 0.41,
        wordSpacing: 0.27,
      ),
      secondary: base.typography.secondary.copyWith(
        fontSize: 14.7,
        wordSpacing: 0.28,
      ),
      caption: base.typography.caption.copyWith(
        fontSize: 13.6,
        letterSpacing: 0.33,
      ),
      code: base.typography.code.copyWith(fontSize: 14.8, wordSpacing: 0.35),
      countdown: base.typography.countdown.copyWith(
        fontSize: 31.4,
        letterSpacing: 0.21,
      ),
      digitLarge: base.typography.digitLarge.copyWith(
        fontSize: 39.6,
        wordSpacing: 0.19,
      ),
    ),
    radii: base.radii.copyWith(pill: 27.3, card: 11.7, tooltip: 7.4, sm: 5.6),
    spacing: base.spacing.copyWith(
      xxs: 3.1,
      xs: 5.2,
      sm: 9.3,
      md: 13.4,
      lg: 17.6,
      xl: 25.7,
      xxl: 34.9,
    ),
    shadows: base.shadows.copyWith(
      button3d: const BoxShadow(
        color: Color(0xFF31566F),
        offset: Offset(0, 7),
        blurRadius: 1.7,
        spreadRadius: 0.4,
      ),
      input3d: const BoxShadow(
        color: Color(0xFF514C64),
        offset: Offset(0, 4),
        blurRadius: 1.3,
      ),
      softElevation: const BoxShadow(
        color: Color(0x4031546F),
        offset: Offset(0, 6),
        blurRadius: 9.7,
        spreadRadius: 0.6,
      ),
      modal: const <BoxShadow>[
        BoxShadow(
          color: Color(0x6631546F),
          offset: Offset(0, 11),
          blurRadius: 26.3,
          spreadRadius: 0.7,
        ),
        BoxShadow(
          color: Color(0x3331546F),
          offset: Offset(0, 3),
          blurRadius: 8.4,
        ),
      ],
    ),
    motion: base.motion.copyWith(
      ease: const Cubic(0.18, 0.72, 0.25, 0.98),
      spring: Curves.easeInOutCubic,
      fast: const Duration(milliseconds: 173),
      normal: const Duration(milliseconds: 287),
      slow: const Duration(milliseconds: 433),
    ),
  );
}

/// The canonical themes for real foreground/background component probes.
///
/// Each variant is rendered independently so a component's semantic roles are
/// checked against both shipped palettes and a fully customized consumer theme.
List<AnimalIslandTheme> animalIslandThemeVariants() => <AnimalIslandTheme>[
  AnimalIslandTheme.light,
  AnimalIslandTheme.dark,
  thirdAnimalIslandTheme(),
];
