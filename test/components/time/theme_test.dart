import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C29 AnimalTime renders themed card spacing and typography', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ValueKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalTime(time: DateTime(2026, 1, 1, 12, 34, 56)),
          ),
        ),
      );

      final card = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AnimalTime),
              matching: find.byType(Container),
            )
            .first,
      );
      final clock = tester.widget<Text>(find.text('12:34:56'));
      final icon = tester.widget<AnimalIcon>(find.byType(AnimalIcon));
      expect(
        card.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.lg + theme.spacing.xxs,
          vertical: theme.spacing.md,
        ),
      );
      expect(clock.style?.fontSize, theme.typography.heading.fontSize! * 0.9);
      expect(clock.style?.color, theme.colors.text);
      expect((card.decoration! as BoxDecoration).color, theme.colors.bgContent);
      expect(icon.color, theme.colors.primaryText);
      expect(
        (card.decoration! as BoxDecoration).border!.top.color,
        theme.colors.border,
      );
      expect(
        themeContrastRatio(
          clock.style!.color!,
          (card.decoration! as BoxDecoration).color!,
        ),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        themeContrastRatio(
          icon.color!,
          (card.decoration! as BoxDecoration).color!,
        ),
        greaterThanOrEqualTo(3),
      );
      expect(
        (card.decoration! as BoxDecoration).borderRadius,
        theme.radii.cardBorder,
      );
    }
  });
}
