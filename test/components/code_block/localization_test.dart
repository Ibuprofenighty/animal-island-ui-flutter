import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C33 code copy labels localize and language overrides persist', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AnimalCodeBlock(code: 'print("Hello");'),
            AnimalCodeBlock(code: '{"ready": true}', language: 'json'),
          ],
        ),
      ),
    );
    expect(find.text('dart'), findsOneWidget);
    expect(find.text('json'), findsOneWidget);
    expect(find.text('Copy'), findsNWidgets(2));
    final english = AnimalLocalizations.of(
      tester.element(find.byType(AnimalCodeBlock).first),
    )!;
    final englishCopyLabel = english.codeCopySemanticLabel;
    final englishCopyNodes = find.bySemanticsLabel(englishCopyLabel);
    expect(englishCopyNodes, findsNWidgets(2));
    expect(find.semantics.byLabel(english.codeCopyLabel), findsNothing);
    final englishCopyNode = tester.getSemantics(englishCopyNodes.first);
    expect(englishCopyNode.label, englishCopyLabel);
    expect(
      englishCopyNode.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('dart'), findsOneWidget);
    expect(find.text('json'), findsOneWidget);
    expect(find.text('复制'), findsNWidgets(2));
    final chinese = AnimalLocalizations.of(
      tester.element(find.byType(AnimalCodeBlock).first),
    )!;
    final chineseCopyLabel = chinese.codeCopySemanticLabel;
    final chineseCopyNodes = find.bySemanticsLabel(chineseCopyLabel);
    expect(chineseCopyNodes, findsNWidgets(2));
    expect(find.semantics.byLabel(chinese.codeCopyLabel), findsNothing);
    final chineseCopyNode = tester.getSemantics(chineseCopyNodes.first);
    expect(chineseCopyNode.label, chineseCopyLabel);
    expect(
      chineseCopyNode.getSemanticsData().hasAction(SemanticsAction.tap),
      isTrue,
    );
  });
}
