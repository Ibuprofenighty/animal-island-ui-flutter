import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/pagination/pagination_model.dart';

void main() {
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
