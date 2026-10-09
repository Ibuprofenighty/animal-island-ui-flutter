import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
// The stripe painter is package-internal; tests observe its controller.
import 'package:animal_island_ui/src/components/progress/progress_painter.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);

AnimalCandyStripePainter _stripes(WidgetTester tester) => tester
    .widgetList<CustomPaint>(
      find.descendant(
        of: find.byType(AnimalProgress),
        matching: find.byType(CustomPaint),
      ),
    )
    .map((CustomPaint paint) => paint.painter)
    .whereType<AnimalCandyStripePainter>()
    .single;

void main() {
  group('AnimalProgress Behavior & Motion Tests (C24 / PRG01-PRG04)', () {
    testWidgets('PRG01: renders linear progress and formats percentage text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          AnimalProgress(
            percent: 0.65,
            infoPosition: AnimalProgressInfoPosition.right,
          ),
        ),
      );

      expect(find.text('65%'), findsOneWidget);
    });

    testWidgets('PRG02: renders inside percentage text for middle/large bars', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 300,
            child: AnimalProgress(
              percent: 0.80,
              size: AnimalProgressSize.large,
              infoPosition: AnimalProgressInfoPosition.inside,
            ),
          ),
        ),
      );

      expect(find.text('80%'), findsOneWidget);
      // The label sits over the fill, not over the remaining track.
      final Rect label = tester.getRect(find.text('80%'));
      final Rect bar = tester.getRect(find.byType(AnimalProgress));
      expect(label.right, lessThanOrEqualTo(bar.left + bar.width * 0.8));
    });

    testWidgets(
      'PRG03: AnimalProgress.circle renders circular progress with custom stroke and size',
      (tester) async {
        await tester.pumpWidget(
          _app(
            AnimalProgress.circle(
              percent: 0.42,
              diameter: 100.0,
              style: AnimalProgressStyle(strokeWidth: 8.0),
            ),
          ),
        );

        expect(find.text('42%'), findsOneWidget);
        expect(
          tester.getSize(find.byType(AnimalProgress)),
          const Size.square(100),
        );
      },
    );

    testWidgets('PRG04: barber-pole animation respects status and TickerMode', (
      tester,
    ) async {
      final tickerNotifier = ValueNotifier<bool>(true);
      addTearDown(tickerNotifier.dispose);

      await tester.pumpWidget(
        _app(
          ValueListenableBuilder<bool>(
            valueListenable: tickerNotifier,
            builder: (context, enabled, _) => TickerMode(
              enabled: enabled,
              child: AnimalProgress(
                percent: 0.5,
                status: AnimalProgressStatus.active,
              ),
            ),
          ),
        ),
      );
      final AnimationController stripes =
          _stripes(tester).phase as AnimationController;
      expect(stripes.isAnimating, isTrue);
      await tester.pump(const Duration(milliseconds: 200));
      expect(stripes.value, greaterThan(0));

      tickerNotifier.value = false;
      await tester.pump();
      expect(stripes.isAnimating, isFalse);
      expect(stripes.value, 0);
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.binding.transientCallbackCount, 0);
    });

    testWidgets(
      'PRO01 out-of-range percents show as 0 or 1 and labels round down',
      (tester) async {
        final List<double> formatted = <double>[];
        Future<String> labelOf(double percent) async {
          await tester.pumpWidget(_app(AnimalProgress(percent: percent)));
          final Semantics semantics = tester.widget<Semantics>(
            find
                .descendant(
                  of: find.byType(AnimalProgress),
                  matching: find.byType(Semantics),
                )
                .first,
          );
          return semantics.properties.value!;
        }

        expect(await labelOf(-0.5), '0%');
        expect(await labelOf(0), '0%');
        expect(await labelOf(0.01), '1%');
        expect(await labelOf(0.29), '29%');
        expect(await labelOf(0.5), '50%');
        expect(await labelOf(0.999), '99%');
        expect(await labelOf(1), '100%');
        expect(await labelOf(1.5), '100%');

        await tester.pumpWidget(
          _app(
            AnimalProgress.circle(
              percent: 7,
              format: (double value) {
                formatted.add(value);
                return 'done';
              },
            ),
          ),
        );
        expect(formatted.toSet(), <double>{1.0});
        expect(find.text('done'), findsOneWidget);
      },
    );

    test('PRO01 a percent that is not finite is rejected', () {
      for (final double percent in <double>[
        double.nan,
        double.infinity,
        double.negativeInfinity,
      ]) {
        expect(() => AnimalProgress(percent: percent), throwsArgumentError);
        expect(
          () => AnimalProgress.circle(percent: percent),
          throwsArgumentError,
        );
      }
      expect(
        () => AnimalProgress.circle(percent: 0.5, diameter: -1),
        throwsArgumentError,
      );
    });

    testWidgets('PRO02 the bar and the ring share status colors and labels', (
      tester,
    ) async {
      String format(double value) => '${(value * 10).round()} of 10';
      for (final AnimalProgressStatus status in AnimalProgressStatus.values) {
        await tester.pumpWidget(
          _app(
            Column(
              children: [
                AnimalProgress(percent: 0.3, status: status, format: format),
                AnimalProgress.circle(
                  percent: 0.3,
                  status: status,
                  format: format,
                ),
              ],
            ),
          ),
        );
        expect(find.text('3 of 10'), findsNWidgets(2));
        final Color bar = _stripes(tester).fillColor;
        final Color ring = tester
            .widgetList<CustomPaint>(find.byType(CustomPaint))
            .map((CustomPaint paint) => paint.painter)
            .whereType<AnimalCircularProgressPainter>()
            .single
            .fillColor;
        expect(ring, bar);
      }
    });

    testWidgets(
      'PRO03 one stripe controller survives 100 activity and motion-policy cycles',
      (tester) async {
        final ValueNotifier<(bool, bool, bool)> flags =
            ValueNotifier<(bool, bool, bool)>((true, true, false));
        addTearDown(flags.dispose);
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<(bool, bool, bool)>(
              valueListenable: flags,
              builder: (context, value, _) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: value.$3),
                child: TickerMode(
                  enabled: value.$2,
                  child: AnimalProgress(
                    percent: 0.6,
                    status: value.$1
                        ? AnimalProgressStatus.active
                        : AnimalProgressStatus.normal,
                  ),
                ),
              ),
            ),
          ),
        );
        final Animation<double> controller = _stripes(tester).phase;

        for (int cycle = 0; cycle < 100; cycle++) {
          for (final (bool, bool, bool) state in <(bool, bool, bool)>[
            (false, true, false),
            (true, true, false),
            (true, false, false),
            (true, true, false),
            (true, true, true),
            (true, true, false),
          ]) {
            flags.value = state;
            await tester.pump(const Duration(milliseconds: 16));
            final bool running = state.$1 && state.$2 && !state.$3;
            expect(identical(_stripes(tester).phase, controller), isTrue);
            expect(tester.takeException(), isNull);
            expect(
              tester.binding.transientCallbackCount,
              running ? greaterThan(0) : 0,
            );
          }
        }

        // Reduced motion shows the complete static state.
        flags.value = (true, true, true);
        await tester.pump();
        expect(_stripes(tester).phase.value, 0);
        expect(find.text('60%'), findsOneWidget);
      },
    );
  });
}
