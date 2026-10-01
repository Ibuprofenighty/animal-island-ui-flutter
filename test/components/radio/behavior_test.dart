import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalRadio & RadioGroup Tests (C15 / RAD01-RAD04)', () {
    testWidgets('RAD01: Standalone radio taps invoke onChanged with value', (
      tester,
    ) async {
      int? selected = 1;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalRadio<int>(
              value: 2,
              groupValue: selected,
              label: const Text('Option 2'),
              onChanged: (val) => selected = val,
            ),
          ),
        ),
      );

      expect(find.text('Option 2'), findsOneWidget);

      await tester.tap(find.byType(AnimalRadio<int>));
      await tester.pumpAndSettle();

      expect(selected, 2);
    });

    testWidgets(
      'RAD01: AnimalRadioGroup enforces mutual exclusivity and respects disabled items',
      (tester) async {
        String? selectedValue = 'pear';

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalRadioGroup<String>(
                    value: selectedValue,
                    options: const [
                      AnimalOption(value: 'pear', label: 'Pear'),
                      AnimalOption(value: 'peach', label: 'Peach'),
                      AnimalOption(
                        value: 'plum',
                        label: 'Plum',
                        disabled: true,
                      ),
                    ],
                    onChanged: (val) => setState(() => selectedValue = val),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Pear'), findsOneWidget);
        expect(find.text('Peach'), findsOneWidget);
        expect(find.text('Plum'), findsOneWidget);

        // Tap Peach -> changes selection to peach
        await tester.tap(find.text('Peach'));
        await tester.pumpAndSettle();
        expect(selectedValue, 'peach');

        // Tap disabled Plum -> ignored
        await tester.tap(find.text('Plum'));
        await tester.pumpAndSettle();
        expect(selectedValue, 'peach');
      },
    );

    testWidgets(
      'RAD03: Renders distinctive rounded square styling and SVG check',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalRadio<int>(
                value: 1,
                groupValue: 1,
                label: const Text('Checked Square'),
                onChanged: (_) {},
              ),
            ),
          ),
        );

        expect(find.byType(AnimalIcon), findsOneWidget);
      },
    );
  });
}
