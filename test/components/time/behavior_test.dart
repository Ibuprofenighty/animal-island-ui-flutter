import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);

void main() {
  group('AnimalTime Behavior & Semantics Tests (C29 / TIM01-TIM03)', () {
    testWidgets('TIM01: renders formatted time snapshot', (tester) async {
      await tester.pumpWidget(
        _app(AnimalTime(time: DateTime(2026, 9, 13, 9, 5, 8))),
      );

      expect(find.text('09:05:08'), findsOneWidget);
      // A fixed time never moves, however long the card is shown.
      await tester.pump(const Duration(minutes: 5));
      expect(find.text('09:05:08'), findsOneWidget);
    });

    testWidgets('TIM02: live mode ticks with clock updates', (tester) async {
      final fakeClock = FakeClock(DateTime(2026, 9, 13, 10, 15, 30));

      await tester.pumpWidget(_app(AnimalTime.live(clock: fakeClock)));

      expect(find.text('10:15:30'), findsOneWidget);

      fakeClock.advance(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('10:15:31'), findsOneWidget);
    });

    testWidgets(
      'Live time refreshes from wall clock after background and TickerMode pause',
      (tester) async {
        final clock = FakeClock(DateTime(2026, 9, 13, 10, 15, 30));
        final tickerNotifier = ValueNotifier<bool>(true);
        addTearDown(tickerNotifier.dispose);

        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<bool>(
              valueListenable: tickerNotifier,
              builder: (context, enabled, child) => TickerMode(
                enabled: enabled,
                child: AnimalTime.live(clock: clock),
              ),
            ),
          ),
        );
        expect(find.text('10:15:30'), findsOneWidget);

        tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
        clock.advance(const Duration(seconds: 3));
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('10:15:30'), findsOneWidget);

        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pump();
        expect(find.text('10:15:33'), findsOneWidget);

        tickerNotifier.value = false;
        await tester.pump();
        clock.advance(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('10:15:33'), findsOneWidget);

        tickerNotifier.value = true;
        await tester.pump();
        expect(find.text('10:15:35'), findsOneWidget);
      },
    );

    testWidgets(
      'TIM03: liveRegion defaults to false to prevent a11y flooding',
      (tester) async {
        await tester.pumpWidget(
          _app(AnimalTime(time: DateTime(2026, 9, 13, 14, 0, 0))),
        );

        final semantics = tester.widget<Semantics>(
          find
              .descendant(
                of: find.byType(AnimalTime),
                matching: find.byType(Semantics),
              )
              .first,
        );
        expect(semantics.properties.liveRegion, isFalse);
        expect(semantics.properties.value, '14:00:00');
      },
    );

    testWidgets('CLK01 a live card moves exactly at each wall-clock second', (
      tester,
    ) async {
      final clock = FakeClock(DateTime(2026, 9, 13, 10, 15, 30, 600));
      await tester.pumpWidget(_app(AnimalTime.live(clock: clock)));
      expect(find.text('10:15:30'), findsOneWidget);

      clock.advance(const Duration(milliseconds: 399));
      await tester.pump(const Duration(milliseconds: 399));
      expect(find.text('10:15:30'), findsOneWidget);
      clock.advance(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(
        find.text('10:15:31'),
        findsOneWidget,
        reason: 'CLK01 the card follows the wall-clock second',
      );
      clock.advance(const Duration(milliseconds: 999));
      await tester.pump(const Duration(milliseconds: 999));
      expect(find.text('10:15:31'), findsOneWidget);
      clock.advance(const Duration(milliseconds: 1));
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('10:15:32'), findsOneWidget);
    });

    testWidgets('CLK01 switching between a fixed and a live time takes effect '
        'at once', (tester) async {
      final clock = FakeClock(DateTime(2026, 9, 13, 10, 15, 30));
      final ValueNotifier<bool> live = ValueNotifier<bool>(false);
      addTearDown(live.dispose);
      await tester.pumpWidget(
        _app(
          ValueListenableBuilder<bool>(
            valueListenable: live,
            builder: (context, isLive, _) => isLive
                ? AnimalTime.live(clock: clock)
                : AnimalTime(time: DateTime(2026, 1, 2, 3, 4, 5)),
          ),
        ),
      );
      expect(find.text('03:04:05'), findsOneWidget);

      live.value = true;
      await tester.pump();
      expect(find.text('10:15:30'), findsOneWidget);
      clock.advance(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('10:15:31'), findsOneWidget);

      live.value = false;
      await tester.pump();
      expect(find.text('03:04:05'), findsOneWidget);
      clock.advance(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('03:04:05'), findsOneWidget);
    });

    testWidgets('CLK03 a live region announces at most once a minute', (
      tester,
    ) async {
      final clock = FakeClock(DateTime(2026, 9, 13, 10, 15, 30));
      await tester.pumpWidget(
        _app(AnimalTime.live(clock: clock, liveRegion: true)),
      );
      ({bool? liveRegion, String? value}) properties() {
        final semantics = tester
            .widget<Semantics>(
              find
                  .descendant(
                    of: find.byType(AnimalTime),
                    matching: find.byType(Semantics),
                  )
                  .first,
            )
            .properties;
        return (liveRegion: semantics.liveRegion, value: semantics.value);
      }

      expect(properties().liveRegion, isTrue);
      expect(properties().value, '10:15');

      clock.advance(const Duration(seconds: 29));
      await tester.pump(const Duration(seconds: 29));
      expect(find.text('10:15:59'), findsOneWidget);
      expect(properties().value, '10:15');
      clock.advance(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(properties().value, '10:16');
    });
  });
}
