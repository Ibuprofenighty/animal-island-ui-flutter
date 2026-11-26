import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_test.dart' show chartHost;

void main() {
  // Reference `.data table { width: 100% }` with automatic table layout: the
  // table fills the chart content and every column is at least as wide as
  // its widest cell, so no cell wraps; a wider table scrolls in
  // `.tableScroll`.
  const series = '本周到访的岛民与临时访客';
  Future<void> open(WidgetTester t, double width) async {
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.column(
            categories: const ['苹果', '香梨'],
            series: [
              IslandChartSeries.values(series, const [64, 85]),
            ],
          ),
        ),
        width: width,
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('查看数据（2）'));
    await t.pumpAndSettle();
  }

  Finder cell(String text) =>
      find.descendant(of: find.byType(Table), matching: find.text(text));
  Finder scroller() => find.ancestor(
    of: find.byType(Table),
    matching: find.byType(SingleChildScrollView),
  );

  testWidgets('the data table fills the chart content and keeps each cell on '
      'one line', (t) async {
    await open(t, 620);
    final table = t.getRect(find.byType(Table));
    final viewport = t.getRect(scroller().first);
    expect(table.width, moreOrLessEquals(viewport.width, epsilon: 0.01));
    final line = t.getSize(cell('系列')).height;
    for (final text in ['数值', '64', '85', '苹果', series]) {
      expect(t.getSize(cell(text).first).height, line, reason: text);
    }
    // Spare width is shared by every column, not given to one of them.
    final seriesLeft = t.getTopLeft(cell(series).first).dx;
    final nameLeft = t.getTopLeft(cell('苹果')).dx;
    final valueLeft = t.getTopLeft(cell('64')).dx;
    final columns = [
      nameLeft - seriesLeft,
      valueLeft - nameLeft,
      table.right - valueLeft + 12,
    ];
    // The two-glyph columns need 48px (12px test glyphs plus 24 padding)
    // and the series column 12 glyphs plus 24.
    expect(columns[0], greaterThan(series.length * 12 + 24));
    expect(columns[1], greaterThan(48));
    expect(columns[2], greaterThan(48));
    expect(columns[1], moreOrLessEquals(columns[2], epsilon: 0.01));
    expect(
      columns[0] / columns[1],
      moreOrLessEquals((series.length * 12 + 24) / 48, epsilon: 0.05),
    );
    expect(t.takeException(), isNull);
  });

  testWidgets('a table wider than the chart content scrolls and does not '
      'wrap', (t) async {
    await open(t, 260);
    final table = t.getRect(find.byType(Table));
    final viewport = t.getRect(scroller().first);
    expect(table.width, greaterThan(viewport.width));
    final line = t.getSize(cell('系列')).height;
    for (final text in ['数值', '64', series]) {
      expect(t.getSize(cell(text).first).height, line, reason: text);
    }
    expect(t.takeException(), isNull);
  });
}
