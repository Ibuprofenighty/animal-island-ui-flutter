import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../../shared/palette.dart';
import 'example.dart';

const _ease = Cubic(0.4, 0, 0.2, 1);
const _short = Duration(milliseconds: 200);

/// CSS margin collapsing between adjacent blocks: a block whose leading
/// margin is [margin] after a sibling that already left [preceding] adds only
/// the difference, so the gap is the larger margin, not the sum.
double collapseMargin(double margin, double preceding) =>
    math.max(0, margin - preceding);

/// Reference `.note` bottom margin (`margin: 12px 0 20px`).
const chartNoteSpaceAfter = 20.0;

/// Reference `.gallery` bottom margin (`margin: 24px 0 32px`).
const chartGallerySpaceAfter = 32.0;

/// Opens another Gallery route through the app router (reference
/// `<a href="#/chart-…">`). Hosts without a router ignore it.
void openGalleryRoute(BuildContext context, String id) {
  final provider = Router.maybeOf(context)?.routeInformationProvider;
  if (provider is PlatformRouteInformationProvider) {
    provider.didPushRouteInformation(RouteInformation(uri: Uri(path: '/$id')));
  }
}

/// Reference demo text with a fixed CSS `line-height`: every line box has
/// that height and is placed by the primary font, so a line mixing Latin and
/// CJK runs is as tall as an all-CJK one.
class ChartLineText extends StatelessWidget {
  const ChartLineText(this.text, {super.key, required this.style});
  final String text;
  final TextStyle style;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: style,
    strutStyle: StrutStyle.fromTextStyle(
      DefaultTextStyle.of(context).style.merge(style),
      forceStrutHeight: true,
    ),
  );
}

/// Reference demo.module.less `.note` (margin 12 0 20, 13px / 1.8).
class ChartNote extends StatelessWidget {
  const ChartNote(this.text, {super.key, this.status = false});
  final String text;

  /// Reference `role="status"`: announced when it changes.
  final bool status;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: chartNoteSpaceAfter),
    child: Semantics(
      liveRegion: status,
      child: ChartLineText(
        text,
        style: const TextStyle(
          fontSize: 13,
          height: 1.8,
          color: GalleryPalette.chartNote,
        ),
      ),
    ),
  );
}

/// Reference `sectionTitleStyle` used inside a section (18 / 600 #725d42).
class ChartSectionTitle extends StatelessWidget {
  const ChartSectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: GalleryPalette.storyInk,
      ),
    ),
  );
}

/// Reference CSS grid of equal `minmax(0, 1fr)` columns, rows aligned to
/// the start (`align-items: start`).
class ChartGrid extends StatelessWidget {
  const ChartGrid({
    super.key,
    required this.columns,
    required this.children,
    this.rowGap = 24,
    this.columnGap = 20,
    this.equalRows = false,
  });
  final int columns;
  final double rowGap, columnGap;

