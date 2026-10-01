import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';
import 'table_column.dart';

/// Renders a single row (header or body) for [AnimalTable].
///
/// Ensures exact matching column geometry and alignment between header and body.
class AnimalTableRow extends StatelessWidget {
  final List<AnimalTableColumn> columns;
  final List<double> columnWidths;
  final List<Widget> cells;
  final bool isHeader;
  final bool isEven;
  final Color backgroundColor;
  final Color? borderColor;

  const AnimalTableRow({
    super.key,
    required this.columns,
    required this.columnWidths,
    required this.cells,
    this.isHeader = false,
    this.isEven = false,
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
