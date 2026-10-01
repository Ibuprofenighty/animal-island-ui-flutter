import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

class _ListenerCountingFocusNode extends FocusNode {
  int listenerAdds = 0;
  int listenerRemoves = 0;

  @override
  void addListener(VoidCallback listener) {
    listenerAdds++;
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listenerRemoves++;
    super.removeListener(listener);
  }
}

void main() {
  testWidgets(
    'N09 borrowed InteractiveRegion nodes detach through 100 replacements',
    (tester) async {
      final List<_ListenerCountingFocusNode> nodes = List.generate(
        101,
        (_) => _ListenerCountingFocusNode(),
      );
      FocusNode current = nodes.first;
      late StateSetter updateHarness;
      final List<bool> focusChanges = <bool>[];

      await tester.pumpWidget(
        MaterialApp(
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                updateHarness = setState;
                return InteractiveRegion(
                  focusNode: current,
                  onPressed: () {},
                  enableHaptics: false,
                  onFocusChanged: focusChanges.add,
                  semanticLabel: 'Focus swap target',
                  child: const Text('Focus swap'),
                );
              },
            ),
          ),
        ),
      );

      for (int index = 1; index < nodes.length; index++) {
        final _ListenerCountingFocusNode previous = nodes[index - 1];
        updateHarness(() => current = nodes[index]);
        await tester.pump();
        expect(
          previous.listenerAdds,
          previous.listenerRemoves,
          reason: 'Node $index must release every listener before replacement',
        );
        expect(nodes[index].listenerAdds, greaterThan(0));
      }

      nodes.last.requestFocus();
      await tester.pump();
      nodes.last.unfocus();
      await tester.pump();
      expect(focusChanges, <bool>[true, false]);

      await tester.pumpWidget(const SizedBox.shrink());
      expect(nodes.last.listenerAdds, nodes.last.listenerRemoves);
      for (final _ListenerCountingFocusNode node in nodes) {
        node.requestFocus();
        node.unfocus();
        node.dispose();
      }
    },
  );

  testWidgets(
    'N09 AnimalInput transfers its effective focus owner and never disposes borrowed nodes',
    (tester) async {
      final TextEditingController controller = TextEditingController(
        text: 'focus-owned input',
      );
      final _ListenerCountingFocusNode first = _ListenerCountingFocusNode();
      final _ListenerCountingFocusNode second = _ListenerCountingFocusNode();
      FocusNode? suppliedNode;
      late StateSetter updateHarness;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                updateHarness = setState;
                return AnimalInput(
                  controller: controller,
                  focusNode: suppliedNode,
                  clearable: true,
                );
              },
            ),
          ),
        ),
      );

      final FocusNode internalNode = tester
          .widget<TextField>(find.byType(TextField))
          .focusNode!;
      updateHarness(() => suppliedNode = first);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode,
        same(first),
        reason: 'null-to-external uses the borrowed node immediately',
      );

      updateHarness(() => suppliedNode = second);
      await tester.pump();
      expect(first.listenerAdds, first.listenerRemoves);

      updateHarness(() => suppliedNode = null);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).focusNode,
        same(internalNode),
        reason: 'external-to-null restores the owned internal node',
      );
      expect(second.listenerAdds, second.listenerRemoves);

      await tester.pumpWidget(const SizedBox.shrink());
      first.requestFocus();
      first.unfocus();
      second.requestFocus();
      second.unfocus();
      expect(controller.text, 'focus-owned input');

      first.dispose();
      second.dispose();
      controller.dispose();
    },
  );
}
