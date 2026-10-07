// API06 efficacy and precedence oracles for AnimalNotification.
//
// Expected values are written out here rather than read from the resolver:
// each case sets a distinct value on one layer and checks the rendered
// property. Light preset tokens: heading 20, body 14, spacing xxs 2, xs 4,
// sm 8, lg 16, card radius 20.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<BuildContext> pumpHost(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
  }) async {
    late BuildContext hostContext;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AnimalLocalizations.localizationsDelegates,
        supportedLocales: AnimalLocalizations.supportedLocales,
        theme: (theme ?? AnimalIslandTheme.light).toThemeData(),
        home: AnimalOverlayHost(
          child: Builder(
            builder: (context) {
              hostContext = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    return hostContext;
  }

  Future<void> pumpNotification(
    WidgetTester tester, {
    AnimalIslandTheme? theme,
    AnimalNotificationStyle? style,
  }) async {
    final BuildContext context = await pumpHost(tester, theme: theme);
    AnimalNotification.open(
      context,
      message: const Text('Island notice'),
      description: const Text('Notice detail'),
      duration: null,
      style: style,
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  AnimalIslandTheme themed(AnimalNotificationStyle style) => AnimalIslandTheme
      .light
      .copyWith(components: AnimalComponentThemes(notification: style));

  Finder inCard(Finder matching) => find.descendant(
    of: find.byType(AnimalNotificationCard),
    matching: matching,
  );

  BoxDecoration cardDecoration(WidgetTester tester) =>
      tester
              .widget<Container>(
                inCard(
                  find.byWidgetPredicate(
                    (w) =>
                        w is Container &&
                        w.decoration is BoxDecoration &&
                        (w.decoration! as BoxDecoration).border != null,
                  ),
                ),
              )
              .decoration!
          as BoxDecoration;
  TextStyle textStyleOf(WidgetTester tester, String text) =>
      DefaultTextStyle.of(tester.element(find.text(text))).style;
  List<AnimalIcon> icons(WidgetTester tester) =>
      tester.widgetList<AnimalIcon>(inCard(find.byType(AnimalIcon))).toList();
  AnimatedContainer closeCircle(WidgetTester tester) =>
      tester.widget<AnimatedContainer>(_closeCircleFinder());
  List<EdgeInsetsGeometry> paddings(WidgetTester tester) => tester
      .widgetList<Padding>(inCard(find.byType(Padding)))
      .map((p) => p.padding)
      .toList();
  List<double?> gapWidths(WidgetTester tester) => tester
      .widgetList<SizedBox>(inCard(find.byType(SizedBox)))
      .map((s) => s.width)
      .toList();

  group('API06 AnimalNotification efficacy', () {
    testWidgets('token change reaches the message and the description', (
      tester,
    ) async {
      final AnimalThemeTypography type = AnimalIslandTheme.light.typography;
      await pumpNotification(
        tester,
        theme: AnimalIslandTheme.light.copyWith(
          typography: type.copyWith(
            heading: type.heading.copyWith(fontSize: 28),
            body: type.body.copyWith(fontSize: 28),
          ),
        ),
      );
      expect(textStyleOf(tester, 'Island notice').fontSize, closeTo(21, 1e-9));
      expect(textStyleOf(tester, 'Notice detail').fontSize, closeTo(26, 1e-9));
    });

    testWidgets('defaults stay the token-derived visuals', (tester) async {
      await pumpNotification(tester);
      final BoxDecoration decoration = cardDecoration(tester);
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect((decoration.border! as Border).top.width, 2);
      expect(decoration.boxShadow!.single.blurRadius, 14);
      expect(decoration.boxShadow!.single.offset, const Offset(0, 6));
      expect(textStyleOf(tester, 'Island notice').fontSize, 15);
      expect(textStyleOf(tester, 'Island notice').fontWeight, FontWeight.w800);
      expect(textStyleOf(tester, 'Notice detail').fontSize, 13);
      expect(icons(tester).map((i) => i.size), <double>[22, 14]);
      expect(
        paddings(tester),
        containsAll(<EdgeInsetsGeometry>[
          const EdgeInsets.only(bottom: 9),
          const EdgeInsets.only(left: 20, top: 14, bottom: 14),
          const EdgeInsets.only(top: 2),
          const EdgeInsets.only(right: 20),
        ]),
      );
      expect(closeCircle(tester).padding, const EdgeInsets.all(4));
      expect(gapWidths(tester), containsAll(<double>[14, 8]));
      expect(
        tester
            .widget<ConstrainedBox>(
              inCard(
                find.byWidgetPredicate(
                  (w) => w is ConstrainedBox && w.constraints.maxWidth == 380,
                ),
              ),
            )
            .constraints
            .maxWidth,
        380,
      );
    });

    testWidgets('every component-theme field changes the rendered card', (
      tester,
    ) async {
      await pumpNotification(
        tester,
        theme: themed(
          AnimalNotificationStyle(
            maxWidth: 240,
            gap: 17,
            padding: const EdgeInsets.all(11),
            iconPadding: const EdgeInsets.only(top: 7),
            iconSize: 31,
            iconGap: 13,
            descriptionGap: 9,
            closeButtonGap: 5,
            closeButtonMargin: const EdgeInsets.only(right: 3),
            closeButtonPadding: const EdgeInsets.all(6),
            closeIconSize: 19,
            closeButtonBorderRadius: BorderRadius.circular(5),
            textStyle: const TextStyle(fontSize: 18),
            descriptionTextStyle: const TextStyle(fontSize: 12),
            backgroundColor: const Color(0xFF102030),
            borderColor: const Color(0xFF203040),
            textColor: const Color(0xFF304050),
            descriptionTextColor: const Color(0xFF405060),
            iconColor: const Color(0xFF506070),
            closeIconColor: const Color(0xFF607080),
            borderWidth: 3,
            borderRadius: BorderRadius.circular(7),
            shadow: const BoxShadow(
              color: Color(0xFF708090),
              blurRadius: 5,
              offset: Offset(1, 2),
            ),
          ),
        ),
      );

      final BoxDecoration decoration = cardDecoration(tester);
      expect(decoration.color, const Color(0xFF102030));
      expect((decoration.border! as Border).top.color, const Color(0xFF203040));
      expect((decoration.border! as Border).top.width, 3);
      expect(decoration.borderRadius, BorderRadius.circular(7));
      expect(decoration.boxShadow, const <BoxShadow>[
        BoxShadow(
          color: Color(0xFF708090),
          blurRadius: 5,
          offset: Offset(1, 2),
        ),
      ]);

      final TextStyle message = textStyleOf(tester, 'Island notice');
      expect(message.fontSize, 18);
      expect(message.color, const Color(0xFF304050));
      final TextStyle description = textStyleOf(tester, 'Notice detail');
      expect(description.fontSize, 12);
      expect(description.color, const Color(0xFF405060));

      final List<AnimalIcon> shown = icons(tester);
      expect(shown.first.size, 31);
      expect(shown.first.color, const Color(0xFF506070));
      expect(shown.last.size, 19);
      expect(shown.last.color, const Color(0xFF607080));

      expect(
        paddings(tester),
        containsAll(<EdgeInsetsGeometry>[
          const EdgeInsets.only(bottom: 17),
          const EdgeInsets.all(11),
          const EdgeInsets.only(top: 7),
          const EdgeInsets.only(right: 3),
        ]),
      );
      expect(closeCircle(tester).padding, const EdgeInsets.all(6));
      expect(gapWidths(tester), containsAll(<double>[13, 5]));
      expect(
        tester
            .widgetList<SizedBox>(inCard(find.byType(SizedBox)))
            .map((s) => s.height),
        contains(9),
      );
      expect(
        tester.getSize(find.byType(AnimalNotificationCard)).width,
        240,
        reason: 'maxWidth bounds the card',
      );
      expect(
        tester
            .widgetList<InteractiveRegion>(
              inCard(find.byType(InteractiveRegion)),
            )
            .single
            .borderRadius,
        BorderRadius.circular(5),
      );
    });

    testWidgets('the close button background resolves the hovered state', (
      tester,
    ) async {
      await pumpNotification(
        tester,
        theme: themed(
          AnimalNotificationStyle(
            closeButtonBackgroundColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered)
                  ? const Color(0xFF00AA00)
                  : const Color(0xFF0000AA),
            ),
          ),
        ),
      );
      Color? fill() => (closeCircle(tester).decoration! as BoxDecoration).color;
      expect(fill(), const Color(0xFF0000AA));

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(_closeCircleFinder()));
      await tester.pump(const Duration(seconds: 1));
      expect(fill(), const Color(0xFF00AA00));
    });
  });

  group('API06 AnimalNotification precedence', () {
    testWidgets('instance > theme > token default', (tester) async {
      await pumpNotification(
        tester,
        theme: themed(
          AnimalNotificationStyle(
            backgroundColor: const Color(0xFF111111),
            iconSize: 30,
          ),
        ),
        style: AnimalNotificationStyle(
          backgroundColor: const Color(0xFF222222),
        ),
      );
      final BoxDecoration decoration = cardDecoration(tester);
      expect(decoration.color, const Color(0xFF222222));
      expect(icons(tester).first.size, 30);
      expect((decoration.border! as Border).top.width, 2);
    });

    testWidgets('a partial text style keeps the lower layers', (tester) async {
      await pumpNotification(
        tester,
        theme: themed(
          AnimalNotificationStyle(
            textStyle: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        style: AnimalNotificationStyle(
          textStyle: const TextStyle(fontSize: 19),
        ),
      );
      final TextStyle style = textStyleOf(tester, 'Island notice');
      expect(style.fontSize, 19);
      expect(style.fontStyle, FontStyle.italic);
      expect(style.fontWeight, FontWeight.w800);
      expect(style.fontFamily, AnimalIslandTheme.light.typography.fontFamily);
    });
  });

  group('API06 AnimalNotification boundary', () {
    test('styles reject values components cannot render', () {
      expect(() => AnimalNotificationStyle(maxWidth: -1), throwsArgumentError);
      expect(
        () => AnimalNotificationStyle(borderWidth: double.nan),
        throwsArgumentError,
      );
      expect(
        () => AnimalNotificationStyle(iconSize: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalNotificationStyle(
          descriptionTextStyle: const TextStyle(fontSize: 0),
        ),
        throwsArgumentError,
      );
    });

    test('theme interpolation keeps exact endpoints', () {
      final AnimalIslandTheme a = themed(
        AnimalNotificationStyle(maxWidth: 300),
      );
      final AnimalIslandTheme b = themed(
        AnimalNotificationStyle(maxWidth: 400),
      );
      expect(a.lerp(b, 0), a);
      expect(a.lerp(b, 1), b);
      expect(
        a.lerp(b, 0.5).components.notification!.maxWidth,
        closeTo(350, 1e-9),
      );
    });

    test('a one-sided override switches at the midpoint without throwing', () {
      final AnimalIslandTheme a = themed(
        AnimalNotificationStyle(
          borderWidth: 3,
          backgroundColor: const Color(0xFF123456),
        ),
      );
      final AnimalIslandTheme early = a.lerp(AnimalIslandTheme.light, 0.25);
      final AnimalIslandTheme late = a.lerp(AnimalIslandTheme.light, 0.75);
      expect(early.components.notification!.borderWidth, 3);
      expect(
        early.components.notification!.backgroundColor,
        const Color(0xFF123456),
      );
      expect(late.components.notification?.borderWidth, isNull);
      expect(late.components.notification?.backgroundColor, isNull);
    });
  });
}

Finder _closeCircleFinder() => find.byWidgetPredicate(
  (w) => w is AnimatedContainer && w.child is AnimalIcon,
);