  /// Reference `grid-auto-rows: 1fr`: every row of the grid as tall as the
  /// tallest one, and every item stretched to its row.
  final bool equalRows;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    if (equalRows) {
      return _UniformRowGrid(
        columns: columns,
        rowGap: rowGap,
        columnGap: columnGap,
        children: children,
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: columnGap,
          children: [
            for (var j = i; j < i + columns; j++)
              Expanded(
                child: j < children.length ? children[j] : const SizedBox(),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: rowGap,
      children: rows,
    );
  }
}

class _UniformRowGrid extends MultiChildRenderObjectWidget {
  const _UniformRowGrid({
    required this.columns,
    required this.rowGap,
    required this.columnGap,
    required super.children,
  });
  final int columns;
  final double rowGap, columnGap;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderUniformRowGrid(columns, rowGap, columnGap);
  @override
  void updateRenderObject(
    BuildContext context,
    _RenderUniformRowGrid renderObject,
  ) {
    renderObject
      ..columns = columns
      ..rowGap = rowGap
      ..columnGap = columnGap;
  }
}

class _GridCell extends ContainerBoxParentData<RenderBox> {}

class _RenderUniformRowGrid extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _GridCell>,
        RenderBoxContainerDefaultsMixin<RenderBox, _GridCell> {
  _RenderUniformRowGrid(this._columns, this._rowGap, this._columnGap);
  int _columns;
  double _rowGap, _columnGap;
  set columns(int value) {
    if (value == _columns) return;
    _columns = value;
    markNeedsLayout();
  }

  set rowGap(double value) {
    if (value == _rowGap) return;
    _rowGap = value;
    markNeedsLayout();
  }

  set columnGap(double value) {
    if (value == _columnGap) return;
    _columnGap = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _GridCell) child.parentData = _GridCell();
  }

  double _cellWidth(double width) =>
      math.max(0, (width - _columnGap * (_columns - 1)) / _columns);

  double _rowHeight(double cellWidth) {
    var height = 0.0;
    for (final child in getChildrenAsList()) {
      height = math.max(height, child.getMaxIntrinsicHeight(cellWidth));
    }
    return height;
  }

  double _height(double width) {
    if (childCount == 0) return 0;
    final rows = (childCount / _columns).ceil();
    return rows * _rowHeight(_cellWidth(width)) + (rows - 1) * _rowGap;
  }

  @override
  double computeMinIntrinsicHeight(double width) => _height(width);
  @override
  double computeMaxIntrinsicHeight(double width) => _height(width);
  @override
  double computeMinIntrinsicWidth(double height) => 0;
  @override
  double computeMaxIntrinsicWidth(double height) {
    var cell = 0.0;
    for (final child in getChildrenAsList()) {
      cell = math.max(cell, child.getMaxIntrinsicWidth(double.infinity));
    }
    return cell * _columns + _columnGap * (_columns - 1);
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    Size(constraints.maxWidth, _height(constraints.maxWidth)),
  );

  @override
  void performLayout() {
    final width = constraints.maxWidth;
    final cellWidth = _cellWidth(width);
    final rowHeight = _rowHeight(cellWidth);
    var index = 0;
    for (final child in getChildrenAsList()) {
      child.layout(
        BoxConstraints.tightFor(width: cellWidth, height: rowHeight),
      );
      final column = index % _columns, row = index ~/ _columns;
      (child.parentData! as _GridCell).offset = Offset(
        column * (cellWidth + _columnGap),
        row * (rowHeight + _rowGap),
      );
      index++;
    }
    size = constraints.constrain(Size(width, _height(width)));
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

/// Reference gallery.module.less `.gallery`: a headed block of examples with
/// a bottom rule, laid out by its own width (container queries).
class ChartGallerySection extends StatelessWidget {
  const ChartGallerySection({
    super.key,
    required this.semanticLabel,
    required this.title,
    required this.body,
    required this.children,
    this.comparison = false,
    this.footer,
    this.precedingMargin = 0,
  });
  final String semanticLabel, title, body;
  final List<Widget> children;

  /// Reference `.comparison-grid`: two columns, never four.
  final bool comparison;
  final Widget? footer;

  /// Space the previous sibling already leaves below itself; the reference
  /// 24px top margin collapses with it.
  final double precedingMargin;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: semanticLabel,
    child: Container(
      margin: EdgeInsets.only(
        top: collapseMargin(24, precedingMargin),
        bottom: chartGallerySpaceAfter,
      ),
      padding: const EdgeInsets.only(bottom: 28),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: GalleryPalette.rule)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columns = width <= 719
              ? 1
              : (!comparison && width >= 1400 ? 4 : 2);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: ChartLineText(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: GalleryPalette.demoStrongInk,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ChartLineText(
                      body,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.8,
                        color: GalleryPalette.chartGalleryBody,
                      ),
                    ),
                  ],
                ),
              ),
              ChartGrid(columns: columns, children: children),
              ?footer,
            ],
          );
        },
      ),
    ),
  );
}

