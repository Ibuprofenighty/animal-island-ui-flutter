import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/palette.dart';
import '../../shared/story.dart';
import 'chart/data.dart';
import 'chart/example.dart';
import 'chart/spec.dart';
import 'chart/widgets.dart';

/// Reference Chart `API`, adapted to the Flutter declarations; every type
/// page shares it.
const _api = [
  ('data', '19 种类型，每种一个命名构造，见左侧图表统计分类', 'IslandChartData', '必填'),
  ('series', '系列名称、data、颜色，mix 可配置系列 mode', 'List<IslandChartSeries>', '必填'),
  ('categories', '分类轴或雷达维度标签', 'List<String>', 'const []'),
  ('title / description', '图表标题与说明', 'String?', 'null'),
  ('height', '绘图区高度，最小 180', 'double', '300'),
  ('colors', '自定义配色，系列色和单点色优先', 'List<Color>?', '岛屿配色'),
  ('legend', '可筛选和悬浮联动的图例', 'bool', 'true'),
  (
    'tooltip',
    '提示配置，null 隐藏，见下方参数',
    'IslandChartTooltip?',
    'IslandChartTooltip()',
  ),
  (
    'tooltip.trigger',
    '同分类对比 / 单点提示，不支持分类的类型自动回退单点',
    'IslandChartTooltipTrigger',
    'axis',
  ),
  ('tooltip.crosshair / showPercentage', '坐标辅助线 / 占比及漏斗转化率', 'bool', 'true'),
  (
    'tooltip.builder',
    '自定义提示，收到 type、name、items、locked；返回 null 隐藏',
    'Widget? Function(BuildContext, IslandChartTooltipContext)?',
    'null',
  ),
  ('highlight / selectable', '悬浮高亮 / 点击锁定，方向键浏览数据，Esc 解除', 'bool', 'true'),
  ('stacked', '柱状、条状图正负值分别堆叠', 'bool', 'false'),
  ('smooth', '折线、面积、混合、时序图平滑连接；山峰图圆润峰顶', 'bool', 'false'),
  ('showAxes / showLabels', '坐标网格 / 数据标签', 'bool', 'true / false'),
  ('min / max', '值域；圆弧与仪表盘默认 0–100', 'double?', '自动'),
  (
    'valueFormatter / xFormatter',
    '数值 / 数值横轴格式化',
    'String Function(double)?',
    'null',
  ),
  ('regions', 'map 的平面轮廓，按 name 与数据关联', 'List<IslandChartRegion>', '-'),
  ('loading / empty', '加载状态 / 空态内容', 'bool / Widget?', 'false / 暂无数据'),
  ('animated', '入场淡入，遵循减少动态效果设置', 'bool', 'true'),
  ('backgroundColor / borderColor', '容器底色与边框，对应示例中的 style', 'Color?', 'null'),
  (
    'onDataActivate',
    '点击、Enter 或 Space 触发，携带原数据与下标',
    'ValueChanged<IslandChartDataEvent>?',
    'null',
  ),
];

