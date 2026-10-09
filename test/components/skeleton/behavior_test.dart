import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: child),
);

/// The shimmer controller, or null while the skeleton rests.
AnimationController? _shimmer(WidgetTester tester) {
  final Iterable<AnimatedBuilder> builders = tester.widgetList<AnimatedBuilder>(
    find.descendant(
      of: find.byType(AnimalSkeleton),
      matching: find.byType(AnimatedBuilder),
    ),
  );
  return builders.isEmpty
      ? null
      : builders.first.animation as AnimationController;
}

void main() {
  group('N23 AnimalSkeleton motion and contract', () {
    testWidgets(
      'SKL02 one shimmer controller survives 100 loading, activity and motion-policy cycles',
      (tester) async {
        final ValueNotifier<(bool, bool, bool, bool)> flags =
            ValueNotifier<(bool, bool, bool, bool)>((true, true, true, false));
        addTearDown(flags.dispose);
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<(bool, bool, bool, bool)>(
              valueListenable: flags,
              builder: (context, value, _) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: value.$4),
                child: TickerMode(
                  enabled: value.$3,
                  child: AnimalSkeleton(
                    loading: value.$1,
                    active: value.$2,
                    width: 120,
                    height: 40,
                    child: const Text('Real content'),
                  ),
                ),
              ),
            ),
          ),
        );
        final AnimationController controller = _shimmer(tester)!;

        for (int cycle = 0; cycle < 100; cycle++) {
          for (final (bool, bool, bool, bool) state
              in <(bool, bool, bool, bool)>[
                (false, true, true, false),
                (true, true, true, false),
                (true, false, true, false),
                (true, true, true, false),
                (true, true, false, false),
                (true, true, true, false),
                (true, true, true, true),
                (true, true, true, false),
              ]) {
            flags.value = state;
            await tester.pump(const Duration(milliseconds: 16));
            final bool running = state.$1 && state.$2 && state.$3 && !state.$4;
            expect(tester.takeException(), isNull);
            expect(controller.isAnimating, running);
            expect(
              tester.binding.transientCallbackCount,
              running ? greaterThan(0) : 0,
            );
            if (running) {
              expect(identical(_shimmer(tester), controller), isTrue);
            }
            expect(
              find.text('Real content'),
              state.$1 ? findsNothing : findsOneWidget,
            );
          }
        }
      },
    );

    testWidgets('SKL02 reduced motion shows the plain fill at rest', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: AnimalSkeleton(width: 120, height: 40),
          ),
        ),
      );
      expect(_shimmer(tester), isNull);
      final BoxDecoration decoration =
          tester
                  .widget<Container>(
                    find.descendant(
                      of: find.byType(AnimalSkeleton),
                      matching: find.byType(Container),
                    ),
                  )
                  .decoration!
              as BoxDecoration;
      expect(decoration.color, AnimalIslandTheme.light.colors.bgDisabled);
      expect(decoration.gradient, isNull);
    });

    test('SKL01 invalid rows, row widths and extents are rejected', () {
      expect(() => AnimalSkeleton(rows: 0), throwsArgumentError);
      expect(() => AnimalSkeleton.paragraph(rows: -1), throwsArgumentError);
      expect(
        () => AnimalSkeleton.paragraph(rowWidths: <double>[0.5, 1.2]),
        throwsArgumentError,
      );
      expect(
        () => AnimalSkeleton(rowWidths: <double>[double.nan]),
        throwsArgumentError,
      );
      expect(() => AnimalSkeleton(width: -1), throwsArgumentError);
      expect(
        () => AnimalSkeleton(height: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => AnimalSkeleton.avatar(size: double.nan),
        throwsArgumentError,
      );
    });

    testWidgets('SKL01 row widths are fractions of the paragraph width', (
      tester,
    ) async {
      final List<double> widths = <double>[0.5, 0.25];
      final AnimalSkeleton paragraph = AnimalSkeleton.paragraph(
        rows: 4,
        rowWidths: widths,
        active: false,
      );
      // The skeleton keeps its own copy of the validated widths.
      widths[0] = 1;
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 300, child: paragraph),
          ),
        ),
      );
      final List<double> rows = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byType(AnimalSkeleton),
              matching: find.byType(Container),
            ),
          )
          .map((Container row) => tester.getSize(find.byWidget(row)).width)
          .toList();
      expect(rows, <double>[150, 75, 180, 300]);
    });

    testWidgets(
      'SKL03 the placeholder exposes loading semantics only and the real child returns',
      (tester) async {
        final SemanticsHandle handle = tester.ensureSemantics();
        final ValueNotifier<bool> loading = ValueNotifier<bool>(true);
        addTearDown(loading.dispose);
        await tester.pumpWidget(
          _app(
            ValueListenableBuilder<bool>(
              valueListenable: loading,
              builder: (context, value, _) => AnimalSkeleton(
                loading: value,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Open the shop'),
                ),
              ),
            ),
          ),
        );
        expect(find.bySemanticsLabel('Loading...'), findsOneWidget);
        expect(find.bySemanticsLabel('Open the shop'), findsNothing);

        loading.value = false;
        await tester.pump();
        expect(find.bySemanticsLabel('Loading...'), findsNothing);
        expect(find.bySemanticsLabel('Open the shop'), findsOneWidget);
        handle.dispose();
      },
    );
  });
}
