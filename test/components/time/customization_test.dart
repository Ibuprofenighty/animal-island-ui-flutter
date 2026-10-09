// API06 efficacy and precedence oracles for AnimalTime.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pumpTime(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalTimeStyle? style,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: AnimalTime(
            time: DateTime(2026, 1, 1, 12, 34, 56),
            style: style,
          ),
        ),
      ),
    );
    // Let MaterialApp finish animating a theme change.
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalTimeStyle time) => AnimalIslandTheme.light
      .copyWith(components: AnimalComponentThemes(time: time));

  Container card(WidgetTester tester) => tester.widget<Container>(
    find
        .descendant(
          of: find.byType(AnimalTime),
          matching: find.byType(Container),
        )
        .first,
  );
  BoxDecoration decoration(WidgetTester tester) =>
      card(tester).decoration! as BoxDecoration;
  TextStyle text(WidgetTester tester) =>
      tester.widget<Text>(find.text('12:34:56')).style!;
  AnimalIcon icon(WidgetTester tester) =>
      tester.widget<AnimalIcon>(find.byType(AnimalIcon));
  double iconGap(WidgetTester tester) => tester
      .widget<SizedBox>(
        find.descendant(
          of: find.byType(AnimalTime),
          matching: find.byWidgetPredicate(
            (w) => w is SizedBox && w.width != null && w.child == null,
          ),
        ),
      )
      .width!;

  group('API06 AnimalTime efficacy', () {
    testWidgets('token changes reach every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      await pumpTime(
        tester,
        theme: light.copyWith(
          typography: light.typography.copyWith(
            heading: light.typography.heading.copyWith(fontSize: 30),
          ),
          colors: light.colors.copyWith(
            bgContent: const Color(0xFF101010),
            primaryText: const Color(0xFF202020),
          ),
          spacing: light.spacing.copyWith(sm: 9, md: 13),
        ),
      );
      expect(text(tester).fontSize, 27);
      expect(decoration(tester).color, const Color(0xFF101010));
      expect(icon(tester).color, const Color(0xFF202020));
      expect(iconGap(tester), 9);
      expect(
        card(tester).padding,
        EdgeInsets.symmetric(
          horizontal: light.spacing.lg + light.spacing.xxs,
          vertical: 13,
        ),
      );
    });

    testWidgets('every component-theme field changes the rendered card', (
      tester,
    ) async {
      await pumpTime(
        tester,
        theme: themed(
          AnimalTimeStyle(
            padding: const EdgeInsets.all(7),
            backgroundColor: const Color(0xFF102030),
            borderColor: const Color(0xFF0000AA),
            borderWidth: 3,
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            textStyle: const TextStyle(fontSize: 21),
            textColor: const Color(0xFFAA0000),
            iconColor: const Color(0xFF00AA00),
            iconSize: 31,
            iconGap: 11,
          ),
        ),
      );
      expect(card(tester).padding, const EdgeInsets.all(7));
      final BoxDecoration d = decoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 3);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(5)));
      expect(text(tester).fontSize, 21);
      expect(text(tester).color, const Color(0xFFAA0000));
      expect(icon(tester).color, const Color(0xFF00AA00));
      expect(icon(tester).size, 31);
      expect(iconGap(tester), 11);
    });
  });

  group('API06 AnimalTime precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalTimeStyle(borderWidth: 2.5, iconSize: 24),
      );
      await pumpTime(tester);
      expect(decoration(tester).border!.top.width, 1.5);
      expect(icon(tester).size, 20);

      await pumpTime(tester, theme: theme);
      expect(decoration(tester).border!.top.width, 2.5);
      expect(icon(tester).size, 24);

      await pumpTime(
        tester,
        theme: theme,
        style: AnimalTimeStyle(iconSize: 28),
      );
      expect(decoration(tester).border!.top.width, 2.5);
      expect(icon(tester).size, 28);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpTime(
        tester,
        theme: themed(
          AnimalTimeStyle(textStyle: const TextStyle(letterSpacing: 1.25)),
        ),
        style: AnimalTimeStyle(
          textStyle: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      final TextStyle style = text(tester);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.letterSpacing, 1.25);
      expect(
        style.fontSize,
        AnimalIslandTheme.light.typography.heading.fontSize! * 0.9,
      );
    });
  });

  group('API06 AnimalTime boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalTimeStyle(borderWidth: -1), throwsArgumentError);
      expect(() => AnimalTimeStyle(iconSize: double.nan), throwsArgumentError);
      expect(
        () => AnimalTimeStyle(padding: const EdgeInsets.all(-2)),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimeStyle(
          borderRadius: const BorderRadius.all(Radius.circular(-1)),
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalTimeStyle(textStyle: const TextStyle(fontSize: -3)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalTimeStyle a = AnimalTimeStyle(iconGap: 4);
      final AnimalTimeStyle b = AnimalTimeStyle(iconGap: 8);
      expect(AnimalTimeStyle.lerp(a, b, 0), same(a));
      expect(AnimalTimeStyle.lerp(a, b, 1), same(b));
      expect(AnimalTimeStyle.lerp(a, b, 0.5)!.iconGap, 6);
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalTimeStyle b = AnimalTimeStyle(iconSize: 30);
      expect(AnimalTimeStyle.lerp(null, b, 0.4)!.iconSize, isNull);
      expect(AnimalTimeStyle.lerp(null, b, 0.6)!.iconSize, 30);
    });
  });
}
