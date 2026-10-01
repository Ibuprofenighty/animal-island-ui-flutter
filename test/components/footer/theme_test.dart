import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C36 AnimalFooter renders themed body spacing and surface color',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey(theme),
            theme: theme.toThemeData(),
            home: const Scaffold(
              body: AnimalFooter(defaultText: 'Island community'),
            ),
          ),
        );

        final footerText = find.text('Island community');
        final body = tester.widget<Container>(
          find.ancestor(of: footerText, matching: find.byType(Container)).first,
        );
        final textStyle = tester.widget<Text>(footerText).style!;
        final icon = tester.widget<AnimalIcon>(find.byType(AnimalIcon));
        expect(
          body.padding,
          EdgeInsets.symmetric(
            vertical: theme.spacing.xl,
            horizontal: theme.spacing.lg + theme.spacing.xs,
          ),
        );
        expect(body.color, theme.colors.surfaceSubtle);
        expect(textStyle.color, theme.colors.textSecondary);
        expect(textStyle.fontSize, theme.typography.caption.fontSize);
        expect(
          themeContrastRatio(textStyle.color!, body.color!),
          greaterThanOrEqualTo(4.5),
        );
        expect(icon.color, theme.colors.primaryText);
        expect(
          themeContrastRatio(icon.color!, body.color!),
          greaterThanOrEqualTo(3),
        );
        expect(
          tester.getSize(find.byType(SizedBox).last).width,
          theme.spacing.sm,
        );
      }
    },
  );
}
