import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('tabs indicator uses theme accent, shape, shadow and motion', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      Widget app(int selectedIndex) => MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        key: ObjectKey(theme),
        theme: theme.toThemeData(),
        home: Scaffold(
          body: SizedBox(
            width: 88,
            child: AnimalTabs(
              tabs: const [
                AnimalTabItem(label: 'Unselected', id: 'unselected'),
                AnimalTabItem(
                  label: 'Disabled',
                  id: 'disabled',
                  disabled: true,
                ),
                AnimalTabItem(label: 'Third', id: 'third'),
                AnimalTabItem(label: 'Selected', id: 'selected'),
              ],
              selectedIndex: selectedIndex,
              onChanged: (_) {},
              scrollable: true,
            ),
          ),
        ),
      );

      await tester.pumpWidget(app(0));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpWidget(app(3));
      await tester.pump();

      final indicator = tester.widget<AnimatedPositioned>(
        find.byType(AnimatedPositioned),
      );
      expect(indicator.duration, theme.motion.normal);
      expect(indicator.curve, theme.motion.spring);

      final pill = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimatedPositioned),
          matching: find.byType(Container),
        ),
      );
      final decoration = pill.decoration! as BoxDecoration;
      expect(decoration.color, theme.colors.primary);
      expect(decoration.borderRadius, theme.radii.pillBorder);
      expect(decoration.boxShadow, [theme.shadows.button3d]);
      expect(
        themeContrastRatio(theme.colors.onPrimary, theme.colors.primary),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected tab text pair',
      );

      final selectedText = tester.widget<Text>(find.text('Selected'));
      expect(selectedText.style!.fontSize, theme.typography.body.fontSize);
      expect(selectedText.style!.color, theme.colors.onPrimary);
      final unselectedText = tester.widget<Text>(find.text('Unselected'));
      expect(unselectedText.style!.color, theme.colors.text);
      expect(
        themeContrastRatio(
          unselectedText.style!.color!,
          theme.colors.surfaceAlt,
        ),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} unselected tab text pair',
      );

      final itemContainer = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.padding ==
                EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg,
                  vertical: theme.spacing.sm,
                ),
          );
      expect(
        itemContainer.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.sm,
        ),
      );

      final disabledSemantics = tester
          .widgetList<Semantics>(
            find.ancestor(
              of: find.text('Disabled'),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((semantics) => semantics.properties.enabled == false);
      expect(disabledSemantics.properties.enabled, isFalse);
      final disabledText = tester.widget<Text>(find.text('Disabled'));
      final disabledForeground = Color.alphaBlend(
        disabledText.style!.color!,
        theme.colors.surfaceAlt,
      );
      expect(
        disabledText.style!.color,
        theme.colors.textSecondary.withValues(alpha: 0.4),
      );
      expect(
        themeContrastRatio(disabledForeground, theme.colors.surfaceAlt),
        greaterThan(1.0),
        reason: '${theme.colors.brightness.name} disabled tab text pair',
      );

      final outer = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.padding == EdgeInsets.all(theme.spacing.xs),
          );
      final outerDecoration = outer.decoration! as BoxDecoration;
      expect(outerDecoration.color, theme.colors.surfaceAlt);
      expect(outerDecoration.border!.top.color, theme.colors.border);
      expect(outerDecoration.borderRadius, theme.radii.pillBorder);
    }
  });
}
