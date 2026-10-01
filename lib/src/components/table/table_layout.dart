import 'table_column.dart';

/// Layout solver and metrics calculation for [AnimalTable].
class AnimalTableLayout {
  /// Total width consumed by the container's outer borders (1.5 on each side = 3.0).
  static const double horizontalTableBorder = 3.0;

  /// Default minimum width allocated to a flex column when space is constrained.
  static const double defaultFlexMinWidth = 120.0;

  /// Computes the exact rendered widths for all columns based on available container width.
  ///
  /// Guarantees that:
  /// 1. Fixed width columns always receive exactly their defined [AnimalTableColumn.width].
  /// 2. Flex columns share remaining available space proportionally according to their [AnimalTableColumn.flex].
  /// 3. If available space is constrained or infinite, flex columns receive at least [defaultFlexMinWidth] * flex.
  static List<double> solveWidths({
    required List<AnimalTableColumn> columns,
    required double availableWidth,
    required double horizontalRowPadding,
    double flexMinWidth = defaultFlexMinWidth,
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

    final insideWidth = availableWidth.isFinite
        ? (availableWidth - horizontalTableBorder)
        : 0.0;

    final netAvailable = insideWidth.isFinite
        ? (insideWidth - horizontalRowPadding - fixedTotal)
        : 0.0;

    if (totalFlex > 0) {
      final minRequiredFlexWidth = totalFlex * flexMinWidth;
      if (insideWidth.isFinite && netAvailable >= minRequiredFlexWidth) {
        // Distribute net remaining space proportionally
        for (int i = 0; i < n; i++) {
          final col = columns[i];
          if (col.width == null) {
            widths[i] = (netAvailable * col.flex) / totalFlex;
          }
        }
      } else {
        // Constrained or unbounded: assign minimum reasonable flex widths
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
