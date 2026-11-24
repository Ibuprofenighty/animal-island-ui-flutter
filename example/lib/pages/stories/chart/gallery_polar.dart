import 'package:animal_island_ui/animal_island_ui.dart';

import '../../../shared/palette.dart';
import 'data.dart';
import 'example.dart';
import 'spec.dart';

/// Reference gallery-polar.ts: labels, palettes, dimension counts and units.
final polarExamples = <IslandChartType, List<ChartExample>>{
  IslandChartType.pie: [
    ChartExample(
      'labels',
      '彩色标签 · 岛屿分区',
      '扇区外直接显示名称，图例用于筛选区域。',
      ChartSpec(
        IslandChartType.pie,
        colors: meadow,
        showLabels: true,
        series: [
          IslandChartSeries(
            name: '面积',
            data: namedPoints(['果园', '海岸', '营地', '花田'], [38, 27, 21, 14]),
          ),
        ],
      ),
    ),
    ChartExample(
      'tonal',
      '同色层次 · 林地植被',
      '以深浅草绿区分四类植被，保留同一视觉基调。',
      ChartSpec(
        IslandChartType.pie,
        colors: forest,
        surface: mintSurface,
        series: [
          IslandChartSeries(
            name: '覆盖面积',
            data: namedPoints(['乔木', '灌木', '草地', '苔藓'], [48, 26, 18, 8]),
          ),
        ],
      ),
    ),
    ChartExample(
      'binary',
      '双色占比 · 预约方式',
      '两项数据清楚对照，悬浮查看各自占比。',
      ChartSpec(
        IslandChartType.pie,
        colors: [sunset[0], sunset[1]],
        showLabels: true,
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '预约人数',
            data: namedPoints(['线上', '现场'], [68, 32]),
          ),
        ],
      ),
    ),
    ChartExample(
      'compact',
      '无图例 · 花田构成',
      '外侧名称代替底部图例，适合紧凑的概览区域。',
      ChartSpec(
        IslandChartType.pie,
        colors: flowers,
        showLabels: true,
        legend: false,
        surface: blossomSurface,
        series: [
          IslandChartSeries(
            name: '花株数量',
            data: namedPoints(['雏菊', '郁金香', '绣球'], [42, 35, 23]),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.ring: [
    ChartExample(
      'composition',
      '多色圆环 · 活动参与',
      '中心显示当前可见合计，底部图例可独立筛选。',
      ChartSpec(
        IslandChartType.ring,
        colors: meadow,
        series: [
          IslandChartSeries(
            name: '参与人数',
            data: namedPoints(['采果', '露营', '手作', '观星'], [86, 64, 42, 28]),
          ),
        ],
      ),
    ),
    ChartExample(
      'goal',
      '双色圆环 · 植树计划',
      '已完成与待完成组成整环，总目标为 100%。',
      ChartSpec(
        IslandChartType.ring,
        colors: [forest[0], GalleryPalette.chartRingRemainder],
        format: ChartFormat.percent,
        surface: mintSurface,
        series: [
          IslandChartSeries(
            name: '计划占比',
            data: namedPoints(['已完成', '待完成'], [76, 24]),
          ),
        ],
      ),
    ),
    ChartExample(
      'labels',
      '暖色标注 · 集市收入',
      '外侧标注摊位，中央汇总本次集市收入。',
      ChartSpec(
        IslandChartType.ring,
        colors: sunset,
        showLabels: true,
        legend: false,
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '营收',
            data: namedPoints(['鲜果', '甜品', '手作'], [380, 260, 180]),
          ),
        ],
      ),
    ),
    ChartExample(
      'single',
      '完整圆环 · 全部归还',
      '单项占满整环，适合展示构成只有一项的结果。',
      ChartSpec(
        IslandChartType.ring,
        colors: [flowers[0]],
        legend: false,
        surface: blossomSurface,
        series: const [
          IslandChartSeries(
            name: '归还状态',
            data: [IslandChartValue(48, name: '已归还')],
          ),
        ],
      ),
    ),
  ],
  IslandChartType.rose: [
    ChartExample(
      'seasons',
      '四季玫瑰 · 花田开放',
      '等角扇区，以面积表达四季的开放花株数。',
      ChartSpec(
        IslandChartType.rose,
        colors: flowers,
        showLabels: true,
        series: [
          IslandChartSeries(
            name: '开放花株',
            data: namedPoints(['春', '夏', '秋', '冬'], [92, 64, 48, 24]),
          ),
        ],
      ),
    ),
    ChartExample(
      'six-petals',
      '六瓣玫瑰 · 海岛体验',
      '增加分类数量，比较六种活动的人气差异。',
      ChartSpec(
        IslandChartType.rose,
        colors: [...sunset, meadow[0]],
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '参与人数',
            data: namedPoints(
              ['露营', '采果', '观星', '手作', '野餐', '拾贝'],
              [84, 62, 46, 72, 54, 38],
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'forest',
      '同色玫瑰 · 林间观察',
      '深浅薄荷色搭配区域名称，弱化多色干扰。',
      ChartSpec(
        IslandChartType.rose,
        colors: forest,
        showLabels: true,
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries(
            name: '观察次数',
            data: namedPoints(['东林', '西林', '南林', '北林'], [42, 78, 56, 90]),
          ),
        ],
      ),
    ),
    ChartExample(
      'balanced',
      '均衡玫瑰 · 志愿分工',
      '接近的数值形成较均衡的轮廓，悬浮读取细微差异。',
      ChartSpec(
        IslandChartType.rose,
        colors: flowers,
        surface: blossomSurface,
        series: [
          IslandChartSeries(
            name: '志愿时数',
            data: namedPoints(
              ['引导', '清洁', '养护', '讲解', '布置'],
              [42, 46, 40, 48, 44],
            ),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.radar: [
    ChartExample(
      'single',
      '单系列 · 营地体验',
      '五个维度采用同一百分制，轮廓展示整体表现。',
      ChartSpec(
        IslandChartType.radar,
        categories: const ['环境', '设施', '交通', '服务', '安静'],
        max: 100,
        colors: forest,
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('营地体验', const [92, 74, 60, 86, 94]),
        ],
      ),
    ),
    ChartExample(
      'comparison',
      '双轮廓 · 新旧营地',
      '薄荷与蜜桃重叠对比，悬浮维度读取双方得分。',
      ChartSpec(
        IslandChartType.radar,
        categories: const ['环境', '设施', '交通', '服务', '安静'],
        max: 100,
        colors: [meadow[0], sunset[0]],
        series: [
          IslandChartSeries.values('新营地', const [88, 92, 65, 80, 72]),
          IslandChartSeries.values('旧营地', const [72, 60, 88, 86, 92]),
        ],
      ),
    ),
    ChartExample(
      'six-dimensions',
      '六维对照 · 区域评分',
      '三个分区共用六个维度，可通过图例单独观察。',
      ChartSpec(
        IslandChartType.radar,
        categories: const ['生态', '景观', '服务', '交通', '设施', '活力'],
        max: 100,
        colors: [flowers[0], sunset[0], meadow[0]],
        surface: creamSurface,
        series: [
          IslandChartSeries.values('海岸', const [72, 96, 82, 68, 60, 88]),
          IslandChartSeries.values('花田', const [90, 86, 64, 80, 70, 72]),
          IslandChartSeries.values('森林', const [96, 78, 70, 58, 82, 66]),
        ],
      ),
    ),
    ChartExample(
      'rating',
      '四维星评 · 手作课程',
      '将量程设为 0–5，适配同单位的评分数据。',
      ChartSpec(
        IslandChartType.radar,
        categories: const ['内容', '节奏', '氛围', '收获'],
        min: 0,
        max: 5,
        colors: flowers,
        surface: blossomSurface,
        series: [
          IslandChartSeries.values('陶艺', const [4.8, 3.6, 4.6, 4.2]),
          IslandChartSeries.values('花艺', const [4.2, 4.8, 3.8, 4.6]),
        ],
      ),
    ),
  ],
  IslandChartType.arcbar: [
    ChartExample(
      'single',
      '单项进度 · 花田养护',
      '单个圆弧展示当前完成率，隐藏重复图例。',
      ChartSpec(
        IslandChartType.arcbar,
        min: 0,
        max: 100,
        colors: forest,
        legend: false,
        format: ChartFormat.percent,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('养护进度', const [78]),
        ],
      ),
    ),
    ChartExample(
      'pair',
      '双项对照 · 海岛建设',
      '两个圆弧分别读取，使用薄荷与蜜桃区分任务。',
      ChartSpec(
        IslandChartType.arcbar,
        colors: [meadow[0], sunset[0]],
        format: ChartFormat.percent,
        series: [
          IslandChartSeries.values('植树', const [82]),
          IslandChartSeries.values('修路', const [56]),
        ],
      ),
    ),
    ChartExample(
      'three',
      '三项概览 · 今日任务',
      '三种颜色并列展示同量程指标，适合紧凑概览。',
      ChartSpec(
        IslandChartType.arcbar,
        colors: [flowers[0], sunset[0], meadow[0]],
        format: ChartFormat.percent,
        legend: false,
        surface: creamSurface,
        series: [
          IslandChartSeries.values('清洁', const [92]),
          IslandChartSeries.values('浇水', const [68]),
          IslandChartSeries.values('布置', const [45]),
        ],
      ),
    ),
    ChartExample(
      'quantity',
      '数量目标 · 图书收集',
      '量程改为 200，中心显示实际本数而非百分比。',
      ChartSpec(
        IslandChartType.arcbar,
        min: 0,
        max: 200,
        colors: [flowers[0]],
        legend: false,
        surface: blossomSurface,
        series: [
          IslandChartSeries.values('图书本数', const [146]),
        ],
      ),
    ),
  ],
  IslandChartType.gauge: [
    ChartExample(
      'comfort',
      '薄荷仪表 · 舒适指数',
      '默认百分比量程，当前读数与刻度使用同一单位。',
      ChartSpec(
        IslandChartType.gauge,
        colors: forest,
        min: 0,
        max: 100,
        format: ChartFormat.percent,
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('舒适指数', const [86]),
        ],
      ),
    ),
    ChartExample(
      'capacity',
      '暖色仪表 · 营位使用',
      '暖色强调较高占用，当前读数为 92%。',
      ChartSpec(
        IslandChartType.gauge,
        colors: [sunset[0]],
        min: 0,
        max: 100,
        format: ChartFormat.percent,
        legend: false,
        surface: creamSurface,
        series: [
          IslandChartSeries.values('营位使用率', const [92]),
        ],
      ),
    ),
    ChartExample(
      'temperature',
      '温度仪表 · 林间气温',
      '自定义 -10 至 40°C 的量程，刻度支持负数。',
      ChartSpec(
        IslandChartType.gauge,
        colors: [flowers[0]],
        min: -10,
        max: 40,
        format: ChartFormat.temperature,
        legend: false,
        surface: blossomSurface,
        series: [
          IslandChartSeries.values('当前气温', const [24]),
        ],
      ),
    ),
    ChartExample(
      'time-budget',
      '时长仪表 · 今日阅读',
      '量程为 0–120 分钟，使用自定义数值格式。',
      ChartSpec(
        IslandChartType.gauge,
        colors: [meadow[2]],
        min: 0,
        max: 120,
        format: ChartFormat.minutes,
        legend: false,
        series: [
          IslandChartSeries.values('阅读时长', const [48]),
        ],
      ),
    ),
  ],
};