/// Reference `ChartGalleryItem`: the chart, a 查看配置 disclosure and, in
/// the overview, a link to the type page.
class ChartGalleryItem extends StatelessWidget {
  const ChartGalleryItem({super.key, required this.example, this.link});
  final ChartExample example;

  /// Link text and target route of the overview showcase.
  final (String, String)? link;
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: '${example.title}示例',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        example.chart(),
        ChartActions(disclosure: '查看配置', code: example.code, link: link),
      ],
    ),
  );
}

/// Reference `.actions`: a `<details>` code disclosure and an optional link,
/// spread to both ends and wrapping; the open disclosure takes the row.
class ChartActions extends StatefulWidget {
  const ChartActions({
    super.key,
    required this.disclosure,
    required this.code,
    this.link,
  });
  final String disclosure, code;
  final (String, String)? link;
  @override
  State<ChartActions> createState() => _ChartActionsState();
}

class _ChartActionsState extends State<ChartActions> {
  bool open = false;
  @override
  Widget build(BuildContext context) {
    final summary = ChartPressable(
      label: widget.disclosure,
      expanded: open,
      onPressed: () => setState(() => open = !open),
    );
    final link = switch (widget.link) {
      (final text, final route) => ChartPressable(
        label: text,
        link: true,
        onPressed: () => openGalleryRoute(context, route),
      ),
      null => null,
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 12,
          color: GalleryPalette.chartActionInk,
        ),
        child: open
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(alignment: Alignment.centerLeft, child: summary),
                  // The library CodeBlock keeps `.wrapper { margin: 1em 0 }`
                  // (12px at the 12px `.actions` size); its top collapses
                  // with the open summary's 8px bottom margin and its bottom
                  // stays inside the `<details>` flex item.
                  IslandCodeBlock(
                    code: widget.code,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  // Alone on its flex line, `space-between` starts it.
                  if (link != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: link,
                      ),
                    ),
                ],
              )
            : Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 4,
                children: [summary, ?link],
              ),
      ),
    );
  }
}

/// Keys of a focused reference `<a>`: Enter follows it; Space scrolls the
/// page as in a browser instead of activating it.
const _linkKeys = <ShortcutActivator, Intent>{
  SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
  SingleActivator(LogicalKeyboardKey.space): ScrollIntent(
    direction: AxisDirection.down,
    type: ScrollIncrementType.page,
  ),
  SingleActivator(LogicalKeyboardKey.space, shift: true): ScrollIntent(
    direction: AxisDirection.up,
    type: ScrollIncrementType.page,
  ),
};

/// Reference `summary` / `.actions a`: 8px padding, radius 12, `#f0e8d8`
/// hover over 0.2s, 2px focus ring 2px outside. A disclosure ([expanded]
/// set) leads with the native `<summary>` marker in the summary ink.
class ChartPressable extends StatefulWidget {
  const ChartPressable({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded,
    this.link = false,
  });
  final String label;
  final bool? expanded;
  final bool link;
  final VoidCallback onPressed;
  @override
  State<ChartPressable> createState() => _ChartPressableState();
}

