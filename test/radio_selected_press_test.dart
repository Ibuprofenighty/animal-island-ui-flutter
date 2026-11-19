import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // A native radio takes focus when its already selected option is pressed,
  // so the arrow keys then move the selection.
  testWidgets('pressing the selected radio focuses it for arrow keys', (
    t,
  ) async {
    var value = 'a';
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => IslandRadioGroup<String>(
              options: const [
                IslandOption(value: 'a', label: '春天'),
                IslandOption(value: 'b', label: '夏天'),
              ],
              value: value,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('春天'));
    await t.pumpAndSettle();
    expect(value, 'a');
    await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await t.pumpAndSettle();
    expect(value, 'b');
    expect(t.takeException(), isNull);
  });
}
