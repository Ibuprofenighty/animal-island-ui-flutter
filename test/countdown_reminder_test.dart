import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

const _start = Duration(seconds: 61);

class _Probe {
  _Probe(this.t);
  final WidgetTester t;
  var now = DateTime(2026, 11, 17, 12);
  late final deadline = now.add(_start);
  late StateSetter rebuild;
  var reduced = false;

  Future<void> mount(Widget Function(DateTime Function() clock) build) =>
      t.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              rebuild = set;
              return MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: Scaffold(
                  body: Align(
                    alignment: Alignment.topLeft,
                    child: build(() => now),
                  ),
                ),
              );
            },
          ),
        ),
      );

  /// Moves the clock so the countdown shows [left] and lets the 250ms poll
  /// and the 200ms colour change complete.
  Future<void> showing(Duration left) async {
    now = deadline.subtract(left);
    await t.pump(const Duration(milliseconds: 250));
    await t.pump(const Duration(milliseconds: 250));
  }

  Color colon() => t.widget<Text>(find.text(':').first).style!.color!;

  Iterable<Color?> borders() => t
      .widgetList<Container>(
        find.descendant(
          of: find.byType(IslandCountdown),
          matching: find.byType(Container),
        ),
      )
      .map((c) => c.decoration)
      .whereType<BoxDecoration>()
      .where((d) => d.gradient != null)
      .map((d) => (d.border as Border?)?.top.color);

  /// Horizontal offset and rotation of the shaking digit group.
  (double, double) group() {
    final transform = t
        .widgetList<Transform>(
          find.ancestor(
            of: find.text(':').first,
            matching: find.byType(Transform),
          ),
        )
        .firstWhere((w) => w.alignment == Alignment.center)
        .transform;
    return (transform.getTranslation().x, transform.entry(1, 0));
  }
}

