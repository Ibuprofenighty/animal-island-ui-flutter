// API06 efficacy and precedence oracles for AnimalSelect.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const List<AnimalOption<String>> _options = <AnimalOption<String>>[
  AnimalOption<String>(
    value: 'a',
    label: 'Alpha',
    icon: SizedBox(width: 10, height: 10),
  ),
  AnimalOption<String>(value: 'b', label: 'Beta'),
  AnimalOption<String>(value: 'c', label: 'Gamma'),
];

void main() {
  Future<void> pumpSelect(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalSelectStyle? style,
    String? value = 'a',
    AnimalInputStatus status = AnimalInputStatus.normal,
    bool allowClear = false,
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
              child: AnimalSelect<String>(
                key: const ValueKey<String>('select'),
                value: value,
                options: _options,
                onChanged: (_) {},
                status: status,
                allowClear: allowClear,
                style: style,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> openMenu(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey<String>('select')));
    await tester.pumpAndSettle();
  }

  InteractiveRegion trigger(WidgetTester tester) => tester.widget(
    find.byWidgetPredicate(
      (widget) => widget is InteractiveRegion && widget.expanded != null,
    ),
  );
  Text triggerText(WidgetTester tester) => tester.widget(
    find.descendant(
      of: find.byWidget(trigger(tester)),
      matching: find.byType(Text),
    ),
  );
  InteractiveRegion option(WidgetTester tester, String label) => tester.widget(
    find.ancestor(
      of: find.text(label).last,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is InteractiveRegion && widget.semanticsBuilder != null,
      ),
    ),
  );
  Text optionText(WidgetTester tester, String label) =>
      tester.widget<Text>(find.text(label).last);
  MenuStyle menuStyle(WidgetTester tester) =>
      tester.widget<MenuAnchor>(find.byType(MenuAnchor)).style!;
  SizedBox menuBox(WidgetTester tester) => tester.widget(
    find
        .ancestor(of: find.byType(ListView), matching: find.byType(SizedBox))
        .first,
  );
  AnimalIcon icon(WidgetTester tester, AnimalIconData data) => tester.widget(
    find.byWidgetPredicate(
      (widget) => widget is AnimalIcon && widget.data == data,
    ),
  );

  AnimalIslandTheme themed(AnimalSelectStyle select) => AnimalIslandTheme.light
      .copyWith(components: AnimalComponentThemes(select: select));

  group('API06 AnimalSelect efficacy', () {
    testWidgets('a typography.body change reaches trigger and option text', (
      tester,
    ) async {
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: AnimalIslandTheme.light.typography.copyWith(
          body: AnimalIslandTheme.light.typography.body.copyWith(fontSize: 28),
        ),
      );
      await pumpSelect(tester, theme: theme);
      // The trigger label is body scaled by 15/14.
      expect(triggerText(tester).style!.fontSize, closeTo(30, 1e-9));
      await openMenu(tester);
      expect(optionText(tester, 'Alpha').style!.fontSize, closeTo(28, 1e-9));
      expect(optionText(tester, 'Beta').style!.fontSize, closeTo(28, 1e-9));
    });

    testWidgets('clear action and warning fields change the rendered select', (
      tester,
    ) async {
      await pumpSelect(
        tester,
        allowClear: true,
        status: AnimalInputStatus.warning,
        theme: themed(
          AnimalSelectStyle(
            clearButtonPadding: const EdgeInsets.all(5),
            clearButtonBorderRadius: const BorderRadius.all(Radius.circular(3)),
            clearButtonBackgroundColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF0000AA),
            ),
            warningColor: const Color(0xFFCC6600),
          ),
        ),
      );
      final Finder clearIcon = find.byWidgetPredicate(
        (w) => w is AnimalIcon && w.data == AnimalIcons.close,
      );
      final AnimatedContainer fill = tester.widget<AnimatedContainer>(
        find
            .ancestor(of: clearIcon, matching: find.byType(AnimatedContainer))
            .first,
      );
      expect(fill.padding, const EdgeInsets.all(5));
      final BoxDecoration fillDecoration = fill.decoration! as BoxDecoration;
      expect(fillDecoration.color, const Color(0xFF0000AA));
      expect(
        fillDecoration.borderRadius,
        const BorderRadius.all(Radius.circular(3)),
      );
      // The warning status takes the themed warning color, with a status glow.
      expect(trigger(tester).border!.top.color, const Color(0xFFCC6600));
      expect(
        trigger(tester).extraShadows!.single.color,
        const Color(0xFFCC6600).withValues(alpha: 0.35),
      );
    });

    testWidgets('every component-theme field changes the rendered select', (
      tester,
    ) async {
      await pumpSelect(
        tester,
        allowClear: true,
        theme: themed(
          AnimalSelectStyle(
            textStyle: const TextStyle(fontSize: 19),
            textColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFFAA0000)
                  : null,
            ),
            backgroundColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF102030),
            ),
            borderColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? const Color(0xFF00AA00)
                  : const Color(0xFF0000AA),
            ),
            glowColor: const WidgetStatePropertyAll<Color>(Color(0xFF445566)),
            borderWidth: 3.5,
            borderRadius: const BorderRadius.all(Radius.circular(7)),
            horizontalPadding: 23,
            arrowIconSize: 27,
            arrowIconColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF0A0B0C),
            ),
            clearIconSize: 21,
            clearIconColor: const Color(0xFF0C0B0A),
            menuBackgroundColor: const Color(0xFF223344),
            menuBorderColor: const Color(0xFF332211),
            menuBorderWidth: 2.75,
            menuBorderRadius: const BorderRadius.all(Radius.circular(3)),
            menuElevation: 9,
            menuVerticalPadding: 11,
            menuMaxWidth: 150,
            menuMaxHeight: 250,
            optionTextStyle: const TextStyle(letterSpacing: 2),
            selectedOptionTextStyle: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
            optionTextColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF00CC00)
                  : const Color(0xFFCC00CC),
            ),
            optionBackgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF111111)
                  : const Color(0xFF222222),
            ),
            optionBorderRadius: const BorderRadius.all(Radius.circular(9)),
            optionPadding: const EdgeInsets.fromLTRB(5, 50, 6, 50),
            optionIconGap: 31,
            checkIconGap: 33,
            checkIconSize: 25,
            checkIconColor: const Color(0xFF5A5A5A),
          ),
        ),
      );

      InteractiveRegion t = trigger(tester);
      expect(t.surfaceColor, const Color(0xFF102030));
      expect(t.border!.top.color, const Color(0xFF0000AA));
      expect(t.border!.top.width, 3.5);
      expect(t.borderRadius, const BorderRadius.all(Radius.circular(7)));
      expect(t.padding, const EdgeInsets.symmetric(horizontal: 23));
      expect(t.extraShadows, isNull);
      final Text label = triggerText(tester);
      expect(label.style!.fontSize, 19);
      expect(label.style!.color, const Color(0xFFAA0000));
      final Icon arrow = tester.widget(
        find.byIcon(Icons.keyboard_arrow_down_rounded),
      );
      expect(arrow.size, 27);
      expect(arrow.color, const Color(0xFF0A0B0C));
      final AnimalIcon clear = icon(tester, AnimalIcons.close);
      expect(clear.size, 21);
      expect(clear.color, const Color(0xFF0C0B0A));

      await openMenu(tester);
      t = trigger(tester);
      expect(t.border!.top.color, const Color(0xFF00AA00));
      expect(t.extraShadows!.single.color, const Color(0xFF445566));

      final MenuStyle menu = menuStyle(tester);
      expect(
        menu.backgroundColor!.resolve(<WidgetState>{}),
        const Color(0xFF223344),
      );
      expect(menu.elevation!.resolve(<WidgetState>{}), 9);
      expect(
        menu.padding!.resolve(<WidgetState>{}),
        const EdgeInsets.symmetric(vertical: 11),
      );
      final RoundedRectangleBorder shape =
          menu.shape!.resolve(<WidgetState>{})! as RoundedRectangleBorder;
      expect(shape.borderRadius, const BorderRadius.all(Radius.circular(3)));
      expect(shape.side.color, const Color(0xFF332211));
      expect(shape.side.width, 2.75);
      expect(menuBox(tester).width, 150);
      expect(menuBox(tester).height, 250);
      // Rows grow with the vertical option padding (50 + 50).
      expect(
        tester.widget<ListView>(find.byType(ListView)).itemExtent,
        greaterThan(100),
      );

      final InteractiveRegion selected = option(tester, 'Alpha');
      expect(selected.surfaceColor, const Color(0xFF111111));
      expect(selected.borderRadius, const BorderRadius.all(Radius.circular(9)));
      expect(selected.padding, const EdgeInsets.fromLTRB(5, 50, 6, 50));
      final Text selectedText = optionText(tester, 'Alpha');
      expect(selectedText.style!.color, const Color(0xFF00CC00));
      expect(selectedText.style!.fontStyle, FontStyle.italic);
      expect(selectedText.style!.letterSpacing, 2);
      expect(
        find.descendant(
          of: find.byWidget(selected),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 31,
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byWidget(selected),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == 33,
          ),
        ),
        findsOneWidget,
      );
      final AnimalIcon check = icon(tester, AnimalIcons.check);
      expect(check.size, 25);
      expect(check.color, const Color(0xFF5A5A5A));

      final InteractiveRegion other = option(tester, 'Beta');
      expect(other.surfaceColor, const Color(0xFF222222));
      final Text otherText = optionText(tester, 'Beta');
      expect(otherText.style!.color, const Color(0xFFCC00CC));
      expect(otherText.style!.letterSpacing, 2);
      expect(otherText.style!.fontStyle, isNot(FontStyle.italic));
    });

    testWidgets('error state resolves through the state properties', (
      tester,
    ) async {
      await pumpSelect(
        tester,
        status: AnimalInputStatus.error,
        theme: themed(
          AnimalSelectStyle(
            borderColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.error)
                  ? const Color(0xFFDD2200)
                  : null,
            ),
            glowColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.error)
                  ? const Color(0xFF660011)
                  : null,
            ),
          ),
        ),
      );
      expect(trigger(tester).border!.top.color, const Color(0xFFDD2200));
      expect(
        trigger(tester).extraShadows!.single.color,
        const Color(0xFF660011),
      );
    });

    testWidgets('the focus ring color themes the open border and glow', (
      tester,
    ) async {
      await pumpSelect(
        tester,
        theme: AnimalIslandTheme.light.copyWith(
          components: AnimalComponentThemes(
            focusRing: AnimalFocusRingStyle(color: const Color(0xFF7700CC)),
          ),
        ),
      );
      await openMenu(tester);
      expect(trigger(tester).border!.top.color, const Color(0xFF7700CC));
      final BoxShadow glow = trigger(tester).extraShadows!.single;
      expect(glow.color, const Color(0xFF7700CC).withValues(alpha: 0.45));
      expect(glow.blurRadius, 4);
      expect(glow.spreadRadius, 2);
      // Default menu width cap in an 800-wide test viewport.
      expect(menuBox(tester).width, 320);
    });

    testWidgets('option rows keep the 48 logical-pixel floor', (tester) async {
      await pumpSelect(
        tester,
        style: AnimalSelectStyle(
          optionTextStyle: const TextStyle(fontSize: 6),
          optionPadding: EdgeInsets.zero,
        ),
      );
      await openMenu(tester);
      expect(tester.widget<ListView>(find.byType(ListView)).itemExtent, 48);
      expect(menuBox(tester).height, 144);
    });

    testWidgets('the menu opens at 200% text scale in a 320-wide viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2)),
              child: Scaffold(
                body: AnimalSelect<String>(
                  key: const ValueKey<String>('select'),
                  value: 'a',
                  options: const <AnimalOption<String>>[
                    AnimalOption<String>(
                      value: 'a',
                      label: 'A long first option label that has to wrap',
                    ),
                    AnimalOption<String>(value: 'b', label: 'Second option'),
                  ],
                  onChanged: (_) {},
                  allowClear: true,
                ),
              ),
            ),
          ),
        ),
      );
      await openMenu(tester);
      expect(tester.takeException(), isNull);
      expect(find.byType(ListView), findsOneWidget);
      expect(menuBox(tester).width, lessThanOrEqualTo(296));
    });
  });

  group('API06 AnimalSelect precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = themed(
        AnimalSelectStyle(borderWidth: 2.5, menuMaxHeight: 70),
      );

      // Token default: the light preset's trigger border and menu cap.
      await pumpSelect(tester);
      expect(trigger(tester).border!.top.width, 1.8);
      expect(triggerText(tester).style!.fontSize, closeTo(15, 1e-9));

      // The theme style replaces the defaults.
      await pumpSelect(tester, theme: theme);
      expect(trigger(tester).border!.top.width, 2.5);

      // The instance style wins over the theme and keeps its other fields.
      await pumpSelect(
        tester,
        theme: theme,
        style: AnimalSelectStyle(borderWidth: 3.5),
      );
      expect(trigger(tester).border!.top.width, 3.5);
      await openMenu(tester);
      expect(menuBox(tester).height, 70);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpSelect(
        tester,
        theme: themed(
          AnimalSelectStyle(textStyle: const TextStyle(letterSpacing: 1.25)),
        ),
        style: AnimalSelectStyle(
          textStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      final TextStyle style = triggerText(tester).style!;
      expect(style.fontWeight, FontWeight.w900);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, closeTo(15, 1e-9));
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalSelect boundary', () {
    test('styles reject values the select cannot render', () {
      expect(() => AnimalSelectStyle(borderWidth: -1), throwsArgumentError);
      expect(
        () => AnimalSelectStyle(menuMaxHeight: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalSelectStyle(textStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
      expect(
        () => AnimalSelectStyle(optionPadding: const EdgeInsets.only(top: -2)),
        throwsArgumentError,
      );
      expect(
        () => AnimalSelectStyle(
          optionPadding: const EdgeInsetsDirectional.only(start: -1),
        ),
        throwsArgumentError,
      );
      expect(
        () => AnimalSelectStyle(
          optionPadding: const EdgeInsetsDirectional.only(end: double.nan),
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(AnimalSelectStyle(menuMaxHeight: 200));
      final AnimalIslandTheme b = themed(AnimalSelectStyle(menuMaxHeight: 300));
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(
        a.lerp(b, 0.5).components.select!.menuMaxHeight,
        closeTo(250, 1e-9),
      );
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer",
      // so they switch at the midpoint instead of blending from 0 or
      // transparent.
      final AnimalIslandTheme a = themed(
        AnimalSelectStyle(
          menuMaxHeight: 200,
          menuBackgroundColor: const Color(0xFF123456),
          optionPadding: const EdgeInsetsDirectional.only(start: 7),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      final AnimalSelectStyle earlySelect = early.components.select!;
      expect(earlySelect.menuMaxHeight, 200);
      expect(earlySelect.menuBackgroundColor, const Color(0xFF123456));
      expect(
        earlySelect.optionPadding,
        const EdgeInsetsDirectional.only(start: 7),
      );
      expect(late.components.select?.menuMaxHeight, isNull);
      expect(late.components.select?.menuBackgroundColor, isNull);
      expect(late.components.select?.optionPadding, isNull);
    });
  });
}
