import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/localizations.dart';
import '../../foundation/recipes/chart.dart';
import '../../foundation/size.dart';
import '../../foundation/theme.dart';
import '../../internal/action_surface.dart';
import '../../internal/css_line_box.dart';
import '../../internal/focus_outline.dart';
import '../actions.dart';
import '../no_data.dart';
import '../tooltip.dart';

part 'cartesian.dart';
part 'geometry.dart';
part 'interaction.dart';
part 'model.dart';
part 'painter.dart';
part 'polar.dart';
part 'specialty.dart';

const _ease = Cubic(0.4, 0, 0.2, 1);
const _shortMotion = Duration(milliseconds: 200);

String _trimmed(double value) {
  final fixed = value.toStringAsFixed(2);
  final trimmed = fixed.contains('.')
      ? fixed.replaceFirst(RegExp(r'\.?0+$'), '')
      : fixed;
  return trimmed == '-0' ? '0' : trimmed;
}

/// Reference default: zh-CN, up to two decimals, compact from 10 000. Like
/// `Intl.NumberFormat` the unit follows the rounded value, so 99 999 999
/// reads 1亿, not 10000万.
String _defaultFormat(double value) {
  final magnitude = value.abs();
  if (magnitude >= 10000) {
    const units = [(1e4, '万'), (1e8, '亿'), (1e12, '万亿')];
    var unit = units.lastIndexWhere((u) => magnitude >= u.$1);
    var scaled = _trimmed(value / units[unit].$1);
    if (unit < units.length - 1 && double.parse(scaled).abs() >= 10000) {
      unit++;
      scaled = _trimmed(value / units[unit].$1);
    }
    return '$scaled${units[unit].$2}';
  }
  final text = _trimmed(value);
  final negative = text.startsWith('-');
  final digits = negative ? text.substring(1) : text;
  final dot = digits.indexOf('.');
  final whole = dot < 0 ? digits : digits.substring(0, dot);
  final grouped = whole.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${negative ? '-' : ''}$grouped${dot < 0 ? '' : digits.substring(dot)}';
}

/// An island-style statistical chart: 19 kinds sharing a legend, tooltips,
/// keyboard reading, a data table and empty states.
///
/// The [data] constructor chooses the kind and holds its typed data; every
/// other parameter is shared presentation. The plot fills the available
/// width (at least 280, scrolling horizontally inside narrower parents;
/// 640 when unbounded) and is [height] tall (minimum 180).
///
/// Tab enters the plot at one roving stop; arrow keys move between readings,
/// Home/End jump to the first/last, Enter/Space or a click calls
/// [onDataActivate] and, when [selectable], locks the reading until it is
/// activated again, an arrow key moves, Escape is pressed or empty plot space
/// is clicked. Legend entries show and hide series or items; the expandable
/// data table lists every valid datum, hidden ones included.
class IslandChart extends StatefulWidget {
  const IslandChart({
    super.key,
    required this.data,
    this.title,
    this.description,
    this.height = 300,
    this.colors,
    this.legend = true,
    this.tooltip = const IslandChartTooltip(),
    this.highlight = true,
    this.selectable = true,
    this.showAxes = true,
    this.showLabels = false,
    this.valueFormatter,
    this.loading = false,
    this.empty,
    this.animated = true,
    this.onDataActivate,
    this.semanticLabel,
    this.backgroundColor,
    this.borderColor,
  });

  /// Chart kind and data.
  final IslandChartData data;

  /// Heading above the plot; also names the chart when [semanticLabel] is
  /// null.
  final String? title;

  /// Secondary text under the [title].
  final String? description;

  /// Plot height; values below 180 use 180 and non-finite values 300.
  final double height;

  /// Palette by series index (item charts: by item index). Point and series
  /// colours win; null or empty uses the island palette.
  final List<Color>? colors;

  /// Shows the clickable legend.
  final bool legend;

  /// Tooltip options; null hides tooltips and crosshair guides.
  final IslandChartTooltip? tooltip;

  /// Dims unrelated marks for the active reading or hovered legend entry.
  final bool highlight;

  /// Lets activation lock the reading.
  final bool selectable;

  /// Draws the grid and axis labels of Cartesian charts.
  final bool showAxes;

  /// Draws value labels (Cartesian), sector names (pie, ring, rose), stage
  /// values (funnel) or region names (map).
  final bool showLabels;

  /// Formats values on axes, tooltips and centres; defaults to zh-CN with up
  /// to two decimals, `万`/`亿` from 10 000.
  final String Function(double value)? valueFormatter;

  /// Replaces the plot with a busy status.
  final bool loading;

  /// Replaces the empty state when there is no drawable data; the built-in
  /// state still explains hidden legends and missing map outlines.
  final Widget? empty;

  /// Fades the plot in over 250ms; reduced motion shows it at once.
  final bool animated;

