// API06 efficacy and precedence oracles for AnimalDrawer.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _red = Color(0xFFE53935);
const Color _blue = Color(0xFF1E88E5);
const Color _green = Color(0xFF43A047);
const BoxShadow _shadow = BoxShadow(color: _blue, blurRadius: 7);

AnimalIslandTheme _themed(AnimalDrawerStyle drawer) => AnimalIslandTheme.light
    .copyWith(components: AnimalComponentThemes(drawer: drawer));

Future<void> _pumpDrawer(
  WidgetTester tester, {
  AnimalIslandTheme? theme,
  AnimalDrawerStyle? style,
  AnimalDrawerPlacement placement = AnimalDrawerPlacement.right,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
      home: Scaffold(
        body: AnimalDrawer(
          title: const Text('Title'),
          footer: const Text('Footer'),
          onClose: () {},
          placement: placement,
          style: style,
          child: const Text('Body'),
        ),
      ),
    ),
  );
  // MaterialApp animates theme changes; settle on the new theme.
  await tester.pumpAndSettle();
}

BoxDecoration _sheet(WidgetTester tester) =>
    tester
            .widget<Container>(
              find
                  .descendant(
                    of: find.byType(AnimalDrawer),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration!
        as BoxDecoration;

EdgeInsetsGeometry _paddingAround(WidgetTester tester, Finder child) => tester
    .widget<Padding>(
      find.ancestor(of: child, matching: find.byType(Padding)).first,
    )
    .padding;

/// The fill of the close action: the innermost animated container of its
/// activation region, which carries the padding, radius and fill color.
AnimatedContainer _close(WidgetTester tester) => tester
    .widgetList<AnimatedContainer>(
      find.descendant(
        of: find.descendant(
          of: find.byType(AnimalDrawer),
          matching: find.byType(InteractiveRegion),
        ),
        matching: find.byType(AnimatedContainer),
      ),
    )
    .last;

BoxDecoration _closeFill(WidgetTester tester) =>
    _close(tester).decoration! as BoxDecoration;

AnimalIcon _closeIcon(WidgetTester tester) => tester.widget(
  find.descendant(
    of: find.byType(AnimalDrawer),
    matching: find.byType(AnimalIcon),
  ),
);

void main() {
  group('API06 AnimalDrawer efficacy', () {
    testWidgets('token change reaches every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      final AnimalIslandTheme theme = light.copyWith(
        typography: light.typography.copyWith(
          title: light.typography.title.copyWith(fontSize: 40),
        ),
        radii: light.radii.copyWith(card: 10),
        spacing: AnimalThemeSpacing(
          xxs: 2,
          xs: 4,
          sm: 8,
          md: 10,
          lg: 20,
          xl: 30,
          xxl: 40,
        ),
      );
      await _pumpDrawer(tester, theme: theme);

      expect(
        DefaultTextStyle.of(tester.element(find.text('Title'))).style.fontSize,
        30,
      );
      expect(
        _sheet(tester).borderRadius,
        const BorderRadius.horizontal(left: Radius.circular(12)),
      );
      expect(
        _paddingAround(tester, find.text('Body')),
        const EdgeInsets.all(24),
      );
      expect(
        _paddingAround(tester, find.text('Footer')),
        const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      );
      expect(_close(tester).padding, const EdgeInsets.all(6));
    });

    testWidgets('every style field changes the rendered drawer', (
      tester,
    ) async {
      await _pumpDrawer(
        tester,
        style: AnimalDrawerStyle(
          backgroundColor: _red,
          borderColor: _blue,
          borderWidth: 5,
          borderRadius: const BorderRadius.all(Radius.circular(3)),
          shadow: _shadow,
          titleTextStyle: const TextStyle(fontSize: 31),
          titleTextColor: _green,
          headerPadding: const EdgeInsets.all(7),
          bodyPadding: const EdgeInsets.all(9),
          footerPadding: const EdgeInsets.all(13),
          dividerColor: _green,
          dividerThickness: 3,
          closeIconColor: _red,
          closeIconSize: 21,
          closeButtonPadding: const EdgeInsets.all(2),
          closeButtonBorderRadius: const BorderRadius.all(Radius.circular(5)),
          closeButtonBackgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered) ? _red : _blue,
          ),
        ),
      );

      final BoxDecoration sheet = _sheet(tester);
      expect(sheet.color, _red);
      expect(sheet.border, Border.all(color: _blue, width: 5));
      expect(sheet.borderRadius, const BorderRadius.all(Radius.circular(3)));
      expect(sheet.boxShadow, const <BoxShadow>[_shadow]);
      final TextStyle title = DefaultTextStyle.of(
        tester.element(find.text('Title')),
      ).style;
      expect(title.fontSize, 31);
      expect(title.color, _green);
      expect(
        _paddingAround(tester, find.byType(InteractiveRegion)),
        const EdgeInsets.all(7),
      );
      expect(
        _paddingAround(tester, find.text('Body')),
        const EdgeInsets.all(9),
      );
      expect(
        _paddingAround(tester, find.text('Footer')),
        const EdgeInsets.all(13),
      );
      final Iterable<Divider> dividers = tester.widgetList<Divider>(
        find.byType(Divider),
      );
      expect(dividers, hasLength(2));
      for (final Divider divider in dividers) {
        expect(divider.color, _green);
        expect(divider.thickness, 3);
        expect(divider.height, 3);
      }
      expect(_closeIcon(tester).color, _red);
      expect(_closeIcon(tester).size, 21);
      expect(_close(tester).padding, const EdgeInsets.all(2));
      expect(
        _closeFill(tester).borderRadius,
        const BorderRadius.all(Radius.circular(5)),
      );
      expect(_closeFill(tester).color, _blue);
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byWidget(_closeIcon(tester))));
      await tester.pumpAndSettle();
      expect(_closeFill(tester).color, _red);
    });

    testWidgets('the barrier color is themed on the route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => AnimalDrawer.show<void>(
                  context: context,
                  style: AnimalDrawerStyle(barrierColor: _green),
                  builder: (context, close) => const Text('Body'),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(
        ModalRoute.of(tester.element(find.text('Body')))!.barrierColor,
        _green,
      );
    });
  });

  group('API06 AnimalDrawer precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = _themed(
        AnimalDrawerStyle(backgroundColor: _blue, borderWidth: 4),
      );
      await _pumpDrawer(tester);
      expect(_sheet(tester).color, AnimalIslandTheme.light.colors.bgContent);
      expect(_sheet(tester).border!.top.width, 1.5);

      await _pumpDrawer(tester, theme: theme);
      expect(_sheet(tester).color, _blue);
      expect(_sheet(tester).border!.top.width, 4);

      await _pumpDrawer(
        tester,
        theme: theme,
        style: AnimalDrawerStyle(backgroundColor: _red),
      );
      expect(_sheet(tester).color, _red);
      expect(_sheet(tester).border!.top.width, 4);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await _pumpDrawer(
        tester,
        theme: _themed(
          AnimalDrawerStyle(titleTextStyle: const TextStyle(letterSpacing: 3)),
        ),
        style: AnimalDrawerStyle(titleTextStyle: const TextStyle(fontSize: 26)),
      );
      final TextStyle title = DefaultTextStyle.of(
        tester.element(find.text('Title')),
      ).style;
      expect(title.fontSize, 26);
      expect(title.letterSpacing, 3);
      expect(title.fontWeight, FontWeight.w800);
    });

    testWidgets('the default corner radius faces into the screen', (
      tester,
    ) async {
      for (final (AnimalDrawerPlacement placement, BorderRadius expected)
          in <(AnimalDrawerPlacement, BorderRadius)>[
            (
              AnimalDrawerPlacement.left,
              const BorderRadius.horizontal(right: Radius.circular(24)),
            ),
            (
              AnimalDrawerPlacement.right,
              const BorderRadius.horizontal(left: Radius.circular(24)),
            ),
            (
              AnimalDrawerPlacement.top,
              const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            (
              AnimalDrawerPlacement.bottom,
              const BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ]) {
        await _pumpDrawer(tester, placement: placement);
        expect(_sheet(tester).borderRadius, expected, reason: placement.name);
      }
    });
  });

  group('API06 AnimalDrawer boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalDrawerStyle(borderWidth: -1), throwsArgumentError);
      expect(
        () => AnimalDrawerStyle(dividerThickness: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalDrawerStyle(titleTextStyle: const TextStyle(fontSize: -2)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = _themed(AnimalDrawerStyle(borderWidth: 2));
      final AnimalIslandTheme b = _themed(AnimalDrawerStyle(borderWidth: 6));
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(b, 0.5).components.drawer!.borderWidth, closeTo(4, 1e-9));
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalIslandTheme a = _themed(
        AnimalDrawerStyle(borderWidth: 6, backgroundColor: _red),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.drawer!.borderWidth, 6);
      expect(early.components.drawer!.backgroundColor, _red);
      expect(late.components.drawer?.borderWidth, isNull);
      expect(late.components.drawer?.backgroundColor, isNull);
    });
  });
}
