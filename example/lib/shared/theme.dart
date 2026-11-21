import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

// hhea ascent / descent per 1000 units of the Gallery stack: Nunito first,
// then the Noto Sans SC CJK fallback (IslandGallerySans).
const _nunitoAscent = 1.011, _nunitoDescent = .353;
const _cjkAscent = 1.160, _cjkDescent = .288;

/// Browser `line-height: normal` for one line of Gallery text at
/// [fontSize] whose stack is Nunito with the CJK fallback (no explicit
/// line-height in the reference). The browser rounds each used font's
/// ascent and descent to whole pixels and takes the maxima, keeping the
/// Nunito strut even on a line set only in the fallback, so a 12px line is
/// 18px with its baseline 14px below the top (Nunito 12/4, CJK 14/3) for
/// any mix of Latin and CJK; Flutter's paragraph sizes a mixed line by the
/// fractional sum instead (19px at 12px). With even half-leading the
/// baseline is line / 2 + size * (ascent - descent) / 2, and the Nunito
/// strut size below solves it for the rounded ascent.
StrutStyle galleryNormalLine(double fontSize) {
  final ascent = math.max(
    (fontSize * _nunitoAscent).round(),
    (fontSize * _cjkAscent).round(),
  );
  final descent = math.max(
    (fontSize * _nunitoDescent).round(),
    (fontSize * _cjkDescent).round(),
  );
  final line = (ascent + descent).toDouble();
  final strutSize = 2 * (ascent - line / 2) / (_nunitoAscent - _nunitoDescent);
  return StrutStyle(
    fontFamily: 'Nunito',
    fontSize: strutSize,
    height: line / strutSize,
    leadingDistribution: TextLeadingDistribution.even,
    forceStrutHeight: true,
  );
}

ThemeData galleryTheme() => IslandTheme.create(fontFamily: 'Nunito').copyWith(
  textTheme: IslandTheme.create(fontFamily: 'Nunito').textTheme
      .merge(
        const TextTheme(
          displayLarge: TextStyle(letterSpacing: 0),
          displayMedium: TextStyle(letterSpacing: 0),
          displaySmall: TextStyle(letterSpacing: 0),
          headlineLarge: TextStyle(letterSpacing: 0),
          headlineMedium: TextStyle(letterSpacing: 0),
          headlineSmall: TextStyle(letterSpacing: 0),
          titleLarge: TextStyle(letterSpacing: 0),
          titleMedium: TextStyle(letterSpacing: 0),
          titleSmall: TextStyle(letterSpacing: 0),
          bodyLarge: TextStyle(letterSpacing: 0),
          bodyMedium: TextStyle(letterSpacing: 0),
          bodySmall: TextStyle(letterSpacing: 0),
          labelLarge: TextStyle(letterSpacing: 0),
          labelMedium: TextStyle(letterSpacing: 0),
          labelSmall: TextStyle(letterSpacing: 0),
        ),
      )
      .apply(fontFamilyFallback: const ['IslandGallerySans']),
);
