import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

int get ticking => SchedulerBinding.instance.transientCallbackCount;

Widget host(Widget child) => MaterialApp(
  theme: IslandTheme.create(),
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);

void main() {
  testWidgets('ocean wave follows an ancestor paint transform on and off '
      'screen without being rebuilt', (t) async {
    final x = ValueNotifier<double>(2000);
    addTearDown(x.dispose);
    await t.pumpWidget(
      host(
        ValueListenableBuilder<double>(
          valueListenable: x,
          builder: (context, value, child) =>
              Transform.translate(offset: Offset(value, 0), child: child),
          child: const SizedBox(
            width: 300,
            child: IslandDivider(variant: IslandDividerVariant.oceanWave),
          ),
        ),
      ),
    );
    await t.pump();
    await t.pump();
    expect(ticking, 0, reason: 'translated outside the screen');
    x.value = 0;
    await t.pump();
    await t.pump();
    expect(ticking, 1, reason: 'moved on screen by the transform alone');
    x.value = 2000;
    await t.pump();
    await t.pump();
    expect(ticking, 0, reason: 'moved off screen by the transform alone');
  });

  testWidgets('countdown shake stops while scrolled out of its viewport', (
    t,
  ) async {
    final now = DateTime(2026, 1, 1, 12);
    final scroll = ScrollController();
    addTearDown(scroll.dispose);
    await t.pumpWidget(
      host(
        SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              IslandCountdown(
                value: now.add(const Duration(seconds: 4)),
                now: () => now,
                shake: const IslandCountdownShake(),
              ),
              const SizedBox(height: 3000),
            ],
          ),
        ),
      ),
    );
    await t.pump();
    await t.pump();
    expect(ticking, 1, reason: 'shaking while shown');
    scroll.jumpTo(2000);
    await t.pump();
    await t.pump();
    expect(ticking, 0, reason: 'scrolled out');
    scroll.jumpTo(0);
    await t.pump();
    await t.pump();
    expect(ticking, 1, reason: 'scrolled back');
    await t.pumpWidget(const SizedBox());
  });
}
