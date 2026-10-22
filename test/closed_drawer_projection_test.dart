import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'Closed retained Drawer exposes no empty full-screen semantic interception surface',
    (t) async {
      final semantics = t.ensureSemantics();
      try {
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            home: IslandDrawerHost(
              child: Scaffold(
                body: Column(
                  children: [
                    IslandButton(
                      onPressed: () {},
                      child: const Text('Underlying action'),
                    ),
                    const IslandDrawer(
                      open: false,
                      onClose: null,
                      child: Text('Retained body'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final emptyScreens = <SemanticsNode>[];
        void inspect(SemanticsNode node) {
          final data = node.getSemanticsData();
          if (!node.hasChildren &&
              data.label.isEmpty &&
              data.value.isEmpty &&
              node.rect.width >= 800 &&
              node.rect.height >= 600)
            emptyScreens.add(node);
          node.visitChildren((child) {
            inspect(child);
            return true;
          });
        }

        inspect(
          t
              .binding
              .renderViews
              .single
              .owner!
              .semanticsOwner!
              .rootSemanticsNode!,
        );
        expect(
          emptyScreens,
          isEmpty,
          reason: 'A retained closed panel must not publish an empty viewport above an actionable host.',
        );
        expect(find.text('Underlying action'), findsOneWidget);
        expect(find.text('Retained body'), findsNothing);
      } finally {
        semantics.dispose();
      }
    },
  );
}
