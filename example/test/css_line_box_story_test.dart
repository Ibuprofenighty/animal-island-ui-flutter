import 'dart:ui' as ui;

import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/story.dart';
import 'package:island_gallery/shared/theme.dart';

// Blink line boxes for the Gallery stack (Nunito, then the Noto Sans SC
// fallback; hhea ascent/descent 1011/353 and 1160/288 per 1000).
//
// An explicit `line-height` L is a line of L in 1/64px, with the baseline at
// the primary (Nunito) ascent A plus floor((L - A - D) / 2), A and D rounded:
//   12px / 1.6: L 19.1875, A 12, D 4 -> baseline 12 + floor(1.59) = 13
//   13px / 1.8: L 23.40625, A 13, D 5 -> baseline 13 + floor(2.70) = 15
//   16px / 1.5: L 24, A 16, D 6 -> baseline 16 + floor(1) = 17
//   18px / 1.5: L 27, A 18, D 6 -> baseline 18 + floor(1.5) = 19
// `line-height: normal` is the largest rounded ascent plus the largest
// rounded descent of the fonts: 12px is max(12, 14) + max(4, 3) = 18.
double cssLine(double size, double height) =>
    (size * height * 64).floorToDouble() / 64;

Future<void> pumpPage(WidgetTester t, String path, double width) async {
  t.view.physicalSize = Size(width, width == 375 ? 812 : 1000);
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: IslandLocalizations.delegates,
      supportedLocales: IslandLocalizations.supportedLocales,
      theme: galleryTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: GalleryPage(
        key: ValueKey('$path-$width'),
        path: path,
        onNavigate: (_) {},
      ),
    ),
  );
  await t.pumpAndSettle();
}

Finder storyBox(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(StoryText)).first;

/// The painted first baseline of [text], below the top of its StoryText box.
double baselineInBox(WidgetTester t, String text) {
  final rich = find.descendant(
    of: find.text(text),
    matching: find.byType(RichText),
  );
  final paragraph = t.renderObject<RenderParagraph>(rich);
  final firstBaseline = paragraph.getDryBaseline(
    paragraph.constraints,
    TextBaseline.alphabetic,
  )!;
  return t.getTopLeft(rich).dy +
      firstBaseline -
      t.getTopLeft(storyBox(text)).dy;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('Progress captions are 18px normal lines, mixed text included', (
    t,
  ) async {
    await pumpPage(t, '/progress', 1440);
    for (final caption in ['岛屿截图上传', '岛屿评价经验', '今日 DIY 任务']) {
      expect(t.getSize(find.text(caption)).height, 18, reason: caption);
    }
    // Each scene: caption 18, margin 4, middle track 24, margin 8, small
    // button 32, then the 14px column gap.
    final tracks = [
      for (final e in find.byType(IslandProgress).evaluate().take(3))
        t.getTopLeft(find.byWidget(e.widget)).dy,
    ];
    expect(tracks[1] - tracks[0], 18 + 4 + 24 + 8 + 32 + 14);
    expect(tracks[2] - tracks[1], 18 + 4 + 24 + 8 + 32 + 14);
  });

  testWidgets('StoryText puts the first baseline where Blink does', (t) async {
    await pumpPage(t, '/no-data', 1440);
    expect(baselineInBox(t, '这里还是空白的一页'), 17);
    expect(t.getSize(storyBox('这里还是空白的一页')).height, cssLine(16, 1.5));
    const description = '记录下一件小事，让海岛的故事慢慢展开。';
    expect(baselineInBox(t, description), 15);
    expect(t.getSize(storyBox(description)).height, cssLine(13, 1.8));

    await pumpPage(t, '/upload', 1440);
    const tip = '未接入 customRequest 时,组件会用定时器模拟上传进度,方便联调 UI';
    expect(baselineInBox(t, tip), 13);
    expect(t.getSize(storyBox(tip)).height, cssLine(12, 1.6));
  });

  testWidgets('wrapped chart gallery text keeps the CSS line pitch', (t) async {
    await pumpPage(t, '/chart-bar', 375);
    const note = '以下为虚构演示数据。横向比较与排名，长分类名称更容易阅读。';
    final body = find.textContaining('4 种独立示例');
    final noteBox = t.getRect(storyBox(note));
    final bodyBox = t.getRect(
      find.ancestor(of: body, matching: find.byType(StoryText)).first,
    );
    final line = cssLine(13, 1.8);
    expect(noteBox.height, 2 * line);
    expect(bodyBox.height, 2 * line);
    // .note margin-bottom 20 collapses into .gallery margin-top 24; the h2
    // line is 18px x 1.5 with an 8px gap to the body, which ends 20px above
    // the first chart (.header margin-bottom).
    expect(bodyBox.top - noteBox.top, 2 * line + 24 + 27 + 8);
    expect(
      t.getTopLeft(find.byType(IslandChart).first).dy - bodyBox.top,
      2 * line + 20,
    );
    expect(baselineInBox(t, '样式与场景'), 19);
  });

  testWidgets('each wrapped line is painted at its CSS offset', (t) async {
    // Five lines of 13px / 1.8 text: Blink places line k at k x 23.40625,
    // Flutter's paragraph at k x 23.
    const key = ValueKey('text');
    await t.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        home: Align(
          alignment: Alignment.topLeft,
          child: RepaintBoundary(
            key: key,
            child: Container(
              color: const Color(0xFFFFFFFF),
              width: 16,
              child: const DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontFamilyFallback: ['IslandGallerySans'],
                  fontSize: 13,
                  height: 1.8,
                  color: Color(0xFF000000),
                ),
                child: StoryText('一一一一一'),
              ),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(StoryText)).height, 5 * cssLine(13, 1.8));
    final boundary = t.renderObject<RenderRepaintBoundary>(find.byKey(key));
    final image = await t.runAsync(() => boundary.toImage());
    final data = await t.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final width = image!.width, height = image.height;
    image.dispose();
    final bytes = data!.buffer.asUint8List();
    // Ink-weighted centre of each line's horizontal stroke.
    final rows = <double>[];
    for (var y = 0; y < height; y++) {
      var ink = 0.0;
      for (var x = 0; x < width; x++) {
        final i = (y * width + x) * 4;
        // Rows the white backing only partly covers are not ink.
        if (bytes[i + 3] == 255) ink += 255 - bytes[i];
      }
      rows.add(ink);
    }
    final centres = <double>[];
    var sum = 0.0, weighted = 0.0;
    for (var y = 0; y <= height; y++) {
      final ink = y < height ? rows[y] : 0.0;
      if (ink > 0) {
        sum += ink;
        weighted += ink * y;
      } else if (sum > 0) {
        centres.add(weighted / sum);
        sum = weighted = 0;
      }
    }
    expect(centres, hasLength(5));
    for (var k = 1; k < 5; k++) {
      expect(
        centres[k] - centres[0],
        // Glyph rows snap to whole pixels; Flutter's pitch would put lines
        // 3 and 4 at 69 and 92, more than 1px from 70.2 and 93.6.
        moreOrLessEquals(k * cssLine(13, 1.8), epsilon: 1),
        reason: 'line $k',
      );
    }
  });
}
