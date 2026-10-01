import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C29 time label and clock format follow the mounted locale', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    final time = DateTime(2026, 5, 10, 13, 14, 15);
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: AnimalTime(time: time),
      ),
    );
    expect(find.bySemanticsLabel('Current time'), findsOneWidget);
    expect(find.text(DateFormat.Hms('en').format(time)), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('当前时间'), findsOneWidget);
    expect(find.text(DateFormat.Hms('zh').format(time)), findsOneWidget);
  });
}
