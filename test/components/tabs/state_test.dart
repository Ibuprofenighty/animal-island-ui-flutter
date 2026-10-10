import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTabs State & Boundary Tests (C10 / TAB03)', () {
    testWidgets('handles empty tabs without exception', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTabs(
              selectedId: null,
              onChanged: (_) {},
              tabs: const [],
            ),
          ),
        ),
      );

      expect(find.byType(AnimalTabs), findsOneWidget);
    });

    testWidgets('didUpdateWidget synchronizes external selectedId change', (
      tester,
    ) async {
      String active = 'tab-0';

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    AnimalTabs(
                      selectedId: active,
                      onChanged: (idx) => setState(() => active = idx),
                      tabs: [
                        AnimalTabItem(id: 'tab-0', label: 'Tab A'),
                        AnimalTabItem(id: 'tab-1', label: 'Tab B'),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => active = 'tab-1'),
                      child: const Text('Select B Externally'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(active, 'tab-0');

      await tester.tap(find.text('Select B Externally'));
      await tester.pumpAndSettle();

      expect(active, 'tab-1');
    });
  });
}
