import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:integration_test/integration_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/home.dart';
import 'package:island_gallery/pages/stories/registry.dart';
import 'package:island_gallery/shared/photos.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Source-bound full catalog static content, wide and narrow', (
    t,
  ) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(1440, 1000);
    await binding.setSurfaceSize(const Size(1440, 1000));
    final boundaryKey = GlobalKey();
    var path = '/upload';
    late StateSetter navigate;
    await t.pumpWidget(
      RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: const Locale('zh'),
          localizationsDelegates: IslandLocalizations.delegates,
          supportedLocales: IslandLocalizations.supportedLocales,
          theme: galleryTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: StatefulBuilder(
            builder: (context, set) {
              navigate = set;
              return GalleryPage(
                path: path,
                onNavigate: (value) => set(() => path = value),
              );
            },
          ),
        ),
      ),
    );
    final warmContext = t.element(find.byType(GalleryPage));
    await t.runAsync(() async {
      final errors = <Object>[];
      await Future.wait([
        for (final photo in galleryPhotos)
          precacheImage(
            AssetImage('assets/photos/$photo'),
            warmContext,
            onError: (error, stack) => errors.add(error),
          ),
      ]);
      expect(
        errors,
        isEmpty,
        reason: 'All shipped photo sources must decode; no placeholder-based visual proof.',
      );
    });
    final folder = Directory(
      const String.fromEnvironment('ISLAND_SCREENSHOT_DIR'),
    );
    expect(folder.path, isNotEmpty);
    await folder.create(recursive: true);
    final observations = <Map<String, Object?>>[];
    Future<void> capture(String name) async {
      final viewport = Offset.zero & t.getSize(find.byKey(boundaryKey));
      expect(
        viewport.size,
        Size(t.view.physicalSize.width, t.view.physicalSize.height),
      );
      final visibleVectors = find
          .byType(SvgPicture)
          .evaluate()
          .where(
            (e) => t
                .getRect(find.byElementPredicate((v) => identical(v, e)))
                .overlaps(viewport),
          )
          .toList();
      final visibleImages = find
          .byType(Image)
          .evaluate()
          .where(
            (e) => t
                .getRect(find.byElementPredicate((v) => identical(v, e)))
                .overlaps(viewport),
          )
          .toList();
      await t.runAsync(() async {
        for (final e in visibleVectors) {
          if (!e.mounted) continue;
          final picture = await vg.loadPicture(
            (e.widget as SvgPicture).bytesLoader,
            e,
          );
          picture.picture.dispose();
        }
        final errors = <Object>[];
        for (final e in visibleImages) {
          if (!e.mounted) continue;
          final image = (e.widget as Image).image;
          if (image is! AssetImage) continue;
          if ([
            'no-such-image.png',
            'assets/missing-avatar.png',
          ].contains(image.assetName))
            continue;
          await precacheImage(
            image,
            e,
            onError: (error, stack) => errors.add(error),
          );
        }
        expect(errors, isEmpty, reason: 'Visible packaged image readiness');
      });
      await t.pump();
      await t.pump(const Duration(milliseconds: 32));
      expect(t.takeException(), isNull, reason: name);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await File('${folder.path}/$name.png')
          .writeAsBytes(bytes!.buffer.asUint8List());
      observations.add({
        'name': name,
        'viewport': [viewport.width, viewport.height],
        'svg_loaders_awaited': visibleVectors.length,
        'visible_image_widgets': visibleImages.length,
      });
      await File('${folder.path}/observations.json')
          .writeAsString(jsonEncode(observations));
      debugPrint('Captured $name');
    }

    final rawRows = jsonDecode(
      await File(const String.fromEnvironment('ISLAND_REFERENCE_SEGMENTS'))
          .readAsString(),
    ) as List;
    final deduplicated = <String, Map<String, dynamic>>{};
    for (final value in rawRows) {
      final row = Map<String, dynamic>.from(value as Map);
      deduplicated[row['name'] as String] = row;
    }
    final scope = {...storyBuilders.keys, 'home'};
    for (final width in [1440.0, 375.0]) {
      final size = Size(width, width == 1440 ? 1000 : 812);
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = size;
      await binding.setSurfaceSize(size);
      final rows =
          deduplicated.values.where((v) => v['width'] == width.toInt()).toList()
            ..sort((a, b) {
              final byId = (a['id'] as String).compareTo(b['id'] as String);
              return byId != 0
                  ? byId
                  : (a['index'] as int).compareTo(b['index'] as int);
            });
      expect(rows.map((r) => r['id']).toSet(), unorderedEquals(scope));
      String? previous;
      for (final row in rows) {
        final id = row['id'] as String;
        if (previous != id) {
          navigate(() => path = id == 'home' ? '/' : '/$id');
          await t.pump();
          await t.pump(const Duration(milliseconds: 200));
          // BackTop deliberately scrolls after500ms on mount. Finish that known
          // demo timer before applying any reference capture position.
          if (id == 'backtop') await t.pump(const Duration(seconds: 1));
          if (id == 'countup') {
            await t.pump(const Duration(seconds: 3));
            expect(find.text('1,320'), findsWidgets);
          }
          if (id == 'typewriter')
            expect(find.text('第三行：继续加油吧！'), findsOneWidget);
          if (id == 'carousel') {
            final first = find.byWidgetPredicate(
              (w) =>
                  w is Semantics &&
                  w.properties.button == true &&
                  w.properties.label == '转到第 1 张',
            );
            await t.tap(first);
            await t.pump();
            expect(find.text('山坡小筑'), findsWidgets);
          }
          previous = id;
        }
        final anchor = id == 'home'
            ? find
                  .descendant(
                    of: find.byType(GalleryHome),
                    matching: find.byType(Scrollable),
                  )
                  .first
            : find.byType(IslandTitle).first;
        final position = id == 'home'
            ? (t.state(anchor) as ScrollableState).position
            : Scrollable.of(t.element(anchor)).position;
        final requested = (row['scroll'] as num).toDouble();
        position.jumpTo(requested.clamp(0, position.maxScrollExtent));
        await t.pump();
        await t.pump(const Duration(milliseconds: 50));
        await capture(row['name'] as String);
        expect(
          position.pixels,
          closeTo(requested.clamp(0, position.maxScrollExtent), .1),
          reason:
              'Capture must retain its actual reference-clamped position: ${row['name']}',
        );
        observations.last.addAll({
          'reference_scroll': requested,
          'actual_scroll': position.pixels,
          'id': id,
          'index': row['index'],
          'width': width.toInt(),
        });
        await File('${folder.path}/observations.json')
            .writeAsString(jsonEncode(observations));
      }
    }
    await t.pumpWidget(const SizedBox());
    await t.pump();
    t.view.resetPhysicalSize();
    t.view.resetDevicePixelRatio();
    await binding.setSurfaceSize(null);
  }, timeout: const Timeout(Duration(minutes: 15)));
}
