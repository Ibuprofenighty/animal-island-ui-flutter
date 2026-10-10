import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C11 carousel action and position semantics localize live', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: SizedBox(
          width: 260,
          child: AnimalCarousel.uncontrolled(
            items: [
              AnimalCarouselItem(id: 'slide-0', child: Text('Slide A')),
              AnimalCarouselItem(id: 'slide-1', child: Text('Slide B')),
            ],
            style: AnimalCarouselStyle(height: 120),
            autoPlay: false,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('Previous slide'), findsOneWidget);
    expect(find.semantics.byLabel('Next slide'), findsOneWidget);
    expect(find.semantics.byLabel('Slide 1 of 2'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('上一张幻灯片'), findsOneWidget);
    expect(find.semantics.byLabel('下一张幻灯片'), findsOneWidget);
    expect(find.semantics.byLabel('第 1 张，共 2 张'), findsOneWidget);
    expect(find.semantics.byLabel('Previous slide'), findsNothing);
    expect(find.semantics.byLabel('Next slide'), findsNothing);
    expect(find.semantics.byLabel('Slide 1 of 2'), findsNothing);
  });
}
