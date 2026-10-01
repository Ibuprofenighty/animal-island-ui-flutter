import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCheckbox & CheckboxGroup Tests (C14 / CHK01-CHK04)', () {
    testWidgets('CHK01: Standalone checkbox toggles on tap', (tester) async {
      bool? checked = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCheckbox(
              value: checked,
              label: const Text('Accept Terms'),
              onChanged: (val) => checked = val,
            ),
          ),
        ),
      );

      expect(find.text('Accept Terms'), findsOneWidget);

      await tester.tap(find.byType(AnimalCheckbox));
      await tester.pumpAndSettle();

      expect(checked, isTrue);
    });

    testWidgets(
      'CHK01: CheckboxGroup selects and deselects items, respects disabled options',
      (tester) async {
        List<String> selectedValues = ['apple'];

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalCheckboxGroup<String>(
                    value: selectedValues,
                    options: const [
                      AnimalOption(value: 'apple', label: 'Apple'),
                      AnimalOption(value: 'banana', label: 'Banana'),
                      AnimalOption(
                        value: 'cherry',
                        label: 'Cherry',
                        disabled: true,
                      ),
                    ],
                    onChanged: (vals) => setState(() => selectedValues = vals),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Apple'), findsOneWidget);
        expect(find.text('Banana'), findsOneWidget);
        expect(find.text('Cherry'), findsOneWidget);

        // Tap Banana -> adds to selection
        await tester.tap(find.text('Banana'));
        await tester.pumpAndSettle();
        expect(selectedValues, containsAll(['apple', 'banana']));

        // Tap disabled Cherry -> ignored
        await tester.tap(find.text('Cherry'));
        await tester.pumpAndSettle();
        expect(selectedValues.contains('cherry'), isFalse);

        // Tap Apple -> removes from selection
        await tester.tap(find.text('Apple'));
        await tester.pumpAndSettle();
        expect(selectedValues.contains('apple'), isFalse);
        expect(selectedValues, ['banana']);
      },
    );

    testWidgets('CHK03: Indeterminate checkbox shows dash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCheckbox(
              value: false,
              indeterminate: true,
              label: const Text('Indeterminate'),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Indeterminate'), findsOneWidget);
    });
  });
}
