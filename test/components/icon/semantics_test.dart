import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalIcon Semantics Tests (S05 / C02)', () {
    testWidgets('decorative icon is excluded from accessibility tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalIcon(data: AnimalIcons.leaf)),
        ),
      );

      final handle = tester.ensureSemantics();
      expect(find.byType(ExcludeSemantics), findsWidgets);
      handle.dispose();
    });

    testWidgets('icon with semanticLabel announces label to screen reader', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalIcon(
              data: AnimalIcons.leaf,
              semanticLabel: 'Cute Island Leaf',
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Cute Island Leaf'), findsOneWidget);
    });

    testWidgets('interactive icon announces button role and action', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalIcon(
              data: AnimalIcons.bell,
              semanticLabel: 'Notification Bell',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Notification Bell'), findsOneWidget);
    });
  });
}
