part of 'chart.dart';

/// Statistical chart kind, named after the uCharts catalogue. Chosen through
/// the matching [IslandChartData] constructor and reported back in
/// [IslandChartDataEvent.type].
enum IslandChartType {
  /// Grouped (or stacked) vertical columns per category.
  column,

  /// Grouped (or stacked) horizontal bars per category.
  bar,

  /// Category trend line; missing values leave a gap.
  line,

  /// Category trend line with a translucent fill to the zero baseline.
  area,

  /// One hill per category whose height is the value.
  mount,

  /// Per-series column, line or area on one value axis.
  mix,

  /// Points on numeric x and y axes.
  scatter,

  /// Scatter points whose area follows a positive weight.
  bubble,

  /// Share of a total as sectors.
  pie,

  /// Pie with a hole showing the visible total.
  ring,

  /// Equal-angle sectors whose area follows the value.
  rose,

  /// Values per dimension on a shared radial range.
  radar,

  /// One progress arc per series.
  arcbar,

  /// One dial with a needle for the first visible series.
  gauge,

  /// Stages in input order, width following the value.
  funnel,

  /// Word cloud, text size following the value.
  word,

  /// Open/close/low/high candles per category.
  candle,

  /// Line over millisecond timestamps with real time spacing.
  time,

  /// Caller-supplied planar regions shaded by value.
  map,
}

/// Mark kind of one [IslandChartSeries] in [IslandChartData.mix].
enum IslandChartSeriesMode {
  /// Columns grouped with the other column series.
  column,

  /// A line with point marks.
  line,

  /// A line with a translucent fill to the zero baseline.
  area,
}

/// Which readings a tooltip gathers.
enum IslandChartTooltipTrigger {
  /// Every visible series at the same category, timestamp or radar dimension;
  /// charts without a shared axis fall back to [item].
  axis,

  /// Only the reading under the pointer or focus.
  item,
}

/// One value of a category, radar, gauge or item chart.
@immutable
class IslandChartValue {
  const IslandChartValue(this.value, {this.name, this.color});

  /// The value; non-finite values are treated as missing.
  final double value;

  /// Name shown in tooltips, item legends and map matching; defaults to the
  /// category at this index, then the one-based index.
  final String? name;

  /// Mark colour; wins over the series colour and the palette.
  final Color? color;
}

/// One point of a scatter, bubble or time chart.
@immutable
class IslandChartPoint {
  const IslandChartPoint({
    required this.x,
    required this.y,
    this.size,
    this.name,
    this.color,
  });

  /// Horizontal coordinate; milliseconds since the epoch for
  /// [IslandChartData.time].
  final double x;

  /// Vertical coordinate, the point's value.
  final double y;

  /// Positive bubble weight, proportional to the bubble area; null weighs 1.
  /// A bubble with a non-positive or non-finite weight is omitted.
  final double? size;

  /// Name shown in tooltips; defaults to the one-based index.
  final String? name;

  /// Mark colour; wins over the series colour and the palette.
  final Color? color;
}

/// One candle. [open] and [close] must lie within [low]..[high], otherwise
/// the candle is omitted.
@immutable
class IslandChartCandle {
  const IslandChartCandle({
    required this.open,
    required this.close,
    required this.low,
    required this.high,
    this.name,
  });

  /// Opening value.
  final double open;

  /// Closing value, the candle's value in events.
  final double close;

  /// Lowest value.
  final double low;

  /// Highest value.
  final double high;

  /// Name, usually a date; defaults to the category, then the index.
  final String? name;
}

/// A named series of values; `null` marks missing data. Names should be
/// unique within one chart.
@immutable
class IslandChartSeries {
  const IslandChartSeries({
    required this.name,
    required this.data,
    this.color,
    this.mode = IslandChartSeriesMode.column,
  });

  /// A series of plain values without per-point names or colours.
  IslandChartSeries.values(
    this.name,
    List<double?> values, {
    this.color,
    this.mode = IslandChartSeriesMode.column,
  }) : data = [for (final v in values) v == null ? null : IslandChartValue(v)];

  /// Legend and tooltip name.
  final String name;

  /// Values by category index.
  final List<IslandChartValue?> data;

  /// Series colour; defaults to the palette entry at the series index.
  final Color? color;

  /// Mark kind inside [IslandChartData.mix]; ignored by other charts.
  final IslandChartSeriesMode mode;
}

/// A named series of coordinates for scatter, bubble and time charts.
@immutable
class IslandChartPointSeries {
  const IslandChartPointSeries({
    required this.name,
    required this.data,
    this.color,
  });

  /// Legend and tooltip name.
  final String name;

  /// Points; `null` marks a missing sample.
  final List<IslandChartPoint?> data;

  /// Series colour; defaults to the palette entry at the series index.
  final Color? color;
}

/// A named series of candles by category index.
@immutable
class IslandChartCandleSeries {
  const IslandChartCandleSeries({
    required this.name,
    required this.data,
    this.color,
  });

  /// Legend and tooltip name.
  final String name;

  /// Candles; `null` marks a missing day.
  final List<IslandChartCandle?> data;

