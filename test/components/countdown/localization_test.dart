import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C28 countdown labels and units follow the mounted locale', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Scaffold(
          body: AnimalCountdown(
            remaining: Duration(days: 1, hours: 2, minutes: 3, seconds: 4),
            format: 'DD:HH:mm:ss',
            prefix: Semantics(
              label: 'Caller prefix',
              child: Text('Caller widget content'),
            ),
          ),
        ),
      ),
    );
    const englishLabel =
        '93784 seconds remaining\nCaller prefix\nCaller widget content\n'
        '01\nDAYS\n:\n02\nHOURS\n:\n03\nMINS\n:\n04\nSECS';
    final englishNode = tester.getSemantics(
      find.bySemanticsLabel(englishLabel),
    );
    expect(englishNode.label, englishLabel);
    expect(find.text('Caller widget content'), findsOneWidget);
    expect(find.text('DAYS'), findsOneWidget);
    expect(find.text('HOURS'), findsOneWidget);
    expect(find.text('MINS'), findsOneWidget);
    expect(find.text('SECS'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    const chineseLabel =
        '剩余 93784 秒\nCaller prefix\nCaller widget content\n'
        '01\n天\n:\n02\n时\n:\n03\n分\n:\n04\n秒';
    final chineseNode = tester.getSemantics(
      find.bySemanticsLabel(chineseLabel),
    );
    expect(chineseNode.label, chineseLabel);
    expect(find.text('Caller widget content'), findsOneWidget);
    expect(find.text('天'), findsOneWidget);
    expect(find.text('时'), findsOneWidget);
    expect(find.text('分'), findsOneWidget);
    expect(find.text('秒'), findsOneWidget);
  });
}
