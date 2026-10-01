import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/background/background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('background fills from theme and provides body text style', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(
          body: AnimalBackground(
            type: AnimalBackgroundType.dots,
            child: Text('background copy'),
          ),
        ),
      ),
    );

    final pattern = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<AnimalBackgroundPainter>()
        .single;
    expect(pattern.bgColor, theme.colors.bg);
    expect(pattern.patternColor, theme.colors.bgSecondary);

    final textStyle = tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('background copy'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;
    expect(textStyle.fontSize, theme.typography.body.fontSize);
    expect(textStyle.color, theme.colors.text);
    expect(
      themeContrastRatio(textStyle.color!, theme.colors.bg),
      greaterThanOrEqualTo(4.5),
    );

    final darkTheme = AnimalIslandTheme.dark;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: darkTheme.toThemeData(),
        home: const Scaffold(
          body: AnimalBackground(type: AnimalBackgroundType.grid),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    final darkPattern = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<AnimalBackgroundPainter>()
        .single;
    expect(
      darkPattern.patternColor,
      darkTheme.colors.border.withValues(alpha: 0.15),
    );
  });
}
