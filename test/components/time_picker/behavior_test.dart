import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/fake_clock.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

/// The items the hour, minute and (when shown) second wheels rest on.
List<int> _wheelItems(WidgetTester tester) => <int>[
  for (final ListWheelScrollView wheel
      in tester.widgetList<ListWheelScrollView>(
        find.byType(ListWheelScrollView),
      ))
    (wheel.controller! as FixedExtentScrollController).selectedItem,
];

Finder _wheel(int column) => find.byType(ListWheelScrollView).at(column);

/// Drags one wheel item upwards, which selects the next item.
Future<void> _dragOneItem(WidgetTester tester, int column) async {
  await tester.drag(_wheel(column), const Offset(0, -36));
  await tester.pumpAndSettle();
}

void main() {
  group('AnimalTimePicker Tests (F11 / TIM01-TIM05)', () {
    testWidgets(
      'onChanged provides atomic AnimalTimeValue containing seconds (F11 / TIM01)',
      (tester) async {
        AnimalTimeValue? receivedValue;
        AnimalTimeValue value = AnimalTimeValue(
          hour: 23,
          minute: 20,
          second: 58,
        );

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => _app(
              AnimalTimePicker(
                value: value,
                format: 'HH:mm:ss',
                clock: FakeClock(DateTime(2026, 1, 1, 10, 20, 30)),
                onChanged: (val) {
                  receivedValue = val;
                  if (val != null) setState(() => value = val);
                },
              ),
            ),
          ),
        );

        await _dragOneItem(tester, 1);
        expect(receivedValue, isNotNull);
        expect(receivedValue!.minute, isNot(20));
        expect(
          receivedValue!.second,
          58,
          reason: 'Changing the minute must keep the selected second',
        );

        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();

        expect(
          receivedValue,
          AnimalTimeValue(hour: 10, minute: 20, second: 30),
        );
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
        _app(
          AnimalTimePicker(
            value: lastValue,
            format: 'HH:mm:ss',
            onChanged: (val) {
              callCount++;
              lastValue = val;
            },
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
        int calls = 0;
        await tester.pumpWidget(
          _app(
            AnimalTimePicker(
              value: AnimalTimeValue(hour: 12, minute: 0),
              disabled: true,
              onChanged: (_) => calls++,
            ),
          ),
        );

        final scrollViews = tester.widgetList<ListWheelScrollView>(
          find.byType(ListWheelScrollView),
        );
        for (final view in scrollViews) {
          expect(view.physics, isA<NeverScrollableScrollPhysics>());
        }

        await tester.tap(find.text('Now'));
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(calls, 0);
      },
    );

    testWidgets('TIM04: external null resets the visible wheels', (
      tester,
    ) async {
      AnimalTimeValue? value = AnimalTimeValue(
        hour: 10,
        minute: 20,
        second: 30,
      );
      late StateSetter update;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return _app(
              AnimalTimePicker(
                value: value,
                format: 'HH:mm:ss',
                onChanged: (_) {},
              ),
            );
          },
        ),
      );
      expect(_wheelItems(tester), <int>[10, 20, 30]);

      update(() => value = null);
      await tester.pumpAndSettle();
      expect(_wheelItems(tester), <int>[
        0,
        0,
        0,
      ], reason: 'External null must reset the visible wheels');
    });
  });

  group('N17 time picker batches and controlled value', () {
    testWidgets(
      'N17 12:34:56 keeps its seconds through display, scroll, Now, clear and reset',
      (tester) async {
        final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
        AnimalTimeValue? value = AnimalTimeValue(
          hour: 12,
          minute: 34,
          second: 56,
        );
        late StateSetter update;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return _app(
                AnimalTimePicker(
                  value: value,
                  clock: FakeClock(DateTime(2026, 1, 1, 7, 8, 9)),
                  onChanged: (next) {
                    proposals.add(next);
                    setState(() => value = next);
                  },
                ),
              );
            },
          ),
        );
        expect(_wheelItems(tester), <int>[12, 34], reason: 'seconds hidden');

        await _dragOneItem(tester, 0);
        expect(proposals, <AnimalTimeValue?>[
          AnimalTimeValue(hour: 13, minute: 34, second: 56),
        ]);

        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Clear'));
        await tester.pumpAndSettle();
        expect(proposals, <AnimalTimeValue?>[
          AnimalTimeValue(hour: 13, minute: 34, second: 56),
          AnimalTimeValue(hour: 7, minute: 8, second: 9),
          null,
        ], reason: 'each batch reports its final value exactly once');

        update(() => value = AnimalTimeValue(hour: 12, minute: 34, second: 56));
        await tester.pumpAndSettle();
        expect(_wheelItems(tester), <int>[12, 34]);
        await _dragOneItem(tester, 1);
        expect(
          proposals.last,
          AnimalTimeValue(hour: 12, minute: 35, second: 56),
          reason: 'a reset value keeps its hidden seconds',
        );
        expect(proposals, hasLength(4));
      },
    );

    testWidgets(
      'N17 Now commits once and an immediate external value is not overwritten by the old batch',
      (tester) async {
        final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
        AnimalTimeValue? value = AnimalTimeValue(hour: 1, minute: 2, second: 3);
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) => _app(
              AnimalTimePicker(
                value: value,
                format: 'HH:mm:ss',
                clock: FakeClock(DateTime(2026, 1, 1, 22, 44, 55)),
                onChanged: (next) {
                  proposals.add(next);
                  // The parent replaces the proposal at once.
                  setState(
                    () =>
                        value = AnimalTimeValue(hour: 9, minute: 15, second: 0),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Now'));
        await tester.pump();
        await tester.pumpAndSettle();

        expect(proposals, <AnimalTimeValue?>[
          AnimalTimeValue(hour: 22, minute: 44, second: 55),
        ]);
        expect(_wheelItems(tester), <int>[
          9,
          15,
          0,
        ], reason: 'the superseded Now animation must not land later');
      },
    );

    testWidgets(
      'N17 wheels return to the value when the parent rejects a change',
      (tester) async {
        int proposals = 0;
        await tester.pumpWidget(
          _app(
            AnimalTimePicker(
              value: AnimalTimeValue(hour: 10, minute: 20, second: 30),
              format: 'HH:mm:ss',
              clock: FakeClock(DateTime(2026, 1, 1, 5, 6, 7)),
              onChanged: (_) => proposals++,
            ),
          ),
        );

        await _dragOneItem(tester, 1);
        expect(proposals, 1);
        expect(_wheelItems(tester), <int>[10, 20, 30]);

        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();
        expect(proposals, 2);
        expect(_wheelItems(tester), <int>[
          10,
          20,
          30,
        ], reason: 'a rejected Now must not stay on the wheels');
      },
    );

    testWidgets(
      'N17 a user drag during a programmatic batch reports only user input',
      (tester) async {
        final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
        await tester.pumpWidget(
          _app(
            AnimalTimePicker(
              // The parent records proposals but keeps its value, so the
              // Now batch is still animating when the drag starts.
              value: AnimalTimeValue(hour: 0, minute: 0, second: 0),
              format: 'HH:mm:ss',
              clock: FakeClock(DateTime(2026, 1, 1, 6, 30, 45)),
              onChanged: proposals.add,
            ),
          ),
        );

        await tester.tap(find.text('Now'));
        await tester.pump(const Duration(milliseconds: 16));
        await _dragOneItem(tester, 2);

        expect(
          proposals.first,
          AnimalTimeValue(hour: 6, minute: 30, second: 45),
        );
        expect(
          proposals.length,
          greaterThan(1),
          reason: 'a drag during an open batch is user input',
        );
        for (final AnimalTimeValue? proposal in proposals.skip(1)) {
          expect(proposal!.hour, 6, reason: 'no intermediate hour is reported');
          expect(proposal.minute, 30);
        }
        expect(_wheelItems(tester), <int>[0, 0, 0]);
      },
    );

    testWidgets('N17 a superseded batch never releases the newer one', (
      tester,
    ) async {
      final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 6, 30, 45));
      final List<AnimalTimeValue?> proposals = <AnimalTimeValue?>[];
      await tester.pumpWidget(
        _app(
          AnimalTimePicker(
            value: AnimalTimeValue(hour: 0, minute: 0, second: 0),
            format: 'HH:mm:ss',
            clock: clock,
            onChanged: proposals.add,
          ),
        ),
      );

      await tester.tap(find.text('Now'));
      await tester.pump(const Duration(milliseconds: 16));
      clock.setTime(DateTime(2026, 1, 1, 18, 10, 20));
      await tester.tap(find.text('Now'));
      await tester.pumpAndSettle();

      expect(proposals, <AnimalTimeValue?>[
        AnimalTimeValue(hour: 6, minute: 30, second: 45),
        AnimalTimeValue(hour: 18, minute: 10, second: 20),
      ], reason: 'only the final value of each batch is proposed');
    });

    testWidgets('N17 step and seconds-format changes stay within the wheels', (
      tester,
    ) async {
      int minuteStep = 5;
      String format = 'HH:mm';
      late StateSetter update;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return _app(
              AnimalTimePicker(
                value: AnimalTimeValue(hour: 8, minute: 55, second: 40),
                format: format,
                minuteStep: minuteStep,
                onChanged: (_) {},
              ),
            );
          },
        ),
      );
      expect(_wheelItems(tester), <int>[8, 11]);

      update(() => minuteStep = 7);
      await tester.pumpAndSettle();
      // 55 snaps to the nearest item of 0, 7, ..., 56.
      expect(_wheelItems(tester), <int>[8, 8]);

      update(() => format = 'HH:mm:ss');
      await tester.pumpAndSettle();
      expect(_wheelItems(tester), <int>[8, 8, 40]);
      expect(tester.takeException(), isNull);
    });

    testWidgets('N17 an immutable time value reaches a typed form field', (
      tester,
    ) async {
      final AnimalFormController controller = AnimalFormController();
      final AnimalFieldKey<AnimalTimeValue> key =
          AnimalFieldKey<AnimalTimeValue>(debugLabel: 'meeting');
      await tester.pumpWidget(
        _app(
          AnimalForm(
            controller: controller,
            child: AnimalFormItem<AnimalTimeValue>(
              fieldKey: key,
              initialValue: AnimalTimeValue(hour: 12, minute: 34, second: 56),
              builder: (context, binding) => AnimalTimePicker(
                value: binding.value,
                format: 'HH:mm:ss',
                onChanged: binding.onChanged,
              ),
            ),
          ),
        ),
      );

      await _dragOneItem(tester, 0);
      final AnimalTimeValue? stored = controller.values.valueFor(key);
      expect(stored, AnimalTimeValue(hour: 13, minute: 34, second: 56));
    });

    testWidgets(
      'N17 popover reuses the inline panel and proposes the same value',
      (tester) async {
        final FakeClock clock = FakeClock(DateTime(2026, 1, 1, 18, 5, 0));
        final List<AnimalTimeValue?> inline = <AnimalTimeValue?>[];
        final List<AnimalTimeValue?> popover = <AnimalTimeValue?>[];
        await tester.pumpWidget(
          _app(AnimalTimePicker(clock: clock, onChanged: inline.add)),
        );
        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          _app(AnimalTimePicker.popover(clock: clock, onChanged: popover.add)),
        );
        expect(find.text('Now'), findsNothing);
        await tester.tap(find.byIcon(Icons.access_time_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Now'), findsOneWidget);
        await tester.tap(find.text('Now'));
        await tester.pumpAndSettle();

        expect(inline, <AnimalTimeValue?>[
          AnimalTimeValue(hour: 18, minute: 5, second: 0),
        ]);
        expect(popover, inline);
      },
    );
  });
}
