import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/theme_fixtures.dart';
import '../support/theme_contrast.dart';

void main() {
  test('light and dark theme text pairs meet measured contrast thresholds', () {
    for (final AnimalIslandTheme theme in <AnimalIslandTheme>[
      AnimalIslandTheme.light,
      AnimalIslandTheme.dark,
      thirdAnimalIslandTheme(),
    ]) {
      final AnimalThemeColors colors = theme.colors;
      final List<_Pair> pairs = <_Pair>[
        _Pair('primary', colors.onPrimary, colors.primary),
        _Pair('success', colors.onSuccess, colors.success),
        _Pair('warning', colors.onWarning, colors.warning),
        _Pair('error', colors.onError, colors.error),
        _Pair('primary surface text', colors.primaryText, colors.bgContent),
        _Pair('success surface text', colors.successText, colors.bgContent),
        _Pair('warning surface text', colors.warningText, colors.bgContent),
        _Pair('error surface text', colors.errorText, colors.bgContent),
        _Pair('info surface text', colors.infoText, colors.bgContent),
        _Pair('button surface primary text', colors.primaryText, colors.bg),
        _Pair(
          'AnimalTag primary surface text',
          colors.primaryText,
          colors.primaryBg,
        ),
        _Pair(
          'AnimalTag success surface text',
          colors.successText,
          colors.successBg,
        ),
        _Pair(
          'AnimalTag warning surface text',
          colors.warningText,
          colors.warningBg,
        ),
        _Pair('AnimalTag error surface text', colors.errorText, colors.errorBg),
        _Pair('AnimalTag info surface text', colors.infoText, colors.infoBg),
        _Pair('primary.background', colors.text, colors.primaryBg),
        _Pair('success.background', colors.text, colors.successBg),
        _Pair('warning.background', colors.text, colors.warningBg),
        _Pair('error.background', colors.text, colors.errorBg),
        _Pair('info.background', colors.text, colors.infoBg),
        _Pair('text/background', colors.text, colors.bg),
        _Pair('body/content', colors.textBody, colors.bgContent),
        _Pair('secondary/content', colors.textSecondary, colors.bgContent),
        _Pair('muted/secondary-surface', colors.textMuted, colors.bgSecondary),
        _Pair(
          'disabled/disabled-surface',
          colors.textDisabled,
          colors.bgDisabled,
        ),
        for (final AnimalTileColor identity in AnimalTileColor.values)
          _Pair(
            'tile.$identity',
            colors.tile(identity).foreground,
            colors.tile(identity).background,
          ),
      ];

      for (final _Pair pair in pairs) {
        expect(
          themeContrastRatio(pair.foreground, pair.background),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.colors.brightness} ${pair.name}',
        );
      }
    }
  });

  test('Material color scheme generated foreground pairs are measured', () {
    for (final AnimalIslandTheme theme in <AnimalIslandTheme>[
      AnimalIslandTheme.light,
      AnimalIslandTheme.dark,
      thirdAnimalIslandTheme(),
    ]) {
      final ColorScheme scheme = theme.toThemeData().colorScheme;
      final List<_Pair> pairs = <_Pair>[
        _Pair('primary', scheme.onPrimary, scheme.primary),
        _Pair('secondary', scheme.onSecondary, scheme.secondary),
        _Pair('tertiary', scheme.onTertiary, scheme.tertiary),
        _Pair('error', scheme.onError, scheme.error),
        _Pair(
          'primaryContainer',
          scheme.onPrimaryContainer,
          scheme.primaryContainer,
        ),
        _Pair('errorContainer', scheme.onErrorContainer, scheme.errorContainer),
        _Pair('surface', scheme.onSurface, scheme.surface),
      ];
      for (final _Pair pair in pairs) {
        expect(
          themeContrastRatio(pair.foreground, pair.background),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.colors.brightness} ColorScheme.${pair.name}',
        );
      }
    }
  });

  test('contrast oracle requires the fully composited opaque surface', () {
    expect(
      () => themeContrastRatio(Colors.black, Colors.transparent),
      throwsArgumentError,
    );
  });

  test('default radii, spacing and tactile depth have explicit owners', () {
    expect(AnimalThemeRadii.standard.pill, 50);
    expect(AnimalThemeRadii.standard.card, 20);
    expect(AnimalThemeRadii.standard.sm, 12);
    expect(AnimalThemeSpacing.standard.xs, 4);
    expect(AnimalThemeSpacing.standard.sm, 8);
    expect(AnimalThemeSpacing.standard.md, 12);
    expect(AnimalThemeSpacing.standard.lg, 16);
    expect(AnimalThemeSpacing.standard.xl, 24);
    expect(AnimalThemeSpacing.standard.xxl, 32);
    expect(AnimalThemeShadows.light.button3d.offset.dy, 5);
    expect(AnimalThemeShadows.light.button3d.blurRadius, 0);
  });
}

class _Pair {
  const _Pair(this.name, this.foreground, this.background);

  final String name;
  final Color foreground;
  final Color background;
}
