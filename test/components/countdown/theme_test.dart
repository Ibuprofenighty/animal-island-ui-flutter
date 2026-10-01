import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C28 AnimalCountdown renders themed digits, radius and shadow', (
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
            body: AnimalCountdown(remaining: Duration(hours: 12)),
          ),
        ),
      );

      final digit = tester.widget<Text>(find.text('12'));
      final tile = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(AnimalCountdown),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = tile.decoration! as BoxDecoration;
      expect(decoration.color, theme.colors.bgContent);
      expect(
        digit.style?.fontSize,
        theme.typography.countdown.fontSize! * (22 / 28),
      );
      expect(
        decoration.borderRadius,
        BorderRadius.circular(theme.radii.sm * (7 / 6)),
      );
      expect(decoration.boxShadow, [theme.shadows.input3d]);
      expect(digit.style?.color, theme.colors.text);
      expect(
        themeContrastRatio(digit.style!.color!, decoration.color!),
        greaterThanOrEqualTo(4.5),
      );
      final unit = tester.widget<Text>(find.text('HOURS'));
      expect(unit.style?.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(unit.style!.color!, theme.colors.bg),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}
