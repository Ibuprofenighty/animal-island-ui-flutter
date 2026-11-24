import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Reference controls draw their focus indicator under `:focus-visible`:
  // keyboard focus shows it, focus taken by a pointer press does not until a
  // key is used.
  late Set<WidgetState> first, second;
  Widget host() => MaterialApp(
    theme: IslandTheme.create(),
    home: Scaffold(
      body: Column(
        children: [
          IslandButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                first = states;
                return null;
              }),
            ),
            child: const Text('First'),
          ),
          IslandButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                second = states;
                return null;
              }),
            ),
            child: const Text('Second'),
          ),
        ],
      ),
    ),
  );

  bool owns(WidgetTester t, String label) {
    final focus = FocusManager.instance.primaryFocus?.context;
    if (focus == null) return false;
    return find
        .descendant(
          of: find.widgetWithText(IslandButton, label),
          matching: find.byElementPredicate((e) => e == focus),
        )
        .evaluate()
        .isNotEmpty;
  }

  testWidgets('a pointer press focuses without the focused state; a key '
      'shows it', (t) async {
    final oldHighlight = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = oldHighlight);
    await t.pumpWidget(host());
    await t.tap(find.text('First'));
    await t.pumpAndSettle();
    expect(owns(t, 'First'), isTrue);
    expect(first.contains(WidgetState.focused), isFalse);

    await t.sendKeyEvent(LogicalKeyboardKey.shiftLeft);
    await t.pumpAndSettle();
    expect(first.contains(WidgetState.focused), isTrue);
  });

  testWidgets('keyboard focus shows the focused state, and a pointer press '
      'on the keyboard-focused control keeps it', (t) async {
    final oldHighlight = FocusManager.instance.highlightStrategy;
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
    addTearDown(() => FocusManager.instance.highlightStrategy = oldHighlight);
    await t.pumpWidget(host());
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(owns(t, 'First'), isTrue);
    expect(first.contains(WidgetState.focused), isTrue);
    await t.tap(find.text('First'));
    await t.pumpAndSettle();
    expect(first.contains(WidgetState.focused), isTrue);

    // Pointer focus on another control hides the indicator there; moving
    // back by keyboard shows it again.
    await t.tap(find.text('Second'));
    await t.pumpAndSettle();
    expect(owns(t, 'Second'), isTrue);
    expect(second.contains(WidgetState.focused), isFalse);
    expect(first.contains(WidgetState.focused), isFalse);
    await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await t.pumpAndSettle();
    expect(owns(t, 'First'), isTrue);
    expect(first.contains(WidgetState.focused), isTrue);
    expect(t.takeException(), isNull);
  });
}