/// Reference `ChartOverviewDemo` (route `charts`): showcase, basic overview
/// and the catalog of type pages.
class ChartOverviewStory extends StatelessWidget {
  const ChartOverviewStory({super.key});
  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width <= 900;
    final area = exampleSpec(IslandChartType.area).copyWith(smooth: true);
    final ring = exampleSpec(IslandChartType.ring);
    final overview = [
      area.chart(title: '一周到访趋势', height: 280),
      ring.chart(title: '岛屿分区占比', height: 280),
    ];
    final picks = [
      chartExamples[IslandChartType.column]![0],
      chartExamples[IslandChartType.line]![0],
      chartExamples[IslandChartType.ring]![0],
      chartExamples[IslandChartType.bar]![2],
      chartExamples[IslandChartType.radar]![2],
      chartExamples[IslandChartType.bubble]![1],
      chartExamples[IslandChartType.funnel]![0],
      chartExamples[IslandChartType.map]![2],
    ];
    return StoryPanel(
      title: '岛屿统计手账',
      children: [
        const ChartNote('19 种统计图形，共用岛屿配色、数据提示、图例筛选和键盘操作。以下均为演示数据。'),
        ChartGallerySection(
          precedingMargin: chartNoteSpaceAfter,
          semanticLabel: '图表样式精选',
          title: '图表样式精选',
          body: '从趋势、构成到分布与转化。每种图表另有 4 组样式示例，所有数据与地图均为虚构演示。',
          children: [
            for (final example in picks)
              ChartGalleryItem(
                example: example,
                link: (
                  '更多${chartPage(example.spec.type).label}示例',
                  'chart-${example.spec.type.name}',
                ),
              ),
          ],
        ),
        StoryLabel(
          '基础概览',
          spaceBefore: collapseMargin(20, chartGallerySpaceAfter),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 22,
                  children: overview,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 22,
                  children: [
                    Expanded(flex: 14, child: overview[0]),
                    Expanded(flex: 10, child: overview[1]),
                  ],
                ),
        ),
        exampleSpec(IslandChartType.column)
            .chart(title: '每日活动参与', description: '点击图例可单独查看一组数据', height: 280),
        Padding(
          padding: const EdgeInsets.only(top: 36),
          child: Semantics(
            container: true,
            label: '选择图表类型',
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final columns = width >= 1200
                    ? 4
                    : width >= 840
                    ? 3
                    : width >= 560
                    ? 2
                    : 1;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Semantics(
                        header: true,
                        child: const ChartLineText(
                          '选择图表类型',
                          style: TextStyle(
                            fontSize: 18,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            color: GalleryPalette.demoStrongInk,
                          ),
                        ),
                      ),
                    ),
                    ChartGrid(
                      columns: columns,
                      rowGap: 24,
                      columnGap: 24,
                      equalRows: true,
                      children: [
                        for (final page in chartPages)
                          ChartCatalogCard(
                            label: page.label,
                            desc: page.desc,
                            onPressed: () => openGalleryRoute(
                              context,
                              'chart-${page.type.name}',
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Reference `ChartTypeDemo` (route `chart-<type>`): style gallery, state
/// demo, boundary demo, configuration, interaction demo and API. One widget
/// serves all 19 types from their data tables.
class ChartTypeStory extends StatefulWidget {
  const ChartTypeStory({super.key, required this.type});
  final IslandChartType type;
  @override
  State<ChartTypeStory> createState() => _ChartTypeStoryState();
}

class _ChartTypeStoryState extends State<ChartTypeStory> {
  bool alternate = false, empty = false, loading = false, enhanced = false;
  String message = '点击图形查看数据；点击图例隐藏或恢复系列。';

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final page = chartPage(type);
    final example = exampleSpec(type, alternate: alternate);
    final supportsStack =
        type == IslandChartType.column || type == IslandChartType.bar;
    final supportsSmooth = const {
      IslandChartType.line,
      IslandChartType.area,
      IslandChartType.mix,
      IslandChartType.time,
    }.contains(type);
    final examples = chartExamples[type]!;
    final boundary = const {
      IslandChartType.column,
      IslandChartType.bar,
      IslandChartType.line,
      IslandChartType.area,
    }.contains(type);
    final shown = (empty ? example.empty : example).copyWith(
      stacked: supportsStack && enhanced,
      smooth: supportsSmooth && enhanced,
    );
    return StoryPanel(
      title: '${page.label} · 海岛统计',
      children: [
        ChartNote(
          '以下为虚构演示数据。'
          '${type == IslandChartType.map ? '地图为自绘岛屿分区，不代表真实行政区。' : page.desc}',
        ),
        if (type == IslandChartType.mount) const _MountCurveSection(),
        ChartGallerySection(
          precedingMargin: type == IslandChartType.mount
              ? chartGallerySpaceAfter
              : chartNoteSpaceAfter,
          semanticLabel: '图表样式与场景示例',
          title: '样式与场景',
          body: '${examples.length} 种独立示例，比较配色、布局和数据表达；悬浮读数，点击图例筛选，展开配置即可复用。',
          children: [
            for (final item in examples) ChartGalleryItem(example: item),
          ],
        ),
        StoryLabel(
          '基础示例与状态切换',
          spaceBefore: collapseMargin(20, chartGallerySpaceAfter),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _button('切换数据', () => alternate = !alternate),
              _button(empty ? '恢复数据' : '查看空态', () => empty = !empty),
              _button(loading ? '结束加载' : '查看加载态', () => loading = !loading),
              if (supportsStack || supportsSmooth)
                _button(
                  supportsStack
                      ? (enhanced ? '切换分组' : '切换堆叠')
                      : (enhanced ? '切换直线' : '切换曲线'),
                  () => enhanced = !enhanced,
                ),
            ],
          ),
        ),
        shown.chart(
          title: '岛屿${page.label}',
          description: page.desc,
          loading: loading,
          height: 320,
          onDataActivate: (event) => setState(
            () => message =
                '${event.seriesName} / ${event.name}：${plainNumber(event.value)}',
          ),
        ),
        ChartNote(message, status: true),
        if (boundary) ...[
          StoryLabel(
            '边界示例：负值、零值与缺测',
            spaceBefore: collapseMargin(20, chartNoteSpaceAfter),
          ),
          ChartSpec(
            type,
            categories: const ['周一', '周二', '周三', '周四', '周五'],
            series: [
              IslandChartSeries.values('净变化', const [18, -12, null, 0, 26]),
            ],
          ).chart(title: '盈余与支出', height: 240),
        ],
        // Its 16px bottom margin collapses into the interaction section's
        // 32px top margin.
        StoryCode(
          example.code(),
          spaceBefore: boundary ? 36 : collapseMargin(36, chartNoteSpaceAfter),
        ),
        _InteractionSection(type: type),
        const StoryApi(rows: _api),
      ],
    );
  }

  Widget _button(String label, VoidCallback change) => IslandButton(
    size: IslandSize.small,
    onPressed: () => setState(change),
    child: Text(label),
  );
}

/// Reference `MountCurveDemo`: pointed and rounded summits side by side.
class _MountCurveSection extends StatelessWidget {
  const _MountCurveSection();
  static final _spec = ChartSpec(
    IslandChartType.mount,
    categories: const ['果园', '海岸', '营地', '花田'],
    series: [
      IslandChartSeries(
        name: '到访人数',
        data: namedPoints(['果园', '海岸', '营地', '花田'], [58, 86, 42, 68], meadow),
      ),
    ],
    min: 0,
    max: 100,
    legend: false,
    showLabels: true,
    height: 240,
  );
  @override
  Widget build(BuildContext context) => ChartGallerySection(
    precedingMargin: chartNoteSpaceAfter,
    semanticLabel: '山峰弧度对照示例',
    title: '新增示例：圆润山峰',
    body: '同一组数据，对照尖顶与圆弧峰顶。圆润轮廓从山脚平滑过渡至峰顶，数值高度保持一致。',
    comparison: true,
    footer: ChartActions(
      disclosure: '查看圆润山峰配置',
      code: _spec.copyWith(smooth: true).code(title: '圆润山峰'),
    ),
    children: [
      _spec.chart(title: '默认尖顶', description: '保留原有山峰轮廓。'),
      _spec
          .copyWith(smooth: true)
          .chart(title: '圆弧峰顶', description: '平滑的坡面与圆润峰顶，适合柔和的海岛统计。'),
    ],
  );
}

/// Reference `ChartInteractionDemo` notes per statistical meaning.
const _details = {
  IslandChartType.pie: '提示包含当前可见数据的占比；隐藏图例后占比随可见合计更新。',
  IslandChartType.ring: '圆心展示可见合计，提示展示单项占比；锁定后可稳定对照数值。',
  IslandChartType.rose: '扇区面积表示数值，提示同时列出数值与可见数据占比。',
  IslandChartType.funnel: '保持业务阶段顺序，提示展示相对首阶段比例与相对上一可见阶段的转化率。',
  IslandChartType.candle: '提示保留开、收、低、高四个值，辅助线便于按日期对照。',
  IslandChartType.time: '同时间戳的数据才参与对比，不同采样时间不会按数组下标混合。',
  IslandChartType.scatter: '提示展示横纵坐标，双向辅助线帮助定位散点。',
  IslandChartType.bubble: '提示保留横纵坐标和权重，气泡面积仍与权重成正比。',
  IslandChartType.radar: '同一维度可同时比较各系列；悬浮图例可单独突出对应多边形。',
  IslandChartType.map: '悬浮区域或对应图例可突出分区，点击可锁定统计值。轮廓为虚构岛屿。',
  IslandChartType.word: '悬浮词条或图例突出权重，未放入图面的词条仍保留在数据明细中。',
  IslandChartType.gauge: '指针限定在量程内，提示保留原始读数；点击锁定后可继续查看明细。',
  IslandChartType.arcbar: '每个可见系列的首个有效值作为指标，提示保留原始数值。',
};

class _InteractionSection extends StatefulWidget {
  const _InteractionSection({required this.type});
  final IslandChartType type;
  @override
  State<_InteractionSection> createState() => _InteractionSectionState();
}

class _InteractionSectionState extends State<_InteractionSection> {
  bool shared = true, highlight = true, selectable = true;
  bool crosshair = true, percentage = true;
  String message = '尚未点击数据';

  @override
  Widget build(BuildContext context) {
    final type = widget.type;
    final axis = const {
      IslandChartType.column,
      IslandChartType.bar,
      IslandChartType.line,
      IslandChartType.area,
      IslandChartType.mount,
      IslandChartType.mix,
      IslandChartType.candle,
      IslandChartType.time,
      IslandChartType.radar,
    }.contains(type);
    final proportion = const {
      IslandChartType.pie,
      IslandChartType.ring,
      IslandChartType.rose,
      IslandChartType.funnel,
    }.contains(type);
    final toggles = [
      ('同分类对比', shared, (bool v) => shared = v, axis),
      ('悬浮高亮', highlight, (bool v) => highlight = v, true),
      ('点击锁定', selectable, (bool v) => selectable = v, true),
      (
        '坐标辅助线',
        crosshair,
        (bool v) => crosshair = v,
        (axis && type != IslandChartType.radar) ||
            type == IslandChartType.scatter ||
            type == IslandChartType.bubble,
      ),
      ('比例明细', percentage, (bool v) => percentage = v, proportion),
    ];
    final trigger = shared ? 'axis' : 'item';
    return Container(
      // Reference `margin: 32px 0`, collapsed with the preceding code
      // block's 16px bottom margin above and, through the section's open
      // bottom edge, with its own last code block and the API table's top
      // margin below (32 in all).
      margin: const EdgeInsets.only(
        top: 32 - 16,
        bottom: 32 - StoryApi.spaceBefore,
      ),
      padding: const EdgeInsets.only(top: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GalleryPalette.rule)),
      ),
      child: Semantics(
        container: true,
        label: '新增图表交互示例',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ChartSectionTitle('新增示例：悬浮对比与锁定读数'),
            ChartNote(_details[type] ?? '移入绘图区即可读取同分类的多个系列，无需精确碰到柱体或折线点。'),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final (name, value, change, show) in toggles)
                    if (show)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () => setState(() => change(!value)),
                            child: ExcludeSemantics(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: GalleryPalette.storyInk,
                                ),
                              ),
                            ),
                          ),
                          IslandSwitch(
                            label: name,
                            showLabel: false,
                            small: true,
                            value: value,
                            onChanged: (next) => setState(() => change(next)),
                          ),
                        ],
                      ),
                ],
              ),
            ),
            exampleSpec(type).chart(
              title: '交互细节体验',
              height: 320,
              description: '悬浮图例突出数据；点击图例筛选。聚焦图形后可用方向键逐项浏览。',
              highlight: highlight,
              selectable: selectable,
              tooltip: IslandChartTooltip(
                trigger: shared
                    ? IslandChartTooltipTrigger.axis
                    : IslandChartTooltipTrigger.item,
                crosshair: crosshair,
                showPercentage: percentage,
              ),
              onDataActivate: (point) => setState(
                () => message =
                    '${point.seriesName} / ${point.name}：${plainNumber(point.value)}',
              ),
            ),
            ChartNote('最近点击：$message。Enter / 空格锁定，Esc 解除。', status: true),
            StoryCode(
              spaceBefore: collapseMargin(36, chartNoteSpaceAfter),
              spaceAfter: 0,
              'IslandChart(\n'
              '  data: data,\n'
              '  highlight: $highlight,\n'
              '  selectable: $selectable,\n'
              '  tooltip: const IslandChartTooltip(\n'
              '    trigger: IslandChartTooltipTrigger.$trigger,\n'
              '    crosshair: $crosshair,\n'
              '    showPercentage: $percentage,\n'
              '  ),\n'
              ')\n\n'
              '// 自定义提示（tooltip.items 包含原数据、格式化值、颜色及适用的比例）\n'
              'IslandChart(\n'
              '  data: data,\n'
              '  tooltip: IslandChartTooltip(\n'
              '    builder: (context, tooltip) => Column(\n'
              '      crossAxisAlignment: CrossAxisAlignment.start,\n'
              '      children: [\n'
              '        Text(tooltip.name, style: const TextStyle(fontWeight: FontWeight.bold)),\n'
              '        for (final item in tooltip.items)\n'
              r"          Text('${item.seriesName}：${item.formattedValue}'),"
              '\n'
              '      ],\n'
              '    ),\n'
              '  ),\n'
              ')',
            ),
          ],
        ),
      ),
    );
  }
}
