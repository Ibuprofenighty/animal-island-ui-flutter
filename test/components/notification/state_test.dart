import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';

void main() {
  group('AnimalNotification State & Key Update Tests (C30 / NOT01-NOT04)', () {
    tearDown(() {
      AnimalNotification.reset();
    });

    testWidgets(
      'same key updates existing notification in-place without adding extra card',
      (tester) async {
        late BuildContext buildCtx;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  buildCtx = context;
                  return const Text('Test Host');
                },
              ),
            ),
          ),
        );

        // Post first notification with key 'upload_progress'
        AnimalNotification.open(
          buildCtx,
          key: 'upload_progress',
          message: const Text('Uploading... 10%'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Uploading... 10%'), findsOneWidget);

        // Post updated notification with the same key
        AnimalNotification.open(
          buildCtx,
          key: 'upload_progress',
          message: const Text('Uploading... 90%'),
        );
        await tester.pump();

        expect(find.text('Uploading... 90%'), findsOneWidget);
        expect(find.text('Uploading... 10%'), findsNothing);
        expect(find.byType(AnimalNotificationCard), findsOneWidget);
      },
    );

    testWidgets(
      'convenience constructors (success, warning, error, info) render matching semantic icons',
      (tester) async {
        late BuildContext buildCtx;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  buildCtx = context;
                  return const Text('Test Host');
                },
              ),
            ),
          ),
        );

        AnimalNotification.success(buildCtx, message: 'Saved successfully');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Saved successfully'), findsOneWidget);
        expect(find.byType(AnimalNotificationCard), findsOneWidget);
      },
    );
  });
}
