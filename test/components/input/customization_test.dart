// API06 efficacy and precedence oracles for AnimalInput.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TextEditingController controller;
  setUp(() => controller = TextEditingController(text: 'Island'));
  tearDown(() => controller.dispose());

  Future<void> pumpInput(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalInputStyle? style,
    AnimalInputSize size = AnimalInputSize.middle,
    AnimalInputStatus status = AnimalInputStatus.normal,
    bool disabled = false,
    FocusNode? focusNode,
    bool shadow = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 300,
              child: AnimalInput(
                key: const ValueKey<String>('input'),
                controller: controller,
                placeholder: 'Hint',
                size: size,
                style: style,
                status: status,
                disabled: disabled,
                focusNode: focusNode,
                shadow: shadow,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  AnimatedContainer container(WidgetTester tester) => tester.widget(
    find.descendant(
      of: find.byKey(const ValueKey<String>('input')),
      matching: find.byType(AnimatedContainer),
    ),
  );
  BoxDecoration decoration(WidgetTester tester) =>
      container(tester).decoration! as BoxDecoration;
  TextField field(WidgetTester tester) => tester.widget(find.byType(TextField));

  AnimalIslandTheme themed(AnimalInputThemeData input) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(input: input));

  group('API06 AnimalInput efficacy', () {
    testWidgets('token change reaches every size preset', (tester) async {
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: AnimalIslandTheme.light.typography.copyWith(
          body: AnimalIslandTheme.light.typography.body.copyWith(fontSize: 28),
        ),
      );
      for (final (AnimalInputSize size, double expected)
          in <(AnimalInputSize, double)>[
            (AnimalInputSize.small, 26),
            (AnimalInputSize.middle, 30),
            (AnimalInputSize.large, 34),
          ]) {
        await pumpInput(tester, theme: theme, size: size);
        expect(field(tester).style!.fontSize, closeTo(expected, 1e-9));
        expect(
          field(tester).decoration!.hintStyle!.fontSize,
          closeTo(expected - 1, 1e-9),
        );
      }
    });

    testWidgets('every component-theme field changes the rendered input', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpInput(
        tester,
        shadow: true,
        focusNode: focusNode,
        theme: themed(
          AnimalInputThemeData(
            style: AnimalInputStyle(
              minHeight: 61,
              horizontalPadding: 23,
              textStyle: const TextStyle(fontSize: 19),
              placeholderTextStyle: const TextStyle(
                fontStyle: FontStyle.italic,
              ),
              backgroundColor: const WidgetStatePropertyAll<Color>(
                Color(0xFF102030),
              ),
              borderColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? const Color(0xFF00AA00)
                    : const Color(0xFF0000AA),
              ),
              textColor: const WidgetStatePropertyAll<Color>(Color(0xFFAA0000)),
              placeholderTextColor: const WidgetStatePropertyAll<Color>(
                Color(0xFF00AAAA),
              ),
              cursorColor: const Color(0xFFAAAA00),
              borderWidth: 3.5,
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              depthShadow: const BoxShadow(
                color: Color(0xFF123456),
                offset: Offset(0, 9),
              ),
            ),
          ),
        ),
      );

      final AnimatedContainer box = container(tester);
      expect(box.constraints!.minHeight, 61);
      expect(box.padding, const EdgeInsets.symmetric(horizontal: 23));
      final BoxDecoration d = decoration(tester);
      expect(d.color, const Color(0xFF102030));
      expect(d.border!.top.color, const Color(0xFF0000AA));
      expect(d.border!.top.width, 3.5);
      expect(d.borderRadius, const BorderRadius.all(Radius.circular(7)));
      expect(
        d.boxShadow,
        contains(
          const BoxShadow(color: Color(0xFF123456), offset: Offset(0, 9)),
        ),
      );
      final TextField f = field(tester);
      expect(f.style!.fontSize, 19);
      expect(f.style!.color, const Color(0xFFAA0000));
      expect(f.cursorColor, const Color(0xFFAAAA00));
      expect(f.decoration!.hintStyle!.fontStyle, FontStyle.italic);
      expect(f.decoration!.hintStyle!.color, const Color(0xFF00AAAA));

      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      expect(decoration(tester).border!.top.color, const Color(0xFF00AA00));
    });

    testWidgets('clear action and glow fields change the rendered input', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: themed(
            AnimalInputThemeData(
              style: AnimalInputStyle(
                clearIconSize: 21,
                clearIconColor: const Color(0xFF00AA00),
                clearButtonBorderRadius: const BorderRadius.all(
                  Radius.circular(3),
                ),
                clearButtonBackgroundColor: const WidgetStatePropertyAll<Color>(
                  Color(0xFF0000AA),
                ),
                glowColor: const WidgetStatePropertyAll<Color>(
                  Color(0xFFAA00AA),
                ),
              ),
            ),
          ).toThemeData(),
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AnimalInput(
                key: const ValueKey<String>('input'),
                controller: controller,
                clearable: true,
                focusNode: focusNode,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      final Finder clearIcon = find.byWidgetPredicate(
        (w) => w is AnimalIcon && w.data == AnimalIcons.close,
      );
      final AnimalIcon icon = tester.widget(clearIcon);
      expect(icon.size, 21);
      expect(icon.color, const Color(0xFF00AA00));
      final BoxDecoration fill =
          tester
                  .widget<AnimatedContainer>(
                    find
                        .ancestor(
                          of: clearIcon,
                          matching: find.byType(AnimatedContainer),
                        )
                        .first,
                  )
                  .decoration!
              as BoxDecoration;
      expect(fill.color, const Color(0xFF0000AA));
      expect(fill.borderRadius, const BorderRadius.all(Radius.circular(3)));

      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      final BoxDecoration field =
          tester
                  .widgetList<AnimatedContainer>(
                    find.descendant(
                      of: find.byKey(const ValueKey<String>('input')),
                      matching: find.byType(AnimatedContainer),
                    ),
                  )
                  .first
                  .decoration!
              as BoxDecoration;
      expect(
        field.boxShadow,
        contains(
          const BoxShadow(
            color: Color(0xFFAA00AA),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ),
      );
    });

    testWidgets('a wide clear control still fits the field', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: themed(
            AnimalInputThemeData(
              style: AnimalInputStyle(
                clearIconSize: 24,
                clearButtonPadding: const EdgeInsets.symmetric(horizontal: 40),
              ),
            ),
          ).toThemeData(),
          home: Scaffold(
            body: SizedBox(
              width: 220,
              child: AnimalInput(
                key: const ValueKey<String>('input'),
                controller: controller,
                clearable: true,
                prefix: const Text('Prefix'),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      final Rect field = tester.getRect(
        find.byKey(const ValueKey<String>('input')),
      );
      final Rect action = tester.getRect(
        find
            .ancestor(
              of: find.byWidgetPredicate(
                (w) => w is AnimalIcon && w.data == AnimalIcons.close,
              ),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      expect(action.width, closeTo(104, 1e-6));
      expect(action.right, lessThanOrEqualTo(field.right + 1e-6));
    });

    testWidgets('spacing fields replace the token gaps', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: themed(
            AnimalInputThemeData(
              style: AnimalInputStyle(
                adornmentGap: 11,
                multilineVerticalPadding: 13,
                clearButtonPadding: const EdgeInsets.symmetric(horizontal: 9),
              ),
            ),
          ).toThemeData(),
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: AnimalInput(
                key: const ValueKey<String>('input'),
                controller: controller,
                clearable: true,
                prefix: const Text('P'),
                maxLines: 3,
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 11),
        findsNWidgets(2),
      );
      // The field's own container is the outermost AnimatedContainer.
      final AnimatedContainer field = tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('input')),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .first;
      expect(
        field.padding,
        const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Padding &&
              w.padding == const EdgeInsets.symmetric(horizontal: 9),
        ),
        findsOneWidget,
      );
    });

    testWidgets('warning color and multiline radius are themed', (
      tester,
    ) async {
      await pumpInput(
        tester,
        status: AnimalInputStatus.warning,
        theme: themed(
          AnimalInputThemeData(
            style: AnimalInputStyle(warningColor: const Color(0xFFCC6600)),
          ),
        ),
      );
      expect(decoration(tester).border!.top.color, const Color(0xFFCC6600));
    });

    testWidgets('the focus ring color themes the focused border', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpInput(
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
  });

  group('API06 AnimalInput precedence', () {
    testWidgets('instance > size theme > general theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalInputThemeData(
          style: AnimalInputStyle(minHeight: 50, borderWidth: 2.5),
          middleStyle: AnimalInputStyle(minHeight: 60),
        ),
      );

      // Token default: the light preset's middle height.
      await pumpInput(tester);
      expect(container(tester).constraints!.minHeight, 44);

      // The general theme style applies to sizes without their own style.
      await pumpInput(tester, theme: theme, size: AnimalInputSize.small);
      expect(container(tester).constraints!.minHeight, 50);
      expect(decoration(tester).border!.top.width, 2.5);

      // The size-specific style wins over the general style.
      await pumpInput(tester, theme: theme);
      expect(container(tester).constraints!.minHeight, 60);
      expect(decoration(tester).border!.top.width, 2.5);

      // The instance style wins over both theme layers.
      await pumpInput(
        tester,
        theme: theme,
        style: AnimalInputStyle(minHeight: 70),
      );
      expect(container(tester).constraints!.minHeight, 70);
      expect(decoration(tester).border!.top.width, 2.5);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpInput(
        tester,
        theme: themed(
          AnimalInputThemeData(
            style: AnimalInputStyle(
              textStyle: const TextStyle(letterSpacing: 1.25),
            ),
          ),
        ),
        style: AnimalInputStyle(
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      final TextStyle style = field(tester).style!;
      expect(style.fontWeight, FontWeight.w900);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, closeTo(15, 1e-9));
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalInput boundary', () {
    test('styles reject values components cannot render', () {
      expect(
        () => AnimalInputStyle(
          clearButtonPadding: const EdgeInsets.only(left: -1),
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalInputStyle(
          clearButtonBorderRadius: const BorderRadius.all(Radius.circular(-2)),
        ),
        throwsArgumentError,
      );
      expect(() => AnimalInputStyle(minHeight: -1), throwsArgumentError);
      expect(
        () => AnimalInputStyle(borderWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalInputStyle(textStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
      expect(
        () => AnimalFocusRingStyle(
          width: AnimalFocusRingStyle.minimumWidth - 0.5,
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalInputThemeData(style: AnimalInputStyle(minHeight: 40)),
      );
      final AnimalIslandTheme b = themed(
        AnimalInputThemeData(style: AnimalInputStyle(minHeight: 60)),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(
        a.lerp(b, 0.5).components.input!.style!.minHeight,
        closeTo(50, 1e-9),
      );
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer".
      // Interpolating from 0 would drop below the focus ring floor.
      final AnimalIslandTheme a = AnimalIslandTheme.light.copyWith(
        components: AnimalComponentThemes(
          focusRing: AnimalFocusRingStyle(width: 3),
          input: AnimalInputThemeData(style: AnimalInputStyle(minHeight: 60)),
        ),
      );
      const AnimalIslandTheme Function() light = _light;
      final AnimalIslandTheme early = a.lerp(light(), 0.25);
      final AnimalIslandTheme late = a.lerp(light(), 0.75);
      expect(early.components.focusRing!.width, 3);
      expect(early.components.input!.style!.minHeight, 60);
      expect(late.components.focusRing?.width, isNull);
      expect(late.components.input?.style?.minHeight, isNull);
    });
  });
}

AnimalIslandTheme _light() => AnimalIslandTheme.light;
