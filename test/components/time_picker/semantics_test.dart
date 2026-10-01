import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTimePicker Semantics Tests', () {
    testWidgets('Emits accessible semantics for Now and Clear', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTimePicker(
              value: AnimalTimeValue(hour: 12, minute: 30),
              showNow: true,
              allowClear: true,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Now'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear time'), findsOneWidget);

      handle.dispose();
    });
  });
}
