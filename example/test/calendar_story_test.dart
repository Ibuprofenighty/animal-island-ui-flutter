import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

Finder cell(String date) => find.bySemanticsLabel(
  RegExp(
    '^${RegExp.escape(date)}'
    r'(?: |$)',
  ),
);

Future<void> pumpStory(WidgetTester t, double width) async {
  t.view.physicalSize = Size(width, width == 375 ? 812 : 1000);
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: IslandLocalizations.delegates,
      supportedLocales: IslandLocalizations.supportedLocales,
      theme: galleryTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: GalleryPage(
        key: ValueKey('calendar-$width'),
        path: '/calendar',
        onNavigate: (_) {},
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('Calendar story shows the three reference demos in the page', (
    t,
  ) async {
    for (final width in [1440.0, 375.0]) {
      await pumpStory(t, width);
      final calendars = t
          .widgetList<IslandCalendar>(find.byType(IslandCalendar))
          .toList();
      expect(calendars, hasLength(3), reason: '$width');
      expect(calendars[0].events.map((e) => e.title), [
        '每日签到',
        '开荒新岛',
        '海岛丰收祭',
        '钓鱼大赛',
        '篝火晚会',
        '摘果子',
        '浇花',
      ]);
      expect(calendars[1].value, DateTime(2026, 8, 10));
      expect(calendars[1].month, DateTime(2026, 8));
      expect(calendars[2].onCreateEvent, isNotNull);
      // Reference demo caption and the leading `width` API row.
      expect(find.text('拖拽跨日期创建事项（draggableEvents）'), findsOneWidget);
      expect(find.text('面板宽度，默认铺满父容器（数值按 px 处理）'), findsOneWidget);
      expect(find.text('2026年8月'), findsNWidgets(3));
      expect(find.text('09:30'), findsOneWidget);
      expect(find.text('20:00'), findsNothing);
      expect(find.text('摘果子'), findsOneWidget);
      expect(find.text('浇花'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
      expect(find.text('当前选中: 2026-08-10', findRichText: true), findsOneWidget);
      expect(
        find.text('新建事项: 在日期上按住并横向拖动', findRichText: true),
        findsOneWidget,
      );
      for (final calendar in find.byType(IslandCalendar).evaluate()) {
        final rect = t.getRect(find.byWidget(calendar.widget));
        expect(rect.left, greaterThanOrEqualTo(0), reason: '$width');
        expect(rect.right, lessThanOrEqualTo(width), reason: '$width');
      }
      expect(t.takeException(), isNull);
    }
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('controlled and drag demos update their status lines', (t) async {
    await pumpStory(t, 1440);
    await t.ensureVisible(cell('2026-08-20').at(1));
    await t.pumpAndSettle();
    await t.tap(cell('2026-08-20').at(1));
    await t.pumpAndSettle();
    expect(find.text('当前选中: 2026-08-20', findRichText: true), findsOneWidget);

    await t.ensureVisible(cell('2026-08-13').at(2));
    await t.pumpAndSettle();
    final gesture = await t.startGesture(
      t.getCenter(cell('2026-08-11').at(2)),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveTo(t.getCenter(cell('2026-08-12').at(2)));
    await t.pump();
    await gesture.moveTo(t.getCenter(cell('2026-08-13').at(2)));
    await t.pump();
    await gesture.up();
    await t.pumpAndSettle();
    expect(
      find.text('新建事项: 事件一（2026-08-11 ~ 2026-08-13）', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('事件一'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
