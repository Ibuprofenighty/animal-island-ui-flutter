import 'dart:ui' as ui;

import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/main.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/stories/chart/widgets.dart';
import 'package:island_gallery/shared/catalog.dart';
import 'package:island_gallery/shared/palette.dart';
import 'package:island_gallery/shared/story.dart';
import 'package:island_gallery/shared/theme.dart';

final chartEntries = galleryGroups['图表统计']!;

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

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
        expect(find.text('查看配置'), findsNWidgets(4));
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
    final semantics = t.ensureSemantics();
    await pumpRoute(t, 'chart-column', 1440);
    final summary = find.text('查看配置').first;
    expect(
      t
          .getSemantics(find.bySemanticsLabel('查看配置').first)
          .flagsCollection
          .isExpanded,
      ui.Tristate.isFalse,
    );
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
    expect(
      t
          .getSemantics(find.bySemanticsLabel('查看配置').first)
          .flagsCollection
          .isExpanded,
      ui.Tristate.isTrue,
    );
    // Reference `.code[open] summary { margin-bottom: 8px }` collapsed with
    // the library CodeBlock `margin: 1em 0` at 12px: 12 above and below.
    final block = find.byWidgetPredicate(
      (w) => w is IslandCodeBlock && w.code.contains('彩色单柱 · 果园收成'),
    );
    expect(
      t.widget<IslandCodeBlock>(block).margin,
      const EdgeInsets.symmetric(vertical: 12),
    );
    semantics.dispose();
  });

  testWidgets('type page blocks collapse their CSS margins as the reference '
      'does', (t) async {
    await pumpRoute(t, 'chart-column', 1440);
    double top(Finder f) => t.getRect(f).top;
    double bottom(Finder f) => t.getRect(f).bottom;
    // .note (margin-bottom 20) -> .gallery (margin-top 24): 24.
    expect(
      top(find.text('样式与场景')) - bottom(find.textContaining('以下为虚构演示数据。')),
      moreOrLessEquals(24, epsilon: 0.01),
    );
    // Status .note (20) -> label (marginTop 20): 20.
    expect(
      top(find.text('边界示例：负值、零值与缺测')) -
          bottom(find.text('点击图形查看数据；点击图例隐藏或恢复系列。')),
      moreOrLessEquals(20, epsilon: 0.01),
    );
    // Boundary chart -> demo CodeBlock (marginTop 36): 36 above the 使用示例
    // tab (6px label padding).
    final tabs = find.text('使用示例');
    expect(tabs, findsNWidgets(2));
    expect(
      top(tabs.first) - 6 - bottom(find.widgetWithText(IslandChart, '盈余与支出')),
      moreOrLessEquals(36, epsilon: 0.01),
    );
    // CodeBlock 1em bottom -> .interaction-demo (margin 32, border 1,
    // padding-top 24).
    final blocks = find.descendant(
      of: find.byType(StoryCode),
      matching: find.byType(IslandCodeBlock),
    );
    expect(
      top(find.text('新增示例：悬浮对比与锁定读数')) - bottom(blocks.first),
      moreOrLessEquals(32 + 1 + 24, epsilon: 0.01),
    );
    // Interaction CodeBlock (1em) -> section end (32) -> ApiTable (24): 32.
    expect(
      top(find.text('API')) - 6 - bottom(blocks.last),
      moreOrLessEquals(32, epsilon: 0.01),
    );

    // Without a boundary demo the status note precedes the code block.
    await pumpRoute(t, 'chart-pie', 1440);
    expect(
      top(find.text('使用示例').first) -
          6 -
          bottom(find.text('点击图形查看数据；点击图例隐藏或恢复系列。')),
      moreOrLessEquals(36, epsilon: 0.01),
    );

    // Mount: the MountCurve gallery (margin-bottom 32) -> the style gallery
    // (margin-top 24): 32 below its rule, which sits 28px under the actions.
    await pumpRoute(t, 'chart-mount', 1440);
    expect(
      top(find.text('样式与场景')) -
          bottom(
            find.ancestor(
              of: find.text('查看圆润山峰配置'),
              matching: find.byType(ChartPressable),
            ),
          ),
      moreOrLessEquals(28 + 1 + 32, epsilon: 0.01),
    );
    expect(
      top(find.text('新增示例：圆润山峰')) - bottom(find.textContaining('以下为虚构演示数据。')),
      moreOrLessEquals(24, epsilon: 0.01),
    );
  });

  testWidgets('gallery inks are the reference theme variables, deepened to '
      '4.5:1 where they fail', (t) async {
    await pumpRoute(t, 'charts', 1440);
    Color ink(Finder f) =>
        (t.renderObject<RenderParagraph>(f).text as TextSpan).style!.color!;
    const white = GalleryPalette.demoSurface;
    final body = ink(find.textContaining('从趋势、构成到分布与转化。'));
    expect(body, GalleryPalette.chartGalleryBody);
    expect(contrast(body, white), greaterThanOrEqualTo(4.5));
    final link = ink(find.text('更多柱状图示例'));
    expect(link, GalleryPalette.chartActionInk);
    for (final surface in [white, GalleryPalette.chartActionHover]) {
      expect(contrast(link, surface), greaterThanOrEqualTo(4.5));
    }
    // `<details class="animal-code">` takes `--animal-text-color` #794f27.
    expect(ink(find.text('查看配置').first), GalleryPalette.demoStrongInk);
    expect(ink(find.text('选择图表类型')), GalleryPalette.demoStrongInk);
    final card = ink(find.text(chartEntries[1].description));
    expect(card, GalleryPalette.chartCatalogBody);
    for (final surface in [
      IslandTokens.light.paper,
      GalleryPalette.chartCatalogHover,
    ]) {
      expect(contrast(card, surface), greaterThanOrEqualTo(4.5));
    }
  });

  for (final width in [1440.0, 375.0]) {
    testWidgets('catalog rows are all as tall as the tallest at $width', (
      t,
    ) async {
      await pumpRoute(t, 'charts', width);
      final cards = find.byType(ChartCatalogCard);
      expect(cards, findsNWidgets(19));
      final heights = {
        for (final card in cards.evaluate())
          t.getSize(find.byWidget(card.widget)).height,
      };
      expect(heights, hasLength(1));
      // At one column the two-line cards set the height of the one-line ones.
      if (width == 375) expect(heights.single, greaterThan(110));
    });
  }

  testWidgets('a line mixing Latin and CJK is as tall as an all-CJK line', (
    t,
  ) async {
    await pumpRoute(t, 'chart-radar', 1440);
    expect(
      t.getSize(find.text('将量程设为 0–5，适配同单位的评分数据。')).height,
      t.getSize(find.text('三个分区共用六个维度，可通过图例单独观察。')).height,
    );
    expect(
      t.getSize(find.textContaining('4 种独立示例')).height,
      moreOrLessEquals(13 * 1.8, epsilon: 0.5),
    );
  });

  testWidgets('a hovered catalog card lifts 2px; a press drops the lift', (
    t,
  ) async {
    var opened = 0;
    // A desktop host: hover highlights show in the traditional mode.
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(
      () => FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.automatic,
    );
    await t.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        home: Center(
          child: SizedBox(
            width: 300,
            child: ChartCatalogCard(
              label: '雷达图',
              desc: '多维指标对比。',
              onPressed: () => opened++,
            ),
          ),
        ),
      ),
    );
    final title = find.text('雷达图');
    final rest = t.getRect(title).top;
    final pointer = await t.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    addTearDown(pointer.removePointer);
    await pointer.moveTo(t.getCenter(title));
    await t.pumpAndSettle();
    expect(t.getRect(title).top, moreOrLessEquals(rest - 2, epsilon: 0.01));
    // Reference `a:active { transform: translateY(0) }`.
    await pointer.down(t.getCenter(title));
    await t.pumpAndSettle();
    expect(t.getRect(title).top, moreOrLessEquals(rest, epsilon: 0.01));
    await pointer.up();
    await t.pumpAndSettle();
    expect(opened, 1);
    expect(t.getRect(title).top, moreOrLessEquals(rest - 2, epsilon: 0.01));
  });

  testWidgets('a map region without data reads 星沙岛：暂无数据', (t) async {
    final semantics = t.ensureSemantics();
    await pumpRoute(t, 'chart-map', 1440);
    expect(find.bySemanticsLabel('星沙岛：暂无数据'), findsWidgets);
    semantics.dispose();
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

    // Keyboard: Space on a focused link does not follow it; Enter does.
    await push('/charts');
    final keyCard = find.bySemanticsLabel(RegExp('^雷达图 '));
    await reveal(t, keyCard);
    Focus.of(
      t.element(
        find.descendant(of: keyCard, matching: find.byType(ExcludeSemantics)),
      ),
    ).requestFocus();
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pumpAndSettle();
    expect(find.text('雷达图 · 海岛统计'), findsNothing);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
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
