import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTimePicker State Tests', () {
    testWidgets('didUpdateWidget synchronizes external time changes', (
      tester,
    ) async {
      AnimalTimeValue? currentTime = AnimalTimeValue(
        hour: 10,
        minute: 20,
        second: 0,
      );

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: Column(
                  children: [
                    AnimalTimePicker.popover(
                      value: currentTime,
                      format: 'HH:mm',
                      onChanged: (t) {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentTime = AnimalTimeValue(
                            hour: 14,
                            minute: 45,
                            second: 0,
                          );
                        });
                      },
                      child: const Text('Update Time'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('10:20'), findsOneWidget);

      await tester.tap(find.text('Update Time'));
      await tester.pumpAndSettle();

      expect(find.text('14:45'), findsOneWidget);
    });

    testWidgets('External second modification updates display format', (
      tester,
    ) async {
      AnimalTimeValue time = AnimalTimeValue(hour: 23, minute: 59, second: 15);

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: AnimalIslandTheme.light.toThemeData(),
              home: Scaffold(
                body: Column(
                  children: [
                    AnimalTimePicker.popover(
                      value: time,
                      format: 'HH:mm:ss',
                      onChanged: (t) {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          time = time.copyWith(second: 58);
                        });
                      },
                      child: const Text('Update Second'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('23:59:15'), findsOneWidget);

      await tester.tap(find.text('Update Second'));
      await tester.pumpAndSettle();

      expect(find.text('23:59:58'), findsOneWidget);
    });
  });
}
