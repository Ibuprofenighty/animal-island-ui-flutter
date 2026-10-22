import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/home.dart';
import 'package:island_gallery/shared/theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

Future<void> showStory(WidgetTester t, String path) async {
  t.view.physicalSize = const Size(1440, 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  await t.pumpWidget(
    MaterialApp(
      theme: galleryTheme(),
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(1440, 1000),
          disableAnimations: true,
        ),
        child: GalleryPage(path: path, onNavigate: (_) {}),
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  carouselCaptionContrastOracle();
  homeWallpaperContrastOracle();
  setUpAll(() async {
    for (final font in {
      'Nunito': [
        'nunito-latin-500-normal.ttf',
        'nunito-latin-700-normal.ttf',
        'nunito-latin-900-normal.ttf',
      ],
      'IslandGallerySans': [
        'IslandGallerySans-400.ttf',
        'IslandGallerySans-500.ttf',
        'IslandGallerySans-900.ttf',
      ],
      'GROBOLD': ['GROBOLD.ttf'],
    }.entries) {
      final loader = FontLoader(font.key);
      for (final asset in font.value) {
        loader.addFont(rootBundle.load('assets/fonts/$asset'));
      }
      await loader.load();
    }
  });

  testWidgets('Title captions remain readable on both dot layers', (t) async {
    await showStory(t, '/title');
    // Frozen reference tone1: small dots paint first, large dots overlap them.
    const base = Color(0xfffdf3d8),
        small = Color(0x1ff0d278),
        large = Color(0x26dcb450);
    final surfaces = [
      base,
      Color.alphaBlend(small, base),
      Color.alphaBlend(large, base),
      Color.alphaBlend(large, Color.alphaBlend(small, base)),
    ];
    final defaultBackground = Color.alphaBlend(
      const Color(0x2650aae6),
      Color.alphaBlend(const Color(0x1a8cd2fa), const Color(0xffddf0fa)),
    );
    for (final variant in ['layer', 'ribbon', 'tab']) {
      final text = t.widget<Text>(find.text('variant="$variant"'));
      expect(
        contrast(text.style!.color!, defaultBackground),
        greaterThanOrEqualTo(4.5),
      );
    }
    for (final name in [
      'default',
      'app-pink',
      'purple',
      'app-blue',
      'app-yellow',
      'app-orange',
      'app-teal',
      'app-green',
      'app-red',
      'lime-green',
      'yellow-green',
      'brown',
      'warm-peach-pink',
    ]) {
      final text = t.widget<Text>(find.text(name));
      for (final background in surfaces) {
        expect(
          contrast(text.style!.color!, background),
          greaterThanOrEqualTo(4.5),
          reason: name,
        );
      }
    }
  });

  testWidgets('Skill swatches and labels project the public product tokens', (
    t,
  ) async {
    await showStory(t, '/skill');
    final tokens = <String, Color>{
      'canvas': IslandTokens.light.canvas,
      'paper': IslandTokens.light.paper,
      'ink': IslandTokens.light.ink,
      'muted': IslandTokens.light.muted,
      'leaf': IslandTokens.light.leaf,
      'onLeaf': IslandTokens.light.onLeaf,
      'outline': IslandTokens.light.outline,
      'sun': IslandTokens.light.sun,
      'danger': IslandTokens.light.danger,
      'link': IslandTokens.light.link,
      'linkHover': IslandTokens.light.linkHover,
      'linkPressed': IslandTokens.light.linkPressed,
      'focus': IslandTokens.light.focus,
      'onCanvas': IslandTokens.light.onCanvas,
      'onSun': IslandTokens.light.onSun,
      'dangerText': IslandTokens.light.dangerText,
      'onDanger': IslandTokens.light.onDanger,
      'dangerHover': IslandTokens.light.dangerHover,
      'dangerPressed': IslandTokens.light.dangerPressed,
      'leafHover': IslandTokens.light.leafHover,
      'leafPressed': IslandTokens.light.leafPressed,
      'warning': IslandTokens.light.warning,
      'inputSurface': IslandTokens.light.inputSurface,
    };
    for (final entry in tokens.entries) {
      final label = find.text(entry.key);
      expect(label, findsOneWidget);
      final tile = find.ancestor(
        of: label,
        matching: find.byWidgetPredicate(
          (w) => w is Container && w.constraints?.maxWidth == 116,
        ),
      );
      expect(tile, findsOneWidget);
      expect(
        find.descendant(
          of: tile,
          matching: find.text(
            '#${entry.value.toARGB32().toRadixString(16).substring(2)}',
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: tile,
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.color == entry.value &&
                w.constraints?.maxHeight == 56,
          ),
        ),
        findsOneWidget,
      );
    }
    expect(find.text('text-color-secondary'), findsNothing);
  });
}

void carouselCaptionContrastOracle() {
  testWidgets(
    'Gallery Carousel captions contrast on all three actual photos at1440 and375',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      final observations = <Map<String, Object?>>[];
      const slides = [
        ('hillside-town.jpg', '山坡小筑', '沿坡而建的小镇，屋顶连成一片暖色。'),
        ('sunny-field.jpg', '阳光田野', '风掠过田野，草浪一层层推向天边。'),
        ('lake-morning.jpg', '晨光湖面', '湖面倒映天光，晨雾如薄纱浮在水上。'),
      ];
      for (final size in [const Size(1440, 1000), const Size(375, 812)]) {
        t.view.physicalSize = size;
        final boundary = GlobalKey();
        await t.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              theme: galleryTheme(),
              locale: const Locale('zh'),
              localizationsDelegates: IslandLocalizations.delegates,
              supportedLocales: IslandLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: GalleryPage(path: '/carousel', onNavigate: (_) {}),
            ),
          ),
        );
        await t.pumpAndSettle();
        final carousel = find.byType(IslandCarousel<String>);
        final context = t.element(carousel);
        await t.runAsync(() async {
          for (final slide in slides) {
            await precacheImage(
              AssetImage('assets/photos/${slide.$1}'),
              context,
            );
          }
        });
        final layout = find
            .descendant(of: carousel, matching: find.byType(LayoutBuilder))
            .first;
        Focus.of(t.element(layout)).requestFocus();
        await t.pumpAndSettle();
        final frame = t.getRect(carousel);
        for (var i = 0; i < slides.length; i++) {
          final title = find.text(slides[i].$2), body = find.text(slides[i].$3);
          expect(title, findsOneWidget);
          expect(body, findsOneWidget);
          final titleRect = t.getRect(title), bodyRect = t.getRect(body);
          final foreground =
              (t.renderObject<RenderParagraph>(title).text as TextSpan)
                  .style!
                  .color!;
          expect(
            (t.renderObject<RenderParagraph>(body).text as TextSpan)
                .style!
                .color,
            foreground,
          );
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = (await t.runAsync(() => render.toImage()))!;
          final bytes = (await t.runAsync(
            () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
          ))!;
          Color sample(Offset global) {
            final point = render.globalToLocal(global);
            final index =
                (point.dy.floor() * image.width + point.dx.floor()) * 4;
            return Color.fromARGB(
              bytes.getUint8(index + 3),
              bytes.getUint8(index),
              bytes.getUint8(index + 1),
              bytes.getUint8(index + 2),
            );
          }

          Color? actualCore;
          for (
            var y = titleRect.top.ceil();
            y < titleRect.bottom.floor() && actualCore == null;
            y++
          ) {
            for (
              var x = titleRect.left.ceil();
              x < titleRect.right.floor();
              x++
            ) {
              final c = sample(Offset(x.toDouble(), y.toDouble()));
              if (c == foreground) {
                actualCore = c;
                break;
              }
            }
          }
          expect(
            actualCore,
            isNotNull,
            reason: 'Actual opaque title core must be rendered, not inferred from declared style',
          );
          // The6px gap between the two owned plain-text lines is unpainted text
          // territory inside their shared backing. Never use antialiased glyph edges as backing.
          expect(bodyRect.top - titleRect.bottom, 6);
          final left = titleRect.left,
              width = bodyRect.width > titleRect.width
                  ? bodyRect.width
                  : titleRect.width;
          for (final fraction in [.05, .25, .5, .75, .95]) {
            final point = Offset(left + width * fraction, titleRect.bottom + 3);
            final backing = sample(point);
            final ratio = contrast(actualCore!, backing);
            observations.add({
              'width': size.width,
              'slide': slides[i].$1,
              'actual_foreground': actualCore.toARGB32(),
              'actual_backing': backing.toARGB32(),
              'sample': [point.dx, point.dy],
              'ratio': ratio,
            });
          }
          image.dispose();
          expect(t.getRect(carousel), frame);
          if (i < slides.length - 1) {
            await t.tap(
              find.byWidgetPredicate(
                (w) =>
                    w is Semantics &&
                    w.properties.button == true &&
                    w.properties.label == '下一张',
              ),
            );
            await t.pumpAndSettle();
          }
        }
        await t.pumpWidget(const SizedBox());
      }
      debugPrint(
        'CAROUSEL_CAPTION_PIXEL_OBSERVATIONS=' + jsonEncode(observations),
        wrapWidth: 200000,
      );
      expect(
        observations.every((r) => (r['ratio']! as double).isFinite),
        isTrue,
        reason: 'CAROUSEL-REFERENCE-CONTRAST-001 records actual ratios under the user-approved reference caption exception; this is not a4.5PASS',
      );
      expect(
        observations.map((r) => r['actual_backing']).toSet().length > 3,
        isTrue,
        reason: 'Real photo colors remain visible through the readable full-width gradient',
      );
    },
  );
}

