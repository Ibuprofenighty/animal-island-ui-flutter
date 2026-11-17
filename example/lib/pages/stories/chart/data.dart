import 'package:flutter/widgets.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../../shared/catalog.dart';
import '../../../shared/palette.dart';
import 'spec.dart';

/// Reference chartPages.ts: label and purpose per type, in sidebar order.
/// The Gallery catalog already holds both (title and description).
typedef ChartPage = ({IslandChartType type, String label, String desc});

final List<ChartPage> chartPages = [
  for (final entry in galleryGroups['图表统计']!)
    if (entry.id.startsWith('chart-'))
      (
        type: IslandChartType.values.byName(entry.id.substring(6)),
        label: entry.title,
        desc: entry.description,
      ),
];

ChartPage chartPage(IslandChartType type) =>
    chartPages.firstWhere((page) => page.type == type);

// Reference gallery-shared.ts colour sets and surfaces.
const meadow = GalleryPalette.chartMeadow;
const sunset = GalleryPalette.chartSunset;
const forest = GalleryPalette.chartForest;
const flowers = GalleryPalette.chartFlowers;
const ChartSurface creamSurface = (
  background: GalleryPalette.chartCreamSurface,
  border: GalleryPalette.chartCreamBorder,
);
const ChartSurface mintSurface = (
  background: GalleryPalette.chartMintSurface,
  border: GalleryPalette.chartMintBorder,
);
const ChartSurface blossomSurface = (
  background: GalleryPalette.chartBlossomSurface,
  border: GalleryPalette.chartBlossomBorder,
);

/// Reference `namedPoints`: names and values with optional cycled colours.
List<IslandChartValue> namedPoints(
  List<String> names,
  List<double> values, [
  List<Color>? colors,
]) => [
  for (var i = 0; i < names.length; i++)
    IslandChartValue(
      values[i],
      name: names[i],
      color: colors?[i % colors.length],
    ),
];

/// Reference `observations`: fixed coordinates named `{prefix}{n}`.
List<IslandChartPoint> observations(
  List<List<double>> coordinates,
  String prefix,
) => [
  for (var i = 0; i < coordinates.length; i++)
    IslandChartPoint(
      x: coordinates[i][0],
      y: coordinates[i][1],
      size: coordinates[i].length > 2 ? coordinates[i][2] : null,
      name: '$prefix${i + 1}',
    ),
];

/// Reference `timePoints`: minutes after 2026-10-31 00:00 UTC.
List<IslandChartPoint> timePoints(List<(double, double)> records) {
  final start = DateTime.utc(2026, 10, 31).millisecondsSinceEpoch;
  return [
    for (final (minutes, y) in records)
      IslandChartPoint(x: start + minutes * 60000, y: y),
  ];
}

List<Offset> _ring(List<(double, double)> points) => [
  for (final (x, y) in points) Offset(x, y),
];

/// Reference data.ts `regions`: invented planar island districts.
final islandRegions = [
  IslandChartRegion(
    name: '果园',
    polygons: [
      _ring([(0, 2), (1, 5), (4, 6), (5, 3), (3, 2)]),
    ],
  ),
  IslandChartRegion(
    name: '海岸',
    polygons: [
      _ring([(5, 3), (4, 6), (7, 5), (9, 3), (8, 1)]),
    ],
  ),
  IslandChartRegion(
    name: '露营地',
    polygons: [
      _ring([(0, 2), (3, 2), (5, 3), (5, 0), (2, -1)]),
    ],
  ),
  IslandChartRegion(
    name: '花田',
    polygons: [
      _ring([(5, 3), (8, 1), (7, -1), (5, 0)]),
    ],
  ),
];

/// Reference gallery-specialty.ts `archipelago`: four separate islands.
final archipelago = [
  IslandChartRegion(
    name: '风铃岛',
    polygons: [
      _ring([(0, 3), (1, 5), (3, 5.5), (4, 4), (3, 2.5), (1, 2)]),
    ],
  ),
  IslandChartRegion(
    name: '月湾岛',
    polygons: [
      _ring([(5, 2), (6, 4), (8, 4.5), (9, 3), (8, 1), (6, 0.5)]),
    ],
  ),
  IslandChartRegion(
    name: '小麦岛',
    polygons: [
      _ring([(1, -1), (2, 0.5), (4, 0), (4.5, -1.5), (3, -2.5), (1.5, -2)]),
    ],
  ),
  IslandChartRegion(
    name: '星沙岛',
    polygons: [
      _ring([(7, -2), (8, -1), (9.5, -2), (9, -3.5), (7.5, -3.5)]),
    ],
  ),
];

const _categories = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
const _trend = <double>[32, 46, 38, 62, 55, 79, 68];
const _comparison = <double>[24, 31, 42, 48, 39, 61, 54];
const _proportions = [('果园', 38.0), ('海岸', 27.0), ('露营地', 21.0), ('花田', 14.0)];

