// N18 lifecycle oracles for the scoped overlay owner: registration before the
// first frame, close before insertion, the observable closing phase,
// exactly-once settlement, host unmount and bounded resources over many
// cycles. Every oracle observes the public contract only: what is rendered,
// how often onClose runs, `isClosed` and the contracted errors.
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/overlay_host/overlay_host.dart'
    show animalOverlayHostResource;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: home,
);

Widget _toast(String text) => Positioned(
  top: 8,
  left: 8,
  child: Text(text, textDirection: TextDirection.ltr),
);

/// Shows occurrences from the host's first build, before its overlay exists.
class _EarlyShow extends StatefulWidget {
  const _EarlyShow({required this.onFirstBuild});

  final void Function(AnimalOverlayController controller) onFirstBuild;

  @override
  State<_EarlyShow> createState() => _EarlyShowState();
}

class _EarlyShowState extends State<_EarlyShow> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (!_done) {
      _done = true;
      widget.onFirstBuild(AnimalOverlayHost.of(context));
    }
    return const SizedBox.expand();
  }
}

Future<AnimalOverlayController> _pumpHost(WidgetTester tester) async {
  late AnimalOverlayController controller;
  await tester.pumpWidget(
    _app(
      AnimalOverlayHost(
        child: Builder(
          builder: (context) {
            controller = AnimalOverlayHost.of(context);
            return const SizedBox.expand();
          },
        ),
      ),
    ),
  );
  return controller;
}

