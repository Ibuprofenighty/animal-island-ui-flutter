// API06 efficacy and precedence oracles for AnimalModal.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'dart:ui' show ImageFilter;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/modal/modal_surface.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const Color _red = Color(0xFFE53935);
const Color _blue = Color(0xFF1E88E5);
const Color _green = Color(0xFF43A047);
const BoxShadow _shadow = BoxShadow(color: _blue, blurRadius: 7);

AnimalIslandTheme _themed(AnimalModalStyle modal) => AnimalIslandTheme.light
    .copyWith(components: AnimalComponentThemes(modal: modal));

Future<void> _pumpModal(
  WidgetTester tester, {
  AnimalIslandTheme? theme,
  AnimalModalStyle? style,
  double width = 500,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
      home: Scaffold(
        body: Center(
          child: AnimalModal(
            title: const Text('Title'),
            content: const Text('Body'),
            footer: const Text('Footer'),
            onClose: () {},
            width: width,
            style: style,
          ),
        ),
      ),
    ),
  );
  // MaterialApp animates theme changes; settle on the new theme.
  await tester.pumpAndSettle();
}

/// Pumps an opener and shows a route modal from it.
Future<void> _pumpRoute(
  WidgetTester tester, {
  required void Function(BuildContext context) open,
  AnimalIslandTheme? theme,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('Open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

BlobModalPainter _painter(WidgetTester tester) =>
    tester
            .widgetList<CustomPaint>(
              find.descendant(
                of: find.byType(AnimalModalSurface),
                matching: find.byType(CustomPaint),
              ),
            )
            .firstWhere((paint) => paint.painter is BlobModalPainter)
            .painter!
        as BlobModalPainter;

AnimalModalSurface _surface(WidgetTester tester) =>
    tester.widget(find.byType(AnimalModalSurface));

TextStyle _textStyleOf(WidgetTester tester, String text) =>
    DefaultTextStyle.of(tester.element(find.text(text))).style;

Iterable<double?> _gapHeights(WidgetTester tester) => tester
    .widgetList<SizedBox>(
      find.descendant(
        of: find.byType(AnimalModal),
        matching: find.byType(SizedBox),
      ),
    )
    .map((box) => box.height);

AnimatedContainer _closeSurface(WidgetTester tester) => tester.widget(
  find
      .ancestor(
        of: find.byType(AnimalIcon),
        matching: find.byType(AnimatedContainer),
      )
      .first,
);

AnimalIcon _closeIcon(WidgetTester tester) => tester.widget(
  find.descendant(
    of: find.byType(AnimalModal),
    matching: find.byType(AnimalIcon),
  ),
);

void main() {
  group('API06 AnimalModal efficacy', () {
    testWidgets('token change reaches every derived default', (tester) async {
      final AnimalIslandTheme light = AnimalIslandTheme.light;
      final AnimalIslandTheme theme = light.copyWith(
        typography: light.typography.copyWith(
          title: light.typography.title.copyWith(fontSize: 40),
          body: light.typography.body.copyWith(fontSize: 28),
        ),
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
      await _pumpModal(tester, theme: theme);

      expect(_textStyleOf(tester, 'Title').fontSize, 30);
      expect(_textStyleOf(tester, 'Body').fontSize, 30);
      expect(
        _surface(tester).padding,
        const EdgeInsets.symmetric(horizontal: 44, vertical: 40),
      );
      // headerGap lg + xxs, footerGap xl + xs.
      expect(_gapHeights(tester), containsAll(<double>[22, 34]));
      expect(_closeSurface(tester).padding, const EdgeInsets.all(6));
    });

    testWidgets('every surface style field changes the rendered modal', (
      tester,
    ) async {
      await _pumpModal(
        tester,
        width: 900,
        style: AnimalModalStyle(
          backgroundColor: _red,
          borderColor: _blue,
          borderWidth: 5,
          shadow: _shadow,
          padding: const EdgeInsets.all(11),
          horizontalMargin: 50,
          titleTextStyle: const TextStyle(fontSize: 31),
          titleTextColor: _green,
          textStyle: const TextStyle(fontSize: 17),
          textColor: _blue,
          headerGap: 13,
          footerGap: 19,
          closeIconColor: _red,
          closeIconSize: 21,
          closeButtonPadding: const EdgeInsets.all(3),
          closeButtonBorderRadius: const BorderRadius.all(Radius.circular(6)),
          closeButtonBackgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.hovered) ? _red : _green,
          ),
        ),
      );

      final BlobModalPainter painter = _painter(tester);
      expect(painter.fillColor, _red);
      expect(painter.borderColor, _blue);
      expect(painter.borderWidth, 5);
      expect(_surface(tester).shadows, const <BoxShadow>[_shadow]);
      expect(_surface(tester).padding, const EdgeInsets.all(11));
      // The test surface is 800 logical pixels wide.
      expect(tester.getSize(find.byType(AnimalModalSurface)).width, 700);
      expect(_textStyleOf(tester, 'Title').fontSize, 31);
      expect(_textStyleOf(tester, 'Title').color, _green);
      expect(_textStyleOf(tester, 'Body').fontSize, 17);
      expect(_textStyleOf(tester, 'Body').color, _blue);
      expect(_gapHeights(tester), containsAll(<double>[13, 19]));
      expect(_closeIcon(tester).color, _red);
      expect(_closeIcon(tester).size, 21);
      expect(_closeSurface(tester).padding, const EdgeInsets.all(3));
      expect(
        (_closeSurface(tester).decoration! as BoxDecoration).color,
        _green,
      );
      expect(
        (_closeSurface(tester).decoration! as BoxDecoration).borderRadius,
        const BorderRadius.all(Radius.circular(6)),
      );
      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.byWidget(_closeIcon(tester))));
      await tester.pumpAndSettle();
      expect((_closeSurface(tester).decoration! as BoxDecoration).color, _red);
    });

    testWidgets('every route style field changes the rendered modal', (
      tester,
    ) async {
      final AnimalModalStyle style = AnimalModalStyle(
        errorTextStyle: const TextStyle(fontSize: 23),
        errorTextColor: _green,
        errorGap: 17,
        actionGap: 27,
        avatarGap: 29,
        barrierColor: _red,
        barrierBlurSigma: 9,
      );
      await _pumpRoute(
        tester,
        open: (context) => AnimalModal.confirm(
          context: context,
          content: const Text('Body'),
          style: style,
          onConfirm: () => throw StateError('Nope'),
        ),
      );
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      final Text error = tester.widget(find.text('Bad state: Nope'));
      expect(error.style!.fontSize, 23);
      expect(error.style!.color, _green);
      expect(_gapHeights(tester), contains(17));
      expect(
        tester
            .widget<Wrap>(
              find.ancestor(
                of: find.byType(AnimalButton).first,
                matching: find.byType(Wrap),
              ),
            )
            .spacing,
        27,
      );
      final ModalRoute<Object?> route = ModalRoute.of(
        tester.element(find.text('Body')),
      )!;
      expect(route.barrierColor, _red);
      expect(
        tester.widget<BackdropFilter>(find.byType(BackdropFilter)).filter,
        ImageFilter.blur(sigmaX: 9, sigmaY: 9),
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await _pumpRoute(
        tester,
        open: (context) => AnimalModal.showDialogue(
          context: context,
          avatar: const Icon(Icons.person),
          dialogue: 'Hello',
          style: style,
        ),
      );
      final Iterable<double?> widths = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(AnimalModal),
              matching: find.byType(SizedBox),
            ),
          )
          .map((box) => box.width);
      expect(widths, contains(29));
    });
  });

  group('API06 AnimalModal precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      final AnimalIslandTheme theme = _themed(
        AnimalModalStyle(backgroundColor: _blue, borderWidth: 4),
      );
      await _pumpModal(tester);
      expect(
        _painter(tester).fillColor,
        AnimalIslandTheme.light.colors.bgContent,
      );
      expect(_painter(tester).borderWidth, 2);

      await _pumpModal(tester, theme: theme);
      expect(_painter(tester).fillColor, _blue);
      expect(_painter(tester).borderWidth, 4);

      await _pumpModal(
        tester,
        theme: theme,
        style: AnimalModalStyle(backgroundColor: _red),
      );
      expect(_painter(tester).fillColor, _red);
      expect(_painter(tester).borderWidth, 4);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await _pumpModal(
        tester,
        theme: _themed(
          AnimalModalStyle(titleTextStyle: const TextStyle(letterSpacing: 3)),
        ),
        style: AnimalModalStyle(titleTextStyle: const TextStyle(fontSize: 26)),
      );
      final TextStyle title = _textStyleOf(tester, 'Title');
      expect(title.fontSize, 26);
      expect(title.letterSpacing, 3);
      expect(title.fontWeight, FontWeight.w800);
    });
  });

  group('API06 AnimalModal boundary', () {
    test('styles reject values components cannot render', () {
      expect(
        () => AnimalModalStyle(padding: const EdgeInsets.only(left: -1)),
        throwsArgumentError,
      );
      expect(
        () => AnimalModalStyle(
          closeButtonBorderRadius: const BorderRadius.all(Radius.circular(-2)),
        ),
        throwsArgumentError,
      );
      expect(() => AnimalModalStyle(borderWidth: -1), throwsArgumentError);
      expect(
        () => AnimalModalStyle(headerGap: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalModalStyle(barrierBlurSigma: -0.5),
        throwsArgumentError,
      );
      expect(
        () => AnimalModalStyle(textStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = _themed(AnimalModalStyle(borderWidth: 2));
      final AnimalIslandTheme b = _themed(AnimalModalStyle(borderWidth: 6));
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(a.lerp(b, 0.5).components.modal!.borderWidth, closeTo(4, 1e-9));
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalIslandTheme a = _themed(
        AnimalModalStyle(borderWidth: 6, backgroundColor: _red),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.modal!.borderWidth, 6);
      expect(early.components.modal!.backgroundColor, _red);
      expect(late.components.modal?.borderWidth, isNull);
      expect(late.components.modal?.backgroundColor, isNull);
    });
  });
}
