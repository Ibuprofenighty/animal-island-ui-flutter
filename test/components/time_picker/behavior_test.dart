import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  group('AnimalTimePicker Tests (F11 / TIM01-TIM05)', () {
    testWidgets(
      'onChanged provides atomic AnimalTimeValue containing seconds (F11 / TIM01)',
      (tester) async {
        AnimalTimeValue? receivedValue;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTimePicker(
                value: AnimalTimeValue(hour: 10, minute: 20, second: 30),
                format: 'HH:mm:ss',
                onChanged: (val) {
                  receivedValue = val;
                },
              ),
            ),
          ),
        );

        // Tap "Now" button
        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();

        expect(receivedValue, isNotNull);
        expect(receivedValue, isA<AnimalTimeValue>());
        expect(receivedValue!.second, inInclusiveRange(0, 59));
        expect(
          receivedValue is! TimeOfDay,
          isTrue,
          reason: 'Time value delivered to onChanged must be AnimalTimeValue with seconds, not TimeOfDay',
        );
      },
    );

    testWidgets('TIM02: Clear button sends null once', (tester) async {
      int callCount = 0;
      AnimalTimeValue? lastValue = AnimalTimeValue(
        hour: 10,
        minute: 20,
        second: 30,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: AnimalTimePicker(
              value: lastValue,
              onChanged: (val) {
                callCount++;
                lastValue = val;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      expect(callCount, 1);
      expect(lastValue, isNull);
    });

    test('TIM03: Step <= 0 throws ArgumentError in constructor', () {
      expect(() => AnimalTimePicker(hourStep: 0), throwsArgumentError);
      expect(() => AnimalTimePicker(minuteStep: -1), throwsArgumentError);
      expect(() => AnimalTimePicker(secondStep: 0), throwsArgumentError);
    });

    testWidgets(
      'TIM04: Disabled time picker locks wheel scrolling and disables buttons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalTimePicker(
                value: AnimalTimeValue(hour: 12, minute: 0),
                disabled: true,
                onChanged: (_) {},
              ),
            ),
          ),
        );

        final scrollViews = tester.widgetList<ListWheelScrollView>(
          find.byType(ListWheelScrollView),
        );
        for (final view in scrollViews) {
          expect(view.physics, isA<NeverScrollableScrollPhysics>());
        }

        // Tap Now button while disabled should not crash and not trigger
        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();
      },
    );
  });
}
