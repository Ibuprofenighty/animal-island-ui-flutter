import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C03 typewriter announces caller text across locale changes', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Builder(
          builder: (context) => AnimalTypewriter(
            text: AnimalLocalizations.of(context)!.today,
            speed: const Duration(milliseconds: 1),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 5));

    expect(find.semantics.byLabel('Today'), findsOneWidget);
    expect(find.text('Typewriter'), findsNothing);

    controller.locale = const Locale('zh');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 5));

    expect(find.semantics.byLabel('今天'), findsOneWidget);
    expect(find.semantics.byLabel('Today'), findsNothing);
  });
}
