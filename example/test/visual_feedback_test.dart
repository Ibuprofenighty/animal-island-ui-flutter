import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

typedef VisualCapture = Future<void> Function(
  String name,
  ui.Image image,
  Map<String, Object?> metadata,
);
const feedbackSlides = [
  ('hillside-town.jpg', '山坡小筑', '沿坡而建的小镇，屋顶连成一片暖色。'),
  ('sunny-field.jpg', '阳光田野', '风掠过田野，草浪一层层推向天边。'),
  ('lake-morning.jpg', '晨光湖面', '湖面倒映天光，晨雾如薄纱浮在水上。'),
];

double feedbackContrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return (x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05));
}

void visualFeedbackOracles({VisualCapture? capture}) {
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

  testWidgets(
    'Official Home host has no fallback double underline on all owned copy',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      for (final size in [const Size(1440, 1000), const Size(375, 812)]) {
        t.view.physicalSize = size;
        final key = GlobalKey();
        await t.pumpWidget(
          RepaintBoundary(
            key: key,
            child: MaterialApp(
              theme: galleryTheme(),
              locale: const Locale('zh'),
              localizationsDelegates: IslandLocalizations.delegates,
              supportedLocales: IslandLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: GalleryPage(
                path: '/',
                wallpaperSeed: 42,
                onNavigate: (_) {},
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final styles = <Map<String, Object?>>[];
        for (final element in find.byType(RichText).evaluate()) {
          final text = element.widget as RichText;
          final style = (text.text as TextSpan).style;
          final fallback =
              style?.decorationStyle == TextDecorationStyle.double &&
              (style?.decoration?.contains(TextDecoration.underline) ?? false);
          styles.add({
            'text': text.text.toPlainText(),
            'fontFamily': style?.fontFamily,
            'fontSize': style?.fontSize,
            'decoration': style?.decoration.toString(),
            'decorationStyle': style?.decorationStyle.toString(),
            'decorationColor': style?.decorationColor?.toARGB32(),
            'fallback_double': fallback,
          });
          expect(fallback, isFalse, reason: text.text.toPlainText());
        }
        expect(
          styles.any((s) => (s['text'] as String).contains('Animal')),
          isTrue,
        );
        expect(styles.any((s) => (s['text'] as String).contains('向下')), isTrue);
        final render =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        if (capture != null) {
          final image = (await t.runAsync(() => render.toImage()))!;
          await capture('home-${size.width.toInt()}', image, {
            'size': [size.width, size.height],
            'seed': 42,
            'scroll': 0,
            'host': 'MaterialApp→GalleryPage→Scaffold/Material→GalleryHome',
            'resolved_styles': styles,
          });
          image.dispose();
        }
        debugPrint(
          'HOME_RESOLVED_STYLES=' +
              jsonEncode({'width': size.width, 'styles': styles}),
          wrapWidth: 200000,
        );
        await t.pumpWidget(const SizedBox());
      }
    },
  );
  testWidgets(
    'Gallery restores reference photo transparency and measures its approved caption contrast exception',
    (t) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      final observations = <Map<String, Object?>>[];
      final backgrounds = <int>{};
      for (final dark in [false, true]) {
        for (final size in [const Size(1440, 1000), const Size(375, 812)]) {
          t.view.physicalSize = size;
          final key = GlobalKey();
          await t.pumpWidget(
            RepaintBoundary(
              key: key,
              child: MaterialApp(
                theme: dark
                    ? galleryTheme().copyWith(
                        brightness: Brightness.dark,
                        colorScheme: const ColorScheme.dark(),
                      )
                    : galleryTheme(),
                locale: const Locale('zh'),
                localizationsDelegates: IslandLocalizations.delegates,
                supportedLocales: IslandLocalizations.supportedLocales,
                home: GalleryPage(path: '/carousel', onNavigate: (_) {}),
              ),
            ),
          );
          // Pause autoplay by its real focus contract before waiting for assets.
          await t.pump(const Duration(milliseconds: 1));
          final carousel = find.byType(IslandCarousel<String>);
          final layout = find
              .descendant(of: carousel, matching: find.byType(LayoutBuilder))
              .first;
          Focus.of(t.element(layout)).requestFocus();
          await t.pump();
          await t.runAsync(() async {
            for (final slide in feedbackSlides) {
              await precacheImage(
                AssetImage('assets/photos/${slide.$1}'),
                t.element(carousel),
              );
            }
          });
          for (var warmup = 0; warmup < 40; warmup++) {
            await t.pump(const Duration(milliseconds: 100));
          }
          await t.pumpAndSettle();
          final frame = t.getRect(carousel);
          final live = t.binding is LiveTestWidgetsFlutterBinding
              ? t.binding as LiveTestWidgetsFlutterBinding
              : null;
          final previousPolicy = live?.framePolicy;
          if (live != null) {
            addTearDown(() => live.framePolicy = previousPolicy!);
          }
          var frameClock = t.binding.currentSystemFrameTimeStamp;
          if (live != null) {
            live.framePolicy =
                LiveTestWidgetsFlutterBindingFramePolicy.benchmark;
          }
          Future<void> step(Duration duration) async {
            if (live == null) {
              await t.pump(duration);
            } else {
              frameClock += duration;
              await t.pumpBenchmark(frameClock);
            }
          }

          Future<void> inspect(
            int slide,
            int elapsed, {
            bool wrap = false,
          }) async {
            final observationStart = observations.length;
            final title = find.text(feedbackSlides[slide].$2),
                body = find.text(feedbackSlides[slide].$3);
            final tr = t.getRect(title), br = t.getRect(body);
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
            expect(br.top - tr.bottom, closeTo(6, .001));
            expect(t.getRect(carousel), frame);
            final movement = tr.left - frame.left - 28;
            final expectedMovement =
                18 *
                (1 - Curves.easeInOut.transform(elapsed.clamp(0, 300) / 300));
            expect(
              movement,
              closeTo(expectedMovement, .02),
              reason: 'Actual controlled-frame geometry must match the normal300ms animation, not screenshot readback wall time',
            );

            expect(
              tr.left - frame.left,
              inInclusiveRange(27.9, 46.1),
            ); // whole-slide18px entry displacement
            expect(frame.bottom - br.bottom, closeTo(58, .001));
            final render =
                key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = (await t.runAsync(() => render.toImage()))!;
            final bytes = (await t.runAsync(
              () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
            ))!;
            Color sample(double x, double y) {
              final q = render.globalToLocal(Offset(x, y));
              final i = (q.dy.floor() * image.width + q.dx.floor()) * 4;
              return Color.fromARGB(
                bytes.getUint8(i + 3),
                bytes.getUint8(i),
                bytes.getUint8(i + 1),
                bytes.getUint8(i + 2),
              );
            }

            bool core = false;
            for (var y = tr.top.ceil(); y < tr.bottom.floor() && !core; y++) {
              for (var x = tr.left.ceil(); x < tr.right.floor(); x++) {
                if (sample(x.toDouble(), y.toDouble()) == foreground) {
                  core = true;
                  break;
                }
              }
            }
            expect(
              core,
              isTrue,
              reason: 'An actual opaque caption text core must exist',
            );
            for (final f in [.05, .25, .5, .75, .95]) {
              final x =
                  tr.left + (br.width > tr.width ? br.width : tr.width) * f;
              final backing = sample(x, tr.bottom + 3);
              final ratio = feedbackContrast(foreground, backing);
              backgrounds.add(backing.toARGB32());
              observations.add({
                'width': size.width,
                'dark': dark,
                'slide': feedbackSlides[slide].$1,
                'elapsed_ms': elapsed,
                'wrap': wrap,
                'observed_movement_x': movement,
                'frame_clock_us':
                    t.binding.currentSystemFrameTimeStamp.inMicroseconds,
                'sample': [x, tr.bottom + 3],
                'foreground': foreground.toARGB32(),
                'backing': backing.toARGB32(),
                'ratio': ratio,
                'threshold': 4.5,
                'meets_threshold': ratio >= 4.5,
                'disposition': 'CAROUSEL-REFERENCE-CONTRAST-001 user-approved caption exception',
              });
              // CAROUSEL-REFERENCE-CONTRAST-001: user prefers the original
              // translucent photo caption. Record the deficit, never call it4.5PASS.
              expect(ratio.isFinite, isTrue);
            }
            final dots = find.descendant(
              of: carousel,
              matching: find.byWidgetPredicate(
                (w) =>
                    w is Semantics &&
                    w.properties.button == true &&
                    w.properties.selected != null,
              ),
            );
            expect(dots, findsNWidgets(3));
            for (final dot in dots.evaluate()) {
              final rect = t.getRect(
                find.byElementPredicate((e) => identical(e, dot)),
              );
              final ink = sample(rect.center.dx, rect.center.dy);
              final backing = sample(rect.center.dx, rect.center.dy + 10);
              final ratio = feedbackContrast(ink, backing);
              expect(
                ratio,
                greaterThanOrEqualTo(3.0),
                reason: 'Actual active/inactive dot core on its white control backing',
              );
              observations.add({
                'width': size.width,
                'dark': dark,
                'slide': feedbackSlides[slide].$1,
                'elapsed_ms': elapsed,
                'wrap': wrap,
                'observed_movement_x': movement,
                'frame_clock_us':
                    t.binding.currentSystemFrameTimeStamp.inMicroseconds,
                'role': 'dot',
                'foreground': ink.toARGB32(),
                'backing': backing.toARGB32(),
                'ratio': ratio,
                'threshold': 3.0,
              });
            }
            if (capture != null) {
              await capture(
                'carousel-${size.width.toInt()}-${dark ? 'dark' : 'light'}-$slide-$elapsed${wrap ? '-loop' : ''}',
                image,
                {
                  'size': [size.width, size.height],
                  'theme': dark ? 'dark' : 'light',
                  'photo': feedbackSlides[slide].$1,
                  'elapsed_ms': elapsed,
                  'wrap': wrap,
                  'observed_movement_x': movement,
                  'frame_clock_us':
                      t.binding.currentSystemFrameTimeStamp.inMicroseconds,
                  'carousel_rect': [
                    frame.left,
                    frame.top,
                    frame.width,
                    frame.height,
                  ],
                  'title_rect': [tr.left, tr.top, tr.width, tr.height],
                  'body_rect': [br.left, br.top, br.width, br.height],
                  'observations': observations.sublist(observationStart),
                },
              );
            }
            image.dispose();
          }

          await inspect(0, 300);
          for (var turn = 1; turn <= 3; turn++) {
            final slide = turn % 3;
            final wrap = turn == 3;
            await t.tap(
              find.byWidgetPredicate(
                (w) =>
                    w is Semantics &&
                    w.properties.button == true &&
                    w.properties.label == '下一张',
              ),
            );
            await step(Duration.zero);
            if (live != null) {
              await step(Duration.zero);
            }
            await inspect(slide, 0, wrap: wrap);
            await step(const Duration(milliseconds: 16));
            await inspect(slide, 16, wrap: wrap);
            await step(const Duration(milliseconds: 134));
            await inspect(slide, 150, wrap: wrap);
            await step(const Duration(milliseconds: 150));
            await inspect(slide, 300, wrap: wrap);
          }
          final gradients = find
              .byType(DecoratedBox)
              .evaluate()
              .map((e) => (e.widget as DecoratedBox).decoration)
              .whereType<BoxDecoration>()
              .map((d) => d.gradient)
              .whereType<LinearGradient>()
              .where(
                (g) =>
                    g.begin == Alignment.bottomCenter &&
                    g.end == Alignment.topCenter,
              );
          expect(
            gradients.any(
              (g) =>
                  g.stops.toString() == [0.0, .62].toString() &&
                  g.colors.length == 2 &&
                  g.colors.first == const Color.fromRGBO(43, 33, 24, .72) &&
                  g.colors.last == Colors.transparent,
            ),
            isTrue,
            reason: 'Restore the pinned reference original .72 tint /62% stop without adaptive support',
          );
          if (live != null) {
            live.framePolicy = previousPolicy!;
          }
          await t.pumpWidget(const SizedBox());
        }
      }
      debugPrint(
        'PHOTO_GRADIENT_PIXEL_OBSERVATIONS=' + jsonEncode(observations),
        wrapWidth: 200000,
      );
      // Different real photos remain visible through the supporting gradient;
      // an opaque rectangular caption backplane cannot satisfy this requirement.
      expect(backgrounds.length, greaterThan(3));
    },
  );
}

void main() => visualFeedbackOracles();
