import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/progress/progress_painter.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C24 AnimalProgress renders themed fill, label and motion', (
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
            body: AnimalProgress(
              percent: 0.5,
              status: AnimalProgressStatus.active,
            ),
          ),
        ),
      );

      final progress = find.byType(AnimalProgress);
      final paint = tester
          .widgetList<CustomPaint>(
            find.descendant(of: progress, matching: find.byType(CustomPaint)),
          )
          .firstWhere((node) => node.painter is AnimalCandyStripePainter);
      expect(
        (paint.painter! as AnimalCandyStripePainter).radius,
        theme.radii.pill,
      );
      expect(
        (paint.painter! as AnimalCandyStripePainter).fillColor,
        theme.colors.primary,
      );
      final percentage = tester.widget<Text>(find.text('50%'));
      expect(percentage.style?.fontSize, theme.typography.caption.fontSize);
      expect(percentage.style?.color, theme.colors.text);
      expect(
        themeContrastRatio(percentage.style!.color!, theme.colors.bg),
        greaterThanOrEqualTo(4.5),
      );
      expect(percentage.style?.shadows, isNull);
      final animation =
          (paint.painter! as AnimalCandyStripePainter).phase
              as AnimationController;
      expect(animation.duration, theme.motion.slow * (1400 / 350));

      for (final (status, fillColor, textColor) in [
        (
          AnimalProgressStatus.normal,
          theme.colors.primary,
          theme.colors.onPrimary,
        ),
        (
          AnimalProgressStatus.active,
          theme.colors.primary,
          theme.colors.onPrimary,
        ),
        (
          AnimalProgressStatus.success,
          theme.colors.success,
          theme.colors.onSuccess,
        ),
        (
          AnimalProgressStatus.exception,
          theme.colors.error,
          theme.colors.onError,
        ),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey('${theme.hashCode}-$status'),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                width: 200,
                child: AnimalProgress(
                  percent: 0.8,
                  size: AnimalProgressSize.large,
                  status: status,
                  infoPosition: AnimalProgressInfoPosition.inside,
                  striped: false,
                  animated: false,
                ),
              ),
            ),
          ),
        );
        final actualLabel = tester.widget<Text>(find.text('80%'));
        final actualPainter =
            tester
                    .widgetList<CustomPaint>(
                      find.descendant(
                        of: find.byType(AnimalProgress),
                        matching: find.byType(CustomPaint),
                      ),
                    )
                    .firstWhere(
                      (node) => node.painter is AnimalCandyStripePainter,
                    )
                    .painter!
                as AnimalCandyStripePainter;
        expect(actualPainter.fillColor, fillColor);
        expect(actualPainter.radius, theme.radii.pill);
        final labelPadding = tester.widget<Padding>(
          find
              .ancestor(of: find.text('80%'), matching: find.byType(Padding))
              .first,
        );
        expect(
          labelPadding.padding,
          EdgeInsetsDirectional.only(end: theme.spacing.sm),
        );
        expect(actualLabel.style?.color, textColor);
        expect(actualLabel.style?.shadows, [
          Shadow(
            color: theme.shadows.softElevation.color,
            offset: theme.shadows.softElevation.offset,
            blurRadius: theme.shadows.softElevation.blurRadius,
          ),
        ]);
        expect(
          themeContrastRatio(
            actualLabel.style!.color!,
            actualPainter.fillColor,
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
    }
  });
}