  /// Legend swatch and focus indicator colour; candle bodies use the fixed
  /// rising/falling colours.
  final Color? color;
}

/// A map region in one planar coordinate system with y pointing up. Nested
/// or crossing outlines fill with the even-odd rule.
@immutable
class IslandChartRegion {
  const IslandChartRegion({required this.name, required this.polygons});

  /// Matched against [IslandChartValue.name].
  final String name;

  /// Closed outlines (`Offset(x, y)`); outlines with fewer than three finite
  /// vertices are ignored.
  final List<List<Offset>> polygons;
}

/// The data and chart kind of an [IslandChart]: one constructor per
/// [IslandChartType], each taking only the data shape and options that kind
/// reads. Treat the lists as immutable and pass a new object to update.
@immutable
final class IslandChartData {
  /// Columns per category; [stacked] stacks positive and negative values
  /// separately from zero.
  const IslandChartData.column({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    bool stacked = false,
    double? min,
    double? max,
  }) : this._(
         IslandChartType.column,
         values: series,
         categories: categories,
         stacked: stacked,
         min: min,
         max: max,
       );

  /// Horizontal bars per category; [stacked] as in [IslandChartData.column].
  const IslandChartData.bar({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    bool stacked = false,
    double? min,
    double? max,
  }) : this._(
         IslandChartType.bar,
         values: series,
         categories: categories,
         stacked: stacked,
         min: min,
         max: max,
       );

  /// Lines per category; [smooth] uses horizontal-tangent curves that never
  /// overshoot neighbouring values.
  const IslandChartData.line({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    bool smooth = false,
    double? min,
    double? max,
  }) : this._(
         IslandChartType.line,
         values: series,
         categories: categories,
         smooth: smooth,
         min: min,
         max: max,
       );

  /// Filled lines per category; [smooth] as in [IslandChartData.line].
  const IslandChartData.area({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    bool smooth = false,
    double? min,
    double? max,
  }) : this._(
         IslandChartType.area,
         values: series,
         categories: categories,
         smooth: smooth,
         min: min,
         max: max,
       );

  /// Hills per category; [smooth] rounds the summits.
  const IslandChartData.mount({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    bool smooth = false,
    double? min,
    double? max,
  }) : this._(
         IslandChartType.mount,
         values: series,
         categories: categories,
         smooth: smooth,
         min: min,
         max: max,
       );

  /// Each series drawn as its [IslandChartSeries.mode] on one value axis.
  const IslandChartData.mix({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    bool smooth = false,
    double? min,
    double? max,
  }) : this._(
         IslandChartType.mix,
         values: series,
         categories: categories,
         smooth: smooth,
         min: min,
         max: max,
       );

  /// Series over at least three [categories] (dimensions) on one range from
  /// [min] (default 0) to [max]; negative values are omitted.
  const IslandChartData.radar({
    required List<IslandChartSeries> series,
    List<String> categories = const [],
    double? min,
    double? max,
  }) : this._(
         IslandChartType.radar,
         values: series,
         categories: categories,
         min: min,
         max: max,
       );

  /// Points on numeric axes; [xFormatter] formats x labels and readings.
  const IslandChartData.scatter({
    required List<IslandChartPointSeries> series,
    double? min,
    double? max,
    String Function(double x)? xFormatter,
  }) : this._(
         IslandChartType.scatter,
         points: series,
         min: min,
         max: max,
         xFormatter: xFormatter,
       );

  /// Weighted points; bubble area follows [IslandChartPoint.size].
  const IslandChartData.bubble({
    required List<IslandChartPointSeries> series,
    double? min,
    double? max,
    String Function(double x)? xFormatter,
  }) : this._(
         IslandChartType.bubble,
         points: series,
         min: min,
         max: max,
         xFormatter: xFormatter,
       );

  /// Lines over millisecond timestamps; x labels default to local `HH:mm`
  /// and readings to `YYYY-MM-DD HH:mm:ss`; [smooth] as in
  /// [IslandChartData.line].
  const IslandChartData.time({
    required List<IslandChartPointSeries> series,
    bool smooth = false,
    double? min,
    double? max,
    String Function(double x)? xFormatter,
  }) : this._(
         IslandChartType.time,
         points: series,
         smooth: smooth,
         min: min,
         max: max,
         xFormatter: xFormatter,
       );

  /// Candles per category; rising candles coral, falling candles mint.
  const IslandChartData.candle({
    required List<IslandChartCandleSeries> series,
    List<String> categories = const [],
    double? min,
    double? max,
  }) : this._(
         IslandChartType.candle,
         candles: series,
         categories: categories,
         min: min,
         max: max,
       );

  /// Sectors of one series' positive values; each value is a legend item.
  IslandChartData.pie({required IslandChartSeries series})
    : this._(IslandChartType.pie, values: [series]);

  /// Pie with a centre total of the visible values.
  IslandChartData.ring({required IslandChartSeries series})
    : this._(IslandChartType.ring, values: [series]);

  /// Equal-angle sectors with square-root radii.
  IslandChartData.rose({required IslandChartSeries series})
    : this._(IslandChartType.rose, values: [series]);

