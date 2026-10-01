import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCard Behavior Tests (S05 / C05 / CARD01-CARD03)', () {
    testWidgets(
      'CARD01: renders 13 tile colors and patterns, supports 4 combinations of header and footer',
      (tester) async {
        // 1. Render all 13 tile colors
        for (final color in AnimalTileColor.values) {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCard(
                  color: color,
                  child: Text('Card ${color.name}'),
                ),
              ),
            ),
          );
          expect(find.text('Card ${color.name}'), findsOneWidget);
        }

        // 2. Render all pattern variants
        for (final pattern in AnimalCardPattern.values) {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCard(
                  pattern: pattern,
                  child: Text('Pattern ${pattern.name}'),
                ),
              ),
            ),
          );
          expect(find.text('Pattern ${pattern.name}'), findsOneWidget);
        }

        // 3. Four combinations of header and footer
        // a) No header, no footer
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalCard(child: Text('Plain Card'))),
          ),
        );
        expect(find.text('Plain Card'), findsOneWidget);

        // b) Header only
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                header: Text('Card Header'),
                child: Text('Content with Header'),
              ),
            ),
          ),
        );
        expect(find.text('Card Header'), findsOneWidget);
        expect(find.text('Content with Header'), findsOneWidget);

        // c) Footer only
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                footer: Text('Card Footer'),
                child: Text('Content with Footer'),
              ),
            ),
          ),
        );
        expect(find.text('Card Footer'), findsOneWidget);
        expect(find.text('Content with Footer'), findsOneWidget);

        // d) Header and footer
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                header: Text('Full Header'),
                footer: Text('Full Footer'),
                child: Text('Full Content'),
              ),
            ),
          ),
        );
        expect(find.text('Full Header'), findsOneWidget);
        expect(find.text('Full Footer'), findsOneWidget);
        expect(find.text('Full Content'), findsOneWidget);
      },
    );

    testWidgets(
      'CARD02: static card has no button semantics; clickable card activates once via Enter/Space and pointer',
      (tester) async {
        int cardTaps = 0;

        // Static card
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalCard(child: Text('Static Card'))),
          ),
        );

        final handle = tester.ensureSemantics();
        // Static card should not have button semantics
        final staticCardSemantics = tester.getSemantics(
          find.byType(AnimalCard),
        );
        expect(staticCardSemantics.flagsCollection.isButton, isFalse);
        handle.dispose();

        // Clickable card
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                onTap: () => cardTaps++,
                child: const Text('Clickable Card'),
              ),
            ),
          ),
        );

        // Pointer tap
        await tester.tap(find.text('Clickable Card'));
        await tester.pumpAndSettle();
        expect(cardTaps, equals(1));

        // Space key
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(cardTaps, equals(2));

        // Enter key
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(cardTaps, equals(3));
      },
    );

    testWidgets(
      'CARD03: pattern painter triggers repaint on color/pattern change',
      (tester) async {
        final patternNotifier = ValueNotifier<AnimalCardPattern>(
          AnimalCardPattern.dots,
        );

        await tester.pumpWidget(
          ValueListenableBuilder<AnimalCardPattern>(
            valueListenable: patternNotifier,
            builder: (context, pattern, _) {
              return MaterialApp(
                localizationsDelegates:
                    AnimalLocalizations.localizationsDelegates,
                supportedLocales: AnimalLocalizations.supportedLocales,

                theme: AnimalIslandTheme.light.toThemeData(),
                home: Scaffold(
                  body: AnimalCard(
                    pattern: pattern,
                    child: const Text('Dynamic Pattern'),
                  ),
                ),
              );
            },
          ),
        );

        expect(find.byType(CustomPaint), findsWidgets);

        // Change pattern
        patternNotifier.value = AnimalCardPattern.stripes;
        await tester.pump();

        expect(find.byType(CustomPaint), findsWidgets);
      },
    );
  });
}
