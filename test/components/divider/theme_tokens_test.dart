import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/divider/divider_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('divider caption and ornament spacing use the active theme', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(body: const AnimalDivider(child: Text('section label'))),
      ),
    );

    final textStyle = tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('section label'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;
    expect(textStyle.fontSize, theme.typography.caption.fontSize);
    expect(textStyle.color, theme.colors.textSecondary);
    expect(
      themeContrastRatio(textStyle.color!, theme.colors.bg),
      greaterThanOrEqualTo(4.5),
    );
    final lines = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<AnimalDividerLinePainter>()
        .toList();
    expect(lines, isNotEmpty);
    expect(
      lines.every((line) => line.color == theme.colors.borderLight),
      isTrue,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(body: AnimalDivider.leaf()),
      ),
    );
    final ornamentPadding = tester
        .widgetList<Padding>(find.byType(Padding))
        .firstWhere(
          (padding) =>
              padding.padding ==
              EdgeInsets.symmetric(horizontal: theme.spacing.md),
        );
    expect(
      ornamentPadding.padding,
      EdgeInsets.symmetric(horizontal: theme.spacing.md),
    );
    expect(find.byType(AnimalIcon), findsOneWidget);
    expect(
      tester.widget<AnimalIcon>(find.byType(AnimalIcon)).color,
      theme.colors.primary,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(body: AnimalDivider.star()),
      ),
    );
    expect(
      tester.widget<AnimalIcon>(find.byType(AnimalIcon)).color,
      theme.colors.warning,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(body: AnimalDivider.flower()),
      ),
    );
    expect(
      tester.widget<AnimalIcon>(find.byType(AnimalIcon)).color,
      theme.colors.error,
    );
  });
}
