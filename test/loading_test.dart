import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'empty loading focus scope consumes both Tab directions without entering background',
    (t) async {
      final outside = FocusNode();
      await t.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: Scaffold(
              body: Stack(
                children: [
                  TextButton(
                    focusNode: outside,
                    onPressed: () {},
                    child: const Text('Outside'),
                  ),
                  IslandLoading(tip: const Text('Busy')),
                ],
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final modalFocus = FocusManager.instance.primaryFocus;
      expect(modalFocus, isNotNull);
      expect(outside.hasFocus, isFalse);
      expect(await t.sendKeyEvent(LogicalKeyboardKey.tab), isTrue);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, same(modalFocus));
      expect(outside.hasFocus, isFalse);
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      expect(await t.sendKeyEvent(LogicalKeyboardKey.tab), isTrue);
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await t.pumpAndSettle();
      expect(outside.hasFocus, isFalse);
      await t.pumpWidget(const SizedBox());
      outside.dispose();
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('vignette reaches corners while side centers stay lighter', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Scaffold(body: IslandLoading(tip: const Text('vignette'))),
        ),
      ),
    );
    await t.pumpAndSettle();
    final painter = t
        .widgetList<CustomPaint>(
          find.ancestor(
            of: find.text('vignette'),
            matching: find.byType(CustomPaint),
          ),
        )
        .firstWhere((w) => w.painter != null)
        .painter!;
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), const Size(800, 600));
    final picture = recorder.endRecording();
    final rgba = (await t.runAsync(() async {
      final image = await picture.toImage(800, 600);
      final bytes = (await image.toByteData())!.buffer.asUint8List();
      image.dispose();
      return bytes;
    }))!;
    int median(int x, int y, int channel) {
      final samples = [
        for (var dy = -5; dy <= 5; dy++)
          rgba[((y + dy) * 800 + x) * 4 + channel],
      ]..sort();
      return samples[samples.length ~/ 2];
    }

    // CSS farthest-corner ellipse: side-center alpha is about.21, corner.6.
    expect(median(0, 300, 0), inInclusiveRange(9, 11));
    expect(median(0, 300, 2), inInclusiveRange(24, 26));
    expect(median(0, 5, 0), inInclusiveRange(6, 8));
    picture.dispose();
    await t.pumpWidget(const SizedBox());
  });

  testWidgets(
    'necessary loading layer remains opaque through exit, reversal and reduced motion',
    (t) async {
      var active = true, reduced = false;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: Scaffold(
                  body: IslandLoading(active: active, tip: const Text('phase')),
                ),
              );
            },
          ),
        ),
      );
      await t.pump();
      await t.pump();
      void readable() {
        expect(find.text('phase'), findsOneWidget);
        for (final w in t.widgetList<Opacity>(
          find.ancestor(of: find.text('phase'), matching: find.byType(Opacity)),
        )) {
          expect(w.opacity, 1);
        }
        for (final w in t.widgetList<FadeTransition>(
          find.ancestor(
            of: find.text('phase'),
            matching: find.byType(FadeTransition),
          ),
        )) {
          expect(w.opacity.value, 1);
        }
        expect(
          t
              .widget<ColoredBox>(
                find
                    .ancestor(
                      of: find.text('phase'),
                      matching: find.byType(ColoredBox),
                    )
                    .first,
              )
              .color,
          const Color(0xff0b101a),
        );
      }

      readable();
      await t.pump(const Duration(milliseconds: 100));
      readable();
      update(() => active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      readable();
      update(() => active = true);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 700));
      readable();
      update(() => active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      readable();
      update(() => reduced = true);
      await t.pump();
      await t.pump();
      await t.pump();
      expect(find.text('phase'), findsNothing);
      update(() => active = true);
      await t.pump();
      await t.pump();
      await t.pump();
      readable();
      update(() => active = false);
      await t.pump();
      await t.pump();
      await t.pump();
      expect(find.text('phase'), findsNothing);
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'delay cancels, reduced exit releases clicks only after removal, reactivation survives',
    (tester) async {
      var active = false;
      var taps = 0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return Scaffold(
                body: MediaQuery(
                  data: const MediaQueryData(disableAnimations: true),
                  child: Stack(
                    children: [
                      Center(
                        child: TextButton(
                          onPressed: () => taps++,
                          child: const Text('underlying'),
                        ),
                      ),
                      IslandLoading(
                        active: active,
                        delay: const Duration(milliseconds: 300),
                        tip: const Text('Snow'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      update(() => active = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Snow'), findsNothing);
      update(() => active = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Snow'), findsNothing);
      update(() => active = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 220));
      expect(find.text('Snow'), findsOneWidget);
      await tester.tapAt(tester.getCenter(find.text('underlying')));
      expect(taps, 0);
      update(() => active = false);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.tapAt(tester.getCenter(find.text('underlying')));
      expect(taps, 1);
      await tester.pump(const Duration(milliseconds: 200));
      update(() => active = true);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();
      expect(find.text('Snow'), findsOneWidget);
      update(() => active = false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      expect(find.text('Snow'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'removal cancels pending show and snow ticker; siblings have isolated lifecycles',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IslandLoading(
                  delay: const Duration(seconds: 2),
                  tip: const Text('Delayed'),
                ),
                IslandLoading(tip: const Text('Immediate')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('Immediate'), findsOneWidget);
      expect(find.text('Delayed'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'open viewport surface keeps live framework theme and visible semantics',
    (tester) async {
      var color = Colors.red;
      late StateSetter update;
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return Theme(
                data: ThemeData(primaryColor: color),
                child: Scaffold(
                  body: MediaQuery(
                    data: const MediaQueryData(disableAnimations: true),
                    child: IslandLoading(
                      tip: Builder(
                        builder: (context) => Text(
                          'Themed snow',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.semantics.simulatedAccessibilityTraversal().any(
          (node) => node.label == 'Themed snow',
        ),
        isTrue,
      );
      expect(
        tester.widget<Text>(find.text('Themed snow')).style!.color,
        Colors.red,
      );
      update(() => color = Colors.blue);
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('Themed snow')).style!.color,
        Colors.blue,
      );
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
    },
  );
}
