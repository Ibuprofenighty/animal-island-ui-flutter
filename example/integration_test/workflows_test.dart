import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:example/app.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Gallery Production Recipe Workflows Integration Tests', () {
    testWidgets(
      'Recipe 1: Form submission, validation error, and reset workflow',
      (tester) async {
        await tester.pumpWidget(
          const AnimalIslandGalleryApp(initialRoute: '/recipes/form'),
        );
        await tester.pumpAndSettle();

        // Verify form recipe is mounted
        expect(
          find.text('Recipe 1: Enterprise Registration Workflow'),
          findsOneWidget,
        );
        expect(find.text('Submit Application'), findsOneWidget);

        // Tap submit with empty form to trigger validation error
        await tester.tap(find.text('Submit Application'));
        await tester.pumpAndSettle();

        // Verify validation failure message
        expect(find.textContaining('Validation failed'), findsOneWidget);

        // Tap Reset Form
        expect(find.text('Reset Form'), findsOneWidget);
        await tester.tap(find.text('Reset Form'));
        await tester.pumpAndSettle();

        // Verify error message is cleared
        expect(find.textContaining('Validation failed'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Recipe 2: Overlay orchestration with notifications, modal dialogue, and drawer',
      (tester) async {
        await tester.pumpWidget(
          const AnimalIslandGalleryApp(initialRoute: '/recipes/overlay'),
        );
        await tester.pumpAndSettle();

        // Verify overlay recipe mounted
        expect(
          find.text('Recipe 2: Island Overlay & Feedback Orchestration'),
          findsOneWidget,
        );

        // Trigger notification
        final noticeButton = find.text('Success Notice');
        expect(noticeButton, findsOneWidget);
        await tester.tap(noticeButton);
        await tester.pumpAndSettle();

        // Verify notification appeared in overlay
        expect(find.textContaining('Island Broadcast #1'), findsOneWidget);

        // Trigger Modal Dialogue
        final modalButton = find.text('Island Mayor Dialogue');
        expect(modalButton, findsOneWidget);
        await tester.tap(modalButton);
        await tester.pumpAndSettle();

        // Verify modal is visible
        expect(find.text('Island Mayor Dialogue'), findsWidgets);
        expect(find.text('Reserve Chair'), findsOneWidget);

        // Confirm modal dialogue
        await tester.tap(find.text('Reserve Chair'));
        await tester.pumpAndSettle();

        // Verify status updated from modal callback
        expect(find.textContaining('successfully reserved'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Recipe 3: Virtual table browsing and pagination workflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const AnimalIslandGalleryApp(initialRoute: '/recipes/data-table'),
      );
      await tester.pumpAndSettle();

      // Verify table recipe mounted
      expect(
        find.text('Recipe 3: Virtual Table, Pagination & Media Gallery'),
        findsOneWidget,
      );
      expect(find.text('Island Item'), findsOneWidget);
      expect(find.text('Bells Value'), findsOneWidget);

      // Verify pagination renders
      expect(find.byType(AnimalPagination), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
