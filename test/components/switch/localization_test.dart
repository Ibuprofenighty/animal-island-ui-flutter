import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C13 switch semantics label updates from English to Chinese', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: const AnimalSwitch(value: true, onChanged: _ignoreSwitch),
      ),
    );

    expect(find.semantics.byLabel('Switch'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('开关'), findsOneWidget);
    expect(find.semantics.byLabel('Switch'), findsNothing);
  });
}

void _ignoreSwitch(bool value) {}
