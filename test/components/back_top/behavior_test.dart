import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalBackTop Behavior Tests (C27 / BTP01-BTP03)', () {
    testWidgets(
      'BTP01 & BTP03: button becomes visible beyond threshold and scrolls to top on tap',
      (tester) async {
        final controller = ScrollController();

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  SingleChildScrollView(
                    controller: controller,
                    child: const SizedBox(height: 2000),
                  ),
                  AnimalBackTop(
                    scrollController: controller,
                    visibilityHeight: 300,
                  ),
                ],
              ),
            ),
          ),
        );

        // Initially at offset 0: invisible and ignored
        final ignorePointer = tester.widget<IgnorePointer>(
          find.descendant(
            of: find.byType(AnimalBackTop),
            matching: find.byType(IgnorePointer),
          ),
        );
        expect(ignorePointer.ignoring, isTrue);

        // Scroll past threshold
        controller.jumpTo(500);
        await tester.pumpAndSettle();

        final visibleIgnorePointer = tester.widget<IgnorePointer>(
          find.descendant(
            of: find.byType(AnimalBackTop),
            matching: find.byType(IgnorePointer),
          ),
        );
        expect(visibleIgnorePointer.ignoring, isFalse);

        // Tap button to scroll back to top
        await tester.tap(find.byType(AnimalBackTop));
        await tester.pumpAndSettle();

        expect(controller.offset, 0.0);

        controller.dispose();
      },
    );
  });
}
