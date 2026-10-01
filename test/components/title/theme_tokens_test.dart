import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animal_island_ui/src/internal/painting/ribbon_painter.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('title consumes tile foreground, font family and wing spacing', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: const Scaffold(
          body: AnimalTitle(
            color: AnimalTileColor.appBlue,
            child: Text('banner title'),
          ),
        ),
      ),
    );

    final tile = theme.colors.tile(AnimalTileColor.appBlue);
    final ribbon = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((paint) => paint.painter)
        .whereType<AnimalRibbonPainter>()
        .single;
    expect(ribbon.frontColor, tile.background);
    final textStyle = tester
        .widget<DefaultTextStyle>(
          find
              .ancestor(
                of: find.text('banner title'),
                matching: find.byType(DefaultTextStyle),
              )
              .first,
        )
        .style;
    expect(textStyle.color, tile.foreground);
    expect(
      themeContrastRatio(textStyle.color!, ribbon.frontColor),
      greaterThanOrEqualTo(4.5),
    );
    expect(textStyle.fontFamily, theme.typography.fontFamily);
    expect(textStyle.fontFamilyFallback, theme.typography.fontFamilyFallback);
    expect(textStyle.fontFamily, 'packages/animal_island_ui/Noto Sans SC');
    expect(textStyle.fontFamilyFallback, [
      'packages/animal_island_ui/Nunito',
      'sans-serif',
    ]);

    final padding = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere(
          (container) =>
              container.padding?.resolve(TextDirection.ltr).left ==
              AnimalTitleSize.middle.wingWidth + theme.spacing.md,
        );
    expect(
      padding.padding!.resolve(TextDirection.ltr).left,
      AnimalTitleSize.middle.wingWidth + theme.spacing.md,
    );
  });
}
