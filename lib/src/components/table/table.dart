import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../loading/loading.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'table_column.dart';
import 'table_layout.dart';
import 'table_row.dart';

export 'table_column.dart';
export 'table_layout.dart';
export 'table_row.dart';

/// Signature for building cells in an [AnimalTable] row at a given [index].
typedef AnimalTableRowBuilder = List<Widget> Function(
  BuildContext context,
  int index,
);

/// Signature for generating a stable [Key] for an [AnimalTable] row at a given [index].
typedef AnimalTableRowKey = Key Function(int index);

/// Enterprise-grade, lazy virtualized Animal Island rounded Table component.
///
/// Features:
/// - Single lazy row contract: [rowCount] + [rowBuilder] + [rowKey]
/// - Virtualized scrolling via [ListView.builder] with pinned sticky header
/// - Solves Fixed, Flex, and Mixed column layout geometry with synchronized X coordinates
/// - Horizontal scrolling when content exceeds container width or columns have fixed widths
/// - Alternating themed zebra rows (`theme.colors.surfaceAlt` / `theme.colors.bgContent`)
/// - Zero [RenderFlex] overflow on large datasets (10,000+ rows)
/// - Built-in [loading] state with cozy leaf spinner overlay
/// - Built-in [emptyWidget] state with kawaii empty island graphic
class AnimalTable extends StatelessWidget {
  /// Columns configuration for the table.
  final List<AnimalTableColumn> columns;

  /// Total number of rows in the table.
  final int rowCount;

  /// Lazy builder producing cell widgets for row at [index].
  final AnimalTableRowBuilder rowBuilder;

  /// Optional function to generate a stable [Key] for each row.
  final AnimalTableRowKey? rowKey;

  /// Whether the table is currently displaying a loading spinner overlay.
  final bool loading;

  /// Custom widget displayed when [rowCount] is 0 and [loading] is false.
  final Widget? emptyWidget;

  /// Minimum total table width in logical pixels.
  final double? minWidth;

  /// Maximum height constraint for the table.
  ///
  /// Required if the table is placed inside an unbounded vertical parent.
  final double? maxHeight;

  /// Optional scroll controller for horizontal scrolling.
  final ScrollController? horizontalScrollController;

  /// Optional scroll controller for vertical row scrolling.
  final ScrollController? verticalScrollController;

  const AnimalTable({
    super.key,
    required this.columns,
    required this.rowCount,
    required this.rowBuilder,
    this.rowKey,
    this.loading = false,
    this.emptyWidget,
    this.minWidth,
    this.maxHeight,
    this.horizontalScrollController,
    this.verticalScrollController,
  }) : assert(columns.length > 0, 'AnimalTable requires at least one column'),
       assert(rowCount >= 0, 'rowCount must not be negative');

  Widget _buildEmptyState(
    AnimalIslandTheme theme,
    AnimalLocalizations localizations,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: theme.spacing.xxl + theme.spacing.xs,
        horizontal: theme.spacing.lg,
      ),
      alignment: Alignment.center,
      child:
          emptyWidget ??
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimalIcon(
                data: AnimalIcons.tree,
                size: 40,
                color: theme.colors.textDisabled,
              ),
              SizedBox(height: theme.spacing.sm),
              Text(
                localizations.empty,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.textDisabled,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AnimalLocalizations.of(context)!;
    final theme = AnimalIslandTheme.of(context);
    final headerBg = theme.colors.surfaceHeader;
    final rowBgEven = theme.colors.surfaceAlt;
    final rowBgOdd = theme.colors.bgContent;
    final borderColor = theme.colors.border;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedHeight && maxHeight == null) {
          throw FlutterError(
            'AnimalTable was placed in an unbounded vertical viewport without a specified maxHeight. '
            'Please provide maxHeight or constrain the parent height.',
          );
        }

        final availableWidth = constraints.maxWidth;
        final insideWidth = availableWidth.isFinite
            ? math.max(
                0.0,
                availableWidth - AnimalTableLayout.horizontalTableBorder,
              )
            : double.infinity;
        final solvedWidths = AnimalTableLayout.solveWidths(
          columns: columns,
          availableWidth: availableWidth,
          horizontalRowPadding: theme.spacing.lg * 2,
        );

        final totalColumnsWidth = AnimalTableLayout.totalContentWidth(
          solvedWidths,
          horizontalRowPadding: theme.spacing.lg * 2,
        );
        final effectiveTableWidth = math.max(
          minWidth ?? 0.0,
          totalColumnsWidth,
        );
        final requiresHorizontalScroll =
            !insideWidth.isFinite || effectiveTableWidth > insideWidth;

        // Header Row
        final headerRow = AnimalTableRow(
          columns: columns,
          columnWidths: solvedWidths,
          cells: columns.map((c) => Text(c.title)).toList(),
          isHeader: true,
          backgroundColor: headerBg,
        );

        // Body Content
        Widget bodyContent;
        if (rowCount == 0 && !loading) {
          bodyContent = _buildEmptyState(theme, localizations);
        } else {
          bodyContent = ListView.builder(
            controller: verticalScrollController,
            padding: EdgeInsets.zero,
            itemCount: rowCount,
            itemBuilder: (context, rowIndex) {
              final cells = rowBuilder(context, rowIndex);
              final isEven = rowIndex % 2 == 0;
              return AnimalTableRow(
                key: rowKey?.call(rowIndex) ?? ValueKey(rowIndex),
                columns: columns,
                columnWidths: solvedWidths,
                cells: cells,
                isEven: isEven,
                backgroundColor: isEven ? rowBgEven : rowBgOdd,
                borderColor: borderColor.withValues(alpha: 0.4),
              );
            },
          );
        }

        final double? resolvedHeight =
            maxHeight ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : null);

        Widget tableStructure;
        if (resolvedHeight != null) {
          tableStructure = SizedBox(
            height: resolvedHeight,
            width: effectiveTableWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerRow,
                Expanded(child: bodyContent),
              ],
            ),
          );
        } else {
          tableStructure = SizedBox(
            width: effectiveTableWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [headerRow, bodyContent],
            ),
          );
        }

        Widget scrollableContent;
        if (requiresHorizontalScroll) {
          scrollableContent = SingleChildScrollView(
            controller: horizontalScrollController,
            scrollDirection: Axis.horizontal,
            child: tableStructure,
          );
        } else {
          scrollableContent = tableStructure;
        }

        return Container(
          decoration: BoxDecoration(
            color: theme.colors.bgContent,
            borderRadius: theme.radii.cardBorder,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.center,
            children: [
              scrollableContent,
              if (loading)
                Positioned.fill(
                  child: Semantics(
                    container: true,
                    excludeSemantics: true,
                    label: localizations.tableLoadingLabel,
                    child: Container(
                      color: theme.colors.bgContent.withValues(alpha: 0.7),
                      child: const Center(
                        child: AnimalLoading.spinner(size: 36.0),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
