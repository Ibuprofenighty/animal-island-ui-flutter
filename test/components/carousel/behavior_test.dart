import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';

void main() {
  _navigationOracles();
  group('AnimalCarousel Behavior Tests (C11 / CAR01-CAR03)', () {
    testWidgets('CAR01: arrow buttons advance and loop slides', (tester) async {
      String active = 'slide-0';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCarousel.uncontrolled(
              style: AnimalCarouselStyle(height: 150),
              showArrows: true,
              loop: true,
              onChange: (idx) => active = idx,
              items: [
                AnimalCarouselItem(id: 'slide-0', child: Text('Slide 0')),
                AnimalCarouselItem(id: 'slide-1', child: Text('Slide 1')),
                AnimalCarouselItem(id: 'slide-2', child: Text('Slide 2')),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Slide 0'), findsOneWidget);

      // Tap Next arrow
      final nextFinder = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Next slide',
      );
      expect(nextFinder, findsOneWidget);

      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      expect(active, 'slide-1');
      expect(find.text('Slide 1'), findsOneWidget);
    });

    testWidgets(
      'CAR02: TickerMode disabled stops autoplay timer and resumes on enable',
      (tester) async {
        final tickerNotifier = ValueNotifier<bool>(true);
        final autoPlayNotifier = ValueNotifier<bool>(true);
        final clock = FakeClock();
        final changes = <String>[];

        Future<void> pumpElapsed(Duration elapsed) async {
          clock.advanceMonotonic(elapsed);
          await tester.pump(elapsed);
        }

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: tickerNotifier,
                builder: (context, enabled, child) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: autoPlayNotifier,
                    builder: (context, autoPlay, child) {
                      return TickerMode(
                        enabled: enabled,
                        child: AnimalCarousel.uncontrolled(
                          style: AnimalCarouselStyle(height: 150),
                          autoPlay: autoPlay,
                          autoPlayInterval: const Duration(milliseconds: 100),
                          clock: clock,
                          onChange: changes.add,
                          items: [
                            AnimalCarouselItem(
                              id: 'slide-0',
                              child: Text('Slide A'),
                            ),
                            AnimalCarouselItem(
                              id: 'slide-1',
                              child: Text('Slide B'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Slide A'), findsOneWidget);
        final pageController = tester
            .widget<PageView>(find.byType(PageView))
            .controller!;

        // Disable TickerMode
        tickerNotifier.value = false;
        await tester.pump();

        await pumpElapsed(const Duration(milliseconds: 300));
        expect(
          pageController.position.isScrollingNotifier.value,
          isFalse,
          reason: 'CAR02_PAUSED_AUTOPLAY_STARTED_SCROLL',
        );
        expect(changes, isEmpty);
        expect(pageController.page, 0);
        expect(find.text('Slide A'), findsOneWidget);

        // Re-enable TickerMode
        tickerNotifier.value = true;
        await tester.pump();

        // The normal 100 ms interval must elapse after resume, with no catch-up.
        await pumpElapsed(const Duration(milliseconds: 50));
        expect(pageController.position.isScrollingNotifier.value, isFalse);
        await pumpElapsed(const Duration(milliseconds: 50));
        expect(pageController.position.isScrollingNotifier.value, isTrue);

        // Let this one in-flight transition finish without another autoplay tick.
        autoPlayNotifier.value = false;
        await tester.pump();
        for (int i = 0; i < 6; i++) {
          await pumpElapsed(const Duration(milliseconds: 50));
        }
        expect(pageController.page, 1);
        expect(changes, <String>['slide-1']);
        expect(find.text('Slide B'), findsOneWidget);
      },
    );
  });
}

Widget _navigationApp(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);
List<AnimalCarouselItem> _slides(int count) => [
  for (var i = 0; i < count; i++)
    AnimalCarouselItem(id: 's$i', child: Text('Slide $i')),
];
void _navigationOracles() {
  testWidgets(
    'CAR02 descendant build policy changes defer safely and resumed transitions never revive',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      var active = 's0';
      var notify = false;
      var roundTrip = false;
      late StateSetter rebuildSlide;
      Widget app() => _navigationApp(
        AnimalCarousel(
          activeId: active,
          autoPlay: false,
          style: AnimalCarouselStyle(
            duration: const Duration(seconds: 1),
            dotDuration: const Duration(seconds: 1),
            dotSize: 8,
            activeDotWidth: 40,
          ),
          items: [
            AnimalCarouselItem(
              id: 's0',
              child: StatefulBuilder(
                builder: (_, setState) {
                  rebuildSlide = setState;
                  if (notify) {
                    notify = false;
                    tester.binding.handleAppLifecycleStateChanged(
                      AppLifecycleState.paused,
                    );
                    if (roundTrip) {
                      tester.binding.handleAppLifecycleStateChanged(
                        AppLifecycleState.resumed,
                      );
                    }
                  }
                  return const Text('Slide 0');
                },
              ),
            ),
            AnimalCarouselItem(id: 's1', child: const Text('Slide 1')),
            AnimalCarouselItem(id: 's2', child: const Text('Slide 2')),
          ],
        ),
      );
      try {
        notify = true;
        await tester.pumpWidget(app());
        expect(
          tester.takeException(),
          isNull,
          reason: 'CAR02_BUILD_POLICY_NOTIFICATION',
        );
        await tester.pumpAndSettle();
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();
        for (final resumeInBuild in [false, true]) {
          roundTrip = resumeInBuild;
          active = 's2';
          await tester.pumpWidget(app());
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.binding.transientCallbackCount, greaterThan(0));
          notify = true;
          rebuildSlide(() {});
          await tester.pump();
          expect(
            tester.takeException(),
            isNull,
            reason: 'CAR02_BUILD_POLICY_NOTIFICATION',
          );
          await tester.pump();
          expect(
            tester.binding.transientCallbackCount,
            0,
            reason: 'CAR02_BUILD_POLICY_INTERRUPTION',
          );
          expect(
            tester.widget<PageView>(find.byType(PageView)).controller!.page,
            2,
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          active = 's0';
          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
        }
      } finally {
        await tester.pumpWidget(const SizedBox());
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      }
    },
  );
  testWidgets(
    'CAR02 low motion TickerMode and background interrupt running page and dot transitions',
    (tester) async {
      var active = 's0';
      var reduced = false;
      var tickerEnabled = true;
      final proposals = <String>[];
      Widget app() => _navigationApp(
        MediaQuery(
          data: MediaQueryData(disableAnimations: reduced),
          child: TickerMode(
            enabled: tickerEnabled,
            child: AnimalCarousel(
              items: _slides(3),
              activeId: active,
              autoPlay: false,
              onChange: proposals.add,
              style: AnimalCarouselStyle(
                duration: const Duration(seconds: 1),
                dotDuration: const Duration(seconds: 1),
                dotSize: 8,
                activeDotWidth: 40,
              ),
            ),
          ),
        ),
      );
      final dots = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer && widget.constraints?.maxHeight == 8,
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      try {
        await tester.pumpWidget(app());
        await tester.pumpAndSettle();
        for (final policy in ['reduced', 'ticker', 'background']) {
          active = 's2';
          await tester.pumpWidget(app());
          await tester.pump(const Duration(milliseconds: 16));
          expect(tester.binding.transientCallbackCount, greaterThan(0));
          if (policy == 'reduced') {
            reduced = true;
            await tester.pumpWidget(app());
          } else if (policy == 'ticker') {
            tickerEnabled = false;
            await tester.pumpWidget(app());
          } else {
            tester.binding.handleAppLifecycleStateChanged(
              AppLifecycleState.paused,
            );
            await tester.pump();
          }
          await tester.pump();
          expect(
            tester.binding.transientCallbackCount,
            0,
            reason: 'CAR02_POLICY_INTERRUPTED_TICKER:$policy',
          );
          expect(
            tester.widget<PageView>(find.byType(PageView)).controller!.page,
            2,
          );
          expect(
            [for (var i = 0; i < 3; i++) tester.getSize(dots.at(i)).width],
            [8, 8, 40],
          );
          reduced = false;
          tickerEnabled = true;
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          await tester.pumpWidget(app());
          await tester.pump();
          expect(tester.binding.transientCallbackCount, 0);
          active = 's0';
          await tester.pumpWidget(app());
          await tester.pumpAndSettle();
        }
        expect(proposals, isEmpty);
        expect(tester.takeException(), isNull);
      } finally {
        await tester.pumpWidget(const SizedBox());
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
      }
    },
  );
  testWidgets(
    'CAR01 defaults remain valid at construction and cleaned deletion never resets mounted ownership',
    (tester) async {
      var items = _slides(3);
      String? initial = 's2';
      final proposals = <String>[];
      Widget app() => _navigationApp(
        AnimalCarousel.uncontrolled(
          key: const ValueKey('strict-default-carousel'),
          items: items,
          defaultActiveId: initial,
          autoPlay: false,
          onChange: proposals.add,
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      final state = tester.state(find.byType(AnimalCarousel));
      final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
      expect(pages.page, 2);
      initial = 's0';
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(AnimalCarousel)), same(state));
      expect(pages.page, 2);
      initial = 's2';
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      items = [items.first];
      expect(app, throwsArgumentError);
      initial = null;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(AnimalCarousel)), same(state));
      expect(pages.page, 0);
      items = [];
      expect(
        () => AnimalCarousel.uncontrolled(items: items, defaultActiveId: 's0'),
        throwsArgumentError,
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(AnimalCarousel)), same(state));
      expect(find.byType(PageView), findsNothing);
      expect(proposals, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'CAR04 RTL arrows mirror logical navigation and controlled proposals preserve the owner',
    (tester) async {
      final proposals = <String>[];
      for (final direction in [
        TextDirection.ltr,
        TextDirection.rtl,
        TextDirection.ltr,
      ]) {
        await tester.pumpWidget(
          _navigationApp(
            Directionality(
              textDirection: direction,
              child: AnimalCarousel(
                items: _slides(3),
                activeId: 's1',
                autoPlay: false,
                onChange: proposals.add,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final copy = AnimalLocalizations.of(
          tester.element(find.byType(AnimalCarousel)),
        )!;
        final previous = find.bySemanticsLabel(copy.carouselPreviousSlide);
        final next = find.bySemanticsLabel(copy.carouselNextSlide);
        double renderedDirection(Finder control) {
          final iconFinder = find.descendant(
            of: control,
            matching: find.byType(Icon),
          );
          final icon = tester.widget<Icon>(iconFinder).icon;
          final baseline = switch (icon) {
            Icons.chevron_left_rounded => -1,
            Icons.chevron_right_rounded => 1,
            _ => throw TestFailure('Expected a directional chevron: $icon'),
          };
          final paragraph = tester.renderObject<RenderParagraph>(
            find.descendant(of: iconFinder, matching: find.byType(RichText)),
          );
          final scaleX = paragraph
              .getTransformTo(tester.renderObject(control))
              .entry(0, 0);
          return baseline * scaleX.sign;
        }

        final rtl = direction == TextDirection.rtl;
        expect(
          renderedDirection(previous),
          rtl ? 1 : -1,
          reason: 'CAR04_RENDERED_DIRECTION_DOUBLE_MIRROR previous $direction',
        );
        expect(
          renderedDirection(next),
          rtl ? -1 : 1,
          reason: 'CAR04_RENDERED_DIRECTION_DOUBLE_MIRROR next $direction',
        );
        expect(tester.getCenter(previous).dx < tester.getCenter(next).dx, !rtl);
        await tester.tap(next);
        await tester.pumpAndSettle();
        expect(proposals.last, 's2');
        expect(
          tester.widget<AnimalCarousel>(find.byType(AnimalCarousel)).activeId,
          's1',
        );
        expect(
          tester.widget<PageView>(find.byType(PageView)).controller!.page,
          1,
        );
        await tester.tap(previous);
        await tester.pumpAndSettle();
        expect(proposals.last, 's0');
        expect(
          tester.widget<AnimalCarousel>(find.byType(AnimalCarousel)).activeId,
          's1',
        );
        expect(
          tester.widget<PageView>(find.byType(PageView)).controller!.page,
          1,
        );
      }
      expect(proposals, ['s2', 's0', 's2', 's0', 's2', 's0']);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'CAR02 invisible owner updates settle pages and dots with zero decorative tickers',
    (tester) async {
      var active = 's0';
      var visible = false;
      final proposals = <String>[];
      Widget app() => _navigationApp(
        AnimalCarousel(
          items: _slides(3),
          activeId: active,
          autoPlay: false,
          visible: visible,
          onChange: proposals.add,
          style: AnimalCarouselStyle(
            duration: const Duration(seconds: 1),
            dotDuration: const Duration(seconds: 1),
            dotSize: 8,
            activeDotWidth: 40,
          ),
        ),
      );
      final dots = find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer && widget.constraints?.maxHeight == 8,
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      active = 's2';
      await tester.pumpWidget(app());
      await tester.pump();
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'CAR02_INVISIBLE_DOT_TICKER',
      );
      expect(dots, findsNWidgets(3));
      expect(
        [for (var i = 0; i < 3; i++) tester.getSize(dots.at(i)).width],
        [8, 8, 40],
      );
      final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
      expect(pages.page, 2);
      visible = true;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      active = 's1';
      await tester.pumpWidget(app());
      await tester.pump(const Duration(milliseconds: 16));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      visible = false;
      await tester.pumpWidget(app());
      await tester.pump();
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: 'CAR02_INTERRUPTED_DECORATIVE_TICKER',
      );
      expect(pages.page, 1);
      expect(
        [for (var i = 0; i < 3; i++) tester.getSize(dots.at(i)).width],
        [8, 40, 8],
      );
      expect(proposals, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'CAR03 accepted controlled swipe continues forward without resetting before the owner rebuilds',
    (tester) async {
      var active = 's0';
      final proposals = <String>[];
      final items = [
        for (var i = 0; i < 3; i++)
          AnimalCarouselItem(id: 's$i', child: Text('Slide $i')),
      ];
      await tester.pumpWidget(
        _navigationApp(
          StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 400,
              height: 220,
              child: AnimalCarousel(
                items: items,
                activeId: active,
                autoPlay: false,
                showArrows: false,
                showDots: false,
                style: AnimalCarouselStyle(
                  duration: const Duration(seconds: 1),
                ),
                onChange: (id) {
                  proposals.add(id);
                  setState(() => active = id);
                },
              ),
            ),
          ),
        ),
      );
      final pages = tester.widget<PageView>(find.byType(PageView)).controller!;
      await tester.drag(
        find.byType(PageView),
        Offset(-tester.getSize(find.byType(PageView)).width * .8, 0),
      );
      final afterDrag = pages.page!;
      expect(afterDrag, greaterThan(.5), reason: 'CAR03_ACCEPTED_SWIPE_RESET');
      await tester.pump(const Duration(milliseconds: 16));
      expect(pages.page!, greaterThanOrEqualTo(afterDrag));
      await tester.pumpAndSettle();
      expect(active, 's1');
      expect(pages.page, 1);
      expect(proposals, ['s1']);
    },
  );
  test('CAR01 stable identity and interval boundaries reject invalid inputs and freeze slides', () {
    final items = _slides(2);
    final carousel = AnimalCarousel(items: items, activeId: 's0');
    items.clear();
    expect(carousel.items, hasLength(2));
    expect(
      () => AnimalCarousel(items: _slides(2), activeId: 'gone'),
      throwsArgumentError,
    );
    expect(
      () => AnimalCarousel(items: [], activeId: 's0'),
      throwsArgumentError,
    );
    expect(
      () => AnimalCarousel.uncontrolled(
        items: _slides(2),
        autoPlayInterval: Duration.zero,
      ),
      throwsArgumentError,
    );
    expect(
      () => AnimalCarousel(
        items: [carousel.items.first, carousel.items.first],
        activeId: 's0',
      ),
      throwsArgumentError,
    );
  });
  testWidgets(
    'CAR01 uncontrolled 5 to 1 to 0 and reorder synchronize the controller without proposals',
    (tester) async {
      var items = _slides(5);
      final proposals = <String>[];
      Widget app() => _navigationApp(
        AnimalCarousel.uncontrolled(
          items: items,
          defaultActiveId: items.any((i) => i.id == 's4') ? 's4' : null,
          autoPlay: false,
          onChange: proposals.add,
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        4,
      );
      items = [items.last, items.first];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        0,
      );
      items = [items.last];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        0,
      );
      items = [];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.byType(PageView), findsNothing);
      expect(proposals, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'CAR03 controlled arrow swipe and external update use one ID and never echo proposals',
    (tester) async {
      var active = 's0';
      final proposals = <String>[];
      Widget app() => _navigationApp(
        AnimalCarousel(
          items: _slides(3),
          activeId: active,
          autoPlay: false,
          onChange: proposals.add,
        ),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Next slide'));
      await tester.pumpAndSettle();
      expect(proposals, ['s1']);
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        0,
      );
      await tester.drag(find.byType(PageView), const Offset(-700, 0));
      await tester.pumpAndSettle();
      expect(proposals, ['s1', 's1']);
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        0,
      );
      active = 's2';
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(
        tester.widget<PageView>(find.byType(PageView)).controller!.page,
        2,
      );
      expect(proposals, hasLength(2));
    },
  );
  testWidgets(
    'CAR02 focus pauses autoplay and resume has one fresh interval while nonloop stops at the end',
    (tester) async {
      final focus = FocusNode();
      final clock = FakeClock();
      final proposals = <String>[];
      var items = [
        AnimalCarouselItem(
          id: 'a',
          child: TextField(focusNode: focus),
        ),
        AnimalCarouselItem(id: 'b', child: const Text('B')),
      ];
      await tester.pumpWidget(
        _navigationApp(
          AnimalCarousel.uncontrolled(
            items: items,
            clock: clock,
            pauseOnHover: false,
            autoPlayInterval: const Duration(milliseconds: 100),
            loop: false,
            onChange: proposals.add,
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      clock.advanceMonotonic(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(proposals, isEmpty);
      focus.unfocus();
      await tester.pump();
      clock.advanceMonotonic(const Duration(milliseconds: 99));
      await tester.pump(const Duration(milliseconds: 99));
      expect(proposals, isEmpty);
      clock.advanceMonotonic(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(proposals, ['b']);
      clock.advanceMonotonic(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(proposals, ['b']);
      await tester.pumpWidget(const SizedBox());
      focus.dispose();
      expect(tester.takeException(), isNull);
    },
  );
}
