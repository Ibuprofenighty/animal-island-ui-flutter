import 'package:flutter/widgets.dart';
import '../../tokens/radii.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../feedback/loading.dart';
import '../../icons/icon_widget.dart';

/// Column specification for [AnimalTable].
class AnimalTableColumn {
  final String title;
  final double? width;
  final Alignment alignment;

  const AnimalTableColumn({
    required this.title,
    this.width,
    this.alignment = Alignment.centerLeft,
  });
}

/// Enterprise-grade Animal Island rounded Table component.
///
/// Features:
/// - Soft 20px rounded outer border ([AnimalRadii.cardBorder])
/// - Alternating warm parchment zebra rows without container assertion errors
/// - High-performance rendering: eliminates expensive double-pass IntrinsicWidth measurement
/// - Optional [maxHeight] virtualized row viewport via [ListView.builder] with pinned sticky header
/// - Horizontal scrolling when content exceeds container width or columns have fixed widths
/// - Built-in [loading] state with cozy leaf spinner overlay
/// - Built-in [emptyWidget] state with kawaii empty island graphic
class AnimalTable extends StatelessWidget {
  final List<AnimalTableColumn> columns;
  final List<List<Widget>> rows;
  final bool loading;
  final Widget? emptyWidget;
  final double? minWidth;
  final double? maxHeight;

  const AnimalTable({
    super.key,
    required this.columns,
    required this.rows,
    this.loading = false,
    this.emptyWidget,
    this.minWidth,
    this.maxHeight,
  });

  Widget _buildHeader(AnimalIslandTheme theme, Color headerBg) {
    return Container(
      decoration: BoxDecoration(
        color: headerBg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: columns.map((col) {
          Widget cell = Container(
            alignment: col.alignment,
            child: Semantics(
              header: true,
              child: Text(
                col.title,
                style: AnimalTypography.heading.copyWith(
                  fontSize: 15.0,
                  color: theme.text,
                ),
              ),
            ),
          );
          return col.width != null ? SizedBox(width: col.width, child: cell) : Expanded(child: cell);
        }).toList(),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    int rowIndex,
    AnimalIslandTheme theme,
    Color rowBgEven,
    Color rowBgOdd,
    Color borderColor,
  ) {
    final row = rows[rowIndex];
    final isEven = rowIndex % 2 == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: isEven ? rowBgEven : rowBgOdd,
        border: Border(
          top: BorderSide(
            color: borderColor.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
      ),
      child: DefaultTextStyle(
        style: AnimalTypography.body.copyWith(color: theme.textBody),
        child: Row(
          children: List.generate(columns.length, (colIndex) {
            final col = columns[colIndex];
            final cellWidget = colIndex < row.length ? row[colIndex] : const SizedBox.shrink();
            Widget cell = Container(alignment: col.alignment, child: cellWidget);
            return col.width != null ? SizedBox(width: col.width, child: cell) : Expanded(child: cell);
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final headerBg = theme.surfaceHeader;
    final rowBgEven = theme.surfaceAlt;
    final rowBgOdd = theme.bgContent;
    final borderColor = theme.border;

    Widget bodyContent;
    if (rows.isEmpty && !loading) {
      bodyContent = Container(
        padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
        alignment: Alignment.center,
        child: emptyWidget ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TreeIcon(size: 40, color: theme.textDisabled),
                const SizedBox(height: 8.0),
                Text(
                  'No island data found',
                  style: AnimalTypography.caption.copyWith(
                    color: theme.textDisabled,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
      );
    } else if (maxHeight != null) {
      bodyContent = ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight!),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: rows.length,
          itemBuilder: (context, rowIndex) => _buildRow(
            context,
            rowIndex,
            theme,
            rowBgEven,
            rowBgOdd,
            borderColor,
          ),
        ),
      );
    } else {
      bodyContent = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(
          rows.length,
          (rowIndex) => _buildRow(
            context,
            rowIndex,
            theme,
            rowBgEven,
            rowBgOdd,
            borderColor,
          ),
        ),
      );
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(theme, headerBg),
        maxHeight != null ? Flexible(child: bodyContent) : bodyContent,
      ],
    );

    final hasFixedWidth = columns.any((c) => c.width != null);
    double? calculatedWidth = minWidth;
    if (calculatedWidth == null && hasFixedWidth) {
      double total = 0.0;
      for (final c in columns) {
        total += (c.width ?? 120.0);
      }
      calculatedWidth = total;
    }

    if (calculatedWidth != null) {
      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: calculatedWidth,
          child: content,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.bgContent,
        borderRadius: AnimalRadii.cardBorder,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          content,
          if (loading)
            Positioned.fill(
              child: Semantics(
                label: '数据加载中',
                child: Container(
                  color: theme.bgContent.withValues(alpha: 0.7),
                  child: const Center(
                    child: AnimalLoading.spinner(size: 36.0),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
