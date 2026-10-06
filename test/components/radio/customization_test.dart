// API06 efficacy and precedence oracles for AnimalRadio<int>.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ValueKey<String> subject = ValueKey<String>('radio');

  Future<void> pumpRadio(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalRadioStyle? style,
    AnimalRadioSize size = AnimalRadioSize.middle,
    bool selected = true,
    Color? activeColor,
    bool disabled = false,
    FocusNode? focusNode,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: Center(
            child: AnimalRadio<int>(
              key: subject,
              value: 1,
              groupValue: selected ? 1 : 2,
              activeColor: activeColor,
              disabled: disabled,
              size: size,
              style: style,
              focusNode: focusNode,
              label: const Text('Label'),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    // Let the app theme transition finish, then the surface transition.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
  }

  Finder control() => find
      .descendant(
        of: find.byKey(subject),
        matching: find.byType(AnimatedContainer),
      )
      .last;
  BoxDecoration decoration(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(control()).decoration! as BoxDecoration;
  TextStyle labelTextStyle(WidgetTester tester) => tester
      .widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text('Label'),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style;
  AnimalIcon icon(WidgetTester tester) => tester.widget<AnimalIcon>(
    find.descendant(of: find.byKey(subject), matching: find.byType(AnimalIcon)),
  );
  double labelGap(WidgetTester tester) =>
      tester.getTopLeft(find.text('Label')).dx -
      tester.getTopRight(control()).dx;

  AnimalIslandTheme themed(AnimalRadioThemeData radio) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(radio: radio));

  group('API06 AnimalRadio efficacy', () {
    testWidgets('token change reaches every size preset', (tester) async {
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: AnimalIslandTheme.light.typography.copyWith(
          body: AnimalIslandTheme.light.typography.body.copyWith(fontSize: 28),
        ),
        spacing: AnimalIslandTheme.light.spacing.copyWith(sm: 11),
      );
      for (final (AnimalRadioSize size, double expected)
          in <(AnimalRadioSize, double)>[
            (AnimalRadioSize.small, 26),
            (AnimalRadioSize.middle, 28),
            (AnimalRadioSize.large, 32),
          ]) {
        await pumpRadio(tester, theme: theme, size: size);
        expect(labelTextStyle(tester).fontSize, closeTo(expected, 1e-9));
        expect(labelGap(tester), closeTo(11, 1e-9));
      }
    });

    testWidgets('default size presets keep the light geometry', (tester) async {
      for (final (AnimalRadioSize size, double box, double glyph, double r)
          in <(AnimalRadioSize, double, double, double)>[
            (AnimalRadioSize.small, 18, 12, 12),
            (AnimalRadioSize.middle, 22, 14, 14),
            (AnimalRadioSize.large, 26, 18, 16),
          ]) {
        await pumpRadio(tester, size: size);
        expect(tester.getSize(control()), Size(box, box));
        expect(icon(tester).size, glyph);
        expect(decoration(tester).borderRadius, BorderRadius.circular(r));
        expect(decoration(tester).border!.top.width, 1.8);
      }
    });

    testWidgets('every component-theme field changes the rendered radio', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpRadio(
        tester,
        focusNode: focusNode,
        theme: themed(
          AnimalRadioThemeData(
            style: AnimalRadioStyle(
              boxSize: 31,
              iconSize: 21,
              borderWidth: 3.5,
              labelGap: 17,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
              labelTextStyle: const TextStyle(fontStyle: FontStyle.italic),
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF102030)
                    : const Color(0xFF302010),
              ),
              borderColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? const Color(0xFF00AA00)
                    : const Color(0xFF0000AA),
              ),
              checkColor: const WidgetStatePropertyAll<Color>(
                Color(0xFFAAAA00),
              ),
              labelTextColor: const WidgetStatePropertyAll<Color>(
                Color(0xFFAA0000),
              ),
              shadow: const BoxShadow(
                color: Color(0xFF123456),
                offset: Offset(0, 9),
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(control()), const Size(31, 31));
      final BoxDecoration d = decoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 3.5);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(2)));
      expect(d.boxShadow, <BoxShadow>[
        const BoxShadow(color: Color(0xFF123456), offset: Offset(0, 9)),
      ]);
      expect(icon(tester).size, 21);
      expect(icon(tester).color, const Color(0xFFAAAA00));
      expect(labelTextStyle(tester).fontStyle, FontStyle.italic);
      expect(labelTextStyle(tester).color, const Color(0xFFAA0000));
      expect(labelGap(tester), closeTo(17, 1e-9));

      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      expect(decoration(tester).border!.top.color, const Color(0xFF00AA00));
    });

    testWidgets('unselected fill and border resolve without selection', (
      tester,
    ) async {
      await pumpRadio(
        tester,
        selected: false,
        theme: themed(
          AnimalRadioThemeData(
            style: AnimalRadioStyle(
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF102030)
                    : const Color(0xFF302010),
              ),
              borderColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFF0000AA)
                    : const Color(0xFFAA00AA),
              ),
            ),
          ),
        ),
      );
      expect(decoration(tester).color, const Color(0xFF302010));
      expect(decoration(tester).border!.top.color, const Color(0xFFAA00AA));
      expect(find.byType(AnimalIcon), findsNothing);
    });

    testWidgets('activeColor sits between the instance style and the theme', (
      tester,
    ) async {
      const Color active = Color(0xFFB52A92);
      final AnimalIslandTheme theme = themed(
        AnimalRadioThemeData(
          style: AnimalRadioStyle(
            fillColor: const WidgetStatePropertyAll<Color>(Color(0xFF102030)),
            checkColor: const WidgetStatePropertyAll<Color>(Color(0xFF00CCCC)),
          ),
        ),
      );

      // activeColor wins over the theme and draws a white check.
      await pumpRadio(tester, theme: theme, activeColor: active);
      expect(decoration(tester).color, active);
      expect(decoration(tester).border!.top.color, active);
      expect(icon(tester).color, const Color(0xFFFFFFFF));

      // The instance style wins over activeColor.
      await pumpRadio(
        tester,
        theme: theme,
        activeColor: active,
        style: AnimalRadioStyle(
          fillColor: const WidgetStatePropertyAll<Color>(Color(0xFF445566)),
          checkColor: const WidgetStatePropertyAll<Color>(Color(0xFF665544)),
        ),
      );
      expect(decoration(tester).color, const Color(0xFF445566));
      expect(icon(tester).color, const Color(0xFF665544));

      // Without activeColor the theme applies.
      await pumpRadio(tester, theme: theme);
      expect(decoration(tester).color, const Color(0xFF102030));
      expect(icon(tester).color, const Color(0xFF00CCCC));
    });

    testWidgets('disabled colors resolve the disabled state', (tester) async {
      await pumpRadio(
        tester,
        disabled: true,
        theme: themed(
          AnimalRadioThemeData(
            style: AnimalRadioStyle(
              fillColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? const Color(0xFF445566)
                    : null,
              ),
              labelTextColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? const Color(0xFF665544)
                    : null,
              ),
            ),
          ),
        ),
      );
      expect(decoration(tester).color, const Color(0xFF445566));
      expect(labelTextStyle(tester).color, const Color(0xFF665544));
      expect(decoration(tester).boxShadow, isEmpty);
    });

    testWidgets('the focus ring color themes the focused border', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpRadio(
        tester,
        focusNode: focusNode,
        theme: AnimalIslandTheme.light.copyWith(
          components: AnimalComponentThemes(
            focusRing: AnimalFocusRingStyle(color: const Color(0xFF7700CC)),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      expect(decoration(tester).border!.top.color, const Color(0xFF7700CC));
    });

    testWidgets('a group forwards its style to every radio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalRadioGroup<int>(
              value: 1,
              options: const <AnimalOption<int>>[
                AnimalOption<int>(value: 1, label: 'One'),
                AnimalOption<int>(value: 2, label: 'Two'),
              ],
              style: AnimalRadioStyle(boxSize: 33),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      for (final Element radio in find.byType(AnimalRadio<int>).evaluate()) {
        final Finder box = find
            .descendant(
              of: find.byWidget(radio.widget),
              matching: find.byType(AnimatedContainer),
            )
            .last;
        expect(tester.getSize(box), const Size(33, 33));
      }
      expect(find.byType(AnimalRadio<int>), findsNWidgets(2));
    });
  });

  group('API06 AnimalRadio group gaps', () {
    Future<double> gapBetweenItems(
      WidgetTester tester, {
      AnimalIslandTheme? theme,
      AnimalRadioStyle? style,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: AnimalRadioGroup<int>(
                value: 1,
                options: const <AnimalOption<int>>[
                  AnimalOption<int>(value: 1, label: 'One'),
                  AnimalOption<int>(value: 2, label: 'Two'),
                ],
                style: style,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final List<Rect> rects = find
          .byType(AnimalRadio<int>)
          .evaluate()
          .map((Element e) => tester.getRect(find.byWidget(e.widget)))
          .toList();
      return rects[1].left - rects[0].right;
    }

    testWidgets('instance > theme > token default for a horizontal group', (
      tester,
    ) async {
      // Light preset: a horizontal group separates items by spacing.lg.
      expect(await gapBetweenItems(tester), 16);
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        components: AnimalComponentThemes(
          radio: AnimalRadioThemeData(style: AnimalRadioStyle(groupGap: 17)),
        ),
      );
      expect(await gapBetweenItems(tester, theme: theme), 17);
      expect(
        await gapBetweenItems(
          tester,
          theme: theme,
          style: AnimalRadioStyle(groupGap: 23),
        ),
        23,
      );
    });
  });

  group('API06 AnimalRadio precedence', () {
    testWidgets('instance > size theme > general theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalRadioThemeData(
          style: AnimalRadioStyle(boxSize: 30, borderWidth: 2.5),
          middleStyle: AnimalRadioStyle(boxSize: 34),
        ),
      );

      // Token default: the light preset's middle box.
      await pumpRadio(tester);
      expect(tester.getSize(control()), const Size(22, 22));

      // The general theme style applies to sizes without their own style.
      await pumpRadio(tester, theme: theme, size: AnimalRadioSize.small);
      expect(tester.getSize(control()), const Size(30, 30));
      expect(decoration(tester).border!.top.width, 2.5);

      // The size-specific style wins over the general style.
      await pumpRadio(tester, theme: theme);
      expect(tester.getSize(control()), const Size(34, 34));
      expect(decoration(tester).border!.top.width, 2.5);

      // The instance style wins over both theme layers.
      await pumpRadio(
        tester,
        theme: theme,
        style: AnimalRadioStyle(boxSize: 38),
      );
      expect(tester.getSize(control()), const Size(38, 38));
      expect(decoration(tester).border!.top.width, 2.5);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpRadio(
        tester,
        theme: themed(
          AnimalRadioThemeData(
            style: AnimalRadioStyle(
              labelTextStyle: const TextStyle(letterSpacing: 1.25),
            ),
          ),
        ),
        style: AnimalRadioStyle(
          labelTextStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      final TextStyle style = labelTextStyle(tester);
      expect(style.fontWeight, FontWeight.w900);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, closeTo(14, 1e-9));
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalRadio boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalRadioStyle(boxSize: -1), throwsArgumentError);
      expect(() => AnimalRadioStyle(iconSize: -0.5), throwsArgumentError);
      expect(
        () => AnimalRadioStyle(borderWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalRadioStyle(labelGap: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalRadioStyle(labelTextStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalRadioThemeData(style: AnimalRadioStyle(boxSize: 20)),
      );
      final AnimalIslandTheme b = themed(
        AnimalRadioThemeData(style: AnimalRadioStyle(boxSize: 40)),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(
        a.lerp(b, 0.5).components.radio!.style!.boxSize,
        closeTo(30, 1e-9),
      );
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer".
      const BoxShadow shadow = BoxShadow(
        color: Color(0xFF123456),
        blurRadius: 6,
      );
      final AnimalIslandTheme a = themed(
        AnimalRadioThemeData(
          style: AnimalRadioStyle(boxSize: 30, shadow: shadow),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.radio!.style!.boxSize, 30);
      expect(early.components.radio!.style!.shadow, shadow);
      expect(late.components.radio?.style?.boxSize, isNull);
      expect(late.components.radio?.style?.shadow, isNull);
    });
  });
}
