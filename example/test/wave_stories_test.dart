import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/stories/divider_story.dart';
import 'package:island_gallery/pages/stories/progress_story.dart';
import 'package:island_gallery/pages/stories/upload_story.dart';
import 'package:island_gallery/shared/theme.dart';

int get ticking => SchedulerBinding.instance.transientCallbackCount;

Future<void> show(
  WidgetTester t,
  Widget story,
  double width, {
  bool reduced = false,
}) async {
  t.view.physicalSize = Size(width, 900);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      theme: galleryTheme(),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: story,
            ),
          ),
        ),
      ),
    ),
  );
  await t.pump();
}

Future<void> reveal(WidgetTester t, Finder finder) async {
  await t.ensureVisible(finder);
  await t.pump();
  await t.pump();
}

void main() {
  testWidgets('Divider story adds the ocean-wave section with a pause toggle', (
    t,
  ) async {
    await show(t, const DividerStory(), 1440);
    final waves = find.byWidgetPredicate(
      (w) => w is IslandDivider && w.variant == IslandDividerVariant.oceanWave,
    );
    expect(waves, findsNWidgets(2));
    expect(find.text('新增示例：海浪分割线'), findsOneWidget);
    expect(ticking, 0, reason: 'waves below the fold stay still');
    await reveal(t, find.text('暂停海浪'));
    expect(t.widget<IslandDivider>(waves.first).animated, isTrue);
    expect(t.widget<IslandDivider>(waves.last).animated, isFalse);
    expect(ticking, greaterThan(0));
    await t.tap(find.text('暂停海浪'));
    await t.pump();
    await t.pump();
    expect(find.text('播放海浪'), findsOneWidget);
    expect(t.widget<IslandDivider>(waves.first).animated, isFalse);
    expect(ticking, 0);
    await t.pumpWidget(const SizedBox());
    expect(t.takeException(), isNull);
  });

  testWidgets('Progress story drives colour and wave bars from one percent', (
    t,
  ) async {
    await show(t, const ProgressStory(), 1440);
    final colored = find.byWidgetPredicate(
      (w) => w is IslandProgress && w.color != null && !w.wave,
    );
    final waved = find.byWidgetPredicate((w) => w is IslandProgress && w.wave);
    expect(colored, findsNWidgets(3));
    expect(waved, findsNWidgets(3));
    expect(t.widgetList<IslandProgress>(colored).map((w) => w.color), [
      IslandColorway.orange.accent,
      IslandColorway.green.accent,
      IslandColorway.purple.accent,
    ]);
    await reveal(t, find.widgetWithText(IslandButton, '100%'));
    await t.tap(find.widgetWithText(IslandButton, '100%'));
    await t.pump();
    for (final w in t.widgetList<IslandProgress>(waved)) {
      expect(w.percent, 100);
    }
    await t.tap(find.widgetWithText(IslandButton, '45%'));
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    expect(ticking, greaterThan(0));
    await t.tap(find.text('暂停海浪'));
    await t.pump();
    for (final w in t.widgetList<IslandProgress>(waved)) {
      expect(w.animated, isFalse);
    }
    await t.pumpWidget(const SizedBox());
    expect(t.takeException(), isNull);
  });

  for (final width in [1440.0, 375.0]) {
    testWidgets('Upload story shows both progress modes for every list at '
        '$width', (t) async {
      await show(t, const UploadStory(), width, reduced: true);
      await t.pumpAndSettle();
      final uploads = find.byWidgetPredicate(
        (w) => w is IslandUpload && w.progress != null,
      );
      expect(uploads, findsNWidgets(6));
      expect(
        t
            .widgetList<IslandUpload>(uploads)
            .map((w) => (w.progress!.type, w.listType)),
        [
          for (final type in [
            IslandUploadProgressType.background,
            IslandUploadProgressType.bar,
          ])
            for (final list in IslandUploadListType.values) (type, list),
        ],
      );
      for (final w in t.widgetList<IslandUpload>(uploads)) {
        expect(w.progress!.wave, isTrue);
        expect(w.progress!.color, IslandTokens.light.leaf);
        expect(w.initialFiles.single.percent, 46);
      }
      expect(
        find.descendant(of: uploads, matching: find.byType(IslandProgress)),
        findsNWidgets(3),
      );
      expect(t.takeException(), isNull);
    });
  }
}
