import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C04 cursor adds no copy and preserves localized child text', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: AnimalCursor(
          type: AnimalCursorType.pointer,
          child: Builder(
            builder: (context) => Text(AnimalLocalizations.of(context)!.today),
          ),
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Cursor'), findsNothing);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });
}
