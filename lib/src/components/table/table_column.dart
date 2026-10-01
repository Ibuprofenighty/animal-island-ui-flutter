import 'package:flutter/widgets.dart';

/// Column specification for [AnimalTable].
class AnimalTableColumn {
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

  const AnimalTableColumn({
    required this.title,
    this.width,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
  }) : assert(flex > 0, 'Column flex must be greater than 0');
}
