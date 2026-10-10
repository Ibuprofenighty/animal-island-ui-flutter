import 'package:animal_island_ui/src/internal/interaction/focus_ring.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('collapse card uses theme colors, geometry and motion', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalCollapse(
              items: [
                AnimalCollapseItem(
                  id: 'enabled',
                  title: Text('Enabled question'),
                  content: Text('Expanded answer'),
                ),
                AnimalCollapseItem(
                  id: 'disabled',
                  title: Text('Disabled question'),
                  content: Text('Disabled answer'),
                  disabled: true,
                ),
              ],
              defaultActiveIds: const {'enabled'},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      final cards = tester.widgetList<Container>(find.byType(Container));
      final enabledCard = cards.firstWhere(
        (container) =>
            container.decoration is BoxDecoration &&
            (container.decoration! as BoxDecoration).borderRadius ==
                theme.radii.cardBorder,
      );
      final enabledDecoration = enabledCard.decoration! as BoxDecoration;
      expect(enabledDecoration.color, theme.colors.bgContent);
      expect(enabledDecoration.border!.top.color, theme.colors.border);
      expect(enabledDecoration.boxShadow, [theme.shadows.softElevation]);
      expect(
        themeContrastRatio(theme.colors.border, theme.colors.bgContent),
        greaterThan(1.0),
        reason: '${theme.colors.brightness.name} collapse card border pair',
      );

      final header = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.padding ==
                EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg,
                  vertical: theme.spacing.md,
                ),
          );
      expect(
        header.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Padding &&
              widget.padding == EdgeInsets.only(bottom: theme.spacing.sm),
        ),
        findsOneWidget,
      );

      final titleStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('Enabled question'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(titleStyle.fontSize, theme.typography.body.fontSize);
      expect(titleStyle.color, theme.colors.text);
      expect(
        themeContrastRatio(titleStyle.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
      );

      final body = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (container) =>
                container.padding == EdgeInsets.all(theme.spacing.lg),
          );
      final bodyDecoration = body.decoration! as BoxDecoration;
      expect(
        bodyDecoration.color,
        theme.colors.surfaceAlt.withValues(alpha: 0.4),
      );
      final bodyStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('Expanded answer'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(bodyStyle.color, theme.colors.text);
      final bodySurface = Color.alphaBlend(
        bodyDecoration.color!,
        theme.colors.bgContent,
      );
      expect(
        themeContrastRatio(bodyStyle.color!, bodySurface),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} expanded answer pair',
      );

      final disabledSemantics = tester
          .widgetList<Semantics>(
            find.ancestor(
              of: find.text('Disabled question'),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((semantics) => semantics.properties.enabled == false);
      final disabledTitleStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('Disabled question'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(disabledTitleStyle.color, theme.colors.textSecondary);
      expect(disabledSemantics.properties.enabled, isFalse);
      final disabledHeaderColor = theme.colors.surfaceAlt.withValues(
        alpha: 0.5,
      );
      final disabledHeaderSurface = Color.alphaBlend(
        disabledHeaderColor,
        theme.colors.bgContent,
      );
      expect(
        themeContrastRatio(disabledTitleStyle.color!, disabledHeaderSurface),
        greaterThan(1.0),
        reason: '${theme.colors.brightness.name} disabled header pair',
      );

      // Put the enabled header into the keyboard-focus state so the actual
      // focus outline, rather than a theme field alone, is observed.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        tester
            .widgetList<AnimalFocusRing>(find.byType(AnimalFocusRing))
            .any((ring) => ring.focused),
        isTrue,
      );
      expect(
        themeContrastRatio(theme.colors.focusYellow, theme.colors.bgContent),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} collapse focus outline pair',
      );

      final expandedHeight = tester
          .getSize(find.byType(AnimatedSize).first)
          .height;
      await tester.tap(find.text('Enabled question'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final remainingHeight = tester
          .getSize(find.byType(AnimatedSize).first)
          .height;
      expect(remainingHeight, greaterThan(0));
      final expectedFactor = theme.motion.spring.transform(
        1.0 - 100 / theme.motion.normal.inMilliseconds,
      );
      expect(remainingHeight / expandedHeight, closeTo(expectedFactor, 0.02));
      await tester.pump(theme.motion.normal);
      expect(
        tester.getSize(find.byType(AnimatedSize).first).height,
        closeTo(0.0, 0.0001),
      );
    }
  });
}
