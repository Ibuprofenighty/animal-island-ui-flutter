import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:flutter/rendering.dart';
import 'package:island_gallery/pages/stories/avatar_story.dart';
import 'package:island_gallery/pages/stories/icon_story.dart';
import 'package:island_gallery/shared/story.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  Future<void> page(WidgetTester t, String route, double width) async {
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
          key: ValueKey('$route-$width'),
          path: route == 'home' ? '/' : '/$route',
          onNavigate: (_) {},
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets(
    'Cursor example preserves measured native-control and wrap geometry',
    (t) async {
      for (final width in [1440.0, 375.0]) {
        await page(t, 'cursor', width);
        final boxes = find.byType(StoryDemoBox);
        final heights = [75.0, 75, width == 375 ? 262.0 : 114.0];
        for (var i = 0; i < 3; i++) {
          final rect = t.getRect(boxes.at(i));
          expect(rect.height, heights[i]);
        }
        expect(t.getSize(find.byType(TextField)), const Size(189, 27));
        expect(t.getSize(find.byType(InputDecorator)), const Size(189, 27));
        final link = find.text('链接 (pointer)');
        final linkText = t.widget<Text>(link);
        expect(linkText.maxLines, 1);
        expect(linkText.softWrap, false);
        final paragraph = t.renderObject<RenderParagraph>(
          find.descendant(of: link, matching: find.byType(RichText)),
        );
        expect(paragraph.size.height, 25);
        expect(paragraph.didExceedMaxLines, false);
        for (final text in ['鼠标移入此区域将显示自定义光标', '鼠标移入此区域将显示雨滴光标']) {
          expect(
            t.widget<StoryText>(find.widgetWithText(StoryText, text)).textAlign,
            TextAlign.center,
          );
        }
        final buttons = find.byType(OutlinedButton);
        expect(t.getSize(buttons.at(0)), const Size(96, 25));
        expect(t.getSize(buttons.at(1)), const Size(123.421875, 25));
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets('Skill catalog keeps category group and quiet path ownership', (
    t,
  ) async {
    for (final width in [1440.0, 375.0]) {
      await page(t, 'skill', width);
      final section = find.ancestor(
        of: find.text('组件目录'),
        matching: find.byType(StoryPanel),
      );
      final category = find.descendant(
        of: section,
        matching: find.text('General'),
      );
      final first = find.descendant(of: section, matching: find.text('Button'));
      final path = find.descendant(of: section, matching: find.text('general'));
      final categoryTag = find.ancestor(
        of: category,
        matching: find.byType(IslandTag),
      );
      final group = find.ancestor(of: first, matching: find.byType(Wrap));
      final cat = t.getRect(categoryTag),
          chips = t.getRect(group),
          code = t.getRect(path);
      expect(cat.width, 128);
      expect(chips.left - cat.right, 8);
      if (width == 375) {
        expect(cat.left, 54);
        expect(chips.width, 131);
        expect(chips.height, 84);
        expect(code.left, 62);
        expect(code.top, chips.bottom + 10);
      } else {
        expect(cat.left, 310);
        expect(chips.height, 24);
        expect(code.left, greaterThan(chips.right));
      }
      expect(t.takeException(), isNull);
    }
  });
  testWidgets('Tabs real-font Chinese titles stay inside the narrow header', (
    t,
  ) async {
    await page(t, 'tabs', 375);
    final roots = find.byType(IslandTabs<String>);
    final tops = [353.0, 592, 864, 1157, 1595, 1860];
    final heights = [177.0, 177, 198, 295, 177, 177];
    for (var i = 0; i < 6; i++) {
      expect(
        t.getTopLeft(roots.at(i)).dy,
        closeTo(tops[i], .1),
        reason: 'Tabs root$i top',
      );
      expect(
        t.getSize(roots.at(i)).height,
        closeTo(heights[i], .1),
        reason: 'Tabs root$i height',
      );
    }
    final tabs = find.byType(IslandTabs<String>);
    for (final tab in tabs.evaluate()) {
      final box = t.getRect(
        find.byElementPredicate((element) => identical(element, tab)),
      );
      final labels = find.descendant(
        of: find.byElementPredicate((element) => identical(element, tab)),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Text &&
              [
                '鱼类',
                '昆虫',
                '海洋生物',
                '岛屿概况',
                '商店',
                '服务台',
              ].contains(w.data?.replaceAll('\u200b', '')),
        ),
      );
      for (final label in labels.evaluate()) {
        final rect = t.getRect(
          find.byElementPredicate((element) => identical(element, label)),
        );
        expect(rect.left, greaterThanOrEqualTo(box.left));
        expect(rect.right, lessThanOrEqualTo(box.right));
      }
    }
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Rate inline and block frames preserve reference line-box space',
    (t) async {
      await page(t, 'rate', 375);
      final frames = find.byType(StoryDemoBox);
      final actual = [
        for (var i = 0; i < 6; i++)
          t.getRect(
            find
                .descendant(
                  of: frames.at(i),
                  matching: find.byType(CustomPaint),
                )
                .first,
          ),
      ];
      final tops = [356.0, 544, 679, 814, 1049, 1176],
          heights = [74.0, 74, 74, 142, 66, 142];
      for (var i = 0; i < 6; i++) {
        expect(actual[i].height, heights[i] - 2, reason: 'frame$i');
        expect(actual[i].top, tops[i] + 1, reason: 'frame$i top');
      }
    },
  );
  testWidgets('BackTop narrow resident cards retain normal text line boxes', (
    t,
  ) async {
    await page(t, 'backtop', 375);
    final card = find.byType(IslandCard).first;
    final name = find.text('小润');
    final desc = find.text('热爱园艺的小松鼠，每天在广场上唱歌');
    expect(t.getSize(name).height, 22);
    expect(t.getSize(desc).height, 40);
    expect(t.getSize(card).height, 98);
  });
  testWidgets('Avatar six section bounds match the wide and narrow reference', (
    t,
  ) async {
    for (final width in [1440.0, 375.0]) {
      await page(t, 'avatar', width);
      final panels = find.descendant(
        of: find.byType(AvatarStory),
        matching: find.byType(StoryPanel),
      );
      final tops = width == 1440
          ? [178.0, 351, 566, 739, 968, 1141]
          : [237.0, 410, 625, 870, 1183, 1356];
      final heights = width == 1440
          ? [137.0, 179, 137, 193, 137, 193]
          : [137.0, 179, 209, 277, 137, 329];
      for (var i = 0; i < 6; i++) {
        final rect = t.getRect(panels.at(i));
        expect(rect.top, closeTo(tops[i], .02), reason: '$width section$i top');
        expect(
          rect.height,
          closeTo(heights[i] + 36, .02),
          reason: '$width section$i including36px margin',
        );
      }
      final code = find.descendant(
        of: find.byType(AvatarStory),
        matching: find.byType(StoryCode),
      );
      expect(t.getTopLeft(code).dy, closeTo(width == 1440 ? 1370 : 1721, .02));
      expect(t.takeException(), isNull);
    }
  });
  testWidgets(
    'Icon catalog uses export order and measured name and label lines',
    (t) async {
      await page(t, 'icon', 1440);
      final names = find.descendant(
        of: find.byType(IconStory),
        matching: find.byWidgetPredicate(
          (w) =>
              w is Text &&
              ((w.data != 'Icon' && (w.data?.endsWith('Icon') ?? false))),
        ),
      );
      final actual = names
          .evaluate()
          .map((e) => (e.widget as Text).data!)
          .toList();
      final sorted = [...actual]..sort();
      expect(actual.length, 163);
      expect(actual, sorted);
      expect(t.getSize(names.first).height, 13);
      expect(t.getSize(find.text('AlertCircle')).height, 18);
      expect(t.getSize(find.text('飞机')).height, 20);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Image fitting dimensions stay exact and narrow images preserve their aspect ratio',
    (t) async {
      for (final width in [1440.0, 375.0]) {
        await page(t, 'image', width);
        final small = t.getRect(
          find.byWidgetPredicate((w) => w is IslandImage && w.alt == '林间溪流'),
        );
        final large = t.getRect(
          find.byWidgetPredicate((w) => w is IslandImage && w.alt == '阳光田野'),
        );
        final available = width == 1440 ? 330.0 : width - 82;
        expect(small.width, available);
        expect(small.height, closeTo(available * 200 / 330, .001));
        expect(large.width, width == 1440 ? 480 : available);
        expect(large.height, closeTo(large.width * 300 / 480, .001));
        if (width == 1440) {
          expect(small.center.dy, large.center.dy);
        } else {
          expect(large.top - small.bottom, 16);
        }
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets(
    'Skeleton loaded caller surface fills width and avatar tops align',
    (t) async {
      await page(t, 'skeleton', 375);
      final text = find.text('内容已加载，骨架屏自动隐藏');
      final surface = find
          .ancestor(of: text, matching: find.byType(Container))
          .first;
      expect(t.getSize(surface), const Size(293, 49));
      final avatars = find.byType(IslandSkeletonAvatar);
      expect(t.getTopLeft(avatars.at(0)).dy, t.getTopLeft(avatars.at(1)).dy);
      expect(t.getTopLeft(avatars.at(1)).dy, t.getTopLeft(avatars.at(2)).dy);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Date range honors available width inside the reference inset', (
    t,
  ) async {
    await page(t, 'date-picker', 375);
    final all = find.byType(IslandDatePicker).evaluate().toList();
    final ranges = all.skip(all.length - 2);
    expect(ranges.length, 2);
    for (final e in ranges) {
      final rect = t.getRect(find.byWidget(e.widget));
      expect(rect.left, 57);
      expect(rect.width, 261);
      expect(rect.height, 40);
    }
    expect(t.takeException(), isNull);
  });
  testWidgets('Chinese section title line is27 while Latin remains24', (
    t,
  ) async {
    await page(t, 'skill', 1440);
    expect(t.getSize(find.text('快速开始')).height, 27);
    expect(t.getSize(find.text('工作原理')).height, 27);
    await page(t, 'skeleton', 1440);
    expect(t.getSize(find.text('Skeleton').last).height, 24);
  });
  testWidgets('Switch size examples initially show both enabled sizes', (
    t,
  ) async {
    await page(t, 'switch', 375);
    final switches = t
        .widgetList<IslandSwitch>(find.byType(IslandSwitch))
        .toList();
    expect(switches.map((w) => w.small).toList(), [
      false,
      false,
      false,
      false,
      true,
      false,
      false,
    ]);
    expect(t.getSize(find.byType(IslandSwitch).at(2)), const Size(52, 28));
    expect(switches.map((w) => w.value).toList(), [
      false,
      true,
      true,
      true,
      true,
      false,
      true,
    ]);
  });
  testWidgets(
    'Home cards stretch by row and code respects observed surface recipe',
    (t) async {
      for (final width in [1440.0, 375.0]) {
        await page(t, 'home', width);
        final cards = find.byType(IslandCard);
        expect(cards, findsNWidgets(24));
        expect(t.getSize(find.text('特性')).height, 33);
        expect(t.getSize(find.text('为什么选择 animal-island-ui')).height, 20);
        expect(t.getSize(find.text('治愈系风格')).height, 22);
        expect(t.getSize(find.text('Input')).height, 20);
        if (width == 1440) {
          for (final first in [0, 4, 8, 12, 16, 20]) {
            for (var i = first + 1; i < first + 4; i++) {
              expect(
                t.getSize(cards.at(i)).height,
                t.getSize(cards.at(first)).height,
              );
              expect(
                t.getTopLeft(cards.at(i)).dy,
                t.getTopLeft(cards.at(first)).dy,
              );
            }
          }
          expect(t.getSize(cards.first).height, closeTo(180.390625, .1));
        }
        final blocks = find.byType(IslandCodeBlock);
        expect(blocks, findsNWidgets(3));
        for (final e in blocks.evaluate()) {
          final finder = find.byWidget(e.widget);
          expect(t.getSize(finder).width, width == 1440 ? 600 : 343);
          final code = e.widget as IslandCodeBlock;
          expect(
            code.padding,
            const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          );
          expect(code.style?.textStyle?.fontSize, 13);
          expect(code.style?.textStyle?.height, 1.8);
          expect(code.margin, EdgeInsets.zero);
        }
        expect(find.text('GitHub'), findsOneWidget);
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets('Badge color rows keep15px labels and18px wrapping gaps', (
    t,
  ) async {
    await page(t, 'badge', 375);
    final label = find.text('app-red');
    expect(t.getSize(label).height, 15);
    final wrap = find.ancestor(of: label, matching: find.byType(Wrap)).first;
    expect(t.widget<Wrap>(wrap).spacing, 18);
    expect(t.widget<Wrap>(wrap).runSpacing, 18);
    expect(t.getSize(wrap).height, 218);
    await page(t, 'tag', 375);
    for (final tag
        in t
            .widgetList<IslandTag>(find.byType(IslandTag))
            .where((w) => w.onClose != null)) {
      expect(tag.variant, IslandTagVariant.soft);
    }
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Progress custom info and slider use reference typography and row metrics',
    (t) async {
      for (final width in [1440.0, 375.0]) {
        await page(t, 'progress', width);
        final info = find.text('3600 / 5000 星');
        final style = DefaultTextStyle.of(t.element(info)).style;
        expect(style.fontSize, 16);
        expect(style.letterSpacing, .32);
        expect(style.height, 1);
        expect(t.getSize(info).width, closeTo(114.984375, 1));
        final row = find
            .ancestor(of: find.byType(Slider), matching: find.byType(Row))
            .first;
        expect(t.getSize(row).height, 22);
        final progress = find.byWidgetPredicate(
          (w) => w is IslandProgress && w.label == '受控进度',
        );
        expect(t.getTopLeft(progress).dy - t.getBottomLeft(row).dy, 8);
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets('CodeBlock Gallery block margins collapse after each caption', (
    t,
  ) async {
    await page(t, 'codeblock', 375);
    final boxes = find.byType(StoryDemoBox);
    final captions = ['基础用法', '关闭复制功能', '自定义样式'];
    for (var i = 0; i < captions.length; i++) {
      expect(
        t.getTopLeft(boxes.at(i)).dy -
            t.getBottomLeft(find.text(captions[i])).dy,
        20,
      );
    }
    expect(t.takeException(), isNull);
  });
}
