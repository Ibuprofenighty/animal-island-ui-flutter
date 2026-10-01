import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

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

    final text = tester.widget<Text>(find.byType(Text).first);
    final style = text.textSpan!.style!;
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

    final caretFinder = find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).color == theme.colors.primary,
    );
    final caret = tester
        .widgetList<Container>(find.byType(Container))
        .firstWhere(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).color ==
                  theme.colors.primary,
        );
    expect((caret.decoration! as BoxDecoration).color, theme.colors.primary);
    expect(
      tester.getSize(caretFinder).height,
      theme.typography.body.fontSize! * 1.1,
    );
  });
}
