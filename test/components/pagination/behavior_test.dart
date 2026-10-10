import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/pagination/pagination_model.dart';

void main() {
  _dataOracles();
  group(
    'AnimalPagination S12 Contract & Behavior Tests (F24 / PAG01-PAG03)',
    () {
      test('PAG01: Safe integer arithmetic and input argument validation', () {
        // 1. Invalid pageSize
        expect(
          () => AnimalPaginationModel.calculateTotalPages(
            total: 100,
            pageSize: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => AnimalPaginationModel.calculateTotalPages(
            total: 100,
            pageSize: -5,
          ),
          throwsArgumentError,
        );

        // 2. Negative total
        expect(
          () => AnimalPaginationModel.calculateTotalPages(
            total: -10,
            pageSize: 10,
          ),
          throwsArgumentError,
        );

        // 3. Normal integer division
        expect(
          AnimalPaginationModel.calculateTotalPages(total: 0, pageSize: 10),
          equals(1),
        );
        expect(
          AnimalPaginationModel.calculateTotalPages(total: 1, pageSize: 10),
          equals(1),
        );
        expect(
          AnimalPaginationModel.calculateTotalPages(total: 10, pageSize: 10),
          equals(1),
        );
        expect(
          AnimalPaginationModel.calculateTotalPages(total: 11, pageSize: 10),
          equals(2),
        );
        expect(
          AnimalPaginationModel.calculateTotalPages(total: 100, pageSize: 10),
          equals(10),
        );

        // 4. Large page count without arbitrary 999999 truncation
        expect(
          AnimalPaginationModel.calculateTotalPages(
            total: 20000000,
            pageSize: 10,
          ),
          equals(2000000),
        );
      });

      test(
        'PAG01: Windowed pagination algorithm produces correct item sequences',
        () {
          // <= 7 pages: direct sequence
          expect(
            AnimalPaginationModel.calculatePageItems(current: 1, totalPages: 5),
            equals([1, 2, 3, 4, 5]),
          );

          // Start window
          expect(
            AnimalPaginationModel.calculatePageItems(
              current: 2,
              totalPages: 10,
            ),
            equals([1, 2, 3, 4, 5, -2, 10]),
          );

          // End window
          expect(
            AnimalPaginationModel.calculatePageItems(
              current: 9,
              totalPages: 10,
            ),
            equals([1, -1, 6, 7, 8, 9, 10]),
          );

          // Middle window
          expect(
            AnimalPaginationModel.calculatePageItems(
              current: 5,
              totalPages: 10,
            ),
            equals([1, -1, 4, 5, 6, -2, 10]),
          );
        },
      );

      testWidgets('PAG02: Disabled state fires zero callbacks', (tester) async {
        int? changedPage;
        final semantics = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalPagination(
                current: 3,
                total: 100,
                pageSize: 10,
                disabled: true,
                onChanged: (p) => changedPage = p,
              ),
            ),
          ),
        );

        final localizations = AnimalLocalizations.of(
          tester.element(find.byType(AnimalPagination)),
        )!;

        // Attempt to tap next page
        final nextPage = find.bySemanticsLabel(localizations.paginationNext);
        final nextPageNode = tester.getSemantics(nextPage);
        expect(nextPageNode.label, localizations.paginationNext);
        expect(
          nextPageNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isFalse,
        );
        await tester.tap(nextPage);
        await tester.pump();
        expect(changedPage, isNull);

        // Attempt to tap page 4
        await tester.tap(find.text('4'));
        await tester.pump();
        expect(changedPage, isNull);
        semantics.dispose();
      });

      testWidgets('PAG02: Ellipsis nodes jump 5 pages forward or backward', (
        tester,
      ) async {
        int? changedPage;
        final semantics = tester.ensureSemantics();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalPagination(
                current: 5,
                total: 200,
                pageSize: 10,
                onChanged: (p) => changedPage = p,
              ),
            ),
          ),
        );

        final localizations = AnimalLocalizations.of(
          tester.element(find.byType(AnimalPagination)),
        )!;

        // Tap backward jump ellipsis
        final backwardJump = find.bySemanticsLabel(
          localizations.paginationSkipBackward,
        );
        final backwardNode = tester.getSemantics(backwardJump);
        expect(backwardNode.label, localizations.paginationSkipBackward);
        expect(
          backwardNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        await tester.tap(backwardJump);
        await tester.pump();
        expect(changedPage, equals(1)); // max(1, 5 - 5) = 1

        // Tap forward jump ellipsis
        final forwardJump = find.bySemanticsLabel(
          localizations.paginationSkipForward,
        );
        final forwardNode = tester.getSemantics(forwardJump);
        expect(forwardNode.label, localizations.paginationSkipForward);
        expect(
          forwardNode.getSemanticsData().hasAction(SemanticsAction.tap),
          isTrue,
        );
        await tester.tap(forwardJump);
        await tester.pump();
        expect(changedPage, equals(10)); // min(20, 5 + 5) = 10
        semantics.dispose();
      });

      testWidgets(
        'PAG03: Auto-compacts on narrow viewport (< 540px) without overflow',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: SizedBox(
                  width: 320,
                  child: AnimalPagination(
                    current: 4,
                    total: 200,
                    pageSize: 10,
                    onChanged: (_) {},
                  ),
                ),
              ),
            ),
          );

          expect(find.text('4 / 20'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    },
  );
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
    'PAG03 ellipsis typography selects the measured window at scaled LTR and RTL thresholds',
    (tester) async {
      tester.view.physicalSize = const Size(2400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final proposals = <int>[];
      Widget app(double width, double scale, TextDirection direction) =>
          _dataApp(
            Directionality(
              textDirection: direction,
              child: SizedBox(
                width: width,
                child: AnimalPagination(
                  current: 5,
                  total: 2000,
                  onChanged: proposals.add,
                  style: AnimalPaginationStyle(
                    ellipsisTextStyle: const TextStyle(fontSize: 80),
                  ),
                ),
              ),
            ),
            scale: scale,
          );
      for (final direction in TextDirection.values) {
        for (final scale in [1.0, 2.0]) {
          await tester.pumpWidget(app(500 * scale, scale, direction));
          expect(
            tester.takeException(),
            isNull,
            reason: 'PAG03_ELLIPSIS_STYLE_MEASUREMENT',
          );
          expect(find.text('5 / 200'), findsOneWidget);
          final copy = AnimalLocalizations.of(
            tester.element(find.byType(AnimalPagination)),
          )!;
          await tester.tap(find.bySemanticsLabel(copy.paginationNext));
          await tester.pumpAndSettle();
          expect(proposals.last, 6);
          expect(
            tester
                .widget<AnimalPagination>(find.byType(AnimalPagination))
                .current,
            5,
          );
          await tester.pumpWidget(app(2000, scale, direction));
          expect(tester.takeException(), isNull);
          expect(find.text('5 / 200'), findsNothing);
          expect(find.text('•••'), findsNWidgets(2));
        }
      }
      expect(proposals, [6, 6, 6, 6]);
    },
  );
  testWidgets(
    'PAG02 ellipsis proposals clamp at the maximum integer without overflow or local commit',
    (tester) async {
      tester.view.physicalSize = const Size(2400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final semantics = tester.ensureSemantics();
      try {
        const last = 9223372036854775807;
        const current = last - 4;
        final proposals = <int>[];
        await tester.pumpWidget(
          _dataApp(
            AnimalPagination(
              current: current,
              total: last,
              pageSize: 1,
              onChanged: proposals.add,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        final copy = AnimalLocalizations.of(
          tester.element(find.byType(AnimalPagination)),
        )!;
        await tester.tap(find.bySemanticsLabel(copy.paginationSkipForward));
        await tester.pumpAndSettle();
        expect(proposals, [last], reason: 'PAG02_MAX_INT_JUMP_OVERFLOW');
        expect(
          tester
              .widget<AnimalPagination>(find.byType(AnimalPagination))
              .current,
          current,
        );
        proposals.clear();
        await tester.tap(find.bySemanticsLabel(copy.paginationSkipBackward));
        await tester.pumpAndSettle();
        expect(proposals, [current - 5]);
      } finally {
        semantics.dispose();
      }
    },
  );
  test('PAG01 current total and pageSize boundaries use exact integers in every build mode', () {
    for (final size in [0, -1]) {
      expect(
        () => AnimalPagination(
          current: 1,
          total: 10,
          pageSize: size,
          onChanged: (_) {},
        ),
        throwsArgumentError,
      );
    }
    for (final current in [0, 11]) {
      expect(
        () => AnimalPagination(current: current, total: 100, onChanged: (_) {}),
        throwsRangeError,
      );
    }
    expect(
      () => AnimalPagination(current: 2, total: 0, onChanged: (_) {}),
      throwsRangeError,
    );
    expect(
      AnimalPagination(
        current: 1,
        total: 9223372036854775807,
        pageSize: 10,
        onChanged: (_) {},
      ).totalPages,
      922337203685477581,
    );
  });
  testWidgets(
    'PAG02 empty disabled and rejected navigation never produce an out of range or local commit',
    (tester) async {
      final proposals = <int>[];
      await tester.pumpWidget(
        _dataApp(
          AnimalPagination(current: 1, total: 0, onChanged: proposals.add),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Next page'));
      await tester.pump();
      expect(proposals, isEmpty);
      await tester.pumpWidget(
        _dataApp(
          AnimalPagination(current: 2, total: 30, onChanged: proposals.add),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Next page'));
      await tester.pumpAndSettle();
      expect(proposals, [3]);
      expect(
        tester.widget<AnimalPagination>(find.byType(AnimalPagination)).current,
        2,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(proposals.every((page) => page >= 1 && page <= 3), isTrue);
    },
  );
  testWidgets(
    'PAG03 measured 320 pixel 200 percent RTL and huge totals keep navigation operable',
    (tester) async {
      final proposals = <int>[];
      await tester.pumpWidget(
        _dataApp(
          Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 320,
              child: AnimalPagination(
                current: 100000000,
                total: 1000000010,
                onChanged: proposals.add,
              ),
            ),
          ),
          scale: 2,
        ),
      );
      expect(find.text('100000000 / 100000001'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final next = find.bySemanticsLabel('Next page');
      expect(tester.getSize(next).width, greaterThanOrEqualTo(48));
      await tester.tap(next);
      await tester.pumpAndSettle();
      expect(proposals, [100000001]);
    },
  );
}
