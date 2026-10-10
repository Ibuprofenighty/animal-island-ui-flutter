import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCarousel Semantics & A11y Tests (C11 / CAR04)', () {
    testWidgets('dots provide slide sequence semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalCarousel.uncontrolled(
              showDots: true,
              items: [
                AnimalCarouselItem(id: 'slide-0', child: Text('Page 1')),
                AnimalCarouselItem(id: 'slide-1', child: Text('Page 2')),
              ],
            ),
          ),
        ),
      );

      final dot1 = find.bySemanticsLabel('Slide 1 of 2');
      final dot2 = find.bySemanticsLabel('Slide 2 of 2');

      expect(dot1, findsOneWidget);
      expect(dot2, findsOneWidget);
    });
  });
}
