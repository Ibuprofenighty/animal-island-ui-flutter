import 'package:flutter/widgets.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

/// Reference gallery-shared.ts value formatters; each has a runtime function
/// and the Dart source shown in the copyable configuration.
enum ChartFormat {
  percent,
  temperature,
  minutes;

  String call(double value) => switch (this) {
    percent => '${value.round()}%',
    temperature => '${value.round()}°C',
    minutes => '${value.round()} 分',
  };

  String get source => switch (this) {
    percent => r"(value) => '${value.round()}%'",
    temperature => r"(value) => '${value.round()}°C'",
    minutes => r"(value) => '${value.round()} 分'",
  };
}

/// A container surface: reference `style: { background, borderColor }`.
typedef ChartSurface = ({Color background, Color border});

/// One demo configuration, read both to draw an [IslandChart] and to print
/// the same configuration as copyable Dart (reference `JSON.stringify` of
/// the drawn props).
@immutable
class ChartSpec {
  const ChartSpec(
    this.type, {
    this.categories = const [],
    this.series = const [],
    this.points = const [],
    this.candles = const [],
    this.regions = const [],
    this.stacked = false,
    this.smooth = false,
    this.min,
    this.max,
    this.colors,
    this.legend = true,
    this.showLabels = false,
    this.showAxes = true,
    this.height,
    this.format,
    this.surface,
  });

  final IslandChartType type;
  final List<String> categories;
  final List<IslandChartSeries> series;
  final List<IslandChartPointSeries> points;
  final List<IslandChartCandleSeries> candles;
  final List<IslandChartRegion> regions;
  final bool stacked, smooth, legend, showLabels, showAxes;
  final double? min, max, height;
  final List<Color>? colors;
  final ChartFormat? format;
  final ChartSurface? surface;

  static const _itemTypes = {
    IslandChartType.pie,
    IslandChartType.ring,
    IslandChartType.rose,
    IslandChartType.funnel,
    IslandChartType.word,
    IslandChartType.map,
  };

  ChartSpec copyWith({
    List<IslandChartSeries>? series,
    bool? stacked,
    bool? smooth,
    List<Color>? colors,
    bool? legend,
    bool? showLabels,
    double? height,
    ChartSurface? surface,
  }) => ChartSpec(
    type,
    categories: categories,
    series: series ?? this.series,
    points: points,
    candles: candles,
    regions: regions,
    stacked: stacked ?? this.stacked,
    smooth: smooth ?? this.smooth,
    min: min,
    max: max,
    colors: colors ?? this.colors,
    legend: legend ?? this.legend,
    showLabels: showLabels ?? this.showLabels,
    showAxes: showAxes,
    height: height ?? this.height,
    format: format,
    surface: surface ?? this.surface,
  );

  /// The same configuration without data (reference `series: []`).
  ChartSpec get empty => ChartSpec(
    type,
    categories: categories,
    series: _itemTypes.contains(type) && series.isNotEmpty
        ? [IslandChartSeries(name: series.first.name, data: const [])]
        : const [],
    regions: regions,
    stacked: stacked,
    smooth: smooth,
    min: min,
    max: max,
    colors: colors,
    legend: legend,
    showLabels: showLabels,
    showAxes: showAxes,
    height: height,
    format: format,
    surface: surface,
  );

  IslandChartSeries get _item =>
      series.isEmpty ? const IslandChartSeries(name: '', data: []) : series[0];

