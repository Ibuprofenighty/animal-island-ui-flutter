import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalSelect Tests (C16 / SEL01-SEL04)', () {
    testWidgets(
      'SEL01: Tapping select opens menu and choosing an item updates value',
      (tester) async {
        String? selected = 'option_a';

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalSelect<String>(
                    value: selected,
                    options: const [
                      AnimalOption(value: 'option_a', label: 'Option A'),
                      AnimalOption(value: 'option_b', label: 'Option B'),
                      AnimalOption(
                        value: 'option_c',
                        label: 'Option C',
                        disabled: true,
                      ),
                    ],
                    onChanged: (val) => setState(() => selected = val),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('Option A'), findsOneWidget);

        // Tap select trigger to open MenuAnchor
        await tester.tap(find.text('Option A'));
        await tester.pumpAndSettle();

        // Tap Option B
        await tester.tap(find.text('Option B'));
        await tester.pumpAndSettle();

        expect(selected, 'option_b');
        expect(find.text('Option B'), findsOneWidget);
      },
    );

    testWidgets('SEL02: Clear button resets value to null', (tester) async {
      String? selected = 'option_a';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalSelect<String>(
                  value: selected,
                  allowClear: true,
                  options: const [
                    AnimalOption(value: 'option_a', label: 'Option A'),
                    AnimalOption(value: 'option_b', label: 'Option B'),
                  ],
                  onChanged: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Option A'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear selection'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Clear selection'));
      await tester.pumpAndSettle();

      expect(selected, isNull);
    });

    testWidgets('SEL03: Disabled option is ignored when tapped', (
      tester,
    ) async {
      String? selected = 'option_a';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AnimalSelect<String>(
                  value: selected,
                  options: const [
                    AnimalOption(value: 'option_a', label: 'Option A'),
                    AnimalOption(
                      value: 'option_b',
                      label: 'Option B',
                      disabled: true,
                    ),
                  ],
                  onChanged: (val) => setState(() => selected = val),
                );
              },
            ),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      // Tap disabled option B
      await tester.tap(find.text('Option B'));
      await tester.pumpAndSettle();

      expect(selected, 'option_a');
    });
  });
}
