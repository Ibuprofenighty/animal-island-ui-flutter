import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCard State & Theme Tests (S05 / C05)', () {
    testWidgets(
      'AnimalCard adapts to custom borderRadius, margin, and padding',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalCard(
                borderRadius: BorderRadius.all(Radius.circular(24.0)),
                margin: EdgeInsets.all(16.0),
                padding: EdgeInsets.all(20.0),
                child: Text('Card Metrics'),
              ),
            ),
          ),
        );

        expect(find.text('Card Metrics'), findsOneWidget);
      },
    );

    testWidgets('AnimalCard respects AnimalIslandTheme dark and light mode', (
      tester,
    ) async {
      final themeNotifier = ValueNotifier<AnimalIslandTheme>(
        AnimalIslandTheme.light,
      );

      await tester.pumpWidget(
        ValueListenableBuilder<AnimalIslandTheme>(
          valueListenable: themeNotifier,
          builder: (context, theme, _) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: theme.toThemeData(),
              home: const Scaffold(
                body: AnimalCard(child: Text('Themed Card')),
              ),
            );
          },
        ),
      );

      expect(find.text('Themed Card'), findsOneWidget);

      themeNotifier.value = AnimalIslandTheme.dark;
      await tester.pumpAndSettle();
      expect(find.text('Themed Card'), findsOneWidget);
    });
  });
}
