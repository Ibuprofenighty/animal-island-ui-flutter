import 'package:flutter/widgets.dart';

import '../../foundation/theme/components/table_theme.dart';
import 'table_column.dart';

/// Internal row renderer sharing the owner's resolved column geometry.
class AnimalTableRow extends StatelessWidget {
  /// Immutable validated columns.
  final List<AnimalTableColumn> columns;

  /// Resolved width of each cell, identical for header and body.
  final List<double> columnWidths;

  /// Validated cells, exactly one per column.
  final List<Widget> cells;

  /// Whether cells announce header semantics.
  final bool isHeader;

  /// Resolved row fill.
  final Color backgroundColor;

  /// Optional resolved row separator.
  final Color? borderColor;

  /// Resolved style from the table owner's sole resolver.
  final AnimalTableStyle style;

  /// Creates a row after the table boundary has validated its schema.
  const AnimalTableRow({
    super.key,
    required this.columns,
    required this.columnWidths,
    required this.cells,
    this.isHeader = false,
    required this.backgroundColor,
    this.borderColor,
    required this.style,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Container(
      constraints: BoxConstraints(minHeight: style.minRowHeight!),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: borderColor == null
            ? null
            : Border(
                top: BorderSide(
                  color: borderColor!,
                  width: style.dividerThickness!,
                ),
              ),
      ),
      padding: style.rowPadding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < columns.length; i++)
            SizedBox(
              width: columnWidths[i],
              child: Align(
                alignment: columns[i].alignment,
                child: Semantics(
                  header: isHeader,
                  child: DefaultTextStyle(
                    style: (isHeader ? style.headerTextStyle : style.textStyle)!
                        .copyWith(
                          color: isHeader
                              ? style.headerTextColor
                              : style.textColor,
                        ),
                    child: cells[i],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
