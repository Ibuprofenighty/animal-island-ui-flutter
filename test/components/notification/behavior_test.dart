import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalNotification RED Tests (F07 / NOT02)', () {
    testWidgets(
      'two isolated apps or hosts must not share single static notification queue',
      (tester) async {
        // Each app has its own AnimalOverlayHost, so each keeps its own queue:
        // the same placement and key in App B must not reach App A.
        BuildContext? ctxA;
        BuildContext? ctxB;

        Widget app(String label, void Function(BuildContext) capture) =>
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,
              theme: AnimalIslandTheme.light.toThemeData(),
              home: AnimalOverlayHost(
                child: Scaffold(
                  body: Builder(
                    builder: (context) {
                      capture(context);
                      return Text(label);
                    },
                  ),
                ),
              ),
            );

        await tester.pumpWidget(
          Row(
            textDirection: TextDirection.ltr,
            children: [
              Expanded(child: app('App A', (c) => ctxA = c)),
              Expanded(child: app('App B', (c) => ctxB = c)),
            ],
          ),
        );

        final AnimalNotificationHandle inA = AnimalNotification.open(
          ctxA!,
          key: 'shared_key',
          message: const Text('Notification for A'),
        );
        await tester.pump();

        final AnimalNotificationHandle inB = AnimalNotification.open(
          ctxB!,
          key: 'shared_key',
          message: const Text('Notification for B'),
        );
        await tester.pump();

        expect(
          find.text('Notification for A'),
          findsOneWidget,
          reason: 'App A should still show Notification for A',
        );
        expect(
          find.text('Notification for B'),
          findsOneWidget,
          reason: 'App B should show Notification for B in its isolated host',
        );
        expect(identical(inA, inB), isFalse);

        // Dismissing in host A leaves host B untouched.
        AnimalNotification.closeAll(ctxA!);
        await tester.pump();
        expect(find.text('Notification for A'), findsNothing);
        expect(find.text('Notification for B'), findsOneWidget);
        expect(inB.status, AnimalNotificationStatus.active);

        // Removing both hosts closes the remaining occurrence and its timer.
        await tester.pumpWidget(const SizedBox.shrink());
        expect(inB.status, AnimalNotificationStatus.closed);
      },
    );
  });
}
