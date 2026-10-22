import '../internal/light_surface_scope.dart';
import '../foundation/theme.dart';

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart' show listEquals;

import '../foundation/localizations.dart';
import '../foundation/pagination_value.dart';
import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import 'pagination.dart';

part 'table_layout.dart';

/// Typed cells are opaque; Table supplies inherited defaults, never rewrites them.
@immutable
class IslandTableColumn<T> {
  const IslandTableColumn({
    required this.id,
    required this.title,
    required this.cellBuilder,
    this.width,
    this.preferredWidth,
    this.alignment = AlignmentDirectional.centerStart,
  }) : assert(width == null || (width > 0 && width < double.infinity)),
       assert(
         preferredWidth == null ||
             (preferredWidth > 0 && preferredWidth < double.infinity),
       ),
       assert(width == null || preferredWidth == null);
  final Object id;
  final Widget title;
  final Widget Function(BuildContext context, T record, int pageIndex)
  cellBuilder;

  /// Fixed width including cell padding. Supports constraint-dependent cells.
  /// If every column is fixed, remaining space is shared proportionally.
  final double? width;

  /// Desired width including padding, shrinking to content minimum when needed.
  /// Mutually exclusive with [width]. Requires finite intrinsic cell widths.
  final double? preferredWidth;
  final AlignmentGeometry alignment;
}

/// Table is the paging owner. Its child Pagination is always controlled.
@immutable
class IslandTablePagination {
  const IslandTablePagination({
    this.value,
    this.initialValue = const IslandPaginationValue(),
    this.onChanged,
    this.showTotal = false,
    this.showSizeChanger = false,
    this.showQuickJumper = false,
    this.pageSizeOptions = const [10, 20, 50, 100],
    this.variant = IslandPaginationVariant.orange,
  });
  final IslandPaginationValue? value;
  final IslandPaginationValue initialValue;
  final ValueChanged<IslandPaginationValue>? onChanged;
  final bool showTotal, showSizeChanger, showQuickJumper;
  final List<int> pageSizeOptions;
  final IslandPaginationVariant variant;
}

class IslandTable<T> extends StatefulWidget {
  const IslandTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.rowKey,
    this.striped = true,
    this.showHeader = true,
    this.loading = false,
    this.empty,
    this.pagination,
    this.onRowPressed,
    this.minWidth = 0,
    this.maxHeight,
    this.semanticLabel,
  }) : assert(minWidth >= 0),
       assert(maxHeight == null || maxHeight > 0);
  final List<IslandTableColumn<T>> columns;
  final List<T> rows;
  final Object Function(T record) rowKey;
  final bool striped, showHeader, loading;
  final Widget? empty;
  final IslandTablePagination? pagination;
  final ValueChanged<T>? onRowPressed;
  final double minWidth;
  final double? maxHeight;
  final String? semanticLabel;
  @override
  State<IslandTable<T>> createState() => _IslandTableState<T>();
}

class _IslandTableState<T> extends State<IslandTable<T>> {
  final geometry = _ColumnGeometry();
  late IslandPaginationValue inner =
      widget.pagination?.initialValue ?? const IslandPaginationValue();
  IslandPaginationValue get value =>
      (widget.pagination?.value ?? inner).normalized(widget.rows.length);
  @override
  void didUpdateWidget(IslandTable<T> old) {
    super.didUpdateWidget(old);
    if (old.pagination == null && widget.pagination != null)
      inner = widget.pagination!.initialValue;
    if (old.pagination != null && widget.pagination != null) {
      assert(
        (old.pagination!.value == null) == (widget.pagination!.value == null),
        'Table paging ownership cannot change in place.',
      );
    }
    if (widget.pagination?.value == null)
      inner = inner.normalized(widget.rows.length);
  }

