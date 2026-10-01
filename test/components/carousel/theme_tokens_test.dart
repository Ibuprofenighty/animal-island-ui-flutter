import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'carousel dots use theme color, spacing, pill radius, shadow and motion',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ObjectKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: AnimalCarousel(
                items: const [],
                autoPlay: false,
                showArrows: false,
                showDots: false,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));
        final emptyDecoration =
            tester.widget<Container>(find.byType(Container)).decoration!
                as BoxDecoration;
        expect(emptyDecoration.color, theme.colors.surfaceAlt);
        expect(emptyDecoration.border!.top.color, theme.colors.border);
        expect(emptyDecoration.borderRadius, theme.radii.cardBorder);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ObjectKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: AnimalCarousel(
                items: const [Text('slide one'), Text('slide two')],
                autoPlay: false,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        final leftArrow = tester.widget<Icon>(
          find.byIcon(Icons.chevron_left_rounded),
        );
        final rightArrow = tester.widget<Icon>(
          find.byIcon(Icons.chevron_right_rounded),
        );
        expect(leftArrow.color, theme.colors.text);
        expect(rightArrow.color, theme.colors.text);
        expect(
          themeContrastRatio(theme.colors.text, theme.colors.bgContent),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.colors.brightness.name} carousel arrow icon pair',
        );

        final dots = tester.widgetList<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final selectedDot = dots.firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color ==
                  theme.colors.primaryText,
        );
        expect(selectedDot.duration, theme.motion.fast);
        expect(selectedDot.curve, theme.motion.ease);
        expect(
          tester.getSize(find.byWidget(selectedDot)),
          const Size(20.0, 8.0),
        );
        expect(
          themeContrastRatio(theme.colors.primaryText, theme.colors.bgContent),
          greaterThanOrEqualTo(4.5),
          reason:
              '${theme.colors.brightness.name} selected dot; width also indicates selection',
        );

        final inactiveDot = dots.firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color ==
                  theme.colors.textSecondary,
        );
        expect(
          tester.getSize(find.byWidget(inactiveDot)),
          const Size(8.0, 8.0),
        );

        final dotsPanel = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere(
              (container) =>
                  container.padding ==
                  EdgeInsets.symmetric(
                    horizontal: theme.spacing.sm,
                    vertical: theme.spacing.xs,
                  ),
            );
        final decoration = dotsPanel.decoration! as BoxDecoration;
        final panelFill = theme.colors.bgContent.withValues(alpha: 0.75);
        expect(decoration.color, panelFill);
        expect(decoration.borderRadius, theme.radii.pillBorder);
        expect(decoration.boxShadow, [theme.shadows.softElevation]);
        final panelSurface = Color.alphaBlend(panelFill, theme.colors.bg);
        expect(
          themeContrastRatio(theme.colors.textSecondary, panelSurface),
          greaterThanOrEqualTo(4.5),
          reason: '${theme.colors.brightness.name} inactive dot contrast pair',
        );

        final overlayPositions = tester.widgetList<Positioned>(
          find.byType(Positioned),
        );
        expect(
          overlayPositions.where(
            (position) => position.left == theme.spacing.md,
          ),
          hasLength(1),
        );
        expect(
          overlayPositions.where(
            (position) => position.right == theme.spacing.md,
          ),
          hasLength(1),
        );
        expect(
          overlayPositions.where(
            (position) => position.bottom == theme.spacing.md,
          ),
          hasLength(1),
        );

        final pageController = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));
        expect(pageController.page!, greaterThan(0.0));
        expect(pageController.page!, lessThan(1.0));
        await tester.pump(theme.motion.normal);
        expect(pageController.page, closeTo(1.0, 0.001));
      }
    },
  );
}