  IslandChartData get data => switch (type) {
    IslandChartType.column => IslandChartData.column(
      series: series,
      categories: categories,
      stacked: stacked,
      min: min,
      max: max,
    ),
    IslandChartType.bar => IslandChartData.bar(
      series: series,
      categories: categories,
      stacked: stacked,
      min: min,
      max: max,
    ),
    IslandChartType.line => IslandChartData.line(
      series: series,
      categories: categories,
      smooth: smooth,
      min: min,
      max: max,
    ),
    IslandChartType.area => IslandChartData.area(
      series: series,
      categories: categories,
      smooth: smooth,
      min: min,
      max: max,
    ),
    IslandChartType.mount => IslandChartData.mount(
      series: series,
      categories: categories,
      smooth: smooth,
      min: min,
      max: max,
    ),
    IslandChartType.mix => IslandChartData.mix(
      series: series,
      categories: categories,
      smooth: smooth,
      min: min,
      max: max,
    ),
    IslandChartType.radar => IslandChartData.radar(
      series: series,
      categories: categories,
      min: min,
      max: max,
    ),
    IslandChartType.scatter => IslandChartData.scatter(
      series: points,
      min: min,
      max: max,
    ),
    IslandChartType.bubble => IslandChartData.bubble(
      series: points,
      min: min,
      max: max,
    ),
    IslandChartType.time => IslandChartData.time(
      series: points,
      smooth: smooth,
      min: min,
      max: max,
    ),
    IslandChartType.candle => IslandChartData.candle(
      series: candles,
      categories: categories,
      min: min,
      max: max,
    ),
    IslandChartType.pie => IslandChartData.pie(series: _item),
    IslandChartType.ring => IslandChartData.ring(series: _item),
    IslandChartType.rose => IslandChartData.rose(series: _item),
    IslandChartType.funnel => IslandChartData.funnel(series: _item),
    IslandChartType.word => IslandChartData.word(series: _item),
    IslandChartType.map => IslandChartData.map(series: _item, regions: regions),
    IslandChartType.arcbar => IslandChartData.arcbar(
      series: series,
      min: min ?? 0,
      max: max ?? 100,
    ),
    IslandChartType.gauge => IslandChartData.gauge(
      series: series,
      min: min ?? 0,
      max: max ?? 100,
    ),
  };

  IslandChart chart({
    Key? key,
    String? title,
    String? description,
    double? height,
    bool loading = false,
    IslandChartTooltip? tooltip = const IslandChartTooltip(),
    bool highlight = true,
    bool selectable = true,
    ValueChanged<IslandChartDataEvent>? onDataActivate,
  }) => IslandChart(
    key: key,
    data: data,
    title: title,
    description: description,
    height: height ?? this.height ?? 300,
    colors: colors,
    legend: legend,
    tooltip: tooltip,
    highlight: highlight,
    selectable: selectable,
    showAxes: showAxes,
    showLabels: showLabels,
    valueFormatter: format?.call,
    loading: loading,
    onDataActivate: onDataActivate,
    backgroundColor: surface?.background,
    borderColor: surface?.border,
  );

  /// Copyable Dart for this configuration, adapted from the reference
  /// `const chartProps: ChartProps = {...}; <Chart {...chartProps} />`.
  String code({String? title, String? description}) {
    final out = StringBuffer(
      "import 'package:animal_island_ui/animal_island_ui.dart';\n"
      "import 'package:flutter/widgets.dart';\n\n"
      'final chart = IslandChart(\n'
      '  data: ${_dataSource('  ')},\n',
    );
    void field(String name, String value) => out.write('  $name: $value,\n');
    if (title != null) field('title', _str(title));
    if (description != null) field('description', _str(description));
    if (height != null) field('height', _num(height!));
    if (colors case final colors?) {
      field('colors', 'const [${colors.map(_color).join(', ')}]');
    }
    if (!legend) field('legend', 'false');
    if (!showAxes) field('showAxes', 'false');
    if (showLabels) field('showLabels', 'true');
    if (format case final format?) field('valueFormatter', format.source);
    if (surface case final surface?) {
      field('backgroundColor', 'const ${_color(surface.background)}');
      field('borderColor', 'const ${_color(surface.border)}');
    }
    out.write(');');
    return out.toString();
  }

