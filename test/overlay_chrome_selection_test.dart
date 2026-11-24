import 'dart:ui' show PointerDeviceKind;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget app(Widget home, ValueChanged<String?> selected) => MaterialApp(
  theme: IslandTheme.create(),
  builder: (context, child) => Overlay.wrap(
    child: SelectionArea(
      onSelectionChanged: (content) => selected(content?.plainText),
      child: child!,
    ),
  ),
  home: home,
);

Future<void> selectAllFrom(WidgetTester t, Finder text) async {
  final mouse = await t.startGesture(
    t.getCenter(text),
    kind: PointerDeviceKind.mouse,
  );
  await mouse.up();
  await t.pump(const Duration(milliseconds: 500));
  await t.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await t.sendKeyEvent(LogicalKeyboardKey.keyA);
  await t.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await t.pump();
}

void main() {
  testWidgets('Modal title and actions stay out of an ancestor selection', (
    t,
  ) async {
    String? selected;
    await t.pumpWidget(
      app(
        Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showIslandModal<void>(
                context: context,
                title: const Text('Island settings'),
                actions: (_) => [const Text('Action note')],
                builder: (_) => const Text('Body copy'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
        (text) => selected = text,
      ),
    );
    await t.tap(find.text('Open'));
    await t.pumpAndSettle();
    await selectAllFrom(t, find.text('Body copy'));
    expect(selected, contains('Body copy'));
    expect(selected, isNot(contains('Island settings')));
    expect(selected, isNot(contains('Action note')));
  });

  testWidgets('closing a stacked modal keeps the outer barrier blocking', (
    t,
  ) async {
    var background = 0;
    late BuildContext page;
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              page = context;
              return Align(
                alignment: Alignment.bottomLeft,
                child: TextButton(
                  onPressed: () => background++,
                  child: const Text('Background'),
                ),
              );
            },
          ),
        ),
      ),
    );
    showIslandModal<void>(
      context: page,
      dismissible: false,
      builder: (_) => const Text('Outer modal'),
    );
    await t.pumpAndSettle();
    showIslandModal<void>(
      context: page,
      builder: (_) => const Text('Inner modal'),
      actions: (context) => [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close inner'),
        ),
      ],
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Close inner'));
    await t.pumpAndSettle();
    expect(find.text('Inner modal'), findsNothing);
    expect(find.text('Outer modal'), findsOneWidget);
    await t.tap(find.text('Background'), warnIfMissed: false);
    await t.pump();
    expect(background, 0);
  });
}
