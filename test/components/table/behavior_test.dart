import 'package:animal_island_ui/src/components/table/table_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  _dataOracles();
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
                  rowKey: (index) => ValueKey('row-$index'),
                  columns: [
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
                  rowKey: (index) => ValueKey('row-$index'),
                  columns: [
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
                rowKey: (index) => ValueKey('row-$index'),
                columns: [AnimalTableColumn(title: 'Item')],
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
                rowKey: (index) => ValueKey('row-$index'),
                columns: [AnimalTableColumn(title: 'Item')],
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
                    rowKey: (index) => ValueKey('row-$index'),
                    columns: [AnimalTableColumn(title: 'Item')],
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
                rowKey: (index) => ValueKey('row-$index'),
                columns: [
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

Widget _dataApp(Widget child, {double scale = 1}) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: MediaQuery(
    data: MediaQueryData(textScaler: TextScaler.linear(scale)),
    child: Scaffold(body: child),
  ),
);
void _dataOracles() {
  testWidgets(
    'TBL04 horizontal keyboard and semantics scroll one geometry and borrowed controllers survive replacement',
    (tester) async {
      final borrowed = ScrollController();
      final replacement = ScrollController();
      final semantics = tester.ensureSemantics();
      Widget app(ScrollController? controller, TextDirection direction) =>
          _dataApp(
            Directionality(
              textDirection: direction,
              child: SizedBox(
                width: 300,
                height: 250,
                child: AnimalTable(
                  horizontalScrollController: controller,
                  columns: [
                    AnimalTableColumn(title: 'A', width: 300),
                    AnimalTableColumn(title: 'B', width: 300),
                  ],
                  rowCount: 2,
                  rowKey: (i) => ValueKey(i),
                  rowBuilder: (context, i) => [Text('A $i'), Text('B $i')],
                ),
              ),
            ),
          );
      await tester.pumpWidget(app(borrowed, TextDirection.ltr));
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
      expect(borrowed.offset, 50, reason: 'TBL04_KEYBOARD_HORIZONTAL_SCROLL');
      expect(
        tester.getTopLeft(find.text('A')).dx,
        closeTo(tester.getTopLeft(find.text('A 0')).dx, 2),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      expect(borrowed.offset, borrowed.position.maxScrollExtent);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      expect(borrowed.offset, lessThan(borrowed.position.maxScrollExtent));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      expect(borrowed.offset, 0);
      final nodes = <SemanticsNode>[];
      void collect(SemanticsNode node) {
        if (node.getSemanticsData().hasAction(SemanticsAction.scrollLeft)) {
          nodes.add(node);
        }
        node.visitChildren((child) {
          collect(child);
          return true;
        });
      }

      final semanticsOwner =
          tester.binding.renderViews.single.owner!.semanticsOwner!;
      collect(semanticsOwner.rootSemanticsNode!);
      expect(nodes, hasLength(1));
      semanticsOwner.performAction(nodes.single.id, SemanticsAction.scrollLeft);
      await tester.pumpAndSettle();
      expect(borrowed.offset, greaterThan(0));
      await tester.pumpWidget(app(replacement, TextDirection.rtl));
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(replacement.offset, 50);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(replacement.offset, 0);
      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      expect(replacement.offset, replacement.position.viewportDimension);
      await tester.pumpWidget(app(null, TextDirection.ltr));
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpWidget(app(borrowed, TextDirection.ltr));
      await tester.pumpWidget(const SizedBox());
      var notifications = 0;
      borrowed.addListener(() => notifications++);
      replacement.addListener(() => notifications++);
      borrowed.notifyListeners();
      replacement.notifyListeners();
      expect(notifications, 2);
      expect(tester.takeException(), isNull);
      borrowed.dispose();
      replacement.dispose();
      semantics.dispose();
    },
  );
  testWidgets(
    'TBL01 10k rows 480 viewport 48 extent 96 cache build at most 24 and scrolling elements stay bounded',
    (tester) async {
      var builds = 0;
      final controller = ScrollController();
      await tester.pumpWidget(
        _dataApp(
          SizedBox(
            width: 600,
            height: 531,
            child: AnimalTable(
              columns: [AnimalTableColumn(title: 'ID', width: 200)],
              rowCount: 10000,
              rowKey: (index) => ValueKey(index),
              rowBuilder: (context, index) {
                builds++;
                return [Text('Row $index')];
              },
              verticalScrollController: controller,
              cacheExtent: 96,
              style: AnimalTableStyle(
                rowPadding: EdgeInsets.zero,
                minRowHeight: 48,
              ),
            ),
          ),
        ),
      );
      expect(builds, greaterThan(0));
      expect(builds, lessThanOrEqualTo(24), reason: 'TBL01_LAZY_BUILD_BOUND');
      expect(controller.position.viewportDimension, 480);
      for (final offset in [1000.0, 10000.0, 200000.0]) {
        controller.jumpTo(offset);
        await tester.pump();
        expect(
          find.byType(AnimalTableRow).evaluate().length,
          lessThanOrEqualTo(25),
          reason: 'TBL01_LIVE_ELEMENT_BOUND',
        );
      }
      expect(find.text('Row 0'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
    },
  );
  testWidgets(
    'TBL02 resolved fixed flex mixed padding minWidth and horizontal geometry agree within 2 dp',
    (tester) async {
      final columns = [
        AnimalTableColumn(title: 'Fixed', width: 80),
        AnimalTableColumn(title: 'Flex', flex: 2),
        AnimalTableColumn(title: 'Last', flex: 1),
      ];
      final geometryStyle = AnimalTableStyle(
        rowPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );
      await tester.pumpWidget(
        _dataApp(
          SizedBox(
            width: 600,
            height: 300,
            child: AnimalTable(
              columns: columns,
              style: geometryStyle,
              rowCount: 3,
              rowKey: (i) => ValueKey(i),
              rowBuilder: (context, i) => [
                Text('Fixed $i'),
                Text('Flex $i'),
                Text('Last $i'),
              ],
            ),
          ),
        ),
      );
      final cell = find
          .ancestor(of: find.text('Flex'), matching: find.byType(SizedBox))
          .first;
      expect(
        tester.getSize(cell).width,
        closeTo((600 - 3 - 48 - 80) * 2 / 3, 2),
        reason: 'TBL02_PADDING_GEOMETRY_MISMATCH',
      );
      for (final label in ['Fixed', 'Flex', 'Last']) {
        expect(
          (tester.getTopLeft(find.text(label)).dx -
                  tester.getTopLeft(find.text('$label 0')).dx)
              .abs(),
          lessThanOrEqualTo(2),
        );
      }
      final horizontal = ScrollController();
      await tester.pumpWidget(
        _dataApp(
          SizedBox(
            width: 320,
            height: 300,
            child: AnimalTable(
              columns: columns,
              style: geometryStyle,
              rowCount: 3,
              rowKey: (i) => ValueKey(i),
              minWidth: 600,
              horizontalScrollController: horizontal,
              rowBuilder: (context, i) => [
                Text('Fixed $i'),
                Text('Flex $i'),
                Text('Last $i'),
              ],
            ),
          ),
        ),
      );
      horizontal.jumpTo(100);
      await tester.pump();
      for (final label in ['Fixed', 'Flex', 'Last']) {
        expect(
          (tester.getTopLeft(find.text(label)).dx -
                  tester.getTopLeft(find.text('$label 0')).dx)
              .abs(),
          lessThanOrEqualTo(2),
        );
      }
      expect(horizontal.position.maxScrollExtent, greaterThan(0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      horizontal.dispose();
    },
  );
  test('TBL04 invalid schema numeric values and duplicate row IDs fail at the boundary', () {
    expect(
      () => AnimalTableColumn(title: 'bad', width: double.nan),
      throwsArgumentError,
    );
    expect(
      () => AnimalTableColumn(title: 'bad', width: 0),
      throwsArgumentError,
    );
    expect(() => AnimalTableColumn(title: 'bad', flex: 0), throwsArgumentError);
    expect(
      () => AnimalTable(
        columns: [],
        rowCount: 0,
        rowKey: (i) => ValueKey(i),
        rowBuilder: (context, i) => [],
      ),
      throwsArgumentError,
    );
    expect(
      () => AnimalTable(
        columns: [AnimalTableColumn(title: 'A')],
        rowCount: 2,
        rowKey: (i) => const ValueKey('duplicate'),
        rowBuilder: (context, i) => [],
      ),
      throwsArgumentError,
    );
    expect(
      () => AnimalTable(
        columns: [AnimalTableColumn(title: 'A')],
        rowCount: 0,
        maxHeight: double.infinity,
        rowKey: (i) => ValueKey(i),
        rowBuilder: (context, i) => [],
      ),
      throwsArgumentError,
    );
  });
  testWidgets(
    'TBL04 lazy rows reject missing and extra cells without silently dropping data',
    (tester) async {
      for (final count in [0, 2]) {
        await tester.pumpWidget(
          _dataApp(
            SizedBox(
              height: 300,
              child: AnimalTable(
                key: ValueKey(count),
                columns: [AnimalTableColumn(title: 'A')],
                rowCount: 1,
                rowKey: (i) => ValueKey(i),
                rowBuilder: (context, i) =>
                    List.generate(count, (_) => const Text('cell')),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isA<ArgumentError>());
      }
    },
  );
  testWidgets(
    'TBL03 reordered row IDs preserve editable state and focus while 200 percent text remains readable',
    (tester) async {
      var ids = ['a', 'b', 'c'];
      Widget app() => _dataApp(
        SizedBox(
          width: 320,
          height: 400,
          child: AnimalTable(
            columns: [AnimalTableColumn(title: 'Long readable heading')],
            rowCount: ids.length,
            rowKey: (i) => ValueKey(ids[i]),
            rowBuilder: (context, i) => [
              TextField(key: ValueKey('field-${ids[i]}')),
            ],
          ),
        ),
        scale: 2,
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('field-a')),
        'belongs to A',
      );
      final focus = FocusManager.instance.primaryFocus;
      ids = ['c', 'a', 'b'];
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, same(focus));
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const ValueKey('field-a')),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        'belongs to A',
      );
      expect(tester.takeException(), isNull);
    },
  );
}
