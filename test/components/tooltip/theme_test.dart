import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/tooltip/tooltip_shape.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C23 AnimalTooltip renders themed radius, shadow, spacing and text',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey(theme),
            theme: theme.toThemeData(),
            home: const Scaffold(
              body: AnimalTooltip(
                variant: AnimalTooltipVariant.island,
                title: Text('Island hint'),
                message: 'Follow the shore',
                child: Text('Target'),
              ),
            ),
          ),
        );

        final tooltip = tester.widget<Tooltip>(find.byType(Tooltip));
        final decoration = tooltip.decoration! as ShapeDecoration;
        final shape = decoration.shape as AnimalIslandBubbleShapeBorder;
        final richMessage = tooltip.richMessage! as TextSpan;
        final titleSpan = richMessage.children!.first as WidgetSpan;
        final messageSpan = richMessage.children!.last as TextSpan;
        expect(decoration.color, theme.colors.bgContent);
        expect(messageSpan.style?.color, theme.colors.textBody);
        expect(
          themeContrastRatio(messageSpan.style!.color!, decoration.color!),
          greaterThanOrEqualTo(4.5),
        );
        expect(titleSpan.child, isA<DefaultTextStyle>());
        expect(shape.radius, theme.radii.tooltip);
        expect(decoration.shadows, [theme.shadows.softElevation]);
        expect(
          tooltip.padding,
          EdgeInsets.fromLTRB(
            theme.spacing.md + theme.spacing.xxs,
            theme.spacing.sm,
            theme.spacing.md + theme.spacing.xxs,
            theme.spacing.md + theme.spacing.xxs,
          ),
        );
        expect(
          tooltip.textStyle!.fontSize!,
          theme.typography.caption.fontSize! * (13 / 12),
        );

        await tester.tap(find.text('Target'));
        await tester.pumpAndSettle();
        final renderedTitle = find.text('Island hint');
        expect(renderedTitle, findsOneWidget);
        final titleStyle = DefaultTextStyle.of(tester.element(renderedTitle))
            .style;
        expect(titleStyle.color, theme.colors.text);
        expect(
          themeContrastRatio(titleStyle.color!, decoration.color!),
          greaterThanOrEqualTo(4.5),
        );
        final renderedMessage = tester
            .widgetList<RichText>(find.byType(RichText))
            .firstWhere(
              (node) => node.text.toPlainText().contains('Follow the shore'),
            );
        TextSpan? findMessageSpan(InlineSpan span) {
          if (span is! TextSpan) return null;
          if (span.text?.contains('Follow the shore') ?? false) return span;
          for (final child in span.children ?? const <InlineSpan>[]) {
            final match = findMessageSpan(child);
            if (match != null) return match;
          }
          return null;
        }

        final renderedMessageSpan = findMessageSpan(renderedMessage.text)!;
        expect(renderedMessageSpan.style?.color, theme.colors.textBody);
        expect(
          themeContrastRatio(
            renderedMessageSpan.style!.color!,
            decoration.color!,
          ),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );
}
