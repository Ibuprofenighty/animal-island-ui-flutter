import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final rich in [false, true]) {
    testWidgets(
      'Typewriter line metrics scale without replacing rich content: $rich',
      (t) async {
        for (final scale in [1.0, 2.0]) {
          final writer = rich
              ? const IslandTypewriter.rich(
                  TextSpan(
                    text: 'a\nb',
                    style: TextStyle(color: Colors.red),
                  ),
                  play: false,
                  style: TextStyle(fontSize: 14),
                  strutStyle: StrutStyle(
                    fontSize: 14,
                    height: 1.5,
                    forceStrutHeight: true,
                  ),
                )
              : const IslandTypewriter(
                  'a\nb',
                  play: false,
                  style: TextStyle(fontSize: 14),
                  strutStyle: StrutStyle(
                    fontSize: 14,
                    height: 1.5,
                    forceStrutHeight: true,
                  ),
                );
          await t.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Center(child: writer),
              ),
            ),
          );
          expect(t.getSize(find.byType(IslandTypewriter)).height, 42 * scale);
          if (rich) {
            final text = t.widget<Text>(
              find.descendant(
                of: find.byType(IslandTypewriter),
                matching: find.byType(Text),
              ),
            );
            expect(text.textSpan!.style!.color, Colors.red);
            expect(text.textSpan!.toPlainText(), 'a\nb');
          }
        }
      },
    );
  }
}
