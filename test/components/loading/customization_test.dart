// API06 efficacy and precedence oracles for AnimalLoading.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
// The particle painter is package-internal; tests observe it directly.
import 'package:animal_island_ui/src/components/loading/loading_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpLoading(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalLoadingStyle? style,
    AnimalLoadingType type = AnimalLoadingType.spinner,
    bool fullScreen = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: AnimalLoading(
            type: type,
            tip: 'Island tip',
            fullScreen: fullScreen,
            snowCount: 5,
            snowSeed: 3,
            style: style,
          ),
        ),
      ),
    );
    // Let MaterialApp finish animating a theme change.
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalLoadingStyle loading) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(loading: loading));

  Text tipText(WidgetTester tester) =>
      tester.widget<Text>(find.text('Island tip'));
  Container tipSurface(WidgetTester tester) => tester.widget<Container>(
    find
        .ancestor(of: find.text('Island tip'), matching: find.byType(Container))
        .first,
  );
  BoxDecoration tipDecoration(WidgetTester tester) =>
      tipSurface(tester).decoration! as BoxDecoration;
  Color? iconColor(WidgetTester tester) =>
      tester.widget<AnimalIcon>(find.byType(AnimalIcon)).color;
  double tipGap(WidgetTester tester) => tester
      .widget<SizedBox>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width == null && w.height != null,
          ),
        ),
      )
      .height!;
  Color? barrier(WidgetTester tester) => tester
      .widget<Material>(
        find
            .descendant(
              of: find.byType(AnimalLoading),
              matching: find.byType(Material),
            )
            .first,
      )
      .color;

  group('API06 AnimalLoading efficacy', () {
    testWidgets('token changes reach the indicator and tip', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      await pumpLoading(
        tester,
        theme: light.copyWith(
          typography: light.typography.copyWith(
            caption: light.typography.caption.copyWith(fontSize: 21),
          ),
          colors: light.colors.copyWith(primaryText: const Color(0xFF224466)),
          spacing: light.spacing.copyWith(md: 15),
        ),
      );
      expect(tipText(tester).style!.fontSize, 21);
      expect(tipText(tester).style!.fontWeight, FontWeight.w700);
      expect(iconColor(tester), const Color(0xFF224466));
      expect(tipGap(tester), 15);
      // horizontal = md + xxs, vertical = sm - xxs.
      expect(
        tipSurface(tester).padding,
        const EdgeInsets.symmetric(horizontal: 17, vertical: 6),
      );
    });

    testWidgets('every component-theme field changes the rendered loading', (
      tester,
    ) async {
      await pumpLoading(
        tester,
        type: AnimalLoadingType.snowflake,
        fullScreen: true,
        theme: themed(
          AnimalLoadingStyle(
            color: const Color(0xFF00AA00),
            tipGap: 17,
            tipPadding: const EdgeInsets.all(9),
            tipTextStyle: const TextStyle(fontSize: 19),
            tipTextColor: const Color(0xFFAA0000),
            tipBackgroundColor: const Color(0xFF102030),
            tipBorderColor: const Color(0xFF0000AA),
            tipBorderWidth: 3.5,
            tipBorderRadius: const BorderRadius.all(Radius.circular(7)),
            tipShadow: const BoxShadow(
              color: Color(0xFF123456),
              offset: Offset(0, 9),
            ),
            barrierColor: const Color(0x80203040),
            snowflakeColor: const Color(0xFF55AAFF),
          ),
        ),
      );

      expect(iconColor(tester), const Color(0xFF00AA00));
      expect(tipGap(tester), 17);
      expect(tipSurface(tester).padding, const EdgeInsets.all(9));
      expect(tipText(tester).style!.fontSize, 19);
      expect(tipText(tester).style!.color, const Color(0xFFAA0000));
      final BoxDecoration d = tipDecoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 3.5);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(7)));
      expect(d.boxShadow, const [
        BoxShadow(color: Color(0xFF123456), offset: Offset(0, 9)),
      ]);
      expect(barrier(tester), const Color(0x80203040));
      final SnowflakeOverlayPainter painter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((p) => p.painter)
          .whereType<SnowflakeOverlayPainter>()
          .single;
      expect(painter.color, const Color(0xFF55AAFF));
    });
  });

  group('API06 AnimalLoading precedence', () {
    testWidgets('indicator color: instance style > theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalLoadingStyle(color: const Color(0xFF111111), tipBorderWidth: 2.5),
      );

      // Token default: the light preset's primary text color, 1.2 border.
      await pumpLoading(tester);
      expect(iconColor(tester), AnimalIslandTheme.light.colors.primaryText);
      expect(tipDecoration(tester).border!.top.width, 1.2);

      await pumpLoading(tester, theme: theme);
      expect(iconColor(tester), const Color(0xFF111111));
      expect(tipDecoration(tester).border!.top.width, 2.5);

      await pumpLoading(
        tester,
        theme: theme,
        style: AnimalLoadingStyle(color: const Color(0xFF222222)),
      );
      expect(iconColor(tester), const Color(0xFF222222));
      expect(tipDecoration(tester).border!.top.width, 2.5);
    });

    testWidgets('barrier color: instance style > theme', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalLoadingStyle(barrierColor: const Color(0x80111111)),
      );
      await pumpLoading(tester, theme: theme, fullScreen: true);
      expect(barrier(tester), const Color(0x80111111));
      await pumpLoading(
        tester,
        theme: theme,
        fullScreen: true,
        style: AnimalLoadingStyle(barrierColor: const Color(0x80222222)),
      );
      expect(barrier(tester), const Color(0x80222222));
    });

    testWidgets('a partial tip text style keeps the lower layers', (
      tester,
    ) async {
      await pumpLoading(
        tester,
        theme: themed(
          AnimalLoadingStyle(
            tipTextStyle: const TextStyle(letterSpacing: 1.25),
          ),
        ),
        style: AnimalLoadingStyle(
          tipTextStyle: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      final TextStyle style = tipText(tester).style!;
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 1.25);
      expect(style.fontWeight, FontWeight.w700);
      expect(style.fontSize, 12);
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalLoading registered defaults', () {
    testWidgets('the default barrier is the translucent page background', (
      tester,
    ) async {
      for (final (AnimalIslandTheme theme, double alpha)
          in <(AnimalIslandTheme, double)>[
            (AnimalIslandTheme.light, 0.53),
            (AnimalIslandTheme.dark, 0.67),
          ]) {
        await pumpLoading(tester, theme: theme, fullScreen: true);
        final Color? color = barrier(tester);
        expect(color!.a, closeTo(alpha, 0.002));
        expect(
          color.withValues(alpha: 1),
          theme.colors.bg.withValues(alpha: 1),
        );
      }
    });

    testWidgets(
      'indicator sizes and dot proportions are constructor geometry',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalLoading(),
                  const AnimalLoading.spinner(),
                  AnimalLoading.snowflake(),
                  const AnimalLoading.dots(),
                ],
              ),
            ),
          ),
        );
        final List<double?> iconSizes = tester
            .widgetList<AnimalIcon>(find.byType(AnimalIcon))
            .map((icon) => icon.size)
            .toList();
        expect(iconSizes, <double>[40, 40, 48]);
        // Dots: diameter 0.28 x 32 with a 0.25-diameter margin on each side.
        final Container dot = tester.widget<Container>(
          find
              .byWidgetPredicate(
                (w) =>
                    w is Container &&
                    w.decoration is BoxDecoration &&
                    (w.decoration! as BoxDecoration).shape == BoxShape.circle,
              )
              .first,
        );
        expect(dot.constraints!.maxWidth, closeTo(8.96, 1e-9));
        expect(dot.margin, const EdgeInsets.symmetric(horizontal: 2.24));
      },
    );
  });

  group('API06 AnimalLoading boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalLoadingStyle(tipGap: -1), throwsArgumentError);
      expect(
        () => AnimalLoadingStyle(tipBorderWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalLoadingStyle(tipTextStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(AnimalLoadingStyle(tipGap: 10));
      final AnimalIslandTheme b = themed(AnimalLoadingStyle(tipGap: 30));
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(b, 0.5).components.loading!.tipGap, closeTo(20, 1e-9));
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalIslandTheme a = themed(
        AnimalLoadingStyle(tipBorderWidth: 3, color: const Color(0xFF00AA00)),
      );
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      final AnimalIslandTheme early = a.lerp(light, 0.25);
      final AnimalIslandTheme late = a.lerp(light, 0.75);
      expect(early.components.loading!.tipBorderWidth, 3);
      expect(early.components.loading!.color, const Color(0xFF00AA00));
      expect(late.components.loading?.tipBorderWidth, isNull);
      expect(late.components.loading?.color, isNull);
    });
  });
}
