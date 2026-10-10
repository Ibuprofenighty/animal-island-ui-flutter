import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/table_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/horizontal_scroll_region.dart';
import '../loading/loading.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'table_column.dart';
import 'table_layout.dart';
import 'table_row.dart';

/// Builds exactly one cell per column for a lazily requested row.
typedef AnimalTableRowBuilder = List<Widget> Function(
  BuildContext context,
  int index,
);

/// Supplies a stable unique row identity, independent of row order.
typedef AnimalTableRowKey = Key Function(int index);

/// A single lazy indexed table with a sticky header and shared column geometry.
/// Row keys are snapshotted without building cells. Reordering preserves cell
/// state by key; rows grow to fit content, including 200% text. Supply bounded
/// width and height, or minWidth/maxHeight in an unbounded parent.
class AnimalTable extends StatelessWidget {
  /// Immutable snapshot of a nonempty column schema.
  final List<AnimalTableColumn> columns;

  /// Nonnegative number of rows.
  final int rowCount;

  /// Only invoked for rows needed by the viewport and cache.
  final AnimalTableRowBuilder rowBuilder;

  /// Required unique identities; evaluated once per row at construction.
  final AnimalTableRowKey rowKey;

  /// Whether to overlay a localized loading indicator.
  final bool loading;

  /// Caller-owned empty content; null uses the localized empty state.
  final Widget? emptyWidget;

  /// Positive finite minimum outer table width, if supplied.
  final double? minWidth;

  /// Positive finite viewport height limit, if supplied.
  final double? maxHeight;

  /// Finite nonnegative viewport cache extent, default 96 logical pixels.
  final double cacheExtent;

  /// Borrowed horizontal scroll controller; never disposed by the table.
  final ScrollController? horizontalScrollController;

  /// Borrowed vertical scroll controller; never disposed by the table.
  final ScrollController? verticalScrollController;

  /// Instance overrides before component theme and tokens.
  final AnimalTableStyle? style;
  late final List<Key> _keys;
  late final Map<Key, int> _indices;

  /// Creates a table. Invalid schema, dimensions or duplicate row keys throw
  /// ArgumentError; lazy rows with missing or extra cells throw ArgumentError
  /// when requested. Validation is identical in debug and release.
  AnimalTable({
    super.key,
    required List<AnimalTableColumn> columns,
    required this.rowCount,
    required this.rowBuilder,
    required this.rowKey,
    this.loading = false,
    this.emptyWidget,
    this.minWidth,
    this.maxHeight,
    this.cacheExtent = 96,
    this.horizontalScrollController,
    this.verticalScrollController,
    this.style,
  }) : columns = List.unmodifiable(columns) {
    if (this.columns.isEmpty) {
      throw ArgumentError.value(columns, 'columns', 'must be nonempty');
    }
    if (rowCount < 0) {
      throw ArgumentError.value(rowCount, 'rowCount', 'must be nonnegative');
    }
    for (final entry in {
      'minWidth': minWidth,
      'maxHeight': maxHeight,
    }.entries) {
      final value = entry.value;
      if (value != null && (!value.isFinite || value <= 0)) {
        throw ArgumentError.value(
          value,
          entry.key,
          'must be finite and positive',
        );
      }
    }
    if (!cacheExtent.isFinite || cacheExtent < 0) {
      throw ArgumentError.value(
        cacheExtent,
        'cacheExtent',
        'must be finite and nonnegative',
      );
    }
    final indices = <Key, int>{};
    final keys = <Key>[];
    for (var i = 0; i < rowCount; i++) {
      final key = rowKey(i);
      if (indices.containsKey(key)) {
        throw ArgumentError.value(key, 'rowKey', 'must be unique');
      }
      keys.add(key);
      indices[key] = i;
    }
    _keys = List.unmodifiable(keys);
    _indices = Map.unmodifiable(indices);
  }

