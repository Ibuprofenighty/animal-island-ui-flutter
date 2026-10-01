import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalFooter Behavior Tests (S05 / C36 / FOT01-FOT03)', () {
    testWidgets(
      'FOT01: renders sea and tree variants, seamless flag, and localized default / custom content',
      (tester) async {
        // 1. Sea variant with default localized content
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalFooter(type: AnimalFooterType.sea)),
          ),
        );
        expect(find.byType(AnimalFooter), findsOneWidget);

        // 2. Tree variant with custom content
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalFooter(
                type: AnimalFooterType.tree,
                content: Text('Custom Island Footer 2026'),
              ),
            ),
          ),
        );
        expect(find.text('Custom Island Footer 2026'), findsOneWidget);

        // 3. Seamless flag
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalFooter(
                seamless: true,
                content: Text('Seamless Footer'),
              ),
            ),
          ),
        );
        expect(find.text('Seamless Footer'), findsOneWidget);
      },
    );

    testWidgets(
      'FOT02: long text and narrow width do not cause layout overflow',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                width: 150,
                child: AnimalFooter(
                  content: const Text(
                    'A very long island community text that wraps across multiple lines safely',
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(AnimalFooter), findsOneWidget);
      },
    );

    testWidgets(
      'FOT03: decorative wave/tree graphics do not create focusable semantic nodes',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalFooter(content: Text('Accessible Island Footer')),
            ),
          ),
        );

        final handle = tester.ensureSemantics();
        expect(
          find.bySemanticsLabel('Accessible Island Footer'),
          findsOneWidget,
        );
        final footerFinder = find.byType(AnimalFooter);
        final semantics = tester.getSemantics(footerFinder);
        expect(semantics.flagsCollection.isButton, isFalse);
        handle.dispose();
      },
    );
  });
}
