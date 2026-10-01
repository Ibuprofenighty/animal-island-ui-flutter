import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTooltip RED Tests (F04 / TIP01)', () {
    testWidgets(
      'title mode does not trigger assertion crash in Flutter Tooltip',
      (tester) async {
        // When title is non-null, old AnimalTooltip passes both message: "" and richMessage: TextSpan,
        // which violates Flutter's Tooltip constructor contract:
        // assert((message == null) != (richMessage == null))
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTooltip(
                title: Text('Tooltip Title'),
                message: 'Tooltip Body Message',
                child: Text('Hover Target'),
              ),
            ),
          ),
        );

        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason: 'AnimalTooltip with title must not trigger assertion error',
        );
      },
    );
  });
}
