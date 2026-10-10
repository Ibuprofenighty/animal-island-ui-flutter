import 'table_column.dart';

/// Layout solver and metrics calculation for [AnimalTable].
class AnimalTableLayout {
  /// Computes the exact rendered widths for all columns based on available container width.
  ///
  /// Guarantees that:
  /// 1. Fixed width columns always receive exactly their defined [AnimalTableColumn.width].
  /// 2. Flex columns share remaining available space proportionally according to their [AnimalTableColumn.flex].
  /// 3. Constrained flex columns receive at least flexMinWidth * flex.
  static List<double> solveWidths({
    required List<AnimalTableColumn> columns,
    required double availableWidth,
    required double horizontalRowPadding,
    required double flexMinWidth,
    required double horizontalTableBorder,
  }) {
    final n = columns.length;
    final widths = List<double>.filled(n, 0.0);

    double fixedTotal = 0.0;
    int totalFlex = 0;

    for (int i = 0; i < n; i++) {
      final col = columns[i];
      if (col.width != null) {
        widths[i] = col.width!;
        fixedTotal += col.width!;
      } else {
        totalFlex += col.flex;
      }
    }

    final insideWidth = availableWidth - horizontalTableBorder;

    final netAvailable = insideWidth - horizontalRowPadding - fixedTotal;

    if (totalFlex > 0) {
      final minRequiredFlexWidth = totalFlex * flexMinWidth;
      if (netAvailable >= minRequiredFlexWidth) {
        // Distribute net remaining space proportionally
        for (int i = 0; i < n; i++) {
          final col = columns[i];
          if (col.width == null) {
            widths[i] = (netAvailable * col.flex) / totalFlex;
          }
        }
      } else {
        // Constrained: assign minimum flex widths.
        for (int i = 0; i < n; i++) {
          final col = columns[i];
          if (col.width == null) {
            widths[i] = flexMinWidth * col.flex;
          }
        }
      }
    }

    return widths;
  }

  /// Calculates total content width of all columns including row padding.
  static double totalContentWidth(
    List<double> columnWidths, {
    required double horizontalRowPadding,
  }) {
    double total = horizontalRowPadding;
    for (final w in columnWidths) {
      total += w;
    }
    return total;
  }
}