class _ChartPressableState extends State<ChartPressable> {
  bool hover = false, focus = false;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final expanded = widget.expanded;
    final style = TextStyle(
      height: 1.6,
      color: expanded != null ? GalleryPalette.chartSummaryInk : null,
      decoration: widget.link ? TextDecoration.underline : null,
      decorationColor: GalleryPalette.chartActionInk,
    );
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => hover = value),
      onShowFocusHighlight: (value) => setState(() => focus = value),
      shortcuts: widget.link ? _linkKeys : null,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Semantics(
        container: true,
        button: !widget.link,
        link: widget.link,
        expanded: expanded,
        label: widget.label,
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: reduced ? Duration.zero : _short,
              curve: _ease,
              padding: const EdgeInsets.all(8),
              foregroundDecoration: focus
                  ? BoxDecoration(
                      border: Border.all(
                        color: IslandTokens.light.focus,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignOutside + 2,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    )
                  : null,
              decoration: BoxDecoration(
                color: hover
                    ? GalleryPalette.chartActionHover
                    : GalleryPalette.chartActionHover.withValues(alpha: 0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (expanded != null)
                    CustomPaint(
                      size: const Size(13, 8),
                      painter: _SummaryMarker(open: expanded),
                    ),
                  Flexible(child: ChartLineText(widget.label, style: style)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chromium's `<summary>` `disclosure-closed` / `disclosure-open` marker: a
/// solid 6×8 triangle (8×6 when open) and its gap to the label.
class _SummaryMarker extends CustomPainter {
  const _SummaryMarker({required this.open});
  final bool open;
  @override
  void paint(Canvas canvas, Size size) {
    final path = open
        ? (Path()
            ..moveTo(0, 1)
            ..lineTo(8, 1)
            ..lineTo(4, 7))
        : (Path()
            ..moveTo(0, 0)
            ..lineTo(6, 4)
            ..lineTo(0, 8));
    canvas.drawPath(
      path..close(),
      Paint()..color = GalleryPalette.chartSummaryInk,
    );
  }

  @override
  bool shouldRepaint(_SummaryMarker old) => old.open != open;
}

/// Reference catalog card: a link to one chart type page.
class ChartCatalogCard extends StatefulWidget {
  const ChartCatalogCard({
    super.key,
    required this.label,
    required this.desc,
    required this.onPressed,
  });
  final String label, desc;
  final VoidCallback onPressed;
  @override
  State<ChartCatalogCard> createState() => _ChartCatalogCardState();
}

class _ChartCatalogCardState extends State<ChartCatalogCard> {
  bool hover = false, focus = false, pressed = false;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced ? Duration.zero : _short;
    // Reference `border: 1.5px`: the browser snaps a border width down to
    // whole device pixels (at least one), so it paints and lays out 1px at
    // 1x and 1.5px at 2x. The content then starts 25px below the card top.
    final border = IslandTheme.borderWidth(context, 1.5);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (value) => setState(() => hover = value),
      onShowFocusHighlight: (value) => setState(() => focus = value),
      shortcuts: _linkKeys,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onPressed();
            return null;
          },
        ),
      },
      child: Semantics(
        link: true,
        label: '${widget.label} ${widget.desc}',
        child: ExcludeSemantics(
          // Reference `a:active { transform: translateY(0) }`: a press drops
          // the hover lift until the pointer is released.
          child: Listener(
            onPointerDown: (_) => setState(() => pressed = true),
            onPointerUp: (_) => setState(() => pressed = false),
            onPointerCancel: (_) => setState(() => pressed = false),
            child: GestureDetector(
              onTap: widget.onPressed,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: hover && !pressed && !reduced ? -2 : 0),
                duration: duration,
                curve: _ease,
                builder: (context, lift, child) =>
                    Transform.translate(offset: Offset(0, lift), child: child),
                child: AnimatedContainer(
                  duration: duration,
                  curve: _ease,
                  constraints: const BoxConstraints(minHeight: 110),
                  padding: const EdgeInsets.all(24),
                  foregroundDecoration: focus
                      ? BoxDecoration(
                          border: Border.all(
                            color: IslandTokens.light.focus,
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignOutside + 3,
                          ),
                          borderRadius: BorderRadius.circular(23),
                        )
                      : null,
                  decoration: BoxDecoration(
                    color: hover
                        ? GalleryPalette.chartCatalogHover
                        : IslandTokens.light.paper,
                    border: Border.all(
                      width: border,
                      color: hover
                          ? GalleryPalette.chartCatalogHoverBorder
                          : GalleryPalette.rule,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      ChartLineText(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: GalleryPalette.demoStrongInk,
                        ),
                      ),
                      ChartLineText(
                        widget.desc,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.8,
                          color: GalleryPalette.chartCatalogBody,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
