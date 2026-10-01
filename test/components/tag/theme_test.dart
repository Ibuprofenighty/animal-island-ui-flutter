import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C34 AnimalTag renders semantic surface foreground roles', (
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
            body: Wrap(
              children: [
                AnimalTag(
                  variant: AnimalTagVariant.primary,
                  onClose: () {},
                  child: Text('Primary tag'),
                ),
                const AnimalTag(
                  variant: AnimalTagVariant.success,
                  child: Text('Success tag'),
                ),
                const AnimalTag(
                  variant: AnimalTagVariant.warning,
                  child: Text('Warning tag'),
                ),
                const AnimalTag(
                  variant: AnimalTagVariant.error,
                  child: Text('Error tag'),
                ),
                const AnimalTag(
                  variant: AnimalTagVariant.neutral,
                  child: Text('Neutral tag'),
                ),
                const AnimalTag(
                  color: AnimalTileColor.appPink,
                  child: Text('Pink tile'),
                ),
              ],
            ),
          ),
        ),
      );

      void expectTag(
        String label,
        Color background,
        Color foreground, {
        double opacity = 1,
      }) {
        final labelFinder = find.text(label);
        final container = tester.widget<Container>(
          find
              .ancestor(of: labelFinder, matching: find.byType(Container))
              .first,
        );
        final actualText = DefaultTextStyle.of(tester.element(labelFinder))
            .style;
        final actualBackground =
            (container.decoration! as BoxDecoration).color!;
        expect(actualBackground, background.withValues(alpha: opacity));
        expect(actualText.color, foreground);
        expect(actualText.fontSize, theme.typography.caption.fontSize);
        expect(
          container.padding,
          EdgeInsets.symmetric(
            horizontal: theme.spacing.md,
            vertical: theme.spacing.xs,
          ),
        );
        expect(
          (container.decoration! as BoxDecoration).borderRadius,
          theme.radii.pillBorder,
        );
        expect(
          themeContrastRatio(
            actualText.color!,
            Color.alphaBlend(actualBackground, theme.colors.bg),
          ),
          greaterThanOrEqualTo(4.5),
        );
      }

      expectTag(
        'Primary tag',
        theme.colors.primaryBg,
        theme.colors.primaryText,
        opacity: theme.colors.brightness == Brightness.dark ? 0.25 : 1,
      );
      expectTag(
        'Success tag',
        theme.colors.successBg,
        theme.colors.successText,
        opacity: theme.colors.brightness == Brightness.dark ? 0.25 : 1,
      );
      expectTag(
        'Warning tag',
        theme.colors.warningBg,
        theme.colors.warningText,
        opacity: theme.colors.brightness == Brightness.dark ? 0.25 : 1,
      );
      expectTag(
        'Error tag',
        theme.colors.errorBg,
        theme.colors.errorText,
        opacity: theme.colors.brightness == Brightness.dark ? 0.25 : 1,
      );
      expectTag('Neutral tag', theme.colors.bgContent, theme.colors.text);
      expectTag(
        'Pink tile',
        theme.colors.tile(AnimalTileColor.appPink).background,
        theme.colors.tile(AnimalTileColor.appPink).foreground,
        opacity: theme.colors.brightness == Brightness.dark ? 0.35 : 1,
      );

      final closeAction = find.descendant(
        of: find.byType(AnimalTag).first,
        matching: find.byType(InteractiveRegion),
      );
      expect(closeAction, findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      final focusRingFinder = find.descendant(
        of: closeAction,
        matching: find.byWidgetPredicate(
          (widget) => widget is CustomPaint && widget.foregroundPainter != null,
        ),
      );
      expect(focusRingFinder, findsOneWidget);
      final focusRing = tester.widget<CustomPaint>(focusRingFinder);
      expect(focusRing.foregroundPainter, isNotNull);
    }
  });
}
