import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

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
        key: ValueKey('no-data-$width'),
        path: '/no-data',
        onNavigate: (_) {},
      ),
    ),
  );
  await t.pumpAndSettle();
}

Future<void> tapText(WidgetTester t, String text) async {
  await t.ensureVisible(find.text(text));
  await t.pumpAndSettle();
  await t.tap(find.text(text));
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

  testWidgets('NoData story shows the reference sections at both widths', (
    t,
  ) async {
    for (final width in [1440.0, 375.0]) {
      await pumpStory(t, width);
      for (final heading in [
        'naive-icons 原生图标空态',
        '基础空态',
        '搜索无结果与恢复',
        '表格内的简洁空态',
        '尺寸与自定义内容',
      ]) {
        expect(find.text(heading), findsOneWidget, reason: '$width $heading');
      }
      final states = t.widgetList<IslandNoData>(find.byType(IslandNoData));
      expect(states.map((s) => s.variant), [
        IslandNoDataVariant.normal,
        IslandNoDataVariant.search,
        IslandNoDataVariant.normal,
        IslandNoDataVariant.search,
        IslandNoDataVariant.simple,
        IslandNoDataVariant.normal,
        IslandNoDataVariant.normal,
        IslandNoDataVariant.normal,
        IslandNoDataVariant.normal,
        IslandNoDataVariant.normal,
      ], reason: '$width');
      expect(states.where((s) => s.bordered), hasLength(5));
      expect(states.map((s) => s.size).skip(5).take(3), [
        IslandSize.small,
        IslandSize.middle,
        IslandSize.large,
      ]);
      expect(find.text('没有找到“星星”'), findsOneWidget);
      expect(find.text('没有找到“星星”相关的岛屿'), findsOneWidget);
      expect(t.takeException(), isNull, reason: '$width');
    }
  });

  testWidgets('auto-fit grids stretch side-by-side boxes to one height', (
    t,
  ) async {
    await pumpStory(t, 1440);
    final first = t.getRect(find.byType(IslandNoData).at(0));
    final second = t.getRect(find.byType(IslandNoData).at(1));
    expect(second.top, first.top);
    expect(second.height, first.height);
    expect(second.left - first.right, 24);
    final small = t.getRect(find.byType(IslandNoData).at(5));
    final large = t.getRect(find.byType(IslandNoData).at(7));
    expect(large.top, small.top);
    expect(large.height, small.height);

    await pumpStory(t, 375);
    final narrowFirst = t.getRect(find.byType(IslandNoData).at(0));
    final narrowSecond = t.getRect(find.byType(IslandNoData).at(1));
    expect(narrowSecond.top - narrowFirst.bottom, 24);
    expect(narrowSecond.width, narrowFirst.width);
  });

  testWidgets('search recovery clears the query and lists every island', (
    t,
  ) async {
    await pumpStory(t, 1440);
    double fontSize(String text) => t
        .widget<RichText>(
          find.descendant(of: find.text(text), matching: find.byType(RichText)),
        )
        .text
        .style!
        .fontSize!;
    // Reference status line and `<li>` items inherit the page's 16px.
    expect(fontSize('没有找到“星星”相关的岛屿'), 16);
    await tapText(t, '清除搜索');
    expect(find.text('找到 3 个岛屿'), findsOneWidget);
    expect(fontSize('找到 3 个岛屿'), 16);
    for (final name in ['薄荷岛', '蜜桃岛', '珊瑚岛']) {
      expect(find.text('•  $name'), findsOneWidget);
      expect(fontSize('•  $name'), 16);
    }
    expect(find.text('清除搜索'), findsNothing);
    await t.enterText(
      find.descendant(
        of: find.byType(IslandTextField),
        matching: find.byType(EditableText),
      ),
      '珊瑚',
    );
    await t.pumpAndSettle();
    expect(find.text('找到 1 个岛屿'), findsOneWidget);
    await t.enterText(
      find.descendant(
        of: find.byType(IslandTextField),
        matching: find.byType(EditableText),
      ),
      '月亮',
    );
    await t.pumpAndSettle();
    expect(find.text('没有找到“月亮”'), findsOneWidget);
  });

  testWidgets('the table empty state creates a note and can be restored', (
    t,
  ) async {
    await pumpStory(t, 1440);
    expect(find.text('写下今天的第一件小事。'), findsOneWidget);
    // Reference Table keeps its 48px empty icon above custom emptyText.
    final table = find.byType(IslandTable<String>);
    final noData = find.descendant(
      of: table,
      matching: find.byType(IslandNoData),
    );
    expect(
      t.getTopLeft(noData).dy - t.getTopLeft(table).dy,
      greaterThan(48 + 16 + 60),
    );
    await tapText(t, '新建手账');
    expect(find.text('第一篇海岛手账'), findsOneWidget);
    expect(find.text('写下今天的第一件小事。'), findsNothing);
    await tapText(t, '重新体验空态');
    expect(find.text('写下今天的第一件小事。'), findsOneWidget);
    expect(find.text('重新体验空态'), findsNothing);
  });
}
