import 'dart:ui' show Tristate;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C10 tab caller label updates in visual and semantics trees', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    var activationCount = 0;

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Builder(
          builder: (context) => AnimalTabs(
            tabs: [
              AnimalTabItem(label: AnimalLocalizations.of(context)!.today),
            ],
            selectedIndex: 0,
            onChanged: (index) {
              expect(index, 0);
              activationCount++;
            },
            scrollable: false,
          ),
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Tabs'), findsNothing);
    final englishTab = find.bySemanticsLabel('Today');
    final englishTabSemantics = find.semantics.byLabel('Today');
    expect(englishTab, findsOneWidget);
    expect(englishTabSemantics, findsOneWidget);
    expect(
      tester
          .getSemantics(englishTab)
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(englishTab)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    tester.semantics.tap(englishTabSemantics);
    await tester.pump();
    expect(activationCount, 1);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    final chineseTab = find.bySemanticsLabel('今天');
    final chineseTabSemantics = find.semantics.byLabel('今天');
    expect(chineseTab, findsOneWidget);
    expect(chineseTabSemantics, findsOneWidget);
    expect(
      tester
          .getSemantics(chineseTab)
          .getSemanticsData()
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(chineseTab)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    tester.semantics.tap(chineseTabSemantics);
    await tester.pump();
    expect(activationCount, 2);
    expect(find.text('Today'), findsNothing);
    expect(find.semantics.byLabel('Today'), findsNothing);
    semantics.dispose();
  });
}
