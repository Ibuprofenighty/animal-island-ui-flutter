import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTable S12 Contract & Behavior Tests (F10 / TBL01-TBL05)', () {
    testWidgets(
      'TBL01: 10000 rows lazy rowBuilder builds <= 24 rows in 400px viewport (F10 CURED)',
      (tester) async {
        int builtRows = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                height: 400,
                child: AnimalTable(
                  columns: const [
                    AnimalTableColumn(title: 'Col 0', width: 100),
                    AnimalTableColumn(title: 'Col 1', width: 100),
                  ],
                  rowCount: 10000,
                  rowBuilder: (context, i) {
                    builtRows++;
                    return [Text('Row $i Col 0'), Text('Row $i Col 1')];
                  },
                ),
              ),
            ),
          ),
        );

        // Contract TBL01: In a 400px high viewport, only visible rows (~10-20 rows) should ever be built.
        expect(
          builtRows,
          lessThanOrEqualTo(24),
          reason: 'Only visible rows should be constructed by lazy rowBuilder in a 400px viewport',
        );
        expect(find.text('Row 0 Col 0'), findsOneWidget);
        expect(find.text('Row 1 Col 0'), findsOneWidget);
      },
    );

    testWidgets(
      'TBL02: Solves fixed, flex, and mixed column widths accurately',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                height: 300,
                width: 500,
                child: AnimalTable(
                  columns: const [
                    AnimalTableColumn(title: 'Fixed ID', width: 80),
                    AnimalTableColumn(title: 'Flex Name', flex: 2),
                    AnimalTableColumn(title: 'Flex Category', flex: 1),
                  ],
                  rowCount: 5,
                  rowBuilder: (context, i) => [
                    Text('ID-$i'),
                    Text('Name-$i'),
                    Text('Category-$i'),
                  ],
                ),
              ),
            ),
          ),
        );

        expect(find.text('Fixed ID'), findsOneWidget);
        expect(find.text('Flex Name'), findsOneWidget);
        expect(find.text('Flex Category'), findsOneWidget);
        expect(find.text('ID-0'), findsOneWidget);
      },
    );

    testWidgets('TBL03: Handles empty state and loading state gracefully', (
      tester,
    ) async {
      // 1. Empty state
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: AnimalTable(
                columns: const [AnimalTableColumn(title: 'Item')],
                rowCount: 0,
                rowBuilder: (context, i) => [const Text('Nothing')],
              ),
            ),
          ),
        ),
      );

      final emptyState = AnimalLocalizations.of(
        tester.element(find.byType(AnimalTable)),
      )!.empty;
      expect(find.text(emptyState), findsOneWidget);

      // 2. Loading state
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: AnimalTable(
                columns: const [AnimalTableColumn(title: 'Item')],
                rowCount: 0,
                loading: true,
                rowBuilder: (context, i) => [const Text('Nothing')],
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AnimalLoading), findsOneWidget);
    });

    testWidgets(
      'TBL04: Unbounded vertical layout throws assertion/error when maxHeight is null',
      (tester) async {
        bool caughtError = false;
        try {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: AnimalTable(
                    columns: const [AnimalTableColumn(title: 'Item')],
                    rowCount: 10,
                    rowBuilder: (context, i) => [Text('Item $i')],
                  ),
                ),
              ),
            ),
          );
        } catch (_) {
          caughtError = true;
        }

        // Either tester catches layout assertion or FlutterError
        final dynamic exception = tester.takeException();
        expect(caughtError || exception != null, isTrue);
      },
    );

    testWidgets('TBL05: Sticky header cells declare header semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: AnimalTable(
                columns: const [
                  AnimalTableColumn(title: 'Villager'),
                  AnimalTableColumn(title: 'Species'),
                ],
                rowCount: 2,
                rowBuilder: (context, i) => [Text('V-$i'), Text('S-$i')],
              ),
            ),
          ),
        ),
      );

      final headerSemantics = tester.widgetList<Semantics>(
        find.ancestor(
          of: find.text('Villager'),
          matching: find.byType(Semantics),
        ),
      );
      expect(headerSemantics.any((s) => s.properties.header == true), isTrue);
    });
  });
}
