import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCarousel State & Boundary Tests (C11 / CAR01)', () {
    testWidgets('empty items render safely without RangeError', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalCarousel(items: [])),
        ),
      );

      expect(find.byType(AnimalCarousel), findsOneWidget);
    });

    testWidgets('single item hides arrows and dots', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalCarousel(items: [Text('Single Page')])),
        ),
      );

      expect(find.text('Single Page'), findsOneWidget);
      expect(find.text('Previous slide'), findsNothing);
      expect(find.text('Next slide'), findsNothing);
    });
  });
}
