import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'explicit input sizes survive desktop density and parent text defaults',
    (t) async {
      for (final density in [VisualDensity.standard, VisualDensity.compact]) {
        for (final size in IslandSize.values) {
          await t.pumpWidget(
            MaterialApp(
              theme: IslandTheme.create().copyWith(visualDensity: density),
              home: Scaffold(
                body: DefaultTextStyle(
                  style: const TextStyle(fontSize: 32, height: 3),
                  child: SizedBox(
                    width: 300,
                    child: IslandTextField(
                      label: 'Field',
                      showLabel: false,
                      size: size,
                    ),
                  ),
                ),
              ),
            ),
          );
          final expected = switch (size) {
            IslandSize.small => 32.0,
            IslandSize.middle => 40.0,
            IslandSize.large => 48.0,
          };
          expect(
            t.getSize(find.byType(TextField)).height,
            closeTo(expected, .1),
            reason: '$size $density',
          );
        }
      }
    },
  );
}
