import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalDatePicker Semantics Tests', () {
    testWidgets('Emits accessible semantics for Today and Clear', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalDatePicker(
              value: AnimalDate(2026, 9, 15),
              showToday: true,
              allowClear: true,
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Today'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear date'), findsOneWidget);

      handle.dispose();
    });
  });
}