void main() {
  testWidgets('digits, colon and separators share the Time clock ink', (
    t,
  ) async {
    final p = _Probe(t);
    await p.mount(
      (clock) =>
          IslandCountdown(value: p.deadline, now: clock, format: 'mm 分 ss'),
    );
    await t.pump();
    // Reference #8b7355 deepened in hue to the Time clock ink #836b4e.
    const ink = Color(0xff836b4e);
    expect(t.widget<Text>(find.text(' 分 ')).style!.color, ink);
    final digits = find.descendant(
      of: find.byType(IslandCountdown),
      matching: find.byType(RichText),
    );
    for (final paragraph in t.widgetList<RichText>(digits)) {
      expect(paragraph.text.style?.color, ink);
    }
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('semanticLabel names the timer beside its value', (t) async {
    final handle = t.ensureSemantics();
    final p = _Probe(t);
    await p.mount(
      (clock) => IslandCountdown(
        value: p.deadline,
        now: clock,
        format: 'mm:ss',
        semanticLabel: '默认提醒倒计时',
      ),
    );
    await t.pump();
    expect(find.bySemanticsLabel('默认提醒倒计时'), findsOneWidget);
    expect(t.getSemantics(find.bySemanticsLabel('默认提醒倒计时')).value, '01:01');
    await t.pumpWidget(const SizedBox());
    handle.dispose();
  });

  testWidgets(
    'default reminders turn orange at 60 and red at 10 displayed seconds, including bordered plates',
    (t) async {
      final p = _Probe(t);
      await p.mount(
        (clock) => IslandCountdown(
          value: p.deadline,
          now: clock,
          format: 'mm:ss',
          bordered: true,
          reminders: IslandCountdownReminder.defaults,
        ),
      );
      await t.pump();
      final normal = p.colon();
      expect(normal, isNot(const Color(0xffa55d05)));
      final normalBorders = p.borders().toSet();
      // 60.001s still displays 61 → 01:01, no reminder yet.
      await p.showing(const Duration(seconds: 60, milliseconds: 1));
      expect(p.colon(), normal);
      await p.showing(const Duration(seconds: 60));
      expect(p.colon(), const Color(0xffa55d05));
      expect(p.borders().toSet(), {const Color(0xffa55d05)});
      await p.showing(const Duration(seconds: 10, milliseconds: 1));
      expect(p.colon(), const Color(0xffa55d05));
      await p.showing(const Duration(seconds: 10));
      expect(p.colon(), const Color(0xffc44043));
      expect(p.borders().toSet(), {const Color(0xffc44043)});
      // A later deadline leaves the reminder range again.
      p.rebuild(() {});
      await p.showing(const Duration(seconds: 61));
      expect(p.colon(), normal);
      expect(p.borders().toSet(), normalBorders);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'custom reminders are order independent, smallest threshold wins, empty list keeps colours',
    (t) async {
      final p = _Probe(t);
      const berry = Color(0xffb25770), brown = Color(0xff9a6a38);
      await p.mount(
        (clock) => Column(
          children: [
            IslandCountdown(
              value: p.deadline,
              now: clock,
              format: 'mm:ss',
              reminders: const [
                IslandCountdownReminder(
                  threshold: Duration(seconds: 5),
                  color: berry,
                ),
                IslandCountdownReminder(
                  threshold: Duration(seconds: 20),
                  color: brown,
                ),
              ],
            ),
            IslandCountdown(value: p.deadline, now: clock, format: 'mm:ss'),
          ],
        ),
      );
      await t.pump();
      Color plain() => t.widget<Text>(find.text(':').last).style!.color!;
      final normal = plain();
      await p.showing(const Duration(seconds: 20));
      expect(p.colon(), brown);
      await p.showing(const Duration(seconds: 5));
      expect(p.colon(), berry);
      expect(plain(), normal);
      // Unbordered plates keep no border.
      expect(p.borders().every((c) => c == null), isTrue);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'shake runs the reference burst in the last five seconds, escalates at three and stops at zero',
    (t) async {
      final p = _Probe(t);
      var finishes = 0;
      await p.mount(
        (clock) => IslandCountdown(
          value: p.deadline,
          now: clock,
          format: 'mm:ss',
          shake: const IslandCountdownShake(),
          onFinish: () => finishes++,
        ),
      );
      await t.pump();
      await p.showing(const Duration(seconds: 6));
      await t.pump(const Duration(milliseconds: 60));
      expect(p.group().$1, 0);

      await p.showing(const Duration(seconds: 5));
      final normal = <(double, double)>[];
      for (var i = 0; i < 100; i++) {
        await t.pump(const Duration(milliseconds: 10));
        normal.add(p.group());
      }
      final xs = normal.map((s) => s.$1).toList();
      expect(xs.reduce((a, b) => a < b ? a : b), closeTo(-1.5, 1e-6));
      expect(xs.reduce((a, b) => a > b ? a : b), closeTo(1.5, 1e-6));
      // The burst occupies 30% of the 1000ms period; the rest is still.
      expect(xs.where((x) => x == 0).length, inInclusiveRange(69, 72));
      // Rotation follows displacement: 0.6 degrees at the 1.5px extreme.
      final extreme = normal.firstWhere(
        (s) => s.$1 == xs.reduce((a, b) => a > b ? a : b),
      );
      expect(extreme.$2, closeTo(0.6 * 3.141592653589793 / 180, 1e-6));

      await p.showing(const Duration(seconds: 3));
      final x = <double>[];
      for (var i = 0; i < 65; i++) {
        await t.pump(const Duration(milliseconds: 10));
        x.add(p.group().$1.abs());
      }
      expect(x.reduce((a, b) => a > b ? a : b), closeTo(2.5, .05));

      await p.showing(Duration.zero);
      expect(finishes, 1);
      expect(p.group().$1, 0);
      await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'reduced motion removes the shake but keeps reminder colours; null shake never moves',
    (t) async {
      final p = _Probe(t)..reduced = true;
      await p.mount(
        (clock) => IslandCountdown(
          value: p.deadline,
          now: clock,
          format: 'mm:ss',
          reminders: IslandCountdownReminder.defaults,
          shake: const IslandCountdownShake(),
        ),
      );
      await t.pump();
      await p.showing(const Duration(seconds: 4));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 37));
        expect(p.group().$1, 0);
      }
      expect(p.colon(), const Color(0xffc44043));
      // Settles because no shake ticker runs.
      await t.pumpAndSettle();
      p.rebuild(() => p.reduced = false);
      await t.pump();
      final moved = <double>[];
      for (var i = 0; i < 30; i++) {
        await t.pump(const Duration(milliseconds: 10));
        moved.add(p.group().$1.abs());
      }
      expect(moved.any((v) => v > 0), isTrue);
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('custom shake threshold and disabled escalation', (t) async {
    final p = _Probe(t);
    await p.mount(
      (clock) => IslandCountdown(
        value: p.deadline,
        now: clock,
        format: 'mm:ss',
        shake: const IslandCountdownShake(
          threshold: Duration(seconds: 8),
          urgentThreshold: Duration.zero,
          distance: 4,
          rotation: 0,
        ),
      ),
    );
    await t.pump();
    await p.showing(const Duration(seconds: 8));
    final x = <double>[];
    for (var i = 0; i < 100; i++) {
      await t.pump(const Duration(milliseconds: 10));
      x.add(p.group().$1.abs());
      expect(p.group().$2, 0);
    }
    expect(x.reduce((a, b) => a > b ? a : b), closeTo(4, .05));
    await p.showing(const Duration(seconds: 1));
    x.clear();
    for (var i = 0; i < 100; i++) {
      await t.pump(const Duration(milliseconds: 10));
      x.add(p.group().$1.abs());
    }
    expect(x.reduce((a, b) => a > b ? a : b), closeTo(4, .05));
    await t.pumpWidget(const SizedBox());
  });
}