  String _dataSource(String indent) {
    final inner = '$indent  ';
    final args = <String>[];
    if (categories.isNotEmpty) {
      args.add('categories: const [${categories.map(_str).join(', ')}]');
    }
    if (stacked) args.add('stacked: true');
    if (smooth) args.add('smooth: true');
    if (min case final min?) args.add('min: ${_num(min)}');
    if (max case final max?) args.add('max: ${_num(max)}');
    if (_itemTypes.contains(type)) {
      args.add('series: ${_valueSeries(_item, inner)}');
      if (type == IslandChartType.map) {
        args.add('regions: ${_regions(inner)}');
      }
    } else {
      final list = switch (type) {
        IslandChartType.scatter ||
        IslandChartType.bubble ||
        IslandChartType.time => [
          for (final s in points) _pointSeries(s, '$inner  '),
        ],
        IslandChartType.candle => [
          for (final s in candles) _candleSeries(s, '$inner  '),
        ],
        _ => [for (final s in series) _valueSeries(s, '$inner  ')],
      };
      args.add('series: [\n${list.map((s) => '$inner  $s,\n').join()}$inner]');
    }
    return 'IslandChartData.${type.name}(\n'
        '${args.map((a) => '$inner$a,\n').join()}$indent)';
  }

  static String _valueSeries(IslandChartSeries s, String indent) {
    final extra = [
      if (s.color case final color?) 'color: const ${_color(color)}',
      if (s.mode != IslandChartSeriesMode.column)
        'mode: IslandChartSeriesMode.${s.mode.name}',
    ];
    final plain = s.data.every(
      (v) => v == null || (v.name == null && v.color == null),
    );
    if (plain) {
      final values = s.data.map((v) => v == null ? 'null' : _num(v.value));
      return 'IslandChartSeries.values(${[_str(s.name), 'const [${values.join(', ')}]', ...extra].join(', ')})';
    }
    final items = [
      for (final v in s.data)
        v == null
            ? 'null'
            : 'IslandChartValue(${[_num(v.value), if (v.name case final n?) 'name: ${_str(n)}', if (v.color case final c?) 'color: ${_color(c)}'].join(', ')})',
    ];
    return _object('IslandChartSeries', [
      'name: ${_str(s.name)}',
      ...extra,
      'data: const [\n${items.map((i) => '$indent    $i,\n').join()}$indent  ]',
    ], indent);
  }

  static String _pointSeries(IslandChartPointSeries s, String indent) {
    final items = [
      for (final p in s.data)
        p == null
            ? 'null'
            : 'IslandChartPoint(${['x: ${_num(p.x)}', 'y: ${_num(p.y)}', if (p.size case final size?) 'size: ${_num(size)}', if (p.name case final n?) 'name: ${_str(n)}', if (p.color case final c?) 'color: ${_color(c)}'].join(', ')})',
    ];
    return _object('IslandChartPointSeries', [
      'name: ${_str(s.name)}',
      if (s.color case final color?) 'color: const ${_color(color)}',
      'data: const [\n${items.map((i) => '$indent    $i,\n').join()}$indent  ]',
    ], indent);
  }

  static String _candleSeries(IslandChartCandleSeries s, String indent) {
    final items = [
      for (final c in s.data)
        c == null
            ? 'null'
            : 'IslandChartCandle(open: ${_num(c.open)}, close: ${_num(c.close)}, '
                  'low: ${_num(c.low)}, high: ${_num(c.high)})',
    ];
    return _object('IslandChartCandleSeries', [
      'name: ${_str(s.name)}',
      'data: const [\n${items.map((i) => '$indent    $i,\n').join()}$indent  ]',
    ], indent);
  }

  String _regions(String indent) {
    final items = [
      for (final r in regions)
        'IslandChartRegion(name: ${_str(r.name)}, polygons: [\n'
            '${r.polygons.map((ring) => '$indent    [${ring.map((o) => 'Offset(${_num(o.dx)}, ${_num(o.dy)})').join(', ')}],\n').join()}'
            '$indent  ])',
    ];
    return 'const [\n${items.map((i) => '$indent  $i,\n').join()}$indent]';
  }

  static String _object(String name, List<String> args, String indent) =>
      '$name(\n${args.map((a) => '$indent  $a,\n').join()}$indent)';

  static String _str(String value) =>
      "'${value.replaceAll(r'\', r'\\').replaceAll("'", r"\'")}'";

  static String _num(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  static String _color(Color color) =>
      'Color(0x${color.toARGB32().toRadixString(16).padLeft(8, '0')})';
}

/// JavaScript `String(number)` for demo status lines: integers without `.0`.
String plainNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toString();
