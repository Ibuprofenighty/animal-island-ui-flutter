import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/timing/motion_policy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_clock.dart';

class _CountingClock extends FakeClock {
  _CountingClock(super.initial);

  int wallReads = 0;
  int monotonicReads = 0;

  int get reads => wallReads + monotonicReads;

  void resetReads() {
    wallReads = 0;
    monotonicReads = 0;
  }

  @override
  DateTime now() {
    wallReads++;
    return super.now();
  }

  @override
  Duration get monotonicNow {
    monotonicReads++;
    return super.monotonicNow;
  }
}

void main() {
  group('Timing and motion policy', () {
    test('wall time and monotonic elapsed advance independently', () {
      final DateTime base = DateTime(2026, 9, 12, 12);
      final FakeClock clock = FakeClock(base);

      expect(clock.now(), base);
      expect(clock.monotonicNow, Duration.zero);
      clock.advanceWall(const Duration(seconds: 42));
      expect(clock.now(), base.add(const Duration(seconds: 42)));
      expect(clock.monotonicNow, Duration.zero);
      clock.advanceMonotonic(const Duration(milliseconds: 1));
      expect(clock.monotonicNow, const Duration(milliseconds: 1));
    });

    testWidgets(
      'Focus, hover, offscreen, reduced motion, and TickerMode are negative policy cases',
      (WidgetTester tester) async {
        final Map<String, bool> outcomes = <String, bool>{};

        Future<void> pumpPolicy({
          bool disableAnimations = false,
          bool tickerEnabled = true,
        }) async {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(disableAnimations: disableAnimations),
              child: TickerMode(
                enabled: tickerEnabled,
                child: Builder(
                  builder: (BuildContext context) {
                    outcomes['normal'] = AnimalMotionPolicy.shouldAnimate(
                      context,
                    );
                    outcomes['focused'] = AnimalMotionPolicy.shouldAnimate(
                      context,
                      focused: true,
                    );
                    outcomes['hovered'] = AnimalMotionPolicy.shouldAnimate(
                      context,
                      hovered: true,
                    );
                    outcomes['offscreen'] = AnimalMotionPolicy.shouldAnimate(
                      context,
                      visible: false,
                    );
                    outcomes['decorative_context'] =
                        AnimalMotionPolicy.decorativeContextEligible(context);
                    outcomes['functional_context'] =
                        AnimalMotionPolicy.functionalTimeContextEligible(
                          context,
                        );
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          );
        }

        await pumpPolicy();
        expect(outcomes['normal'], isTrue);
        expect(outcomes['focused'], isFalse);
        expect(outcomes['hovered'], isFalse);
        expect(outcomes['offscreen'], isFalse);

        await pumpPolicy(disableAnimations: true);
        expect(outcomes['normal'], isFalse);
        expect(outcomes['decorative_context'], isFalse);
        expect(outcomes['functional_context'], isTrue);

        await pumpPolicy(tickerEnabled: false);
        expect(outcomes['normal'], isFalse);
        expect(outcomes['decorative_context'], isFalse);
        expect(outcomes['functional_context'], isFalse);
      },
    );

    testWidgets(
      'Background-first functional registration refreshes wall time on resume without catch-up',
      (WidgetTester tester) async {
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        final FakeClock clock = FakeClock(DateTime(2026, 9, 12, 12));
        FakeClock activeClock = clock;
        final AnimalMotionScheduler scheduler = AnimalMotionScheduler(
          clock: clock,
        );
        DateTime? lastWallRead;
        final List<Duration> elapsedTicks = <Duration>[];
        int tickCount = 0;
        int resumeCount = 0;
        final AnimalMotionRegistration functional = scheduler.schedulePeriodic(
          interval: const Duration(milliseconds: 1),
          work: AnimalScheduledWork.functionalTime,
          eligible: false,
          onTick: (DateTime _, Duration elapsed) {
            tickCount++;
            elapsedTicks.add(elapsed);
            lastWallRead = activeClock.now();
          },
          onResume: () {
            resumeCount++;
            lastWallRead = activeClock.now();
          },
        );
        final AnimalMotionRegistration decorative = scheduler.schedulePeriodic(
          interval: const Duration(milliseconds: 1),
          work: AnimalScheduledWork.decorative,
          eligible: false,
          onTick: (_, _) => tickCount++,
        );

        // Ineligible registrations do not tick.
        await tester.pump(const Duration(milliseconds: 10));
        expect(tickCount, 0);
        functional.setEligible(true);
        decorative.setEligible(true);

        clock.advanceWall(const Duration(seconds: 3));
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(resumeCount, 1);
        expect(lastWallRead, clock.now());

        clock.advanceMonotonic(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 1));
        expect(tickCount, 2);
        expect(elapsedTicks, <Duration>[const Duration(milliseconds: 1)]);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        final int beforeBackground = tickCount;
        clock.advanceWall(const Duration(seconds: 5));
        clock.advanceMonotonic(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 10));
        expect(tickCount, beforeBackground);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(resumeCount, 2);
        expect(lastWallRead, clock.now());
        clock.advanceMonotonic(const Duration(milliseconds: 1));
        await tester.pump(const Duration(milliseconds: 1));
        expect(tickCount, beforeBackground + 2);
        expect(elapsedTicks.last, const Duration(milliseconds: 1));

        decorative.setEligible(false);
        clock.advanceWall(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 10));
        expect(tickCount, beforeBackground + 12);

        functional.setEligible(false);
        final int whileTickerDisabled = tickCount;
        await tester.pump(const Duration(milliseconds: 10));
        expect(tickCount, whileTickerDisabled);

        functional.setEligible(true);
        decorative.setEligible(true);
        expect(resumeCount, 3);
        expect(lastWallRead, clock.now());
        final FakeClock replacement = FakeClock(DateTime(2027, 1, 1));
        activeClock = replacement;
        scheduler.updateClock(replacement);
        expect(resumeCount, 4);
        expect(lastWallRead, replacement.now());

        // A disposed scheduler keeps no registration: nothing ticks or
        // resumes any more.
        scheduler.dispose();
        final int afterDispose = tickCount;
        await tester.pump(const Duration(milliseconds: 10));
        expect(tickCount, afterDispose);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(resumeCount, 4);
      },
    );

    testWidgets(
      'Owner-visible component work pauses and resumes without decorative catch-up',
      (WidgetTester tester) async {
        final _CountingClock clock = _CountingClock(
          DateTime(2026, 9, 13, 10, 15, 30),
        );
        final ValueNotifier<bool> visible = ValueNotifier<bool>(false);
        final List<int> carouselChanges = <int>[];
        final List<Duration> countdownChanges = <Duration>[];
        int typewriterCompletions = 0;

        Future<void> elapse(Duration duration) async {
          clock.advance(duration);
          await tester.pump(duration);
        }

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: ValueListenableBuilder<bool>(
                valueListenable: visible,
                builder: (BuildContext context, bool isVisible, Widget? child) {
                  return Column(
                    children: <Widget>[
                      Offstage(
                        offstage: !isVisible,
                        child: AnimalCarousel(
                          height: 100,
                          autoPlayInterval: const Duration(seconds: 1),
                          items: const <Widget>[
                            Text('Slide 0'),
                            Text('Slide 1'),
                            Text('Slide 2'),
                          ],
                          visible: isVisible,
                          clock: clock,
                          onChange: carouselChanges.add,
                        ),
                      ),
                      Offstage(
                        offstage: !isVisible,
                        child: AnimalTypewriter(
                          text: 'AB',
                          speed: const Duration(seconds: 1),
                          visible: isVisible,
                          clock: clock,
                          onComplete: () => typewriterCompletions++,
                        ),
                      ),
                      Offstage(
                        offstage: !isVisible,
                        child: AnimalTime(
                          live: true,
                          visible: isVisible,
                          clock: clock,
                        ),
                      ),
                      Offstage(
                        offstage: !isVisible,
                        child: AnimalCountdown(
                          remaining: const Duration(seconds: 10),
                          format: 'ss',
                          visible: isVisible,
                          clock: clock,
                          onChange: countdownChanges.add,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        clock.resetReads();
        await elapse(const Duration(seconds: 3));
        expect(clock.reads, 0);
        expect(carouselChanges, isEmpty);
        expect(countdownChanges, isEmpty);
        expect(typewriterCompletions, 0);

        visible.value = true;
        await tester.pump();
        expect(find.text('10:15:33'), findsOneWidget);
        expect(countdownChanges, <Duration>[const Duration(seconds: 7)]);
        expect(carouselChanges, isEmpty);
        expect(typewriterCompletions, 0);

        await elapse(const Duration(seconds: 1));
        await elapse(const Duration(milliseconds: 250));
        expect(carouselChanges, <int>[1]);
        expect(typewriterCompletions, 0);

        visible.value = false;
        await tester.pump();
        clock.resetReads();
        final List<int> pausedCarousel = List<int>.of(carouselChanges);
        final int pausedCompletions = typewriterCompletions;
        await elapse(const Duration(seconds: 3));
        expect(clock.reads, 0);
        expect(carouselChanges, pausedCarousel);
        expect(typewriterCompletions, pausedCompletions);

        visible.value = true;
        await tester.pump();
        expect(find.text('10:15:37'), findsOneWidget);
        expect(countdownChanges.last, const Duration(seconds: 3));
        expect(carouselChanges, pausedCarousel);
        expect(typewriterCompletions, 0);

        clock.resetReads();
        await elapse(const Duration(milliseconds: 999));
        expect(clock.reads, 0);
        expect(carouselChanges, pausedCarousel);
        expect(typewriterCompletions, 0);
        await elapse(const Duration(milliseconds: 1));
        await elapse(const Duration(milliseconds: 250));
        expect(carouselChanges, <int>[1, 2]);
        expect(typewriterCompletions, 1);
        expect(find.text('10:15:38'), findsOneWidget);
        expect(countdownChanges.last, const Duration(seconds: 2));

        await tester.pumpWidget(const SizedBox.shrink());
        clock.resetReads();
        await elapse(const Duration(seconds: 3));
        expect(clock.reads, 0);
        visible.dispose();
      },
    );
  });
}
