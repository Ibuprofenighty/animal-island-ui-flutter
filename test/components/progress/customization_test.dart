// API06 efficacy and precedence oracles for AnimalProgress.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
// The painters are package-internal; tests observe them directly.
import 'package:animal_island_ui/src/components/progress/progress_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpProgress(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalProgressStyle? style,
    AnimalProgressSize size = AnimalProgressSize.middle,
    AnimalProgressInfoPosition infoPosition = AnimalProgressInfoPosition.right,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: SizedBox(
            width: 300,
            child: Column(
              children: [
                AnimalProgress(
                  percent: 0.8,
                  size: size,
                  infoPosition: infoPosition,
                  animated: false,
                  style: style,
                ),
                AnimalProgress.circle(percent: 0.4, style: style),
              ],
            ),
          ),
        ),
      ),
    );
    // Let MaterialApp finish animating a theme change.
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalProgressThemeData progress) =>
      AnimalIslandTheme.light.copyWith(
        components: AnimalComponentThemes(progress: progress),
      );

  AnimalCandyStripePainter bar(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((p) => p.painter)
      .whereType<AnimalCandyStripePainter>()
      .single;
  AnimalCircularProgressPainter ring(WidgetTester tester) => tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((p) => p.painter)
      .whereType<AnimalCircularProgressPainter>()
      .single;
  BoxDecoration track(WidgetTester tester) =>
      tester
              .widget<Container>(
                find
                    .descendant(
                      of: find.byType(AnimalProgress).first,
                      matching: find.byType(Container),
                    )
                    .first,
              )
              .decoration!
          as BoxDecoration;
  double barHeight(WidgetTester tester) => tester
      .getSize(
        find
            .descendant(
              of: find.byType(AnimalProgress).first,
              matching: find.byType(Container),
            )
            .first,
      )
      .height;
  TextStyle label(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!;
  double labelGap(WidgetTester tester) => tester
      .widget<SizedBox>(
        find.descendant(
          of: find.byType(AnimalProgress).first,
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width != null && w.child == null,
          ),
        ),
      )
      .width!;

  group('API06 AnimalProgress efficacy', () {
    testWidgets('token changes reach every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      await pumpProgress(
        tester,
        theme: light.copyWith(
          colors: light.colors.copyWith(
            primary: const Color(0xFF123456),
            bgDisabled: const Color(0xFF654321),
          ),
          typography: light.typography.copyWith(
            caption: light.typography.caption.copyWith(fontSize: 17),
          ),
          spacing: light.spacing.copyWith(md: 14),
        ),
      );
      expect(bar(tester).fillColor, const Color(0xFF123456));
      expect(ring(tester).fillColor, const Color(0xFF123456));
      expect(track(tester).color, const Color(0xFF654321));
      expect(ring(tester).trackColor, const Color(0xFF654321));
      expect(label(tester, '80%').fontSize, 17);
      expect(labelGap(tester), 14);
    });

    testWidgets('every component-theme field changes the rendered progress', (
      tester,
    ) async {
      await pumpProgress(
        tester,
        size: AnimalProgressSize.large,
        infoPosition: AnimalProgressInfoPosition.inside,
        theme: themed(
          AnimalProgressThemeData(
            style: AnimalProgressStyle(
              color: const Color(0xFF00AA00),
              trackColor: const Color(0xFF102030),
              trackBorderColor: const Color(0xFF0000AA),
              trackBorderWidth: 3,
              height: 30,
              strokeWidth: 6,
              stripeColor: const Color(0x55ABCDEF),
              labelTextStyle: const TextStyle(fontSize: 13),
              labelTextColor: const Color(0xFFAA0000),
              insideLabelTextStyle: const TextStyle(fontSize: 15),
              insideLabelTextColor: const Color(0xFF00FFFF),
              labelGap: 11,
            ),
          ),
        ),
      );
      expect(bar(tester).fillColor, const Color(0xFF00AA00));
      expect(bar(tester).stripeColor, const Color(0x55ABCDEF));
      expect(track(tester).color, const Color(0xFF102030));
      expect(track(tester).border!.top.color, const Color(0xFF0000AA));
      expect(track(tester).border!.top.width, 3);
      expect(barHeight(tester), 30);
      expect(ring(tester).strokeWidth, 6);
      expect(ring(tester).trackColor, const Color(0xFF102030));
      expect(label(tester, '80%').fontSize, 15);
      expect(label(tester, '80%').color, const Color(0xFF00FFFF));
      expect(label(tester, '40%').fontSize, 13);
      expect(label(tester, '40%').color, const Color(0xFFAA0000));

      await pumpProgress(
        tester,
        theme: themed(
          AnimalProgressThemeData(
            style: AnimalProgressStyle(
              labelTextColor: const Color(0xFFAA0000),
              labelGap: 11,
            ),
          ),
        ),
      );
      expect(label(tester, '80%').color, const Color(0xFFAA0000));
      expect(labelGap(tester), 11);
    });
  });

  group('API06 AnimalProgress precedence', () {
    testWidgets('instance > size theme > general theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalProgressThemeData(
          style: AnimalProgressStyle(height: 10, trackBorderWidth: 2),
          largeStyle: AnimalProgressStyle(height: 26),
        ),
      );
      await pumpProgress(tester, size: AnimalProgressSize.large);
      expect(barHeight(tester), 22);
      expect(track(tester).border!.top.width, 1.2);

      await pumpProgress(tester, theme: theme);
      expect(barHeight(tester), 10);
      await pumpProgress(tester, theme: theme, size: AnimalProgressSize.large);
      expect(barHeight(tester), 26);
      expect(track(tester).border!.top.width, 2);

      await pumpProgress(
        tester,
        theme: theme,
        size: AnimalProgressSize.large,
        style: AnimalProgressStyle(height: 34),
      );
      expect(barHeight(tester), 34);
      expect(track(tester).border!.top.width, 2);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpProgress(
        tester,
        theme: themed(
          AnimalProgressThemeData(
            style: AnimalProgressStyle(
              labelTextStyle: const TextStyle(letterSpacing: 1.25),
            ),
          ),
        ),
        style: AnimalProgressStyle(
          labelTextStyle: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      final TextStyle style = label(tester, '80%');
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 1.25);
      expect(style.fontWeight, FontWeight.w800);
      expect(
        style.fontSize,
        AnimalIslandTheme.light.typography.caption.fontSize,
      );
    });
  });

  group('API06 AnimalProgress boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalProgressStyle(height: -1), throwsArgumentError);
      expect(
        () => AnimalProgressStyle(strokeWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalProgressStyle(
          insideLabelTextStyle: const TextStyle(fontSize: 0),
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalProgressThemeData a = AnimalProgressThemeData(
        style: AnimalProgressStyle(height: 10),
      );
      final AnimalProgressThemeData b = AnimalProgressThemeData(
        style: AnimalProgressStyle(height: 20),
      );
      expect(AnimalProgressThemeData.lerp(a, b, 0), same(a));
      expect(AnimalProgressThemeData.lerp(a, b, 1), same(b));
      expect(AnimalProgressThemeData.lerp(a, b, 0.5)!.style!.height, 15);
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalProgressStyle b = AnimalProgressStyle(
        stripeColor: const Color(0xFF00FF00),
      );
      expect(AnimalProgressStyle.lerp(null, b, 0.4)!.stripeColor, isNull);
      expect(
        AnimalProgressStyle.lerp(null, b, 0.6)!.stripeColor,
        const Color(0xFF00FF00),
      );
    });
  });
}
