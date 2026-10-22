import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
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
  testWidgets('Drawer reference title and paragraph geometry at 1440', (
    t,
  ) async {
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        home: IslandDrawerHost(
          child: GalleryPage(path: '/drawer', onNavigate: (_) {}),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(IslandButton, '右侧抽屉'));
    await t.pumpAndSettle();
    final title = t.getRect(find.text('岛屿设置'));
    expect(title.left, 1086);
    expect(title.top, 24);
    expect(title.height, 42);
    final paragraph = t.getRect(find.text('打开时背景内容会下沉并降亮，突出抽屉主体，形成景深层次。'));
    expect(paragraph.left, 1086);
    expect(paragraph.top, 101);
    expect(paragraph.height, 64);
  });
}
