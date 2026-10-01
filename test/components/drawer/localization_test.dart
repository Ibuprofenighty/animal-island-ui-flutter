import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('AnimalDrawer updates route and close semantics while open', (
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
                AnimalDrawer.show<void>(
                  context: context,
                  title: const Text('Caller title'),
                  child: const Text('Caller content'),
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
    expect(find.bySemanticsLabel('Drawer'), findsOneWidget);
    expect(find.bySemanticsLabel('Close drawer'), findsOneWidget);

    controller.locale = const Locale('zh', 'TW');
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('抽屉'), findsOneWidget);
    expect(find.bySemanticsLabel('关闭抽屉'), findsOneWidget);
    expect(find.bySemanticsLabel('关闭'), findsOneWidget);
    expect(find.text('Caller content'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('关闭抽屉'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
