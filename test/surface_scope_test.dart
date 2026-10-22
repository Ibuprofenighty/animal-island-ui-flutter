import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show foreground, readable;

void main() {
  testWidgets(
    'all notification surfaces provide readable action and custom close icon defaults in dark hosts',
    (t) async {
      final data = IslandTheme.create(brightness: Brightness.dark);
      for (final entry in {
        IslandNotificationType.success: const Color(0xfff5fae9),
        IslandNotificationType.info: const Color(0xffecf9f6),
        IslandNotificationType.warning: const Color(0xfffdf6d9),
        IslandNotificationType.error: const Color(0xfffde8e8),
      }.entries) {
        final controller = IslandNotificationsController();
        await t.pumpWidget(
          MaterialApp(
            theme: data,
            home: Scaffold(
              body: IslandThemeHost(
                data: data,
                child: IslandNotifications(
                  controller: controller,
                  child: const SizedBox(),
                ),
              ),
            ),
          ),
        );
        controller.show(
          IslandNotification(
            type: entry.key,
            duration: Duration.zero,
            message: const Text('Message'),
            action: IslandButton(
              variant: IslandButtonVariant.link,
              onPressed: () {},
              child: const Text('Action'),
            ),
            closeIcon: const Icon(Icons.close, key: ValueKey('close')),
          ),
        );
        await t.pump();
        await t.pumpAndSettle();
        readable(foreground(t, 'Action'), entry.value);
        readable(
          IconTheme.of(t.element(find.byKey(const ValueKey('close')))).color!,
          entry.value,
          minimum: 3,
        );
        await t.pumpWidget(const SizedBox());
        controller.dispose();
      }
    },
  );

  testWidgets(
    'fixed cream slots keep plain content and nested public actions readable after dark switch',
    (t) async {
      var data = IslandTheme.create();
      late StateSetter update;
      final edit = TextEditingController(text: 'retained');
      Widget slots() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Slot'),
          const Icon(Icons.star, key: ValueKey('icon')),
          IslandButton(
            variant: IslandButtonVariant.link,
            onPressed: () {},
            child: const Text('Link'),
          ),
          const Text('Explicit', style: TextStyle(color: Colors.purple)),
          IslandTextField(label: 'Editor', controller: edit),
        ],
      );
      for (final kind in ['drawer', 'modal', 'card', 'table', 'carousel']) {
        data = IslandTheme.create();
        await t.pumpWidget(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return MaterialApp(
                theme: data,
                home: Scaffold(
                  body: IslandThemeHost(
                    data: data,
                    child: Center(
                      child: switch (kind) {
                        'drawer' => IslandDrawerHost(
                          child: IslandDrawer(
                            open: true,
                            onClose: () {},
                            footer: slots(),
                            child: const Text('Body'),
                          ),
                        ),
                        'modal' => IslandModal(
                          child: const Text('Body'),
                          actions: [SizedBox(width: 260, child: slots())],
                        ),
                        'card' => IslandCard(
                          child: SizedBox(width: 260, child: slots()),
                        ),
                        'table' => IslandTable<int>(
                          rows: const [],
                          rowKey: (x) => x,
                          empty: slots(),
                          columns: [
                            IslandTableColumn(
                              id: 'x',
                              title: const Text('Header'),
                              cellBuilder: (_, x, i) => Text('$x'),
                            ),
                          ],
                        ),
                        _ => IslandCarousel<int>(
                          value: 1,
                          onChanged: (_) {},
                          items: [
                            IslandSlide(
                              value: 1,
                              child: SizedBox(width: 260, child: slots()),
                            ),
                          ],
                        ),
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await t.pumpAndSettle();
        final identity = t.state(find.byType(EditableText));
        update(() => data = IslandTheme.create(brightness: Brightness.dark));
        for (final ms in [0, 16, 50, 100, 200]) {
          await t.pump(Duration(milliseconds: ms));
          readable(foreground(t, 'Slot'), const Color(0xfff7f3df));
          readable(foreground(t, 'Link'), const Color(0xfff7f3df));
          final icon = t.element(find.byKey(const ValueKey('icon')));
          readable(
            IconTheme.of(icon).color!,
            const Color(0xfff7f3df),
            minimum: 3,
          );
          expect(foreground(t, 'Explicit'), Colors.purple);
          expect(t.state(find.byType(EditableText)), same(identity));
          expect(edit.text, 'retained');
        }
        await t.pumpWidget(const SizedBox());
      }
      edit.dispose();
    },
  );

  testWidgets(
    'owned colored slots give icons the readable role while preserving explicit icon colors',
    (t) async {
      const icon = Icon(Icons.star, key: ValueKey('role'), size: 12);
      final examples = <Widget, Color>{
        const IslandAvatar(icon: icon): const Color(0xffe6f9f6),
        const IslandBadge(color: IslandColorway.neutral, indicator: icon):
            const Color(0xffd4c4a8),
        const IslandTitle(child: icon): const Color(0xff27d039),
        const IslandCountUp(end: 2, prefix: icon, duration: Duration.zero):
            const Color(0xfff8f8f0),
        IslandCountdown(
          value: DateTime(2026, 10, 15, 0, 0, 10),
          now: () => DateTime(2026, 10, 15),
          prefix: icon,
        ): const Color(
          0xfff8f8f0,
        ),
        IslandTabs<int>(
          items: const [IslandTab(value: 1, label: icon, child: Text('Body'))],
          value: 1,
          onChanged: (_) {},
        ): IslandTokens.dark.leaf,
      };
      for (final e in examples.entries) {
        final data = IslandTheme.create(brightness: Brightness.dark);
        await t.pumpWidget(
          MaterialApp(
            theme: data,
            home: Scaffold(
              body: IslandThemeHost(
                data: data,
                child: Center(child: e.key),
              ),
            ),
          ),
        );
        await t.pump();
        await t.pump(const Duration(milliseconds: 400));
        readable(
          IconTheme.of(t.element(find.byKey(const ValueKey('role')))).color!,
          e.value,
          minimum: 3,
          reason: '${e.key.runtimeType}',
        );
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      }
      final data = IslandTheme.create();
      await t.pumpWidget(
        MaterialApp(
          theme: data,
          home: Scaffold(
            body: IslandThemeHost(
              data: data,
              child: IslandLoading(active: true, tip: icon),
            ),
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      readable(
        IconTheme.of(t.element(find.byKey(const ValueKey('role')))).color!,
        const Color(0xff0b101a),
        minimum: 3,
      );
      await t.pumpWidget(const SizedBox());
    },
  );
}