  void change(IslandPaginationValue next) {
    if (widget.loading) return;
    if (widget.pagination?.value == null) setState(() => inner = next);
    widget.pagination?.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    assert(
      widget.rows.map(widget.rowKey).toSet().length == widget.rows.length,
      'Table row keys must be unique.',
    );
    assert(
      widget.columns.map((c) => c.id).toSet().length == widget.columns.length,
      'Table column ids must be unique.',
    );
    final paging = widget.pagination;
    final data = paging == null
        ? widget.rows
        : widget.rows.sublist(
            value.startIndex(widget.rows.length),
            value.endIndex(widget.rows.length),
          );
    final strings = IslandLocalizations.of(context);
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : math.max(widget.minWidth, 600.0);
        final width = math.max(widget.minWidth, available);
        Widget cells({T? record, int index = 0, bool header = false}) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final (columnIndex, column) in widget.columns.indexed)
              _IntrinsicColumnCell(
                key: ValueKey(column.id),
                geometry: geometry,
                column: columnIndex,
                child: Semantics(
                  role: header
                      ? ui.SemanticsRole.columnHeader
                      : ui.SemanticsRole.cell,
                  container: true,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: header ? 16 : 14,
                    ),
                    child: ConstrainedBox(
                      // Match the reference line box without constraining taller
                      // opaque content. CSS layout uses 1/64 logical-pixel units.
                      constraints: BoxConstraints(
                        minHeight:
                            (MediaQuery.textScalerOf(context).scale(14) *
                                    (header ? 1.5 : 1.6) *
                                    64)
                                .floor() /
                            64,
                      ),
                      child: Align(
                        alignment: column.alignment,
                        child: ContentScope(
                          softWrap: header ? false : null,
                          textStyle: TextStyle(
                            fontSize: 14,
                            height: header ? kTextHeightNone : 1.6,
                            fontWeight: header
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: header ? .28 : 0,
                            color: const Color(0xff725d42),
                          ),
                          child: header
                              ? column.title
                              : column.cellBuilder(context, record as T, index),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
        Widget surface(Set<WidgetState> states, Widget child, int index) {
          final hover = states.contains(WidgetState.hovered);
          return Container(
            decoration: BoxDecoration(
              color: hover
                  ? const Color(0xffd6f0ea)
                  : widget.striped && index.isOdd
                  ? const Color(0x99f8f8f0)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(hover ? 30 : 0),
            ),
            // Paint focus without contributing border padding or changing the
            // wrapper topology around caller-owned cells.
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(hover ? 30 : 0),
              border: states.contains(WidgetState.focused)
                  ? Border.all(color: IslandTokens.light.focus)
                  : null,
            ),
            child: CustomPaint(
              foregroundPainter: !hover && index < data.length - 1
                  ? const _RowRule()
                  : null,
              child: child,
            ),
          );
        }

        final table = Semantics(
          role: ui.SemanticsRole.table,
          container: true,
          explicitChildNodes: true,
          label: widget.semanticLabel,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showHeader)
                Semantics(
                  role: ui.SemanticsRole.row,
                  container: true,
                  explicitChildNodes: true,
                  child: CustomPaint(
                    foregroundPainter: const _RowRule(),
                    child: cells(header: true),
                  ),
                ),
              if (data.isEmpty)
                Semantics(
                  role: ui.SemanticsRole.row,
                  container: true,
                  explicitChildNodes: true,
                  child: Semantics(
                    role: ui.SemanticsRole.cell,
                    container: true,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 60,
                        horizontal: 20,
                      ),
                      child:
                          widget.empty ??
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 16,
                            children: [
                              SvgPicture.string(
                                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="#9f927d" fill-opacity="0.5" d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V5h14v14zM7 10h2v7H7zm4-3h2v10h-2zm4 6h2v4h-2z"/></svg>',
                                width: 48,
                                height: 48,
                                excludeFromSemantics: true,
                              ),
                              Text(
                                strings.noData,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: IslandTokens.light.muted,
                                ),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              for (var i = 0; i < data.length; i++)
                Semantics(
                  key: ValueKey(widget.rowKey(data[i])),
                  role: ui.SemanticsRole.row,
                  container: true,
                  child: ActionSurface(
                    button: false,
                    isolateChildFocus: true,
                    passiveHover: true,
                    mouseCursor: widget.onRowPressed == null
                        ? MouseCursor.defer
                        : SystemMouseCursors.click,
                    onActivate: widget.onRowPressed == null
                        ? null
                        : () => widget.onRowPressed!(data[i]),
                    builder: (_, states) =>
                        surface(states, cells(record: data[i], index: i), i),
                  ),
                ),
            ],
          ),
        );
        Widget scroll = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _IntrinsicColumns(
            geometry: geometry,
            minimumWidth: width,
            fixedWidths: [for (final column in widget.columns) column.width],
            preferredWidths: [
              for (final column in widget.columns) column.preferredWidth,
            ],
            child: table,
          ),
        );
        if (widget.maxHeight != null)
          scroll = ConstrainedBox(
            constraints: BoxConstraints(maxHeight: widget.maxHeight!),
            child: SingleChildScrollView(child: scroll),
          );
        return scroll;
      },
    );
    content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        content,
        if (paging != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: IslandPagination(
                total: widget.rows.length,
                alignment: AlignmentDirectional.centerEnd,
                value: value,
                onChanged: change,
                disabled: widget.loading,
                showTotal: paging.showTotal,
                showSizeChanger: paging.showSizeChanger,
                showQuickJumper: paging.showQuickJumper,
                pageSizeOptions: paging.pageSizeOptions,
                variant: paging.variant,
              ),
            ),
          ),
      ],
    );
    return LightSurfaceScope(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          color: const Color(0xfff7f3df),
          child: Stack(
            children: [
              ExcludeFocus(
                excluding: widget.loading,
                child: IgnorePointer(
                  ignoring: widget.loading,
                  child: ExcludeSemantics(
                    excluding: widget.loading,
                    child: content,
                  ),
                ),
              ),
              if (widget.loading)
                Positioned.fill(
                  child: Semantics(
                    liveRegion: true,
                    label: strings.loading,
                    child: const ClipRect(
                      child: ColoredBox(
                        color: Color(0xfff7f3df),
                        child: Center(child: _TableSpinner()),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RowRule extends CustomPainter {
  const _RowRule();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xfff0e8d8)
      ..strokeWidth = 1;
    for (double x = 20; x < size.width - 20; x += 12) {
      canvas.drawLine(
        Offset(x, size.height - .5),
        Offset(math.min(x + 6, size.width - 20), size.height - .5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RowRule old) => false;
}

class _TableSpinner extends StatefulWidget {
  const _TableSpinner();
  @override
  State<_TableSpinner> createState() => _TableSpinnerState();
}

class _TableSpinnerState extends State<_TableSpinner>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      animation.stop();
    } else {
      animation.repeat();
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(40, 40),
    painter: _SpinnerPainter(animation),
  );
}

class _SpinnerPainter extends CustomPainter {
  _SpinnerPainter(this.animation) : super(repaint: animation);
  final Animation<double> animation;
  @override
  void paint(Canvas canvas, Size size) {
    final phase = (animation.value * 2) % 1;
    final extent = .25 + (math.sin(phase * math.pi) * 1.6);
    canvas.drawArc(
      const Rect.fromLTWH(4, 4, 32, 32),
      animation.value * 6 * math.pi - math.pi / 2,
      extent * math.pi,
      false,
      Paint()
        ..color = IslandTokens.light.link
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SpinnerPainter old) => old.animation != animation;
}
