import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTitle Behavior Tests (S05 / C06 / TIT01-TIT03)', () {
    testWidgets(
      'TIT01: renders small, middle, and large sizes with swallowtail and folded corners',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Column(
                children: [
                  AnimalTitle(
                    size: AnimalTitleSize.small,
                    child: Text('Small Title'),
                  ),
                  AnimalTitle(
                    size: AnimalTitleSize.middle,
                    child: Text('Middle Title'),
                  ),
                  AnimalTitle(
                    size: AnimalTitleSize.large,
                    child: Text('Large Title'),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Small Title'), findsOneWidget);
        expect(find.text('Middle Title'), findsOneWidget);
        expect(find.text('Large Title'), findsOneWidget);

        final smallBox = tester.renderObject<RenderBox>(
          find.text('Small Title'),
        );
        final largeBox = tester.renderObject<RenderBox>(
          find.text('Large Title'),
        );
        expect(largeBox.size.height, greaterThan(smallBox.size.height));
      },
    );

    testWidgets('TIT02: announces heading semantics with single child label', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTitle(child: Text('Island Daily Announcements')),
          ),
        ),
      );

      final handle = tester.ensureSemantics();
      final headingFinder = find.bySemanticsLabel('Island Daily Announcements');
      expect(headingFinder, findsOneWidget);
      final semantics = tester.getSemantics(headingFinder);
      expect(semantics.flagsCollection.isHeader, isTrue);
      handle.dispose();
    });

    testWidgets(
      'TIT03: narrow constraints do not cause negative width or layout crash',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                width: 80.0,
                child: AnimalTitle(child: Text('Narrow')),
              ),
            ),
          ),
        );

        expect(find.text('Narrow'), findsOneWidget);
        final titleBox = tester.renderObject<RenderBox>(
          find.byType(AnimalTitle),
        );
        expect(titleBox.size.width, greaterThanOrEqualTo(80.0));
      },
    );
  });
}
