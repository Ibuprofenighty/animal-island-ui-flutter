import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const choices = [
  IslandOption(value: 'a', label: 'Apple'),
  IslandOption(value: 'b', label: 'Berry'),
  IslandOption(value: 'c', label: 'Cherry'),
];

Widget control(String kind) => switch (kind) {
  'select' => IslandSelect<String>(
    label: 'Choice',
    options: choices,
    value: 'a',
    onChanged: (_) {},
  ),
  'date' => IslandDatePicker.uncontrolled(
    label: 'Date',
    now: () => DateTime(2026, 10, 15),
  ),
  'range' => IslandDatePicker.rangeUncontrolled(
    label: 'Range',
    now: () => DateTime(2026, 10, 15),
  ),
  'time' => const IslandTimePicker.uncontrolled(label: 'Time'),
  'pagination' => const IslandPagination.uncontrolled(
    total: 1,
    showSizeChanger: true,
  ),
  _ => IslandTooltip.click(
    message: 'Tooltip content',
    placement: IslandTooltipPlacement.left,
    builder: (_, toggle) =>
        IslandButton(onPressed: toggle, child: const Text('Tooltip anchor')),
  ),
};

Finder trigger(String kind) => switch (kind) {
  'select' => namedButton('Choice'),
  'date' => namedButton('Date'),
  'range' => namedButton('Range'),
  'time' => namedButton('Time'),
  'pagination' => namedButton('10 / page'),
  _ => find.text('Tooltip anchor'),
};

Finder namedButton(String label) => find.byWidgetPredicate(
  (w) =>
      w is Semantics &&
      w.properties.button == true &&
      w.properties.label == label,
);

Finder marker(String kind) => switch (kind) {
  'select' => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.role == ui.SemanticsRole.list,
  ),
  'date' || 'range' || 'time' => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        w.properties.button != true &&
        w.properties.label ==
            switch (kind) {
              'date' => '选择日期',
              'range' => '选择日期范围',
              _ => 'Time',
            },
  ),
  'pagination' => find.byWidgetPredicate(
    (w) =>
        w is Semantics &&
        w.container == true &&
        w.properties.label == 'Items per page',
  ),
  _ =>
    find
        .ancestor(
          of: find.text('Tooltip content'),
          matching: find.byType(CustomPaint),
        )
        .first,
};

Finder surface(String kind) => find
    .ancestor(
      of: marker(kind),
      matching: find.byWidgetPredicate(
        (w) => w is Material && w.type == MaterialType.transparency,
      ),
    )
    .first;

void inside(Rect rect, Size viewport, String reason) {
  expect(rect.left, greaterThanOrEqualTo(-.01), reason: reason);
  expect(rect.top, greaterThanOrEqualTo(-.01), reason: reason);
  expect(rect.right, lessThanOrEqualTo(viewport.width + .01), reason: reason);
  expect(rect.bottom, lessThanOrEqualTo(viewport.height + .01), reason: reason);
}

void main() => registerAnchoredViewportTests();

