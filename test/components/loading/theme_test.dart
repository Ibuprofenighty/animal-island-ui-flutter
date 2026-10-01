import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C25 AnimalLoading renders themed indicator and tip surface', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ValueKey(theme),
          theme: theme.toThemeData(),
          home: const Scaffold(body: AnimalLoading(tip: 'Preparing island')),
        ),
      );

      final icon = tester.widget<AnimalIcon>(find.byType(AnimalIcon).first);
      final tip = tester.widget<Text>(find.text('Preparing island'));
      final tipContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Preparing island'),
              matching: find.byType(Container),
            )
            .first,
      );
      expect(icon.color, theme.colors.primaryText);
      expect(
        themeContrastRatio(icon.color!, theme.colors.bg),
        greaterThanOrEqualTo(3),
      );
      expect(tip.style?.fontSize, theme.typography.caption.fontSize);
      final tipDecoration = tipContainer.decoration! as BoxDecoration;
      expect(
        tipDecoration.color,
        theme.colors.bgContent.withValues(alpha: 0.9),
      );
      expect(tip.style?.color, theme.colors.text);
      expect(tipDecoration.borderRadius, theme.radii.pillBorder);
      expect(
        themeContrastRatio(
          tip.style!.color!,
          Color.alphaBlend(tipDecoration.color!, theme.colors.bg),
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        tipContainer.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.md + theme.spacing.xxs,
          vertical: theme.spacing.sm - theme.spacing.xxs,
        ),
      );
      expect(tipDecoration.boxShadow, [theme.shadows.softElevation]);
      final animation =
          tester
                  .widget<AnimatedBuilder>(
                    find
                        .descendant(
                          of: find.byType(AnimalLoading),
                          matching: find.byType(AnimatedBuilder),
                        )
                        .first,
                  )
                  .animation
              as AnimationController;
      expect(animation.duration, theme.motion.normal * (1200 / 250));
    }
  });
}