  @override
  Widget build(BuildContext context) {
    final copy = AnimalLocalizations.of(context)!;
    final resolved = _resolveTableStyle(AnimalIslandTheme.of(context), style);
    final borderColor = resolved.borderColor!;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight && maxHeight == null) {
          throw ArgumentError('AnimalTable needs bounded height or maxHeight');
        }
        if (!constraints.hasBoundedWidth && minWidth == null) {
          throw ArgumentError('AnimalTable needs bounded width or minWidth');
        }
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : minWidth!;
        final geometryWidth = math.max(width, minWidth ?? 0);
        final padding = resolved.rowPadding!.resolve(
          Directionality.of(context),
        );
        final solvedWidths = AnimalTableLayout.solveWidths(
          columns: columns,
          availableWidth: geometryWidth,
          horizontalRowPadding: padding.horizontal,
          flexMinWidth: resolved.flexMinWidth!,
          horizontalTableBorder: resolved.borderWidth! * 2,
        );
        final contentWidth = math.max(
          geometryWidth - resolved.borderWidth! * 2,
          AnimalTableLayout.totalContentWidth(
            solvedWidths,
            horizontalRowPadding: padding.horizontal,
          ),
        );
        final height = constraints.hasBoundedHeight
            ? math.min(
                maxHeight ?? constraints.maxHeight,
                constraints.maxHeight,
              )
            : maxHeight!;
        final headerRow = AnimalTableRow(
          columns: columns,
          columnWidths: solvedWidths,
          cells: [for (final column in columns) Text(column.title)],
          isHeader: true,
          backgroundColor: resolved.headerBackgroundColor!,
          style: resolved,
        );
        Widget bodyContent;
        if (rowCount == 0 && !loading) {
          bodyContent = SingleChildScrollView(
            child: Container(
              padding: resolved.emptyPadding,
              alignment: Alignment.center,
              child:
                  emptyWidget ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimalIcon(
                        data: AnimalIcons.tree,
                        size: resolved.emptyIconSize!,
                        color: resolved.emptyTextColor,
                      ),
                      SizedBox(height: resolved.emptyIconGap),
                      Text(
                        copy.empty,
                        style: resolved.emptyTextStyle!.copyWith(
                          color: resolved.emptyTextColor,
                        ),
                      ),
                    ],
                  ),
            ),
          );
        } else {
          bodyContent = ListView.builder(
            controller: verticalScrollController,
            padding: EdgeInsets.zero,
            scrollCacheExtent: ScrollCacheExtent.pixels(cacheExtent),
            findChildIndexCallback: (key) => _indices[key],
            itemCount: rowCount,
            itemBuilder: (context, rowIndex) {
              final cells = List<Widget>.unmodifiable(
                rowBuilder(context, rowIndex),
              );
              if (cells.length != columns.length) {
                throw ArgumentError.value(
                  cells.length,
                  'rowBuilder',
                  'must return exactly ${columns.length} cells',
                );
              }
              return AnimalTableRow(
                key: _keys[rowIndex],
                columns: columns,
                columnWidths: solvedWidths,
                cells: cells,
                style: resolved,
                backgroundColor: rowIndex.isEven
                    ? resolved.evenRowBackgroundColor!
                    : resolved.oddRowBackgroundColor!,
                borderColor: resolved.dividerColor,
              );
            },
          );
        }
        final structure = SizedBox(
          height: math.max(0, height - resolved.borderWidth! * 2),
          width: contentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              headerRow,
              Expanded(child: bodyContent),
            ],
          ),
        );
        final horizontal = contentWidth > width - resolved.borderWidth! * 2;
        Widget surface(ScrollController? controller) => Container(
          decoration: BoxDecoration(
            color: resolved.backgroundColor,
            borderRadius: resolved.borderRadius,
            border: Border.all(
              color: borderColor,
              width: resolved.borderWidth!,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              horizontal
                  ? SingleChildScrollView(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      child: structure,
                    )
                  : structure,
              if (loading)
                Positioned.fill(
                  child: Semantics(
                    container: true,
                    excludeSemantics: true,
                    label: copy.tableLoadingLabel,
                    child: Container(
                      color: resolved.backgroundColor!.withValues(alpha: .7),
                      child: Center(
                        child: AnimalLoading.spinner(
                          size: resolved.loadingSize!,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
        return horizontal
            ? HorizontalScrollRegion(
                controller: horizontalScrollController,
                borderRadius: resolved.borderRadius!,
                builder: surface,
              )
            : surface(null);
      },
    );
  }
}

AnimalTableStyle _resolveTableStyle(
  AnimalIslandTheme theme,
  AnimalTableStyle? instance,
) => (instance ?? AnimalTableStyle())
    .merge(theme.components.table)
    .merge(
      AnimalTableStyle(
        backgroundColor: theme.colors.bgContent,
        headerBackgroundColor: theme.colors.surfaceHeader,
        evenRowBackgroundColor: theme.colors.surfaceAlt,
        oddRowBackgroundColor: theme.colors.bgContent,
        borderColor: theme.colors.border,
        borderWidth: 1.5,
        borderRadius: theme.radii.cardBorder,
        dividerColor: theme.colors.border.withValues(alpha: .4),
        dividerThickness: 1,
        rowPadding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.md,
        ),
        minRowHeight: 48,
        flexMinWidth: 120,
        headerTextStyle: theme.typography.button,
        textStyle: theme.typography.body,
        headerTextColor: theme.colors.text,
        textColor: theme.colors.textBody,
        emptyTextStyle: theme.typography.caption,
        emptyTextColor: theme.colors.textDisabled,
        emptyPadding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.xxl + theme.spacing.xs,
        ),
        emptyIconSize: 40,
        emptyIconGap: theme.spacing.sm,
        loadingSize: 36,
      ),
    );
