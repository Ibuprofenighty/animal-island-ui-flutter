import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/focus_ring.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AnimalLocalizations.localizationsDelegates,
  supportedLocales: AnimalLocalizations.supportedLocales,
  theme: AnimalIslandTheme.light.toThemeData(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets(
    'N09 readOnly targets stay focusable while pointer, key, and semantics activation stay unavailable',
    (tester) async {
      final FocusNode focusNode = FocusNode();
      addTearDown(focusNode.dispose);
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _app(
            InteractiveRegion(
              focusNode: focusNode,
              readOnly: true,
              onPressed: null,
              semanticLabel: 'Read only target',
              enableHaptics: false,
              child: const Text('Read only'),
            ),
          ),
        );

        focusNode.requestFocus();
        await tester.pump();
        expect(focusNode.hasFocus, isTrue);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        await tester.tap(find.text('Read only'));
        await tester.pump();
        final SemanticsData data = tester
            .getSemantics(find.text('Read only'))
            .getSemanticsData();
        expect(data.flagsCollection.isEnabled, Tristate.isTrue);
        expect(data.hasAction(SemanticsAction.tap), isFalse);
        expect(data.flagsCollection.isReadOnly, isTrue);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'N09 shared pointer, keyboard, and semantics activation each fire once',
    (tester) async {
      final FocusNode focusNode = FocusNode();
      int activations = 0;
      final SemanticsHandle semantics = tester.ensureSemantics();

      await tester.pumpWidget(
        _app(
          InteractiveRegion(
            focusNode: focusNode,
            onPressed: () => activations++,
            semanticLabel: 'Shared activation target',
            enableHaptics: false,
            child: const Text('Activate'),
          ),
        ),
      );

      final Finder target = find.text('Activate');
      final SemanticsFinder semanticsTarget = find.semantics.byLabel(
        RegExp('Shared activation target'),
      );
      final Rect hitRect = tester.getRect(find.byType(InteractiveRegion));
      expect(hitRect.width, greaterThanOrEqualTo(48));
      expect(hitRect.height, greaterThanOrEqualTo(48));
      await tester.tap(target);
      await tester.pump();
      expect(activations, 1);

      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(activations, 3);

      expect(
        tester
            .getSemantics(target)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isTrue,
      );
      expect(
        tester.getSemantics(target).getSemanticsData().label,
        'Shared activation target',
      );
      tester.semantics.tap(semanticsTarget);
      await tester.pump();
      expect(activations, 4);

      semantics.dispose();
      await tester.pumpWidget(const SizedBox.shrink());
      focusNode.dispose();
    },
  );

  testWidgets(
    'N09 mixed keys, focus loss, disable, hide, callback replacement, pointer cancel, and unmount cancel',
    (tester) async {
      final FocusNode focusNode = FocusNode();
      int oldHandlerCalls = 0;
      int newHandlerCalls = 0;
      bool disabled = false;
      bool visible = true;
      bool mountedTarget = true;
      VoidCallback handler = () => oldHandlerCalls++;
      late StateSetter updateHarness;

      await tester.pumpWidget(
        MaterialApp(
          theme: AnimalIslandTheme.light.toThemeData(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                updateHarness = setState;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (mountedTarget)
                      InteractiveRegion(
                        focusNode: focusNode,
                        onPressed: handler,
                        disabled: disabled,
                        visible: visible,
                        enableHaptics: false,
                        semanticLabel: 'Cancelable target',
                        child: const Text('Cancelable'),
                      ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Harness control'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      focusNode.requestFocus();
      await tester.pump();

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(oldHandlerCalls, 0, reason: 'Enter-down/Space-up is invalid');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(oldHandlerCalls, 0, reason: 'Space-down/Enter-up is invalid');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      focusNode.unfocus();
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(oldHandlerCalls, 0, reason: 'Blur cancels a held key');

      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      updateHarness(() {
        handler = () => newHandlerCalls++;
      });
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(oldHandlerCalls, 0);
      expect(newHandlerCalls, 0, reason: 'Handler replacement invalidates');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      updateHarness(() => disabled = true);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(newHandlerCalls, 0, reason: 'Disable cancels a held key');

      updateHarness(() => disabled = false);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      updateHarness(() => visible = false);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(newHandlerCalls, 0, reason: 'Hide cancels a held key');

      updateHarness(() => visible = true);
      await tester.pump();
      final TestGesture pointer = await tester.startGesture(
        tester.getCenter(find.text('Cancelable')),
      );
      await tester.pump();
      await pointer.cancel();
      await tester.pump();
      expect(newHandlerCalls, 0, reason: 'Pointer cancel never activates');

      await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
      updateHarness(() => mountedTarget = false);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(find.text('Cancelable'), findsNothing);
      expect(newHandlerCalls, 0, reason: 'Unmount cancels a held key');

      await tester.pumpWidget(const SizedBox.shrink());
      focusNode.dispose();
    },
  );

  testWidgets(
    'N09 Tag body and close have separate 48dp hit targets and no event leakage',
    (tester) async {
      int bodyCalls = 0;
      int closeCalls = 0;
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          AnimalTag(
            onTap: () => bodyCalls++,
            onClose: () => closeCalls++,
            child: const Text('Apricot'),
          ),
        ),
      );

      final Finder regions = find.byType(InteractiveRegion);
      expect(regions, findsNWidgets(2));
      final Finder body = regions.at(0);
      final Finder close = regions.at(1);
      expect(find.semantics.byLabel(RegExp('Apricot')), findsOneWidget);
      expect(find.semantics.byLabel(RegExp('Remove tag')), findsOneWidget);
      final Rect bodyRect = tester.getRect(body);
      final Rect closeRect = tester.getRect(close);
      expect(bodyRect.width, greaterThanOrEqualTo(48));
      expect(bodyRect.height, greaterThanOrEqualTo(48));
      expect(closeRect.width, greaterThanOrEqualTo(48));
      expect(closeRect.height, greaterThanOrEqualTo(48));
      expect(bodyRect.overlaps(closeRect), isFalse);

      await tester.tap(close);
      await tester.pump();
      expect(closeCalls, 1);
      expect(bodyCalls, 0);
      await tester.tap(body);
      await tester.pump();
      expect(bodyCalls, 1);
      expect(closeCalls, 1);

      semantics.dispose();
    },
  );

  testWidgets('N09 nested card child action is not repeated by the card', (
    tester,
  ) async {
    int cardCalls = 0;
    int buttonCalls = 0;
    await tester.pumpWidget(
      _app(
        AnimalCard(
          onTap: () => cardCalls++,
          child: AnimalButton(
            onPressed: () => buttonCalls++,
            child: const Text('Nested action'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Nested action'));
    await tester.pump();
    expect(buttonCalls, 1);
    expect(cardCalls, 0);
  });

  testWidgets('N09 nested card and child expose separate semantic actions', (
    tester,
  ) async {
    int cardCalls = 0;
    int buttonCalls = 0;
    final SemanticsHandle semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _app(
        AnimalCard(
          onTap: () => cardCalls++,
          semanticLabel: 'Outer card action',
          child: AnimalButton(
            onPressed: () => buttonCalls++,
            semanticLabel: 'Inner button action',
            child: const Text('Nested semantic action'),
          ),
        ),
      ),
    );

    final SemanticsFinder outer = find.semantics.byLabel(
      RegExp(r'^Outer card action$'),
    );
    final SemanticsFinder inner = find.semantics.byLabel(
      RegExp(r'^Inner button action$'),
    );
    expect(outer, findsOneWidget);
    expect(inner, findsOneWidget);

    tester.semantics.tap(outer);
    await tester.pump();
    expect(cardCalls, 1);
    expect(buttonCalls, 0);

    tester.semantics.tap(inner);
    await tester.pump();
    expect(cardCalls, 1);
    expect(buttonCalls, 1);

    semantics.dispose();
  });

  testWidgets(
    'N09 pagination keeps navigation and each leaf semantic action separate',
    (tester) async {
      final List<int> changedPages = <int>[];
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          AnimalPagination(
            current: 5,
            total: 100,
            pageSize: 10,
            onChanged: changedPages.add,
          ),
        ),
      );

      final AnimalLocalizations localizations = AnimalLocalizations.of(
        tester.element(find.byType(AnimalPagination)),
      )!;
      Finder nodeFor(String label) => find.bySemanticsLabel(label);
      SemanticsFinder semanticsNodeFor(String label) =>
          find.semantics.byLabel(RegExp('^${RegExp.escape(label)}\$'));

      final Finder navigation = nodeFor(
        localizations.paginationNavigation(5, 10),
      );
      expect(navigation, findsOneWidget);
      expect(
        tester
            .getSemantics(navigation)
            .getSemanticsData()
            .hasAction(SemanticsAction.tap),
        isFalse,
      );

      final List<(String, int)> actions = <(String, int)>[
        (localizations.paginationPrevious, 4),
        (localizations.paginationSkipBackward, 1),
        (localizations.paginationPage(4), 4),
        (localizations.paginationSkipForward, 10),
        (localizations.paginationNext, 6),
      ];
      for (final (String label, int expectedPage) in actions) {
        final Finder target = nodeFor(label);
        expect(target, findsOneWidget, reason: label);
        expect(
          tester
              .getSemantics(target)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
          reason: label,
        );
        tester.semantics.tap(semanticsNodeFor(label));
        await tester.pump();
        expect(changedPages, <int>[expectedPage], reason: label);
        changedPages.clear();
      }

      semantics.dispose();
    },
  );

  testWidgets('N09 carousel dots have disjoint 48dp hit targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        AnimalCarousel.uncontrolled(
          style: AnimalCarouselStyle(height: 200),
          showArrows: false,
          showDots: true,
          items: <AnimalCarouselItem>[
            AnimalCarouselItem(id: 'slide-0', child: Text('First slide')),
            AnimalCarouselItem(id: 'slide-1', child: Text('Second slide')),
            AnimalCarouselItem(id: 'slide-2', child: Text('Third slide')),
          ],
        ),
      ),
    );

    final Finder dots = find.byType(InteractiveRegion);
    expect(dots, findsNWidgets(3));
    final List<Rect> hitRects = <Rect>[
      for (int index = 0; index < 3; index++) tester.getRect(dots.at(index)),
    ];
    for (final Rect rect in hitRects) {
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
    }
    for (int index = 1; index < hitRects.length; index++) {
      expect(
        hitRects[index - 1].overlaps(hitRects[index]),
        isFalse,
        reason: 'Adjacent carousel dot hit targets must not overlap',
      );
    }
  });

  testWidgets(
    'N09 Select clear is independent and option activation closes the menu once',
    (tester) async {
      String? value = 'one';
      int changes = 0;
      late StateSetter updateHarness;
      final SemanticsHandle semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,
            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  updateHarness = setState;
                  return AnimalSelect<String>(
                    value: value,
                    allowClear: true,
                    options: const <AnimalOption<String>>[
                      AnimalOption<String>(value: 'one', label: 'One'),
                      AnimalOption<String>(value: 'two', label: 'Two'),
                    ],
                    onChanged: (String? next) {
                      changes++;
                      setState(() => value = next);
                    },
                  );
                },
              ),
            ),
          ),
        );

        final Finder clear = find.byType(InteractiveRegion).at(1);
        expect(
          find.semantics.byLabel(RegExp('Clear selection')),
          findsOneWidget,
        );
        final Rect clearRect = tester.getRect(clear);
        expect(clearRect.width, greaterThanOrEqualTo(48));
        expect(clearRect.height, greaterThanOrEqualTo(48));
        await tester.tap(clear);
        await tester.pumpAndSettle();
        expect(value, isNull);
        expect(changes, 1);

        updateHarness(() => value = 'one');
        await tester.pump();
        await tester.tap(find.text('One'));
        await tester.pumpAndSettle();
        expect(find.text('Two'), findsOneWidget);
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(one)',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(
          FocusManager.instance.primaryFocus?.debugLabel,
          'AnimalSelect(two)',
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(value, 'two');
        expect(changes, 2);
        expect(find.text('Two'), findsOneWidget);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'N09 InteractiveRegion borrowed focus replacement reports the active node after RTL rebuilds',
    (tester) async {
      final FocusNode originalNode = FocusNode();
      final FocusNode replacementNode = FocusNode();
      final FocusNode reusedNode = FocusNode();
      addTearDown(originalNode.dispose);
      addTearDown(replacementNode.dispose);
      addTearDown(reusedNode.dispose);
      FocusNode activeNode = originalNode;
      TextDirection direction = TextDirection.ltr;
      late StateSetter updateHost;
      final List<bool> focusChanges = <bool>[];
      await tester.pumpWidget(
        _app(
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              updateHost = setState;
              return Directionality(
                textDirection: direction,
                child: InteractiveRegion(
                  enableHaptics: false,
                  onPressed: () {},
                  focusNode: activeNode,
                  onFocusChanged: focusChanges.add,
                  child: const SizedBox(width: 24, height: 24),
                ),
              );
            },
          ),
        ),
      );

      originalNode.requestFocus();
      await tester.pumpAndSettle();
      expect(originalNode.hasFocus, isTrue);
      expect(focusChanges, <bool>[true]);
      final Finder focusRing = find.byType(AnimalFocusRing);
      expect(tester.widget<AnimalFocusRing>(focusRing).focused, isTrue);

      bool replacementFocusedBeforeDeferredNotice = false;
      tester.binding.addPostFrameCallback((Duration _) {
        replacementNode.requestFocus();
        FocusManager.instance.applyFocusChangesIfNeeded();
        replacementFocusedBeforeDeferredNotice = replacementNode.hasFocus;
      });
      updateHost(() {
        activeNode = replacementNode;
        direction = TextDirection.rtl;
      });
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(replacementFocusedBeforeDeferredNotice, isTrue);
      expect(replacementNode.hasFocus, isTrue);
      expect(focusChanges, <bool>[true, true]);
      expect(tester.takeException(), isNull);

      originalNode.requestFocus();
      await tester.pumpAndSettle();
      expect(replacementNode.hasFocus, isTrue);
      expect(focusChanges, <bool>[true, true]);
      replacementNode.requestFocus();
      await tester.pumpAndSettle();
      expect(replacementNode.hasFocus, isTrue);
      expect(focusChanges, <bool>[true, true]);
      expect(tester.widget<AnimalFocusRing>(focusRing).focused, isTrue);

      updateHost(() {
        activeNode = reusedNode;
        direction = TextDirection.ltr;
      });
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      reusedNode.requestFocus();
      await tester.pumpAndSettle();
      expect(reusedNode.hasFocus, isTrue);
      expect(focusChanges, <bool>[true, true, false, true]);
      expect(tester.widget<AnimalFocusRing>(focusRing).focused, isTrue);
    },
  );
  testWidgets(
    'N09 interactive AnimalIcon keeps its label, borrowed focus, and one activation',
    (tester) async {
      final FocusNode focusNode = FocusNode();
      int activations = 0;
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          AnimalIcon(
            data: AnimalIcons.heart,
            size: 16,
            semanticLabel: 'Favorite icon action',
            focusNode: focusNode,
            onTap: () => activations++,
          ),
        ),
      );

      final Finder target = find.byType(InteractiveRegion);
      final SemanticsFinder semanticsTarget = find.semantics.byLabel(
        RegExp('Favorite icon action'),
      );
      expect(semanticsTarget, findsOneWidget);
      final Rect rect = tester.getRect(target);
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));
      focusNode.requestFocus();
      await tester.pump();
      tester.semantics.tap(semanticsTarget);
      await tester.pump();
      expect(activations, 1);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        _app(
          InteractiveRegion(
            focusNode: focusNode,
            onPressed: () => activations++,
            enableHaptics: false,
            child: const Text('Remounted borrowed target'),
          ),
        ),
      );
      focusNode.requestFocus();
      await tester.pump();
      expect(focusNode.hasFocus, isTrue, reason: 'Borrowed node survives');
      await tester.pumpWidget(const SizedBox.shrink());
      semantics.dispose();
      focusNode.dispose();
    },
  );
}
