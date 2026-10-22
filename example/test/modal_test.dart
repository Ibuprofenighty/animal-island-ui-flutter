import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/stories/modal_story.dart';
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
  testWidgets(
    'Modal page keeps all seven trigger rows at reference positions',
    (t) async {
      t.view.physicalSize = const Size(1440, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: GalleryPage(path: '/modal', onNavigate: (_) {}),
        ),
      );
      await t.pumpAndSettle();
      for (final entry in [
        ('异形 Modal', 288.0),
        ('基础 Modal', 394.0),
        ('带标题 Modal', 394.0),
        ('自定义 Footer', 394.0),
        ('关闭打字机效果', 500.0),
        ('浅色遮罩', 606.0),
        ('深色遮罩', 606.0),
      ]) {
        expect(
          t.getTopLeft(find.widgetWithText(IslandButton, entry.$1)).dy,
          entry.$2,
          reason: entry.$1,
        );
      }
    },
  );
  testWidgets(
    'Fishing copy replays one 80ms timeline across its two explicit lines',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: const Scaffold(
            body: SingleChildScrollView(child: ModalStory()),
          ),
        ),
      );
      final trigger = find.widgetWithText(IslandButton, '异形 Modal');
      for (var run = 0; run < 2; run++) {
        await t.tap(trigger);
        await t.pump();
        expect(find.text('钓', findRichText: true), findsNothing);
        await t.pump(const Duration(milliseconds: 80));
        expect(find.text('钓', findRichText: true), findsOneWidget);
        await t.pump(const Duration(milliseconds: 400));
        expect(find.text('钓到石头了!', findRichText: true), findsOneWidget);
        expect(find.text('竟'), findsNothing);
        await t.pump(const Duration(milliseconds: 80));
        expect(find.text('竟'), findsOneWidget);
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pumpAndSettle();
        expect(find.byType(IslandModal), findsNothing);
      }
    },
  );
  for (final width in [1280.0, 375.0]) {
    testWidgets('Modal seven reference examples at $width', (t) async {
      t.view.physicalSize = Size(width, 812);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: ModalStory()),
          ),
        ),
      );
      for (final label in [
        '异形 Modal',
        '基础 Modal',
        '带标题 Modal',
        '自定义 Footer',
        '关闭打字机效果',
        '浅色遮罩',
        '深色遮罩',
      ]) {
        final trigger = find.widgetWithText(IslandButton, label);
        await t.ensureVisible(trigger);
        await t.tap(trigger);
        await t.pumpAndSettle();
        final clip = find.descendant(
          of: find.byType(IslandModal),
          matching: find.byType(ClipPath),
        );
        final rect = t.getRect(clip);
        expect(rect.width, width == 1280 ? 520 : 343);
        expect(rect.center.dx, width / 2);
        if (width == 375 && label == '带标题 Modal') expect(rect.height, 330);
        expect(find.byType(IconButton), findsNothing);
        final route = ModalRoute.of(t.element(find.byType(IslandModal)))!;
        expect(
          route.barrierColor,
          label == '浅色遮罩'
              ? const Color(0x14000000)
              : label == '深色遮罩'
              ? const Color(0xbf000000)
              : const Color(0x59000000),
        );
        if (width == 1280) {
          final h = (label == '带标题 Modal' || label == '深色遮罩')
              ? 266.0
              : (label == '异形 Modal' || label == '基础 Modal' ? 217.0 : 234.0);
          expect(rect.height, closeTo(h, .1), reason: label);
        }
        if (label == '异形 Modal' || label == '基础 Modal') {
          expect(find.text('钓到石头了!', findRichText: true), findsOneWidget);
          expect(find.text('竟然连这种都能钓起来...'), findsOneWidget);
        }
        final action = label == '自定义 Footer' ? '确认搬家' : '确定';
        await t.tap(find.text(action));
        await t.pumpAndSettle();
        expect(find.byType(IslandModal), findsNothing);
        expect(t.takeException(), isNull);
      }
    });
  }
}