  /// A reading was clicked or activated with Enter/Space.
  final ValueChanged<IslandChartDataEvent>? onDataActivate;

  /// Accessible chart name; defaults to [title], then
  /// [IslandLocalizations.chart] (统计图表 in Chinese).
  final String? semanticLabel;

  /// Container fill replacing the theme surface, like the reference root
  /// `style.background`. Grid, text, tooltip and legend keep their theme
  /// colours; their contrast on this fill is the caller's responsibility.
  final Color? backgroundColor;

  /// Container border replacing the theme border.
  final Color? borderColor;

  @override
  State<IslandChart> createState() => _IslandChartState();
}

class _IslandChartState extends State<IslandChart>
    with TickerProviderStateMixin
    implements _Emphasis {
  final _hidden = <String>{};
  String? _activeKey, _focusedKey, _selectedKey, _legendFocus, _focusOwner;
  bool _focusVisible = false, _pointerFocus = false, _overMark = false;
  bool _detailsOpen = false;
  final _nodes = <String, FocusNode>{};
  final _scroll = ScrollController();
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: widget.animated && !widget.loading ? 0 : 1,
  );
  late final Animation<double> _fadeCurve = CurvedAnimation(
    parent: _fade,
    curve: _ease,
  );
  late final AnimationController _emphasis = AnimationController(
    vsync: this,
    duration: _shortMotion,
    value: 1,
  );
  final _from = <String, double>{}, _to = <String, double>{};
  _Derived? _derived;
  List<_Mark> get _marks => _derived?.scene.marks ?? const [];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_scrolled);
    if (_fade.value < 1) _fade.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _fade.value = 1;
      _emphasis.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant IslandChart old) {
    super.didUpdateWidget(old);
    if (old.loading && !widget.loading) {
      if (widget.animated && !MediaQuery.disableAnimationsOf(context)) {
        _fade.forward(from: 0);
      } else {
        _fade.value = 1;
      }
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_scrolled)
      ..dispose();
    _fade.dispose();
    _emphasis.dispose();
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _scrolled() => setState(() {});

  double _current(String key, double fallback) {
    final to = _to[key];
    if (to == null) return fallback;
    final from = _from[key] ?? to;
    return from + (to - from) * _ease.transform(_emphasis.value);
  }

  @override
  double markOpacity(String identity) => _current('o$identity', 1);
  @override
  double markShadow(String identity) => _current('s$identity', 0);
  @override
  double layerOpacity(int seriesIndex) => _current('l$seriesIndex', 1);

  void _retarget(Map<String, double> targets, bool reduced) {
    if (mapEquals(targets, _to)) return;
    final now = {
      for (final MapEntry(:key, :value) in targets.entries)
        key: _to.containsKey(key) ? _current(key, value) : value,
    };
    _from
      ..clear()
      ..addAll(now);
    _to
      ..clear()
      ..addAll(targets);
    if (reduced) {
      _emphasis.value = 1;
    } else {
      _emphasis.forward(from: 0);
    }
  }

  void _clearActive() {
    _activeKey = null;
    _focusedKey = null;
    _selectedKey = null;
  }

  void _activate(_Mark mark) {
    final key = mark.identity;
    setState(() {
      _activeKey = key;
      if (widget.selectable) _selectedKey = _selectedKey == key ? null : key;
    });
    widget.onDataActivate?.call(mark.point.event);
  }

  FocusNode _node(String identity) =>
      _nodes.putIfAbsent(identity, () => FocusNode(debugLabel: identity));

  void _releaseStaleNodes(Set<String> live) {
    final stale = [
      for (final MapEntry(:key, :value) in _nodes.entries)
        if (!live.contains(key)) (key, value),
    ];
    if (stale.isEmpty) return;
    for (final (key, _) in stale) {
      _nodes.remove(key);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final (_, node) in stale) {
        node.dispose();
      }
    });
  }

  _Mark? _markAt(Offset at) {
    for (final mark in _marks.reversed) {
      if (mark.hit(at)) return mark;
    }
    return null;
  }

  KeyEventResult _markKey(KeyEvent event, int index) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final marks = _marks;
    final key = event.logicalKey;
    if (event is KeyDownEvent &&
        (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter ||
            key == LogicalKeyboardKey.space)) {
      _activate(marks[index]);
      return KeyEventResult.handled;
    }
    final next = switch (key) {
      LogicalKeyboardKey.home => 0,
      LogicalKeyboardKey.end => marks.length - 1,
      LogicalKeyboardKey.arrowLeft ||
      LogicalKeyboardKey.arrowUp => (index - 1 + marks.length) % marks.length,
      LogicalKeyboardKey.arrowRight ||
      LogicalKeyboardKey.arrowDown => (index + 1) % marks.length,
      _ => null,
    };
    if (next == null) return KeyEventResult.ignored;
    final target = marks[next].identity;
    setState(() {
      _clearActive();
      _focusedKey = target;
      _focusVisible = true;
    });
    _node(target).requestFocus();
    return KeyEventResult.handled;
  }

  String _describe(
    _Point p,
    String Function(double) format,
    IslandLocalizations strings,
  ) {
    final type = p.type;
    if (p.candle case final c?) {
      return strings.chartCandle(
        format(c.open),
        format(c.close),
        format(c.low),
        format(c.high),
      );
    }
    if (_coordinateTypes.contains(type)) {
      final x =
          widget.data._xFormatter?.call(p.x) ??
          (type == IslandChartType.time ? _timestamp(p.x) : format(p.x));
      return '$x · ${format(p.value)}'
          '${type == IslandChartType.bubble ? ' · ${strings.chartWeight(format(p.size))}' : ''}';
    }
    return format(p.value);
  }

  /// The scene and every string derived from it, rebuilt only when an input
  /// that shapes them changes; hover, focus, legend hover and scrolling
  /// reuse it (reference `useMemo` on the scene).
  _Derived _derive(_SceneInputs inputs, List<_Series> series) {
    final cached = _derived;
    if (cached != null && cached.inputs == inputs) return cached;
    final all = _normalize(inputs.data, series, inputs.palette);
    final visible = [
      for (final p in all)
        if (!inputs.hidden.contains(
          _legendKey(inputs.data, series, p.seriesIndex, p.name, p.dataIndex),
        ))
          p,
    ];
    final scene = _buildScene(
      _SceneContext(
        data: inputs.data,
        series: series,
        points: visible,
        width: inputs.width,
        height: inputs.height,
        format: inputs.format,
        showAxes: inputs.showAxes,
        showLabels: inputs.showLabels,
        strings: inputs.strings,
      ),
    );
    String describe(_Point p) => _describe(p, inputs.format, inputs.strings);
    return _derived = _Derived(
      inputs: inputs,
      all: all,
      visible: visible,
      scene: scene,
      labels: [
        for (final m in scene.marks)
          inputs.strings.chartReading(
            m.point.seriesName,
            m.point.name,
            describe(m.point),
          ),
      ],
      rows: [for (final p in all) (p.seriesName, p.name, describe(p))],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = ChartColors.of(Theme.of(context).brightness);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final narrow = (MediaQuery.maybeSizeOf(context)?.width ?? 1000) <= 480;
    final padding = narrow ? 12.0 : 20.0;
    final border = IslandTheme.borderWidth(context, 1.5);
    final base = DefaultTextStyle.of(context).style
        .copyWith(decoration: TextDecoration.none);
    final label =
        widget.semanticLabel ??
        widget.title ??
        IslandLocalizations.of(context).chart;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.escape) {
            setState(_clearActive);
          }
          return KeyEventResult.ignored;
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? colors.surface,
            border: Border.all(
              color: widget.borderColor ?? colors.border,
              width: border,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding + border),
            child: LayoutBuilder(
              builder: (context, constraints) => _content(
                context,
                colors,
                base,
                label,
                reduced,
                constraints.maxWidth.isFinite ? constraints.maxWidth : 640,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(
    BuildContext context,
    ChartColors colors,
    TextStyle base,
    String label,
    bool reduced,
    double viewportWidth,
  ) {
    final data = widget.data;
    final type = data.type;
    final strings = IslandLocalizations.of(context);
    final format = widget.valueFormatter ?? _defaultFormat;
    final palette = widget.colors?.isNotEmpty == true
        ? widget.colors!
        : colors.series;
    final series = _seriesOf(data);
    final itemLegend = _itemTypes.contains(type);
    final chartHeight = widget.height.isFinite
        ? math.max(180.0, widget.height)
        : 300.0;
    final width = math.max(280.0, viewportWidth);
    final options = widget.tooltip;
    final shared =
        options?.trigger != IslandChartTooltipTrigger.item &&
        _sharedTypes.contains(type);
    String legendKey(int seriesIndex, String name, [int? index]) =>
        _legendKey(data, series, seriesIndex, name, index);
    final derived = _derive(
      _SceneInputs(
        data: data,
        palette: palette,
        hidden: Set.of(_hidden),
        width: width,
        height: chartHeight,
        format: format,
        showAxes: widget.showAxes,
        showLabels: widget.showLabels,
        strings: strings,
      ),
      series,
    );
    final allPoints = derived.all;
    final entries = itemLegend
        ? [
            for (final p in allPoints)
              (
                key: legendKey(p.seriesIndex, p.name, p.dataIndex),
                name: p.name,
                color: p.color,
              ),
          ]
        : [
            for (var i = 0; i < series.length; i++)
              (
                key: legendKey(i, series[i].name),
                name: series[i].name,
                color: series[i].color ?? palette[i % palette.length],
              ),
          ];
    final visible = derived.visible;
    final scene = derived.scene;
    final marks = scene.marks;
    bool present(String? key) => marks.any((m) => m.identity == key);
    if (widget.loading) {
      _activeKey = _focusedKey = _legendFocus = null;
    }
    if (widget.loading || !widget.selectable || !present(_selectedKey)) {
      _selectedKey = null;
    }
    _releaseStaleNodes({for (final m in marks) m.identity});
    final selected = widget.selectable
        ? marks.where((m) => m.identity == _selectedKey).firstOrNull
        : null;
    final active =
        selected ??
        marks
            .where((m) => m.identity == (_activeKey ?? _focusedKey))
            .firstOrNull;
    final related = active == null
        ? const <_Mark>[]
        : _relatedMarks(marks, active, shared);
    final relatedKeys = {for (final m in related) m.key};
    final focusedLegend = entries
        .where((e) => e.key == _legendFocus && !_hidden.contains(e.key))
        .firstOrNull;
    final hiddenCount = entries.where((e) => _hidden.contains(e.key)).length;
    final empty = marks.isEmpty;
    final allHidden = allPoints.isNotEmpty && visible.isEmpty;
    final missingMap = type == IslandChartType.map && data._regions.isEmpty;

    bool muted(_Mark mark) {
      if (!widget.highlight) return false;
      if (focusedLegend != null) {
        return legendKey(
              mark.point.seriesIndex,
              mark.point.name,
              mark.point.dataIndex,
            ) !=
            focusedLegend.key;
      }
      return active != null && !relatedKeys.contains(mark.key);
    }

    _retarget({
      for (final m in marks) ...{
        'o${m.identity}': muted(m) ? 0.24 : 1,
        's${m.identity}':
            widget.highlight && active != null && relatedKeys.contains(m.key)
            ? 1
            : 0,
      },
      for (final layer in scene.layers)
        'l${layer.seriesIndex}':
            widget.highlight &&
                focusedLegend != null &&
                legendKey(layer.seriesIndex, '') != focusedLegend.key
            ? 0.24
            : 1,
    }, reduced);

    final total = marks.fold<double>(
      0,
      (sum, m) => sum + math.max(0, m.point.value),
    );
    IslandChartTooltipContext? tooltipContext;
    if (active != null && options != null) {
      final first = marks.firstOrNull?.point.value ?? 0;
      tooltipContext = IslandChartTooltipContext(
        type: type,
        name: type == IslandChartType.time
            ? data._xFormatter?.call(active.point.x) ??
                  _timestamp(active.point.x)
            : active.point.name,
        locked: selected != null,
        items: [
          for (final mark in related)
            if (marks.indexOf(mark) case final index)
              if (index > 0 ? marks[index - 1].point.value : 0.0
                  case final previous)
                if (type == IslandChartType.funnel ? first : total
                    case final denominator)
                  IslandChartTooltipItem(
                    type: type,
                    seriesIndex: mark.point.seriesIndex,
                    dataIndex: mark.point.dataIndex,
                    seriesName: mark.point.seriesName,
                    name: mark.point.name,
                    value: mark.point.value,
                    datum: mark.point.datum,
                    color: mark.point.color,
                    formattedValue: _describe(mark.point, format, strings),
                    percentage:
                        const {
                              IslandChartType.pie,
                              IslandChartType.ring,
                              IslandChartType.rose,
                              IslandChartType.funnel,
                            }.contains(type) &&
                            denominator > 0
                        ? mark.point.value / denominator * 100
                        : null,
                    conversion: type == IslandChartType.funnel && previous > 0
                        ? mark.point.value / previous * 100
                        : null,
                  ),
        ],
      );
    }
    final tooltipContent = options == null || tooltipContext == null
        ? null
        : options.builder != null
        ? options.builder!(context, tooltipContext)
        : _TooltipContent(
            context: tooltipContext,
            colors: colors,
            showPercentage: options.showPercentage,
            selectable: widget.selectable,
          );

    final plot = scene.plot;
    final crosshair = <(Offset, Offset)>[
      if (options != null &&
          options.crosshair &&
          active != null &&
          plot != null) ...[
        if (plot.horizontal)
          (
            Offset(plot.left, active.axisPosition ?? active.y),
            Offset(plot.right, active.axisPosition ?? active.y),
          )
        else
          (
            Offset(active.axisPosition ?? active.x, plot.top),
            Offset(active.axisPosition ?? active.x, plot.bottom),
          ),
        if (!shared && !plot.horizontal)
          (Offset(plot.left, active.y), Offset(plot.right, active.y)),
      ],
    ];
    final haloTypes = const {
      IslandChartType.line,
      IslandChartType.area,
      IslandChartType.mix,
      IslandChartType.time,
      IslandChartType.scatter,
      IslandChartType.bubble,
      IslandChartType.radar,
    };
    for (final m in marks) {
      m.hitHalo = m.point.value == 0 || haloTypes.contains(type);
    }
    final tabStop = present(_focusedKey)
        ? _focusedKey
        : marks.firstOrNull?.identity;
    final focusedMark = _focusVisible
        ? marks.where((m) => m.identity == _focusedKey).firstOrNull
        : null;

    void restoreAll() => setState(() {
      _hidden.clear();
      _clearActive();
    });

    final canvas = MouseRegion(
      cursor: _overMark ? SystemMouseCursors.click : MouseCursor.defer,
      onHover: (event) {
        final hit = _markAt(event.localPosition);
        String? key;
        if (hit != null) {
          key = hit.identity;
        } else {
          key = _nearestMark(
            scene,
            event.localPosition.dx,
            event.localPosition.dy,
            shared,
          )?.identity;
        }
        if (_overMark != (hit != null) ||
            (selected == null && key != _activeKey) ||
            (selected != null && hit != null && key != _activeKey)) {
          setState(() {
            _overMark = hit != null;
            if (selected == null || hit != null) _activeKey = key;
          });
        }
      },
      onExit: (_) => setState(() {
        _overMark = false;
        _activeKey = null;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final hit = _markAt(details.localPosition);
          if (hit == null) {
            setState(_clearActive);
            return;
          }
          final node = _node(hit.identity);
          if (node.hasFocus) {
            _focusVisible = false;
          } else {
            _pointerFocus = true;
            node.requestFocus();
          }
          _activate(hit);
        },
        child: CustomPaint(
          size: Size(width, chartHeight),
          painter: _ChartPainter(
            scene: scene,
            colors: colors,
            textStyle: base,
            showBackground: !empty,
            emphasis: this,
            crosshair: crosshair,
            indicators:
                widget.highlight &&
                    active != null &&
                    (plot != null || type == IslandChartType.radar)
                ? related
                : const [],
            focused: focusedMark,
            repaint: _emphasis,
          ),
        ),
      ),
    );

    final plotGroup = Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: Stack(
        children: [
          canvas,
          for (final (path, name) in scene.emptyRegions)
            if (path.getBounds() case final bounds)
              Positioned.fromRect(
                rect: bounds,
                child: _EmptyRegion(
                  outline: path.shift(-bounds.topLeft),
                  label: strings.chartRegionNoData(name),
                  // Empty plot space, as on the reference SVG background.
                  onTap: () => setState(_clearActive),
                ),
              ),
          for (var i = 0; i < marks.length; i++)
            Positioned.fromRect(
              rect: marks[i].bounds,
              child: _markNode(
                marks[i],
                i,
                tabStop: marks[i].identity == tabStop,
                pressed: widget.selectable ? selected == marks[i] : null,
                label: derived.labels[i],
              ),
            ),
        ],
      ),
    );

    final tooltipVisible = tooltipContent != null && active != null;
    final viewport = SizedBox(
      height: chartHeight,
      child: widget.loading
          ? Semantics(
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    strings.chartLoading,
                    textAlign: TextAlign.center,
                    style: base.copyWith(
                      fontSize: 14,
                      color: colors.secondaryInk,
                    ),
                  ),
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  // Reference `.viewport`: `overflow: auto` with a thin
                  // scrollbar over a transparent track, shown only while
                  // the 280px minimum plot overflows a narrower parent.
                  child: RawScrollbar(
                    controller: _scroll,
                    thumbVisibility: true,
                    thickness: 4,
                    radius: Radius.zero,
                    crossAxisMargin: 0,
                    mainAxisMargin: 0,
                    thumbColor: colors.scrollbar,
                    // Shown at full colour at once, as the reference.
                    fadeDuration: Duration.zero,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        controller: _scroll,
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: width,
                          height: chartHeight,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              FadeTransition(
                                opacity: _fadeCurve,
                                child: plotGroup,
                              ),
                              if (tooltipVisible)
                                Positioned.fill(
                                  child: CustomSingleChildLayout(
                                    delegate: _TooltipLayout(
                                      anchor: Offset(active.x, active.y),
                                      height: chartHeight,
                                      viewportWidth: viewportWidth,
                                      scrollLeft: _scroll.hasClients
                                          ? _scroll.offset
                                          : 0,
                                    ),
                                    child: _TooltipPanel(
                                      colors: colors,
                                      locked: selected != null,
                                      child: tooltipContent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (empty)
                  Positioned.fill(
                    child: Semantics(
                      liveRegion: true,
                      container: true,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child:
                              !allHidden && !missingMap && widget.empty != null
                              ? widget.empty!
                              : IslandNoData(
                                  size: IslandSize.small,
                                  title: Text(
                                    allHidden
                                        ? strings.chartAllHidden
                                        : missingMap
                                        ? strings.chartMissingMap
                                        : strings.noData,
                                  ),
                                  description: allHidden
                                      ? Text(strings.chartAllHiddenHint)
                                      : null,
                                  actions: [
                                    if (hiddenCount > 0)
                                      IslandButton(
                                        size: IslandSize.small,
                                        onPressed: restoreAll,
                                        child: Text(strings.chartRestoreLegend),
                                      ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );

    final text = base.copyWith(color: colors.ink);
    final secondary = base.copyWith(
      color: colors.secondaryInk,
      fontSize: 12,
      height: 1.7,
    );
    // Reference `.title` inherits `line-height: normal`: each font keeps its
    // own metrics and the primary font is the line's minimum (CSS strut), so
    // a title mixing Latin and CJK runs is as tall as an all-CJK one.
    final titleStyle = text.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w800,
      height: kTextHeightNone,
    );
    final title = widget.title, description = widget.description;
    return DefaultTextStyle(
      style: text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || description != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title,
                      style: titleStyle,
                      strutStyle: StrutStyle.fromTextStyle(titleStyle),
                    ),
                  if (description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      // Reference `.description` `line-height: 1.7`: a fixed
                      // line box placed by the primary font, whatever
                      // fallback font a run uses.
                      child: Text(
                        description,
                        style: secondary,
                        strutStyle: StrutStyle.fromTextStyle(
                          secondary,
                          forceStrutHeight: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          viewport,
          if (widget.legend && entries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                label: strings.chartLegend,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final entry in entries)
                      MouseRegion(
                        onEnter: (_) =>
                            setState(() => _legendFocus = entry.key),
                        onExit: (_) => setState(() {
                          if (_legendFocus == entry.key) _legendFocus = null;
                        }),
                        child: Focus(
                          canRequestFocus: false,
                          skipTraversal: true,
                          onFocusChange: (focused) => setState(() {
                            if (focused) {
                              _legendFocus = entry.key;
                            } else if (_legendFocus == entry.key) {
                              _legendFocus = null;
                            }
                          }),
                          child: _Pill(
                            key: ValueKey(entry.key),
                            label: entry.name,
                            colors: colors,
                            reduced: reduced,
                            swatch: entry.color,
                            hidden: _hidden.contains(entry.key),
                            onPressed: () => setState(() {
                              if (!_hidden.remove(entry.key)) {
                                _hidden.add(entry.key);
                              }
                              _clearActive();
                            }),
                          ),
                        ),
                      ),
                    if (hiddenCount > 0 && !empty)
                      _Pill(
                        label: strings.chartRestoreLegend,
                        colors: colors,
                        reduced: reduced,
                        onPressed: restoreAll,
                      ),
                  ],
                ),
              ),
            ),
          if (!widget.loading && selected != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 16,
                runSpacing: 8,
                children: [
                  Text(
                    strings.chartLockedReading(selected.point.name),
                    style: text.copyWith(fontSize: 12),
                  ),
                  _Pill(
                    label: strings.chartUnlock,
                    colors: colors,
                    reduced: reduced,
                    lift: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    onPressed: () => setState(_clearActive),
                  ),
                ],
              ),
            ),
          if (!widget.loading && allPoints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: _DataDetails(
                open: _detailsOpen,
                onToggle: () => setState(() => _detailsOpen = !_detailsOpen),
                caption: strings.chartDataCaption(label),
                colors: colors,
                style: base,
                rows: derived.rows,
              ),
            ),
          if (type == IslandChartType.word &&
              marks.length < visible.where((p) => p.value > 0).length)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(strings.chartWordsOmitted, style: secondary),
            ),
        ],
      ),
    );
  }

  Widget _markNode(
    _Mark mark,
    int index, {
    required bool tabStop,
    required bool? pressed,
    required String label,
  }) {
    final identity = mark.identity;
    return Semantics(
      container: true,
      button: true,
      toggled: pressed,
      label: label,
      onTap: () => _activate(mark),
      child: Focus(
        focusNode: _node(identity),
        skipTraversal: !tabStop,
        onFocusChange: (focused) {
          if (focused == (_focusOwner == identity)) return;
          setState(() {
            if (focused) {
              _focusOwner = identity;
              _activeKey = null;
              _focusedKey = identity;
              _focusVisible = !_pointerFocus;
              _pointerFocus = false;
            } else {
              _focusOwner = null;
              if (_focusedKey == identity) _focusedKey = null;
            }
          });
        },
        onKeyEvent: (_, event) => _markKey(event, index),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// A map region without data: hit-tested inside its own outline only, it
/// shows the reference `<title>` text on hover and names the region for
/// assistive technology. It is not a reading and takes no focus.
class _EmptyRegion extends StatelessWidget {
  const _EmptyRegion({
    required this.outline,
    required this.label,
    required this.onTap,
  });
  final Path outline;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _OutlineClipper(outline),
    child: IslandTooltip(
      message: label,
      excludeFromSemantics: true,
      child: Semantics(
        container: true,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: onTap,
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
}

class _OutlineClipper extends CustomClipper<Path> {
  const _OutlineClipper(this.outline);
  final Path outline;
  @override
  Path getClip(Size size) => outline;
  @override
  bool shouldReclip(_OutlineClipper old) => old.outline != outline;
}

/// Places the tooltip beside its reading, inside the visible plot.
class _TooltipLayout extends SingleChildLayoutDelegate {
  const _TooltipLayout({
    required this.anchor,
    required this.height,
    required this.viewportWidth,
    required this.scrollLeft,
  });
  final Offset anchor;
  final double height, viewportWidth, scrollLeft;

  double get _width => math.min(260, math.max(1, viewportWidth - 16));

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        minWidth: _width,
        maxWidth: _width,
        maxHeight: math.max(0, height - 16),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final w = childSize.width, h = childSize.height;
    final x = anchor.dx, y = anchor.dy;
    final preferred = x + 16 + w <= scrollLeft + viewportWidth - 8
        ? x + 16
        : x - w - 16;
    final left = math.max(
      scrollLeft + 8,
      math.min(preferred, scrollLeft + viewportWidth - w - 8),
    );
    final top = math.max(
      8.0,
      math.min(height - h - 8, y - h - 14 >= 8 ? y - h - 14 : y + 16),
    );
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_TooltipLayout old) =>
      anchor != old.anchor ||
      height != old.height ||
      viewportWidth != old.viewportWidth ||
      scrollLeft != old.scrollLeft;
}

/// The tooltip surface; hover panels let clicks through, locked panels
/// scroll long content.
class _TooltipPanel extends StatelessWidget {
  const _TooltipPanel({
    required this.colors,
    required this.locked,
    required this.child,
  });
  final ChartColors colors;
  final bool locked;
  final Widget child;
  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: !locked,
    child: Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          boxShadow: const [
            BoxShadow(
              color: ChartColors.tooltipShadow,
              offset: Offset(0, 4),
              blurRadius: 14,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: colors.ink,
                fontSize: 12,
                height: 1.6,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// The reference default tooltip content.
class _TooltipContent extends StatelessWidget {
  const _TooltipContent({
    required this.context,
    required this.colors,
    required this.showPercentage,
    required this.selectable,
  });
  final IslandChartTooltipContext context;
  final ChartColors colors;
  final bool showPercentage, selectable;

  @override
  Widget build(BuildContext buildContext) {
    final tip = context;
    final strings = IslandLocalizations.of(buildContext);
    final rule = BorderSide(color: colors.border);
    final funnel = tip.type == IslandChartType.funnel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(border: Border(bottom: rule)),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              Text(
                tip.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (tip.locked)
                Text(strings.chartLocked, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
        for (final item in tip.items)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, right: 8),
                  child: _Swatch(item.color),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(item.seriesName)),
                          const SizedBox(width: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 16 * 7),
                            child: Text(
                              item.formattedValue,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (showPercentage && item.percentage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            (funnel
                                ? strings.chartOfFirstStage
                                : strings.chartShare)(
                              _defaultFormat(item.percentage!),
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      if (showPercentage && item.conversion != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            strings.chartOfPreviousStage(
                              _defaultFormat(item.conversion!),
                            ),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (selectable)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(border: Border(top: rule)),
            child: Text(
              tip.locked ? strings.chartUnlockHint : strings.chartLockHint,
              style: const TextStyle(fontSize: 11),
            ),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.color);
  final Color color;
  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 10,
    child: DecoratedBox(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    ),
  );
}

/// Legend entry and the restore/release pills.
class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.colors,
    required this.reduced,
    required this.onPressed,
    this.swatch,
    this.hidden,
    this.lift = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });
  final String label;
  final ChartColors colors;
  final bool reduced, lift;
  final VoidCallback onPressed;
  final Color? swatch;

  /// Legend visibility; null for plain action pills.
  final bool? hidden;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final off = hidden == true;
    return ActionSurface(
      toggled: hidden == null ? null : !off,
      onActivate: onPressed,
      builder: (context, states) {
        final hovered = states.contains(WidgetState.hovered);
        final fill = hovered ? colors.legendHover : colors.legendFill;
        return AnimatedContainer(
          duration: reduced ? Duration.zero : _shortMotion,
          curve: _ease,
          constraints: BoxConstraints(minHeight: lift ? 32 : 0),
          transform: Matrix4.translationValues(
            0,
            lift && !reduced && hovered && !states.contains(WidgetState.pressed)
                ? -1
                : 0,
            0,
          ),
          padding: padding,
          decoration: BoxDecoration(
            color: off ? fill.withValues(alpha: fill.a * 0.5) : fill,
            borderRadius: const BorderRadius.all(Radius.circular(50)),
          ),
          foregroundDecoration: FocusOutline(
            const StadiumBorder(),
            states.contains(WidgetState.focused)
                ? colors.focus
                : Colors.transparent,
            width: 2,
            offset: 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (swatch case final color?) ...[
                Opacity(opacity: off ? 0.5 : 1, child: _Swatch(color)),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: off ? colors.legendHiddenInk : colors.ink,
                  decoration: off
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: colors.legendHiddenInk,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The expandable data table, the non-visual alternative to the plot.
class _DataDetails extends StatelessWidget {
  const _DataDetails({
    required this.open,
    required this.onToggle,
    required this.caption,
    required this.colors,
    required this.style,
    required this.rows,
  });
  final bool open;
  final VoidCallback onToggle;
  final String caption;
  final ChartColors colors;
  final TextStyle style;
  final List<(String, String, String)> rows;

  /// Reference `.data table { width: 100% }` under automatic table layout:
  /// every column is at least as wide as its widest cell, and a table
  /// narrower than the chart shares the spare width between the columns in
  /// proportion to those widths. A wider table keeps its content widths and
  /// scrolls in `.tableScroll`.
  Map<int, TableColumnWidth> _columnWidths(
    BuildContext context,
    double available,
    TextStyle cell,
  ) {
    final headers = IslandLocalizations.of(context).chartTableHeaders;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final base = DefaultTextStyle.of(context).style.merge(cell);
    final bold = base.copyWith(fontWeight: FontWeight.w700);
    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width.ceilToDouble() + 24;
    }

    final widths = [
      for (var i = 0; i < 3; i++)
        [
          if (i < headers.length) measure(headers[i], bold),
          for (final row in rows)
            measure(switch (i) {
              0 => row.$1,
              1 => row.$2,
              _ => row.$3,
            }, base),
        ].fold<double>(24, math.max),
    ];
    final total = widths.fold<double>(0, (sum, width) => sum + width);
    final scale = available.isFinite && available > total
        ? available / total
        : 1.0;
    return {for (var i = 0; i < 3; i++) i: FixedColumnWidth(widths[i] * scale)};
  }

  @override
  Widget build(BuildContext context) {
    final cell = style.copyWith(
      fontSize: 12,
      color: colors.ink,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final rule = BoxDecoration(
      border: Border(bottom: BorderSide(color: colors.border)),
    );
    final summary = IslandLocalizations.of(context).chartViewData(rows.length);
    final summaryStyle = style.copyWith(
      fontSize: 12,
      height: kTextHeightNone,
      color: colors.secondaryInk,
    );
    Widget pad(String text, {bool header = false}) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        text,
        style: header ? cell.copyWith(fontWeight: FontWeight.w700) : cell,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionSurface(
          expanded: open,
          onActivate: onToggle,
          builder: (context, states) => Container(
            padding: const EdgeInsets.all(4),
            foregroundDecoration: FocusOutline(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              states.contains(WidgetState.focused)
                  ? colors.focus
                  : Colors.transparent,
              width: 2,
              offset: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(10, 10),
                  painter: _DisclosurePainter(colors.secondaryInk, open),
                ),
                const SizedBox(width: 4),
                // Reference `.data summary` is 12px and, like `.title`,
                // inherits `line-height: normal`: the label mixing digits and
                // CJK is an 18px line (Nunito 12/4, Noto Sans SC 14/3
                // rounded), where Flutter's own line is 19.
                CssLineBox(
                  height: cssNormalLineHeight(context, summary, summaryStyle),
                  child: Text(summary, style: summaryStyle),
                ),
              ],
            ),
          ),
        ),
        if (open)
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pad(caption),
                      Table(
                        columnWidths: _columnWidths(
                          context,
                          constraints.maxWidth,
                          cell,
                        ),
                        children: [
                          TableRow(
                            decoration: rule,
                            children: [
                              for (final header in IslandLocalizations.of(
                                context,
                              ).chartTableHeaders)
                                pad(header, header: true),
                            ],
                          ),
                          for (final (series, name, value) in rows)
                            TableRow(
                              decoration: rule,
                              children: [pad(series), pad(name), pad(value)],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The `<details>` disclosure triangle.
class _DisclosurePainter extends CustomPainter {
  const _DisclosurePainter(this.color, this.open);
  final Color color;
  final bool open;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final path = open
        ? (Path()
            ..moveTo(w * 0.1, h * 0.25)
            ..lineTo(w * 0.9, h * 0.25)
            ..lineTo(w * 0.5, h * 0.85))
        : (Path()
            ..moveTo(w * 0.25, h * 0.1)
            ..lineTo(w * 0.85, h * 0.5)
            ..lineTo(w * 0.25, h * 0.9));
    canvas.drawPath(path..close(), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_DisclosurePainter old) =>
      old.color != color || old.open != open;
}