void homeWallpaperContrastOracle({
  Future<void> Function(
    String name,
    ui.Image image,
    Map<String, Object?> metadata,
  )?
  capture,
}) {
  testWidgets(
    'Home reference-transparent copy records its approved wallpaper contrast exception',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(() => t.binding.setSurfaceSize(null));
      const description =
          'Kawaii 风格的 Flutter 组件库，基于 Dart 构建，让 Windows 与 Web 应用充满温暖质感';
      const sections = ['特性', '组件一览', '安装', '快速上手', '主题定制'];
      const descriptions = [
        '为什么选择 animal-island-ui',
        '详细文档与在线演示请从左侧菜单进入',
        '一行命令即可安装',
        '引入组件即可使用，样式自动加载',
        '通过作用域 Theme 实现运行时换肤，无需重新构建',
      ];
      final observations = <Map<String, Object?>>[];
      for (final width in [1440.0, 375.0]) {
        final size = Size(width, width == 1440 ? 1000 : 812);
        t.view.physicalSize = size;
        await t.binding.setSurfaceSize(size);
        for (final seed in [0, 7, 42]) {
          final boundary = GlobalKey();
          await t.pumpWidget(
            RepaintBoundary(
              key: boundary,
              child: MaterialApp(
                locale: const Locale('zh'),
                localizationsDelegates: IslandLocalizations.delegates,
                supportedLocales: IslandLocalizations.supportedLocales,
                theme: galleryTheme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: true),
                  child: child!,
                ),
                home: Scaffold(
                  body: GalleryHome(onNavigate: (_) {}, wallpaperSeed: seed),
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          Finder paragraph(String text) => find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText() == text,
          );
          Future<void> inspect(
            String role,
            Finder ink,
            List<Offset> backings,
          ) async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = (await t.runAsync(() => render.toImage()))!;
            final bytes = (await t.runAsync(
              () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
            ))!;
            Color pixel(Offset global) {
              final p = render.globalToLocal(global);
              final i = (p.dy.floor() * image.width + p.dx.floor()) * 4;
              return Color.fromARGB(
                bytes.getUint8(i + 3),
                bytes.getUint8(i),
                bytes.getUint8(i + 1),
                bytes.getUint8(i + 2),
              );
            }

            final rect = t.getRect(ink);
            Color? actualCore;
            for (
              var y = rect.top.ceil();
              y < rect.bottom.floor() && actualCore == null;
              y++
            ) {
              for (var x = rect.left.ceil(); x < rect.right.floor(); x++) {
                final color = pixel(Offset(x.toDouble(), y.toDouble()));
                if (color == IslandTokens.light.onCanvas) {
                  actualCore = color;
                  break;
                }
              }
            }
            expect(
              actualCore,
              isNotNull,
              reason: '$role requires actual opaque foreground pixels',
            );
            for (final point in backings) {
              final backing = pixel(point);
              observations.add({
                'width': width,
                'seed': seed,
                'role': role,
                'foreground': actualCore!.toARGB32(),
                'backing': backing.toARGB32(),
                'point': [point.dx, point.dy],
                'ratio': contrast(actualCore, backing),
                'threshold': 4.5,
                'meets_threshold': contrast(actualCore, backing) >= 4.5,
                'disposition': 'HOME-REFERENCE-CONTRAST-001 user-approved Home text exception',
              });
            }
            if (capture != null) {
              final roleIndex = role == 'hero typewriter copy'
                  ? 'hero'
                  : role == 'footer credit'
                  ? 'footer'
                  : 'section-${sections.indexOf(role.substring(8))}';
              await capture(
                'home-${width.toInt()}-seed$seed-$roleIndex',
                image,
                {
                  'size': [size.width, size.height],
                  'seed': seed,
                  'role': role,
                  'ink_rect': [rect.left, rect.top, rect.width, rect.height],
                  'observations': observations
                      .where(
                        (o) =>
                            o['width'] == width &&
                            o['seed'] == seed &&
                            o['role'] == role,
                      )
                      .toList(),
                  'contrast': 'HOME-REFERENCE-CONTRAST-001: explicit Home text exception, not4.5PASS',
                },
              );
            }
            image.dispose();
            expect(t.takeException(), isNull);
          }

          final body = paragraph(description);
          expect(body, findsOneWidget);
          final render = t.renderObject<RenderParagraph>(body);
          final spaces = <Offset>[];
          for (var i = 0; i < description.length; i++) {
            if (description[i] != ' ') continue;
            final boxes = render.getBoxesForSelection(
              TextSelection(baseOffset: i, extentOffset: i + 1),
            );
            for (final box in boxes)
              spaces.add(render.localToGlobal(box.toRect().center));
          }
          expect(spaces, isNotEmpty);
          await inspect('hero typewriter copy', body, spaces);
          for (var i = 0; i < sections.length; i++) {
            final title = find.byWidgetPredicate(
              (w) =>
                  w is Text && w.data == sections[i] && w.style?.fontSize == 24,
            );
            final desc = find.text(descriptions[i]);
            expect(title, findsOneWidget);
            expect(desc, findsOneWidget);
            await t.ensureVisible(title);
            await t.pumpAndSettle();
            final a = t.getRect(title), b = t.getRect(desc);
            expect(b.top - a.bottom, 8);
            final left = a.left < b.left ? a.left : b.left;
            final extent = a.width > b.width ? a.width : b.width;
            await inspect('section ' + sections[i], title, [
              for (final fraction in [.05, .25, .5, .75, .95])
                Offset(left + extent * fraction, a.bottom + 4),
            ]);
          }
          final credit = find.text('Flutter + Dart · Reference Gallery');
          await t.ensureVisible(credit);
          await t.pumpAndSettle();
          final cr = t.renderObject<RenderParagraph>(credit);
          final creditText = (t.widget<Text>(credit).data)!;
          final points = <Offset>[];
          for (var i = 0; i < creditText.length; i++)
            if (creditText[i] == ' ')
              for (final b in cr.getBoxesForSelection(
                TextSelection(baseOffset: i, extentOffset: i + 1),
              ))
                points.add(cr.localToGlobal(b.toRect().center));
          await inspect('footer credit', credit, points);
          await t.pumpWidget(const SizedBox());
        }
      }
      debugPrint(
        'HOME_WALLPAPER_PIXEL_OBSERVATIONS=' + jsonEncode(observations),
        wrapWidth: 1000000,
      );
      expect(
        observations.every((r) => (r['ratio']! as double).isFinite),
        isTrue,
        reason: 'HOME-REFERENCE-CONTRAST-001 measures actual ratios under the explicit user-approved Home text exception; not4.5PASS.',
      );
    },
  );
}
