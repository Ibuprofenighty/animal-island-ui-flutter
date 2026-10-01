import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalBackTop Semantics Tests (C27 / BTP01)', () {
    testWidgets('invisible button ignores hit-test and semantics', (
      tester,
    ) async {
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
                  child: const SizedBox(height: 1000),
                ),
                AnimalBackTop(scrollController: controller),
              ],
            ),
          ),
        ),
      );

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimalBackTop),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(
        ignorePointer.ignoring,
        isTrue,
        reason: 'BTP01 invisible BackTop ignores pointer input',
      );

      controller.dispose();
    });
  });
}
