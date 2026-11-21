import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const short = [
  IslandOption(value: 'a', label: 'Apple'),
  IslandOption(value: 'b', label: 'Berry'),
  IslandOption(value: 'c', label: 'Cherry'),
];
const wide = [
  IslandOption(value: 'a', label: 'A considerably longer option label'),
  IslandOption(value: 'b', label: 'Berry'),
];

Finder get panel => find
    .ancestor(
      of: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.role == ui.SemanticsRole.list,
      ),
      matching: find.byWidgetPredicate(
        (w) => w is Material && w.type == MaterialType.transparency,
      ),
    )
    .first;

Finder get select => find.byType(IslandSelect<String>);

Future<(Rect, Rect)> open(
  WidgetTester t, {
  required Size view,
  required Offset at,
  List<IslandOption<String>> options = short,
  IslandSelectVariant? variant,
}) async {
  t.view.physicalSize = view;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      key: UniqueKey(),
      theme: IslandTheme.create(),
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              left: at.dx,
              top: at.dy,
              width: 140,
              child: variant == null
                  ? IslandSelect<String>(
                      label: 'Choice',
                      options: options,
                      value: 'a',
                      onChanged: (_) {},
                    )
                  : IslandSelect<String>(
                      label: 'Choice',
                      options: options,
                      value: 'a',
                      variant: variant,
                      onChanged: (_) {},
                    ),
            ),
          ],
        ),
      ),
    ),
  );
  await t.tap(select);
  await t.pumpAndSettle();
  return (t.getRect(select), t.getRect(panel));
}

void main() {
  testWidgets('default variant is dropdown: centred 6px below the trigger', (
    t,
  ) async {
    final (anchor, rect) = await open(
      t,
      view: const Size(1440, 1000),
      at: const Offset(300, 300),
    );
    expect(rect.top - anchor.bottom, closeTo(6, .01));
    expect(rect.center.dx, closeTo(anchor.center.dx, .01));
    expect(t.takeException(), isNull);
  });

  testWidgets('dropdown and game panels share the content-sized width', (
    t,
  ) async {
    final (_, dropdown) = await open(
      t,
      view: const Size(1440, 1000),
      at: const Offset(300, 300),
      options: wide,
    );
    final (anchor, game) = await open(
      t,
      view: const Size(1440, 1000),
      at: const Offset(300, 300),
      options: wide,
      variant: IslandSelectVariant.game,
    );
    expect(dropdown.width, game.width);
    expect(dropdown.width, greaterThan(anchor.width));
  });

  testWidgets('dropdown flips 6px above when below is short and above larger', (
    t,
  ) async {
    final (anchor, rect) = await open(
      t,
      view: const Size(1440, 1000),
      at: const Offset(300, 940),
    );
    expect(anchor.top - rect.bottom, closeTo(6, .01));
    expect(rect.center.dx, closeTo(anchor.center.dx, .01));
  });

  testWidgets('search filtering keeps the flip estimate on every option', (
    t,
  ) async {
    // Reference Select.tsx: dropdownHeight = options.length * 44 + 24, from
    // all options, so typing a filter does not move a flipped panel back.
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: Stack(
            children: [
              Positioned(
                left: 300,
                top: 880,
                child: IslandSelect<String>(
                  label: 'Choice',
                  options: short,
                  value: 'a',
                  showSearch: true,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
    final trigger = t.getRect(select);
    final below = 1000 - trigger.bottom - 6;
    expect(below, lessThan(short.length * 44 + 24));
    expect(below, greaterThan(1 * 44 + 24));
    await t.tap(select);
    await t.pumpAndSettle();
    expect(t.getRect(select).top - t.getRect(panel).bottom, closeTo(6, .01));
    await t.enterText(find.byType(TextField), 'Cherry');
    await t.pumpAndSettle();
    expect(find.text('Berry'), findsNothing);
    expect(t.getRect(select).top - t.getRect(panel).bottom, closeTo(6, .01));
  });

  testWidgets('dropdown aligns to the trigger edge on an overflowing side', (
    t,
  ) async {
    final (leftAnchor, left) = await open(
      t,
      view: const Size(375, 812),
      at: const Offset(8, 100),
      options: wide,
    );
    expect(leftAnchor.center.dx - left.width / 2, lessThan(0));
    expect(left.left, closeTo(leftAnchor.left, .01));
    expect(left.top - leftAnchor.bottom, closeTo(6, .01));
    final (rightAnchor, right) = await open(
      t,
      view: const Size(375, 812),
      at: const Offset(375 - 148, 100),
      options: wide,
    );
    expect(rightAnchor.center.dx + right.width / 2, greaterThan(375));
    expect(right.right, closeTo(rightAnchor.right, .01));
  });

  testWidgets('game variant keeps the side popover vertically centred', (
    t,
  ) async {
    final (anchor, rect) = await open(
      t,
      view: const Size(1440, 1000),
      at: const Offset(300, 300),
      variant: IslandSelectVariant.game,
    );
    expect(rect.left - anchor.right, closeTo(6, .01));
    expect(rect.center.dy, closeTo(anchor.center.dy, .01));
  });

  for (final variant in IslandSelectVariant.values) {
    testWidgets('$variant panel stays inside the viewport at every corner', (
      t,
    ) async {
      for (final size in [
        const Size(320, 480),
        const Size(240, 240),
        const Size(1440, 1000),
      ]) {
        for (final corner in [0, 1, 2, 3]) {
          final (_, rect) = await open(
            t,
            view: size,
            at: Offset(
              corner.isOdd ? size.width - 148 : 8,
              corner >= 2 ? size.height - 96 : 32,
            ),
            options: wide,
            variant: variant,
          );
          final reason = '$variant $size corner$corner';
          expect(rect.left, greaterThanOrEqualTo(-.01), reason: reason);
          expect(rect.top, greaterThanOrEqualTo(-.01), reason: reason);
          expect(
            rect.right,
            lessThanOrEqualTo(size.width + .01),
            reason: reason,
          );
          expect(
            rect.bottom,
            lessThanOrEqualTo(size.height + .01),
            reason: reason,
          );
          expect(t.takeException(), isNull, reason: reason);
        }
      }
    });
  }
}
