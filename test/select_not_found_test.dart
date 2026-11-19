import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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

Future<Rect> openEmpty(
  WidgetTester t, {
  Widget? notFound,
  List<IslandOption<String>> options = const [],
  String? search,
  Widget? reference,
}) async {
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
              left: 600,
              top: 300,
              child: notFound == null
                  ? IslandSelect<String>(
                      label: 'Choice',
                      options: options,
                      value: null,
                      showSearch: search != null,
                      onChanged: (_) {},
                    )
                  : IslandSelect<String>(
                      label: 'Choice',
                      options: options,
                      value: null,
                      showSearch: search != null,
                      notFound: notFound,
                      onChanged: (_) {},
                    ),
            ),
            if (reference != null)
              Positioned(left: 0, top: 0, child: reference),
          ],
        ),
      ),
    ),
  );
  if (search != null) {
    await t.enterText(find.byType(TextField), search);
  } else {
    await t.tap(find.byType(IslandSelect<String>));
  }
  await t.pumpAndSettle();
  return t.getRect(panel);
}

void main() {
  // Reference `.dropdown` is absolutely positioned with no width, so it
  // shrinks to its content: `.notFound` (14px side padding, nowrap).
  testWidgets('default notFound panel is its content width plus padding', (
    t,
  ) async {
    final rect = await openEmpty(t);
    final text = t.getRect(find.text('暂无数据'));
    expect(rect.width, closeTo(text.width + 28, .01));
    expect(text.height, closeTo(21, .01), reason: 'one 14px/1.5 line');
    expect(t.takeException(), isNull);
  });

  testWidgets('longer custom notFound text stays on one unclipped line', (
    t,
  ) async {
    const message = 'No island residents match this search';
    final rect = await openEmpty(t, notFound: const Text(message));
    final text = t.getRect(find.text(message));
    expect(rect.width, closeTo(text.width + 28, .01));
    expect(rect.width, greaterThan(140));
    expect(text.height, closeTo(21, .01), reason: 'one 14px/1.5 line');
    expect(text.left, greaterThanOrEqualTo(rect.left));
    expect(text.right, lessThanOrEqualTo(rect.right));
  });

  testWidgets('custom notFound widget keeps its natural size', (t) async {
    final reference = IslandButton(
      key: const ValueKey('natural'),
      onPressed: () {},
      child: const Text('Create a new option'),
    );
    final rect = await openEmpty(
      t,
      notFound: IslandButton(
        key: const ValueKey('slot'),
        onPressed: () {},
        child: const Text('Create a new option'),
      ),
      reference: reference,
    );
    final natural = t.getSize(find.byKey(const ValueKey('natural')));
    final slot = t.getRect(find.byKey(const ValueKey('slot')));
    expect(slot.size, natural);
    expect(rect.width, closeTo(natural.width + 28, .01));
  });

  testWidgets('filtering to no match sizes the panel to notFound', (t) async {
    const options = [
      IslandOption(value: 'a', label: 'A considerably longer option label'),
    ];
    final rect = await openEmpty(t, options: options, search: 'zzz');
    final text = t.getRect(find.text('暂无数据'));
    expect(rect.width, closeTo(text.width + 28, .01));
  });

  testWidgets('option list width still follows the widest label', (t) async {
    const options = [
      IslandOption(value: 'a', label: 'A considerably longer option label'),
      IslandOption(value: 'b', label: 'Berry'),
    ];
    final rect = await openEmpty(t, options: options);
    final label = t.getRect(find.text(options.first.label).last);
    // Option padding 30 + 30 around the label (reference 14px start padding
    // plus the 16px dot, 30px end padding).
    expect(rect.width, closeTo(label.width + 60, 1));
  });
}
