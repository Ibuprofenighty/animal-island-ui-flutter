import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C07 divider adds no copy and keeps caller child localized', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Builder(
          builder: (context) => AnimalDivider(
            child: Text(AnimalLocalizations.of(context)!.today),
          ),
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Divider'), findsNothing);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
  });
}
