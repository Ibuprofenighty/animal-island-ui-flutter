import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTag S12 Contract & Behavior Tests (TAG01-TAG03)', () {
    testWidgets(
      'TAG01: Main tag tap and close button are completely decoupled without event leakage',
      (tester) async {
        int tapCount = 0;
        int closeCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTag(
                onTap: () => tapCount++,
                onClose: () => closeCount++,
                child: const Text('Peach'),
              ),
            ),
          ),
        );

        expect(find.text('Peach'), findsOneWidget);
        expect(find.bySemanticsLabel('Remove tag'), findsOneWidget);

        // Tap main tag label
        await tester.tap(find.text('Peach'));
        await tester.pump();
        expect(tapCount, equals(1));
        expect(closeCount, equals(0));

        // Tap close button
        await tester.tap(find.bySemanticsLabel('Remove tag'));
        await tester.pump();
        expect(tapCount, equals(1));
        expect(closeCount, equals(1));
      },
    );

    testWidgets(
      'TAG02: Disabled state locks both actions and prevents callbacks',
      (tester) async {
        int tapCount = 0;
        int closeCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTag(
                disabled: true,
                onTap: () => tapCount++,
                onClose: () => closeCount++,
                child: const Text('Locked Tag'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Locked Tag'), warnIfMissed: false);
        await tester.pump();
        expect(tapCount, equals(0));
        expect(closeCount, equals(0));
      },
    );

    testWidgets(
      'TAG02: Static tag without onTap does NOT impersonate a button',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalTag(child: Text('Pure Static Label'))),
          ),
        );

        final semanticsWidgets = tester.widgetList<Semantics>(
          find.ancestor(
            of: find.text('Pure Static Label'),
            matching: find.byType(Semantics),
          ),
        );
        expect(
          semanticsWidgets.any((s) => s.properties.button == true),
          isFalse,
        );
      },
    );

    testWidgets(
      'TAG03: Renders all sizes and status variants without assertion errors',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalTag(
                    variant: AnimalTagVariant.primary,
                    size: AnimalTagSize.small,
                    child: Text('Small Primary'),
                  ),
                  AnimalTag(
                    variant: AnimalTagVariant.success,
                    size: AnimalTagSize.middle,
                    child: Text('Middle Success'),
                  ),
                  AnimalTag(
                    variant: AnimalTagVariant.warning,
                    size: AnimalTagSize.large,
                    child: Text('Large Warning'),
                  ),
                  AnimalTag(
                    variant: AnimalTagVariant.error,
                    child: Text('Error Tag'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Small Primary'), findsOneWidget);
        expect(find.text('Middle Success'), findsOneWidget);
        expect(find.text('Large Warning'), findsOneWidget);
        expect(find.text('Error Tag'), findsOneWidget);
      },
    );
  });
}
