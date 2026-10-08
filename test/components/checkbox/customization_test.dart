// API06 efficacy and precedence oracles for AnimalCheckbox.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ValueKey<String> subject = ValueKey<String>('checkbox');

  Future<void> pumpCheckbox(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalCheckboxStyle? style,
    AnimalCheckboxSize size = AnimalCheckboxSize.middle,
    bool value = true,
    bool indeterminate = false,
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
            child: AnimalCheckbox(
              key: subject,
              value: value,
              indeterminate: indeterminate,
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

  AnimalIslandTheme themed(AnimalCheckboxThemeData checkbox) =>
      AnimalIslandTheme.light.copyWith(
        components: AnimalComponentThemes(checkbox: checkbox),
      );

  group('API06 AnimalCheckbox efficacy', () {
    testWidgets('token change reaches every size preset', (tester) async {
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: AnimalIslandTheme.light.typography.copyWith(
          body: AnimalIslandTheme.light.typography.body.copyWith(fontSize: 28),
        ),
        spacing: AnimalIslandTheme.light.spacing.copyWith(sm: 11),
      );
      for (final (AnimalCheckboxSize size, double expected)
          in <(AnimalCheckboxSize, double)>[
            (AnimalCheckboxSize.small, 26),
            (AnimalCheckboxSize.middle, 28),
            (AnimalCheckboxSize.large, 32),
          ]) {
        await pumpCheckbox(tester, theme: theme, size: size);
        expect(labelTextStyle(tester).fontSize, closeTo(expected, 1e-9));
        expect(labelGap(tester), closeTo(11, 1e-9));
      }
    });

    testWidgets('default size presets keep the light geometry', (tester) async {
      for (final (AnimalCheckboxSize size, double box, double glyph, double r)
          in <(AnimalCheckboxSize, double, double, double)>[
            (AnimalCheckboxSize.small, 18, 12, 5),
            (AnimalCheckboxSize.middle, 22, 14, 6),
            (AnimalCheckboxSize.large, 26, 18, 7),
          ]) {
        await pumpCheckbox(tester, size: size);
        expect(tester.getSize(control()), Size(box, box));
        expect(icon(tester).size, glyph);
        expect(decoration(tester).borderRadius, BorderRadius.circular(r));
        expect(decoration(tester).border!.top.width, 1.8);
      }
    });

    testWidgets('every component-theme field changes the rendered checkbox', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpCheckbox(
        tester,
        focusNode: focusNode,
        theme: themed(
          AnimalCheckboxThemeData(
            style: AnimalCheckboxStyle(
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

    testWidgets('unchecked fill and the indeterminate bar are themed', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalCheckboxThemeData(
          style: AnimalCheckboxStyle(
            iconSize: 20,
            fillColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF102030)
                  : const Color(0xFF302010),
            ),
            checkColor: const WidgetStatePropertyAll<Color>(Color(0xFF00CCCC)),
          ),
        ),
      );
      await pumpCheckbox(tester, theme: theme, value: false);
      expect(decoration(tester).color, const Color(0xFF302010));

      await pumpCheckbox(
        tester,
        theme: theme,
        value: false,
        indeterminate: true,
      );
      expect(decoration(tester).color, const Color(0xFF102030));
      final Container bar = tester.widget<Container>(
        find.descendant(of: control(), matching: find.byType(Container)).last,
      );
      expect(bar.constraints!.maxWidth, closeTo(14, 1e-9));
      expect((bar.decoration! as BoxDecoration).color, const Color(0xFF00CCCC));
    });

    testWidgets('disabled colors resolve the disabled state', (tester) async {
      await pumpCheckbox(
        tester,
        disabled: true,
        theme: themed(
          AnimalCheckboxThemeData(
            style: AnimalCheckboxStyle(
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
      await pumpCheckbox(
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

    testWidgets('a group forwards its style to every checkbox', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCheckboxGroup<int>(
              value: const <int>[1],
              options: const <AnimalOption<int>>[
                AnimalOption<int>(value: 1, label: 'One'),
                AnimalOption<int>(value: 2, label: 'Two'),
              ],
              style: AnimalCheckboxStyle(boxSize: 33),
              onChanged: (_) {},
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      for (final Element checkbox in find.byType(AnimalCheckbox).evaluate()) {
        final Finder box = find
            .descendant(
              of: find.byWidget(checkbox.widget),
              matching: find.byType(AnimatedContainer),
            )
            .last;
        expect(tester.getSize(box), const Size(33, 33));
      }
      expect(find.byType(AnimalCheckbox), findsNWidgets(2));
    });
  });

  group('API06 AnimalCheckbox group gaps', () {
    Future<double> gapBetweenItems(
      WidgetTester tester, {
      AnimalIslandTheme? theme,
      AnimalCheckboxStyle? style,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: AnimalCheckboxGroup<int>(
                value: const <int>[1],
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
          .byType(AnimalCheckbox)
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
          checkbox: AnimalCheckboxThemeData(
            style: AnimalCheckboxStyle(groupGap: 17),
          ),
        ),
      );
      expect(await gapBetweenItems(tester, theme: theme), 17);
      expect(
        await gapBetweenItems(
          tester,
          theme: theme,
          style: AnimalCheckboxStyle(groupGap: 23),
        ),
        23,
      );
    });
  });

  group('API06 AnimalCheckbox precedence', () {
    testWidgets('instance > size theme > general theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalCheckboxThemeData(
          style: AnimalCheckboxStyle(boxSize: 30, borderWidth: 2.5),
          middleStyle: AnimalCheckboxStyle(boxSize: 34),
        ),
      );

      // Token default: the light preset's middle box.
      await pumpCheckbox(tester);
      expect(tester.getSize(control()), const Size(22, 22));

      // The general theme style applies to sizes without their own style.
      await pumpCheckbox(tester, theme: theme, size: AnimalCheckboxSize.small);
      expect(tester.getSize(control()), const Size(30, 30));
      expect(decoration(tester).border!.top.width, 2.5);

      // The size-specific style wins over the general style.
      await pumpCheckbox(tester, theme: theme);
      expect(tester.getSize(control()), const Size(34, 34));
      expect(decoration(tester).border!.top.width, 2.5);

      // The instance style wins over both theme layers.
      await pumpCheckbox(
        tester,
        theme: theme,
        style: AnimalCheckboxStyle(boxSize: 38),
      );
      expect(tester.getSize(control()), const Size(38, 38));
      expect(decoration(tester).border!.top.width, 2.5);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpCheckbox(
        tester,
        theme: themed(
          AnimalCheckboxThemeData(
            style: AnimalCheckboxStyle(
              labelTextStyle: const TextStyle(letterSpacing: 1.25),
            ),
          ),
        ),
        style: AnimalCheckboxStyle(
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

  group('API06 AnimalCheckbox boundary', () {
    test('styles reject values components cannot render', () {
      expect(
        () => AnimalCheckboxStyle(
          borderRadius: const BorderRadius.all(Radius.circular(-2)),
        ),
        throwsArgumentError,
      );
      expect(() => AnimalCheckboxStyle(boxSize: -1), throwsArgumentError);
      expect(() => AnimalCheckboxStyle(iconSize: -0.5), throwsArgumentError);
      expect(
        () => AnimalCheckboxStyle(borderWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalCheckboxStyle(labelGap: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalCheckboxStyle(labelTextStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalCheckboxThemeData(style: AnimalCheckboxStyle(boxSize: 20)),
      );
      final AnimalIslandTheme b = themed(
        AnimalCheckboxThemeData(style: AnimalCheckboxStyle(boxSize: 40)),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(
        a.lerp(b, 0.5).components.checkbox!.style!.boxSize,
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
        AnimalCheckboxThemeData(
          style: AnimalCheckboxStyle(boxSize: 30, shadow: shadow),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.checkbox!.style!.boxSize, 30);
      expect(early.components.checkbox!.style!.shadow, shadow);
      expect(late.components.checkbox?.style?.boxSize, isNull);
      expect(late.components.checkbox?.style?.shadow, isNull);
    });
  });
}
