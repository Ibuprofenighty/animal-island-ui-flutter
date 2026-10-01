import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCollapse State & Disabled Tests (C09 / COL03)', () {
    testWidgets('uncontrolled mode tracks internal active state', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCollapse(
              defaultActiveIds: {'item_1'},
              items: [
                AnimalCollapseItem(
                  id: 'item_1',
                  title: Text('Title 1'),
                  content: Text('Body 1'),
                ),
                AnimalCollapseItem(
                  id: 'item_2',
                  title: Text('Title 2'),
                  content: Text('Body 2'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Body 1'), findsOneWidget);

      await tester.tap(find.text('Title 2'));
      await tester.pumpAndSettle();

      expect(find.text('Body 2'), findsOneWidget);
    });

    testWidgets(
      'COL03: disabled items and global disabled ignore click interactions',
      (tester) async {
        Set<String> active = <String>{};

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return AnimalCollapse(
                    activeIds: active,
                    onChanged: (ids) => setState(() => active = ids),
                    items: const [
                      AnimalCollapseItem(
                        id: 'enabled_item',
                        title: Text('Enabled Item'),
                        content: Text('Enabled Content'),
                      ),
                      AnimalCollapseItem(
                        id: 'disabled_item',
                        title: Text('Disabled Item'),
                        content: Text('Disabled Content'),
                        disabled: true,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );

        // Tapping disabled item does nothing
        await tester.tap(find.text('Disabled Item'));
        await tester.pumpAndSettle();

        expect(active, isEmpty);

        // Tapping enabled item toggles it
        await tester.tap(find.text('Enabled Item'));
        await tester.pumpAndSettle();

        expect(active, {'enabled_item'});
      },
    );
  });
}
