import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_test.dart' show chartHost, semanticTap;

void main() {
  // Reference ChartTooltip.tsx sets an inline border-box `width` of
  // min(260, max(1, viewportWidth - 16)) with `.tooltip` padding 14px 16px,
  // so builder content is laid out at that width less 32.
  Future<BoxConstraints> builderConstraints(
    WidgetTester t, {
    required double width,
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
                return const SizedBox(width: 400, height: 20);
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

  double viewportWidth(WidgetTester t) => t.getSize(
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
  ).width;

  testWidgets('builder content gets the reference 260px tooltip width', (
    t,
  ) async {
    final constraints = await builderConstraints(t, width: 683);
    expect(constraints.minWidth, 260 - 32);
    expect(constraints.maxWidth, 260 - 32);
    expect(t.takeException(), isNull);
  });

  testWidgets('a narrow viewport narrows the tooltip to viewport - 16', (
    t,
  ) async {
    final constraints = await builderConstraints(t, width: 240);
    final viewport = viewportWidth(t);
    expect(viewport, lessThan(260 + 16));
    expect(constraints.maxWidth, closeTo(viewport - 16 - 32, .01));
    expect(constraints.minWidth, constraints.maxWidth);
  });
}
