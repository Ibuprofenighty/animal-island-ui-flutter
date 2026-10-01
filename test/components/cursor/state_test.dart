import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalCursor State Tests (S05 / C04)', () {
    testWidgets('AnimalCursor dynamically updates when type property changes', (
      tester,
    ) async {
      final typeNotifier = ValueNotifier<AnimalCursorType>(
        AnimalCursorType.defaultCursor,
      );

      await tester.pumpWidget(
        ValueListenableBuilder<AnimalCursorType>(
          valueListenable: typeNotifier,
          builder: (context, type, _) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: AnimalCursor(
                  type: type,
                  child: const Text('Dynamic Cursor Area'),
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('Dynamic Cursor Area'), findsOneWidget);

      typeNotifier.value = AnimalCursorType.pointer;
      await tester.pump();
      expect(find.text('Dynamic Cursor Area'), findsOneWidget);

      typeNotifier.value = AnimalCursorType.notAllowed;
      await tester.pump();
      expect(find.text('Dynamic Cursor Area'), findsOneWidget);
    });
  });
}
