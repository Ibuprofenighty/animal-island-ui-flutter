import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('AnimalModal updates default actions on its open route', (
    tester,
  ) async {
    final controller = LocalizationTestController(
      initialLocale: const Locale('en'),
    );
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                AnimalModal.confirm(
                  context: context,
                  title: const Text('Caller title'),
                  content: const Text('Caller content'),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.bySemanticsLabel('Dismiss'), findsOneWidget);
    expect(find.bySemanticsLabel('Dialog'), findsOneWidget);

    controller.locale = const Locale('zh', 'CN');
    await tester.pumpAndSettle();
    expect(find.text('确认'), findsOneWidget);
    expect(find.bySemanticsLabel('关闭'), findsOneWidget);
    expect(find.bySemanticsLabel('对话框'), findsOneWidget);
    expect(find.text('Caller content'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
