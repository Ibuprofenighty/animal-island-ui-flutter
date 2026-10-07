// N20 behavior oracles for AnimalDrawer routes (C22 / DRW01-DRW03).
//
// Expected values are literals or independent observations of the rendered
// tree, the semantics tree, the Navigator and the focus system.
import 'dart:async';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  bool disableAnimations = false,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      theme: AnimalIslandTheme.light.toThemeData(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
          disableAnimations: disableAnimations,
        ),
        child: child!,
      ),
      home: Scaffold(
        resizeToAvoidBottomInset: false,
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

final Finder _closeControl = find.bySemanticsLabel('Close drawer');

/// Every semantics node of the current tree.
List<SemanticsNode> _semanticsNodes(WidgetTester tester) {
  final List<SemanticsNode> nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester
        .renderObject(find.byType(MaterialApp))
        .owner!
        .semanticsOwner!
        .rootSemanticsNode!,
  );
  return nodes;
}

void main() {
  group('C22 AnimalDrawer placement and reach (DRW01)', () {
    testWidgets('every placement keeps the close control reachable at 320 px, '
        '200% text, a top inset and an open keyboard', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(tester.view.reset);

      for (final AnimalDrawerPlacement placement
          in AnimalDrawerPlacement.values) {
        late _Outcome<String?> outcome;
        await _pumpOpener(
          tester,
          textScale: 2,
          open: (context) => outcome = _Outcome<String?>(
            AnimalDrawer.show<String>(
              context: context,
              placement: placement,
              title: const Text('Island preferences'),
              builder: (context, close) => const Text('Sound effects'),
            ),
          ),
        );
        await _open(tester);
        expect(tester.takeException(), isNull, reason: placement.name);

        final Rect close = tester.getRect(_closeControl);
        expect(close.top, greaterThanOrEqualTo(44), reason: placement.name);
        expect(
          close.bottom,
          lessThanOrEqualTo(568 - 260),
          reason: placement.name,
        );
        expect(close.left, greaterThanOrEqualTo(0), reason: placement.name);
        expect(close.right, lessThanOrEqualTo(320), reason: placement.name);

        await tester.tap(_closeControl);
        await tester.pumpAndSettle();
        expect(find.text('Island preferences'), findsNothing);
        expect(outcome.values, <String?>[null], reason: placement.name);
      }
    });

    testWidgets('a width or height larger than the screen does not overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final AnimalDrawerPlacement placement
          in AnimalDrawerPlacement.values) {
        await _pumpOpener(
          tester,
          open: (context) => AnimalDrawer.show<void>(
            context: context,
            placement: placement,
            width: 2000,
            height: 2000,
            title: const Text('Wide drawer'),
            builder: (context, close) => const Text('Body'),
          ),
        );
        await _open(tester);
        expect(tester.takeException(), isNull, reason: placement.name);
        final Size sheet = tester.getSize(
          find
              .descendant(
                of: find.byType(AnimalDrawer),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(sheet.width, lessThanOrEqualTo(320), reason: placement.name);
        expect(sheet.height, lessThanOrEqualTo(568), reason: placement.name);
        await tester.tap(_closeControl);
        await tester.pumpAndSettle();
      }
    });
  });

  group('C22 AnimalDrawer dismissal, result and focus (DRW02)', () {
    testWidgets('maskClosable false ignores the barrier; Escape and back '
        'dismiss with null and focus returns to the opener', (tester) async {
      final FocusNode opener = FocusNode(debugLabel: 'opener');
      addTearDown(opener.dispose);
      final Map<String, Future<void> Function()> dismissals =
          <String, Future<void> Function()>{
            'Escape': () => tester.sendKeyEvent(LogicalKeyboardKey.escape),
            'back': () async {
              await tester.binding.handlePopRoute();
            },
          };
      for (final MapEntry<String, Future<void> Function()> dismissal
          in dismissals.entries) {
        late _Outcome<String?> outcome;
        await _pumpOpener(
          tester,
          focusNode: opener,
          open: (context) => outcome = _Outcome<String?>(
            AnimalDrawer.show<String>(
              context: context,
              maskClosable: false,
              title: const Text('Island settings'),
              builder: (context, close) => const Text('Audio'),
            ),
          ),
        );
        opener.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(opener.hasFocus, isFalse, reason: dismissal.key);

        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        expect(find.text('Island settings'), findsOneWidget);
        expect(outcome.values, isEmpty);

        await dismissal.value();
        await tester.pumpAndSettle();
        expect(find.text('Island settings'), findsNothing);
        expect(outcome.values, <String?>[null], reason: dismissal.key);
        expect(opener.hasFocus, isTrue, reason: dismissal.key);
      }
    });

    testWidgets('a typed close from the footer completes once; later close '
        'requests are ignored', (tester) async {
      void Function(String result)? closeDrawer;
      late _Outcome<String?> outcome;
      await _pumpOpener(
        tester,
        open: (context) => outcome = _Outcome<String?>(
          AnimalDrawer.show<String>(
            context: context,
            title: const Text('Save drawer'),
            builder: (context, close) => const Text('Unsaved changes'),
            footerBuilder: (context, close) {
              closeDrawer = close;
              return TextButton(
                onPressed: () => close('saved'),
                child: const Text('Save'),
              );
            },
          ),
        ),
      );
      await _open(tester);
      await tester.tap(find.text('Save'));
      closeDrawer!('late');
      await tester.pumpAndSettle();
      closeDrawer!('later');
      await tester.pumpAndSettle();

      expect(find.text('Save drawer'), findsNothing);
      expect(outcome.values, <String?>['saved']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a drawer on a nested Navigator closes only its own route', (
      tester,
    ) async {
      final GlobalKey<NavigatorState> rootKey = GlobalKey<NavigatorState>();
      final GlobalKey<NavigatorState> nestedKey = GlobalKey<NavigatorState>();
      void Function(String result)? closeDrawer;
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
                      AnimalDrawer.show<String>(
                        context: context,
                        builder: (context, close) {
                          closeDrawer = close;
                          return const Text('Nested drawer body');
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
        Navigator.of(tester.element(find.text('Nested drawer body'))),
        same(nestedKey.currentState),
      );

      unawaited(
        nestedKey.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const Text('Top page')),
        ),
      );
      await tester.pumpAndSettle();
      closeDrawer!('done');
      await tester.pumpAndSettle();

      expect(find.text('Top page'), findsOneWidget);
      expect(
        find.text('Nested drawer body', skipOffstage: false),
        findsNothing,
      );
      expect(outcome.values, <String?>['done']);
      expect(rootKey.currentState!.canPop(), isFalse);
    });
  });

  group('C22 AnimalDrawer semantics and motion (DRW03)', () {
    testWidgets('the route adds one named route scope without a duplicated '
        'label', (tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await _pumpOpener(
        tester,
        open: (context) => AnimalDrawer.show<void>(
          context: context,
          title: const Text('Island tools'),
          builder: (context, close) => const Text('Net and fishing rod'),
        ),
      );
      await _open(tester);
      final List<SemanticsNode> labelled = _semanticsNodes(tester)
          .where((node) => node.label == 'Drawer')
          .toList();
      expect(labelled, hasLength(1));
      final SemanticsData data = labelled.single.getSemanticsData();
      expect(data.flagsCollection.scopesRoute, isTrue);
      expect(data.flagsCollection.namesRoute, isTrue);
      // The drawer route is one named scope: no second route scope and no
      // repeated label inside it.
      final List<SemanticsNode> inside = <SemanticsNode>[];
      labelled.single.visitChildren((child) {
        void collect(SemanticsNode node) {
          inside.add(node);
          node.visitChildren((next) {
            collect(next);
            return true;
          });
        }

        collect(child);
        return true;
      });
      expect(inside, isNotEmpty);
      expect(
        inside.where(
          (node) => node.getSemanticsData().flagsCollection.scopesRoute,
        ),
        isEmpty,
      );
      expect(inside.where((node) => node.label == 'Drawer'), isEmpty);
      var scopedAncestors = 0;
      for (
        SemanticsNode? node = labelled.single.parent;
        node != null;
        node = node.parent
      ) {
        if (node.getSemanticsData().flagsCollection.scopesRoute) {
          scopedAncestors += 1;
        }
      }
      expect(scopedAncestors, 0);
      handle.dispose();
    });

    testWidgets('reduced motion shows the drawer without sliding and it stays '
        'operable', (tester) async {
      late _Outcome<String?> outcome;
      await _pumpOpener(
        tester,
        disableAnimations: true,
        open: (context) => outcome = _Outcome<String?>(
          AnimalDrawer.show<String>(
            context: context,
            placement: AnimalDrawerPlacement.left,
            title: const Text('Still drawer'),
            builder: (context, close) => TextButton(
              onPressed: () => close('picked'),
              child: const Text('Pick'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump();

      final Finder title = find.text('Still drawer');
      expect(
        find.ancestor(of: title, matching: find.byType(SlideTransition)),
        findsNothing,
      );
      expect(
        tester
            .getTopLeft(
              find
                  .descendant(
                    of: find.byType(AnimalDrawer),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .dx,
        0,
      );

      await tester.tap(find.text('Pick'));
      await tester.pump();
      await tester.pump();
      expect(title, findsNothing);
      expect(outcome.values, <String?>['picked']);
    });
  });
}
