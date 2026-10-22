import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Single-line hint keeps its field height with narrow opaque adornments',
    (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 210,
                child: IslandTextField(
                  label: 'Phone',
                  showLabel: false,
                  hint: 'Please enter your phone number',
                  prefix: Icon(Icons.phone, size: 20),
                  suffix: Icon(Icons.keyboard_return, size: 20),
                ),
              ),
            ),
          ),
        ),
      );
      expect(t.getSize(find.byType(TextField)).height, 40);
      await t.enterText(
        find.byType(TextField),
        'A long single-line phone value',
      );
      await t.pump();
      expect(t.getSize(find.byType(TextField)).height, 40);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Multiline hint retains explicitly requested lines', (t) async {
    await t.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 160,
            child: IslandTextField(
              label: 'Notes',
              showLabel: false,
              maxLines: 3,
              hint: 'First line of notes\nSecond line\nThird line',
            ),
          ),
        ),
      ),
    );
    expect(t.getSize(find.byType(TextField)).height, greaterThan(60));
    expect(t.takeException(), isNull);
  });
}
