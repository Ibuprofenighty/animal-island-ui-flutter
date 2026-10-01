import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C32 AnimalPagination renders themed button shape and spacing', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ValueKey(theme),
          theme: theme.toThemeData(),
          home: const Scaffold(
            body: AnimalPagination(
              current: 2,
              total: 100,
              onChanged: _ignorePage,
            ),
          ),
        ),
      );

      final button = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.byType(AnimalPagination),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final decoration = button.decoration! as BoxDecoration;
      expect(
        button.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.md,
          vertical: theme.spacing.sm,
        ),
      );
      expect(decoration.borderRadius, theme.radii.pillBorder);
      expect(decoration.boxShadow, [theme.shadows.button3d]);
      expect(
        tester.widget<Text>(find.text('2')).style?.fontSize,
        theme.typography.button.fontSize! * (14 / 15),
      );
      expect(
        tester.widget<Text>(find.text('2')).style?.color,
        theme.colors.onPrimary,
      );
      final selectedText = tester.widget<Text>(find.text('2'));
      final selectedSurface = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('2'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final selectedBackground =
          (selectedSurface.decoration! as BoxDecoration).color!;
      expect(selectedBackground, theme.colors.primary);
      expect(
        themeContrastRatio(selectedText.style!.color!, selectedBackground),
        greaterThanOrEqualTo(4.5),
      );

      final unselectedText = tester.widget<Text>(find.text('1'));
      final unselectedSurface = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('1'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final unselectedBackground =
          (unselectedSurface.decoration! as BoxDecoration).color!;
      expect(unselectedBackground, theme.colors.bgContent);
      expect(unselectedText.style?.color, theme.colors.text);
      expect(
        themeContrastRatio(unselectedText.style!.color!, unselectedBackground),
        greaterThanOrEqualTo(4.5),
      );

      final ellipsis = tester.widget<Text>(find.text('•••'));
      final ellipsisSurface = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('•••'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final ellipsisBackground =
          (ellipsisSurface.decoration! as BoxDecoration).color!;
      expect(ellipsisBackground, theme.colors.bgContent);
      expect(ellipsis.style?.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(ellipsis.style!.color!, ellipsisBackground),
        greaterThanOrEqualTo(4.5),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalPagination(
              current: 2,
              total: 100,
              disabled: true,
              onChanged: _ignorePage,
            ),
          ),
        ),
      );
      final disabledPageText = tester.widget<Text>(find.text('1'));
      final disabledPageSurface = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.text('1'),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(disabledPageText.style?.color, theme.colors.textDisabled);
      expect(
        (disabledPageSurface.decoration! as BoxDecoration).color,
        theme.colors.surfaceAlt,
      );
      expect(
        themeContrastRatio(
          disabledPageText.style!.color!,
          (disabledPageSurface.decoration! as BoxDecoration).color!,
        ),
        greaterThanOrEqualTo(4.5),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalPagination(
              current: 1,
              total: 100,
              onChanged: _ignorePage,
            ),
          ),
        ),
      );
      final leadingIcon = tester.widget<AnimalIcon>(
        find.byType(AnimalIcon).first,
      );
      final leadingButton = tester.widget<AnimatedContainer>(
        find
            .ancestor(
              of: find.byType(AnimalIcon).first,
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(leadingIcon.color, theme.colors.textDisabled);
      expect(
        (leadingButton.decoration! as BoxDecoration).color,
        theme.colors.surfaceAlt,
      );
      expect(
        themeContrastRatio(
          leadingIcon.color!,
          (leadingButton.decoration! as BoxDecoration).color!,
        ),
        greaterThanOrEqualTo(3),
      );
    }
  });
}

void _ignorePage(int _) {}
