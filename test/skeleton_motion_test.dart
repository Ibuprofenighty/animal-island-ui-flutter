import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'paragraph uses one full-width sweep and repeats supplied widths',
    (t) async {
      var active = true;
      List<double>? widths = [.8, .5];
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                update = set;
                return IslandSkeleton(
                  variant: IslandSkeletonVariant.paragraph,
                  width: 200,
                  rows: 4,
                  rowWidths: widths,
                  active: active,
                );
              },
            ),
          ),
        ),
      );
      final root = find.byType(IslandSkeleton);
      final transforms = find.descendant(
        of: root,
        matching: find.byType(Transform),
      );
      expect(transforms, findsOneWidget);
      expect(t.getSize(root), const Size(200, 86));
      final rows = find.descendant(
        of: root,
        matching: find.byType(FractionallySizedBox),
      );
      expect(
        t.widgetList<FractionallySizedBox>(rows).map((w) => w.widthFactor),
        [.8, .5, .5, .5],
      );
      double x() => t.widget<Transform>(transforms).transform.storage[12];
      expect(x(), -200);
      await t.pump(const Duration(milliseconds: 800));
      expect(x(), closeTo(0, .01));
      final gradient = t
          .widgetList<DecoratedBox>(
            find.descendant(of: root, matching: find.byType(DecoratedBox)),
          )
          .single;
      expect(
        (gradient.decoration as BoxDecoration).gradient!.colors[2],
        const Color(0x8cfffcf2),
      );
      update(() => active = false);
      await t.pump();
      expect(transforms, findsNothing);
      update(() {
        active = true;
        widths = [];
      });
      await t.pump();
      expect(x(), -200);
      expect(
        t.widgetList<FractionallySizedBox>(rows).map((w) => w.widthFactor),
        [1, 1, 1, 1],
      );
      update(() => widths = null);
      await t.pump();
      expect(
        t.widgetList<FractionallySizedBox>(rows).map((w) => w.widthFactor),
        [1, .92, .84, .76],
      );
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('loaded content stays opaque and reduced motion stops sweep', (
    t,
  ) async {
    await t.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: Column(
            children: [
              IslandSkeleton(variant: IslandSkeletonVariant.paragraph),
              IslandSkeleton(loading: false, child: Text('Loaded')),
              IslandSkeleton(loading: false, width: 90),
              IslandSkeletonButton(),
              IslandSkeletonInput(),
              IslandSkeletonAvatar(),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Loaded'), findsOneWidget);
    expect(find.byType(Transform), findsNothing);
    await t.pump(const Duration(seconds: 2));
    expect(t.hasRunningAnimations, isFalse);
    expect(t.takeException(), isNull);
  });
}
