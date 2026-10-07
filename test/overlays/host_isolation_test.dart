// N18 isolation oracles: two hosts under one Navigator, owner-bound handles,
// single binding per controller and no root-overlay fallback.
import 'package:animal_island_ui/animal_island_ui.dart';
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

Widget _host(
  Key key,
  void Function(AnimalOverlayController) capture, {
  AnimalOverlayController? controller,
}) => AnimalOverlayHost(
  key: key,
  controller: controller,
  child: Builder(
    builder: (context) {
      capture(AnimalOverlayHost.of(context));
      return const SizedBox.expand();
    },
  ),
);

void main() {
  group('N18 overlay host isolation', () {
    testWidgets('two hosts under one Navigator keep their occurrences apart', (
      tester,
    ) async {
      const Key hostA = ValueKey<String>('host-a');
      const Key hostB = ValueKey<String>('host-b');
      late AnimalOverlayController a;
      late AnimalOverlayController b;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Row(
              children: <Widget>[
                Expanded(child: _host(hostA, (c) => a = c)),
                Expanded(child: _host(hostB, (c) => b = c)),
              ],
            ),
          ),
        ),
      );
      expect(identical(a, b), isFalse);

      int closesA = 0;
      int closesB = 0;
      final AnimalOverlayEntryHandle inA = a.show(
        builder: (_, _) => _toast('in A'),
        onClose: () => closesA++,
      );
      final AnimalOverlayEntryHandle inB = b.show(
        builder: (_, _) => _toast('in B'),
        onClose: () => closesB++,
      );
      await tester.pump();

      // Each occurrence renders inside its own host only.
      expect(
        find.descendant(of: find.byKey(hostA), matching: find.text('in A')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byKey(hostB), matching: find.text('in B')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: find.byKey(hostA), matching: find.text('in B')),
        findsNothing,
      );

      a.closeAll();
      await tester.pump();
      expect(inA.isClosed, isTrue);
      expect(inB.isClosed, isFalse);
      expect(find.text('in A'), findsNothing);
      expect(find.text('in B'), findsOneWidget);
      expect(closesA, 1);
      expect(closesB, 0);
    });

    testWidgets('a foreign handle is rejected and left untouched', (
      tester,
    ) async {
      late AnimalOverlayController a;
      late AnimalOverlayController b;
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              Expanded(child: _host(const ValueKey<int>(1), (c) => a = c)),
              Expanded(child: _host(const ValueKey<int>(2), (c) => b = c)),
            ],
          ),
        ),
      );
      int closes = 0;
      final AnimalOverlayEntryHandle owned = b.show(
        builder: (_, _) => _toast('owned by B'),
        onClose: () => closes++,
      );
      expect(() => a.close(owned), throwsArgumentError);
      await tester.pump();
      expect(owned.isClosed, isFalse);
      expect(find.text('owned by B'), findsOneWidget);
      expect(closes, 0);
    });

    testWidgets('one controller cannot bind to two hosts at once', (
      tester,
    ) async {
      final AnimalOverlayController shared = AnimalOverlayController();
      await tester.pumpWidget(
        _app(
          Column(
            children: <Widget>[
              Expanded(
                child: AnimalOverlayHost(
                  controller: shared,
                  child: const SizedBox.expand(),
                ),
              ),
              Expanded(
                child: AnimalOverlayHost(
                  controller: shared,
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      );
      final Object? error = tester.takeException();
      expect(error, isA<StateError>());
      expect(
        (error! as StateError).message,
        contains('already bound to another AnimalOverlayHost'),
      );
      // The first binding stays in force: disposing a bound controller is
      // misuse.
      expect(shared.dispose, throwsStateError);
      await tester.pumpWidget(_app(const SizedBox.shrink()));
      // Both hosts are gone, so the caller may dispose it now.
      shared.dispose();
    });

    testWidgets('swapping a host controller settles the old one without '
        'disposing it', (tester) async {
      final AnimalOverlayController first = AnimalOverlayController();
      final AnimalOverlayController second = AnimalOverlayController();
      await tester.pumpWidget(
        _app(AnimalOverlayHost(controller: first, child: const SizedBox())),
      );
      int closes = 0;
      final AnimalOverlayEntryHandle handle = first.show(
        builder: (_, _) => _toast('from first'),
        onClose: () => closes++,
      );
      await tester.pump();
      expect(find.text('from first'), findsOneWidget);

      await tester.pumpWidget(
        _app(AnimalOverlayHost(controller: second, child: const SizedBox())),
      );
      expect(handle.isClosed, isTrue);
      expect(closes, 1);
      await tester.pump();
      expect(find.text('from first'), findsNothing);
      // The old controller is unbound but not disposed: it still registers
      // occurrences, which never render here.
      final AnimalOverlayEntryHandle parked = first.show(
        builder: (_, _) => _toast('parked'),
      );
      second.show(builder: (_, _) => _toast('from second'));
      await tester.pump();
      expect(parked.isClosed, isFalse);
      expect(find.text('parked'), findsNothing);
      expect(find.text('from second'), findsOneWidget);

      await tester.pumpWidget(_app(const SizedBox.shrink()));
      first.dispose();
      second.dispose();
    });

    testWidgets('a context without a host has no root-overlay fallback', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox.expand();
            },
          ),
        ),
      );
      expect(AnimalOverlayHost.maybeOf(context), isNull);
      expect(() => AnimalOverlayHost.of(context), throwsFlutterError);
    });
  });
}
