import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalBackTop State & Lifecycle Tests (C27 / BTP02)', () {
    testWidgets('didUpdateWidget detaches old controller and attaches to new', (
      tester,
    ) async {
      final controller1 = ScrollController();
      final controller2 = ScrollController();

      var activeCtrl = controller1;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      controller: activeCtrl,
                      child: const SizedBox(height: 2000),
                    ),
                    AnimalBackTop(
                      scrollController: activeCtrl,
                      visibilityHeight: 300,
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => activeCtrl = controller2),
                      child: const Text('Switch Controller'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Scroll controller1 past threshold
      controller1.jumpTo(500);
      await tester.pumpAndSettle();

      var ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimalBackTop),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isFalse);

      // Switch to controller2
      await tester.tap(find.text('Switch Controller'));
      await tester.pumpAndSettle();

      // controller2 is attached; scrolling controller2 below threshold hides BackTop
      controller2.jumpTo(100);
      await tester.pumpAndSettle();

      ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimalBackTop),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isTrue);

      // Old controller1 is detached and has no clients
      expect(controller1.hasClients, isFalse);

      // New controller2 scrolling triggers BackTop visibility
      controller2.jumpTo(600);
      await tester.pumpAndSettle();
      ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(AnimalBackTop),
          matching: find.byType(IgnorePointer),
        ),
      );
      expect(ignorePointer.ignoring, isFalse);

      controller1.dispose();
      controller2.dispose();
    });
  });
}
