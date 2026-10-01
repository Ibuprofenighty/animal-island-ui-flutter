import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';

void main() {
  group('AnimalDatePicker State Tests', () {
    testWidgets('didUpdateWidget synchronizes external value updates', (
      tester,
    ) async {
      AnimalDate currentDate = AnimalDate(2026, 9, 15);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: Column(
                  children: [
                    AnimalDatePicker(value: currentDate, onChanged: (d) {}),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentDate = AnimalDate(2026, 10, 20);
                        });
                      },
                      child: const Text('Update Date'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      final materialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );
      expect(
        find.text(materialLocalizations.formatMonthYear(DateTime(2026, 9))),
        findsOneWidget,
      );

      await tester.tap(find.text('Update Date'));
      await tester.pumpAndSettle();

      expect(
        find.text(materialLocalizations.formatMonthYear(DateTime(2026, 10))),
        findsOneWidget,
      );
    });

    testWidgets('Previous and next year navigation updates displayed year', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalDatePicker(value: AnimalDate(2026, 5, 1))),
        ),
      );

      final materialLocalizations = MaterialLocalizations.of(
        tester.element(find.byType(AnimalDatePickerPanel)),
      );
      expect(
        find.text(materialLocalizations.formatMonthYear(DateTime(2026, 5))),
        findsOneWidget,
      );

      // Tap next year
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_right_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text(materialLocalizations.formatMonthYear(DateTime(2027, 5))),
        findsOneWidget,
      );

      // Tap prev year twice
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.keyboard_double_arrow_left_rounded));
      await tester.pumpAndSettle();
      expect(
        find.text(materialLocalizations.formatMonthYear(DateTime(2025, 5))),
        findsOneWidget,
      );
    });
  });
}
