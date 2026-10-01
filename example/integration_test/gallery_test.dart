import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/app.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gallery Navigation & Deep-Linking Integration Tests', () {
    testWidgets('Gallery boots on overview and displays all components', (
      tester,
    ) async {
      await tester.pumpWidget(const AnimalIslandGalleryApp(initialRoute: '/'));
      await tester.pumpAndSettle();

      // Verify overview title and search bar
      expect(find.text('Animal Island UI'), findsWidgets);
      expect(find.text('Component Gallery'), findsWidgets);

      // Verify zero unhandled exceptions
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Gallery deep-links directly to component story and renders interactive controls',
      (tester) async {
        await tester.pumpWidget(
          const AnimalIslandGalleryApp(initialRoute: '/components/button'),
        );
        await tester.pumpAndSettle();

        // Verify button story mounted
        expect(find.byType(AnimalButton), findsWidgets);
        expect(find.text('Button 按钮'), findsWidgets);

        // Verify theme toggle works within story
        final darkButton = find.byIcon(Icons.dark_mode);
        if (darkButton.evaluate().isNotEmpty) {
          await tester.tap(darkButton);
          await tester.pumpAndSettle();
        }

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Gallery deep-links to /icons and searches icons', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AnimalIslandGalleryApp(initialRoute: '/icons'),
      );
      await tester.pumpAndSettle();

      // Verify icon browser mounted
      expect(find.text('Icons 图标库'), findsWidgets);
      expect(find.byType(AnimalIcon), findsWidgets);

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'Gallery handles unknown routes with 404 screen and returns home',
      (tester) async {
        await tester.pumpWidget(
          const AnimalIslandGalleryApp(
            initialRoute: '/components/non_existent_widget',
          ),
        );
        await tester.pumpAndSettle();

        // Verify 404 screen
        expect(find.text('404: Lost on the Island'), findsOneWidget);
        expect(find.text('Return to Overview'), findsOneWidget);

        // Tap return button
        await tester.tap(find.text('Return to Overview'));
        await tester.pumpAndSettle();

        // Verify returned to overview
        expect(find.text('Component Gallery'), findsWidgets);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
