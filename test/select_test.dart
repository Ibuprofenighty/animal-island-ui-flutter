import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: child),
  ),
);
const options = [
  IslandOption(value: 'a', label: 'Apple'),
  IslandOption(value: 'b', label: 'Berry'),
  IslandOption(value: 'c', label: 'Cherry', disabled: true),
];
void main() {
  testWidgets(
    'Select keyboard skips disabled and rejected proposals preserve parent value',
    (t) async {
      String? requested;
      await t.pumpWidget(
        host(
          IslandSelect<String>(
            options: options,
            value: 'a',
            onChanged: (v) => requested = v,
            label: 'Fruit',
          ),
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pumpAndSettle();
      expect(find.text('Berry'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(requested, 'b');
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Berry'), findsNothing);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.end);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(requested, 'b');
    },
  );
  testWidgets(
    'Select search, empty result and outside close reset query once',
    (t) async {
      final searches = <String>[];
      await t.pumpWidget(
        host(
          Column(
            children: [
              IslandSelect<String>(
                options: options,
                value: 'a',
                onChanged: (_) {},
                showSearch: true,
                onSearch: searches.add,
              ),
              const SizedBox(height: 80),
              const Text('Outside'),
            ],
          ),
        ),
      );
      await t.enterText(find.byType(TextField), 'zz');
      await t.pumpAndSettle();
      expect(find.text('暂无数据'), findsOneWidget);
      expect(searches, ['zz']);
      await t.tap(find.text('Outside'));
      await t.pumpAndSettle();
      expect(searches, ['zz', '']);
      expect(find.text('暂无数据'), findsNothing);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Apple',
      );
    },
  );
  testWidgets(
    'Select follows stable option values across reorder and borrows focus',
    (t) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var list = options;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandSelect<String>(
                options: list,
                value: 'b',
                onChanged: (_) {},
                focusNode: focus,
                allowClear: true,
              );
            },
          ),
        ),
      );
      await t.tap(find.text('Berry'));
      await t.pumpAndSettle();
      update(() => list = [options[2], options[1], options[0]]);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('Berry'), findsOneWidget);
      expect(focus.hasFocus, isTrue);
      await t.pumpWidget(const SizedBox());
      focus.requestFocus();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Select clear dispatches once and retains an open option panel', (
    t,
  ) async {
    final requests = <String?>[];
    var cleared = 0;
    await t.pumpWidget(
      host(
        IslandSelect<String>(
          options: options,
          value: 'a',
          onChanged: requests.add,
          allowClear: true,
          onClear: () => cleared++,
        ),
      ),
    );
    await t.tap(find.text('Apple'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('清除'));
    await t.pumpAndSettle();
    expect(requests, [null]);
    expect(cleared, 1);
    expect(find.text('Berry'), findsOneWidget);
    expect(find.text('Apple'), findsNWidgets(2));
  });
}
