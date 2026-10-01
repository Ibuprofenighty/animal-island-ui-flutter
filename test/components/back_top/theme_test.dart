import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C27 AnimalBackTop renders themed button shape, padding and fade',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        final controller = ScrollController();
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: controller,
                    child: const SizedBox(height: 1000),
                  ),
                  AnimalBackTop(
                    scrollController: controller,
                    visibilityHeight: 0,
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pump();

        final backTop = find.byType(AnimalBackTop);
        final button = tester.widget<AnimatedContainer>(
          find
              .descendant(of: backTop, matching: find.byType(AnimatedContainer))
              .first,
        );
        final fade = tester.widget<AnimatedOpacity>(
          find.descendant(of: backTop, matching: find.byType(AnimatedOpacity)),
        );
        final icon = tester.widget<AnimalIcon>(find.byType(AnimalIcon));
        expect(button.padding, EdgeInsets.all(theme.spacing.md));
        expect(
          (button.decoration! as BoxDecoration).color,
          theme.colors.bgContent,
        );
        expect(icon.color, theme.colors.primaryText);
        expect(
          themeContrastRatio(
            icon.color!,
            (button.decoration! as BoxDecoration).color!,
          ),
          greaterThanOrEqualTo(3),
        );
        expect(
          (button.decoration! as BoxDecoration).borderRadius,
          theme.radii.pillBorder,
        );
        expect(fade.duration, theme.motion.normal);
        controller.dispose();
      }
    },
  );
}
