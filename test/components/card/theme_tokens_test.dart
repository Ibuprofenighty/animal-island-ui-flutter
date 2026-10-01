import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animal_island_ui/src/components/card/card_pattern_painter.dart';
import 'package:flutter/gestures.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('card uses tile colors, theme body style and themed defaults', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    const label = 'tile content';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(
          body: AnimalCard(color: AnimalTileColor.appPink, child: Text(label)),
        ),
      ),
    );

    final tile = theme.colors.tile(AnimalTileColor.appPink);
    final cardBox = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color == tile.background,
        );
    final cardDecoration = cardBox.decoration! as BoxDecoration;
    expect(cardDecoration.color, tile.background);
    expect(
      cardDecoration.borderRadius,
      theme.radii.cardBorder,
      reason: 'M27: rendered card follows active theme radius',
    );
    expect(
      (cardDecoration.border! as Border).top.color,
      theme.colors.borderLight.withValues(alpha: 0.6),
    );
    final patternPainter = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<AnimalCardPatternPainter>()
        .single;
    expect(patternPainter.radius, theme.radii.card);

    final textStyle = tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;
    expect(textStyle.fontSize, theme.typography.body.fontSize);
    expect(textStyle.color, tile.foreground);
    expect(
      themeContrastRatio(textStyle.color!, tile.background),
      greaterThanOrEqualTo(4.5),
    );

    final contentPadding = tester
        .widgetList<Padding>(find.byType(Padding))
        .firstWhere(
          (padding) =>
              padding.padding ==
              EdgeInsets.all(theme.spacing.lg + theme.spacing.xs),
        );
    expect(
      contentPadding.padding,
      EdgeInsets.all(theme.spacing.lg + theme.spacing.xs),
    );

    final animation = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(animation.duration, theme.motion.fast);
    expect(
      (tester
                  .widgetList<Container>(find.byType(Container))
                  .firstWhere(
                    (container) =>
                        container.decoration is BoxDecoration &&
                        (container.decoration! as BoxDecoration).color ==
                            tile.background,
                  )
                  .decoration!
              as BoxDecoration)
          .boxShadow,
      isNull,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(
          body: AnimalCard(
            header: const Text('default card heading'),
            footer: const Text('default card footer'),
            child: const Text('default card body'),
          ),
        ),
      ),
    );
    final defaultCard = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color ==
                  theme.colors.bgContent,
        );
    expect(
      (defaultCard.decoration! as BoxDecoration).color,
      theme.colors.bgContent,
    );

    TextStyle inheritedStyle(String label) => tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text(label),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;

    for (final label in [
      'default card heading',
      'default card body',
      'default card footer',
    ]) {
      final style = inheritedStyle(label);
      expect(style.color, theme.colors.textBody);
      expect(
        themeContrastRatio(style.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets(
    'default card applies content colors and readable footer contrast',
    (tester) async {
      final themes = <AnimalIslandTheme>[
        AnimalIslandTheme.light,
        AnimalIslandTheme.dark,
        thirdAnimalIslandTheme(),
      ];
      for (final theme in themes) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: theme.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                header: const Text('card heading'),
                footer: const Text('card footer'),
                child: const Text('card body'),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        final card = tester
            .widgetList<Container>(find.byType(Container))
            .firstWhere(
              (container) =>
                  container.decoration is BoxDecoration &&
                  (container.decoration! as BoxDecoration).color ==
                      theme.colors.bgContent,
            );
        expect(
          (card.decoration! as BoxDecoration).color,
          theme.colors.bgContent,
        );

        TextStyle inheritedStyle(String label) => tester
            .widget<DefaultTextStyle>(
              find
                  .ancestor(
                    of: find.text(label),
                    matching: find.byType(DefaultTextStyle),
                  )
                  .first,
            )
            .style;

        final heading = inheritedStyle('card heading');
        expect(heading.fontSize, theme.typography.heading.fontSize);
        expect(heading.color, theme.colors.textBody);
        expect(
          themeContrastRatio(heading.color!, theme.colors.bgContent),
          greaterThanOrEqualTo(4.5),
        );

        final body = inheritedStyle('card body');
        expect(body.fontSize, theme.typography.body.fontSize);
        expect(body.color, theme.colors.textBody);
        expect(
          themeContrastRatio(body.color!, theme.colors.bgContent),
          greaterThanOrEqualTo(4.5),
        );

        final footer = inheritedStyle('card footer');
        expect(footer.fontSize, theme.typography.caption.fontSize);
        expect(footer.color, theme.colors.textBody);
        expect(
          themeContrastRatio(footer.color!, theme.colors.bgContent),
          greaterThanOrEqualTo(4.5),
        );
      }
    },
  );

  testWidgets('card hover lift follows theme motion over time', (tester) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(
          body: AnimalCard(
            hoverable: true,
            onTap: () {},
            child: const Text('hover body'),
          ),
        ),
      ),
    );

    final card = find.byType(AnimalCard);
    final animatedCard = find.descendant(
      of: card,
      matching: find.byWidgetPredicate(
        (widget) => widget is AnimatedContainer && widget.transform != null,
      ),
    );
    final animation = tester.widget<AnimatedContainer>(animatedCard);
    expect(animation.duration, theme.motion.fast);
    expect(animation.curve, theme.motion.ease);

    final before = tester.getTopLeft(find.text('hover body')).dy;
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(
      location: tester.getCenter(find.text('hover body')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final during = tester.getTopLeft(find.text('hover body')).dy;
    expect(during, lessThan(before));
    expect(during, greaterThan(before - 2.0));

    await tester.pump(theme.motion.fast - const Duration(milliseconds: 80));
    final after = tester.getTopLeft(find.text('hover body')).dy;
    expect(after, closeTo(before - 2.0, 0.05));
    await pointer.removePointer();
  });
}
