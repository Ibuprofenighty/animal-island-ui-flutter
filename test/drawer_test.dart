import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: IslandDrawerHost(child: Scaffold(body: child)),
);
void main() {
  testWidgets('empty drawer consumes Tab without entering its excluded host', (
    t,
  ) async {
    final outside = FocusNode();
    await t.pumpWidget(
      host(
        Column(
          children: [
            TextButton(
              focusNode: outside,
              onPressed: () {},
              child: const Text('Outside'),
            ),
            const IslandDrawer(open: true, onClose: null, child: Text('Empty')),
          ],
        ),
      ),
    );
    await t.pumpAndSettle();
    final current = FocusManager.instance.primaryFocus;
    expect(outside.hasFocus, isFalse);
    expect(await t.sendKeyEvent(LogicalKeyboardKey.tab), isTrue);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, same(current));
    expect(outside.hasFocus, isFalse);
    await t.pumpWidget(const SizedBox());
    outside.dispose();
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'sole drawer action keeps primary focus through forward and reverse Tab and activates once',
    (t) async {
      var closes = 0;
      await t.pumpWidget(
        host(
          IslandDrawer(
            open: true,
            onClose: () => closes++,
            title: const Text('Single'),
            child: const Text('Body'),
          ),
        ),
      );
      await t.pumpAndSettle();
      final close = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.label == '关闭' &&
            w.properties.button == true,
      );
      expect(close, findsOneWidget);
      final initial = FocusManager.instance.primaryFocus;
      expect(initial, isNotNull);
      for (var i = 0; i < 3; i++) {
        expect(
          await t.sendKeyEvent(LogicalKeyboardKey.tab),
          isTrue,
          reason: 'Closed loop must consume Tab even when the same node retains focus',
        );
        await t.pumpAndSettle();
        expect(FocusManager.instance.primaryFocus, same(initial));
      }
      await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      expect(await t.sendKeyEvent(LogicalKeyboardKey.tab), isTrue);
      await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await t.pumpAndSettle();
      expect(FocusManager.instance.primaryFocus, same(initial));
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(closes, 1);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'viewport geometry ignores a smaller trigger MediaQuery and paints the depth backplane',
    (t) async {
      final boundaryKey = GlobalKey();
      var placement = IslandDrawerPlacement.right;
      late StateSetter change;
      await t.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 300)),
              child: IslandDrawerHost(
                child: Scaffold(
                  backgroundColor: Colors.blue,
                  body: StatefulBuilder(
                    builder: (context, set) {
                      change = set;
                      return IslandDrawer(
                        open: true,
                        placement: placement,
                        onClose: () {},
                        title: const Text('Viewport'),
                        child: const Text('Body'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final panel = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == const Color(0xfff7f3df),
      );
      // The native runner uses its actual window, not the headless 800x600 view.
      // The deliberately smaller trigger MediaQuery must never bound the panel.
      final viewport = t.binding.renderViews.single.size;
      expect(viewport.width, greaterThan(400));
      expect(viewport.height, greaterThan(300));
      expect(
        t.getRect(panel),
        Rect.fromLTWH(viewport.width - 378, 0, 378, viewport.height),
      );
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final corner = await t.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final rgb =
            bytes!.getUint8(0) << 16 |
            bytes.getUint8(1) << 8 |
            bytes.getUint8(2);
        image.dispose();
        return rgb;
      });
      expect(corner, 0xd1d1d1);
      for (final entry in {
        IslandDrawerPlacement.left: Rect.fromLTWH(0, 0, 378, viewport.height),
        IslandDrawerPlacement.top: Rect.fromLTWH(0, 0, viewport.width, 300),
        IslandDrawerPlacement.bottom: Rect.fromLTWH(
          0,
          viewport.height - 300,
          viewport.width,
          300,
        ),
      }.entries) {
        change(() => placement = entry.key);
        await t.pumpAndSettle();
        expect(t.getRect(panel), entry.value);
      }
    },
  );

  testWidgets(
    'controlled rejection keeps drawer; accepted close restores trigger focus',
    (t) async {
      var open = false, reject = true, requests = 0;
      late StateSetter change;
      final origin = FocusNode();
      addTearDown(origin.dispose);
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) {
              change = set;
              return Column(
                children: [
                  IslandButton(
                    focusNode: origin,
                    onPressed: () => set(() => open = true),
                    child: const Text('Open'),
                  ),
                  IslandDrawer(
                    open: open,
                    title: const Text('Settings'),
                    onClose: () {
                      requests++;
                      if (!reject) set(() => open = false);
                    },
                    child: const Text('Panel content'),
                  ),
                ],
              );
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Panel content'), findsNothing);
      await t.tap(find.text('Open'));
      await t.pumpAndSettle();
      expect(find.text('Panel content'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(requests, 1);
      expect(find.text('Panel content'), findsOneWidget);
      change(() => reject = false);
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(requests, 2);
      expect(find.text('Panel content'), findsNothing);
      expect(origin.hasFocus, isTrue);
    },
  );
  testWidgets(
    'closed panel preserves editor and nested action never triggers mask',
    (t) async {
      var open = true, closes = 0, actions = 0;
      late StateSetter change;
      final editor = TextEditingController();
      addTearDown(editor.dispose);
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) {
              change = set;
              return IslandDrawer(
                open: open,
                title: const Text('Editor'),
                onClose: () {
                  closes++;
                  set(() => open = false);
                },
                child: Column(
                  children: [
                    TextField(controller: editor),
                    IslandButton(
                      onPressed: () => actions++,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'Retained');
      await t.tap(find.text('Save'));
      await t.pump();
      expect(actions, 1);
      expect(closes, 0);
      await t.tapAt(const Offset(30, 300));
      await t.pumpAndSettle();
      expect(closes, 1);
      change(() => open = true);
      await t.pumpAndSettle();
      expect(editor.text, 'Retained');
      expect(find.text('Retained'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('mask disable and focus loop isolate background controls', (
    t,
  ) async {
    final outside = FocusNode(), inside = FocusNode();
    addTearDown(() {
      outside.dispose();
      inside.dispose();
    });
    var closes = 0;
    await t.pumpWidget(
      host(
        Column(
          children: [
            TextButton(
              focusNode: outside,
              onPressed: () {},
              child: const Text('Outside'),
            ),
            IslandDrawer(
              open: true,
              maskClosable: false,
              onClose: () => closes++,
              title: const Text('Locked'),
              child: IslandButton(
                focusNode: inside,
                onPressed: () {},
                child: const Text('Inside'),
              ),
            ),
          ],
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tapAt(const Offset(30, 300));
    await t.pumpAndSettle();
    expect(closes, 0);
    for (var i = 0; i < 6; i++) {
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      expect(outside.hasFocus, isFalse);
    }
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(closes, 1);
  });
}
