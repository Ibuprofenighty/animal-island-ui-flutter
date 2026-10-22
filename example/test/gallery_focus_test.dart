import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/catalog.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  setUpAll(() async {
    for (final entry in {
      'Nunito': ['nunito-latin-500-normal.ttf', 'nunito-latin-700-normal.ttf'],
      'IslandGallerySans': [
        'IslandGallerySans-400.ttf',
        'IslandGallerySans-500.ttf',
        'IslandGallerySans-900.ttf',
      ],
      'GROBOLD': ['GROBOLD.ttf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final asset in entry.value) {
        loader.addFont(rootBundle.load('assets/fonts/$asset'));
      }
      await loader.load();
    }
  });

  Future<void> show(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: galleryTheme(),
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(width, 1000),
            disableAnimations: true,
          ),
          child: GalleryPage(path: '/collapse', onNavigate: (_) {}),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tab(WidgetTester tester, {bool reverse = false}) async {
    if (reverse) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    if (reverse) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
  }

  void expectDisclosureFocus(WidgetTester tester, int index) {
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<IslandCollapse>(),
      same(tester.widget(find.byType(IslandCollapse).at(index))),
      reason: 'Tab must remain in the document region, on disclosure $index',
    );
  }

  bool expanded(WidgetTester tester, int index) =>
      tester
          .getSize(
            find.descendant(
              of: find.byType(IslandCollapse).at(index),
              matching: find.byType(SizeTransition),
            ),
          )
          .height >
      0;

  for (final scenario in [(1440.0, 0.0), (1440.0, 650.0), (375.0, 0.0)]) {
    testWidgets(
      'document Tab order at ${scenario.$1} with sidebar scroll ${scenario.$2}',
      (tester) async {
        await show(tester, scenario.$1);
        if (scenario.$2 > 0) {
          await tester.drag(
            find
                .ancestor(
                  of: find.widgetWithText(TextButton, 'Skill 介绍'),
                  matching: find.byType(Scrollable),
                )
                .first,
            Offset(0, -scenario.$2),
          );
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('1個島嶼可以登錄多少名用戶?'));
        await tester.pumpAndSettle();
        expectDisclosureFocus(tester, 0);
        expect(expanded(tester, 0), isTrue);

        await tab(tester);
        expectDisclosureFocus(tester, 1);
        await tester.sendKeyEvent(LogicalKeyboardKey.space);
        await tester.pumpAndSettle();
        expect(expanded(tester, 0), isTrue);
        expect(expanded(tester, 1), isTrue);

        await tab(tester, reverse: true);
        expectDisclosureFocus(tester, 0);
        await tab(tester);
        expectDisclosureFocus(tester, 1);
        await tab(tester);
        expectDisclosureFocus(tester, 2);
        await tab(tester);
        // The disabled fourth disclosure is not a keyboard target. The next
        // real document action is the public CodeBlock copy control.
        expect(
          FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<IslandCodeBlock>(),
          same(tester.widget(find.byType(IslandCodeBlock))),
        );
        expect(expanded(tester, 3), isFalse);
        await tab(tester, reverse: true);
        expectDisclosureFocus(tester, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('all existing sidebar actions are reachable before content', (
    tester,
  ) async {
    await show(tester, 1440);
    final entries = galleryGroups.values.expand((group) => group).toList();
    // Local navigation already exposes keyboard actions. Their reachability
    // is a local contract, not a claim about reference DOM button semantics.
    // Begin with the home-logo action, then the first sidebar action.
    // Pointer activation of a Material button does not imply keyboard focus.
    await tab(tester);
    await tab(tester);
    for (var index = 0; index < entries.length; index++) {
      final target = find.widgetWithText(TextButton, entries[index].label);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<TextButton>(),
        same(tester.widget(target)),
        reason:
            'Existing sidebar action ${entries[index].id} must be reachable',
      );
      await tab(tester);
    }
    expect(entries.last.id, 'countup');
    expectDisclosureFocus(tester, 0);
    await tab(tester, reverse: true);
    expect(
      FocusManager.instance.primaryFocus?.context
          ?.findAncestorWidgetOfExactType<TextButton>(),
      same(tester.widget(find.widgetWithText(TextButton, entries.last.label))),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'reverse Tab from initial content reaches the final sidebar action',
    (tester) async {
      await show(tester, 1440);
      await tester.tap(find.text('1個島嶼可以登錄多少名用戶?'));
      await tester.pumpAndSettle();
      await tab(tester, reverse: true);
      final last = find.widgetWithText(
        TextButton,
        galleryGroups.values.last.last.label,
      );
      expect(
        last,
        findsOneWidget,
        reason: 'Reverse traversal must reach CountUp',
      );
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<TextButton>(),
        same(tester.widget(last)),
      );
      await tab(tester);
      expectDisclosureFocus(tester, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mobile drawer keeps its traversal scope and releases it on close',
    (tester) async {
      await show(tester, 375);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is IslandTooltip && w.message == '打开导航',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      for (var index = 0; index < 5; index++) {
        await tab(tester);
        expect(
          FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<Drawer>(),
          isNotNull,
          reason: 'Open drawer traversal must stay inside its existing scope',
        );
      }
      await tab(tester, reverse: true);
      expect(
        FocusManager.instance.primaryFocus?.context
            ?.findAncestorWidgetOfExactType<Drawer>(),
        isNotNull,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsNothing);
      await tester.tap(find.text('1個島嶼可以登錄多少名用戶?'));
      await tester.pumpAndSettle();
      await tab(tester);
      expectDisclosureFocus(tester, 1);
      expect(tester.takeException(), isNull);
    },
  );
}
