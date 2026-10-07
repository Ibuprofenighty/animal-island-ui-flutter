// N19 notification queue oracles: one synchronous per-host, per-placement
// queue with 3 shown and 50 waiting, business keys separate from
// occurrences, and exactly-once onClose across every close path.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: home,
);

/// A host whose child exposes a context under it.
Widget _host(void Function(BuildContext) capture, {Key? key}) =>
    AnimalOverlayHost(
      key: key,
      child: Builder(
        builder: (context) {
          capture(context);
          return const SizedBox.expand();
        },
      ),
    );

Future<BuildContext> _pumpHost(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(_app(_host((c) => context = c)));
  return context;
}

/// The placement stacks rendered in the host overlay: each non-empty
/// placement is rendered by exactly one host occurrence holding one stack.
Finder _placementStacks() => find.descendant(
  of: find.byType(AnimalOverlayHost),
  matching: find.byType(SingleChildScrollView),
);

Finder _dismissButton() => find
    .descendant(
      of: find.byType(AnimalNotificationCard),
      matching: find.byType(AnimalIcon),
    )
    .last;

void main() {
  group('N19 notification queue', () {
    testWidgets(
      'NOT01 ten same-frame opens share one container: 3 active, 7 waiting',
      (tester) async {
        final BuildContext context = await _pumpHost(tester);

        final List<AnimalNotificationHandle> handles = [
          for (var i = 1; i <= 10; i++)
            AnimalNotification.open(
              context,
              message: Text('Parcel $i'),
              duration: null,
            ),
        ];

        // Registration is synchronous: no frame has run since the opens.
        expect(
          handles.map((h) => h.status).toList(),
          <AnimalNotificationStatus>[
            AnimalNotificationStatus.active,
            AnimalNotificationStatus.active,
            AnimalNotificationStatus.active,
            for (var i = 0; i < 7; i++) AnimalNotificationStatus.waiting,
          ],
          reason: 'the placement queue must be registered before the next open',
        );

        await tester.pump();
        expect(_placementStacks(), findsOneWidget);
        expect(find.byType(AnimalNotificationCard), findsNWidgets(3));
        expect(find.text('Parcel 1'), findsOneWidget);
        expect(find.text('Parcel 3'), findsOneWidget);
        expect(find.text('Parcel 4'), findsNothing);

        // Closing a shown notification promotes the oldest waiting one.
        handles[1].close();
        expect(handles[1].status, AnimalNotificationStatus.closed);
        expect(handles[3].status, AnimalNotificationStatus.active);
        expect(handles[4].status, AnimalNotificationStatus.waiting);
        await tester.pump();
        expect(find.text('Parcel 4'), findsOneWidget);
        expect(_placementStacks(), findsOneWidget);
      },
    );

    testWidgets(
      'NOT01 the 51st waiting notification is rejected and no older one is dropped',
      (tester) async {
        final BuildContext context = await _pumpHost(tester);
        var closes = 0;
        final List<AnimalNotificationHandle> accepted = [
          for (var i = 0; i < 53; i++)
            AnimalNotification.open(
              context,
              message: Text('Item $i'),
              duration: null,
              onClose: () => closes++,
            ),
        ];
        var rejectedCloses = 0;
        final AnimalNotificationHandle rejected = AnimalNotification.open(
          context,
          message: const Text('One too many'),
          duration: null,
          onClose: () => rejectedCloses++,
        );

        expect(rejected.status, AnimalNotificationStatus.rejected);
        expect(
          accepted.where((h) => h.status == AnimalNotificationStatus.active),
          hasLength(3),
        );
        expect(
          accepted.where((h) => h.status == AnimalNotificationStatus.waiting),
          hasLength(50),
        );

        rejected.close();
        expect(rejected.status, AnimalNotificationStatus.rejected);
        expect(rejectedCloses, 0, reason: 'a rejected item never opened');
        expect(closes, 0);

        // A rejected item does not occupy a slot; a freed slot is reusable.
        accepted.first.close();
        final AnimalNotificationHandle next = AnimalNotification.open(
          context,
          message: const Text('After a slot frees'),
          duration: null,
        );
        expect(next.status, AnimalNotificationStatus.waiting);
        expect(closes, 1);

        // Other placements have their own limits.
        final AnimalNotificationHandle bottom = AnimalNotification.open(
          context,
          message: const Text('Bottom'),
          placement: AnimalNotificationPlacement.bottom,
          duration: null,
        );
        expect(bottom.status, AnimalNotificationStatus.active);
        await tester.pumpWidget(const SizedBox.shrink());
        expect(closes, 53);
        expect(rejectedCloses, 0);
      },
    );

    testWidgets(
      'NOT02 two hosts keep separate queues for the same placement and key',
      (tester) async {
        late BuildContext a;
        late BuildContext b;
        const Key hostA = ValueKey<String>('host-a');
        const Key hostB = ValueKey<String>('host-b');
        await tester.pumpWidget(
          _app(
            Row(
              children: [
                Expanded(child: _host((c) => a = c, key: hostA)),
                Expanded(child: _host((c) => b = c, key: hostB)),
              ],
            ),
          ),
        );

        final AnimalNotificationHandle inA = AnimalNotification.open(
          a,
          key: 'shared',
          message: const Text('Notification for A'),
          duration: null,
        );
        final AnimalNotificationHandle inB = AnimalNotification.open(
          b,
          key: 'shared',
          message: const Text('Notification for B'),
          duration: null,
        );
        await tester.pump();

        expect(identical(inA, inB), isFalse);
        expect(
          find.descendant(
            of: find.byKey(hostA),
            matching: find.text('Notification for A'),
          ),
          findsOneWidget,
          reason: 'App A should still show Notification for A',
        );
        expect(
          find.descendant(
            of: find.byKey(hostB),
            matching: find.text('Notification for B'),
          ),
          findsOneWidget,
        );

        AnimalNotification.closeAll(a);
        await tester.pump();
        expect(inA.status, AnimalNotificationStatus.closed);
        expect(inB.status, AnimalNotificationStatus.active);
        expect(find.text('Notification for B'), findsOneWidget);
        expect(find.text('Notification for A'), findsNothing);
      },
    );

    testWidgets(
      'NOT03 a same-key update replaces content in place and restarts its duration',
      (tester) async {
        final BuildContext context = await _pumpHost(tester);
        final AnimalNotificationHandle first = AnimalNotification.open(
          context,
          key: 'upload',
          message: const Text('Uploading 10%'),
          duration: const Duration(seconds: 2),
        );
        AnimalNotification.open(
          context,
          message: const Text('Neighbour'),
          duration: null,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 1500));

        final AnimalNotificationHandle updated = AnimalNotification.open(
          context,
          key: 'upload',
          message: const Text('Uploading 90%'),
          duration: const Duration(seconds: 2),
        );
        expect(identical(updated, first), isTrue);
        await tester.pump();
        expect(find.text('Uploading 90%'), findsOneWidget);
        expect(find.text('Uploading 10%'), findsNothing);
        expect(find.byType(AnimalNotificationCard), findsNWidgets(2));
        // No reordering: the updated card stays above its neighbour.
        expect(
          tester.getTopLeft(find.text('Uploading 90%')).dy,
          lessThan(tester.getTopLeft(find.text('Neighbour')).dy),
        );

        // 2.5 s after the first open: the first duration would have ended.
        await tester.pump(const Duration(milliseconds: 1000));
        expect(
          first.status,
          AnimalNotificationStatus.active,
          reason: 'the old timer must not close the updated notification',
        );
        // 2 s after the update the restarted duration ends.
        await tester.pump(const Duration(milliseconds: 1001));
        expect(first.status, AnimalNotificationStatus.closed);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );

    testWidgets(
      'NOT03 a persistent notification stays and an update to persistent cancels the timer',
      (tester) async {
        final BuildContext context = await _pumpHost(tester);
        final AnimalNotificationHandle persistent = AnimalNotification.open(
          context,
          message: const Text('Stays'),
          duration: null,
        );
        final AnimalNotificationHandle timed = AnimalNotification.open(
          context,
          key: 'timed',
          message: const Text('Timed'),
          duration: const Duration(seconds: 1),
        );
        AnimalNotification.open(
          context,
          key: 'timed',
          message: const Text('Now persistent'),
          duration: null,
        );
        await tester.pump(const Duration(hours: 1));
        expect(persistent.status, AnimalNotificationStatus.active);
        expect(timed.status, AnimalNotificationStatus.active);
        expect(find.text('Now persistent'), findsOneWidget);
        expect(find.text('Stays'), findsOneWidget);
      },
    );

    testWidgets(
      'NOT03 reusing a key after close opens a new occurrence with its own onClose',
      (tester) async {
        final BuildContext context = await _pumpHost(tester);
        var firstCloses = 0;
        var secondCloses = 0;
        final AnimalNotificationHandle first = AnimalNotification.open(
          context,
          key: 'mail',
          message: const Text('Mail 1'),
          duration: null,
          onClose: () => firstCloses++,
        );
        first.close();
        final AnimalNotificationHandle second = AnimalNotification.open(
          context,
          key: 'mail',
          message: const Text('Mail 2'),
          duration: null,
          onClose: () => secondCloses++,
        );
        expect(identical(first, second), isFalse);
        expect(first.status, AnimalNotificationStatus.closed);
        expect(second.status, AnimalNotificationStatus.active);
        expect((firstCloses, secondCloses), (1, 0));

        await tester.pump();
        expect(find.text('Mail 2'), findsOneWidget);
        second.close();
        first.close();
        expect((firstCloses, secondCloses), (1, 1));
      },
    );

    testWidgets('NOT04 onClose runs exactly once across every close path', (
      tester,
    ) async {
      BuildContext context = await _pumpHost(tester);
      final Map<String, int> closes = <String, int>{};
      AnimalNotificationHandle open(String name, {Duration? duration}) =>
          AnimalNotification.open(
            context,
            message: Text(name),
            duration: duration,
            onClose: () => closes[name] = (closes[name] ?? 0) + 1,
          );

      // Close button, then every other path.
      final AnimalNotificationHandle clicked = open('clicked');
      await tester.pump();
      await tester.tap(_dismissButton());
      await tester.pump();
      clicked.close();
      AnimalNotification.closeAll(context);
      expect(
        closes['clicked'],
        1,
        reason: 'onClose must run exactly once per occurrence',
      );

      // Timeout, then the handle.
      final AnimalNotificationHandle timed = open(
        'timed',
        duration: const Duration(seconds: 1),
      );
      await tester.pump(const Duration(milliseconds: 1001));
      expect(timed.status, AnimalNotificationStatus.closed);
      timed.close();
      expect(closes['timed'], 1);

      // Handle twice, then closeAll twice.
      final AnimalNotificationHandle handled = open('handled');
      handled.close();
      handled.close();
      AnimalNotification.closeAll(context);
      AnimalNotification.closeAll(context);
      expect(closes['handled'], 1);

      // Host unmount closes shown and waiting occurrences once each.
      final List<AnimalNotificationHandle> unmounted = [
        for (var i = 0; i < 5; i++) open('unmounted $i'),
      ];
      expect(unmounted.last.status, AnimalNotificationStatus.waiting);
      await tester.pumpWidget(const SizedBox.shrink());
      for (final AnimalNotificationHandle handle in unmounted) {
        expect(handle.status, AnimalNotificationStatus.closed);
        handle.close();
      }
      for (var i = 0; i < 5; i++) {
        expect(closes['unmounted $i'], 1);
      }
      expect(closes['clicked'], 1);
      expect(closes['timed'], 1);
      expect(closes['handled'], 1);

      // A fresh host starts with an empty queue.
      context = await _pumpHost(tester);
      expect(open('fresh').status, AnimalNotificationStatus.active);
      await tester.pump();
      expect(find.byType(AnimalNotificationCard), findsOneWidget);
    });

    testWidgets('NOT04 onClose may re-enter open and close', (tester) async {
      final BuildContext context = await _pumpHost(tester);
      late AnimalNotificationHandle victim;
      AnimalNotificationHandle? reopened;
      var victimCloses = 0;
      final AnimalNotificationHandle trigger = AnimalNotification.open(
        context,
        message: const Text('Trigger'),
        duration: null,
        onClose: () {
          victim.close();
          reopened = AnimalNotification.open(
            context,
            message: const Text('Reopened'),
            duration: null,
          );
        },
      );
      victim = AnimalNotification.open(
        context,
        message: const Text('Victim'),
        duration: null,
        onClose: () => victimCloses++,
      );

      AnimalNotification.closeAll(context);
      expect(trigger.status, AnimalNotificationStatus.closed);
      expect(victim.status, AnimalNotificationStatus.closed);
      expect(victimCloses, 1);
      expect(
        reopened?.status,
        AnimalNotificationStatus.active,
        reason: 'an occurrence opened during closeAll stays open',
      );
      await tester.pump();
      expect(find.text('Reopened'), findsOneWidget);
      expect(find.text('Trigger'), findsNothing);
      expect(_placementStacks(), findsOneWidget);
    });

    testWidgets('closeAll with a placement closes only that placement', (
      tester,
    ) async {
      final BuildContext context = await _pumpHost(tester);
      final AnimalNotificationHandle top = AnimalNotification.open(
        context,
        message: const Text('Top'),
        duration: null,
      );
      final AnimalNotificationHandle bottom = AnimalNotification.open(
        context,
        message: const Text('Bottom'),
        placement: AnimalNotificationPlacement.bottomLeft,
        duration: null,
      );
      await tester.pump();
      expect(_placementStacks(), findsNWidgets(2));
      AnimalNotification.closeAll(
        context,
        placement: AnimalNotificationPlacement.bottomLeft,
      );
      expect(top.status, AnimalNotificationStatus.active);
      expect(bottom.status, AnimalNotificationStatus.closed);
      await tester.pump();
      expect(_placementStacks(), findsOneWidget);
      expect(find.text('Top'), findsOneWidget);
    });

    testWidgets('NOT04 a swipe closes the notification once', (tester) async {
      final BuildContext context = await _pumpHost(tester);
      var closes = 0;
      final AnimalNotificationHandle handle = AnimalNotification.open(
        context,
        message: const Text('Swipe me'),
        duration: null,
        onClose: () => closes++,
      );
      await tester.pump();
      await tester.drag(find.text('Swipe me'), const Offset(600, 0));
      await tester.pumpAndSettle();
      expect(handle.status, AnimalNotificationStatus.closed);
      expect(closes, 1);
      expect(find.byType(AnimalNotificationCard), findsNothing);
      expect(_placementStacks(), findsNothing);
    });

    testWidgets('NOT04 closing the host occurrences closes every queued '
        'notification once', (tester) async {
      final BuildContext context = await _pumpHost(tester);
      var closes = 0;
      final List<AnimalNotificationHandle> handles = [
        for (var i = 0; i < 5; i++)
          AnimalNotification.open(
            context,
            message: Text('Queued $i'),
            duration: null,
            onClose: () => closes++,
          ),
        AnimalNotification.open(
          context,
          message: const Text('Bottom'),
          placement: AnimalNotificationPlacement.bottom,
          duration: null,
          onClose: () => closes++,
        ),
      ];
      await tester.pump();
      expect(_placementStacks(), findsNWidgets(2));

      // Something other than the queue closes the placement containers.
      AnimalOverlayHost.of(context).closeAll();
      await tester.pump();
      for (final AnimalNotificationHandle handle in handles) {
        expect(handle.status, AnimalNotificationStatus.closed);
      }
      expect(closes, 6);
      expect(_placementStacks(), findsNothing);
      expect(find.byType(AnimalNotificationCard), findsNothing);
    });

    testWidgets('NOT05 with reduced motion a notification appears in place', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: _host((c) => context = c),
          ),
        ),
      );
      AnimalNotification.open(
        context,
        message: const Text('Still'),
        duration: null,
      );
      await tester.pump();
      final FadeTransition fade = tester.widget(
        find
            .ancestor(
              of: find.text('Still'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      final SlideTransition slide = tester.widget(
        find
            .ancestor(
              of: find.text('Still'),
              matching: find.byType(SlideTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);
      expect(slide.position.value, Offset.zero);
    });

    testWidgets('hover and focus pause the duration timer', (tester) async {
      final BuildContext context = await _pumpHost(tester);
      final AnimalNotificationHandle handle = AnimalNotification.open(
        context,
        message: const Text('Hover me'),
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final TestGesture mouse = await tester.createGesture(
        kind: PointerDeviceKind.mouse,
      );
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('Hover me')));
      await tester.pump(const Duration(seconds: 5));
      expect(handle.status, AnimalNotificationStatus.active);

      await mouse.moveTo(Offset.zero);
      await tester.pump(const Duration(milliseconds: 100));
      expect(handle.status, AnimalNotificationStatus.active);
      await tester.pump(const Duration(seconds: 1));
      expect(handle.status, AnimalNotificationStatus.closed);

      // Focus inside the card pauses it as well.
      final AnimalNotificationHandle focused = AnimalNotification.open(
        context,
        message: const Text('Focus me'),
        duration: const Duration(seconds: 1),
      );
      await tester.pump();
      final FocusNode closeFocus = Focus.of(
        tester.element(
          find
              .descendant(
                of: find.byType(AnimalNotificationCard),
                matching: find.byType(AnimalIcon),
              )
              .last,
        ),
      );
      closeFocus.requestFocus();
      await tester.pump(const Duration(seconds: 5));
      expect(focused.status, AnimalNotificationStatus.active);
      closeFocus.unfocus();
      await tester.pump(const Duration(milliseconds: 1001));
      expect(focused.status, AnimalNotificationStatus.closed);
    });

    testWidgets('NOT05 six placements fit a 320 logical pixel host', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final BuildContext context = await _pumpHost(tester);
      for (final AnimalNotificationPlacement placement
          in AnimalNotificationPlacement.values) {
        AnimalNotification.open(
          context,
          message: Text('Placement ${placement.name}'),
          description: const Text(
            'A long description that must wrap inside a narrow host instead '
            'of overflowing a fixed card width.',
          ),
          placement: placement,
          duration: null,
        );
      }
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      expect(find.byType(AnimalNotificationCard), findsNWidgets(6));
      for (final Element card
          in find.byType(AnimalNotificationCard).evaluate()) {
        final Rect rect = tester.getRect(find.byWidget(card.widget));
        expect(rect.left, greaterThanOrEqualTo(0));
        expect(rect.right, lessThanOrEqualTo(320));
        expect(rect.width, lessThanOrEqualTo(320 - 2 * 16));
      }
    });

    testWidgets('NOT05 the close button is keyboard operable', (tester) async {
      final BuildContext context = await _pumpHost(tester);
      var closes = 0;
      final AnimalNotificationHandle handle = AnimalNotification.open(
        context,
        message: const Text('Morning announcement'),
        duration: null,
        onClose: () => closes++,
      );
      await tester.pump();
      final Element icon = find
          .descendant(
            of: find.byType(AnimalNotificationCard),
            matching: find.byType(AnimalIcon),
          )
          .evaluate()
          .last;
      Focus.of(icon).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(handle.status, AnimalNotificationStatus.closed);
      expect(closes, 1);
      expect(find.text('Morning announcement'), findsNothing);
    });

    testWidgets('NOT05 each notification is one stable live region', (
      tester,
    ) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final BuildContext context = await _pumpHost(tester);
      AnimalNotification.open(
        context,
        message: const Text('Announce once'),
        duration: null,
      );

      List<SemanticsNode> liveRegions() => find.semantics
          .byPredicate(
            (node) => node.getSemanticsData().flagsCollection.isLiveRegion,
          )
          .evaluate()
          .toList();

      await tester.pump();
      final List<SemanticsNode> first = liveRegions();
      expect(first, hasLength(1));
      final int id = first.single.id;
      // Entrance animation frames keep the same node; nothing re-announces.
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 40));
        final List<SemanticsNode> now = liveRegions();
        expect(now, hasLength(1));
        expect(now.single.id, id);
      }
      semantics.dispose();
    });

    testWidgets('1000 open and close rounds leave nothing retained', (
      tester,
    ) async {
      final BuildContext context = await _pumpHost(tester);
      var closes = 0;
      AnimalNotificationHandle? previous;
      for (var round = 0; round < 1000; round++) {
        final AnimalNotificationHandle handle = AnimalNotification.open(
          context,
          key: 'round',
          message: Text('Round $round'),
          placement: AnimalNotificationPlacement
              .values[round % AnimalNotificationPlacement.values.length],
          duration: null,
          onClose: () => closes++,
        );
        expect(identical(handle, previous), isFalse);
        handle.close();
        previous = handle;
      }
      expect(closes, 1000);
      await tester.pump();
      expect(_placementStacks(), findsNothing);
      expect(find.byType(AnimalNotificationCard), findsNothing);
      // Nothing is retained: the next open is shown at once.
      expect(
        AnimalNotification.open(
          context,
          message: const Text('After'),
          duration: null,
        ).status,
        AnimalNotificationStatus.active,
      );
    });

    testWidgets('a context without a host or a non-positive duration throws', (
      tester,
    ) async {
      late BuildContext bare;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              bare = c;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      expect(
        () => AnimalNotification.open(bare, message: const Text('x')),
        throwsFlutterError,
      );

      final BuildContext context = await _pumpHost(tester);
      expect(
        () => AnimalNotification.open(
          context,
          message: const Text('x'),
          duration: Duration.zero,
        ),
        throwsArgumentError,
      );
      await tester.pump();
      expect(_placementStacks(), findsNothing);
    });
  });
}
