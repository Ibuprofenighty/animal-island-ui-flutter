import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';
import 'package:island_gallery/shared/story.dart';

void main() {
  testWidgets(
    'placeholder controls stay inside their demo at viewport and fit boundaries',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      for (final width in [
        320.0,
        360.0,
        375.0,
        390.0,
        411.0,
        412.0,
        413.0,
        414.0,
        1440.0,
      ]) {
        t.view.physicalSize = Size(width, 1000);
        await t.pumpWidget(
          MaterialApp(
            theme: galleryTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            home: GalleryPage(path: '/select', onNavigate: (_) {}),
          ),
        );
        await t.pumpAndSettle();
        final fields = find.byType(IslandSelect<String>);
        final flower = t.getRect(fields.at(1)), fruit = t.getRect(fields.at(2));
        final content = t.getRect(find.byType(StoryDemoBox).first).deflate(17);
        for (final rect in [flower, fruit]) {
          expect(rect.size, const Size(140, 41));
          expect(rect.left, greaterThanOrEqualTo(content.left));
          expect(rect.right, lessThanOrEqualTo(content.right + .001));
          expect(rect.top, greaterThanOrEqualTo(content.top));
          expect(rect.bottom, lessThanOrEqualTo(content.bottom + .001));
        }
        if (content.width < 296) {
          expect(fruit.left, flower.left);
          expect(fruit.top - flower.bottom, 16);
        } else {
          expect(fruit.top, flower.top);
          expect(flower.left, content.left);
          expect(fruit.right, closeTo(content.right, .001));
          expect(fruit.left - flower.right, greaterThanOrEqualTo(16));
        }
        await t.ensureVisible(fields.at(2));
        await t.tap(fields.at(2));
        await t.pumpAndSettle();
        expect(find.text('蓝莓'), findsOneWidget);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'shared wrapping retains selection, child identity and focused trigger',
    (t) async {
      var width = 296.0;
      String? value;
      late StateSetter resize;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (_, set) {
                resize = set;
                return SizedBox(
                  width: width,
                  child: storyRow([
                    IslandSelect<String>(
                      label: 'Flower',
                      options: [const IslandOption(value: 'a', label: 'A')],
                      value: null,
                      onChanged: (_) {},
                    ),
                    IslandSelect<String>(
                      label: 'Fruit',
                      focusNode: focus,
                      options: [const IslandOption(value: 'b', label: 'B')],
                      value: value,
                      onChanged: (next) => set(() => value = next),
                    ),
                  ], alignment: WrapAlignment.spaceBetween),
                );
              },
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final fruit = find.byType(IslandSelect<String>).last;
      final state = t.state(fruit);
      focus.requestFocus();
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(value, 'b');
      for (final next in [295.9, 296.0, 296.1, 500.0, 238.0]) {
        resize(() => width = next);
        await t.pumpAndSettle();
        expect(t.state(fruit), same(state));
        expect(focus.hasPrimaryFocus, isTrue);
        expect(value, 'b');
        expect(t.getRect(fruit).right, lessThanOrEqualTo(next + .001));
      }
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(find.text('B'), findsNWidgets(2));
      expect(t.takeException(), isNull);
    },
  );

  setUpAll(loadGalleryFonts);
  testWidgets('Select trigger and popup geometry follows reference at 1440', (
    t,
  ) async {
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        home: GalleryPage(path: '/select', onNavigate: (_) {}),
      ),
    );
    await t.pumpAndSettle();
    final fields = find.byType(IslandSelect<String>);
    const expected = [
      Rect.fromLTWH(313, 332, 140, 41),
      Rect.fromLTWH(314, 467, 140, 41),
      Rect.fromLTWH(1218, 467, 140, 41),
      Rect.fromLTWH(313, 602, 140, 41),
      Rect.fromLTWH(313, 736, 140, 41),
      Rect.fromLTWH(469, 736, 140, 41),
      Rect.fromLTWH(313, 870, 213, 39),
      Rect.fromLTWH(542, 870, 213, 39),
    ];
    for (var i = 0; i < expected.length; i++) {
      expect(t.getRect(fields.at(i)), expected[i], reason: 'trigger $i');
    }
    final codeLabel = find
        .ancestor(of: find.text('使用示例'), matching: find.byType(Container))
        .first;
    expect(t.getTopLeft(codeLabel).dy - t.getBottomLeft(fields.at(6)).dy, 52);
    await t.tap(find.text('鲈鱼'));
    await t.pumpAndSettle();
    final option = find
        .ancestor(of: find.text('鲷鱼'), matching: find.byType(MouseRegion))
        .first;
    expect(t.getRect(option), const Rect.fromLTWH(459, 291, 102, 41));
  });
}
