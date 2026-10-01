import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C33 AnimalCodeBlock renders themed code typography and spacing',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey(theme),
            theme: theme.toThemeData(),
            home: const Scaffold(
              body: AnimalCodeBlock(code: 'final island = true;'),
            ),
          ),
        );

        final block = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(AnimalCodeBlock),
                matching: find.byType(Container),
              )
              .first,
        );
        final code = tester.widget<SelectableText>(find.byType(SelectableText));
        final background = (block.decoration! as BoxDecoration).color!;
        final language = tester.widget<Text>(find.text('dart'));
        final copy = tester.widget<Text>(find.text('Copy'));
        final copySurface = tester.widget<AnimatedContainer>(
          find
              .ancestor(
                of: find.text('Copy'),
                matching: find.byType(AnimatedContainer),
              )
              .first,
        );
        expect(block.padding, EdgeInsets.all(theme.spacing.lg));
        expect(
          (block.decoration! as BoxDecoration).borderRadius,
          theme.radii.cardBorder,
        );
        expect(code.style?.fontSize, theme.typography.code.fontSize);
        expect(code.style?.fontFamily, theme.typography.code.fontFamily);
        expect(
          background,
          theme.colors.brightness == Brightness.dark
              ? theme.colors.surfaceHeader
              : theme.colors.bgInput,
        );
        expect(code.style?.color, theme.colors.text);
        expect(language.style?.color, theme.colors.textSecondary);
        expect(copy.style?.color, theme.colors.textSecondary);
        expect(copySurface.duration, theme.motion.fast);
        expect(
          themeContrastRatio(code.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          themeContrastRatio(language.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          themeContrastRatio(copy.style!.color!, background),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );
}
