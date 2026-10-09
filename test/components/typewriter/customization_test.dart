// API06 efficacy and precedence oracles for AnimalTypewriter.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpTypewriter(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalTypewriterStyle? style,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: AnimalTypewriter(
            key: UniqueKey(),
            text: 'Island',
            speed: const Duration(days: 1),
            showCursor: true,
            style: style,
          ),
        ),
      ),
    );
    // Let MaterialApp finish animating a theme change.
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalTypewriterStyle typewriter) =>
      AnimalIslandTheme.light.copyWith(
        components: AnimalComponentThemes(typewriter: typewriter),
      );

  RenderParagraph paragraph(WidgetTester tester) =>
      tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.byType(AnimalTypewriter),
          matching: find.byType(RichText),
        ),
      );
  TextStyle textStyle(WidgetTester tester) => paragraph(tester).text.style!;

  /// Matches the cursor painted at the start of the text.
  PaintPattern cursor(WidgetTester tester, Color color, double width) {
    final RenderParagraph p = paragraph(tester);
    const TextPosition start = TextPosition(offset: 0);
    final double height = p.getFullHeightForCaret(start);
    return paints..rrect(
      rrect: RRect.fromRectAndRadius(
        p.getOffsetForCaret(start, Rect.fromLTWH(0, 0, width, height)) &
            Size(width, height),
        Radius.circular(width / 2),
      ),
      color: color,
    );
  }

  group('API06 AnimalTypewriter efficacy', () {
    testWidgets('token changes reach the text and cursor', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      await pumpTypewriter(
        tester,
        theme: light.copyWith(
          typography: light.typography.copyWith(
            body: light.typography.body.copyWith(fontSize: 23),
          ),
          colors: light.colors.copyWith(
            text: const Color(0xFF224466),
            primary: const Color(0xFF664422),
          ),
        ),
      );
      expect(textStyle(tester).fontSize, 23);
      expect(textStyle(tester).color, const Color(0xFF224466));
      expect(
        paragraph(tester).parent,
        cursor(tester, const Color(0xFF664422), 2),
      );
    });

    testWidgets('every component-theme field changes the rendered typewriter', (
      tester,
    ) async {
      await pumpTypewriter(
        tester,
        theme: themed(
          AnimalTypewriterStyle(
            textStyle: const TextStyle(fontSize: 19),
            textColor: const Color(0xFFAA0000),
            cursorColor: const Color(0xFF00AA00),
            cursorWidth: 4,
          ),
        ),
      );
      expect(textStyle(tester).fontSize, 19);
      expect(textStyle(tester).color, const Color(0xFFAA0000));
      expect(
        paragraph(tester).parent,
        cursor(tester, const Color(0xFF00AA00), 4),
      );
    });
  });

  group('API06 AnimalTypewriter precedence', () {
    testWidgets('instance style > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalTypewriterStyle(
          cursorColor: const Color(0xFF111111),
          textColor: const Color(0xFF333333),
        ),
      );
      await pumpTypewriter(tester);
      expect(textStyle(tester).color, AnimalIslandTheme.light.colors.text);

      await pumpTypewriter(tester, theme: theme);
      expect(textStyle(tester).color, const Color(0xFF333333));
      expect(
        paragraph(tester).parent,
        cursor(tester, const Color(0xFF111111), 2),
      );

      await pumpTypewriter(
        tester,
        theme: theme,
        style: AnimalTypewriterStyle(cursorColor: const Color(0xFF222222)),
      );
      expect(textStyle(tester).color, const Color(0xFF333333));
      expect(
        paragraph(tester).parent,
        cursor(tester, const Color(0xFF222222), 2),
      );
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpTypewriter(
        tester,
        theme: themed(
          AnimalTypewriterStyle(
            textStyle: const TextStyle(letterSpacing: 1.25),
          ),
        ),
        style: AnimalTypewriterStyle(
          textStyle: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      final TextStyle style = textStyle(tester);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, AnimalIslandTheme.light.typography.body.fontSize);
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalTypewriter boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalTypewriterStyle(cursorWidth: -1), throwsArgumentError);
      expect(
        () => AnimalTypewriterStyle(cursorWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalTypewriterStyle(textStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalTypewriterStyle a = AnimalTypewriterStyle(cursorWidth: 2);
      final AnimalTypewriterStyle b = AnimalTypewriterStyle(cursorWidth: 6);
      expect(AnimalTypewriterStyle.lerp(a, b, 0), same(a));
      expect(AnimalTypewriterStyle.lerp(a, b, 1), same(b));
      expect(AnimalTypewriterStyle.lerp(a, b, 0.5)!.cursorWidth, 4);
      expect(AnimalTypewriterStyle.lerp(a, b, 1.5)!.cursorWidth, 6);
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalTypewriterStyle b = AnimalTypewriterStyle(
        cursorColor: const Color(0xFF00FF00),
      );
      expect(AnimalTypewriterStyle.lerp(null, b, 0.4)!.cursorColor, isNull);
      expect(
        AnimalTypewriterStyle.lerp(null, b, 0.6)!.cursorColor,
        const Color(0xFF00FF00),
      );
    });
  });
}