  /// Stages in input order; tooltips add rates against the first and the
  /// preceding visible stage.
  IslandChartData.funnel({required IslandChartSeries series})
    : this._(IslandChartType.funnel, values: [series]);

  /// Words sized by their positive values; words that do not fit stay in the
  /// data table.
  IslandChartData.word({required IslandChartSeries series})
    : this._(IslandChartType.word, values: [series]);

  /// [regions] shaded by the [series] value with the same name. No outlines
  /// are built in or fetched.
  IslandChartData.map({
    required IslandChartSeries series,
    required List<IslandChartRegion> regions,
  }) : this._(IslandChartType.map, values: [series], regions: regions);

  /// One arc per series reading its first valid value on [min]..[max]; the
  /// arc is clamped, readings keep the real value.
  const IslandChartData.arcbar({
    required List<IslandChartSeries> series,
    double min = 0,
    double max = 100,
  }) : this._(IslandChartType.arcbar, values: series, min: min, max: max);

  /// A dial for the first valid value of the first visible series.
  const IslandChartData.gauge({
    required List<IslandChartSeries> series,
    double min = 0,
    double max = 100,
  }) : this._(IslandChartType.gauge, values: series, min: min, max: max);

  const IslandChartData._(
    this.type, {
    List<IslandChartSeries> values = const [],
    List<IslandChartPointSeries> points = const [],
    List<IslandChartCandleSeries> candles = const [],
    List<String> categories = const [],
    bool stacked = false,
    bool smooth = false,
    double? min,
    double? max,
    List<IslandChartRegion> regions = const [],
    String Function(double x)? xFormatter,
  }) : _values = values,
       _points = points,
       _candles = candles,
       _categories = categories,
       _stacked = stacked,
       _smooth = smooth,
       _min = min,
       _max = max,
       _regions = regions,
       _xFormatter = xFormatter;

  /// The chart kind.
  final IslandChartType type;
  final List<IslandChartSeries> _values;
  final List<IslandChartPointSeries> _points;
  final List<IslandChartCandleSeries> _candles;
  final List<String> _categories;
  final bool _stacked, _smooth;
  final double? _min, _max;
  final List<IslandChartRegion> _regions;
  final String Function(double x)? _xFormatter;
}

/// A reading activated by a pointer, Enter or Space.
@immutable
class IslandChartDataEvent {
  const IslandChartDataEvent({
    required this.type,
    required this.seriesIndex,
    required this.dataIndex,
    required this.seriesName,
    required this.name,
    required this.value,
    required this.datum,
  });

  /// The chart kind.
  final IslandChartType type;

  /// Index of the series in the data given to the chart (0 for item charts).
  final int seriesIndex;

  /// Index of the datum in its series, counting missing entries.
  final int dataIndex;

  /// Series name.
  final String seriesName;

  /// Datum name: its own name, the category, or the one-based index.
  final String name;

  /// Value; the y coordinate for point charts and the close for candles.
  final double value;

  /// The caller's [IslandChartValue], [IslandChartPoint] or
  /// [IslandChartCandle].
  final Object datum;
}

/// One tooltip row; rates are computed over the visible data.
@immutable
class IslandChartTooltipItem extends IslandChartDataEvent {
  const IslandChartTooltipItem({
    required super.type,
    required super.seriesIndex,
    required super.dataIndex,
    required super.seriesName,
    required super.name,
    required super.value,
    required super.datum,
    required this.color,
    required this.formattedValue,
    this.percentage,
    this.conversion,
  });

  /// Mark colour.
  final Color color;

  /// Formatted reading, including coordinates, weight or all four candle
  /// values.
  final String formattedValue;

  /// Percent share of the drawn total (pie, ring, rose) or of the first
  /// visible stage (funnel); null elsewhere or for a zero denominator.
  final double? percentage;

  /// Funnel percent of the preceding visible stage; null for the first stage
  /// or a zero denominator.
  final double? conversion;
}

/// What a custom tooltip receives.
@immutable
class IslandChartTooltipContext {
  const IslandChartTooltipContext({
    required this.type,
    required this.name,
    required this.items,
    required this.locked,
  });

  /// The chart kind.
  final IslandChartType type;

  /// Category, item name, or the formatted timestamp of a time chart.
  final String name;

  /// The visible readings compared at this position.
  final List<IslandChartTooltipItem> items;

  /// Whether a click, Enter or Space locked the reading.
  final bool locked;
}

/// Tooltip options; pass `tooltip: null` to [IslandChart] to hide tooltips
/// and guides.
@immutable
class IslandChartTooltip {
  const IslandChartTooltip({
    this.trigger = IslandChartTooltipTrigger.axis,
    this.crosshair = true,
    this.showPercentage = true,
    this.builder,
  });

  /// Shared readings per category/time/dimension, or a single reading.
  final IslandChartTooltipTrigger trigger;

  /// Draws the dashed axis guide on Cartesian charts.
  final bool crosshair;

  /// Shows shares and funnel rates in the default content.
  final bool showPercentage;

  /// Custom content; returning null hides the panel.
  final Widget? Function(
    BuildContext context,
    IslandChartTooltipContext tooltip,
  )?
  builder;
}
