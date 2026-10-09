import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

RenderParagraph _paragraph(WidgetTester tester) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.byType(AnimalTypewriter),
        matching: find.byType(RichText),
      ),
    );

void main() {
  testWidgets('typewriter inherits body typography and semantic text color', (
    tester,
  ) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(
          body: AnimalTypewriter(
            text: 'Theme type',
            speed: const Duration(days: 1),
          ),
        ),
      ),
    );

    final style = _paragraph(tester).text.style!;
    expect(style.fontSize, theme.typography.body.fontSize);
    expect(style.letterSpacing, theme.typography.body.letterSpacing);
    expect(style.wordSpacing, theme.typography.body.wordSpacing);
    expect(style.fontFamily, theme.typography.fontFamily);
    expect(style.fontFamilyFallback, theme.typography.fontFamilyFallback);
    expect(style.fontFamilyFallback, [
      'packages/animal_island_ui/Nunito',
      'sans-serif',
    ]);
    expect(style.color, theme.colors.text);
    expect(
      themeContrastRatio(style.color!, theme.colors.bg),
      greaterThanOrEqualTo(4.5),
    );
  });

  testWidgets('typewriter caret uses the primary accent color', (tester) async {
    final theme = thirdAnimalIslandTheme();
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,

        theme: theme.toThemeData(),
        home: Scaffold(
          body: AnimalTypewriter(
            text: 'Typing',
            speed: const Duration(seconds: 1),
            showCursor: true,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1));

    // The caret is as tall as the line at the typing position.
    final RenderParagraph paragraph = _paragraph(tester);
    const TextPosition start = TextPosition(offset: 0);
    final double lineHeight = paragraph.getFullHeightForCaret(start);
    expect(
      paragraph.parent,
      paints..rrect(
        rrect: RRect.fromRectAndRadius(
          paragraph.getOffsetForCaret(
                start,
                Rect.fromLTWH(0, 0, 2, lineHeight),
              ) &
              Size(2, lineHeight),
          const Radius.circular(1),
        ),
        color: theme.colors.primary,
      ),
    );
  });
}
