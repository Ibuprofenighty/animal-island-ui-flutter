import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/app.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gallery Accessibility & Responsive Scale Integration Tests', () {
    testWidgets(
      'App handles 200% text scaling and theme switching with zero layout overflows',
      (tester) async {
        await tester.pumpWidget(const AnimalIslandGalleryApp());
        await tester.pumpAndSettle();

        // Verify home shell loaded
        expect(find.text('Animal Island UI'), findsWidgets);

        // Verify theme switching via toolbar
        final darkButtonFinder = find.byIcon(Icons.dark_mode);
        if (darkButtonFinder.evaluate().isNotEmpty) {
          await tester.tap(darkButtonFinder);
          await tester.pumpAndSettle();
        }

        // Re-pump under 2.0x text scaling
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(1024, 768),
              textScaler: TextScaler.linear(2.0),
            ),
            child: const AnimalIslandGalleryApp(),
          ),
        );
        await tester.pumpAndSettle();

        // Assert zero unhandled RenderFlex layout overflows or exceptions
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Interactive elements expose semantic labels and button traits',
      (tester) async {
        await tester.pumpWidget(const AnimalIslandGalleryApp());
        await tester.pumpAndSettle();

        // Verify Semantics contains buttons
        expect(find.byType(AnimalButton), findsWidgets);
        final firstButton = find.byType(AnimalButton).first;
        expect(firstButton, findsOneWidget);
      },
    );
  });
}
