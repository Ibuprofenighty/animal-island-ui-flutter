import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Drawer cursor never owns panel actions or mask dismissal', (
    t,
  ) async {
    var open = true, actions = 0, closes = 0;
    await t.pumpWidget(
      MaterialApp(
        home: IslandDrawerHost(
          child: StatefulBuilder(
            builder: (context, set) => IslandDrawer(
              open: open,
              semanticLabel: 'Settings',
              title: const Text('Settings'),
              onClose: () {
                closes++;
                set(() => open = false);
              },
              child: IslandButton(
                onPressed: () => actions++,
                child: const Text('Save'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(find.byType(IslandCursor), findsOneWidget);
    final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(600, 200));
    await t.pumpAndSettle();
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(actions, 1);
    expect(closes, 0);
    await mouse.moveTo(const Offset(30, 300));
    await t.pumpAndSettle();
    await t.tapAt(const Offset(30, 300));
    await t.pumpAndSettle();
    expect(closes, 1);
    expect(find.text('Settings'), findsNothing);
    await mouse.removePointer();
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Drawer explicitly names a dialog without reading its title widget',
    (t) async {
      final handle = t.ensureSemantics();
      try {
        await t.pumpWidget(
          MaterialApp(
            home: IslandDrawerHost(
              child: IslandDrawer(
                open: true,
                semanticLabel: 'Preferences',
                title: const Text('Opaque heading'),
                onClose: () {},
                child: const Text('Body'),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final nodes = <SemanticsNode>[];
        void visit(SemanticsNode n) {
          nodes.add(n);
          n.visitChildren((child) {
            visit(child);
            return true;
          });
        }

        visit(
          t
              .binding
              .renderViews
              .single
              .owner!
              .semanticsOwner!
              .rootSemanticsNode!,
        );
        final dialog = nodes.singleWhere(
          (n) => n.getSemanticsData().role == ui.SemanticsRole.dialog,
        );
        expect(dialog.getSemanticsData().label, 'Preferences');
        final buttons = nodes
            .where((n) => n.getSemanticsData().flagsCollection.isButton)
            .toList();
        expect(buttons, hasLength(1));
        expect(buttons.single.getSemanticsData().label, '关闭');
        expect(
          nodes.any(
            (n) =>
                n.getSemanticsData().headingLevel == 2 &&
                n.getSemanticsData().label == 'Opaque heading',
          ),
          isTrue,
        );
      } finally {
        handle.dispose();
      }
    },
  );
  testWidgets(
    'Drawer exit follows CSS elapsed-time curve rather than reversing entrance easing',
    (t) async {
      late StateSetter change;
      var open = true;
      await t.pumpWidget(
        MaterialApp(
          home: IslandDrawerHost(
            child: StatefulBuilder(
              builder: (context, set) {
                change = set;
                return IslandDrawer(
                  open: open,
                  onClose: () {},
                  child: const Text('Body'),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      change(() => open = false);
      await t.pump();
      await t.pump(const Duration(milliseconds: 180));
      final translation = t.widget<FractionalTranslation>(
        find
            .ancestor(
              of: find.text('Body'),
              matching: find.byType(FractionalTranslation),
            )
            .first,
      );
      expect(
        translation.translation.dx,
        closeTo(const Cubic(.2, 0, .2, 1).transform(.5), .001),
      );
      await t.pumpAndSettle();
      expect(find.text('Body'), findsNothing);
    },
  );
}
