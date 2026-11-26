import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(
  Widget child, {
  Locale locale = const Locale('en'),
  bool disableAnimations = false,
  Brightness brightness = Brightness.light,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: IslandLocalizations.delegates,
    supportedLocales: IslandLocalizations.supportedLocales,
    theme: IslandTheme.create(brightness: brightness),
    builder: (context, appChild) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: appChild!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('non-hoverable IslandCard skips TweenAnimationBuilder overhead', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(const IslandCard(child: Text('Static card'))),
    );
    expect(find.byType(TweenAnimationBuilder<Matrix4>), findsNothing);
  });

  testWidgets(
    'IslandBackground isolates painting in RepaintBoundary and skips ClipRRect at zero radius',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 200,
            height: 200,
            child: IslandBackground(
              type: IslandBackgroundType.sprinkles,
              child: Text('Layered'),
            ),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(IslandBackground),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(IslandBackground),
          matching: find.byType(ClipRRect),
        ),
        findsNothing,
      );
    },
  );

  testWidgets(
    'IslandLoading and IslandAvatarGroup support const instantiation',
    (tester) async {
      const loading = IslandLoading(active: false);
      const group = IslandAvatarGroup(
        children: [IslandAvatar(child: Text('A'))],
      );
      await tester.pumpWidget(
        _host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [loading, group],
          ),
        ),
      );
      expect(find.text('A'), findsOneWidget);
    },
  );

  testWidgets(
    'IslandTooltip hover trigger opens on keyboard focus and click trigger dismisses on outside tap',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _host(
          IslandTooltip(
            message: 'Keyboard tip',
            child: IslandButton(
              focusNode: focus,
              onPressed: () {},
              child: const Text('Focus me'),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pumpAndSettle();
      expect(find.text('Keyboard tip'), findsOneWidget);

      await tester.pumpWidget(
        _host(
          Align(
            alignment: Alignment.topLeft,
            child: IslandTooltip.click(
              message: 'Click tip',
              builder: (_, toggle) => IslandButton(
                onPressed: toggle,
                child: const Text('Toggle tip'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Toggle tip'));
      await tester.pumpAndSettle();
      expect(find.text('Click tip'), findsOneWidget);
      await tester.tapAt(const Offset(700, 500));
      await tester.pumpAndSettle();
      expect(find.text('Click tip'), findsNothing);
    },
  );

  testWidgets(
    'focus that a press leaves behind neither opens a hover Tooltip nor holds a Notification',
    (tester) async {
      final controller = IslandNotificationsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          IslandNotifications(
            controller: controller,
            child: IslandTooltip(
              message: 'Pressed tip',
              child: IslandButton(onPressed: () {}, child: const Text('Press')),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Press'));
      await tester.pumpAndSettle();
      expect(find.text('Pressed tip'), findsNothing);

      var pressed = 0;
      controller.show(
        IslandNotification(
          message: const Text('Pressed body'),
          duration: const Duration(seconds: 2),
          onPressed: () => pressed++,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pressed body'));
      await tester.pump();
      expect(pressed, 1);
      await tester.pump(const Duration(milliseconds: 2100));
      await tester.pumpAndSettle();
      expect(find.text('Pressed body'), findsNothing);
    },
  );

  testWidgets('keyboard focus holds a Notification until it leaves', (
    tester,
  ) async {
    final controller = IslandNotificationsController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _host(
        IslandNotifications(
          controller: controller,
          child: const SizedBox.expand(),
        ),
      ),
    );
    controller.show(
      IslandNotification(
        message: const Text('Keyboard body'),
        duration: const Duration(seconds: 2),
        onPressed: () {},
      ),
    );
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(find.text('Keyboard body'), findsOneWidget);
    FocusManager.instance.primaryFocus!.unfocus();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard body'), findsNothing);
  });

  testWidgets(
    'IslandSelect with showSearch and allowClear keeps clear button mounted on Tab',
    (tester) async {
      String? value = 'apple';
      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (_, setState) => IslandSelect<String>(
              value: value,
              showSearch: true,
              allowClear: true,
              options: const [
                IslandOption(value: 'apple', label: 'Apple'),
                IslandOption(value: 'pear', label: 'Pear'),
              ],
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Clear'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Clear'), findsOneWidget);
    },
  );

  testWidgets(
    'IslandNotification pauses auto-dismiss on hover and fits narrow viewports',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final controller = IslandNotificationsController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _host(
          IslandNotifications(
            controller: controller,
            child: const SizedBox.expand(),
          ),
        ),
      );
      controller.show(
        const IslandNotification(
          message: Text('Hold on hover'),
          duration: Duration(seconds: 2),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Hold on hover'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final mouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.text('Hold on hover')));
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Hold on hover'), findsOneWidget);

      // Reference `max-width: calc(100vw - 48px)`.
      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('Hold on hover'),
                    matching: find.byType(AnimatedContainer),
                  )
                  .first,
            )
            .width,
        272,
      );

      // Leaving restarts the full duration.
      await mouse.moveTo(const Offset(1, 630));
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.text('Hold on hover'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pumpAndSettle();
      expect(find.text('Hold on hover'), findsNothing);
      await mouse.removePointer();
    },
  );

  testWidgets(
    'IslandCarousel suppresses autoplay when disableAnimations is enabled',
    (tester) async {
      String active = 'a';
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 400,
            height: 200,
            child: IslandCarousel<String>(
              value: active,
              autoplay: true,
              interval: const Duration(seconds: 1),
              items: const [
                IslandSlide(value: 'a', child: Text('Slide A')),
                IslandSlide(value: 'b', child: Text('Slide B')),
              ],
              onChanged: (next) => active = next,
            ),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(active, 'a');
    },
  );

  testWidgets('IslandRate mirrors left and right arrow keys in RTL', (
    tester,
  ) async {
    var rating = 2;
    await tester.pumpWidget(
      _host(
        Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (_, setState) => IslandRate(
              value: rating,
              onChanged: (next) => setState(() => rating = next),
            ),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    // In RTL, arrowRight decreases the rating and arrowLeft increases it.
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(rating, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pump();
    expect(rating, 2);
  });

  test(
    'ThemeExtensions and public immutable styles implement value equality',
    () {
      expect(IslandTokens.light, equals(IslandTokens.light.copyWith()));
      expect(
        IslandTokens.light.hashCode,
        equals(IslandTokens.light.copyWith().hashCode),
      );
      expect(const IslandButtonTheme(), equals(const IslandButtonTheme()));
      expect(const IslandCardTheme(), equals(const IslandCardTheme()));
      expect(const IslandCardStyle(), equals(const IslandCardStyle()));
      expect(
        const IslandCodeBlockTheme(),
        equals(const IslandCodeBlockTheme()),
      );
      expect(
        const IslandCodeBlockStyle(
          syntaxColors: {IslandCodeToken.keyword: Color(0xFF112233)},
        ),
        equals(
          const IslandCodeBlockStyle(
            syntaxColors: {IslandCodeToken.keyword: Color(0xFF112233)},
          ),
        ),
      );
      expect(const IslandTimeStyle(), equals(const IslandTimeStyle()));
      expect(
        const IslandOption<int>(value: 1, label: 'One'),
        equals(const IslandOption<int>(value: 1, label: 'One')),
      );
    },
  );
}
