// N20 oracles for the full-screen AnimalLoading occurrence: it is shown only
// through the nearest AnimalOverlayHost, its handle has one idempotent close,
// and removal follows the host's lifecycle (LOD02), while the full-screen
// barrier blocks the controls it covers (LOD03).
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget home, {bool reduceMotion = false}) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  builder: reduceMotion
      ? (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        )
      : null,
  home: home,
);

/// Captures a context below the host.
Widget _probe(void Function(BuildContext context) capture, {Widget? child}) =>
    Builder(
      builder: (context) {
        capture(context);
        return child ?? const SizedBox.expand();
      },
    );

/// Runs [onFirstBuild] once, during the host's first build, before the host's
/// overlay is bound.
class _EarlyShow extends StatefulWidget {
  const _EarlyShow({required this.onFirstBuild});

  final void Function(BuildContext context) onFirstBuild;

  @override
  State<_EarlyShow> createState() => _EarlyShowState();
}

class _EarlyShowState extends State<_EarlyShow> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    if (!_done) {
      _done = true;
      widget.onFirstBuild(context);
    }
    return const SizedBox.expand();
  }
}

void main() {
  group('N20 AnimalLoading overlay lifecycle (LOD02)', () {
    testWidgets('M16: close before the first frame leaves zero host entries '
        'and no orphan', (tester) async {
      final AnimalOverlayController controller = AnimalOverlayController();
      late AnimalLoadingHandle handle;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            controller: controller,
            child: _EarlyShow(
              onFirstBuild: (context) {
                handle = AnimalLoading.show(context, tip: 'Early tip');
                handle.close();
              },
            ),
          ),
        ),
      );
      // The host has bound its overlay after the first frame; the closed
      // occurrence never entered it.
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.byType(AnimalLoading),
        findsNothing,
        reason: 'LOD02 close before first frame must leave zero host entries',
      );
      expect(find.text('Early tip'), findsNothing);
      expect(handle.isClosed, isTrue);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('show and close in one frame on a bound host leaves zero '
        'entries; repeated close is ignored', (tester) async {
      final AnimalOverlayController controller = AnimalOverlayController();
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            controller: controller,
            child: _probe((c) => context = c),
          ),
        ),
      );

      final AnimalLoadingHandle handle = AnimalLoading.show(
        context,
        tip: 'Same frame',
      );
      expect(handle.isClosed, isFalse);
      handle.close();
      handle.close();
      expect(handle.isClosed, isTrue);

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(AnimalLoading), findsNothing);
      expect(find.text('Same frame'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('two handles on one host close independently', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(AnimalOverlayHost(child: _probe((c) => context = c))),
      );

      final AnimalLoadingHandle first = AnimalLoading.show(
        context,
        tip: 'First',
      );
      final AnimalLoadingHandle second = AnimalLoading.show(
        context,
        tip: 'Second',
      );
      await tester.pump();
      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);

      first.close();
      await tester.pump();
      expect(first.isClosed, isTrue);
      expect(second.isClosed, isFalse);
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);

      second.close();
      await tester.pump();
      expect(find.byType(AnimalLoading), findsNothing);
    });

    testWidgets('nested hosts are independent and unmounting a host closes '
        'its loading', (tester) async {
      final AnimalOverlayController outer = AnimalOverlayController();
      final AnimalOverlayController inner = AnimalOverlayController();
      late BuildContext outerContext;
      late BuildContext innerContext;

      Widget tree({required bool withInner}) => _app(
        AnimalOverlayHost(
          controller: outer,
          child: _probe(
            (c) => outerContext = c,
            child: withInner
                ? AnimalOverlayHost(
                    controller: inner,
                    child: _probe((c) => innerContext = c),
                  )
                : const SizedBox.expand(),
          ),
        ),
      );

      await tester.pumpWidget(tree(withInner: true));
      final AnimalLoadingHandle innerHandle = AnimalLoading.show(
        innerContext,
        tip: 'Inner',
      );
      final AnimalLoadingHandle outerHandle = AnimalLoading.show(
        outerContext,
        tip: 'Outer',
      );
      await tester.pump();
      expect(find.text('Inner'), findsOneWidget);
      expect(find.text('Outer'), findsOneWidget);

      // Removing the inner host closes only its own loading.
      await tester.pumpWidget(tree(withInner: false));
      expect(innerHandle.isClosed, isTrue);
      expect(outerHandle.isClosed, isFalse);
      expect(find.text('Inner'), findsNothing);
      expect(find.text('Outer'), findsOneWidget);

      // A late close after the host is gone is ignored.
      innerHandle.close();
      await tester.pump();
      expect(outerHandle.isClosed, isFalse);
      expect(find.text('Outer'), findsOneWidget);

      outerHandle.close();
      await tester.pump();
      expect(find.byType(AnimalLoading), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      inner.dispose();
      outer.dispose();
    });

    testWidgets('show without a host throws and shows nothing', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(_app(_probe((c) => context = c)));
      expect(() => AnimalLoading.show(context), throwsFlutterError);
      await tester.pump();
      expect(find.byType(AnimalLoading), findsNothing);
    });

    testWidgets('show rejects an invalid snowCount before registering', (
      tester,
    ) async {
      final AnimalOverlayController controller = AnimalOverlayController();
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            controller: controller,
            child: _probe((c) => context = c),
          ),
        ),
      );
      expect(() => AnimalLoading.show(context, snowCount: 0), throwsRangeError);
      expect(
        () => AnimalLoading.show(context, snowCount: 101),
        throwsRangeError,
      );
      await tester.pump();
      expect(find.byType(AnimalLoading), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      controller.dispose();
    });

    testWidgets('show applies its style to the full-screen loading', (
      tester,
    ) async {
      late BuildContext context;
      await tester.pumpWidget(
        _app(AnimalOverlayHost(child: _probe((c) => context = c))),
      );
      final AnimalLoadingHandle handle = AnimalLoading.show(
        context,
        type: AnimalLoadingType.spinner,
        style: AnimalLoadingStyle(
          barrierColor: const Color(0x80102030),
          color: const Color(0xFF00AA00),
        ),
      );
      await tester.pump();
      final Material barrier = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(AnimalLoading),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(barrier.color, const Color(0x80102030));
      expect(
        tester.widget<AnimalIcon>(find.byType(AnimalIcon)).color,
        const Color(0xFF00AA00),
      );
      handle.close();
      await tester.pump();
    });
  });

  group('N20 AnimalLoading full-screen access (LOD03)', () {
    testWidgets('the barrier blocks pointer, keyboard and semantics access to '
        'covered controls', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      final FocusNode buttonFocus = FocusNode();
      addTearDown(buttonFocus.dispose);
      int taps = 0;
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            child: Scaffold(
              body: _probe(
                (c) => context = c,
                child: Center(
                  child: ElevatedButton(
                    focusNode: buttonFocus,
                    onPressed: () => taps++,
                    child: const Text('Background Action'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Background Action'));
      expect(taps, 1);
      buttonFocus.requestFocus();
      await tester.pump();
      expect(buttonFocus.hasFocus, isTrue);
      expect(find.semantics.byLabel('Background Action'), findsOne);

      final AnimalLoadingHandle handle = AnimalLoading.show(
        context,
        tip: 'Saving island progress...',
      );
      await tester.pump();
      expect(find.text('Saving island progress...'), findsOneWidget);

      // Pointer: the barrier absorbs the tap.
      await tester.tap(find.text('Background Action'), warnIfMissed: false);
      expect(taps, 1);
      // Keyboard: focus moved into the loading scope and cannot reach the
      // covered button.
      expect(buttonFocus.hasFocus, isFalse);
      for (int i = 0; i < 3; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(buttonFocus.hasFocus, isFalse);
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(taps, 1);
      // Semantics: covered controls leave the accessibility tree.
      expect(find.semantics.byLabel('Background Action'), findsNothing);

      handle.close();
      await tester.pump();
      expect(find.text('Saving island progress...'), findsNothing);
      // Focus returns to the control that held it before the barrier.
      expect(buttonFocus.hasFocus, isTrue);
      expect(find.semantics.byLabel('Background Action'), findsOne);
      await tester.tap(find.text('Background Action'));
      expect(taps, 2);
      semantics.dispose();
    });

    testWidgets('the tip is announced exactly once', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      late BuildContext context;
      await tester.pumpWidget(
        _app(AnimalOverlayHost(child: _probe((c) => context = c))),
      );
      final AnimalLoadingHandle handle = AnimalLoading.show(
        context,
        tip: 'Fetching island mail',
      );
      await tester.pump();
      expect(find.semantics.byLabel('Fetching island mail'), findsOne);
      expect(find.semantics.byLabel(RegExp('Fetching island mail')), findsOne);
      handle.close();
      await tester.pump();
      semantics.dispose();
    });

    testWidgets('reduced motion stops the animation and keeps loading '
        'semantics and blocking', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      int taps = 0;
      late BuildContext context;
      await tester.pumpWidget(
        _app(
          AnimalOverlayHost(
            child: Scaffold(
              body: _probe(
                (c) => context = c,
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => taps++,
                    child: const Text('Background Action'),
                  ),
                ),
              ),
            ),
          ),
          reduceMotion: true,
        ),
      );
      final AnimalLoadingHandle handle = AnimalLoading.show(context);
      await tester.pump();
      // No ticking animation remains, so the tree settles.
      expect(tester.binding.transientCallbackCount, 0);
      await tester.pumpAndSettle();
      expect(find.semantics.byLabel('Loading...'), findsOne);
      await tester.tap(find.text('Background Action'), warnIfMissed: false);
      expect(taps, 0);

      handle.close();
      await tester.pump();
      expect(find.semantics.byLabel('Loading...'), findsNothing);
      semantics.dispose();
    });
  });
}
