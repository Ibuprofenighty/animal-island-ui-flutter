import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const options = [
  IslandOption(value: 1, label: 'One'),
  IslandOption(value: 2, label: 'Two'),
];
void main() {
  for (final radio in [false, true]) {
    for (final vertical in [false, true]) {
      testWidgets(
        'Choice spacing preserves option geometry and activation: radio=$radio vertical=$vertical',
        (t) async {
          final semantics = t.ensureSemantics();
          final requests = <Object>[];
          try {
            await t.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: radio
                        ? IslandRadioGroup<int>(
                            options: options,
                            value: 1,
                            onChanged: requests.add,
                            vertical: vertical,
                            spacing: 27,
                          )
                        : IslandCheckboxGroup<int>(
                            options: options,
                            values: const {1},
                            onChanged: requests.add,
                            vertical: vertical,
                            spacing: 27,
                          ),
                  ),
                ),
              ),
            );
            final first = t.getRect(find.bySemanticsLabel('One'));
            final second = t.getRect(find.bySemanticsLabel('Two'));
            expect(
              vertical ? second.top - first.bottom : second.left - first.right,
              closeTo(27, .001),
            );
            await t.tap(find.bySemanticsLabel('Two'));
            await t.pump();
            expect(requests, hasLength(1));
            expect(t.takeException(), isNull);
            await t.pumpWidget(const SizedBox.shrink());
          } finally {
            semantics.dispose();
          }
        },
      );
    }
  }
  test('Choice spacing rejects nonfinite and negative layout input', () {
    for (final spacing in [-1.0, double.nan, double.infinity]) {
      expect(
        () => IslandRadioGroup<int>(
          options: options,
          value: 1,
          onChanged: (_) {},
          spacing: spacing,
        ),
        throwsArgumentError,
      );
      expect(
        () => IslandCheckboxGroup<int>(
          options: options,
          values: const {1},
          onChanged: (_) {},
          spacing: spacing,
        ),
        throwsArgumentError,
      );
    }
  });
}