void main() {
  group('N18 overlay host lifecycle', () {
    testWidgets('an occurrence shown before the first frame is inserted once '
        'the host binds', (tester) async {
      late AnimalOverlayEntryHandle handle;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            child: _EarlyShow(
              onFirstBuild: (c) {
                handle = c.show(builder: (_, _) => _toast('early'));
              },
            ),
          ),
        ),
      );
      // Registered synchronously during the first build and inserted when
      // the host bound after that frame.
      expect(handle.isClosed, isFalse);
      await tester.pump();
      expect(find.text('early'), findsOneWidget);
    });

    testWidgets('closing before insertion settles with zero entries', (
      tester,
    ) async {
      late AnimalOverlayEntryHandle handle;
      int closes = 0;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            child: _EarlyShow(
              onFirstBuild: (c) {
                handle = c.show(
                  builder: (_, _) => _toast('never'),
                  onClose: () => closes++,
                );
                handle.close();
                expect(handle.isClosed, isTrue);
                expect(closes, 1);
              },
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('never'), findsNothing);
      expect(handle.isClosed, isTrue);
      expect(closes, 1);
    });

    testWidgets('close is idempotent and onClose runs exactly once', (
      tester,
    ) async {
      final AnimalOverlayController controller = await _pumpHost(tester);
      int closes = 0;
      final AnimalOverlayEntryHandle handle = controller.show(
        builder: (_, _) => _toast('toast'),
        onClose: () => closes++,
      );
      await tester.pump();
      expect(find.text('toast'), findsOneWidget);

      handle.close();
      handle.close();
      controller.close(handle);
      controller.closeAll();
      await tester.pump();
      expect(handle.isClosed, isTrue);
      expect(find.text('toast'), findsNothing);
      expect(closes, 1);
    });

    testWidgets('while onClose runs the occurrence is removed but not yet '
        'closed, and every further close is ignored', (tester) async {
      final AnimalOverlayController controller = await _pumpHost(tester);
      late AnimalOverlayEntryHandle handle;
      int closes = 0;
      bool? closedDuringCallback;
      handle = controller.show(
        builder: (_, _) => _toast('closing'),
        onClose: () {
          closes++;
          closedDuringCallback = handle.isClosed;
          // Re-entrant closes during the closing phase are ignored.
          handle.close();
          controller.closeAll();
        },
      );
      await tester.pump();
      expect(find.text('closing'), findsOneWidget);

      handle.close();
      expect(closedDuringCallback, isFalse);
      expect(handle.isClosed, isTrue);
      expect(closes, 1);
      await tester.pump();
      expect(find.text('closing'), findsNothing);
    });

    testWidgets('unmounting the host settles every occurrence and leaves no '
        'pending callback', (tester) async {
      final AnimalOverlayController controller = await _pumpHost(tester);
      final List<String> closed = <String>[];
      final List<AnimalOverlayEntryHandle> handles = <AnimalOverlayEntryHandle>[
        for (final String id in <String>['a', 'b', 'c'])
          controller.show(
            builder: (_, _) => _toast(id),
            onClose: () => closed.add(id),
          ),
      ];
      await tester.pump();

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      expect(closed, <String>['a', 'b', 'c']);
      for (final AnimalOverlayEntryHandle handle in handles) {
        expect(handle.isClosed, isTrue);
      }
      // The host disposed the controller it created: further use is a
      // contracted error, and nothing settles again later.
      expect(
        () => controller.show(builder: (_, _) => const SizedBox()),
        throwsStateError,
      );
      await tester.pump(const Duration(seconds: 10));
      expect(closed, <String>['a', 'b', 'c']);
    });

    testWidgets('1000 show/close cycles return every resource to baseline', (
      tester,
    ) async {
      final AnimalOverlayController controller = await _pumpHost(tester);
      int closes = 0;
      for (var i = 0; i < 1000; i++) {
        final AnimalOverlayEntryHandle handle = controller.show(
          builder: (_, _) => _toast('cycle $i'),
          onClose: () => closes++,
        );
        if (i % 3 == 0) await tester.pump();
        handle.close();
      }
      await tester.pump();
      expect(closes, 1000);
      expect(find.textContaining('cycle'), findsNothing);
      // Nothing is still registered: closing everything settles nothing more.
      controller.closeAll();
      await tester.pump(const Duration(seconds: 2));
      expect(closes, 1000);
    });

    testWidgets('a caller-owned controller outlives its host and rebinds', (
      tester,
    ) async {
      final AnimalOverlayController controller = AnimalOverlayController();
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(controller: controller, child: const SizedBox()),
        ),
      );
      // Disposing a controller while a host is bound to it is misuse.
      expect(controller.dispose, throwsStateError);

      int closes = 0;
      final AnimalOverlayEntryHandle first = controller.show(
        builder: (_, _) => _toast('first'),
        onClose: () => closes++,
      );
      await tester.pump();
      expect(find.text('first'), findsOneWidget);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      // The host released its binding and settled the occurrence, but the
      // caller still owns the controller.
      expect(first.isClosed, isTrue);
      expect(closes, 1);

      // Unbound, a new occurrence waits and inserts on rebind.
      final AnimalOverlayEntryHandle second = controller.show(
        builder: (_, _) => _toast('second'),
      );
      expect(second.isClosed, isFalse);
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(controller: controller, child: const SizedBox()),
        ),
      );
      await tester.pump();
      expect(find.text('second'), findsOneWidget);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      controller.dispose();
      expect(second.isClosed, isTrue);
      expect(
        () => controller.show(builder: (_, _) => const SizedBox()),
        throwsStateError,
      );
    });

    testWidgets('a throwing onClose cannot leave other occurrences live', (
      tester,
    ) async {
      final AnimalOverlayController a = AnimalOverlayController();
      final AnimalOverlayController b = AnimalOverlayController();
      await tester.pumpWidget(
        _app(AnimalOverlayHost(controller: a, child: const SizedBox())),
      );
      final AnimalOverlayEntryHandle failing = a.show(
        builder: (_, _) => _toast('failing'),
        onClose: () => throw StateError('callback failure'),
      );
      int plainCloses = 0;
      final AnimalOverlayEntryHandle plain = a.show(
        builder: (_, _) => _toast('plain'),
        onClose: () => plainCloses++,
      );
      await tester.pump();

      await tester.pumpWidget(
        _app(AnimalOverlayHost(controller: b, child: const SizedBox())),
      );
      final Object? reported = tester.takeException();
      expect(reported, isA<StateError>());
      expect((reported! as StateError).message, 'callback failure');
      expect(failing.isClosed, isTrue);
      expect(plain.isClosed, isTrue);
      expect(plainCloses, 1);
      await tester.pump();
      expect(find.text('failing'), findsNothing);
      expect(find.text('plain'), findsNothing);

      // The new controller is the bound one.
      b.show(builder: (_, _) => _toast('on b'));
      await tester.pump();
      expect(find.text('on b'), findsOneWidget);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      a.dispose();
      b.dispose();
    });

    testWidgets('an occurrence shown by onClose during a controller swap '
        'stays created on the unbound controller', (tester) async {
      final AnimalOverlayController a = AnimalOverlayController();
      final AnimalOverlayController b = AnimalOverlayController();
      await tester.pumpWidget(
        _app(AnimalOverlayHost(controller: a, child: const SizedBox())),
      );
      AnimalOverlayEntryHandle? reentrant;
      a.show(
        builder: (_, _) => _toast('original'),
        onClose: () =>
            reentrant = a.show(builder: (_, _) => _toast('re-entrant')),
      );
      await tester.pump();

      await tester.pumpWidget(
        _app(AnimalOverlayHost(controller: b, child: const SizedBox())),
      );
      await tester.pump();
      // Registered on the unbound controller: live, but never rendered.
      expect(reentrant!.isClosed, isFalse);
      expect(find.text('re-entrant'), findsNothing);
      expect(find.text('original'), findsNothing);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      a.dispose();
      expect(reentrant!.isClosed, isTrue);
      b.dispose();
    });

    testWidgets(
      'an occurrence shown by onClose while the host unmounts closes with it',
      (tester) async {
        final AnimalOverlayController controller = await _pumpHost(tester);
        AnimalOverlayEntryHandle? late;
        int lateCloses = 0;
        controller.show(
          builder: (_, _) => _toast('closing'),
          onClose: () => late = controller.show(
            builder: (_, _) => _toast('late'),
            onClose: () => lateCloses++,
          ),
        );
        await tester.pump();

        await tester.pumpWidget(_app(const SizedBox.shrink()));
        // The host unbinds before settling, so the re-entrant occurrence is only
        // registered; disposing the host's controller then closes it. Nothing
        // enters the disposed overlay and nothing stays live.
        expect(tester.takeException(), isNull);
        expect(late!.isClosed, isTrue);
        expect(lateCloses, 1);
        // After disposal a further show is a contracted error.
        expect(
          () => controller.show(builder: (_, _) => const SizedBox()),
          throwsStateError,
        );
      },
    );

    testWidgets('host resources are released when the host unbinds and '
        'recreated on next use', (tester) async {
      final AnimalOverlayController controller = AnimalOverlayController();
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(controller: controller, child: const SizedBox()),
        ),
      );
      final List<String> events = <String>[];
      int created = 0;
      Object resource() => animalOverlayHostResource<Object>(
        controller,
        'queue',
        create: () => 'resource ${++created}',
        release: (value) => events.add('release $value'),
      );
      final AnimalOverlayEntryHandle handle = controller.show(
        builder: (_, _) => _toast('shown'),
        onClose: () => events.add('close occurrence'),
      );
      final Object first = resource();
      expect(identical(resource(), first), isTrue);
      expect(created, 1);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      // Resources are released before the remaining occurrences close, so a
      // queue can settle its waiting items first.
      expect(events, <String>['release resource 1', 'close occurrence']);
      expect(handle.isClosed, isTrue);

      final Object second = resource();
      expect(second, 'resource 2');
      controller.dispose();
      expect(events.last, 'release resource 2');
      expect(() => resource(), throwsStateError);
    });
  });
}
