import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext buildCtx;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: AnimalIslandTheme.light.toThemeData(),
      home: AnimalOverlayHost(
        child: Scaffold(
          body: Builder(
            builder: (context) {
              buildCtx = context;
              return const Text('Test Host');
            },
          ),
        ),
      ),
    ),
  );
  return buildCtx;
}

void main() {
  group('AnimalNotification State & Key Update Tests (C30 / NOT01-NOT04)', () {
    testWidgets(
      'same key updates existing notification in-place without adding extra card',
      (tester) async {
        final BuildContext buildCtx = await _pumpHost(tester);

        final AnimalNotificationHandle first = AnimalNotification.open(
          buildCtx,
          key: 'upload_progress',
          message: const Text('Uploading... 10%'),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Uploading... 10%'), findsOneWidget);

        final AnimalNotificationHandle second = AnimalNotification.open(
          buildCtx,
          key: 'upload_progress',
          message: const Text('Uploading... 90%'),
        );
        await tester.pump();

        expect(identical(first, second), isTrue);
        expect(find.text('Uploading... 90%'), findsOneWidget);
        expect(find.text('Uploading... 10%'), findsNothing);
        expect(find.byType(AnimalNotificationCard), findsOneWidget);

        await tester.pumpWidget(const SizedBox.shrink());
        expect(first.status, AnimalNotificationStatus.closed);
      },
    );

    testWidgets(
      'convenience constructors (success, warning, error, info) render matching semantic icons',
      (tester) async {
        final BuildContext buildCtx = await _pumpHost(tester);

        final List<(AnimalNotificationHandle, String, AnimalIconData)> shown = [
          (
            AnimalNotification.success(buildCtx, message: 'Saved successfully'),
            'Saved successfully',
            AnimalIcons.check,
          ),
          (
            AnimalNotification.warning(buildCtx, message: 'Storm coming'),
            'Storm coming',
            AnimalIcons.bell,
          ),
          (
            AnimalNotification.error(buildCtx, message: 'Upload failed'),
            'Upload failed',
            AnimalIcons.close,
          ),
        ];
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.byType(AnimalNotificationCard), findsNWidgets(3));
        for (final (handle, text, icon) in shown) {
          expect(handle.status, AnimalNotificationStatus.active);
          final Finder card = find.ancestor(
            of: find.text(text),
            matching: find.byType(AnimalNotificationCard),
          );
          final AnimalIcon typeIcon = tester.widget<AnimalIcon>(
            find.descendant(of: card, matching: find.byType(AnimalIcon)).first,
          );
          expect(typeIcon.data, icon);
        }

        final AnimalNotificationHandle info = AnimalNotification.info(
          buildCtx,
          message: 'Island news',
        );
        expect(info.status, AnimalNotificationStatus.waiting);
        AnimalNotification.closeAll(buildCtx);
        await tester.pump();
        expect(find.byType(AnimalNotificationCard), findsNothing);
      },
    );
  });
}
