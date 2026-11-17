import 'package:animal_island_ui/animal_island_ui.dart';

import 'data.dart';
import 'example.dart';
import 'spec.dart';

/// Reference gallery-specialty.ts: coordinates, weights, stages, ranges and
/// planar outlines.
final specialtyExamples = <IslandChartType, List<ChartExample>>{
  IslandChartType.scatter: [
    ChartExample(
      'correlation',
      '单组分布 · 步道体验',
      '横轴为路程，纵轴为体验评分，观察整体分布。',
      ChartSpec(
        IslandChartType.scatter,
        colors: forest,
        legend: false,
        min: 0,
        max: 100,
        points: [
          IslandChartPointSeries(
            name: '步道观测',
            data: observations([
              [1, 36],
              [2, 48],
              [2.5, 42],
              [3, 64],
              [4, 58],
              [5, 76],
              [5.5, 68],
              [6, 85],
            ], '步道'),
          ),
        ],
      ),
    ),
    ChartExample(
      'clusters',
      '分组散点 · 活动偏好',
      '横轴为活动分钟数，纵轴为满意度，区分活动类型。',
      ChartSpec(
        IslandChartType.scatter,
        colors: [sunset[0], flowers[0], meadow[0]],
        min: 0,
        max: 100,
        surface: creamSurface,
        points: [
          IslandChartPointSeries(
            name: '手作',
            data: observations([
              [20, 68],
              [30, 82],
              [35, 74],
            ], '手作'),
          ),
          IslandChartPointSeries(
            name: '露营',
            data: observations([
              [60, 78],
              [75, 92],
              [85, 86],
            ], '露营'),
          ),
          IslandChartPointSeries(
            name: '采果',
            data: observations([
              [40, 58],
              [50, 72],
              [55, 64],
            ], '采果'),
          ),
        ],
      ),
    ),
    ChartExample(
      'quadrants',
      '正负分布 · 区域变化',
      '横轴为到访变化，纵轴为营收变化，保留正负坐标。',
      ChartSpec(
        IslandChartType.scatter,
        colors: [flowers[0]],
        surface: blossomSurface,
        points: [
          IslandChartPointSeries(
            name: '区域变化',
            data: observations([
              [-28, 18],
              [-12, -24],
              [8, 12],
              [22, 38],
              [36, -14],
              [-38, -32],
              [46, 48],
            ], '分区'),
          ),
        ],
      ),
    ),
    ChartExample(
      'labels',
      '标注散点 · 四处观景点',
      '少量观测值直接标注评分，悬浮查看完整坐标。',
      ChartSpec(
        IslandChartType.scatter,
        colors: [meadow[0]],
        showLabels: true,
        min: 0,
        max: 100,
        legend: false,
        surface: mintSurface,
        points: const [
          IslandChartPointSeries(
            name: '景观评分',
            data: [
              IslandChartPoint(name: '栈桥', x: 12, y: 52),
              IslandChartPoint(name: '灯塔', x: 28, y: 76),
              IslandChartPoint(name: '山顶', x: 46, y: 88),
              IslandChartPoint(name: '海滩', x: 62, y: 64),
            ],
          ),
        ],
      ),
    ),
  ],
  IslandChartType.bubble: [
    ChartExample(
      'weight',
      '大小气泡 · 活动规模',
      '横轴时长、纵轴评分、气泡面积表示参与人数。',
      ChartSpec(
        IslandChartType.bubble,
        colors: forest,
        min: 0,
        max: 100,
        legend: false,
        points: [
          IslandChartPointSeries(
            name: '活动体验',
            data: observations([
              [12, 36, 12],
              [24, 62, 32],
              [40, 48, 18],
              [56, 78, 56],
              [72, 68, 40],
            ], '活动'),
          ),
        ],
      ),
    ),
    ChartExample(
      'grouped',
      '双色气泡 · 海岸与林间',
      '同一套坐标与权重尺度，比较两类活动的分布。',
      ChartSpec(
        IslandChartType.bubble,
        colors: [sunset[0], flowers[0]],
        min: 0,
        max: 100,
        surface: creamSurface,
        points: [
          IslandChartPointSeries(
            name: '海岸',
            data: observations([
              [15, 32, 15],
              [35, 68, 48],
              [65, 56, 30],
            ], '海岸'),
          ),
          IslandChartPointSeries(
            name: '林间',
            data: observations([
              [25, 58, 28],
              [48, 42, 18],
              [75, 82, 56],
            ], '林间'),
          ),
        ],
      ),
    ),
    ChartExample(
      'colored',
      '单点配色 · 营地设施',
      '设施使用不同颜色，气泡面积表达使用次数。',
      ChartSpec(
        IslandChartType.bubble,
        legend: false,
        min: 0,
        max: 100,
        surface: mintSurface,
        points: [
          IslandChartPointSeries(
            name: '设施使用',
            data: [
              for (final (i, p) in observations([
                [15, 42, 18],
                [32, 78, 48],
                [48, 56, 32],
                [70, 84, 64],
              ], '设施').indexed)
                IslandChartPoint(
                  x: p.x,
                  y: p.y,
                  size: p.size,
                  name: p.name,
                  color: meadow[i],
                ),
            ],
          ),
        ],
      ),
    ),
    ChartExample(
      'minimal',
      '无网格气泡 · 游玩偏好',
      '隐藏坐标，悬浮读取时长、评分与参与规模。',
      ChartSpec(
        IslandChartType.bubble,
        colors: flowers,
        showAxes: false,
        legend: false,
        surface: blossomSurface,
        points: [
          IslandChartPointSeries(
            name: '游玩偏好',
            data: observations([
              [12, 34, 16],
              [26, 58, 42],
              [44, 42, 24],
              [58, 76, 64],
              [76, 60, 36],
            ], '项目'),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.funnel: [
    ChartExample(
      'conversion',
      '四阶段 · 活动报名',
      '完整保留报名顺序，提示展示阶段转化率。',
      ChartSpec(
        IslandChartType.funnel,
        colors: meadow,
        showLabels: true,
        legend: false,
        series: [
          IslandChartSeries(
            name: '报名人数',
            data: namedPoints(['浏览', '咨询', '预约', '到场'], [360, 240, 160, 128]),
          ),
        ],
      ),
    ),
    ChartExample(
      'tonal',
      '同色漏斗 · 手作课程',
      '以深浅草绿表达五个连续阶段的数量。',
      ChartSpec(
        IslandChartType.funnel,
        colors: forest,
        showLabels: true,
        legend: false,
        height: 260,
        surface: mintSurface,
        series: [
          IslandChartSeries(
            name: '参与人数',
            data: namedPoints(
              ['查看', '收藏', '报名', '签到', '完成'],
              [480, 340, 240, 180, 150],
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'simple',
      '简洁漏斗 · 集市到访',
      '仅显示阶段名称，具体数值在悬浮提示中查看。',
      ChartSpec(
        IslandChartType.funnel,
        colors: sunset,
        legend: false,
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '到访人数',
            data: namedPoints(['看到活动', '到达集市', '参与体验'], [280, 196, 108]),
          ),
        ],
      ),
    ),
    ChartExample(
      'retention',
      '暖色漏斗 · 志愿留存',
      '接近的阶段数值呈现较平缓的轮廓，便于比较留存。',
      ChartSpec(
        IslandChartType.funnel,
        colors: flowers,
        showLabels: true,
        legend: false,
        surface: blossomSurface,
        series: [
          IslandChartSeries(
            name: '志愿人数',
            data: namedPoints(['报名', '培训', '上岗', '持续参与'], [100, 92, 86, 78]),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.word: [
    ChartExample(
      'colorful',
      '多彩词云 · 海岛印象',
      '关闭底部图例，让词条大小与颜色成为阅读重点。',
      ChartSpec(
        IslandChartType.word,
        colors: meadow,
        legend: false,
        series: [
          IslandChartSeries(
            name: '提及次数',
            data: namedPoints(
              ['海风', '露营', '星空', '日落', '果园', '咖啡', '朋友', '贝壳', '花田', '野餐'],
              [96, 84, 72, 64, 56, 48, 40, 32, 24, 16],
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'monochrome',
      '单色词云 · 森林日记',
      '统一草绿色，只通过字体大小表达词条权重。',
      ChartSpec(
        IslandChartType.word,
        colors: [forest[0]],
        legend: false,
        surface: mintSurface,
        series: [
          IslandChartSeries(
            name: '提及次数',
            data: namedPoints(
              ['森林', '清晨', '松果', '晨露', '小径', '鸟鸣', '苔藓', '树荫'],
              [100, 78, 64, 52, 46, 38, 30, 22],
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'warm',
      '暖色词云 · 集市记忆',
      '蜜桃与暖黄色系，搭配简洁的奶油底色。',
      ChartSpec(
        IslandChartType.word,
        colors: sunset,
        legend: false,
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '提及次数',
            data: namedPoints(
              ['手作', '鲜花', '面包', '陶艺', '咖啡', '果酱', '甜品', '编织', '香草'],
              [92, 78, 68, 60, 52, 42, 34, 28, 20],
            ),
          ),
        ],
      ),
    ),
    ChartExample(
      'focus',
      '重点词条 · 周末计划',
      '用单点颜色强调主词，保留图例用于交互筛选。',
      ChartSpec(
        IslandChartType.word,
        colors: [flowers[0]],
        surface: blossomSurface,
        series: [
          IslandChartSeries(
            name: '计划人数',
            data: [
              IslandChartValue(120, name: '慢生活', color: sunset[0]),
              ...namedPoints(
                ['阅读', '散步', '喝茶', '写信', '听风'],
                [68, 56, 44, 32, 24],
              ),
            ],
          ),
        ],
      ),
    ),
  ],
  IslandChartType.candle: [
    ChartExample(
      'week',
      '每日区间 · 集市果价',
      '展示开、收、高、低，保留涨珊瑚、跌薄荷的语义。',
      const ChartSpec(
        IslandChartType.candle,
        categories: ['周一', '周二', '周三', '周四', '周五'],
        min: 20,
        max: 80,
        legend: false,
        candles: [
          IslandChartCandleSeries(
            name: '果价（虚构）',
            data: [
              IslandChartCandle(open: 36, close: 48, low: 30, high: 54),
              IslandChartCandle(open: 48, close: 42, low: 36, high: 58),
              IslandChartCandle(open: 42, close: 62, low: 38, high: 68),
              IslandChartCandle(open: 62, close: 56, low: 48, high: 72),
              IslandChartCandle(open: 56, close: 68, low: 50, high: 76),
            ],
          ),
        ],
      ),
    ),
    ChartExample(
      'narrow-range',
      '局部量程 · 平稳交易',
      '缩小显示量程，观察幅度较小的区间变化。',
      const ChartSpec(
        IslandChartType.candle,
        categories: ['一', '二', '三', '四', '五'],
        min: 90,
        max: 110,
        legend: false,
        surface: mintSurface,
        candles: [
          IslandChartCandleSeries(
            name: '成交价（虚构）',
            data: [
              IslandChartCandle(open: 96, close: 100, low: 94, high: 103),
              IslandChartCandle(open: 100, close: 98, low: 95, high: 104),
              IslandChartCandle(open: 98, close: 104, low: 96, high: 107),
              IslandChartCandle(open: 104, close: 101, low: 98, high: 108),
              IslandChartCandle(open: 101, close: 105, low: 99, high: 109),
            ],
          ),
        ],
      ),
    ),
    ChartExample(
      'labels',
      '收盘标注 · 四季价格',
      '少量区间直接标注收盘值，便于快速对照。',
      const ChartSpec(
        IslandChartType.candle,
        categories: ['春', '夏', '秋', '冬'],
        min: 0,
        max: 100,
        showLabels: true,
        legend: false,
        surface: creamSurface,
        candles: [
          IslandChartCandleSeries(
            name: '季末价格（虚构）',
            data: [
              IslandChartCandle(open: 36, close: 58, low: 22, high: 74),
              IslandChartCandle(open: 58, close: 42, low: 28, high: 70),
              IslandChartCandle(open: 42, close: 68, low: 32, high: 86),
              IslandChartCandle(open: 68, close: 54, low: 40, high: 80),
            ],
          ),
        ],
      ),
    ),
    ChartExample(
      'flat',
      '平盘与波动 · 市集观察',
      '开收相同仍显示实体，悬浮查看完整区间。',
      const ChartSpec(
        IslandChartType.candle,
        categories: ['一', '二', '三', '四', '五'],
        min: 20,
        max: 80,
        legend: false,
        surface: blossomSurface,
        candles: [
          IslandChartCandleSeries(
            name: '观察价（虚构）',
            data: [
              IslandChartCandle(open: 40, close: 40, low: 32, high: 48),
              IslandChartCandle(open: 40, close: 58, low: 36, high: 66),
              IslandChartCandle(open: 58, close: 58, low: 50, high: 72),
              IslandChartCandle(open: 58, close: 42, low: 34, high: 64),
              IslandChartCandle(open: 42, close: 50, low: 38, high: 58),
            ],
          ),
        ],
      ),
    ),
  ],
  IslandChartType.time: [
    ChartExample(
      'regular',
      '等时采样 · 步道到访',
      '每隔 15 分钟采样，曲线表达连续变化。',
      ChartSpec(
        IslandChartType.time,
        smooth: true,
        colors: forest,
        legend: false,
        surface: mintSurface,
        points: [
          IslandChartPointSeries(
            name: '到访人数',
            data: timePoints([
              (0, 18),
              (15, 32),
              (30, 26),
              (45, 48),
              (60, 42),
              (75, 62),
            ]),
          ),
        ],
      ),
    ),
    ChartExample(
      'irregular',
      '不等间隔 · 活动签到',
      '短间隔与长间隔按真实时间比例排列。',
      ChartSpec(
        IslandChartType.time,
        colors: [sunset[0]],
        legend: false,
        showLabels: true,
        max: 100,
        surface: creamSurface,
        points: [
          IslandChartPointSeries(
            name: '累计签到',
            data: timePoints([(0, 12), (5, 28), (12, 42), (45, 64), (90, 82)]),
          ),
        ],
      ),
    ),
    ChartExample(
      'comparison',
      '双线时序 · 南北入口',
      '同一时刻对比两个入口，悬浮提示合并读数。',
      ChartSpec(
        IslandChartType.time,
        colors: [meadow[0], flowers[0]],
        points: [
          IslandChartPointSeries(
            name: '南入口',
            data: timePoints([(0, 22), (20, 42), (40, 36), (60, 62), (80, 48)]),
          ),
          IslandChartPointSeries(
            name: '北入口',
            data: timePoints([(0, 18), (20, 28), (40, 48), (60, 38), (80, 56)]),
          ),
        ],
      ),
    ),
    ChartExample(
      'minimal',
      '无网格时序 · 午后热度',
      '简化装饰，保留真实时间间隔与单点读取。',
      ChartSpec(
        IslandChartType.time,
        colors: [flowers[0]],
        showAxes: false,
        smooth: true,
        legend: false,
        surface: blossomSurface,
        points: [
          IslandChartPointSeries(
            name: '热度指数',
            data: timePoints([
              (0, 24),
              (10, 38),
              (25, 62),
              (50, 46),
              (70, 72),
              (100, 58),
            ]),
          ),
        ],
      ),
    ),
  ],
  IslandChartType.map: [
    ChartExample(
      'tonal',
      '单色深浅 · 分区到访',
      '同色填充深浅表达数量，区域名称直接标注。',
      exampleSpec(IslandChartType.map).copyWith(
        colors: [forest[0]],
        showLabels: true,
        legend: false,
        surface: mintSurface,
      ),
    ),
    ChartExample(
      'category',
      '分类配色 · 区域采收',
      '不同区域采用暖色区分，悬浮查看各自采收量。',
      exampleSpec(IslandChartType.map).copyWith(
        colors: sunset,
        showLabels: false,
        surface: creamSurface,
        series: [
          IslandChartSeries(
            name: '采收量',
            data: namedPoints(['果园', '海岸', '露营地', '花田'], [82, 26, 48, 62]),
          ),
        ],
      ),
    ),
    ChartExample(
      'islands',
      '独立群岛 · 周末到访',
      '换一组平面轮廓，展示互不相连的四座虚构岛屿。',
      ChartSpec(
        IslandChartType.map,
        regions: archipelago,
        colors: meadow,
        showLabels: true,
        legend: false,
        series: [
          IslandChartSeries(
            name: '到访人数',
            data: namedPoints(['风铃岛', '月湾岛', '小麦岛', '星沙岛'], [88, 62, 46, 30]),
          ),
        ],
      ),
    ),
    ChartExample(
      'missing',
      '缺测区域 · 观察记录',
      '星沙岛未提供记录，保留沙色轮廓而不填成零值。',
      ChartSpec(
        IslandChartType.map,
        regions: archipelago,
        colors: [flowers[0]],
        showLabels: true,
        legend: false,
        surface: blossomSurface,
        series: [
          IslandChartSeries(
            name: '观察次数',
            data: namedPoints(['风铃岛', '月湾岛', '小麦岛'], [68, 92, 42]),
          ),
        ],
      ),
    ),
  ],
};
