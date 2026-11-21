import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/story.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  setUpAll(loadGalleryFonts);
  for (final route in [
    'select',
    'date-picker',
    'pagination',
    'image',
    'tooltip',
  ]) {
    testWidgets('$route parent containment at narrow widths and desktop', (
      t,
    ) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      for (final width in [320.0, 360.0, 375.0, 390.0, 414.0, 1440.0]) {
        t.view.physicalSize = Size(width, 1000);
        await t.pumpWidget(
          MaterialApp(
            theme: galleryTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: GalleryPage(
              key: ValueKey('$route-$width'),
              path: '/$route',
              onNavigate: (_) {},
            ),
          ),
        );
        await t.pumpAndSettle();
        final panel = find.byType(StoryPanel).first;
        final content = t.getRect(panel).deflate(25);
        final controls = find.descendant(
          of: panel,
          matching: find.byWidgetPredicate(
            (w) =>
                w is IslandSelect<String> ||
                w is IslandDatePicker ||
                w is IslandPagination ||
                w is IslandImage,
          ),
        );
        for (final element in controls.evaluate()) {
          final target = find.byElementPredicate((e) => identical(e, element));
          final rect = t.getRect(target);
          expect(
            rect.left,
            greaterThanOrEqualTo(content.left - .001),
            reason: '$route $width ${element.widget.runtimeType} left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(content.right + .001),
            reason: '$route $width ${element.widget.runtimeType} right',
          );
          if (element.widget is IslandPagination) {
            final actions = find.descendant(
              of: target,
              matching: find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.button == true,
              ),
            );
            for (final action in actions.evaluate()) {
              final r = t.getRect(
                find.byElementPredicate((e) => identical(e, action)),
              );
              expect(r.left, greaterThanOrEqualTo(rect.left - .001));
              expect(r.right, lessThanOrEqualTo(rect.right + .001));
            }
          }
        }
        final heading = find
            .descendant(of: panel, matching: find.byType(IslandTag))
            .first;
        expect(
          t.getRect(heading).right,
          lessThanOrEqualTo(content.right + .001),
        );
        if (route == 'tooltip') {
          final horizontal = find
              .descendant(
                of: panel,
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is SingleChildScrollView &&
                      w.scrollDirection == Axis.horizontal,
                ),
              )
              .first;
          final viewport = t.getRect(horizontal);
          expect(viewport.left, greaterThanOrEqualTo(content.left));
          expect(viewport.right, lessThanOrEqualTo(content.right));
          final right = find.widgetWithText(IslandButton, 'right');
          await t.ensureVisible(right);
          await t.pumpAndSettle();
          final r = t.getRect(right);
          expect(r.left, greaterThanOrEqualTo(viewport.left - .001));
          expect(r.right, lessThanOrEqualTo(viewport.right + .001));
        }
        expect(t.takeException(), isNull);
      }
    });
  }

  Future<void> showRoute(WidgetTester t, String route, double width) async {
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetPhysicalSize);
    t.view.physicalSize = Size(width, 1000);
    await t.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        locale: const Locale('zh'),
        localizationsDelegates: IslandLocalizations.delegates,
        supportedLocales: IslandLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: GalleryPage(
          key: ValueKey('$route-$width'),
          path: '/$route',
          onNavigate: (_) {},
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  testWidgets('rate count=10 stars stay reachable inside their demo box', (
    t,
  ) async {
    for (final width in [320.0, 375.0, 1440.0]) {
      await showRoute(t, 'rate', width);
      final rate = find.byWidgetPredicate(
        (w) => w is IslandRate && w.count == 10,
      );
      await t.ensureVisible(rate);
      await t.pumpAndSettle();
      final box = t.getRect(
        find.ancestor(of: rate, matching: find.byType(StoryDemoBox)).first,
      );
      final viewport = t.getRect(
        find.ancestor(of: rate, matching: find.byType(Scrollable)).first,
      );
      expect(viewport.left, greaterThanOrEqualTo(box.left), reason: '$width');
      expect(viewport.right, lessThanOrEqualTo(box.right), reason: '$width');
      final last = find.descendant(
        of: rate,
        matching: find.bySemanticsLabel('10 星'),
      );
      await t.ensureVisible(last);
      await t.pumpAndSettle();
      final star = t.getRect(last);
      expect(star.right, lessThanOrEqualTo(viewport.right + .001));
      expect(star.left, greaterThanOrEqualTo(viewport.left - .001));
      expect(t.takeException(), isNull);
    }
  });

  testWidgets('Form API tables carry the reference titles', (t) async {
    await showRoute(t, 'form', 1440);
    expect(find.text('Form API'), findsOneWidget);
    expect(find.text('FormItem API'), findsOneWidget);
  });

  testWidgets('cursor page keeps the page selection outside raindrop boxes', (
    t,
  ) async {
    await showRoute(t, 'cursor', 1440);
    Color? selection(Finder finder) =>
        DefaultSelectionStyle.of(t.element(finder)).selectionColor;
    final arrow = selection(find.text('鼠标移入此区域将显示自定义光标'));
    final raindrop = selection(find.text('鼠标移入此区域将显示雨滴光标'));
    // Reference `.demo-raindrop-zone` changes only the cursor: the panel's
    // code block and API table keep the arrow highlight, and only the
    // raindrop preview (an `.animal-cursor` raindrop) resets it.
    expect(arrow, isNot(raindrop));
    expect(
      selection(
        find.descendant(
          of: find.byType(StoryCode),
          matching: find.byType(SelectableText),
        ),
      ),
      arrow,
    );
    expect(selection(find.text('forceAll')), arrow);
  });

  testWidgets('backtop code chip flows inline at the UA monospace size', (
    t,
  ) async {
    await showRoute(t, 'backtop', 375);
    final chip = find.text('visibilityHeight=400');
    expect(
      find.ancestor(
        of: chip,
        matching: find.byWidgetPredicate(
          (w) =>
              w is RichText && w.text.toPlainText().contains('意味着滚动超过 400px'),
        ),
      ),
      findsOneWidget,
    );
    expect(t.widget<Text>(chip).style!.fontSize, 12 * 13 / 16);
  });

  testWidgets('cursor native-control labels use bundled Arimo and fit', (
    t,
  ) async {
    await showRoute(t, 'cursor', 375);
    for (final label in ['按钮 (pointer)', '禁用 (not-allowed)']) {
      final text = find.text(label);
      final style = t.widget<DefaultTextStyle>(
        find.ancestor(of: text, matching: find.byType(DefaultTextStyle)).first,
      );
      expect(style.style.fontFamily, 'IslandGalleryControls', reason: label);
      // The label's natural width fits the line box it is given, so its
      // glyphs stay inside the native-control box.
      expect(
        t
            .renderObject<RenderParagraph>(text)
            .getMaxIntrinsicWidth(double.infinity),
        lessThanOrEqualTo(t.getSize(text).width + .5),
        reason: label,
      );
    }
  });
}
