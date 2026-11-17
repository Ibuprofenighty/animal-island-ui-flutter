import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

final _sailboat = find.byWidgetPredicate(
  (w) => w is IslandIcon && w.glyph == IslandGlyph.sailboat,
);

class _Host {
  _Host(this.t);
  final WidgetTester t;
  var active = true, reduced = false, showBoat = true;
  var type = IslandLoadingType.circle;
  var taps = 0;
  late StateSetter update;

  Future<void> mount() => t.pumpWidget(
    MaterialApp(
      home: StatefulBuilder(
        builder: (_, set) {
          update = set;
          return MediaQuery(
            data: MediaQueryData(
              size: const Size(800, 600),
              disableAnimations: reduced,
            ),
            child: Scaffold(
              body: Stack(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () => taps++,
                      child: const Text('below'),
                    ),
                  ),
                  IslandLoading(
                    type: type,
                    showBoat: showBoat,
                    active: active,
                    tip: const Text('sailing'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Path clip() {
    final clip = t.widget<ClipPath>(
      find
          .ancestor(of: find.text('sailing'), matching: find.byType(ClipPath))
          .first,
    );
    return clip.clipper!.getClip(const Size(800, 600));
  }

  Future<void> tapBelow() => t.tapAt(const Offset(400, 300));
}

void main() {
  testWidgets(
    'an immediately active loading is built with its first frame, before any reconcile frame',
    (t) async {
      for (final type in IslandLoadingType.values) {
        final h = _Host(t)..type = type;
        await h.mount();
        // The overlay entry is inserted after the first frame and painted by
        // the next one; no further show frame is needed.
        await t.pump();
        expect(find.text('sailing'), findsOneWidget, reason: '$type');
        await t.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets(
    'circle form shows the sailboat 20px from the right and 30px from the bottom; snow and showBoat false do not',
    (t) async {
      t.view.physicalSize = const Size(800, 600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final h = _Host(t);
      await h.mount();
      await t.pump();
      expect(_sailboat, findsWidgets);
      final scene = t.getRect(
        find.ancestor(of: _sailboat.first, matching: find.byType(AspectRatio)),
      );
      expect(
        scene,
        const Rect.fromLTWH(800 - 20 - 120, 600 - 30 - 120, 120, 120),
      );
      expect(
        t.widget<IslandIcon>(_sailboat.first).color,
        const Color(0xff2a2a2a),
      );
      h.update(() => h.showBoat = false);
      await t.pump();
      expect(_sailboat, findsNothing);
      expect(find.text('sailing'), findsOneWidget);
      h.update(() {
        h.showBoat = true;
        h.type = IslandLoadingType.snow;
      });
      await t.pump();
      expect(_sailboat, findsNothing);
      expect(find.text('sailing'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'boat bobs and water scrolls while animating; reduced motion keeps them at rest and settles',
    (t) async {
      final h = _Host(t);
      await h.mount();
      await t.pump();
      List<Matrix4> transforms() => [
        for (final w in t.widgetList<Transform>(
          find.ancestor(of: _sailboat.first, matching: find.byType(Transform)),
        ))
          w.transform.clone(),
      ];
      final before = transforms();
      await t.pump(const Duration(milliseconds: 500));
      expect(transforms(), isNot(equals(before)));
      h.update(() => h.reduced = true);
      await t.pumpAndSettle();
      final rest = transforms();
      await t.pump(const Duration(milliseconds: 700));
      expect(transforms(), equals(rest));
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'closing opens a linear centre circle over fadeDuration while background input stays blocked until removal',
    (t) async {
      t.view.physicalSize = const Size(800, 600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final h = _Host(t);
      await h.mount();
      await t.pump();
      expect(h.clip().contains(const Offset(400, 300)), isTrue);
      h.update(() => h.active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      // Full radius: ceil(hypot(800, 600) / 2) + 50 = 550; half way: 275.
      final half = h.clip();
      expect(half.contains(const Offset(400, 300)), isFalse);
      expect(half.contains(const Offset(400 + 270, 300)), isFalse);
      expect(half.contains(const Offset(400 + 280, 300)), isTrue);
      expect(half.contains(const Offset(5, 5)), isTrue);
      await h.tapBelow();
      expect(h.taps, 0, reason: 'the exiting layer still blocks input');
      // Reactivation closes the circle at once.
      h.update(() => h.active = true);
      await t.pump();
      await t.pump();
      expect(h.clip().contains(const Offset(400, 300)), isTrue);
      expect(find.text('sailing'), findsOneWidget);
      h.update(() => h.active = false);
      await t.pump();
      await t.pump();
      await t.pump(const Duration(milliseconds: 590));
      expect(h.clip().contains(const Offset(5, 5)), isFalse);
      await t.pump(const Duration(milliseconds: 20));
      await t.pump();
      expect(find.text('sailing'), findsNothing);
      await h.tapBelow();
      expect(h.taps, 1);
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('reduced motion removes the circle form immediately on close', (
    t,
  ) async {
    final h = _Host(t)..reduced = true;
    await h.mount();
    await t.pumpAndSettle();
    expect(find.text('sailing'), findsOneWidget);
    h.update(() => h.active = false);
    await t.pump();
    await t.pump();
    await t.pump();
    expect(find.text('sailing'), findsNothing);
    await h.tapBelow();
    expect(h.taps, 1);
    await t.pumpWidget(const SizedBox());
  });
}
