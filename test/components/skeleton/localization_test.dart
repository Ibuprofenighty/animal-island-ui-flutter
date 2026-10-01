import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C26 skeleton loading semantics follow the mounted locale', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: const AnimalSkeleton(active: false),
      ),
    );
    expect(find.bySemanticsLabel('Loading...'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('加载中...'), findsOneWidget);
  });
}
