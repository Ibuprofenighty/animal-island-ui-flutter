import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'Painting the software cursor adds no full-viewport semantic hit layer',
    (t) async {
      final handle = t.ensureSemantics();
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      try {
        var clicks = 0;
        await t.pumpWidget(
          MaterialApp(
            home: IslandCursor(
              child: Center(
                child: IslandButton(
                  onPressed: () => clicks++,
                  child: const Text('under cursor'),
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        int countNodes() {
          var count = 0;
          void visit(SemanticsNode node) {
            count++;
            node.visitChildren((child) {
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
          return count;
        }

        final before = countNodes();
        await mouse.addPointer(
          location: t.getCenter(find.text('under cursor')),
        );
        await t.pumpAndSettle();
        await mouse.moveTo(
          t.getCenter(find.text('under cursor')) + const Offset(2, 2),
        );
        await t.pumpAndSettle();
        expect(
          countNodes(),
          before,
          reason: 'A decorative cursor must not insert framework-wrapper semantics.',
        );
        await mouse.down(t.getCenter(find.text('under cursor')));
        await mouse.up();
        await t.pumpAndSettle();
        expect(clicks, 1);
        expect(find.bySemanticsLabel('under cursor'), findsOneWidget);
      } finally {
        await mouse.removePointer();
        handle.dispose();
      }
    },
  );
}
