import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalLoading Behavior & F14 Tests (C25 / LOD01-LOD03)', () {
    tearDown(() {
      AnimalLoading.hide();
    });

    testWidgets(
      'LOD02 / F14: releasing handle before first frame cleans up cleanly without orphan',
      (tester) async {
        late BuildContext buildCtx;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  buildCtx = context;
                  return const Text('Loading Host');
                },
              ),
            ),
          ),
        );

        // Trigger show
        final handle = AnimalLoading.show(
          buildCtx,
          tip: 'Fetching island mail...',
        );

        expect(handle.isClosed, isFalse);

        // Immediately release handle before any frame pumps
        handle.close();
        expect(handle.isClosed, isTrue);

        // Duplicate release must be completely safe / idempotent
        handle.release();

        // Pump frames
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Must not have left an orphan AnimalLoading in the tree
        expect(find.text('Fetching island mail...'), findsNothing);
      },
    );

    testWidgets('LOD01: renders spinner, snowflake, and dots indicators', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalLoading.spinner(tip: 'Spinning'),
                AnimalLoading.snowflake(
                  tip: 'Snowing',
                  snowCount: 30,
                  snowSeed: 42,
                ),
                AnimalLoading.dots(tip: 'Dotting'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Spinning'), findsOneWidget);
      expect(find.text('Snowing'), findsOneWidget);
      expect(find.text('Dotting'), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets(
      'LOD03: fullscreen mode blocks interactions behind barrier and displays tip',
      (tester) async {
        late BuildContext buildCtx;
        int tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
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
        );

        // Initially can tap background button
        await tester.tap(find.text('Background Action'));
        expect(tapCount, 1);

        // Show fullscreen loading
        final handle = AnimalLoading.show(
          buildCtx,
          tip: 'Saving island progress...',
        );
        await tester.pump();

        expect(find.text('Saving island progress...'), findsOneWidget);

        // Tapping behind barrier is blocked
        await tester.tap(find.text('Background Action'), warnIfMissed: false);
        expect(tapCount, 1);

        // Dismiss loading
        handle.close();
        await tester.pumpAndSettle();

        expect(find.text('Saving island progress...'), findsNothing);

        // Now background can be tapped again
        await tester.tap(find.text('Background Action'));
        expect(tapCount, 2);
      },
    );
  });
}
