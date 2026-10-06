// API06 efficacy and precedence oracles for AnimalSwitch.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property.
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const ValueKey<String> _boundaryKey = ValueKey<String>('boundary');

void main() {
  Future<void> pumpSwitch(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalSwitchStyle? style,
    AnimalSwitchSize size = AnimalSwitchSize.defaultSize,
    bool value = true,
    bool disabled = false,
    bool loading = false,
    bool labels = true,
    String checkedLabel = 'ON',
    FocusNode? focusNode,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        // A new theme mounts a new tree, so no theme or decoration
        // transition is in flight when the switch is inspected.
        key: ObjectKey(theme),
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: _boundaryKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: AnimalSwitch(
                  value: value,
                  onChanged: (_) {},
                  size: size,
                  style: style,
                  disabled: disabled,
                  loading: loading,
                  focusNode: focusNode,
                  checkedChildren: labels ? Text(checkedLabel) : null,
                  unCheckedChildren: labels ? const Text('OFF') : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
  }

  Finder trackFinder() => find
      .descendant(
        of: find.byType(AnimalSwitch),
        matching: find.byType(AnimatedContainer),
      )
      .last;
  BoxDecoration track(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(trackFinder()).decoration!
          as BoxDecoration;
  Finder thumbFinder() => find.descendant(
    of: find.byType(AnimalSwitch),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).shape == BoxShape.circle,
    ),
  );
  BoxDecoration thumb(WidgetTester tester) =>
      tester.widget<Container>(thumbFinder()).decoration! as BoxDecoration;
  BoxDecoration? focusOutline(WidgetTester tester) =>
      tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byType(AnimalSwitch),
                  matching: find.byType(Container),
                ),
              )
              .firstWhere((container) => container.foregroundDecoration != null)
              .foregroundDecoration
          as BoxDecoration?;
  TextStyle label(WidgetTester tester, String text) => tester
      .widget<DefaultTextStyle>(
        find
            .ancestor(
              of: find.text(text),
              matching: find.byType(DefaultTextStyle),
            )
            .first,
      )
      .style;

  AnimalIslandTheme themed(AnimalSwitchThemeData data) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(switchControl: data));

  group('API06 AnimalSwitch efficacy', () {
    testWidgets('token change reaches every size preset', (tester) async {
      final AnimalIslandTheme theme = AnimalIslandTheme.light.copyWith(
        typography: AnimalIslandTheme.light.typography.copyWith(
          body: AnimalIslandTheme.light.typography.body.copyWith(fontSize: 28),
        ),
      );
      for (final (AnimalSwitchSize size, double expected)
          in <(AnimalSwitchSize, double)>[
            (AnimalSwitchSize.small, 22),
            (AnimalSwitchSize.defaultSize, 26),
          ]) {
        await pumpSwitch(tester, theme: theme, size: size);
        expect(label(tester, 'ON').fontSize, closeTo(expected, 1e-9));
        expect(label(tester, 'OFF').fontSize, closeTo(expected, 1e-9));
        expect(label(tester, 'ON').fontWeight, FontWeight.bold);
      }
    });

    testWidgets('every component-theme field changes the rendered switch', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final AnimalIslandTheme theme = themed(
        AnimalSwitchThemeData(
          style: AnimalSwitchStyle(
            width: 90,
            height: 40,
            thumbSize: 30,
            trackBorderWidth: 3,
            thumbBorderWidth: 2.5,
            focusBorderWidth: 4,
            loadingStrokeWidth: 5,
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            labelTextStyle: const TextStyle(
              fontSize: 9,
              fontStyle: FontStyle.italic,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? const Color(0xFF000001)
                  : states.contains(WidgetState.selected)
                  ? const Color(0xFF000002)
                  : const Color(0xFF000003),
            ),
            trackBorderColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF000004),
            ),
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.disabled)
                  ? const Color(0xFF000005)
                  : const Color(0xFF000006),
            ),
            thumbBorderColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF000007),
            ),
            labelTextColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? const Color(0xFF000008)
                  : const Color(0xFF000009),
            ),
            loadingIndicatorColor: const WidgetStatePropertyAll<Color>(
              Color(0xFF00000A),
            ),
          ),
        ),
      );

      await pumpSwitch(tester, theme: theme, focusNode: focusNode);
      // Minimum 90×40 content plus the 3 logical-pixel border on each side.
      final Rect trackRect = tester.getRect(trackFinder());
      expect(trackRect.size, const Size(96, 46));
      final Rect thumbRect = tester.getRect(thumbFinder());
      expect(thumbRect.size, const Size(30, 30));
      // Checked LTR thumb sits at the right end: border 3 + inset (40-30)/2.
      expect(trackRect.right - thumbRect.right, closeTo(8, 1e-9));
      final BoxDecoration t = track(tester);
      expect(t.color, const Color(0xFF000002));
      expect(t.border!.top.color, const Color(0xFF000004));
      expect(t.border!.top.width, 3);
      expect(t.borderRadius, const BorderRadius.all(Radius.circular(6)));
      final BoxDecoration th = thumb(tester);
      expect(th.color, const Color(0xFF000006));
      expect(th.border!.top.color, const Color(0xFF000007));
      expect(th.border!.top.width, 2.5);
      expect(label(tester, 'ON').fontSize, 9);
      expect(label(tester, 'ON').fontStyle, FontStyle.italic);
      expect(label(tester, 'ON').color, const Color(0xFF000008));
      expect(label(tester, 'OFF').color, const Color(0xFF000009));

      focusNode.requestFocus();
      await tester.pump(const Duration(seconds: 1));
      final BoxDecoration outline = focusOutline(tester)!;
      expect(outline.border!.top.width, 4);
      expect(outline.borderRadius, const BorderRadius.all(Radius.circular(6)));

      await pumpSwitch(tester, theme: theme, value: false, disabled: true);
      expect(track(tester).color, const Color(0xFF000001));
      expect(thumb(tester).color, const Color(0xFF000005));

      await pumpSwitch(tester, theme: theme, value: false);
      expect(track(tester).color, const Color(0xFF000003));

      await pumpSwitch(tester, theme: theme, loading: true);
      final CircularProgressIndicator indicator = tester.widget(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.strokeWidth, 5);
      expect(indicator.valueColor!.value, const Color(0xFF00000A));
      // The indicator diameter is 0.6 of the 30 logical-pixel thumb.
      expect(
        tester.getSize(find.byType(CircularProgressIndicator)),
        const Size(18, 18),
      );
    });

    testWidgets('the label gap widens a label-sized track', (tester) async {
      const String wide = 'Island bulletin on';
      await pumpSwitch(tester, checkedLabel: wide);
      final double defaultWidth = tester.getSize(trackFinder()).width;
      await pumpSwitch(
        tester,
        checkedLabel: wide,
        theme: themed(
          AnimalSwitchThemeData(style: AnimalSwitchStyle(labelGap: 20)),
        ),
      );
      // The default gap is 4; the label-sized track grows by the difference.
      expect(
        tester.getSize(trackFinder()).width - defaultWidth,
        closeTo(16, 1e-9),
      );
    });

    testWidgets('the track inset shadow is themed', (tester) async {
      Future<(Color edge, Color center)> samplePixels() async {
        final Rect trackRect = tester.getRect(trackFinder());
        final Rect boundaryRect = tester.getRect(find.byKey(_boundaryKey));
        final RenderRepaintBoundary boundary = tester.renderObject(
          find.byKey(_boundaryKey),
        ) as RenderRepaintBoundary;
        final ui.Image image = (await tester.runAsync(
          () => boundary.toImage(pixelRatio: 1),
        ))!;
        try {
          final ByteData pixels = (await tester.runAsync<ByteData>(
            () async =>
                (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!,
          ))!;
          Color pixelAt(int x, int y) {
            final int offset = (y * image.width + x) * 4;
            return Color.fromARGB(
              pixels.getUint8(offset + 3),
              pixels.getUint8(offset),
              pixels.getUint8(offset + 1),
              pixels.getUint8(offset + 2),
            );
          }

          final int x =
              (trackRect.right - trackRect.height / 2 - boundaryRect.left)
                  .round();
          return (
            pixelAt(x, (trackRect.top + 2 - boundaryRect.top).round()),
            pixelAt(x, (trackRect.center.dy - boundaryRect.top).round()),
          );
        } finally {
          image.dispose();
        }
      }

      await pumpSwitch(tester, value: false, labels: false);
      final (Color defaultEdge, _) = await samplePixels();

      await pumpSwitch(
        tester,
        value: false,
        labels: false,
        theme: themed(
          AnimalSwitchThemeData(
            style: AnimalSwitchStyle(
              trackInsetShadow: const BoxShadow(
                color: Color(0xFF0022FF),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ),
          ),
        ),
      );
      final (Color edge, Color center) = await samplePixels();
      expect(edge, isNot(defaultEdge));
      expect(edge.b, greaterThan(center.b));
      expect(edge.r, lessThan(center.r));
      expect(center, AnimalIslandTheme.light.colors.bgSecondary);
    });

    testWidgets('the focus ring color themes the focus outline', (
      tester,
    ) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      await pumpSwitch(
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
      expect(focusOutline(tester)!.border!.top.color, const Color(0xFF7700CC));
    });
  });

  group('API06 AnimalSwitch precedence', () {
    testWidgets('instance > size theme > general theme > token default', (
      tester,
    ) async {
      final AnimalIslandTheme theme = themed(
        AnimalSwitchThemeData(
          style: AnimalSwitchStyle(width: 70, thumbBorderWidth: 2.5),
          defaultSizeStyle: AnimalSwitchStyle(width: 80),
        ),
      );

      // Token default: the light preset's 58 logical-pixel minimum plus the
      // 1.5 logical-pixel track border on each side.
      await pumpSwitch(tester, labels: false);
      expect(tester.getSize(trackFinder()).width, 61);
      expect(thumb(tester).border!.top.width, 1.2);

      // The general theme style applies to sizes without their own style.
      await pumpSwitch(
        tester,
        theme: theme,
        labels: false,
        size: AnimalSwitchSize.small,
      );
      expect(tester.getSize(trackFinder()).width, 73);
      expect(thumb(tester).border!.top.width, 2.5);

      // The size-specific style wins over the general style.
      await pumpSwitch(tester, theme: theme, labels: false);
      expect(tester.getSize(trackFinder()).width, 83);
      expect(thumb(tester).border!.top.width, 2.5);

      // The instance style wins over both theme layers.
      await pumpSwitch(
        tester,
        theme: theme,
        labels: false,
        style: AnimalSwitchStyle(width: 100),
      );
      expect(tester.getSize(trackFinder()).width, 103);
      expect(thumb(tester).border!.top.width, 2.5);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpSwitch(
        tester,
        theme: themed(
          AnimalSwitchThemeData(
            style: AnimalSwitchStyle(
              labelTextStyle: const TextStyle(letterSpacing: 1.25),
            ),
          ),
        ),
        style: AnimalSwitchStyle(
          labelTextStyle: const TextStyle(fontWeight: FontWeight.w900),
        ),
      );
      final TextStyle style = label(tester, 'ON');
      expect(style.fontWeight, FontWeight.w900);
      expect(style.letterSpacing, 1.25);
      expect(style.fontSize, closeTo(13, 1e-9));
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
      expect(style.color, AnimalIslandTheme.light.colors.onSuccess);
    });
  });

  group('API06 AnimalSwitch boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalSwitchStyle(width: -1), throwsArgumentError);
      expect(
        () => AnimalSwitchStyle(thumbSize: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalSwitchStyle(trackBorderWidth: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalSwitchStyle(labelTextStyle: const TextStyle(fontSize: 0)),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalSwitchThemeData(style: AnimalSwitchStyle(width: 40)),
      );
      final AnimalIslandTheme b = themed(
        AnimalSwitchThemeData(style: AnimalSwitchStyle(width: 60)),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(
        a.lerp(b, 0.5).components.switchControl!.style!.width,
        closeTo(50, 1e-9),
      );
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      // Only one theme sets these fields; null means "use the lower layer".
      const BoxShadow shadow = BoxShadow(
        color: Color(0xFF123456),
        blurRadius: 6,
      );
      final AnimalIslandTheme a = themed(
        AnimalSwitchThemeData(
          style: AnimalSwitchStyle(width: 40, trackInsetShadow: shadow),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.switchControl!.style!.width, 40);
      expect(early.components.switchControl!.style!.trackInsetShadow, shadow);
      expect(late.components.switchControl?.style?.width, isNull);
      expect(late.components.switchControl?.style?.trackInsetShadow, isNull);
    });
  });
}
