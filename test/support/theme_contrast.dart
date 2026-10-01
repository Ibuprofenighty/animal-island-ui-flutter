import 'package:flutter/material.dart';

/// WCAG contrast for the color a rendered text foreground produces on its
/// actual opaque surface, including alpha-composited foregrounds.
double themeContrastRatio(Color foreground, Color background) {
  if (background.a != 1) {
    throw ArgumentError.value(
      background,
      'background',
      'must be the fully composited opaque surface',
    );
  }
  final Color renderedForeground = Color.alphaBlend(foreground, background);
  final double foregroundLuminance = renderedForeground.computeLuminance();
  final double backgroundLuminance = background.computeLuminance();
  final double lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final double darker = foregroundLuminance < backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
