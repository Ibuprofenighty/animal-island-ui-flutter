import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';
import 'table_column.dart';

/// Renders a single row (header or body) for [AnimalTable].
///
/// Ensures exact matching column geometry and alignment between header and body.
class AnimalTableRow extends StatelessWidget {
  /// Columns that supply each cell's alignment.
  final List<AnimalTableColumn> columns;

  /// Resolved width of each column, one entry per column.
  final List<double> columnWidths;

  /// Cell content in column order; a missing cell renders empty.
  final List<Widget> cells;

  /// Whether the row is the header, which uses heading text and header
  /// semantics. Defaults to false.
  final bool isHeader;

  /// Fill of the row.
  final Color backgroundColor;

  /// Color of the 1 logical-pixel top border; null draws no border.
  final Color? borderColor;

  /// Creates a row; [columns] and [columnWidths] must have equal lengths.
  const AnimalTableRow({
    super.key,
    required this.columns,
    required this.columnWidths,
    required this.cells,
    this.isHeader = false,
    required this.backgroundColor,
    this.borderColor,
  }) : assert(columns.length == columnWidths.length);

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor != null
            ? Border(top: BorderSide(color: borderColor!, width: 1.0))
            : null,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.lg,
        vertical: theme.spacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(columns.length, (colIndex) {
          final col = columns[colIndex];
          final colWidth = columnWidths[colIndex];
          final cellWidget = colIndex < cells.length
              ? cells[colIndex]
              : const SizedBox.shrink();

          final Widget cellContent;
          if (isHeader) {
            cellContent = Semantics(
              header: true,
              child: DefaultTextStyle(
                style: theme.typography.heading.copyWith(
                  fontSize: theme.typography.button.fontSize,
                  color: theme.colors.text,
                ),
                child: cellWidget,
              ),
            );
          } else {
            cellContent = DefaultTextStyle(
              style: theme.typography.body.copyWith(
                color: theme.colors.textBody,
              ),
              child: cellWidget,
            );
          }

          return SizedBox(
            width: colWidth,
            child: Align(alignment: col.alignment, child: cellContent),
          );
        }),
      ),
    );
  }
}
