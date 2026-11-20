import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(IslandNotificationsController controller) => MaterialApp(
  locale: const Locale('zh'),
  localizationsDelegates: IslandLocalizations.delegates,
  supportedLocales: IslandLocalizations.supportedLocales,
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
  testWidgets('dismiss removes entries at once and fires callbacks once', (
    t,
  ) async {
    final controller = IslandNotificationsController();
    addTearDown(controller.dispose);
    await t.pumpWidget(host(controller));
    final log = <String>[];
    for (final name in ['A', 'B']) {
      controller.show(
        IslandNotification(
          message: Text(name),
          duration: Duration.zero,
          onDismiss: () => log.add('dismiss $name'),
          onClose: () => log.add('close $name'),
        ),
        id: name,
      );
    }
    await t.pumpAndSettle();
    controller
        .show(
          IslandNotification(
            message: const Text('Leaving'),
            duration: Duration.zero,
            onClose: () => log.add('close Leaving'),
          ),
          id: 'leaving',
        )
        .close();
    await t.pump(const Duration(milliseconds: 100));
    controller.dismiss('A');
    expect(log, ['dismiss A', 'close A']);
    await t.pump();
    expect(find.text('A'), findsNothing);
    expect(find.text('B'), findsOneWidget);
    controller.dismiss();
    // Reference destroy: no 250ms exit; already-leaving entries end too.
    expect(log, [
      'dismiss A',
      'close A',
      'dismiss B',
      'close B',
      'close Leaving',
    ]);
    await t.pump();
    expect(find.text('B'), findsNothing);
    expect(find.text('Leaving'), findsNothing);
    await t.pump(const Duration(milliseconds: 300));
    expect(log, hasLength(5));
    expect(t.takeException(), isNull);
  });
  testWidgets('clickable hover lifts 1px; focus outline keeps card geometry', (
    t,
  ) async {
    final controller = IslandNotificationsController();
    addTearDown(controller.dispose);
    await t.pumpWidget(host(controller));
    controller.show(
      IslandNotification(
        message: const Text('Click'),
        duration: Duration.zero,
        onPressed: () {},
      ),
    );
    await t.pumpAndSettle();
    final rest = t.getRect(find.text('Click'));
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(rest.center);
    await t.pump();
    await t.pump(const Duration(milliseconds: 100));
    final mid = t.getRect(find.text('Click')).top - rest.top;
    expect(mid, inExclusiveRange(-1, 0));
    await t.pumpAndSettle();
    expect(t.getRect(find.text('Click')).top - rest.top, closeTo(-1, .001));
    await mouse.moveTo(Offset.zero);
    await t.pumpAndSettle();
    expect(t.getRect(find.text('Click')), rest);
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    expect(t.getRect(find.text('Click')), rest);
    await mouse.removePointer();
  });
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
