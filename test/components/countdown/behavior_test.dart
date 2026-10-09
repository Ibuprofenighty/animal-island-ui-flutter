import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';
import '../../support/same_frame_rebuild.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);

/// Advances the clock and the test's timers together.
Future<void> _elapse(
  WidgetTester tester,
  FakeClock clock,
  Duration duration,
) async {
  clock.advance(duration);
  await tester.pump(duration);
}

/// The digits of every tile, in order.
List<String> _tiles(WidgetTester tester) => tester
    .widgetList<Text>(
      find.descendant(
        of: find.byType(AnimalCountdown),
        matching: find.byType(Text),
      ),
    )
    .map((Text text) => text.data!)
    .where((String data) => RegExp(r'^\d+$').hasMatch(data))
    .toList();

void main() {
  group('AnimalCountdown Behavior & Clock Tests (C28 / CTD01-CTD04)', () {
    testWidgets(
      'CTD01: remaining mode decrements and calls onFinish exactly once',
      (tester) async {
        final fakeClock = FakeClock(DateTime(2026, 9, 13, 12, 0, 0));
        int finishCount = 0;
        Duration? lastChange;

        await tester.pumpWidget(
          _app(
            AnimalCountdown.duration(
              duration: const Duration(seconds: 3),
              clock: fakeClock,
              onChange: (d) => lastChange = d,
              onFinish: () => finishCount++,
            ),
          ),
        );

        expect(finishCount, 0);
        await _elapse(tester, fakeClock, const Duration(seconds: 1));
        expect(lastChange, const Duration(seconds: 2));
        expect(finishCount, 0);
        await _elapse(tester, fakeClock, const Duration(seconds: 1));
        expect(lastChange, const Duration(seconds: 1));
        expect(finishCount, 0);
        await _elapse(tester, fakeClock, const Duration(seconds: 1));
        expect(finishCount, 1);
        expect(lastChange, const Duration(seconds: 1));

        await _elapse(tester, fakeClock, const Duration(seconds: 2));
        expect(finishCount, 1);
      },
    );

    testWidgets(
      'CTD02: targetTime with FakeClock provides deterministic stepping',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 12, 0, 0));
        int finishCount = 0;

        await tester.pumpWidget(
          _app(
            AnimalCountdown(
              targetTime: DateTime(2026, 9, 13, 12, 0, 10),
              format: AnimalCountdownFormat.seconds,
              clock: clock,
              onFinish: () => finishCount++,
            ),
          ),
        );
        expect(_tiles(tester), <String>[
          '10',
        ], reason: 'CDN02 tiles follow the real deadline');

        // The timer is three seconds late: the tiles follow the real
        // deadline instead of counting timer callbacks.
        clock.advance(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 1));
        expect(_tiles(tester), <String>[
          '07',
        ], reason: 'CDN02 tiles follow the real deadline');
        await _elapse(tester, clock, const Duration(seconds: 1));
        expect(_tiles(tester), <String>['06']);
        expect(finishCount, 0);

        clock.advance(const Duration(seconds: 6));
        await tester.pump(const Duration(seconds: 1));
        expect(_tiles(tester), <String>['00']);
        expect(finishCount, 1);
      },
    );

    testWidgets(
      'CDN01 the tiles round up and onFinish runs once exactly at the deadline',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 12));
        final List<Duration> changes = <Duration>[];
        int finishCount = 0;
        await tester.pumpWidget(
          _app(
            AnimalCountdown.duration(
              duration: const Duration(milliseconds: 1500),
              format: AnimalCountdownFormat.seconds,
              clock: clock,
              onChange: changes.add,
              onFinish: () => finishCount++,
            ),
          ),
        );
        expect(_tiles(tester), <String>['02']);

        await _elapse(tester, clock, const Duration(milliseconds: 499));
        expect(_tiles(tester), <String>['02']);
        await _elapse(tester, clock, const Duration(milliseconds: 1));
        expect(_tiles(tester), <String>['01']);
        expect(changes, <Duration>[const Duration(seconds: 1)]);

        await _elapse(tester, clock, const Duration(milliseconds: 999));
        expect(_tiles(tester), <String>['01']);
        expect(finishCount, 0, reason: '1 ms before the deadline');
        await _elapse(tester, clock, const Duration(milliseconds: 1));
        expect(_tiles(tester), <String>['00']);
        expect(finishCount, 1);
        expect(changes, <Duration>[const Duration(seconds: 1)]);

        await _elapse(tester, clock, const Duration(seconds: 3));
        expect(finishCount, 1);
      },
    );

    testWidgets('CTD03: initial zero duration invokes onFinish exactly once', (
      tester,
    ) async {
      final clock = FakeClock(DateTime(2026, 9, 13, 12));
      final ValueNotifier<int> finished = ValueNotifier<int>(0);
      addTearDown(finished.dispose);

      // onFinish rebuilds the parent: it must run after the frame, not
      // during the build that started the countdown.
      await tester.pumpWidget(
        _app(
          ValueListenableBuilder<int>(
            valueListenable: finished,
            builder: (context, count, _) => Column(
              children: [
                Text('finished $count'),
                AnimalCountdown.duration(
                  duration: Duration.zero,
                  clock: clock,
                  onFinish: () => finished.value++,
                ),
                AnimalCountdown.duration(
                  duration: const Duration(seconds: -5),
                  clock: clock,
                  onFinish: () => finished.value++,
                ),
                AnimalCountdown(
                  targetTime: DateTime(2026, 9, 13, 11),
                  clock: clock,
                  onFinish: () => finished.value++,
                ),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      await _elapse(tester, clock, const Duration(seconds: 5));
      expect(finished.value, 3);
      expect(find.text('finished 3'), findsOneWidget);
    });

    testWidgets(
      'Countdown recomputes its wall deadline after a background pause',
      (tester) async {
        final FakeClock clock = FakeClock(DateTime(2026, 9, 13, 12));
        int finishCount = 0;
        Duration? lastChange;

        await tester.pumpWidget(
          _app(
            AnimalCountdown(
              targetTime: DateTime(2026, 9, 13, 12, 0, 3),
              format: AnimalCountdownFormat.seconds,
              clock: clock,
              onChange: (Duration value) => lastChange = value,
              onFinish: () => finishCount++,
            ),
          ),
        );

        expect(find.text('03'), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        clock.advance(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('03'), findsOneWidget);
        expect(finishCount, 0);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(find.text('01'), findsOneWidget);
        expect(lastChange, const Duration(seconds: 1));
        expect(finishCount, 0);

        clock.advance(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('00'), findsOneWidget);
        expect(finishCount, 1);
      },
    );

    testWidgets(
      'CDN02 a deadline reached while hidden or in the background finishes on time',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 12));
        final ValueNotifier<bool> ticking = ValueNotifier<bool>(true);
        addTearDown(ticking.dispose);
        final List<Duration> changes = <Duration>[];
        int finishCount = 0;
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<bool>(
              valueListenable: ticking,
              builder: (context, enabled, _) => TickerMode(
                enabled: enabled,
                child: AnimalCountdown.duration(
                  duration: const Duration(minutes: 10),
                  format: AnimalCountdownFormat.minutesSeconds,
                  clock: clock,
                  onChange: changes.add,
                  onFinish: () => finishCount++,
                ),
              ),
            ),
          ),
        );

        // Five minutes in the background: no refresh, then the real time.
        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        await _elapse(tester, clock, const Duration(minutes: 5));
        expect(_tiles(tester), <String>['10', '00']);
        expect(changes, isEmpty);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(_tiles(tester), <String>['05', '00']);
        expect(changes, <Duration>[const Duration(minutes: 5)]);

        // Hidden by TickerMode, the deadline still finishes on time.
        ticking.value = false;
        await tester.pump();
        await _elapse(tester, clock, const Duration(minutes: 4, seconds: 59));
        expect(finishCount, 0);
        expect(changes, hasLength(1));
        await _elapse(tester, clock, const Duration(seconds: 1));
        expect(finishCount, 1);
        ticking.value = true;
        await tester.pump();
        expect(_tiles(tester), <String>['00', '00']);
        expect(finishCount, 1);
      },
    );

    testWidgets(
      'CDN02 replacing the target in the same frame drops the scheduled finish',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 12));
        int oldFinishes = 0;
        int newFinishes = 0;
        await tester.pumpWidget(
          _app(
            SameFrameRebuild(
              firstWidth: 100,
              // The first build starts at the deadline and schedules its
              // finish; the second, in the same frame, counts down instead.
              builder: (width) => width <= 100
                  ? AnimalCountdown.duration(
                      duration: Duration.zero,
                      clock: clock,
                      onFinish: () => oldFinishes++,
                    )
                  : AnimalCountdown(
                      targetTime: DateTime(2026, 9, 13, 12, 0, 2),
                      clock: clock,
                      onFinish: () => newFinishes++,
                    ),
            ),
          ),
        );
        await _elapse(tester, clock, const Duration(seconds: 1));
        expect(oldFinishes, 0);
        expect(newFinishes, 0);
        await _elapse(tester, clock, const Duration(seconds: 1));
        expect(oldFinishes, 0);
        expect(newFinishes, 1);

        // A countdown removed in the same frame never finishes either.
        int removedFinishes = 0;
        await tester.pumpWidget(
          _app(
            SameFrameRebuild(
              key: UniqueKey(),
              firstWidth: 100,
              builder: (width) => width <= 100
                  ? AnimalCountdown.duration(
                      duration: Duration.zero,
                      clock: clock,
                      onFinish: () => removedFinishes++,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        );
        await _elapse(tester, clock, const Duration(seconds: 1));
        expect(removedFinishes, 0);
      },
    );

    testWidgets(
      'CDN02 a later target change starts a new countdown and cancels the old deadline',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 12));
        final ValueNotifier<DateTime> target = ValueNotifier<DateTime>(
          DateTime(2026, 9, 13, 12, 0, 3),
        );
        addTearDown(target.dispose);
        final List<DateTime> finishedAt = <DateTime>[];
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<DateTime>(
              valueListenable: target,
              builder: (context, value, _) => AnimalCountdown(
                targetTime: value,
                format: AnimalCountdownFormat.seconds,
                clock: clock,
                onFinish: () => finishedAt.add(clock.now()),
              ),
            ),
          ),
        );
        await _elapse(tester, clock, const Duration(seconds: 2));
        target.value = DateTime(2026, 9, 13, 12, 0, 10);
        await tester.pump();
        expect(_tiles(tester), <String>['08']);
        await _elapse(tester, clock, const Duration(seconds: 1));
        expect(finishedAt, isEmpty, reason: 'the old deadline was cancelled');
        await _elapse(tester, clock, const Duration(seconds: 7));
        expect(finishedAt, <DateTime>[DateTime(2026, 9, 13, 12, 0, 10)]);

        // A new target after finishing counts down and finishes again.
        target.value = DateTime(2026, 9, 13, 12, 0, 12);
        await tester.pump();
        expect(_tiles(tester), <String>['02']);
        await _elapse(tester, clock, const Duration(seconds: 2));
        expect(finishedAt, hasLength(2));
      },
    );

    testWidgets(
      'CDN02 an earlier target set while the tiles are paused finishes at the new deadline',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 12));
        final ValueNotifier<Duration> duration = ValueNotifier<Duration>(
          const Duration(seconds: 10),
        );
        addTearDown(duration.dispose);
        int finishCount = 0;
        await tester.pumpWidget(
          _app(
            TickerMode(
              enabled: false,
              child: ValueListenableBuilder<Duration>(
                valueListenable: duration,
                builder: (context, value, _) => AnimalCountdown.duration(
                  duration: value,
                  clock: clock,
                  onFinish: () => finishCount++,
                ),
              ),
            ),
          ),
        );
        await _elapse(tester, clock, const Duration(seconds: 1));
        duration.value = const Duration(seconds: 3);
        await tester.pump();
        await _elapse(tester, clock, const Duration(milliseconds: 2999));
        expect(finishCount, 0);
        await _elapse(tester, clock, const Duration(milliseconds: 1));
        expect(
          finishCount,
          1,
          reason: 'CDN02 the deadline follows the new duration while paused',
        );
      },
    );

    testWidgets('CDN03 every format shows its largest unit unwrapped', (
      tester,
    ) async {
      final clock = FakeClock(DateTime(2026, 9, 13, 12));
      Future<List<String>> tilesFor(
        AnimalCountdownFormat format,
        Duration duration,
      ) async {
        await tester.pumpWidget(
          _app(
            AnimalCountdown.duration(
              key: UniqueKey(),
              duration: duration,
              format: format,
              clock: clock,
            ),
          ),
        );
        return _tiles(tester);
      }

      const Duration span = Duration(
        days: 400,
        hours: 5,
        minutes: 6,
        seconds: 7,
      );
      expect(
        await tilesFor(AnimalCountdownFormat.daysHoursMinutesSeconds, span),
        <String>['400', '05', '06', '07'],
      );
      expect(
        await tilesFor(
          AnimalCountdownFormat.hoursMinutesSeconds,
          const Duration(hours: 30, seconds: 1),
        ),
        <String>['30', '00', '01'],
      );
      expect(
        await tilesFor(
          AnimalCountdownFormat.minutesSeconds,
          const Duration(minutes: 90, seconds: 5),
        ),
        <String>['90', '05'],
      );
      expect(
        await tilesFor(
          AnimalCountdownFormat.seconds,
          const Duration(minutes: 2),
        ),
        <String>['120'],
      );
    });
  });
}
