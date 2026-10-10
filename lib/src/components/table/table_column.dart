import 'package:flutter/widgets.dart';

/// Column specification for [AnimalTable].
final class AnimalTableColumn {
  /// Column title text displayed in the sticky header.
  final String title;

  /// Optional fixed column width in logical pixels.
  ///
  /// If null, the column will expand flexibly based on [flex].
  final double? width;

  /// Flex weight for columns with null [width]. Default is 1.
  final int flex;

  /// Content alignment for both header and data cells in this column.
  final Alignment alignment;

  /// Creates a column specification; [flex] must be greater than 0.
  AnimalTableColumn({
    required this.title,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  }) {
    if (flex <= 0) throw ArgumentError.value(flex, 'flex', 'must be positive');
    if (width != null && (!width!.isFinite || width! <= 0)) {
      throw ArgumentError.value(width, 'width', 'must be finite and positive');
    }
    if (!alignment.x.isFinite || !alignment.y.isFinite) {
      throw ArgumentError.value(alignment, 'alignment', 'must be finite');
    }
  }
}
