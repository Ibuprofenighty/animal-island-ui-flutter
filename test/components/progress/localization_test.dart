import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C24 progress semantics localize while caller formats persist', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimalProgress(
              percent: 0.4,
              animated: false,
              format: (_) => 'caller progress',
            ),
            AnimalProgress.circle(percent: 0.6, format: (_) => 'caller circle'),
          ],
        ),
      ),
    );
    expect(find.bySemanticsLabel('Progress'), findsOneWidget);
    expect(find.bySemanticsLabel('Circular progress'), findsOneWidget);
    expect(find.text('caller progress'), findsOneWidget);
    expect(find.text('caller circle'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('进度'), findsOneWidget);
    expect(find.bySemanticsLabel('圆形进度'), findsOneWidget);
    expect(find.text('caller progress'), findsOneWidget);
    expect(find.text('caller circle'), findsOneWidget);
  });
}
