import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: home,
);

void main() {
  group('AnimalLoading Behavior & F14 Tests (C25 / LOD01-LOD03)', () {
    testWidgets(
      'LOD02 / F14: closing the handle before the first frame leaves no orphan',
      (tester) async {
        final AnimalOverlayController controller = AnimalOverlayController();
        late BuildContext buildCtx;

        await tester.pumpWidget(
          _app(
            AnimalOverlayHost(
              controller: controller,
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    buildCtx = context;
                    return const Text('Loading Host');
                  },
                ),
              ),
            ),
          ),
        );

        final handle = AnimalLoading.show(
          buildCtx,
          tip: 'Fetching island mail...',
        );
        expect(handle.isClosed, isFalse);

        // Close before any frame shows the occurrence.
        handle.close();
        expect(handle.isClosed, isTrue);
        // A repeated close is ignored.
        handle.close();
        expect(handle.isClosed, isTrue);

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(AnimalLoading), findsNothing);
        expect(find.text('Fetching island mail...'), findsNothing);

        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
      },
    );

    testWidgets('LOD01: renders spinner, snowflake, and dots indicators', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Column(
              children: [
                const AnimalLoading.spinner(tip: 'Spinning'),
                AnimalLoading.snowflake(
                  tip: 'Snowing',
                  snowCount: 30,
                  snowSeed: 42,
                ),
                const AnimalLoading.dots(tip: 'Dotting'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Spinning'), findsOneWidget);
      expect(find.text('Snowing'), findsOneWidget);
      expect(find.text('Dotting'), findsOneWidget);
      // Spinner and snowflake draw an icon; dots draw three circles.
      expect(find.byType(AnimalIcon), findsNWidgets(2));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Container &&
              w.decoration is BoxDecoration &&
              (w.decoration! as BoxDecoration).shape == BoxShape.circle,
        ),
        findsNWidgets(3),
      );
    });

    testWidgets(
      'LOD03: fullscreen mode blocks interactions behind barrier and displays tip',
      (tester) async {
        late BuildContext buildCtx;
        int tapCount = 0;

        await tester.pumpWidget(
          _app(
            AnimalOverlayHost(
              child: Scaffold(
                body: Builder(
                  builder: (context) {
                    buildCtx = context;
                    return ElevatedButton(
                      onPressed: () => tapCount++,
                      child: const Text('Background Action'),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Background Action'));
        expect(tapCount, 1);

        final handle = AnimalLoading.show(
          buildCtx,
          tip: 'Saving island progress...',
        );
        await tester.pump();

        expect(find.text('Saving island progress...'), findsOneWidget);

        // Tapping behind the barrier is blocked.
        await tester.tap(find.text('Background Action'), warnIfMissed: false);
        expect(tapCount, 1);

        handle.close();
        await tester.pumpAndSettle();

        expect(find.text('Saving island progress...'), findsNothing);

        await tester.tap(find.text('Background Action'));
        expect(tapCount, 2);
      },
    );

    testWidgets('LOD03: an inline fullScreen loading blocks the controls it '
        'covers', (tester) async {
      int tapCount = 0;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Stack(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () => tapCount++,
                    child: const Text('Covered Action'),
                  ),
                ),
                Positioned.fill(
                  child: AnimalLoading(
                    type: AnimalLoadingType.dots,
                    fullScreen: true,
                    tip: 'Inline barrier',
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Covered Action'), warnIfMissed: false);
      expect(tapCount, 0);
      expect(find.text('Inline barrier'), findsOneWidget);
    });
  });
}
