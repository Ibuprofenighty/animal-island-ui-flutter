import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalNotification RED Tests (F07 / NOT02)', () {
    testWidgets(
      'two isolated apps or hosts must not share single static notification queue',
      (tester) async {
        // Defect F07: AnimalNotification uses static Map<_activeQueues> and Map<_activeEntries>,
        // meaning notifications opened in App A pollute and interact with App B!
        BuildContext? ctxA;
        BuildContext? ctxB;

        await tester.pumpWidget(
          Row(
            textDirection: TextDirection.ltr,
            children: [
              Expanded(
                child: MaterialApp(
                  localizationsDelegates:
                      AnimalLocalizations.localizationsDelegates,
                  supportedLocales: AnimalLocalizations.supportedLocales,

                  theme: AnimalIslandTheme.light.toThemeData(),
                  home: Scaffold(
                    body: Builder(
                      builder: (context) {
                        ctxA = context;
                        return const Text('App A');
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MaterialApp(
                  localizationsDelegates:
                      AnimalLocalizations.localizationsDelegates,
                  supportedLocales: AnimalLocalizations.supportedLocales,

                  theme: AnimalIslandTheme.light.toThemeData(),
                  home: Scaffold(
                    body: Builder(
                      builder: (context) {
                        ctxB = context;
                        return const Text('App B');
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

        // Open in App A
        AnimalNotification.open(
          ctxA!,
          key: 'shared_key',
          message: const Text('Notification for A'),
        );
        await tester.pump();

        // Open in App B with same placement & key
        AnimalNotification.open(
          ctxB!,
          key: 'shared_key',
          message: const Text('Notification for B'),
        );
        await tester.pump();

        // In a multi-host architecture, App A has 1 notification and App B has 1 notification.
        // Under old static architecture, the second open overwrote or shared the exact same queue entry!
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

        // Cleanup
        AnimalNotification.reset();
      },
    );
  });
}
