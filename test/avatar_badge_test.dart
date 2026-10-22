import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(
    body: Align(alignment: Alignment.topLeft, child: child),
  ),
);
void main() {
  testWidgets(
    'Avatar group defaults never override explicit child settings or state on reorder',
    (t) async {
      var reversed = false, clicks = 0;
      late StateSetter update;
      const a = ValueKey('a'), b = ValueKey('b');
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              final children = <Widget>[
                const IslandAvatar(key: a, child: Text('A')),
                const IslandAvatar(
                  key: b,
                  dimension: 64,
                  shape: IslandAvatarShape.circle,
                  child: Text('B', style: TextStyle(color: Colors.red)),
                ),
                IslandButton(
                  key: const ValueKey('action'),
                  onPressed: () => clicks++,
                  child: const Text('Action'),
                ),
              ];
              return IslandAvatarGroup(
                size: IslandSize.small,
                shape: IslandAvatarShape.square,
                children: reversed ? children.reversed.toList() : children,
              );
            },
          ),
        ),
      );
      expect(t.getSize(find.byKey(a)), const Size(32, 32));
      expect(t.getSize(find.byKey(b)), const Size(64, 64));
      final state = t.state(find.byKey(a));
      expect(t.widget<Text>(find.text('B')).style!.color, Colors.red);
      await t.tap(find.text('Action'));
      await t.pump();
      expect(clicks, 1);
      update(() => reversed = true);
      await t.pump();
      expect(identical(state, t.state(find.byKey(a))), isTrue);
      expect(t.getSize(find.byKey(b)), const Size(64, 64));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Avatar image failure notifies once, resets with source and allows fallback refusal',
    (t) async {
      var errors = 0;
      var path = 'missing-first.png';
      var allow = true;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandAvatar(
                image: AssetImage(path),
                child: const Text('Fallback'),
                onImageError: (_, _) {
                  errors++;
                  return allow;
                },
              );
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(errors, 1);
      expect(find.text('Fallback'), findsOneWidget);
      update(() => allow = false);
      await t.pumpAndSettle();
      expect(errors, 1);
      update(() => path = 'missing-next.png');
      await t.pumpAndSettle();
      expect(errors, 2);
      expect(find.text('Fallback'), findsNothing);
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Badge overflow, zero, empty and custom slot retain wrapped action',
    (t) async {
      var clicks = 0;
      await t.pumpWidget(
        host(
          Wrap(
            spacing: 20,
            children: [
              const IslandBadge(count: 100),
              const IslandBadge(count: 0),
              const IslandBadge(count: 0, showZero: true),
              const IslandBadge(text: '  '),
              IslandBadge(
                dot: true,
                child: IslandButton(
                  onPressed: () => clicks++,
                  child: const Text('Open'),
                ),
              ),
              const IslandBadge(indicator: Icon(Icons.star, color: Colors.red)),
            ],
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('99+'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(t.widget<Icon>(find.byIcon(Icons.star)).color, Colors.red);
      await t.tap(find.text('Open'));
      expect(clicks, 1);
      expect(t.takeException(), isNull);
    },
  );
}
