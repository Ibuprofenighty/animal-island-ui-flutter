import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalSwitch Tests (C13 / SW01-SW03)', () {
    testWidgets('SW01: Tap toggles switch and invokes onChanged', (
      tester,
    ) async {
      bool value = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalSwitch(value: value, onChanged: (val) => value = val),
          ),
        ),
      );

      await tester.tap(find.byType(AnimalSwitch));
      await tester.pumpAndSettle();

      expect(value, isTrue);
    });

    testWidgets('SW01: Disabled or loading switch ignores taps', (
      tester,
    ) async {
      int callCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Column(
              children: [
                AnimalSwitch(
                  value: false,
                  disabled: true,
                  onChanged: (val) => callCount++,
                ),
                AnimalSwitch(
                  value: false,
                  loading: true,
                  onChanged: (val) => callCount++,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AnimalSwitch).first);
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);

      await tester.tap(find.byType(AnimalSwitch).last);
      await tester.pump(const Duration(milliseconds: 50));
      expect(callCount, 0);
    });

    testWidgets('SW02: Renders with checked and unchecked children', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalSwitch(
              value: true,
              checkedChildren: const Text('ON'),
              unCheckedChildren: const Text('OFF'),
              onChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('ON'), findsOneWidget);
    });

    testWidgets('SW03: Semantics reports toggle status accurately', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(body: AnimalSwitch(value: true, onChanged: (_) {})),
        ),
      );

      expect(find.bySemanticsLabel('Switch'), findsOneWidget);

      handle.dispose();
    });
  });
}
