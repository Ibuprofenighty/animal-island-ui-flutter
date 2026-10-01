import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('AnimalTooltip keeps its caller-owned message across locales', (
    tester,
  ) async {
    final controller = LocalizationTestController(
      initialLocale: const Locale('en'),
    );

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: const Scaffold(
          body: Center(
            child: AnimalTooltip(
              message: 'Caller-owned tooltip',
              triggerMode: TooltipTriggerMode.tap,
              waitDuration: Duration.zero,
              showDuration: Duration(minutes: 1),
              child: Text('Trigger'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Trigger'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Caller-owned tooltip'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pump();
    expect(find.text('Caller-owned tooltip'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
