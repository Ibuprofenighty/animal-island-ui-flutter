import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C05 card preserves localized caller content and semantics', (
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
          builder: (context) {
            final localizations = AnimalLocalizations.of(context)!;
            return AnimalCard(
              onTap: () => activationCount++,
              semanticLabel: localizations.clear,
              child: Text(localizations.today),
            );
          },
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Card'), findsNothing);
    expect(find.semantics.byLabel('Clear'), findsOneWidget);
    expect(find.semantics.byLabel('Today'), findsOneWidget);
    final englishClearWidget = find.bySemanticsLabel('Clear');
    final englishClear = find.semantics.byLabel('Clear');
    expect(
      tester
          .getSemantics(englishClearWidget)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    tester.semantics.tap(englishClear);
    await tester.pump();
    expect(activationCount, 1);
    expect(find.text('Today'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    expect(find.semantics.byLabel('清空'), findsOneWidget);
    expect(find.semantics.byLabel('今天'), findsOneWidget);
    final chineseClearWidget = find.bySemanticsLabel('清空');
    final chineseClear = find.semantics.byLabel('清空');
    expect(
      tester
          .getSemantics(chineseClearWidget)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    tester.semantics.tap(chineseClear);
    await tester.pump();
    expect(activationCount, 2);
    expect(find.text('今天'), findsOneWidget);
    expect(find.semantics.byLabel('Clear'), findsNothing);
    expect(find.text('Today'), findsNothing);
    semantics.dispose();
  });
}
