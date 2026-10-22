import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show foreground, readable, fill;

void opaque(WidgetTester t, Finder target) {
  expect(target, findsOneWidget);
  for (final w in t.widgetList<Opacity>(
    find.ancestor(of: target, matching: find.byType(Opacity)),
  )) {
    expect(w.opacity, 1);
  }
  for (final w in t.widgetList<FadeTransition>(
    find.ancestor(of: target, matching: find.byType(FadeTransition)),
  )) {
    expect(w.opacity.value, 1);
  }
}

Widget host(Widget child) => MaterialApp(
  theme: IslandTheme.create(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets(
    'all Badge palettes stay readable at full text size from first frame; wrapped child survives zero',
    (t) async {
      for (final color in IslandColorway.values) {
        await t.pumpWidget(
          host(
            IslandBadge(
              key: ValueKey(color),
              text: '8',
              color: color,
              size: IslandBadgeSize.small,
            ),
          ),
        );
        for (final ms in [0, 16, 40, 70, 100, 100]) {
          await t.pump(Duration(milliseconds: ms));
          opaque(t, find.text('8'));
          readable(foreground(t, '8'), fill(t, find.text('8')));
          final text = t.renderObject<RenderParagraph>(find.text('8'));
          expect((text.text as TextSpan).style!.fontSize, 9);
          for (final transform in t.widgetList<Transform>(
            find.ancestor(of: find.text('8'), matching: find.byType(Transform)),
          )) {
            expect(transform.transform.storage[0], greaterThanOrEqualTo(1));
          }
        }
      }
      var count = 0;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandBadge(count: count, child: const _Probe());
            },
          ),
        ),
      );
      final state = t.state(find.byType(_Probe));
      await t.tap(find.text('value 0'));
      await t.pump();
      for (final value in [1, 0, 2, 0]) {
        update(() => count = value);
        await t.pump();
        expect(t.state(find.byType(_Probe)), same(state));
        expect(find.text('value 1'), findsOneWidget);
      }
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Modal stays opaque with a clear barrier and preserves edited content when reduced mid-entry',
    (t) async {
      var reduced = false;
      late StateSetter update;
      late BuildContext page;
      await t.pumpWidget(
        StatefulBuilder(
          builder: (_, set) {
            update = set;
            return MaterialApp(
              theme: IslandTheme.create(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: reduced),
                child: child!,
              ),
              home: Builder(
                builder: (context) {
                  page = context;
                  return const SizedBox();
                },
              ),
            );
          },
        ),
      );
      showIslandModal<void>(
        context: page,
        barrierColor: Colors.transparent,
        builder: (_) => const _Probe(),
      );
      await t.pump();
      final state = t.state(find.byType(_Probe));
      for (final ms in [0, 16, 50]) {
        await t.pump(Duration(milliseconds: ms));
        opaque(t, find.text('value 0'));
        final backing = t
            .widget<ColoredBox>(
              find
                  .ancestor(
                    of: find.text('value 0'),
                    matching: find.byType(ColoredBox),
                  )
                  .first,
            )
            .color;
        expect(backing.a, 1);
      }
      await t.tap(find.text('value 0'));
      await t.pump();
      update(() => reduced = true);
      await t.pump();
      await t.pump();
      expect(t.state(find.byType(_Probe)), same(state));
      expect(find.text('value 1'), findsOneWidget);
      opaque(t, find.text('value 1'));
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.byType(_Probe), findsNothing);
    },
  );

  testWidgets(
    'Notification exit is opaque and reduced completion is once, ordered and safe for same-ID reopen',
    (t) async {
      final controller = IslandNotificationsController();
      addTearDown(controller.dispose);
      var reduced = false;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: IslandNotifications(
                  controller: controller,
                  child: const SizedBox(),
                ),
              );
            },
          ),
        ),
      );
      final events = <String>[];
      late IslandNotificationHandle first;
      first = controller.show(
        IslandNotification(
          message: const Text('Notice'),
          duration: Duration.zero,
          onDismiss: () {
            events.add('dismiss');
            first.close();
          },
          onClose: () {
            events.add('close');
            controller.show(
              const IslandNotification(
                message: Text('Reopened'),
                duration: Duration.zero,
              ),
              id: 'id',
            );
          },
        ),
        id: 'id',
      );
      await t.pump();
      await t.pump();
      for (final ms in [0, 16, 60]) {
        await t.pump(Duration(milliseconds: ms));
        opaque(t, find.text('Notice'));
        readable(foreground(t, 'Notice'), fill(t, find.text('Notice')));
      }
      first.close();
      await t.pump();
      await t.pump(const Duration(milliseconds: 50));
      opaque(t, find.text('Notice'));
      expect(events, ['dismiss']);
      update(() => reduced = true);
      await t.pump();
      await t.pump();
      await t.pump();
      expect(events, ['dismiss', 'close']);
      expect(find.text('Notice'), findsNothing);
      expect(find.text('Reopened'), findsOneWidget);
      first.close();
      await t.pump(const Duration(milliseconds: 500));
      expect(events, ['dismiss', 'close']);
      expect(find.text('Reopened'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'Loading keeps background input and semantics blocked until removal, with one interactive tip',
    (t) async {
      var active = false, reduced = false, backgroundTaps = 0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      late StateSetter update;
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: Stack(
                  children: [
                    TextButton(
                      focusNode: focus,
                      onPressed: () => backgroundTaps++,
                      child: const Text('Background'),
                    ),
                    IslandLoading(active: active, tip: const _Probe()),
                  ],
                ),
              );
            },
          ),
        ),
      );
      focus.requestFocus();
      await t.pump();
      update(() => active = true);
      await t.pump();
      await t.pump();
      await t.pump();
      await t.pump();
      final state = t.state(find.byType(_Probe));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pump();
      expect(find.text('value 1'), findsOneWidget);
      update(() => active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      opaque(t, find.text('value 1'));
      expect(t.state(find.byType(_Probe)), same(state));
      await t.tapAt(t.getCenter(find.text('Background')));
      expect(backgroundTaps, 0);
      final labels = t.semantics
          .simulatedAccessibilityTraversal()
          .map((n) => n.label)
          .join(' ');
      expect(labels, isNot(contains('Background')));
      update(() => active = true);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 700));
      expect(t.state(find.byType(_Probe)), same(state));
      update(() {
        active = false;
        reduced = true;
      });
      await t.pump();
      await t.pump();
      await t.pump();
      await t.pump();
      expect(find.byType(_Probe), findsNothing);
      expect(focus.hasFocus, isTrue);
      await t.tap(find.text('Background'));
      expect(backgroundTaps, 1);
      semantics.dispose();
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'CountUp keeps opaque builder identity and celebration content in reduced mode',
    (t) async {
      var reduced = false;
      final controller = IslandCountUpController();
      addTearDown(controller.dispose);
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: IslandCountUp(
                  end: 2,
                  duration: const Duration(milliseconds: 100),
                  isCounting: true,
                  controller: controller,
                  builder: (_, value) => const _Probe(),
                  celebration: const Text('Done'),
                ),
              );
            },
          ),
        ),
      );
      final state = t.state(find.byType(_Probe));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      await t.pump();
      expect(t.state(find.byType(_Probe)), same(state));
      opaque(t, find.text('Done'));
      update(() => reduced = true);
      await t.pump();
      opaque(t, find.text('Done'));
      expect(t.state(find.byType(_Probe)), same(state));
      await t.pump(const Duration(milliseconds: 901));
      expect(find.text('Done'), findsNothing);
      controller.reset();
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 101));
      await t.pump();
      opaque(t, find.text('Done'));
      expect(t.state(find.byType(_Probe)), same(state));
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'Carousel paints exactly one retained slide during rapid reversals',
    (t) async {
      var value = 'a';
      late StateSetter update;
      final painted = <String>[];
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return SizedBox(
                width: 400,
                child: IslandCarousel(
                  value: value,
                  onChanged: (_) {},
                  items: [
                    for (final id in ['a', 'b', 'c'])
                      IslandSlide(
                        value: id,
                        child: CustomPaint(
                          painter: _PaintProbe(() => painted.add(id)),
                          child: SizedBox(
                            width: 400,
                            height: 200,
                            child: Text(id),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      for (final id in ['b', 'c', 'a', 'b']) {
        painted.clear();
        update(() => value = id);
        await t.pump();
        expect(painted, [id]);
        opaque(t, find.text(id));
        await t.pump(const Duration(milliseconds: 40));
        expect(painted.every((v) => v == id), isTrue);
      }
      await t.pumpWidget(const SizedBox());
    },
  );
}

class _Probe extends StatefulWidget {
  const _Probe();
  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  int value = 0;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => value++),
    child: Text('value $value'),
  );
}

class _PaintProbe extends CustomPainter {
  _PaintProbe(this.record);
  final VoidCallback record;
  @override
  void paint(Canvas canvas, Size size) => record();
  @override
  bool shouldRepaint(_PaintProbe old) => true;
}
