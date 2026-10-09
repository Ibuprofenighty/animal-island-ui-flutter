import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalSkeleton State & Theme Tests (C26 / SKL01-SKL04)', () {
    testWidgets(
      'SKL01: loading false renders child directly without skeleton chrome',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalSkeleton(
                loading: false,
                child: Text('Content Loaded Successfully'),
              ),
            ),
          ),
        );

        expect(find.text('Content Loaded Successfully'), findsOneWidget);
      },
    );

    testWidgets(
      'SKL02: static mode (active == false) renders a plain block without a shimmer',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalSkeleton(
                loading: true,
                active: false,
                variant: AnimalSkeletonVariant.rect,
              ),
            ),
          ),
        );

        // A static skeleton builds no shimmer animation.
        expect(
          find.descendant(
            of: find.byType(AnimalSkeleton),
            matching: find.byType(AnimatedBuilder),
          ),
          findsNothing,
        );
        expect(find.byType(Container), findsOneWidget);
      },
    );

    testWidgets('SKL03: presets render expected geometries', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalSkeleton.button(),
                AnimalSkeleton.input(),
                AnimalSkeleton.avatar(),
                AnimalSkeleton.paragraph(rows: 2),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(AnimalSkeleton), findsNWidgets(4));
    });

    testWidgets('SKL04: adapts to dark theme governed surfaces', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.dark.toThemeData(),
          home: Scaffold(
            body: AnimalSkeleton(
              active: false,
              variant: AnimalSkeletonVariant.rect,
            ),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimalSkeleton),
          matching: find.byType(Container),
        ),
      );
      final boxDeco = container.decoration as BoxDecoration;
      expect(boxDeco.color, AnimalIslandTheme.dark.colors.surfaceHeader);
    });
  });
}