void registerAnchoredViewportTests({
  Future<void> Function(WidgetTester tester, String name)? capture,
}) {
  testWidgets(
    'opening and reopening reveals committed last option in its own list',
    (t) async {
      t.view.physicalSize = const Size(375, 812);
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
                  left: 57,
                  top: 32,
                  width: 140,
                  child: IslandSelect<String>(
                    label: 'Choice',
                    value: '29',
                    onChanged: (_) {},
                    options: [
                      for (var i = 0; i < 30; i++)
                        IslandOption(value: '$i', label: 'Option $i'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      for (var pass = 0; pass < 2; pass++) {
        await t.tap(trigger('select'));
        await t.pumpAndSettle();
        final last = find.descendant(
          of: marker('select'),
          matching: find.text('Option 29'),
        );
        expect(
          t.getRect(surface('select')).contains(t.getCenter(last)),
          isTrue,
        );
        await capture?.call(t, 'anchor-select-committed-last-$pass');
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(marker('select'), findsNothing);
      }
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'fitting vertical attachments retain Date below6 and Pagination above8 gaps',
    (t) async {
      for (final kind in ['date', 'pagination']) {
        await t.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: IslandTheme.create(),
            locale: const Locale('en'),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            home: Scaffold(
              body: Stack(
                children: [
                  Positioned(
                    left: 300,
                    top: kind == 'date' ? 100 : 450,
                    width: kind == 'date' ? 140 : 200,
                    child: control(kind),
                  ),
                ],
              ),
            ),
          ),
        );
        await t.tap(trigger(kind));
        await t.pumpAndSettle();
        final rect = t.getRect(surface(kind));
        final anchor = t.getRect(
          kind == 'date'
              ? find.byType(IslandDatePicker)
              : namedButton('10 / page'),
        );
        if (kind == 'date') {
          expect(rect.top - anchor.bottom, 6);
        } else {
          expect(anchor.top - rect.bottom, 8);
        }
        expect(rect.overlaps(anchor), isFalse);
        await capture?.call(t, 'anchor-$kind-fitting-vertical');
        await t.tap(trigger(kind));
        await t.pumpAndSettle();
        expect(marker(kind), findsNothing);
        expect(t.takeException(), isNull);
      }
    },
  );

  testWidgets(
    '375px Select flips overflowing side without changing natural width or gap',
    (t) async {
      t.view.physicalSize = const Size(375, 812);
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
                  left: 57,
                  top: 350,
                  width: 140,
                  child: IslandSelect<String>(
                    label: 'Choice',
                    value: 'a',
                    onChanged: (_) {},
                    options: const [
                      IslandOption(value: 'a', label: '鲈鱼'),
                      IslandOption(value: 'b', label: '鲷鱼'),
                      IslandOption(value: 'c', label: '草鱼'),
                      IslandOption(value: 'd', label: '龙睛鱼'),
                      IslandOption(value: 'e', label: '神仙鱼'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await t.tap(trigger('select'));
      await t.pumpAndSettle();
      final rect = t.getRect(surface('select'));
      expect(rect.left, 203);
      expect(rect.width, closeTo(102, .1));
      expect(rect.left - t.getRect(find.byType(IslandSelect<String>)).right, 6);
      inside(rect, const Size(375, 812), '375px reference overflow correction');
      await capture?.call(t, 'anchor-select-375-correction');
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('fitting viewport-edge attachment stays unchanged', (t) async {
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: control('date'),
            ),
          ),
        ),
      ),
    );
    await t.tap(trigger('date'));
    await t.pumpAndSettle();
    expect(t.getRect(surface('date')).left, 0);
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'nested offset Overlay supplies its own bounds rather than screen MediaQuery',
    (t) async {
      final viewportKey = GlobalKey();
      final entry = OverlayEntry(
        builder: (_) => Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned(
                left: 8,
                top: 120,
                width: 140,
                child: MediaQuery(
                  data: const MediaQueryData(
                    size: Size(90, 100),
                    disableAnimations: true,
                  ),
                  child: control('select'),
                ),
              ),
            ],
          ),
        ),
      );
      try {
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.only(left: 40, top: 80),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    key: viewportKey,
                    width: 280,
                    height: 360,
                    child: Overlay(initialEntries: [entry]),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.tap(trigger('select'));
        await t.pumpAndSettle();
        final viewport = t.getRect(find.byKey(viewportKey));
        final popup = t.getRect(surface('select'));
        expect(popup.left, greaterThanOrEqualTo(viewport.left));
        expect(popup.right, lessThanOrEqualTo(viewport.right));
        expect(popup.top, greaterThanOrEqualTo(viewport.top));
        expect(popup.bottom, lessThanOrEqualTo(viewport.bottom));
        expect(popup.width, greaterThan(90));
        expect(t.takeException(), isNull);
      } finally {
        if (entry.mounted) entry.remove();
        await t.pumpWidget(const SizedBox.shrink());
        entry.dispose();
      }
    },
  );

  testWidgets(
    'short time and narrow calendar retain reachable footer and navigation',
    (t) async {
      t.view.physicalSize = const Size(240, 240);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      for (final kind in ['time', 'date']) {
        await t.pumpWidget(
          MaterialApp(
            key: UniqueKey(),
            theme: IslandTheme.create(),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: control(kind),
                ),
              ),
            ),
          ),
        );
        await t.tap(trigger(kind));
        await t.pumpAndSettle();
        final target = kind == 'time' ? find.text('确定') : namedButton('下一年');
        await t.ensureVisible(target);
        await t.pumpAndSettle();
        final panel = t.getRect(surface(kind));
        expect(panel.contains(t.getCenter(target)), isTrue);
        await t.tap(target);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
      }
    },
  );

  testWidgets(
    'long Tooltip scrolls and keeps opaque child state and style on resize',
    (t) async {
      t.view.physicalSize = const Size(320, 240);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final contentKey = GlobalKey();
      await t.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create(),
          home: Scaffold(
            body: Center(
              child: IslandTooltip.click(
                message: 'Tooltip content',
                content: StatefulBuilder(
                  key: contentKey,
                  builder: (_, set) => const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Tooltip content'),
                      const SizedBox(height: 500),
                      const Text(
                        'Last line',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ],
                  ),
                ),
                builder: (_, toggle) => IslandButton(
                  onPressed: toggle,
                  child: const Text('Tooltip anchor'),
                ),
              ),
            ),
          ),
        ),
      );
      await t.tap(trigger('tooltip'));
      await t.pumpAndSettle();
      final identity = contentKey.currentState;
      await t.drag(surface('tooltip'), const Offset(0, -800));
      await t.pumpAndSettle();
      expect(
        t
            .getRect(surface('tooltip'))
            .contains(t.getCenter(find.text('Last line'))),
        isTrue,
      );
      t.view.physicalSize = const Size(240, 320);
      await t.pumpAndSettle();
      await capture?.call(t, 'anchor-tooltip-long-resized');
      expect(contentKey.currentState, same(identity));
      expect(
        t.widget<Text>(find.text('Last line')).style!.color,
        Colors.purple,
      );
      expect(t.takeException(), isNull);
    },
  );
  for (final kind in [
    'select',
    'date',
    'range',
    'time',
    'pagination',
    'tooltip',
  ]) {
    testWidgets(
      '$kind panel fits actual viewport at both edges and short heights',
      (t) async {
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        for (final size in [
          const Size(375, 812),
          const Size(320, 480),
          const Size(240, 240),
          const Size(1440, 1000),
        ]) {
          t.view.physicalSize = size;
          for (final corner in [0, 1, 2, 3]) {
            final right = corner.isOdd;
            final bottom = corner >= 2;
            await t.pumpWidget(
              MaterialApp(
                key: UniqueKey(),
                theme: IslandTheme.create(),
                locale: const Locale('en'),
                localizationsDelegates: IslandLocalizations.delegates,
                supportedLocales: IslandLocalizations.supportedLocales,
                home: Scaffold(
                  body: MediaQuery(
                    data: MediaQueryData(size: size, disableAnimations: true),
                    child: Stack(
                      children: [
                        Positioned(
                          left: right
                              ? size.width - (kind == 'pagination' ? 208 : 148)
                              : 8,
                          top: bottom ? size.height - 96 : 32,
                          width: kind == 'pagination' ? 200 : 140,
                          child: control(kind),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
            await t.pumpAndSettle();
            await t.tap(trigger(kind));
            await t.pumpAndSettle();
            expect(surface(kind), findsOneWidget);
            inside(t.getRect(surface(kind)), size, '$kind $size right=$right');
            expect(
              t.takeException(),
              isNull,
              reason: '$kind $size right=$right',
            );
            await capture?.call(
              t,
              'anchor-$kind-${size.width.toInt()}x${size.height.toInt()}-corner$corner',
            );
            await t.pumpWidget(const SizedBox.shrink());
          }
        }
      },
    );
  }

  testWidgets('fitting desktop Select retains reference beside attachment', (
    t,
  ) async {
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
                top: 300,
                width: 140,
                child: control('select'),
              ),
            ],
          ),
        ),
      ),
    );
    await t.tap(trigger('select'));
    await t.pumpAndSettle();
    final anchor = t.getRect(trigger('select'));
    final panel = t.getRect(surface('select'));
    // Trigger semantics occupy the label; the public Select owns the full140px anchor.
    final fullAnchor = t.getRect(find.byType(IslandSelect<String>));
    expect(panel.left, closeTo(fullAnchor.right + 6, .01));
    expect(panel.center.dy, closeTo(fullAnchor.center.dy, .01));
    expect(panel.center.dy, closeTo(anchor.center.dy, .01));
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'Select follows scroll resize and dynamic long search without losing commit authority',
    (t) async {
      t.view.physicalSize = const Size(375, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      final scroll = ScrollController(), focus = FocusNode();
      final events = <String?>[];
      try {
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            home: Scaffold(
              body: SingleChildScrollView(
                controller: scroll,
                child: SizedBox(
                  height: 1800,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 57,
                        top: 400,
                        width: 140,
                        child: IslandSelect<String>(
                          label: 'Search',
                          value: 'a',
                          focusNode: focus,
                          showSearch: true,
                          onChanged: events.add,
                          options: [
                            ...choices,
                            for (var i = 0; i < 30; i++)
                              IslandOption(
                                value: 'long$i',
                                label:
                                    'Long searchable option number $i with readable wrapping',
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await t.enterText(find.byType(TextField), 'Long searchable');
        await t.pumpAndSettle();
        inside(
          t.getRect(surface('select')),
          const Size(375, 812),
          'long query',
        );
        expect(focus.hasPrimaryFocus, isTrue);
        scroll.jumpTo(280);
        await t.pumpAndSettle();
        inside(
          t.getRect(surface('select')),
          const Size(375, 812),
          'after scroll',
        );
        t.view.physicalSize = const Size(240, 320);
        await t.pumpAndSettle();
        inside(
          t.getRect(surface('select')),
          const Size(240, 320),
          'after resize',
        );
        expect(
          find.text('Long searchable option number 0 with readable wrapping'),
          findsOneWidget,
        );
        final hostOffset = scroll.offset;
        await t.sendKeyEvent(LogicalKeyboardKey.end);
        await t.pumpAndSettle();
        inside(
          t.getRect(
            find.text(
              'Long searchable option number 29 with readable wrapping',
            ),
          ),
          const Size(240, 320),
          'keyboard active option must be visible',
        );
        await t.sendKeyEvent(LogicalKeyboardKey.enter);
        await t.pumpAndSettle();
        expect(events, ['long29']);
        expect(scroll.offset, hostOffset);
        expect(
          t.widget<TextField>(find.byType(TextField)).controller!.text,
          'Apple',
        );
        expect(focus.hasPrimaryFocus, isTrue);
        await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await t.pumpAndSettle();
        inside(t.getRect(surface('select')), const Size(240, 320), 'reopen');
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(marker('select'), findsNothing);
        await t.pumpWidget(const SizedBox.shrink());
        expect(t.takeException(), isNull);
      } finally {
        scroll.dispose();
        focus.dispose();
      }
    },
  );
}
