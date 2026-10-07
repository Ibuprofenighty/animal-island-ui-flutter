// N20 behavior oracles for AnimalModal routes (C21 / MOD01-MOD04).
//
// Expected values are literals or independent observations of the rendered
// tree, the Navigator and the focus system; none is computed by the modal.
import 'dart:async';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every completion of a presented route's result.
class _Outcome<T> {
  _Outcome(Future<T> future) {
    future.then(values.add);
  }

  final List<T> values = <T>[];
}

Future<void> _pumpOpener(
  WidgetTester tester, {
  required void Function(BuildContext context) open,
  FocusNode? focusNode,
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: AnimalIslandTheme.light.toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              focusNode: focusNode,
              onPressed: () => open(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

/// Whether [node]'s widget sits below the single [AnimalModal] in the tree.
bool _insideModal(WidgetTester tester, FocusNode? node) {
  final BuildContext? context = node?.context;
  if (context == null) return false;
  final Element modal = tester.element(find.byType(AnimalModal));
  var inside = false;
  context.visitAncestorElements((ancestor) {
    if (ancestor == modal) inside = true;
    return !inside;
  });
  return inside;
}

void main() {
  group('C21 AnimalModal confirmation (MOD02)', () {
    testWidgets('confirm completes true only after onConfirm accepts; '
        'false keeps the modal open', (tester) async {
      final List<bool> answers = <bool>[false, true];
      var calls = 0;
      late _Outcome<bool> outcome;
      await _pumpOpener(
        tester,
        open: (context) => outcome = _Outcome<bool>(
          AnimalModal.confirm(
            context: context,
            title: const Text('Delete island?'),
            content: const Text('This cannot be undone.'),
            onConfirm: () async => answers[calls++],
          ),
        ),
      );
      await _open(tester);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.text('Delete island?'), findsOneWidget);
      expect(outcome.values, isEmpty);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('Delete island?'), findsNothing);
      expect(outcome.values, <bool>[true]);
    });

    testWidgets('a thrown confirmation keeps the modal open, shows the error '
        'and can be retried', (tester) async {
      var calls = 0;
      late _Outcome<bool> outcome;
      await _pumpOpener(
        tester,
        open: (context) => outcome = _Outcome<bool>(
          AnimalModal.confirm(
            context: context,
            title: const Text('Sync island'),
            content: const Text('Upload your island?'),
            onConfirm: () {
              calls += 1;
              if (calls == 1) throw StateError('Server unavailable');
              return true;
            },
          ),
        ),
      );
      await _open(tester);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(find.text('Bad state: Server unavailable'), findsOneWidget);
      expect(find.text('Sync island'), findsOneWidget);
      expect(outcome.values, isEmpty);

      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(find.text('Sync island'), findsNothing);
      expect(outcome.values, <bool>[true]);
    });

    testWidgets('while a confirmation is pending, repeated confirm and every '
        'close request are ignored', (tester) async {
      final Completer<bool> gate = Completer<bool>();
      var calls = 0;
      late _Outcome<bool> outcome;
      await _pumpOpener(
        tester,
        open: (context) => outcome = _Outcome<bool>(
          AnimalModal.confirm(
            context: context,
            title: const Text('Pending modal'),
            content: const Text('Waiting for the server.'),
            onConfirm: () {
              calls += 1;
              return gate.future;
            },
          ),
        ),
      );
      await _open(tester);

      final Finder confirm = find.byType(AnimalButton).last;
      await tester.tap(confirm);
      await tester.pump(const Duration(milliseconds: 100));
      final Map<String, Future<void> Function()> requests =
          <String, Future<void> Function()>{
            'repeated confirm': () => tester.tap(confirm, warnIfMissed: false),
            'Escape': () => tester.sendKeyEvent(LogicalKeyboardKey.escape),
            'back': () async {
              await tester.binding.handlePopRoute();
            },
            'barrier': () => tester.tapAt(const Offset(4, 4)),
            'close control': () =>
                tester.tap(find.bySemanticsLabel('Close modal')),
            'cancel': () =>
                tester.tap(find.text('Cancel'), warnIfMissed: false),
          };
      for (final MapEntry<String, Future<void> Function()> request
          in requests.entries) {
        await request.value();
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          find.text('Pending modal'),
          findsOneWidget,
          reason: '${request.key} while pending',
        );
        expect(outcome.values, isEmpty, reason: '${request.key} while pending');
      }

      expect(calls, 1);
      expect(find.text('Pending modal'), findsOneWidget);
      expect(outcome.values, isEmpty);

      gate.complete(true);
      await tester.pumpAndSettle();
      expect(find.text('Pending modal'), findsNothing);
      expect(outcome.values, <bool>[true]);
    });
  });

  group('C21 AnimalModal dismissal and focus (MOD03)', () {
    testWidgets('cancel, close control, Escape, back and barrier each '
        'complete with false exactly once', (tester) async {
      final Map<String, Future<void> Function()> dismissals =
          <String, Future<void> Function()>{
            'cancel': () => tester.tap(find.text('Cancel')),
            'close control': () =>
                tester.tap(find.bySemanticsLabel('Close modal')),
            'Escape': () => tester.sendKeyEvent(LogicalKeyboardKey.escape),
            'back': () async {
              await tester.binding.handlePopRoute();
            },
            'barrier': () => tester.tapAt(const Offset(4, 4)),
          };
      for (final MapEntry<String, Future<void> Function()> dismissal
          in dismissals.entries) {
        late _Outcome<bool> outcome;
        await _pumpOpener(
          tester,
          open: (context) => outcome = _Outcome<bool>(
            AnimalModal.confirm(
              context: context,
              title: const Text('Leave island?'),
              content: const Text('Your friends will miss you.'),
            ),
          ),
        );
        await _open(tester);
        await dismissal.value();
        await tester.pumpAndSettle();
        expect(find.text('Leave island?'), findsNothing, reason: dismissal.key);
        expect(outcome.values, <bool>[false], reason: dismissal.key);
      }
    });

    testWidgets('maskClosable false and mask false ignore barrier taps; '
        'Escape still dismisses', (tester) async {
      for (final (bool mask, bool maskClosable) in <(bool, bool)>[
        (true, false),
        (false, true),
      ]) {
        late _Outcome<bool> outcome;
        await _pumpOpener(
          tester,
          open: (context) => outcome = _Outcome<bool>(
            AnimalModal.confirm(
              context: context,
              title: const Text('Guarded modal'),
              content: const Text('Only explicit actions close me.'),
              mask: mask,
              maskClosable: maskClosable,
            ),
          ),
        );
        await _open(tester);
        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();
        expect(find.text('Guarded modal'), findsOneWidget);
        expect(outcome.values, isEmpty);
        if (!mask) {
          expect(find.byType(BackdropFilter), findsNothing);
        }

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.text('Guarded modal'), findsNothing);
        expect(outcome.values, <bool>[false]);
      }
    });

    testWidgets('focus stays inside the modal and returns to the opener', (
      tester,
    ) async {
      final FocusNode opener = FocusNode(debugLabel: 'opener');
      addTearDown(opener.dispose);
      late _Outcome<bool> outcome;
      await _pumpOpener(
        tester,
        focusNode: opener,
        open: (context) => outcome = _Outcome<bool>(
          AnimalModal.confirm(
            context: context,
            title: const Text('Focus modal'),
            content: const Text('Tab around.'),
          ),
        ),
      );
      opener.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(find.text('Focus modal'), findsOneWidget);
      expect(opener.hasFocus, isFalse);

      final Set<FocusNode> visited = <FocusNode>{};
      for (var i = 0; i < 9; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        final FocusNode? focused = FocusManager.instance.primaryFocus;
        expect(_insideModal(tester, focused), isTrue, reason: 'Tab #$i');
        visited.add(focused!);
      }
      // Close control, cancel and confirm.
      expect(visited, hasLength(3));

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(outcome.values, <bool>[false]);
      expect(opener.hasFocus, isTrue);
    });
  });

  group('C21 AnimalModal typed content results', () {
    testWidgets('show<String> completes with the value its content closes '
        'with, and null when dismissed', (tester) async {
      final List<_Outcome<String?>> outcomes = <_Outcome<String?>>[];
      await _pumpOpener(
        tester,
        open: (context) => outcomes.add(
          _Outcome<String?>(
            AnimalModal.show<String>(
              context: context,
              title: const Text('Pick a fruit'),
              builder: (context, close) => TextButton(
                onPressed: () => close('apple'),
                child: const Text('Apple'),
              ),
            ),
          ),
        ),
      );

      await _open(tester);
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await _open(tester);
      await tester.tap(find.bySemanticsLabel('Close modal'));
      await tester.pumpAndSettle();
      await _open(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Pick a fruit'), findsNothing);
      expect(outcomes.map((outcome) => outcome.values), <List<String?>>[
        <String?>['apple'],
        <String?>[null],
        <String?>[null],
      ]);
    });

    testWidgets('a modal on a nested Navigator closes only its own route', (
      tester,
    ) async {
      final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> nestedKey = GlobalKey<NavigatorState>();
      void Function(String result)? closeModal;
      late _Outcome<String?> outcome;
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootKey,
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: Navigator(
              key: nestedKey,
              onGenerateRoute: (settings) => MaterialPageRoute<void>(
                builder: (context) => Center(
                  child: TextButton(
                    onPressed: () => outcome = _Outcome<String?>(
                      AnimalModal.show<String>(
                        context: context,
                        builder: (context, close) {
                          closeModal = close;
                          return const Text('Nested modal body');
                        },
                      ),
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await _open(tester);
      expect(
        Navigator.of(tester.element(find.text('Nested modal body'))),
        same(nestedKey.currentState),
      );

      unawaited(
        nestedKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const Text('Top page')),
        ),
      );
      await tester.pumpAndSettle();
      closeModal!('done');
      await tester.pumpAndSettle();

      expect(find.text('Top page'), findsOneWidget);
      expect(find.text('Nested modal body', skipOffstage: false), findsNothing);
      expect(outcome.values, <String?>['done']);
      expect(rootKey.currentState!.canPop(), isFalse);

      nestedKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('the result is delivered exactly once when the Navigator '
        'disposes the open modal', (tester) async {
      late _Outcome<bool> confirmOutcome;
      late _Outcome<String?> contentOutcome;
      await _pumpOpener(
        tester,
        open: (context) {
          contentOutcome = _Outcome<String?>(
            AnimalModal.show<String>(
              context: context,
              builder: (context, close) => const Text('Content modal'),
            ),
          );
          confirmOutcome = _Outcome<bool>(
            AnimalModal.confirm(
              context: context,
              content: const Text('Confirm modal'),
            ),
          );
        },
      );
      await _open(tester);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      await tester.pump();

      expect(confirmOutcome.values, <bool>[false]);
      expect(contentOutcome.values, <String?>[null]);
    });
  });

  group('C21 AnimalModal layout (MOD01)', () {
    testWidgets('a long body at 320 px, 200% text and an open keyboard '
        'scrolls to the actions instead of truncating', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.reset);
      late _Outcome<bool> outcome;
      await _pumpOpener(
        tester,
        textScale: 2,
        open: (context) => outcome = _Outcome<bool>(
          AnimalModal.confirm(
            context: context,
            title: const Text('Island news'),
            content: Text('The museum is expanding. ' * 40),
          ),
        ),
      );
      await _open(tester);
      expect(tester.takeException(), isNull);

      final Finder confirm = find.text('Confirm');
      await tester.ensureVisible(confirm);
      await tester.pumpAndSettle();
      final Rect rect = tester.getRect(confirm);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(568 - 260));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(320));

      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(outcome.values, <bool>[true]);
    });
  });

  group('C21 AnimalModal dialogue (MOD04)', () {
    testWidgets('dialogue shows speaker and avatar, finishes once and '
        'continues with true', (tester) async {
      var finished = 0;
      late _Outcome<bool> outcome;
      await _pumpOpener(
        tester,
        open: (context) => outcome = _Outcome<bool>(
          AnimalModal.showDialogue(
            context: context,
            speaker: 'Tom Nook',
            avatar: const Icon(Icons.star),
            dialogue: 'Yes, yes! Welcome to the island!',
            typeSpeed: const Duration(milliseconds: 1),
            onFinish: () => finished += 1,
          ),
        ),
      );
      await _open(tester);
      // The typewriter measures elapsed wall-clock time between its ticks.
      for (var i = 0; i < 3; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 80)),
        );
        await tester.pump(const Duration(milliseconds: 20));
      }

      expect(find.text('Tom Nook'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Yes, yes! Welcome to the island!'), findsOneWidget);
      expect(finished, 1);

      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 80)),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(finished, 1);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(outcome.values, <bool>[true]);
      expect(finished, 1);
    });

    testWidgets('a rich Widget body is rendered as given and never re-typed '
        'from extracted text', (tester) async {
      const Key star = ValueKey<String>('inline-star');
      await _pumpOpener(
        tester,
        open: (context) => AnimalModal.confirm(
          context: context,
          content: const Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'Catch a '),
                WidgetSpan(child: Icon(Icons.star, key: star)),
                TextSpan(text: ' tonight'),
              ],
            ),
          ),
        ),
      );
      await _open(tester);

      expect(find.byKey(star), findsOneWidget);
      expect(find.byType(AnimalTypewriter), findsNothing);
      expect(find.textContaining('Catch a'), findsOneWidget);
    });
  });
}
