import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('AnimalFooter updates its default copy with the locale', (
    tester,
  ) async {
    final controller = LocalizationTestController(
      initialLocale: const Locale('en'),
    );

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: const Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimalFooter(),
              AnimalFooter(defaultText: 'Caller footer override'),
              AnimalFooter(content: Text('Caller child content')),
            ],
          ),
        ),
      ),
    );
    expect(
      find.text('Animal Island UI • Crafted with cozy care'),
      findsOneWidget,
    );
    expect(find.text('Caller footer override'), findsOneWidget);
    expect(find.text('Caller child content'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pump();
    expect(find.text('Animal Island UI • 温暖呈现'), findsOneWidget);
    expect(find.text('Caller footer override'), findsOneWidget);
    expect(find.text('Caller child content'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
