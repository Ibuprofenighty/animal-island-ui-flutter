import 'package:animal_island_ui/animal_island_ui.dart';

import 'data.dart';
import 'example.dart';
import 'spec.dart';

/// Reference gallery-cartesian.ts: structure, palette and density variants.
final cartesianExamples = <IslandChartType, List<ChartExample>>{
  IslandChartType.column: [
    ChartExample(
      'harvest',
      '彩色单柱 · 果园收成',
      '每种水果独立配色，直接标注采收数量。',
      ChartSpec(
        IslandChartType.column,
        categories: const ['苹果', '香梨', '蜜桃', '樱桃'],
        legend: false,
        showLabels: true,
        max: 100,
        series: [
          IslandChartSeries(
            name: '采收数量',
            data: namedPoints(
              ['苹果', '香梨', '蜜桃', '樱桃'],
              [64, 85, 52, 73],
              meadow,
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'grouped',
      '多系列分组 · 活动预约',
      '薄荷、蜜桃与花紫，对比三类活动的预约量。',
      ChartSpec(
        IslandChartType.column,
        categories: const ['周五', '周六', '周日'],
        colors: [meadow[0], sunset[0], flowers[0]],
        surface: creamSurface,
        series: [
          IslandChartSeries.values('露营', const [28, 54, 42]),
          IslandChartSeries.values('野餐', const [38, 45, 62]),
          IslandChartSeries.values('观星', const [18, 32, 48]),
        ],
      ),
    ),
    ChartExample(
      'stacked',
      '暖色堆叠 · 集市营收',
      '同一根柱子查看总量，悬浮比较各摊位贡献。',
      ChartSpec(
        IslandChartType.column,
        categories: const ['一月', '二月', '三月', '四月'],
        colors: sunset,
        stacked: true,
        surface: blossomSurface,
        series: [
          IslandChartSeries.values('鲜果', const [32, 48, 42, 58]),
          IslandChartSeries.values('甜品', const [24, 28, 38, 32]),
          IslandChartSeries.values('手作', const [16, 22, 18, 28]),
        ],
      ),
    ),
    ChartExample(
      'diverging',
      '正负对比 · 物资变化',
      '收入与消耗分列零线两侧，保留真实正负值。',
      ChartSpec(
        IslandChartType.column,
        categories: const ['木材', '种子', '石料', '布料'],
        colors: [meadow[0], sunset[0]],
        series: [
          IslandChartSeries.values('补充', const [42, 28, 54, 36]),
          IslandChartSeries.values('消耗', const [-26, -18, -32, -20]),
        ],
      ),
    ),
  ],
  IslandChartType.bar: [
    ChartExample(
      'ranking',
      '单色排名 · 步道人气',
      '按到访量排列，让较长的地点名称也容易阅读。',
      ChartSpec(
        IslandChartType.bar,
        categories: const ['海风步道', '森林小径', '日落栈桥', '花田环线'],
        colors: forest,
        legend: false,
        max: 120,
        series: [
          IslandChartSeries.values('到访人数', const [102, 86, 65, 42]),
        ],
      ),
    ),
    ChartExample(
      'grouped',
      '双组对照 · 周末到访',
      '暖色背景搭配两组条形，比较不同区域的变化。',
      ChartSpec(
        IslandChartType.bar,
        categories: const ['果园', '海岸', '营地'],
        colors: [sunset[0], flowers[0]],
        surface: creamSurface,
        series: [
          IslandChartSeries.values('本周', const [72, 94, 58]),
          IslandChartSeries.values('上周', const [54, 68, 70]),
        ],
      ),
    ),
    ChartExample(
      'share',
      '百分比堆叠 · 预约来源',
      '各行合计 100%，对比不同渠道的构成。',
      ChartSpec(
        IslandChartType.bar,
        categories: const ['露营', '野餐', '观星', '采果'],
        colors: meadow,
        stacked: true,
        max: 100,
        format: ChartFormat.percent,
        series: [
          IslandChartSeries.values('提前预约', const [60, 45, 75, 50]),
          IslandChartSeries.values('现场报名', const [25, 40, 15, 30]),
          IslandChartSeries.values('团体安排', const [15, 15, 10, 20]),
        ],
      ),
    ),
    ChartExample(
      'balance',
      '双向条形 · 预算结余',
      '用单点颜色区分结余与超支，突出零线。',
      ChartSpec(
        IslandChartType.bar,
        categories: const ['花田', '营地', '步道', '集市'],
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries(
            name: '预算结余',
            data: namedPoints(['花田', '营地', '步道', '集市'], [32, -18, 48, -26], [
              meadow[0],
              sunset[0],
              meadow[0],
              sunset[0],
            ]),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.line: [
    ChartExample(
      'smooth',
      '柔和曲线 · 一周到访',
      '双系列平滑连接，适合观察整体趋势。',
      ChartSpec(
        IslandChartType.line,
        categories: const ['一', '二', '三', '四', '五', '六', '日'],
        smooth: true,
        colors: [meadow[0], sunset[0]],
        series: [
          IslandChartSeries.values('海岸', const [22, 38, 30, 52, 45, 78, 64]),
          IslandChartSeries.values('森林', const [16, 24, 36, 28, 42, 55, 48]),
        ],
      ),
    ),
    ChartExample(
      'labels',
      '标记折线 · 每月新成员',
      '保留折点与数值，适合读取少量关键指标。',
      ChartSpec(
        IslandChartType.line,
        categories: const ['一月', '二月', '三月', '四月', '五月'],
        colors: [flowers[0]],
        showLabels: true,
        legend: false,
        max: 100,
        surface: blossomSurface,
        series: [
          IslandChartSeries.values('新成员', const [24, 42, 36, 68, 82]),
        ],
      ),
    ),
    ChartExample(
      'minimal',
      '无网格曲线 · 阅读时长',
      '隐藏坐标和图例，悬浮仍能读取日期与分钟数。',
      ChartSpec(
        IslandChartType.line,
        categories: const ['周一', '周二', '周三', '周四', '周五', '周六'],
        colors: forest,
        smooth: true,
        showAxes: false,
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('阅读分钟', const [15, 32, 24, 45, 38, 60]),
        ],
      ),
    ),
    ChartExample(
      'gaps',
      '缺测断点 · 环境观察',
      '缺失记录保留断口，不把未知数据补成零。',
      ChartSpec(
        IslandChartType.line,
        categories: const ['一', '二', '三', '四', '五', '六', '日'],
        colors: [sunset[0], flowers[0]],
        series: [
          IslandChartSeries.values('海岸', const [62, 70, null, 78, 68, 82, 76]),
          IslandChartSeries.values('林地', const [48, 58, 64, 56, null, 70, 66]),
        ],
      ),
    ),
  ],
  IslandChartType.area: [
    ChartExample(
      'smooth',
      '薄荷面积 · 到访走势',
      '单系列曲线与柔和填充，强调趋势和体量。',
      ChartSpec(
        IslandChartType.area,
        categories: const ['一', '二', '三', '四', '五', '六', '日'],
        colors: forest,
        smooth: true,
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('到访人数', const [24, 42, 34, 58, 48, 86, 72]),
        ],
      ),
    ),
    ChartExample(
      'comparison',
      '多色叠映 · 区域热度',
      '面积透明叠映，三条曲线分别读取，不做堆叠。',
      ChartSpec(
        IslandChartType.area,
        categories: const ['春', '夏', '秋', '冬'],
        colors: [flowers[0], sunset[0], meadow[0]],
        smooth: true,
        series: [
          IslandChartSeries.values('海岸', const [35, 88, 62, 28]),
          IslandChartSeries.values('花田', const [78, 52, 45, 22]),
          IslandChartSeries.values('森林', const [42, 65, 80, 45]),
        ],
      ),
    ),
    ChartExample(
      'minimal',
      '暖色留白 · 采收节奏',
      '隐藏网格、保留关键数值，适合概览中的趋势块。',
      ChartSpec(
        IslandChartType.area,
        categories: const ['第一批', '第二批', '第三批', '第四批'],
        colors: sunset,
        legend: false,
        showAxes: false,
        showLabels: true,
        max: 100,
        surface: creamSurface,
        series: [
          IslandChartSeries.values('采收篮数', const [28, 54, 42, 76]),
        ],
      ),
    ),
    ChartExample(
      'signed',
      '跨零面积 · 库存净变化',
      '以零为基线，正负面积表达补充和消耗。',
      ChartSpec(
        IslandChartType.area,
        categories: const ['一', '二', '三', '四', '五', '六'],
        colors: [flowers[0]],
        legend: false,
        series: [
          IslandChartSeries.values('净变化', const [30, 12, -24, -10, 28, 46]),
        ],
      ),
    ),
  ],
  IslandChartType.mount: [
    ChartExample(
      'colored',
      '彩色山丘 · 分区人气',
      '不同区域用独立颜色，山丘高度代表到访量。',
      ChartSpec(
        IslandChartType.mount,
        categories: const ['果园', '海岸', '营地', '花田'],
        legend: false,
        showLabels: true,
        max: 100,
        series: [
          IslandChartSeries(
            name: '到访人数',
            data: namedPoints(
              ['果园', '海岸', '营地', '花田'],
              [58, 86, 42, 68],
              meadow,
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'forest',
      '林间山丘 · 四季采收',
      '统一草绿色，突出季节之间的高低变化。',
      ChartSpec(
        IslandChartType.mount,
        categories: const ['春', '夏', '秋', '冬'],
        colors: forest,
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('采收篮数', const [36, 68, 92, 24]),
        ],
      ),
    ),
    ChartExample(
      'clean',
      '暖色山丘 · 四处日落',
      '隐藏坐标网格，以直接标注配合柔和填充。',
      ChartSpec(
        IslandChartType.mount,
        categories: const ['栈桥', '灯塔', '山顶', '海滩'],
        legend: false,
        showAxes: false,
        showLabels: true,
        max: 100,
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '观景人数',
            data: namedPoints(
              ['栈桥', '灯塔', '山顶', '海滩'],
              [72, 46, 84, 58],
              sunset,
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'signed',
      '双向山丘 · 花田净增',
      '山丘可跨零展示，使用正负配色表达增减。',
      ChartSpec(
        IslandChartType.mount,
        categories: const ['春', '夏', '秋', '冬'],
        legend: false,
        series: [
          IslandChartSeries(
            name: '花株净增',
            data: namedPoints(['春', '夏', '秋', '冬'], [68, 42, -18, -36], [
              meadow[0],
              meadow[1],
              sunset[0],
              flowers[0],
            ]),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.mix: [
    ChartExample(
      'target',
      '柱线组合 · 预约与目标',
      '柱体显示实际人数，折线显示同单位的目标。',
      ChartSpec(
        IslandChartType.mix,
        categories: const ['周五', '周六', '周日', '假日'],
        colors: [meadow[0], sunset[0]],
        series: [
          IslandChartSeries.values('实际预约', const [42, 68, 58, 88]),
          IslandChartSeries.values('预约目标', const [
            50,
            60,
            65,
            80,
          ], mode: IslandChartSeriesMode.line),
        ],
      ),
    ),
    ChartExample(
      'area-line',
      '面积与曲线 · 新旧步道',
      '面积衬托旧步道，曲线强调新步道的增长。',
      ChartSpec(
        IslandChartType.mix,
        categories: const ['一', '二', '三', '四', '五', '六'],
        colors: [meadow[1], flowers[0]],
        smooth: true,
        surface: mintSurface,
        series: [
          IslandChartSeries.values('旧步道', const [
            64,
            58,
            72,
            66,
            78,
            70,
          ], mode: IslandChartSeriesMode.area),
          IslandChartSeries.values('新步道', const [
            18,
            30,
            42,
            38,
            58,
            76,
          ], mode: IslandChartSeriesMode.line),
        ],
      ),
    ),
    ChartExample(
      'three-series',
      '分组柱线 · 活动参与',
      '两类活动分组对照，折线补充参与人数合计。',
      ChartSpec(
        IslandChartType.mix,
        categories: const ['春', '夏', '秋', '冬'],
        colors: [sunset[0], flowers[0], meadow[0]],
        smooth: true,
        surface: creamSurface,
        series: [
          IslandChartSeries.values('采果', const [28, 42, 52, 18]),
          IslandChartSeries.values('手作', const [18, 30, 26, 38]),
          IslandChartSeries.values('合计', const [
            46,
            72,
            78,
            56,
          ], mode: IslandChartSeriesMode.line),
        ],
      ),
    ),
    ChartExample(
      'balance',
      '收支与结余 · 海岛物资',
      '三条系列共用一条数值轴，单位保持一致。',
      ChartSpec(
        IslandChartType.mix,
        categories: const ['一月', '二月', '三月', '四月'],
        colors: [meadow[0], sunset[0], flowers[0]],
        series: [
          IslandChartSeries.values('收入', const [52, 68, 42, 76]),
          IslandChartSeries.values('支出', const [-32, -48, -58, -42]),
          IslandChartSeries.values('结余', const [
            20,
            20,
            -16,
            34,
          ], mode: IslandChartSeriesMode.line),
        ],
      ),
    ),
  ],
};
