import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));
void main() {
  testWidgets(
    'numeric variants preserve opaque content and independent timelines',
    (t) async {
      final semantics = t.ensureSemantics();
      try {
        final upChild = GlobalKey();
        final downChild = GlobalKey();
        late StateSetter rebuild;
        var island = false;
        var now = DateTime(2026, 10, 14);
        final deadline = now.add(const Duration(seconds: 10));
        DateTime clock() => now;
        double value = 0;
        Duration? remaining;
        var done = 0;
        Widget probe(Key key) =>
            StatefulBuilder(key: key, builder: (_, _) => const Text('opaque'));
        await t.pumpWidget(
          host(
            StatefulBuilder(
              builder: (_, set) {
                rebuild = set;
                return Column(
                  children: [
                    IslandCountUp(
                      end: 100,
                      isCounting: true,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear,
                      semanticLabel: 'Score',
                      prefix: probe(upChild),
                      variant: island
                          ? IslandCountUpVariant.island
                          : IslandCountUpVariant.normal,
                      onUpdate: (v) => value = v,
                      onComplete: (_) {
                        done++;
                        return null;
                      },
                    ),
                    IslandCountdown(
                      value: deadline,
                      now: clock,
                      prefix: probe(downChild),
                      variant: island
                          ? IslandCountdownVariant.island
                          : IslandCountdownVariant.normal,
                      onChange: (v) => remaining = v,
                    ),
                  ],
                );
              },
            ),
          ),
        );
        final upState = upChild.currentState;
        final downState = downChild.currentState;
        await t.pump();
        now = now.add(const Duration(seconds: 2));
        await t.pump(const Duration(milliseconds: 250));
        expect(value, closeTo(25, .01));
        expect(remaining, const Duration(seconds: 8));
        rebuild(() => island = true);
        await t.pump();
        expect(identical(upChild.currentState, upState), isTrue);
        expect(identical(downChild.currentState, downState), isTrue);
        expect(value, closeTo(25, .01));
        expect(done, 0);
        await t.pump(const Duration(milliseconds: 750));
        expect(value, 100);
        expect(done, 1);
        expect(remaining, const Duration(seconds: 8));
        final node = t.getSemantics(find.byType(IslandCountUp));
        expect(node.label, 'Score');
        expect(node.value, '100');
        expect(node.label.contains('opaque'), isFalse);
        await t.pumpWidget(const SizedBox());
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('pause resumes the same timeline and completes once', (t) async {
    var running = true;
    late StateSetter update;
    double last = 0;
    var completions = 0;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (c, s) {
            update = s;
            return IslandCountUp(
              end: 100,
              isCounting: running,
              curve: Curves.linear,
              duration: const Duration(seconds: 2),
              onUpdate: (v) => last = v,
              onComplete: (_) {
                completions++;
                return null;
              },
            );
          },
        ),
      ),
    );
    await t.pump();
    await t.pump(const Duration(milliseconds: 500));
    expect(last, closeTo(25, .01));
    update(() => running = false);
    await t.pump();
    final paused = last;
    await t.pump(const Duration(seconds: 5));
    expect(last, paused);
    expect(completions, 0);
    update(() => running = true);
    await t.pump();
    await t.pump();
    await t.pump(const Duration(milliseconds: 1500));
    expect(last, 100);
    expect(completions, 1);
    await t.pump(const Duration(seconds: 3));
    expect(completions, 1);
  });
  testWidgets(
    'reset during callback supersedes completion and borrowed controller survives',
    (t) async {
      final controller = IslandCountUpController();
      var resetOnce = false;
      var completions = 0;
      double last = 0;
      await t.pumpWidget(
        host(
          IslandCountUp(
            end: 100,
            isCounting: true,
            curve: Curves.linear,
            controller: controller,
            duration: const Duration(seconds: 1),
            onUpdate: (v) {
              last = v;
              if (v == 100 && !resetOnce) {
                resetOnce = true;
                controller.reset(50);
              }
            },
            onComplete: (_) {
              completions++;
              return null;
            },
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(completions, 0);
      expect(find.text('50'), findsOneWidget);
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(last, closeTo(75, .01));
      await t.pump(const Duration(milliseconds: 500));
      expect(completions, 1);
      await t.pumpWidget(const SizedBox());
      controller.reset(10);
      controller.dispose();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'target changes reset, formatting updates do not restart, interval quantizes',
    (t) async {
      var end = 100.0, separator = '';
      late StateSetter update;
      double last = 0;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandCountUp(
                start: 0,
                end: end,
                isCounting: true,
                curve: Curves.linear,
                duration: const Duration(seconds: 2),
                updateInterval: const Duration(milliseconds: 500),
                decimalPlaces: 1,
                decimalSeparator: separator,
                onUpdate: (v) => last = v,
              );
            },
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 750));
      expect(last, 25);
      update(() => separator = ',');
      await t.pump();
      expect(find.text('25,0'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 250));
      expect(last, 50);
      update(() => end = 200);
      await t.pump();
      expect(find.text('0,0'), findsOneWidget);
      await t.pump();
      await t.pump(const Duration(milliseconds: 1000));
      expect(last, 100);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'repeat delay is canceled on pause and disposal; zero duration finishes outside build',
    (t) async {
      var running = true;
      late StateSetter update;
      var completions = 0;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandCountUp(
                end: 1320.5,
                isCounting: running,
                duration: Duration.zero,
                decimalPlaces: 1,
                thousandsSeparator: ',',
                celebrate: true,
                celebration: const Text('Done'),
                onComplete: (_) {
                  completions++;
                  return const IslandCountUpRepeat(delay: Duration(seconds: 1));
                },
              );
            },
          ),
        ),
      );
      await t.pump();
      expect(find.text('1,320.5'), findsOneWidget);
      expect(completions, 1);
      update(() => running = false);
      await t.pump();
      await t.pump(const Duration(seconds: 2));
      expect(completions, 1);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 2));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'automatic decimals handle scientific notation and callbacks stay instance-local',
    (t) async {
      var done = 0;
      await t.pumpWidget(
        host(
          Row(
            children: [
              IslandCountUp(
                end: .0000001,
                isCounting: true,
                duration: Duration.zero,
                onComplete: (_) {
                  done++;
                  return null;
                },
              ),
              const IslandCountUp(start: 10, end: 99),
            ],
          ),
        ),
      );
      await t.pump();
      expect(find.text('0.0000001'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(done, 1);
    },
  );
}
