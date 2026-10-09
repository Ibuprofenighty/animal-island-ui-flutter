// API06 efficacy and precedence oracles for AnimalCountdown.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpCountdown(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalCountdownStyle? style,
    AnimalCountdownSize size = AnimalCountdownSize.middle,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: AnimalCountdown.duration(
            duration: const Duration(minutes: 12, seconds: 34),
            format: AnimalCountdownFormat.minutesSeconds,
            prefix: const Text('Prefix'),
            size: size,
            style: style,
          ),
        ),
      ),
    );
    // Let MaterialApp finish animating a theme change.
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalCountdownThemeData countdown) =>
      AnimalIslandTheme.light.copyWith(
        components: AnimalComponentThemes(countdown: countdown),
      );

  Container tile(WidgetTester tester) => tester.widget<Container>(
    find.ancestor(of: find.text('12'), matching: find.byType(Container)).first,
  );
  BoxDecoration decoration(WidgetTester tester) =>
      tile(tester).decoration! as BoxDecoration;
  Size tileSize(WidgetTester tester) => tester.getSize(
    find.ancestor(of: find.text('12'), matching: find.byType(Container)).first,
  );
  TextStyle digits(WidgetTester tester) =>
      tester.widget<Text>(find.text('12')).style!;
  TextStyle separator(WidgetTester tester) =>
      tester.widget<Text>(find.text(':')).style!;
  TextStyle unit(WidgetTester tester) =>
      tester.widget<Text>(find.text('MINS')).style!;
  double gapUnder(WidgetTester tester) => tester
      .widgetList<SizedBox>(
        find.descendant(
          of: find.byType(AnimalCountdown),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.height != null && w.child == null,
          ),
        ),
      )
      .first
      .height!;
  double prefixGap(WidgetTester tester) => tester
      .widget<SizedBox>(
        find.descendant(
          of: find.byType(AnimalCountdown),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width != null && w.child == null,
          ),
        ),
      )
      .width!;
  EdgeInsetsGeometry separatorPadding(WidgetTester tester) => tester
      .widget<Padding>(
        find.ancestor(of: find.text(':'), matching: find.byType(Padding)).first,
      )
      .padding;

  group('API06 AnimalCountdown efficacy', () {
    testWidgets('token changes reach every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      await pumpCountdown(
        tester,
        theme: light.copyWith(
          typography: light.typography.copyWith(
            countdown: light.typography.countdown.copyWith(fontSize: 56),
          ),
          colors: light.colors.copyWith(
            bgContent: const Color(0xFF101010),
            text: const Color(0xFF202020),
          ),
          spacing: light.spacing.copyWith(sm: 12),
        ),
      );
      expect(digits(tester).fontSize, 44);
      expect(digits(tester).color, const Color(0xFF202020));
      expect(separator(tester).color, const Color(0xFF202020));
      expect(decoration(tester).color, const Color(0xFF101010));
      expect(prefixGap(tester), 12);
    });

    testWidgets('every component-theme field changes the rendered countdown', (
      tester,
    ) async {
      await pumpCountdown(
        tester,
        theme: themed(
          AnimalCountdownThemeData(
            style: AnimalCountdownStyle(
              width: 61,
              height: 52,
              backgroundColor: const Color(0xFF102030),
              borderColor: const Color(0xFF0000AA),
              borderWidth: 3,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              shadow: const BoxShadow(
                color: Color(0xFF123456),
                offset: Offset(0, 7),
              ),
              digitTextStyle: const TextStyle(fontSize: 19),
              digitTextColor: const Color(0xFFAA0000),
              labelTextStyle: const TextStyle(fontSize: 9),
              labelTextColor: const Color(0xFF00AA00),
              labelGap: 7,
              separatorPadding: const EdgeInsets.all(3),
              prefixGap: 13,
            ),
          ),
        ),
      );
      expect(tileSize(tester), const Size(61, 52));
      final BoxDecoration d = decoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 3);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(5)));
      expect(d.boxShadow, const [
        BoxShadow(color: Color(0xFF123456), offset: Offset(0, 7)),
      ]);
      expect(digits(tester).fontSize, 19);
      expect(digits(tester).color, const Color(0xFFAA0000));
      expect(unit(tester).fontSize, 9);
      expect(unit(tester).color, const Color(0xFF00AA00));
      expect(gapUnder(tester), 7);
      expect(separatorPadding(tester), const EdgeInsets.all(3));
      expect(prefixGap(tester), 13);
    });
  });

  group('API06 AnimalCountdown precedence', () {
    testWidgets('instance > size theme > general theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalCountdownThemeData(
          style: AnimalCountdownStyle(width: 50, borderWidth: 2),
          smallStyle: AnimalCountdownStyle(width: 44),
        ),
      );
      await pumpCountdown(tester, size: AnimalCountdownSize.small);
      expect(tileSize(tester), const Size(40, 36));
      expect(decoration(tester).border!.top.width, 1.5);

      await pumpCountdown(tester, theme: theme);
      expect(tileSize(tester).width, 50);
      await pumpCountdown(
        tester,
        theme: theme,
        size: AnimalCountdownSize.small,
      );
      expect(tileSize(tester).width, 44);
      expect(decoration(tester).border!.top.width, 2);

      await pumpCountdown(
        tester,
        theme: theme,
        size: AnimalCountdownSize.small,
        style: AnimalCountdownStyle(width: 47),
      );
      expect(tileSize(tester).width, 47);
      expect(decoration(tester).border!.top.width, 2);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpCountdown(
        tester,
        theme: themed(
          AnimalCountdownThemeData(
            style: AnimalCountdownStyle(
              labelTextStyle: const TextStyle(letterSpacing: 1.25),
            ),
          ),
        ),
        style: AnimalCountdownStyle(
          labelTextStyle: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      final TextStyle style = unit(tester);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 1.25);
      expect(style.fontWeight, FontWeight.w700);
      expect(
        style.fontSize,
        AnimalIslandTheme.light.typography.caption.fontSize! * 10 / 12,
      );
    });
  });

  group('API06 AnimalCountdown boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalCountdownStyle(width: -1), throwsArgumentError);
      expect(
        () => AnimalCountdownStyle(labelGap: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalCountdownStyle(
          separatorPadding: const EdgeInsets.only(left: -1),
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalCountdownStyle(
          digitTextStyle: const TextStyle(fontSize: double.infinity),
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalCountdownThemeData a = AnimalCountdownThemeData(
        middleStyle: AnimalCountdownStyle(width: 40),
      );
      final AnimalCountdownThemeData b = AnimalCountdownThemeData(
        middleStyle: AnimalCountdownStyle(width: 60),
      );
      expect(AnimalCountdownThemeData.lerp(a, b, 0), same(a));
      expect(AnimalCountdownThemeData.lerp(a, b, 1), same(b));
      expect(AnimalCountdownThemeData.lerp(a, b, 0.5)!.middleStyle!.width, 50);
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalCountdownStyle b = AnimalCountdownStyle(prefixGap: 9);
      expect(AnimalCountdownStyle.lerp(null, b, 0.4)!.prefixGap, isNull);
      expect(AnimalCountdownStyle.lerp(null, b, 0.6)!.prefixGap, 9);
    });
  });
}
