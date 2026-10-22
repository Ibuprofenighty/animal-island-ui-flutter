import 'dart:ui' show CheckedState, SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'Radio and Rate flags belong to each checked action, Checkbox stays independent',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IslandRadioGroup(
                  options: const [
                    IslandOption(value: 1, label: 'Radio one'),
                    IslandOption(value: 2, label: 'Radio two', disabled: true),
                  ],
                  value: 1,
                  onChanged: (_) {},
                ),
                const IslandRate(initialValue: 2),
                IslandCheckbox(label: 'Check', value: true, onChanged: (_) {}),
              ],
            ),
          ),
        ),
      );
      for (final label in ['Radio one', 'Radio two', '1 星', '2 星']) {
        expect(
          t
              .getSemantics(find.bySemanticsLabel(label))
              .flagsCollection
              .isInMutuallyExclusiveGroup,
          isTrue,
          reason: label,
        );
      }
      expect(
        t
            .getSemantics(find.bySemanticsLabel('Check'))
            .flagsCollection
            .isInMutuallyExclusiveGroup,
        isFalse,
      );
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics && w.properties.role == SemanticsRole.radioGroup,
        ),
        findsNWidgets(2),
      );
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'Rejected radio proposal does not mutate host value; reordering keeps identity',
    (t) async {
      var options = const [
        IslandOption(value: 'a', label: 'Apple'),
        IslandOption(value: 'b', label: 'Berry'),
        IslandOption(value: 'c', label: 'Cherry', disabled: true),
      ];
      String? proposal;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (ctx, set) {
                update = set;
                return IslandRadioGroup(
                  options: options,
                  value: 'a',
                  onChanged: (v) => proposal = v,
                );
              },
            ),
          ),
        ),
      );
      await t.tap(find.text('Berry'));
      await t.pump();
      expect(proposal, 'b');
      final before = t.getSemantics(find.text('Apple'));
      expect(before.flagsCollection.isChecked, CheckedState.isTrue);
      update(() => options = [options[1], options[2], options[0]]);
      await t.pump();
      await t.tap(find.text('Apple'));
      await t.pump();
      proposal = null;
      await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await t.pump();
      expect(proposal, 'b');
    },
  );
  testWidgets(
    'Checkbox group commits a new immutable set and leaves source untouched',
    (t) async {
      final source = {'a'};
      Set<String>? proposal;
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IslandCheckboxGroup(
              options: const [
                IslandOption(value: 'a', label: 'A'),
                IslandOption(value: 'b', label: 'B'),
              ],
              values: source,
              onChanged: (v) => proposal = v,
            ),
          ),
        ),
      );
      await t.tap(find.text('B'));
      await t.pump();
      expect(source, {'a'});
      expect(proposal, {'a', 'b'});
      expect(() => proposal!.add('c'), throwsUnsupportedError);
    },
  );
  test('Duplicate option identities fail before rendering', () {
    expect(
      () => IslandRadioGroup(
        options: const [
          IslandOption(value: 1, label: 'A'),
          IslandOption(value: 1, label: 'B'),
        ],
        value: 1,
        onChanged: (_) {},
      ),
      throwsArgumentError,
    );
  });
}
