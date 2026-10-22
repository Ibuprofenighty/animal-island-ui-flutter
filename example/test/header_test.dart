import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/home.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  for (final width in [375.0, 1440.0]) {
    testWidgets(
      'Home has no document chrome before and after navigation at $width',
      (t) async {
        t.view.physicalSize = Size(width, 812);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        var path = '/';
        await t.pumpWidget(
          MaterialApp(
            theme: galleryTheme(),
            home: StatefulBuilder(
              builder: (_, set) => MediaQuery(
                data: MediaQueryData(
                  size: Size(width, 812),
                  disableAnimations: true,
                ),
                child: GalleryPage(
                  path: path,
                  onNavigate: (next) => set(() => path = next),
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        void noChrome() {
          expect(find.byType(Drawer), findsNothing);
          expect(
            find.byWidgetPredicate(
              (w) => w is IslandTooltip && ['返回首页', '打开导航'].contains(w.message),
            ),
            findsNothing,
          );
          expect(t.getTopLeft(find.byType(GalleryHome)).dy, 0);
        }

        noChrome();
        await t.tap(find.widgetWithText(IslandButton, '开始使用 →'));
        await t.pumpAndSettle();
        expect(path, '/skill');
        if (width == 375) {
          final back = find.descendant(
            of: find.byWidgetPredicate(
              (w) => w is IslandTooltip && w.message == '返回首页',
            ),
            matching: find.byType(IconButton),
          );
          expect(back, findsOneWidget);
          await t.tap(back);
        } else {
          await t.tap(find.text('Animal Island UI').first);
        }
        await t.pumpAndSettle();
        expect(path, '/');
        noChrome();
        expect(t.takeException(), isNull);
      },
    );
  }
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

  Finder action(String label) => find.descendant(
    of: find.byWidgetPredicate(
      (widget) => widget is IslandTooltip && widget.message == label,
    ),
    matching: find.byType(IconButton),
  );

  Future<void> show(
    WidgetTester tester, {
    Key? repaintKey,
    ValueChanged<String>? onNavigate,
    double width = 375,
  }) async {
    tester.view.physicalSize = Size(width, 812);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: repaintKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: galleryTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 812),
              disableAnimations: true,
            ),
            child: GalleryPage(
              path: '/collapse',
              onNavigate: onNavigate ?? (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    '375px header uses measured flex layout and keeps content origin',
    (tester) async {
      await show(tester);
      final back = tester.getRect(action('返回首页'));
      final menu = tester.getRect(action('打开导航'));
      expect(back, const Rect.fromLTWH(12, 11.5, 36, 28));
      expect(menu, const Rect.fromLTWH(329.03125, 11.5, 33.96875, 28));
      final headerTitle = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Collapse 折叠面板' &&
            widget.style?.fontSize == 15,
      );
      final title = tester.getRect(headerTitle);
      expect(title.left, closeTo(126.21875, .1));
      expect(title.top, 14.5);
      expect(title.width, closeTo(124.609375, .1));
      expect(title.height, 22);
      expect(title.center.dx, closeTo(188.5234375, .1));
      expect(tester.getTopLeft(find.byType(IslandTitle).first).dy, 68);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'menu paints three equal full bars without Unicode font fallback',
    (tester) async {
      final repaintKey = GlobalKey();
      await show(tester, repaintKey: repaintKey);
      expect(find.text('☰'), findsNothing);
      final boundary =
          repaintKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final pixels = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final colors = <int>[];
        for (var y = 18; y <= 34; y++) {
          for (var x = 338; x <= 353; x++) {
            final offset = (y * image.width + x) * 4;
            colors.add(
              bytes!.getUint8(offset) << 16 |
                  bytes.getUint8(offset + 1) << 8 |
                  bytes.getUint8(offset + 2),
            );
          }
        }
        image.dispose();
        return colors;
      });
      for (var y = 18; y <= 34; y++) {
        for (var x = 338; x <= 353; x++) {
          final color = pixels![(y - 18) * 16 + x - 338];
          final isBar =
              x >= 339 && x <= 352 && [19, 20, 25, 26, 31, 32].contains(y);
          expect(color == 0x573719, isBar, reason: 'header pixel ($x, $y)');
        }
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('header actions are named once and retain navigation behavior', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final paths = <String>[];
      await show(tester, onNavigate: paths.add);
      for (final label in ['返回首页', '打开导航']) {
        final named = find.bySemanticsLabel(label);
        expect(named, findsOneWidget);
        final data = tester.getSemantics(named).getSemanticsData();
        expect(data.label, label);
        expect(data.flagsCollection.isButton, isTrue);
        expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
      }
      await tester.tap(action('打开导航'));
      await tester.pumpAndSettle();
      expect(find.byType(Drawer), findsOneWidget);
      expect(paths, isEmpty);
      await tester.tapAt(const Offset(360, 200));
      await tester.pumpAndSettle();
      await tester.tap(action('返回首页'));
      expect(paths, ['/']);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('desktop Gallery has no mobile header actions', (tester) async {
    await show(tester, width: 768);
    expect(action('返回首页'), findsNothing);
    expect(action('打开导航'), findsNothing);
    expect(tester.getTopLeft(find.byType(IslandTitle).first).dy, 32);
    expect(tester.takeException(), isNull);
  });
}