/// Reference data.ts `exampleProps`: the base example of each type, shared
/// by the overview, the state demo and the interaction demo.
ChartSpec exampleSpec(IslandChartType type, {bool alternate = false}) {
  final values = alternate
      ? const <double>[51, 35, 72, 49, 86, 60, 93]
      : _trend;
  switch (type) {
    case IslandChartType.pie ||
        IslandChartType.ring ||
        IslandChartType.rose ||
        IslandChartType.funnel ||
        IslandChartType.map:
      return ChartSpec(
        type,
        series: [
          IslandChartSeries(
            name: '到访人数',
            data: [
              for (var i = 0; i < _proportions.length; i++)
                IslandChartValue(
                  alternate
                      ? _proportions[i].$2 + i * 7 + 5
                      : _proportions[i].$2,
                  name: _proportions[i].$1,
                ),
            ],
          ),
        ],
        regions: type == IslandChartType.map ? islandRegions : const [],
        showLabels: type == IslandChartType.map,
      );
    case IslandChartType.radar:
      return ChartSpec(
        type,
        categories: const ['生态', '服务', '交通', '设施', '景观'],
        max: 100,
        series: [
          IslandChartSeries.values(
            '本月',
            alternate ? const [86, 70, 90, 60, 85] : const [72, 90, 65, 82, 94],
          ),
          IslandChartSeries.values('上月', const [60, 74, 78, 65, 81]),
        ],
      );
    case IslandChartType.scatter || IslandChartType.bubble:
      return ChartSpec(
        type,
        points: [
          IslandChartPointSeries(
            name: '海岸活动',
            data: [
              IslandChartPoint(
                name: '拾贝',
                x: 12,
                y: alternate ? 42 : 28,
                size: 12,
              ),
              const IslandChartPoint(name: '钓鱼', x: 30, y: 55, size: 25),
              const IslandChartPoint(name: '潜水', x: 46, y: 38, size: 18),
              const IslandChartPoint(name: '观景', x: 65, y: 72, size: 38),
            ],
          ),
          const IslandChartPointSeries(
            name: '林间活动',
            data: [
              IslandChartPoint(name: '采果', x: 20, y: 42, size: 20),
              IslandChartPoint(name: '野餐', x: 42, y: 64, size: 32),
              IslandChartPoint(name: '露营', x: 58, y: 48, size: 16),
            ],
          ),
        ],
      );
    case IslandChartType.gauge || IslandChartType.arcbar:
      return ChartSpec(
        type,
        min: 0,
        max: 100,
        format: ChartFormat.percent,
        series: type == IslandChartType.gauge
            ? [
                IslandChartSeries.values('岛屿舒适度', [alternate ? 91 : 72]),
              ]
            : [
                IslandChartSeries.values('植树目标', [alternate ? 88 : 72]),
                IslandChartSeries.values('步道维护', [alternate ? 76 : 58]),
              ],
      );
    case IslandChartType.word:
      const words = [
        '海风', '露营', '星空', '果园', '钓鱼', '日落', //
        '咖啡', '贝壳', '花田', '步道', '朋友', '野餐',
      ];
      return ChartSpec(
        type,
        series: [
          IslandChartSeries(
            name: '提及次数',
            data: [
              for (var i = 0; i < words.length; i++)
                IslandChartValue(
                  ((alternate ? 15 : 12) - i) * 8.0,
                  name: words[i],
                ),
            ],
          ),
        ],
      );
    case IslandChartType.candle:
      return ChartSpec(
        type,
        categories: const [
          '10/01',
          '10/02',
          '10/03',
          '10/04',
          '10/05',
          '10/06',
        ],
        min: 20,
        candles: [
          IslandChartCandleSeries(
            name: '集市价格（示例）',
            data: [
              const IslandChartCandle(open: 40, close: 55, low: 32, high: 62),
              const IslandChartCandle(open: 55, close: 48, low: 44, high: 66),
              IslandChartCandle(
                open: 48,
                close: alternate ? 70 : 62,
                low: 42,
                high: 74,
              ),
              const IslandChartCandle(open: 62, close: 68, low: 54, high: 78),
              const IslandChartCandle(open: 68, close: 51, low: 47, high: 72),
              const IslandChartCandle(open: 51, close: 64, low: 45, high: 70),
            ],
          ),
        ],
      );
    case IslandChartType.time:
      const minutes = [0, 5, 15, 20, 45, 60];
      return ChartSpec(
        type,
        points: [
          IslandChartPointSeries(
            name: '实时到访',
            data: [
              for (var i = 0; i < minutes.length; i++)
                IslandChartPoint(
                  name: '${minutes[i]} 分钟',
                  x: DateTime.utc(
                    2026,
                    10,
                    31,
                    2,
                    minutes[i],
                  ).millisecondsSinceEpoch.toDouble(),
                  y: values[i],
                ),
            ],
          ),
        ],
      );
    case IslandChartType.column ||
        IslandChartType.bar ||
        IslandChartType.line ||
        IslandChartType.area ||
        IslandChartType.mount ||
        IslandChartType.mix:
      return ChartSpec(
        type,
        categories: _categories,
        series: [
          IslandChartSeries.values('本周', values),
          IslandChartSeries.values(
            '上周',
            _comparison,
            mode: type == IslandChartType.mix
                ? IslandChartSeriesMode.line
                : IslandChartSeriesMode.column,
          ),
        ],
      );
  }
}
