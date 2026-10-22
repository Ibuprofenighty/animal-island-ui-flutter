import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(IslandNotificationsController controller) => MaterialApp(
  home: Scaffold(
    body: IslandNotifications(
      controller: controller,
      child: const SizedBox.expand(),
    ),
  ),
);
void main() {
  testWidgets(
    'custom close content stays on one line and retains state through focus',
    (t) async {
      final controller = IslandNotificationsController();
      addTearDown(controller.dispose);
      await t.pumpWidget(host(controller));
      var body = 0, dismissed = 0;
      controller.show(
        IslandNotification(
          message: const Text('Body'),
          duration: Duration.zero,
          onPressed: () => body++,
          onDismiss: () => dismissed++,
          closeIcon: const _CloseContent(),
        ),
      );
      await t.pumpAndSettle();
      final original = t.state(find.byType(_CloseContent));
      final close = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == '关闭',
      );
      expect(t.getSize(close).width, 22);
      expect(t.getSize(find.text('CLOSE')).width, greaterThan(22));
      expect(t.getCenter(find.text('CLOSE')), t.getCenter(close));
      expect(t.getSize(find.text('CLOSE')).height, closeTo(11, .01));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(t.state(find.byType(_CloseContent)), same(original));
      expect(t.getSize(find.text('CLOSE')).height, closeTo(11, .01));
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect((body, dismissed), (0, 1));
      expect(find.text('Body'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'dismissed handles cannot revive; new generation with same ID is isolated',
    (t) async {
      final controller = IslandNotificationsController();
      addTearDown(controller.dispose);
      await t.pumpWidget(host(controller));
      var dismissed = 0, closed = 0;
      final first = controller.show(
        IslandNotification(
          message: const Text('0%'),
          duration: Duration.zero,
          onDismiss: () => dismissed++,
          onClose: () => closed++,
        ),
        id: 'upload',
      );
      await t.pumpAndSettle();
      first.close();
      expect(first.isOpen, isFalse);
      expect(dismissed, 1);
      expect(closed, 0);
      expect(
        first.update(const IslandNotification(message: Text('50%'))),
        isFalse,
      );
      first.close();
      await t.pump(const Duration(milliseconds: 251));
      await t.pumpAndSettle();
      expect(closed, 1);
      expect(find.text('0%'), findsNothing);
      final second = controller.show(
        const IslandNotification(message: Text('new'), duration: Duration.zero),
        id: 'upload',
      );
      expect(second.isOpen, isTrue);
      first.close();
      expect(
        first.update(const IslandNotification(message: Text('old'))),
        isFalse,
      );
      await t.pumpAndSettle();
      expect(find.text('new'), findsOneWidget);
    },
  );
  testWidgets('updates restart expiry and preserve child action independence', (
    t,
  ) async {
    final controller = IslandNotificationsController();
    addTearDown(controller.dispose);
    await t.pumpWidget(host(controller));
    var body = 0, child = 0;
    final handle = controller.show(
      IslandNotification(
        message: const Text('Body'),
        onPressed: () => body++,
        duration: const Duration(seconds: 1),
        action: IslandButton(
          onPressed: () => child++,
          child: const Text('Act'),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('Act'));
    await t.pump();
    expect(child, 1);
    expect(body, 0);
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pump();
    expect(child, 2);
    expect(body, 0);
    await t.tap(find.text('Body'));
    await t.pump();
    expect(body, 1);
    handle.update(
      const IslandNotification(
        message: Text('Updated'),
        duration: const Duration(seconds: 2),
      ),
    );
    await t.pump(const Duration(milliseconds: 1100));
    expect(handle.isOpen, isTrue);
    await t.pump(const Duration(milliseconds: 1000));
    expect(handle.isOpen, isFalse);
    await t.pumpAndSettle();
    expect(find.text('Updated'), findsNothing);
  });
  testWidgets(
    'close action never activates body; destroy preserves reentrant additions',
    (t) async {
      final controller = IslandNotificationsController();
      addTearDown(controller.dispose);
      await t.pumpWidget(host(controller));
      var body = 0;
      controller.show(
        IslandNotification(
          message: const Text('A'),
          onPressed: () => body++,
          duration: Duration.zero,
          onDismiss: () => controller.show(
            const IslandNotification(
              message: Text('Added'),
              duration: Duration.zero,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('×'));
      await t.pumpAndSettle();
      expect(body, 0);
      expect(find.text('Added'), findsOneWidget);
      controller.show(
        IslandNotification(
          message: const Text('B'),
          duration: Duration.zero,
          onDismiss: () => controller.show(
            const IslandNotification(
              message: Text('Survivor'),
              duration: Duration.zero,
            ),
          ),
        ),
      );
      controller.dismiss();
      await t.pumpAndSettle();
      expect(find.text('Added'), findsNothing);
      expect(find.text('Survivor'), findsOneWidget);
    },
  );
  testWidgets('six positions and bottom ordering remain viewport owned', (
    t,
  ) async {
    final controller = IslandNotificationsController();
    addTearDown(controller.dispose);
    await t.pumpWidget(host(controller));
    for (final p in IslandNotificationPosition.values) {
      controller.show(
        IslandNotification(
          message: Text(p.name),
          position: p,
          duration: Duration.zero,
        ),
      );
    }
    await t.pumpAndSettle();
    expect(
      t.getTopLeft(find.text('topLeft')).dx,
      lessThan(t.getTopLeft(find.text('topRight')).dx),
    );
    expect(
      t.getTopLeft(find.text('top')).dy,
      lessThan(t.getTopLeft(find.text('bottom')).dy),
    );
    final bottom = t.getTopLeft(find.text('bottom')).dy;
    controller.show(
      const IslandNotification(
        message: Text('second'),
        position: IslandNotificationPosition.bottom,
        duration: Duration.zero,
      ),
    );
    await t.pumpAndSettle();
    expect(t.getTopLeft(find.text('bottom')).dy, closeTo(bottom, .01));
    expect(t.getTopLeft(find.text('second')).dy, lessThan(bottom));
    await t.pumpWidget(const SizedBox());
    final handle = controller.show(
      const IslandNotification(
        message: Text('still owned'),
        duration: Duration.zero,
      ),
    );
    expect(handle.isOpen, isTrue);
  });
}

class _CloseContent extends StatefulWidget {
  const _CloseContent();
  @override
  State<_CloseContent> createState() => _CloseContentState();
}

class _CloseContentState extends State<_CloseContent> {
  @override
  Widget build(BuildContext context) => const Text(
    'CLOSE',
    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
  );
}
