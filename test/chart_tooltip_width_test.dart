import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_test.dart' show chartHost, semanticTap;

void main() {
  const contentKey = ValueKey('tooltip-content');
  // Reference ChartTooltip.tsx sets an inline border-box `width` of
  // min(260, max(1, viewportWidth - 16)) with `.tooltip` padding 14px 16px.
  // Builder content wider than that widens the panel up to 400 (owner
  // decision; the reference scrolls it horizontally), both less 32 of padding
  // and never past viewport - 16.
  Future<BoxConstraints> builderConstraints(
    WidgetTester t, {
    required double width,
    double content = 400,
  }) async {
    final semantics = t.ensureSemantics();
    late BoxConstraints seen;
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.ring(
            series: const IslandChartSeries(
              name: '区域',
              data: [
                IslandChartValue(30, name: '果园'),
                IslandChartValue(70, name: '海岸'),
              ],
            ),
          ),
          tooltip: IslandChartTooltip(
            builder: (context, tip) => LayoutBuilder(
              builder: (context, constraints) {
                seen = constraints;
                return SizedBox(key: contentKey, width: content, height: 20);
              },
            ),
          ),
        ),
        width: width,
      ),
    );
    await t.pumpAndSettle();
    await semanticTap(t, '区域，海岸，70');
    await t.pumpAndSettle();
    semantics.dispose();
    return seen;
  }

  double viewportWidth(WidgetTester t) => t
      .getSize(
        find
            .descendant(
              of: find.byType(IslandChart),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is SingleChildScrollView &&
                    w.scrollDirection == Axis.horizontal,
              ),
            )
            .first,
      )
      .width;

  testWidgets('narrow builder content keeps the reference 260px panel', (
    t,
  ) async {
    final constraints = await builderConstraints(t, width: 683, content: 100);
    expect(constraints.minWidth, 260 - 32);
    expect(constraints.maxWidth, 400 - 32);
    expect(t.getSize(find.byKey(contentKey)).width, 260 - 32);
    expect(t.takeException(), isNull);
  });

  testWidgets('wide builder content widens the panel up to 400', (t) async {
    await builderConstraints(t, width: 683, content: 300);
    expect(t.getSize(find.byKey(contentKey)).width, 300);
    await builderConstraints(t, width: 683, content: 900);
    expect(t.getSize(find.byKey(contentKey)).width, 400 - 32);
    expect(t.takeException(), isNull);
  });

  testWidgets('the default tooltip content stays 260 wide', (t) async {
    final semantics = t.ensureSemantics();
    await t.pumpWidget(
      chartHost(
        IslandChart(
          data: IslandChartData.ring(
            series: const IslandChartSeries(
              name: '区域',
              data: [
                IslandChartValue(30, name: '果园'),
                IslandChartValue(70, name: '海岸'),
              ],
            ),
          ),
        ),
        width: 683,
      ),
    );
    await t.pumpAndSettle();
    await semanticTap(t, '区域，海岸，70');
    await t.pumpAndSettle();
    semantics.dispose();
    final panel = find.ancestor(
      of: find.text('海岸'),
      matching: find.byType(CustomSingleChildLayout),
    );
    final box = find.descendant(
      of: panel.first,
      matching: find.byType(DecoratedBox),
    );
    expect(t.getSize(box.first).width, 260);
  });

  testWidgets('a narrow viewport narrows the tooltip to viewport - 16', (
    t,
  ) async {
    final constraints = await builderConstraints(t, width: 240);
    final viewport = viewportWidth(t);
    expect(viewport, lessThan(260 + 16));
    expect(constraints.maxWidth, closeTo(viewport - 16 - 32, .01));
    expect(constraints.minWidth, constraints.maxWidth);
    expect(t.takeException(), isNull);
  });
}
