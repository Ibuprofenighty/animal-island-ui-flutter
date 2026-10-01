import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/theme_fixtures.dart';

void main() {
  group('AnimalIslandTheme', () {
    test('presets compose the six family-owned defaults', () {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      final AnimalIslandTheme dark = AnimalIslandTheme.dark;

      expect(light.colors, same(AnimalThemeColors.light));
      expect(light.typography, same(AnimalThemeTypography.standard));
      expect(light.radii, same(AnimalThemeRadii.standard));
      expect(light.spacing, same(AnimalThemeSpacing.standard));
      expect(light.shadows, same(AnimalThemeShadows.light));
      expect(light.motion, same(AnimalThemeMotion.standard));
      expect(dark.colors, same(AnimalThemeColors.dark));
      expect(dark.shadows, same(AnimalThemeShadows.dark));
      expect(light.copyWith(), light);
      expect(light.copyWith().hashCode, light.hashCode);
      expect(dark.copyWith(), dark);
    });

    test(
      'ThemeData bridge uses resolved tokens and registers this extension',
      () {
        final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
          typography: AnimalThemeTypography.standard.copyWith(
            fontFamily: 'Test Family',
            fontFamilyFallback: const <String>['Test Fallback'],
          ),
        );
        final ThemeData data = theme.toThemeData();

        expect(data.extension<AnimalIslandTheme>(), same(theme));
        expect(data.brightness, Brightness.light);
        expect(data.colorScheme.primary, theme.colors.primary);
        expect(data.colorScheme.onPrimary, theme.colors.onPrimary);
        expect(data.colorScheme.secondary, isNot(theme.colors.primary));
        expect(data.colorScheme.onSecondary, isNot(theme.colors.onPrimary));
        expect(data.textTheme.bodyMedium!.fontFamily, 'Test Family');
        expect(data.textTheme.bodyMedium!.fontFamilyFallback, <String>[
          'Test Fallback',
        ]);
      },
    );

    test('typography resolves the active family for direct painters', () {
      final AnimalThemeTypography typography = thirdAnimalIslandTheme()
          .typography
          .copyWith(
            fontFamily: 'Painter Family',
            fontFamilyFallback: const <String>['Painter Fallback'],
          );
      final TextStyle inherited = typography.resolve(
        const TextStyle(fontSize: 18),
      );
      final TextStyle explicit = typography.resolve(
        const TextStyle(
          fontSize: 18,
          fontFamily: 'Explicit Code Family',
          fontFamilyFallback: <String>['Explicit Code Fallback'],
        ),
      );

      expect(inherited.fontFamily, 'Painter Family');
      expect(inherited.fontFamilyFallback, <String>['Painter Fallback']);
      expect(explicit.fontFamily, 'Explicit Code Family');
      expect(explicit.fontFamilyFallback, <String>['Explicit Code Fallback']);
      expect(AnimalThemeTypography.standard.code.fontFamily, 'monospace');
    });

    test('tile color pairs copy and interpolate both owned colors', () {
      const AnimalTileColors first = AnimalTileColors(
        background: Color(0xFF102030),
        foreground: Color(0xFFE0D0C0),
      );
      const AnimalTileColors second = AnimalTileColors(
        background: Color(0xFF90A0B0),
        foreground: Color(0xFF203040),
      );

      expect(
        first.copyWith(background: Colors.black),
        const AnimalTileColors(
          background: Colors.black,
          foreground: Color(0xFFE0D0C0),
        ),
      );
      expect(
        first.copyWith(foreground: Colors.white),
        const AnimalTileColors(
          background: Color(0xFF102030),
          foreground: Colors.white,
        ),
      );
      expect(AnimalTileColors.lerp(first, second, 0), same(first));
      expect(AnimalTileColors.lerp(first, second, 1), same(second));

      const double t = 0.37;
      final AnimalTileColors midpoint = AnimalTileColors.lerp(first, second, t);
      expect(
        midpoint.background,
        Color.lerp(first.background, second.background, t),
      );
      expect(
        midpoint.foreground,
        Color.lerp(first.foreground, second.foreground, t),
      );
    });

    testWidgets('of requires the explicit Animal Island extension', (
      WidgetTester tester,
    ) async {
      Object? error;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              try {
                AnimalIslandTheme.of(context);
              } on Object catch (caught) {
                error = caught;
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(error, isA<StateError>());
    });

    testWidgets('of resolves the explicitly installed theme', (
      WidgetTester tester,
    ) async {
      late AnimalIslandTheme resolved;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.dark.toThemeData(),
          home: Builder(
            builder: (BuildContext context) {
              resolved = AnimalIslandTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolved, AnimalIslandTheme.dark);
    });

    test('copyWith and lerp retain immutable value and exact endpoints', () {
      final AnimalIslandTheme first = AnimalIslandTheme.light;
      final AnimalIslandTheme second = thirdAnimalIslandTheme();

      expect(first.lerp(second, 0), same(first));
      expect(first.lerp(second, 1), same(second));
      expect(first.colors.lerp(second.colors, 0), same(first.colors));
      expect(first.colors.lerp(second.colors, 1), same(second.colors));
      expect(
        first.typography.lerp(second.typography, 0),
        same(first.typography),
      );
      expect(
        first.typography.lerp(second.typography, 1),
        same(second.typography),
      );
      expect(first.radii.lerp(second.radii, 0), same(first.radii));
      expect(first.radii.lerp(second.radii, 1), same(second.radii));
      expect(first.spacing.lerp(second.spacing, 0), same(first.spacing));
      expect(first.spacing.lerp(second.spacing, 1), same(second.spacing));
      expect(first.shadows.lerp(second.shadows, 0), same(first.shadows));
      expect(first.shadows.lerp(second.shadows, 1), same(second.shadows));
      expect(first.motion.lerp(second.motion, 0), same(first.motion));
      expect(first.motion.lerp(second.motion, 1), same(second.motion));

      final AnimalIslandTheme midpoint = first.lerp(second, 0.37);
      expect(midpoint, isNot(first));
      expect(
        midpoint.radii.card,
        closeTo(20 + (second.radii.card - 20) * 0.37, 1e-12),
      );
      expect(
        midpoint.spacing.md,
        closeTo(12 + (second.spacing.md - 12) * 0.37, 1e-12),
      );
      expect(midpoint.typography.body.letterSpacing, isNotNull);
      expect(midpoint.typography.body.wordSpacing, isNotNull);
      expect(first.copyWith(colors: second.colors), isNot(first));
    });

    test('copyWith exposes every public token field', () {
      final AnimalThemeColors colors = AnimalThemeColors.light;
      _expectAllChanged(colors, <Object>[
        colors.copyWith(brightness: Brightness.dark),
        colors.copyWith(primary: Colors.black),
        colors.copyWith(primaryActive: Colors.black),
        colors.copyWith(primaryBg: Colors.black),
        colors.copyWith(onPrimary: Colors.black),
        colors.copyWith(primaryText: Colors.black),
        colors.copyWith(success: Colors.black),
        colors.copyWith(successBg: Colors.black),
        colors.copyWith(onSuccess: Colors.black),
        colors.copyWith(successText: Colors.black),
        colors.copyWith(warning: Colors.black),
        colors.copyWith(warningBg: Colors.black),
        colors.copyWith(onWarning: Colors.black),
        colors.copyWith(warningText: Colors.black),
        colors.copyWith(error: Colors.black),
        colors.copyWith(errorBg: Colors.black),
        colors.copyWith(onError: Colors.black),
        colors.copyWith(errorText: Colors.black),
        colors.copyWith(info: Colors.black),
        colors.copyWith(infoBg: Colors.black),
        colors.copyWith(infoText: Colors.black),
        colors.copyWith(text: Colors.black),
        colors.copyWith(textBody: Colors.black),
        colors.copyWith(textSecondary: Colors.black),
        colors.copyWith(textMuted: Colors.black),
        colors.copyWith(textDisabled: Colors.black),
        colors.copyWith(bg: Colors.black),
        colors.copyWith(bgContent: Colors.black),
        colors.copyWith(bgInput: Colors.black),
        colors.copyWith(bgSecondary: Colors.black),
        colors.copyWith(bgDisabled: Colors.black),
        colors.copyWith(bgInputDisabled: Colors.black),
        colors.copyWith(border: Colors.black),
        colors.copyWith(borderLight: Colors.black),
        colors.copyWith(focusYellow: Colors.black),
        colors.copyWith(surfaceHeader: Colors.black),
        colors.copyWith(surfaceAlt: Colors.black),
        colors.copyWith(surfaceSubtle: Colors.black),
        for (final AnimalTileColor color in AnimalTileColor.values)
          colors.copyWith(
            tileColors: <AnimalTileColor, AnimalTileColors>{
              ...colors.tileColors,
              color: colors.tile(color).copyWith(background: Colors.black),
            },
          ),
      ]);

      final AnimalThemeTypography typography = AnimalThemeTypography.standard;
      _expectAllChanged(typography, <Object>[
        typography.copyWith(fontFamily: 'Changed Family'),
        typography.copyWith(fontFamilyFallback: const <String>['Changed']),
        typography.copyWith(title: typography.title.copyWith(fontSize: 71)),
        typography.copyWith(heading: typography.heading.copyWith(fontSize: 71)),
        typography.copyWith(
          subheading: typography.subheading.copyWith(fontSize: 71),
        ),
        typography.copyWith(button: typography.button.copyWith(fontSize: 71)),
        typography.copyWith(body: typography.body.copyWith(fontSize: 71)),
        typography.copyWith(
          secondary: typography.secondary.copyWith(fontSize: 71),
        ),
        typography.copyWith(caption: typography.caption.copyWith(fontSize: 71)),
        typography.copyWith(code: typography.code.copyWith(fontSize: 71)),
        typography.copyWith(
          countdown: typography.countdown.copyWith(fontSize: 71),
        ),
        typography.copyWith(
          digitLarge: typography.digitLarge.copyWith(fontSize: 71),
        ),
      ]);

      final AnimalThemeRadii radii = AnimalThemeRadii.standard;
      _expectAllChanged(radii, <Object>[
        radii.copyWith(pill: 51.1),
        radii.copyWith(card: 21.1),
        radii.copyWith(tooltip: 17.1),
        radii.copyWith(sm: 13.1),
      ]);

      final AnimalThemeSpacing spacing = AnimalThemeSpacing.standard;
      _expectAllChanged(spacing, <Object>[
        spacing.copyWith(xxs: 2.1),
        spacing.copyWith(xs: 4.1),
        spacing.copyWith(sm: 8.1),
        spacing.copyWith(md: 12.1),
        spacing.copyWith(lg: 16.1),
        spacing.copyWith(xl: 24.1),
        spacing.copyWith(xxl: 32.1),
      ]);

      final AnimalThemeShadows shadows = AnimalThemeShadows.light;
      _expectAllChanged(shadows, <Object>[
        shadows.copyWith(button3d: const BoxShadow(color: Colors.black)),
        shadows.copyWith(input3d: const BoxShadow(color: Colors.black)),
        shadows.copyWith(softElevation: const BoxShadow(color: Colors.black)),
        shadows.copyWith(
          modal: const <BoxShadow>[BoxShadow(color: Colors.black)],
        ),
      ]);

      final AnimalThemeMotion motion = AnimalThemeMotion.standard;
      _expectAllChanged(motion, <Object>[
        motion.copyWith(ease: Curves.linear),
        motion.copyWith(spring: Curves.linear),
        motion.copyWith(fast: const Duration(milliseconds: 151)),
        motion.copyWith(normal: const Duration(milliseconds: 251)),
        motion.copyWith(slow: const Duration(milliseconds: 351)),
      ]);

      final AnimalIslandTheme theme = AnimalIslandTheme.light;
      final AnimalIslandTheme alternate = thirdAnimalIslandTheme();
      _expectAllChanged(theme, <Object>[
        theme.copyWith(colors: AnimalThemeColors.dark),
        theme.copyWith(typography: alternate.typography),
        theme.copyWith(radii: alternate.radii),
        theme.copyWith(spacing: alternate.spacing),
        theme.copyWith(shadows: alternate.shadows),
        theme.copyWith(motion: alternate.motion),
      ]);
    });

    test(
      'family values freeze owned collections and reject invalid values',
      () {
        final AnimalThemeColors colors = AnimalThemeColors.light.copyWith();
        expect(colors, AnimalThemeColors.light);
        expect(colors.hashCode, AnimalThemeColors.light.hashCode);
        expect(
          AnimalTileColors(background: Colors.red, foreground: Colors.white),
          AnimalTileColors(background: Colors.red, foreground: Colors.white),
        );
        expect(
          AnimalThemeTypography.standard.copyWith(),
          AnimalThemeTypography.standard,
        );
        expect(
          AnimalThemeTypography.standard.copyWith().hashCode,
          AnimalThemeTypography.standard.hashCode,
        );
        expect(AnimalThemeRadii.standard.copyWith(), AnimalThemeRadii.standard);
        expect(
          AnimalThemeRadii.standard.copyWith().hashCode,
          AnimalThemeRadii.standard.hashCode,
        );
        expect(
          AnimalThemeSpacing.standard.copyWith(),
          AnimalThemeSpacing.standard,
        );
        expect(
          AnimalThemeSpacing.standard.copyWith().hashCode,
          AnimalThemeSpacing.standard.hashCode,
        );
        expect(AnimalThemeShadows.light.copyWith(), AnimalThemeShadows.light);
        expect(
          AnimalThemeShadows.light.copyWith().hashCode,
          AnimalThemeShadows.light.hashCode,
        );
        expect(
          AnimalThemeMotion.standard.copyWith(),
          AnimalThemeMotion.standard,
        );
        expect(
          AnimalThemeMotion.standard.copyWith().hashCode,
          AnimalThemeMotion.standard.hashCode,
        );
        expect(
          () => colors.tileColors[AnimalTileColor.def] = const AnimalTileColors(
            background: Colors.black,
            foreground: Colors.white,
          ),
          throwsUnsupportedError,
        );
        expect(
          () => AnimalThemeColors.light.copyWith(
            tileColors: const <AnimalTileColor, AnimalTileColors>{},
          ),
          throwsArgumentError,
        );
        expect(
          () => AnimalThemeRadii.standard.copyWith(card: double.nan),
          throwsArgumentError,
        );
        expect(
          () => AnimalThemeSpacing.standard.copyWith(md: double.infinity),
          throwsArgumentError,
        );
        expect(
          () => AnimalThemeTypography.standard.copyWith(fontFamily: '  '),
          throwsArgumentError,
        );
        expect(
          () => AnimalThemeTypography.standard.copyWith(
            body: const TextStyle(fontSize: double.nan),
          ),
          throwsArgumentError,
        );
        expect(
          () => AnimalThemeMotion.standard.copyWith(
            fast: Duration(microseconds: -1),
          ),
          throwsArgumentError,
        );

        final List<BoxShadow> mutableShadows = <BoxShadow>[
          BoxShadow(color: Colors.black),
        ];
        final AnimalThemeShadows shadows = AnimalThemeShadows.light.copyWith(
          modal: mutableShadows,
        );
        mutableShadows.clear();
        expect(shadows.modal, hasLength(1));
        expect(() => shadows.modal.clear(), throwsUnsupportedError);

        final List<String> mutableFallback = <String>['Fallback'];
        final AnimalThemeTypography typography = AnimalThemeTypography.standard
            .copyWith(fontFamilyFallback: mutableFallback);
        mutableFallback.add('Later Mutation');
        expect(typography.fontFamilyFallback, <String>['Fallback']);
      },
    );
  });
}

void _expectAllChanged(Object original, List<Object> changedValues) {
  for (final Object changed in changedValues) {
    expect(changed, isNot(original));
  }
}
