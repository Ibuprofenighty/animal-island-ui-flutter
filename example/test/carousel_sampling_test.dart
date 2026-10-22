import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

import 'support/gallery_fonts.dart';

void main() => registerCarouselConsumerCaptures();

void registerCarouselConsumerCaptures({String? captureDirectory}) {
  setUpAll(loadGalleryFonts);
  for (final width in [1440.0, 375.0]) {
    testWidgets('Gallery Carousel real photo caption sampling at $width', (
      t,
    ) async {
      final size = Size(width, width == 375 ? 812 : 1000);
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = size;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(() async {
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      });
      final boundary = GlobalKey();
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          locale: const Locale('zh'),
          localizationsDelegates: IslandLocalizations.delegates,
          supportedLocales: IslandLocalizations.supportedLocales,
          builder: (_, child) => RepaintBoundary(key: boundary, child: child!),
          home: GalleryPage(
            path: '/carousel',
            wallpaperSeed: 42,
            onNavigate: (_) {},
          ),
        ),
      );
      await t.runAsync(() async {
        final context = t.element(find.byType(GalleryPage));
        await Future.wait([
          for (final name in [
            'hillside-town.jpg',
            'sunny-field.jpg',
            'lake-morning.jpg',
          ])
            precacheImage(AssetImage('assets/photos/$name'), context),
        ]);
      });
      await t.pumpAndSettle();
      final carousel = find.byType(IslandCarousel<String>);
      expect(carousel, findsOneWidget);
      await t.ensureVisible(carousel);
      await t.pumpAndSettle();
      final next = IslandLocalizations.of(t.element(carousel)).nextSlide;
      final arrow = find.descendant(
        of: carousel,
        matching: find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.button == true &&
              w.properties.label == next,
        ),
      );
      expect(arrow, findsOneWidget);
      final rows = <Map<String, Object?>>[];
      Future<void> capture(String phase, int requested) async {
        final root =
            boundary.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final rect = t
            .getRect(carousel)
            .shift(-root.localToGlobal(Offset.zero));
        final output =
            captureDirectory ??
            Platform.environment['SURFACE_SAMPLING_EVIDENCE'];
        if (output != null)
          await t.runAsync(() async {
            final image = await root.toImage(pixelRatio: 1);
            final png = await image.toByteData(format: ui.ImageByteFormat.png);
            final dir = Directory('$output/gallery-carousel-$width')
              ..createSync(recursive: true);
            File('${dir.path}/$phase-$requested.png')
                .writeAsBytesSync(png!.buffer.asUint8List());
            rows.add({
              'phase': phase,
              'requested_elapsed_ms': requested,
              'pixels': [image.width, image.height],
              'render_target_dpr': 1,
              'carousel_bounds': [rect.left, rect.top, rect.right, rect.bottom],
              'actual_binding': t.binding.runtimeType.toString(),
              'content': 'Unchanged real CarouselStory three photos + original72%→transparent62% gradient + Chinese caption; official GalleryPage/Material host, seed42',
            });
            File('${dir.path}/captures.json')
                .writeAsStringSync(jsonEncode(rows));
            image.dispose();
          });
      }

      await capture('rest', 0);
      await t.tap(arrow);
      await t.pump();
      var previous = 0;
      for (final ms in [16, 64, 128]) {
        await t.pump(Duration(milliseconds: ms - previous));
        previous = ms;
        await capture('enter', ms);
      }
      await t.pumpAndSettle();
      await capture('settled', 300);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    });
  }
}
