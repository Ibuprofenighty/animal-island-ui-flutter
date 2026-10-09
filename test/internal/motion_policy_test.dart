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
                    outcomes['reduces_motion'] =
                        AnimalMotionPolicy.reducesMotion(context);
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
        expect(outcomes['reduces_motion'], isFalse);

        await pumpPolicy(disableAnimations: true);
        expect(outcomes['normal'], isFalse);
        expect(outcomes['reduces_motion'], isTrue);
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
        final AnimalMotionScheduler scheduler = AnimalMotionScheduler(
          clock: clock,
        );
        final List<DateTime> readouts = <DateTime>[];
        final List<Duration> ticks = <Duration>[];
        final AnimalMotionRegistration readout = scheduler.scheduleReadout(
          eligible: true,
          nextReadout: () => const Duration(seconds: 1),
          onReadout: () => readouts.add(clock.now()),
        );
        final AnimalPeriodicRegistration decorative = scheduler
            .schedulePeriodic(
              interval: const Duration(seconds: 1),
              eligible: true,
              onTick: ticks.add,
            );

        // Registered while backgrounded: nothing runs, however long it waits.
        clock.advance(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 3));
        expect(readouts, isEmpty);
        expect(ticks, isEmpty);

        // Resuming reads the wall clock once; the missed seconds are not
        // replayed.
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(readouts, <DateTime>[DateTime(2026, 9, 12, 12, 0, 3)]);
        clock.advance(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(readouts, hasLength(2));
        expect(ticks, <Duration>[const Duration(seconds: 1)]);

        // A second background pause also resumes without catch-up.
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        clock.advance(const Duration(seconds: 5));
        await tester.pump(const Duration(seconds: 5));
        expect(readouts, hasLength(2));
        expect(ticks, hasLength(1));
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(readouts, hasLength(3));
        expect(readouts.last, DateTime(2026, 9, 12, 12, 0, 9));
        clock.advance(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(ticks, <Duration>[
          const Duration(seconds: 1),
          const Duration(seconds: 1),
        ]);

        // Becoming eligible only schedules: the component refreshes itself
        // in that call.
        readout.setEligible(false);
        decorative.setEligible(false);
        clock.advance(const Duration(seconds: 4));
        await tester.pump(const Duration(seconds: 4));
        final int before = readouts.length;
        readout.setEligible(true);
        expect(readouts, hasLength(before));
        clock.advance(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(readouts, hasLength(before + 1));

        scheduler.dispose();
      },
    );

    testWidgets(
      'readouts follow their next boundary and a deadline fires once in the background',
      (WidgetTester tester) async {
        final FakeClock clock = FakeClock(DateTime(2026, 9, 12, 12));
        final AnimalMotionScheduler scheduler = AnimalMotionScheduler(
          clock: clock,
        );
        final List<Duration> readouts = <Duration>[];
        Duration? next = const Duration(milliseconds: 300);
        scheduler.scheduleReadout(
          eligible: true,
          nextReadout: () => next,
          onReadout: () => readouts.add(clock.monotonicNow),
        );
        Future<void> elapse(Duration duration) async {
          clock.advance(duration);
          await tester.pump(duration);
        }

        await elapse(const Duration(milliseconds: 299));
        expect(readouts, isEmpty);
        await elapse(const Duration(milliseconds: 1));
        expect(readouts, <Duration>[const Duration(milliseconds: 300)]);
        next = null;
        await elapse(const Duration(milliseconds: 300));
        expect(readouts, hasLength(2), reason: 'the armed readout still runs');
        await elapse(const Duration(seconds: 5));
        expect(readouts, hasLength(2), reason: 'a null delay ends readouts');

        // A deadline whose timer fires early waits again; it fires once,
        // also while the app is in the background.
        Duration deadline = clock.monotonicNow + const Duration(seconds: 1);
        int due = 0;
        final AnimalMotionRegistration task = scheduler.scheduleDeadline(
          eligible: true,
          remaining: () => deadline - clock.monotonicNow,
          onDue: () => due++,
        );
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        deadline += const Duration(seconds: 1);
        await elapse(const Duration(seconds: 1));
        expect(due, 0);
        await elapse(const Duration(milliseconds: 999));
        expect(due, 0);
        await elapse(const Duration(milliseconds: 1));
        expect(due, 1);
        await elapse(const Duration(seconds: 5));
        expect(due, 1);

        // Restarting reads the deadline again.
        deadline = clock.monotonicNow + const Duration(seconds: 2);
        task.restart();
        await elapse(const Duration(seconds: 2));
        expect(due, 2);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        scheduler.dispose();
      },
    );

    testWidgets(
      'a repeating animation stops in the background and rests while ineligible',
      (WidgetTester tester) async {
        final AnimationController controller = AnimationController(
          vsync: const TestVSync(),
          duration: const Duration(seconds: 1),
        );
        final AnimalMotionScheduler scheduler = AnimalMotionScheduler();
        final AnimalMotionRegistration motion = scheduler.scheduleAnimation(
          controller,
          eligible: false,
          restValue: 0.5,
        );
        expect(controller.value, 0.5);
        expect(controller.isAnimating, isFalse);

        for (int i = 0; i < 100; i++) {
          motion.setEligible(true);
          expect(controller.isAnimating, isTrue);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.paused,
          );
          expect(controller.isAnimating, isFalse);
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.resumed,
          );
          expect(controller.isAnimating, isTrue);
          motion.setEligible(false);
          expect(controller.isAnimating, isFalse);
          expect(controller.value, 0.5);
        }
        expect(tester.binding.transientCallbackCount, 0);

        // A task mounted in the background starts when the app resumes.
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.inactive,
        );
        motion.setEligible(true);
        expect(controller.isAnimating, isFalse);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        expect(controller.isAnimating, isTrue);

        scheduler.dispose();
        expect(controller.isAnimating, isFalse);
        controller.dispose();
      },
    );

    testWidgets(
      'a disposed scheduler rejects new work and its registrations stop',
      (WidgetTester tester) async {
        final AnimalMotionScheduler scheduler = AnimalMotionScheduler();
        int ticks = 0;
        final AnimalPeriodicRegistration periodic = scheduler.schedulePeriodic(
          interval: const Duration(milliseconds: 10),
          eligible: true,
          onTick: (_) => ticks++,
        );
        expect(
          () => scheduler.schedulePeriodic(
            interval: Duration.zero,
            eligible: true,
            onTick: (_) {},
          ),
          throwsArgumentError,
        );

        scheduler.dispose();
        scheduler.dispose();
        await tester.pump(const Duration(milliseconds: 50));
        expect(ticks, 0);
        expect(() => periodic.setEligible(false), throwsStateError);
        expect(() => periodic.restart(), throwsStateError);
        expect(
          () => periodic.updateInterval(const Duration(seconds: 1)),
          throwsStateError,
        );
        periodic.dispose();
        expect(
          () => scheduler.schedulePeriodic(
            interval: Duration.zero,
            eligible: true,
            onTick: (_) {},
          ),
          throwsStateError,
        );
        expect(
          () => scheduler.scheduleDeadline(
            eligible: true,
            remaining: () => Duration.zero,
            onDue: () {},
          ),
          throwsStateError,
        );
        expect(() => scheduler.updateClock(FakeClock()), throwsStateError);
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
                        child: AnimalTime.live(
                          visible: isVisible,
                          clock: clock,
                        ),
                      ),
                      Offstage(
                        offstage: !isVisible,
                        child: AnimalCountdown.duration(
                          duration: const Duration(seconds: 10),
                          format: AnimalCountdownFormat.seconds,
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

        // The readouts move at the next whole second, 750 ms later; the
        // decorative work restarts its full cadence.
        clock.resetReads();
        await elapse(const Duration(milliseconds: 749));
        expect(clock.reads, 0);
        await elapse(const Duration(milliseconds: 1));
        expect(find.text('10:15:38'), findsOneWidget);
        expect(countdownChanges.last, const Duration(seconds: 2));
        await elapse(const Duration(milliseconds: 249));
        expect(carouselChanges, pausedCarousel);
        expect(typewriterCompletions, 0);
        await elapse(const Duration(milliseconds: 1));
        await elapse(const Duration(milliseconds: 250));
        expect(carouselChanges, <int>[1, 2]);
        expect(typewriterCompletions, 1);

        await tester.pumpWidget(const SizedBox.shrink());
        clock.resetReads();
        await elapse(const Duration(seconds: 3));
        expect(clock.reads, 0);
        visible.dispose();
      },
    );
  });
}
