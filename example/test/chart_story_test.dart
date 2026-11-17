import 'dart:ui' as ui;

import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/main.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/catalog.dart';
import 'package:island_gallery/shared/theme.dart';

final chartEntries = galleryGroups['图表统计']!;

Future<void> pumpRoute(WidgetTester t, String id, double width) async {
  final size = Size(width, width == 375 ? 812 : 1000);
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: IslandLocalizations.delegates,
      supportedLocales: IslandLocalizations.supportedLocales,
      theme: galleryTheme(),
      home: MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: true),
        child: GalleryPage(
          key: ValueKey('$id-$width'),
          path: '/$id',
          onNavigate: (_) {},
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}

/// The state demo chart of a type page, titled 岛屿{label}.
Finder mainChart(String label) => find.widgetWithText(IslandChart, '岛屿$label');

Future<void> reveal(WidgetTester t, Finder finder) async {
  await t.ensureVisible(finder);
  await t.pumpAndSettle();
}

/// First legend entry of exampleProps(type), the series or item name.
const firstLegend = {
  'column': '本周',
  'bar': '本周',
  'line': '本周',
  'area': '本周',
  'mount': '本周',
  'mix': '本周',
  'radar': '本月',
  'scatter': '海岸活动',
  'bubble': '海岸活动',
  'arcbar': '植树目标',
  'gauge': '岛屿舒适度',
  'candle': '集市价格（示例）',
  'time': '实时到访',
  'pie': '果园',
  'ring': '果园',
  'rose': '果园',
  'funnel': '果园',
  'map': '果园',
  'word': '海风',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  test('the catalog lists the overview and all 19 chart kinds', () {
    expect(chartEntries.first.id, 'charts');
    expect(
      {for (final entry in chartEntries.skip(1)) entry.id},
      {for (final type in IslandChartType.values) 'chart-${type.name}'},
    );
  });

  for (final width in [1440.0, 375.0]) {
    testWidgets('charts overview at $width: showcase, overview, catalog', (
      t,
    ) async {
      await pumpRoute(t, 'charts', width);
      expect(t.takeException(), isNull);
      for (final text in [
        '岛屿统计手账',
        '图表样式精选',
        '基础概览',
        '一周到访趋势',
        '岛屿分区占比',
        '每日活动参与',
        '选择图表类型',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(find.byType(IslandChart), findsNWidgets(11));
      for (final entry in chartEntries.skip(1)) {
        expect(find.text(entry.title), findsOneWidget, reason: entry.id);
        expect(find.text(entry.description), findsOneWidget);
      }
      for (final label in ['柱状图', '折线图', '环形图', '条状图', '雷达图', '气泡图', '漏斗图']) {
        expect(find.text('更多$label示例'), findsOneWidget, reason: label);
      }
      expect(find.text('更多地图统计示例'), findsOneWidget);
      for (final card in chartEntries.skip(1)) {
        final rect = t.getRect(find.text(card.title));
        expect(rect.right, lessThanOrEqualTo(width), reason: card.id);
      }
    });

    for (final entry in chartEntries.skip(1)) {
      final type = entry.id.substring(6);
      testWidgets('${entry.id} at $width: reference sections render', (
        t,
      ) async {
        await pumpRoute(t, entry.id, width);
        expect(t.takeException(), isNull);
        final label = entry.title;
        for (final text in [
          '$label · 海岛统计',
          '样式与场景',
          '基础示例与状态切换',
          '岛屿$label',
          '新增示例：悬浮对比与锁定读数',
          '交互细节体验',
          '点击图形查看数据；点击图例隐藏或恢复系列。',
          '最近点击：尚未点击数据。Enter / 空格锁定，Esc 解除。',
          'API',
        ]) {
          expect(find.text(text), findsOneWidget, reason: text);
        }
        final boundary = const {'column', 'bar', 'line', 'area'}.contains(type);
        expect(
          find.text('边界示例：负值、零值与缺测'),
          boundary ? findsOneWidget : findsNothing,
        );
        expect(
          find.text('新增示例：圆润山峰'),
          type == 'mount' ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(IslandChart),
          findsNWidgets(
            4 + 1 + 1 + (boundary ? 1 : 0) + (type == 'mount' ? 2 : 0),
          ),
        );
        expect(find.text('▶ 查看配置'), findsNWidgets(4));
        for (final chart in find.byType(IslandChart).evaluate()) {
          final rect = t.getRect(find.byWidget(chart.widget));
          expect(rect.left, greaterThanOrEqualTo(0), reason: '$width');
          expect(rect.right, lessThanOrEqualTo(width), reason: '$width');
        }

        // Legend toggle (every family): hiding the first entry of the state
        // demo offers 恢复全部图例 in that chart.
        final legend = find.descendant(
          of: mainChart(label),
          matching: find.text(firstLegend[type]!),
        );
        await reveal(t, legend);
        await t.tap(legend);
        await t.pumpAndSettle();
        expect(
          find.descendant(of: mainChart(label), matching: find.text('恢复全部图例')),
          findsOneWidget,
        );
        expect(t.takeException(), isNull);
      });
    }
  }

  testWidgets('state buttons switch empty, loading and stacked states', (
    t,
  ) async {
    await pumpRoute(t, 'chart-column', 1440);
    await reveal(t, find.text('查看空态'));
    await t.tap(find.text('查看空态'));
    await t.pumpAndSettle();
    expect(
      find.descendant(of: mainChart('柱状图'), matching: find.text('暂无数据')),
      findsOneWidget,
    );
    await t.tap(find.text('恢复数据'));
    await t.tap(find.text('查看加载态'));
    await t.pumpAndSettle();
    expect(find.text('正在整理数据…'), findsOneWidget);
    await t.tap(find.text('结束加载'));
    await t.tap(find.text('切换堆叠'));
    await t.pumpAndSettle();
    expect(find.text('切换分组'), findsOneWidget);
    expect(find.text('正在整理数据…'), findsNothing);
    expect(t.takeException(), isNull);
  });

  testWidgets('activating a reading reports it; keyboard reading follows', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    await pumpRoute(t, 'chart-line', 1440);
    final reading = find.semantics.byPredicate(
      (node) =>
          node.label == '本周，周一，32' &&
          node.getSemanticsData().hasAction(ui.SemanticsAction.tap),
    );
    await reveal(t, find.text('岛屿折线图'));
    t.semantics.tap(reading.first);
    await t.pumpAndSettle();
    expect(find.text('本周 / 周一：32'), findsOneWidget);

    // The interaction demo: a pointer press focuses the reading, then the
    // arrow key moves and Enter activates the next one.
    final last = find.bySemanticsLabel('本周，周一，32').last;
    await reveal(t, last);
    await t.tapAt(t.getCenter(last));
    await t.pumpAndSettle();
    expect(find.text('最近点击：本周 / 周一：32。Enter / 空格锁定，Esc 解除。'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pumpAndSettle();
    expect(find.text('最近点击：本周 / 周二：46。Enter / 空格锁定，Esc 解除。'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('interaction switches show only meaningful controls', (t) async {
    await pumpRoute(t, 'chart-pie', 1440);
    expect(find.text('比例明细'), findsOneWidget);
    expect(find.text('同分类对比'), findsNothing);
    expect(find.text('坐标辅助线'), findsNothing);
    await pumpRoute(t, 'chart-scatter', 1440);
    expect(find.text('坐标辅助线'), findsOneWidget);
    expect(find.text('同分类对比'), findsNothing);
    await pumpRoute(t, 'chart-column', 1440);
    expect(find.textContaining('TooltipTrigger.axis'), findsOneWidget);
    final toggle = find.bySemanticsLabel('同分类对比');
    await reveal(t, toggle);
    expect(
      t.getSemantics(toggle).flagsCollection.isToggled,
      ui.Tristate.isTrue,
    );
    await t.tap(toggle);
    await t.pumpAndSettle();
    expect(
      t.getSemantics(toggle).flagsCollection.isToggled,
      ui.Tristate.isFalse,
    );
    expect(find.textContaining('TooltipTrigger.item'), findsOneWidget);
  });

  testWidgets('查看配置 reveals Dart for the drawn configuration', (t) async {
    await pumpRoute(t, 'chart-column', 1440);
    final summary = find.text('▶ 查看配置').first;
    await reveal(t, summary);
    await t.tap(summary);
    await t.pumpAndSettle();
    final code = t
        .widgetList<IslandCodeBlock>(find.byType(IslandCodeBlock))
        .map((block) => block.code)
        .firstWhere((code) => code.contains("title: '彩色单柱 · 果园收成'"));
    expect(code, contains('IslandChartData.column('));
    expect(code, contains("categories: const ['苹果', '香梨', '蜜桃', '樱桃']"));
    expect(
      code,
      contains("IslandChartValue(64, name: '苹果', color: Color(0xff3d9e88))"),
    );
    expect(code, contains('legend: false'));
    expect(code, contains('showLabels: true'));
    expect(find.text('▼ 查看配置'), findsOneWidget);
  });

  testWidgets('catalog cards and showcase links open their type page', (
    t,
  ) async {
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await t.pumpWidget(const IslandGallery());
    Future<void> push(String path) async {
      await t.binding.defaultBinaryMessenger.handlePlatformMessage(
        SystemChannels.navigation.name,
        SystemChannels.navigation.codec.encodeMethodCall(
          MethodCall('pushRouteInformation', {'location': path}),
        ),
        (_) {},
      );
      await t.pumpAndSettle();
    }

    await push('/charts');
    final card = find.bySemanticsLabel(RegExp('^雷达图 '));
    await reveal(t, card);
    await t.tap(card);
    await t.pumpAndSettle();
    expect(find.text('雷达图 · 海岛统计'), findsOneWidget);

    await push('/charts');
    final link = find.text('更多漏斗图示例');
    await reveal(t, link);
    await t.tap(link);
    await t.pumpAndSettle();
    expect(find.text('漏斗图 · 海岛统计'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });
}
