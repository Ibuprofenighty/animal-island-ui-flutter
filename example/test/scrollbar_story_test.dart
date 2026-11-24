import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

Future<void> pumpGallery(
  WidgetTester t,
  String path,
  double width, {
  ValueChanged<String>? onNavigate,
}) async {
  t.view.physicalSize = Size(width, width == 375 ? 812 : 1000);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: IslandLocalizations.delegates,
      supportedLocales: IslandLocalizations.supportedLocales,
      theme: galleryTheme(),
      home: GalleryPage(
        key: const ValueKey('gallery'),
        path: path,
        onNavigate: onNavigate ?? (_) {},
      ),
    ),
  );
}

void main() {
  setUpAll(loadGalleryFonts);

  for (final width in [1440.0, 375.0]) {
    testWidgets('the Scrollbar page lays out its six areas at $width', (
      t,
    ) async {
      await pumpGallery(t, '/scrollbar', width);
      // The sidebar NEW badge animates without end; settle by time instead.
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull);
      expect(find.byType(IslandScrollbar), findsNWidgets(6));
      for (final title in ['基础用法', '和默认滚动条对比', '滚动方向', '轨道与滑块']) {
        expect(find.text(title), findsOneWidget);
      }
      final areas = t.widgetList<IslandScrollbar>(find.byType(IslandScrollbar));
      expect(
        areas.where((a) => a.direction == IslandScrollbarDirection.horizontal),
        hasLength(1),
      );
      expect(areas.where((a) => a.showTrack), hasLength(1));
      expect(areas.where((a) => a.thumbColor != null), hasLength(1));
      // The first area is 220 high with its 1px frame, and its rows overflow.
      final first = find.byType(IslandScrollbar).first;
      expect(t.getSize(first).height, 218);
      final scrollable = t.state<ScrollableState>(
        find.descendant(of: first, matching: find.byType(Scrollable)).first,
      );
      expect(scrollable.position.maxScrollExtent, greaterThan(0));
    });
  }

  testWidgets('the Skill page shows at once when opened by its address', (
    t,
  ) async {
    await pumpGallery(t, '/skill', 1440);
    await t.pump();
    expect(t.widget<IslandLoading>(find.byType(IslandLoading)).active, isFalse);
    expect(t.takeException(), isNull);
  });

  testWidgets('the Skill page plays its Loading for 2s when entered from the '
      'home page, and not from the menu', (t) async {
    var path = '/';
    late StateSetter rebuild;
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: IslandLocalizations.delegates,
        supportedLocales: IslandLocalizations.supportedLocales,
        theme: galleryTheme(),
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return GalleryPage(
              key: const ValueKey('gallery'),
              path: path,
              wallpaperSeed: 17,
              onNavigate: (value) => setState(() => path = value),
            );
          },
        ),
      ),
    );
    await t.pump(const Duration(seconds: 1));
    await t.tap(find.text('开始使用 →'));
    await t.pump();
    expect(path, '/skill');
    IslandLoading loading() => t.widget(find.byType(IslandLoading));
    expect(loading().type, IslandLoadingType.circle);
    expect(loading().active, isTrue);
    await t.pump(const Duration(milliseconds: 1999));
    expect(loading().active, isTrue);
    await t.pump(const Duration(milliseconds: 1));
    expect(loading().active, isFalse);
    await t.pump(const Duration(seconds: 2));
    expect(find.text('快速开始'), findsOneWidget);

    rebuild(() => path = '/button');
    await t.pump();
    await t.pump(const Duration(seconds: 1));
    await t.tap(find.text('Skill 介绍'));
    await t.pump();
    expect(path, '/skill');
    expect(loading().active, isFalse);
    await t.pump(const Duration(seconds: 3));
    expect(t.takeException(), isNull);
  });
}
