import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/home.dart';
import 'package:island_gallery/shared/palette.dart';
import 'package:island_gallery/shared/theme.dart';

import '../../test/support/fake_clock_only.dart';

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
        expect(find.byType(IslandLoading), findsOneWidget);
        await t.pump(const Duration(seconds: 2));
        await t.pumpAndSettle();
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
          expect(color == 0x725d42, isBar, reason: 'header pixel ($x, $y)');
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

  group('reference shell', () {
    Future<void> showPath(
      WidgetTester tester,
      String path, {
      double width = 1440,
      bool reduced = true,
    }) async {
      tester.view.physicalSize = Size(width, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var current = path;
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: galleryTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 812),
              disableAnimations: reduced,
            ),
            child: StatefulBuilder(
              builder: (_, set) => GalleryPage(
                path: current,
                onNavigate: (next) => set(() => current = next),
              ),
            ),
          ),
        ),
      );
      if (reduced) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }
    }

    Finder item(String label) => find.widgetWithText(TextButton, label);
    // The sidebar aside's painted box (its Container margin excluded).
    Rect aside(WidgetTester tester) => tester.getRect(
      find
          .descendant(
            of: find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.margin == const EdgeInsets.fromLTRB(12, 12, 0, 8),
            ),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    BoxDecoration badge(WidgetTester tester, String label) =>
        tester
                .widget<Container>(
                  find
                      .ancestor(
                        of: find.descendant(
                          of: item(label),
                          matching: find.text('NEW'),
                        ),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;

    // The fill behind a sidebar item (reference S.menuItem): its target, and
    // the colour painted in the current frame.
    Finder fillBox(String label) => find
        .ancestor(of: item(label), matching: find.byType(AnimatedContainer))
        .first;
    Color? fill(WidgetTester tester, String label) =>
        (tester.widget<AnimatedContainer>(fillBox(label)).decoration!
                as BoxDecoration)
            .color;
    Color? painted(WidgetTester tester, String label) =>
        (tester
                    .renderObject<RenderDecoratedBox>(
                      find
                          .descendant(
                            of: fillBox(label),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration)
            .color;
    Color? ink(WidgetTester tester, String label) => tester
        .widget<TextButton>(item(label))
        .style!
        .foregroundColor!
        .resolve({});
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
    }

    testWidgets('sidebar items hover without ripple; NEW badge inverts', (
      tester,
    ) async {
      await showPath(tester, '/skill');
      Color? overlay(String label, Set<WidgetState> states) => tester
          .widget<TextButton>(item(label))
          .style!
          .overlayColor!
          .resolve(states);
      expect(fill(tester, 'Button 按钮')!.a, 0);
      expect(fill(tester, 'Skill 介绍'), const Color(0xffb7c6e5));
      // The Skill page's 2s mount Loading blocks pointer input until it lifts.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(item('Button 按钮')));
      await tester.pumpAndSettle();
      expect(fill(tester, 'Button 按钮'), const Color(0xffd6dff0));
      await mouse.moveTo(tester.getCenter(item('Skill 介绍')));
      await tester.pumpAndSettle();
      expect(fill(tester, 'Button 按钮')!.a, 0);
      expect(
        fill(tester, 'Skill 介绍'),
        const Color(0xffb7c6e5),
        reason: 'the active item keeps #B7C6E5',
      );
      expect(overlay('Button 按钮', {WidgetState.hovered}), Colors.transparent);
      expect(overlay('Button 按钮', {WidgetState.pressed}), Colors.transparent);
      expect(
        tester.widget<TextButton>(item('Button 按钮')).style!.splashFactory,
        NoSplash.splashFactory,
      );
      final active = badge(tester, 'Skill 介绍');
      expect(active.color, Colors.white);
      expect(active.gradient, isNull);
      expect(active.boxShadow!.single.color, const Color(0x26725d42));
      final inactive = badge(tester, 'Icon 图标');
      expect((inactive.gradient! as LinearGradient).colors, const [
        Color(0xfffc736d),
        Color(0xfff7825a),
      ]);
      expect(inactive.boxShadow!.single.color, const Color(0x40725d42));
      expect(tester.takeException(), isNull);
    });

    testWidgets('sidebar fill and ink move together over 0.15s ease', (
      tester,
    ) async {
      await showPath(tester, '/title', reduced: false);
      expect(ink(tester, 'Title 标题'), GalleryPalette.navActiveInk);
      expect(ink(tester, 'Button 按钮'), GalleryPalette.navInk);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      addTearDown(mouse.removePointer);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(item('Button 按钮')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      expect(
        painted(tester, 'Button 按钮')!.a,
        allOf(greaterThan(0), lessThan(1)),
      );
      await tester.pump(const Duration(milliseconds: 80));
      expect(painted(tester, 'Button 按钮'), GalleryPalette.navHover);
      // Navigation: the new active item's fill and ink change over 0.15s.
      await tester.tap(item('Button 按钮'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 75));
      final step = painted(tester, 'Button 按钮')!;
      expect(step, isNot(GalleryPalette.navHover));
      expect(step, isNot(GalleryPalette.navActive));
      final midInk = ink(tester, 'Button 按钮')!;
      expect(midInk, isNot(GalleryPalette.navInk));
      expect(midInk, isNot(GalleryPalette.navActiveInk));
      // The intermediate pair stays readable.
      expect(ratio(midInk, step), greaterThanOrEqualTo(4.5));
      await tester.pump(const Duration(milliseconds: 80));
      expect(painted(tester, 'Button 按钮'), GalleryPalette.navActive);
      expect(ink(tester, 'Button 按钮'), GalleryPalette.navActiveInk);
      expect(painted(tester, 'Title 标题')!.a, 0);
      expect(ink(tester, 'Title 标题'), GalleryPalette.navInk);
      await tester.pumpWidget(const SizedBox());
    }, skip: fakeClockOnly);

    testWidgets('shell inks follow the measured reference colours', (
      tester,
    ) async {
      await showPath(tester, '/collapse');
      Color? textColor(Finder finder) =>
          tester.widget<Text>(finder.first).style?.color;
      expect(textColor(find.text('Animal Island UI')), const Color(0xff725d42));
      expect(textColor(find.text('── 基础 ──')), GalleryPalette.navGroupInk);
      expect(ink(tester, 'Button 按钮'), GalleryPalette.navInk);
      expect(ink(tester, 'Collapse 折叠面板'), GalleryPalette.navActiveInk);
      // Aside, hover fill and the bottom wave under the scrolling list.
      for (final surface in const [
        Color(0xfffaf8f3),
        Color(0xffd6dff0),
        Color(0xffa2b0e7),
      ]) {
        expect(
          ratio(GalleryPalette.navInk, surface),
          greaterThanOrEqualTo(4.5),
        );
        if (surface != const Color(0xffd6dff0)) {
          expect(
            ratio(GalleryPalette.navGroupInk, surface),
            greaterThanOrEqualTo(4.5),
          );
        }
      }
      expect(
        ratio(GalleryPalette.navActiveInk, GalleryPalette.navActive),
        greaterThanOrEqualTo(4.5),
      );
      // Page description over the wallpaper and its largest dot.
      final description = find.byWidgetPredicate(
        (w) =>
            w is Text &&
            w.style?.fontSize == 14 &&
            w.style?.color == GalleryPalette.pageDescription,
      );
      expect(description, findsOneWidget);
      for (final surface in [
        IslandTokens.light.canvas,
        Color.alphaBlend(
          GalleryPalette.wallpaperLargeDot,
          IslandTokens.light.canvas,
        ),
      ]) {
        expect(
          ratio(GalleryPalette.pageDescription, surface),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('sidebar group labels are 17px line boxes', (tester) async {
      await showPath(tester, '/collapse');
      for (final label in ['── 指南 ──', '── 基础 ──', '── 表单 ──']) {
        expect(tester.getSize(find.text(label)).height, 17);
      }
      // Label line box, its 4px bottom padding, then the item's 1px margin.
      final label = tester.getRect(find.text('── 基础 ──'));
      expect(tester.getTopLeft(item('Title 标题')).dy, label.bottom + 4 + 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('NEW badge pulses 1.8s unless motion is reduced', (
      tester,
    ) async {
      double scale() => tester
          .widget<Transform>(
            find
                .ancestor(
                  of: find.descendant(
                    of: item('Icon 图标'),
                    matching: find.text('NEW'),
                  ),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .getMaxScaleOnAxis();
      await showPath(tester, '/title');
      expect(scale(), 1);
      await tester.pump(const Duration(seconds: 1));
      expect(scale(), 1);

      await showPath(tester, '/title', reduced: false);
      expect(scale(), closeTo(1, 1e-6));
      await tester.pump(const Duration(milliseconds: 900));
      expect(scale(), closeTo(1.08, 1e-6));
      await tester.pump(const Duration(milliseconds: 900));
      expect(scale(), closeTo(1, 1e-6));
      await tester.pumpWidget(const SizedBox());
    }, skip: fakeClockOnly);

    testWidgets('desktop sidebar and content follow reference geometry', (
      tester,
    ) async {
      await showPath(tester, '/collapse');
      expect(aside(tester), const Rect.fromLTRB(12, 12, 232, 812 - 8));
      final scroll = tester.widget<SingleChildScrollView>(
        find
            .ancestor(
              of: find.byType(IslandTitle).first,
              matching: find.byType(SingleChildScrollView),
            )
            .first,
      );
      expect(scroll.padding, const EdgeInsets.fromLTRB(40, 32, 40, 32));
      // Reference App root arrow cursor plus the sidebar Cursor raindrop.
      expect(
        tester
            .widget<IslandCursor>(
              find
                  .ancestor(
                    of: item('Cursor 光标'),
                    matching: find.byType(IslandCursor),
                  )
                  .first,
            )
            .variant,
        IslandCursorVariant.raindrop,
      );
      expect(
        find.ancestor(
          of: find.byType(Scaffold),
          matching: find.byWidgetPredicate(
            (w) => w is IslandCursor && w.variant == IslandCursorVariant.arrow,
          ),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('chart group closes the sidebar and its last item scrolls in', (
      tester,
    ) async {
      await showPath(tester, '/charts');
      final heading = find.text('── 图表统计 ──');
      expect(heading, findsOneWidget);
      expect(
        tester.getTopLeft(heading).dy,
        greaterThan(tester.getTopLeft(find.text('── 数据展示 ──')).dy),
      );
      expect(badge(tester, 'Chart 图表总览').color, Colors.white);
      expect(
        find.descendant(of: item('Column 柱状图'), matching: find.text('NEW')),
        findsNothing,
      );
      final menu = find
          .descendant(
            of: find.byWidgetPredicate(
              (w) =>
                  w is Container &&
                  w.margin == const EdgeInsets.fromLTRB(12, 12, 0, 8),
            ),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(item('Map 地图统计'), 100, scrollable: menu);
      await tester.pumpAndSettle();
      expect(item('Map 地图统计').hitTestable(), findsOneWidget);
      expect(
        aside(tester).contains(tester.getBottomLeft(item('Map 地图统计'))),
        isTrue,
      );
      // Reference v4.0.0 logo `transform: translateY(-2px)`.
      final logo = find.byType(Image).first;
      final title = find.text('Animal Island UI').first;
      expect(
        tester.getCenter(logo).dy,
        closeTo(tester.getCenter(title).dy - 2, .5),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile drawer is the 240px aside over a .35 scrim', (
      tester,
    ) async {
      await showPath(tester, '/collapse', width: 375);
      final scroll = tester.widget<SingleChildScrollView>(
        find
            .ancestor(
              of: find.byType(IslandTitle).first,
              matching: find.byType(SingleChildScrollView),
            )
            .first,
      );
      expect(scroll.padding, const EdgeInsets.all(16));
      Finder scrim() => find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == const Color(0x59000000),
      );
      expect(scrim(), findsNothing);
      await tester.tap(action('打开导航'));
      await tester.pumpAndSettle();
      expect(aside(tester), const Rect.fromLTRB(12, 12, 252, 812 - 8));
      // The overlay covers the whole viewport, header included.
      expect(tester.getRect(scrim()), const Rect.fromLTWH(0, 0, 375, 812));
      expect(tester.takeException(), isNull);
    });

    testWidgets('mobile drawer appears and leaves at once, as the reference', (
      tester,
    ) async {
      await showPath(tester, '/collapse', width: 375, reduced: false);
      Finder scrim() => find.byWidgetPredicate(
        (w) => w is ColoredBox && w.color == const Color(0x59000000),
      );
      await tester.tap(action('打开导航'));
      await tester.pump();
      // First frame: the full scrim and the aside at its resting place.
      expect(scrim(), findsOneWidget);
      expect(aside(tester), const Rect.fromLTRB(12, 12, 252, 812 - 8));
      await tester.tapAt(const Offset(360, 400));
      await tester.pump();
      expect(find.byType(Drawer), findsNothing);
      expect(scrim(), findsNothing);
      // Navigating from the drawer closes it with the route change.
      await tester.tap(action('打开导航'));
      await tester.pump();
      await tester.tap(item('Button 按钮'));
      await tester.pump();
      expect(find.byType(Drawer), findsNothing);
      expect(scrim(), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }, skip: fakeClockOnly);

    testWidgets('background wallpaper fades over 0.45s and back', (
      tester,
    ) async {
      await showPath(tester, '/title', reduced: false);
      await tester.tap(item('Background 背景'));
      await tester.pump();
      await tester.pump();
      double opacity() => tester
          .widget<Opacity>(
            find
                .ancestor(
                  of: find.byType(IslandBackground),
                  matching: find.byType(Opacity),
                )
                .first,
          )
          .opacity;
      final start = opacity();
      await tester.pump(const Duration(milliseconds: 225));
      expect(opacity(), allOf(greaterThan(start), lessThan(1)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(opacity(), 1);
      await tester.tap(item('Title 标题'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 225));
      expect(opacity(), allOf(greaterThan(0), lessThan(1)));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      expect(find.byType(IslandBackground), findsNothing);
      await tester.pumpWidget(const SizedBox());
    }, skip: fakeClockOnly);
  });

  testWidgets('desktop Gallery has no mobile header actions', (tester) async {
    await show(tester, width: 768);
    expect(action('返回首页'), findsNothing);
    expect(action('打开导航'), findsNothing);
    expect(tester.getTopLeft(find.byType(IslandTitle).first).dy, 32);
    expect(tester.takeException(), isNull);
  });
}
