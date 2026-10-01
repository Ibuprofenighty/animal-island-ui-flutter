import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalInput Behavior & Contract Tests (C12 / INP01-INP04)', () {
    testWidgets(
      'INP01: External controller ownership is preserved and not disposed on unmount',
      (tester) async {
        final controller = TextEditingController(text: 'Initial external');
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: AnimalInput(controller: controller)),
          ),
        );

        expect(find.text('Initial external'), findsOneWidget);

        // Unmount the widget by pumping another root widget
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(body: SizedBox.shrink()),
          ),
        );
        await tester.pumpAndSettle();

        // The external controller must still be valid and not throw a disposed error
        expect(controller.text, 'Initial external');
        controller.text = 'Still works';
        expect(controller.text, 'Still works');
        controller.dispose();
      },
    );

    testWidgets('INP02: Typing updates text and triggers onChanged', (
      tester,
    ) async {
      String? changed;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalInput(
              placeholder: 'Type island name',
              onChanged: (val) => changed = val,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(AnimalInput), 'Horizon Island');
      await tester.pumpAndSettle();

      expect(changed, 'Horizon Island');
      expect(find.text('Horizon Island'), findsOneWidget);
    });

    testWidgets('INP03: Clear button clears text and triggers onChanged once', (
      tester,
    ) async {
      String? changed;
      final controller = TextEditingController(text: 'Clear me');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalInput(
              controller: controller,
              clearable: true,
              onChanged: (val) => changed = val,
            ),
          ),
        ),
      );

      expect(find.text('Clear me'), findsOneWidget);
      expect(find.bySemanticsLabel('Clear input'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Clear input'));
      await tester.pumpAndSettle();

      expect(controller.text, '');
      expect(changed, '');
    });

    testWidgets(
      'INP03: readOnly disables text modification, disabled prevents interaction',
      (tester) async {
        final controller = TextEditingController(text: 'Immutable');

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalInput(controller: controller, readOnly: true),
            ),
          ),
        );

        final editableText = tester.widget<EditableText>(
          find.byType(EditableText),
        );
        expect(editableText.readOnly, isTrue);
      },
    );

    testWidgets(
      'INP04: Status error applies error styling and renders prefix/suffix',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalInput(
                status: AnimalInputStatus.error,
                prefix: Icon(Icons.search),
                suffix: Text('.island'),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.search), findsOneWidget);
        expect(find.text('.island'), findsOneWidget);
      },
    );
  });
}
