import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  testWidgets(
    'hover-only card moves without acquiring a fake action or losing child state',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 260,
                child: IslandCard(
                  hoverable: true,
                  child: TextField(controller: null),
                ),
              ),
            ),
          ),
        ),
      );
      final fieldState = tester.state(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'retained');
      final before = tester.getTopLeft(find.byType(TextField));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byType(IslandCard)));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byType(TextField)).dy,
        closeTo(before.dy - 2, .01),
      );
      expect(tester.state(find.byType(TextField)), same(fieldState));
      expect(find.text('retained'), findsOneWidget);
      final semantics = tester.ensureSemantics();
      expect(
        tester
            .getSemantics(find.byType(IslandCard))
            .getSemanticsData()
            .flagsCollection
            .isButton,
        isFalse,
      );
      semantics.dispose();
      await mouse.removePointer();
    },
  );

  testWidgets(
    'card defaults do not override explicit descendants; nested button consumes activation',
    (tester) async {
      var parent = 0, child = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: IslandCard(
                pattern: IslandColorway.blue,
                onTap: () => parent++,
                child: Column(
                  children: [
                    const Text('explicit', style: TextStyle(color: Colors.red)),
                    IslandButton(
                      onPressed: () => child++,
                      child: const Text('nested'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('nested'));
      expect(child, 1);
      expect(parent, 0);
      expect(
        tester.widget<Text>(find.text('explicit')).style!.color,
        Colors.red,
      );
      await tester.tap(find.text('explicit'));
      expect(parent, 1);
    },
  );
}
