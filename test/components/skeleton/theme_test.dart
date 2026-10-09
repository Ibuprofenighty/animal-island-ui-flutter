import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C26 AnimalSkeleton renders themed shimmer color, radius and timing',
    (tester) async {
      final theme = thirdAnimalIslandTheme();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: theme.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalSkeleton(
                  key: const ValueKey('rect-skeleton'),
                  width: 120,
                  height: 32,
                  active: true,
                ),
                AnimalSkeleton.paragraph(
                  key: ValueKey('paragraph-skeleton'),
                  rows: 3,
                ),
              ],
            ),
          ),
        ),
      );

      final skeleton = find.byKey(const ValueKey('rect-skeleton'));
      final animation =
          tester
                  .widget<AnimatedBuilder>(
                    find.descendant(
                      of: skeleton,
                      matching: find.byType(AnimatedBuilder),
                    ),
                  )
                  .animation
              as AnimationController;
      final block = tester.widget<Container>(
        find.descendant(of: skeleton, matching: find.byType(Container)).first,
      );
      final decoration = block.decoration! as BoxDecoration;
      final gradient = decoration.gradient! as LinearGradient;
      expect(animation.duration, theme.motion.slow * (1400 / 350));
      expect(gradient.colors, [
        theme.colors.bgDisabled,
        theme.colors.bgInput,
        theme.colors.bgDisabled,
      ]);
      expect(decoration.borderRadius, theme.radii.cardBorder);

      final paragraph = find.byKey(const ValueKey('paragraph-skeleton'));
      final rowGaps = tester.widgetList<Padding>(
        find.descendant(of: paragraph, matching: find.byType(Padding)),
      );
      expect(
        rowGaps.map((padding) => padding.padding),
        contains(EdgeInsets.only(bottom: theme.spacing.md - theme.spacing.xxs)),
      );
    },
  );
}
