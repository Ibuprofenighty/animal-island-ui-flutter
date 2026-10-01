import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalOverlayHost & Scoped Controller Tests (S04 / T04.04)', () {
    testWidgets(
      'AnimalOverlayHost provides scoped controller and manages entry lifecycle',
      (tester) async {
        late AnimalOverlayController controller;
        int closeCallbackCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: AnimalOverlayHost(
              child: Builder(
                builder: (context) {
                  controller = AnimalOverlayHost.of(context);
                  return const Scaffold(body: Text('Host Content'));
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(controller.activeCount, 0);

        // Show an entry
        final handle = controller.show(
          id: 'toast-1',
          onClose: () => closeCallbackCount++,
          builder: (context, h) {
            return const Positioned(
              top: 20,
              left: 20,
              child: Text('Toast 1 Message'),
            );
          },
        );

        await tester.pump();
        expect(find.text('Toast 1 Message'), findsOneWidget);
        expect(handle.isActive, isTrue);
        expect(controller.activeCount, 1);

        // Close the entry
        handle.close();
        await tester.pump();

        expect(find.text('Toast 1 Message'), findsNothing);
        expect(handle.isDisposed, isTrue);
        expect(controller.activeCount, 0);
        expect(
          closeCallbackCount,
          1,
          reason: 'onClose callback must be called exactly once',
        );
      },
    );

    testWidgets(
      'Multiple AnimalOverlayHost instances are completely isolated (F07 / F14 solution)',
      (tester) async {
        late AnimalOverlayController controllerA;
        late AnimalOverlayController controllerB;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Row(
                children: [
                  Expanded(
                    child: AnimalOverlayHost(
                      child: Builder(
                        builder: (context) {
                          controllerA = AnimalOverlayHost.of(context);
                          return const Text('App A');
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimalOverlayHost(
                      child: Builder(
                        builder: (context) {
                          controllerB = AnimalOverlayHost.of(context);
                          return const Text('App B');
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Show toast on App A with key 'notification-same-key'
        controllerA.show(
          id: 'notification-same-key',
          builder: (context, handle) => const Text('App A Active Notification'),
        );

        // Show toast on App B with the SAME key 'notification-same-key'
        controllerB.show(
          id: 'notification-same-key',
          builder: (context, handle) => const Text('App B Active Notification'),
        );

        await tester.pump();

        // Both toasts must coexist in their respective hosts without destroying each other!
        expect(find.text('App A Active Notification'), findsOneWidget);
        expect(find.text('App B Active Notification'), findsOneWidget);
        expect(controllerA.activeCount, 1);
        expect(controllerB.activeCount, 1);

        // Closing App A's toast must NOT touch App B's toast
        controllerA.close('notification-same-key');
        await tester.pump();

        expect(find.text('App A Active Notification'), findsNothing);
        expect(find.text('App B Active Notification'), findsOneWidget);
        expect(controllerA.activeCount, 0);
        expect(controllerB.activeCount, 1);
      },
    );
  });
}
