import 'dart:io' show File;
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:island_gallery/shared/theme.dart';
import 'package:island_gallery/shared/story.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/home.dart';
import 'package:island_gallery/pages/stories/registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
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

  for (final width in [1440.0, 375.0]) {
    testWidgets('Home product version follows pubspec at $width', (t) async {
      final pattern = RegExp(r'^version: ([^\r\n]+)\r?$', multiLine: true);
      final expected = pattern
          .firstMatch(File('../pubspec.yaml').readAsStringSync())!
          .group(1)!;
      expect(
        pattern.firstMatch(File('pubspec.yaml').readAsStringSync())!.group(1),
        expected,
      );
      t.view.physicalSize = Size(width, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 1000),
              disableAnimations: true,
            ),
            child: Scaffold(
              body: GalleryHome(wallpaperSeed: 17, onNavigate: (_) {}),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final badge = find.text('v$expected');
      expect(badge, findsOneWidget);
      expect(
        t.getRect(badge).overlaps(Offset.zero & Size(width, 1000)),
        isTrue,
      );
      expect(find.text('v2.2.1'), findsNothing);
      final credit = find.text('Flutter + Dart · Reference Gallery');
      await t.ensureVisible(credit);
      await t.pumpAndSettle();
      expect(credit, findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets(
    'Input reference Card spans panel with measured first field and size steps',
    (t) async {
      t.view.physicalSize = const Size(1440, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: const MediaQuery(
            data: MediaQueryData(
              size: Size(1440, 1000),
              disableAnimations: true,
            ),
            child: GalleryPage(path: '/input', onNavigate: _ignoreNavigation),
          ),
        ),
      );
      await t.pumpAndSettle();
      final card = t.getRect(find.byType(IslandCard));
      expect(card.left, 297);
      expect(card.width, 1078);
      final fields = find.byType(TextField);

      expect(t.getRect(fields.at(0)), const Rect.fromLTWH(318, 321, 360, 40));
      expect(t.getRect(fields.at(1)), const Rect.fromLTWH(318, 373, 360, 40));
      expect(t.getSize(fields.at(5)), const Size(360, 32));
      expect(t.getSize(fields.at(6)), const Size(360, 40));
      expect(t.getSize(fields.at(7)), const Size(360, 48));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Skeleton paragraph matches198px reference inner width', (
    t,
  ) async {
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
          child: GalleryPage(path: '/skeleton', onNavigate: (_) {}),
        ),
      ),
    );
    await t.pumpAndSettle();
    final paragraph = find.byWidgetPredicate(
      (w) =>
          w is IslandSkeleton && w.variant == IslandSkeletonVariant.paragraph,
    );
    expect(t.getSize(paragraph), const Size(198, 86));
    expect(t.getSize(find.text('paragraph')).height, 18);
    expect(t.getTopLeft(paragraph).dy, 444);
    await t.tap(find.byType(IslandSwitch));
    await t.pumpAndSettle();
    expect(find.text('输入框已加载'), findsOneWidget);
    expect(paragraph, findsOneWidget);
  });

  for (final width in [1440.0, 375.0]) {
    testWidgets('Title complete reference examples at $width', (t) async {
      t.view.physicalSize = Size(width, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 1000),
              disableAnimations: true,
            ),
            child: GalleryPage(path: '/title', onNavigate: (_) {}),
          ),
        ),
      );
      await t.pumpAndSettle();
      final titles = find.descendant(
        of: find.byType(StoryPanel),
        matching: find.byType(IslandTitle),
      );
      expect(titles, findsNWidgets(25));
      for (final text in [
        "LET'S PLAY!",
        '小标题',
        '中等标题',
        '大号标题',
        '蜂蜜阳光',
        '海风信箱',
        '青柠苏打',
        '热可可',
      ]) {
        expect(find.text(text), findsOneWidget);
      }
      if (width == 1440) {
        final title = titles.first;
        expect(t.getTopLeft(title).dx, 338);
        expect(t.getTopLeft(title).dy, 329);
        expect(t.getSize(title).height, 42);
      }
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
    'reference label natural line metrics retain Latin and Chinese heights',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: const Scaffold(
            body: Column(
              children: [
                StoryLabel('type="default"'),
                StoryLabel('variant 风格变体'),
              ],
            ),
          ),
        ),
      );
      expect(t.getSize(find.text('type="default"')).height, 19);
      expect(t.getSize(find.text('variant 风格变体')).height, 21);
    },
  );
  testWidgets('explicit story text line boxes inherit typography and scale', (
    t,
  ) async {
    for (final scale in [1.0, 2.0]) {
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(
              body: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  height: 1.4,
                ),
                child: StoryText('a\nb'),
              ),
            ),
          ),
        ),
      );
      expect(
        t.getSize(find.byType(StoryText)).height,
        closeTo(scale == 1 ? 44.78125 : 89.59375, .001),
      );
      expect(t.takeException(), isNull);
    }
  });
  for (final width in [1440.0, 375.0]) {
    testWidgets('Collapse reference line boxes at $width', (t) async {
      t.view.physicalSize = Size(width, 1000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(width, 1000),
              disableAnimations: true,
            ),
            child: GalleryPage(path: '/collapse', onNavigate: (_) {}),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
      expect(t.getRect(find.text('基础用法')).height, 21);
      final cards = find.byType(IslandCollapse);
      final first = t.getRect(cards.at(0));
      expect(first.left, width == 375 ? 41 : 297);
      expect(first.top, width == 375 ? 324 : 288);
      expect(first.height, closeTo(width == 375 ? 92.78125 : 76, .1));
      final nextTop = t.getTopLeft(cards.at(1)).dy;
      expect(nextTop, closeTo(width == 375 ? 416.78125 : 364, .1));
      await t.tap(find.text('1個島嶼可以登錄多少名用戶?'));
      await t.pumpAndSettle();
      final open = t.getRect(cards.at(0));
      expect(
        open.height - 12,
        closeTo(width == 375 ? 152.375 : 111.796875, .1),
      );
      expect(
        t.getTopLeft(cards.at(1)).dy - nextTop,
        closeTo(width == 375 ? 71.59375 : 47.796875, .1),
      );
      expect(t.takeException(), isNull);
    });
  }
  for (final width in [1440.0, 768.0, 375.0]) {
    for (final id in storyBuilders.keys) {
      testWidgets('$id renders at width $width without overflow', (t) async {
        t.view.physicalSize = Size(width, width == 375 ? 812 : 1000);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            theme: galleryTheme(),
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(width, width == 375 ? 812 : 1000),
                disableAnimations: true,
              ),
              child: GalleryPage(path: '/$id', onNavigate: (_) {}),
            ),
          ),
        );
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
        if (id == 'pagination' && width == 375) {
          final totalExample = find.byType(IslandPagination).at(2);
          final selected = find.descendant(
            of: totalExample,
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == '第 3 页',
            ),
          );
          final changer = find.descendant(
            of: totalExample,
            matching: find.byWidgetPredicate(
              (w) => w is Semantics && w.properties.label == '10 条/页',
            ),
          );
          final bounds = t.getRect(totalExample);
          for (final target in [selected, changer]) {
            final rect = t.getRect(target);
            expect(rect.left, greaterThanOrEqualTo(bounds.left));
            expect(rect.right, lessThanOrEqualTo(bounds.right));
            expect(rect.top, greaterThanOrEqualTo(bounds.top));
            expect(rect.bottom, lessThanOrEqualTo(bounds.bottom));
          }
          expect(t.getRect(selected).size, const Size(32, 32));
        }
        if (id == 'table' && width == 375) {
          final rows = find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.role == ui.SemanticsRole.row,
          );
          expect(t.getRect(rows.at(0)).top, closeTo(414, .1));
          expect(t.getRect(rows.at(0)).width, closeTo(409.859375, .1));
          for (var i = 1; i <= 5; i++) {
            expect(t.getRect(rows.at(i)).height, closeTo(72.78125, .1));
          }
          expect(t.getRect(rows.at(5)).bottom, closeTo(830.90625, .1));
        }
        if (id == 'table' && width == 1440) {
          final island = t.getTopLeft(find.text('岛屿').first).dx;
          final fruit = t.getTopLeft(find.text('喜欢的水果').first).dx;
          final hobby = t.getTopLeft(find.text('爱好').first).dx;
          expect(island, closeTo(523, .1));
          expect(fruit - island, closeTo(252.34375, .1));
          expect(hobby - fruit, closeTo(342.828125, .1));
          final rows = find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.role == ui.SemanticsRole.row,
          );
          expect(t.getRect(rows.at(0)).top, closeTo(355, .1));
          expect(t.getRect(rows.at(0)).height, closeTo(53, .1));
          expect(t.getRect(rows.at(1)).height, closeTo(50.390625, .1));
          expect(t.getRect(rows.at(5)).bottom, closeTo(659.953125, .1));
        }
        if (id == 'form' && width == 1440) {
          // Browser reference, DPR 1; margins and line boxes accumulate.
          expect(
            t.getTopLeft(find.widgetWithText(TextField, '请输入用户名')).dy,
            closeTo(374.390625, .1),
          );
          expect(
            t.getTopLeft(find.widgetWithText(TextField, '输入昵称')).dy,
            closeTo(676.78125, .1),
          );
          expect(
            t.getTopLeft(find.widgetWithText(TextField, '输入标题')).dy,
            closeTo(845.171875, .1),
          );
        }
        expect(
          find.text('API'),
          id == 'skill'
              ? findsNothing
              : (id == 'avatar' || id == 'notification' || id == 'form'
                    ? findsNWidgets(2)
                    : findsOneWidget),
        );
      });
    }
  }
  testWidgets('375px Tag follows reference header and wrapped layout', (
    t,
  ) async {
    t.view.physicalSize = const Size(375, 812);
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
        home: GalleryPage(path: '/tag', onNavigate: (_) {}),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getTopLeft(find.byType(StoryPanel)).dy, closeTo(216, .1));
    final small = find.widgetWithText(IslandTag, 'small');
    expect(t.getTopLeft(small), const Offset(41, 467));
    expect(t.getSize(small).height, 24);
    final heading = find.byWidgetPredicate(
      (w) => w is Text && w.data == 'Tag 标签' && w.style?.fontSize == 15,
    );
    Rect actionRect(String label) => t.getRect(
      find.descendant(
        of: find.byWidgetPredicate(
          (w) => w is IslandTooltip && w.message == label,
        ),
        matching: find.byType(IconButton),
      ),
    );
    final title = t.getRect(heading);
    expect(
      title.left - actionRect('返回首页').right,
      closeTo(actionRect('打开导航').left - title.right, .1),
    );
    expect(title.center.dx, closeTo(188.5234375, .1));
    expect(
      find.byWidgetPredicate((w) => w is IslandTooltip && w.message == '返回首页'),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate((w) => w is IslandTooltip && w.message == '打开导航'),
      findsOneWidget,
    );
    expect(t.takeException(), isNull);
  });
  testWidgets('Home uses licensed font and navigates to guide', (t) async {
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    String? route;
    await t.pumpWidget(
      MaterialApp(
        theme: galleryTheme(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(1440, 1000),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: GalleryHome(wallpaperSeed: 17, onNavigate: (v) => route = v),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('开始使用 →'));
    expect(route, 'skill');
    expect(t.takeException(), isNull);
  });

  testWidgets(
    'Choice Gallery restores measured frame and reference default values',
    (t) async {
      await _showVisualStory(t, '/checkbox', const Size(375, 812));
      final frames = find.byType(StoryDemoBox);
      expect(frames, findsNWidgets(6));
      final first = t.getRect(frames.first);
      expect(first.left, closeTo(41, .1));
      expect(first.top, closeTo(358, .1));
      expect(first.size, const Size(293, 98));
      final checks = t
          .widgetList<IslandCheckboxGroup<String>>(
            find.byType(IslandCheckboxGroup<String>),
          )
          .toList();
      expect(checks[3].values, {'海滩'});
      expect(checks[4].options.map((e) => e.label), ['海滩', '森林', '花园']);
      expect(checks[5].values, {'花园', '村庄'});
      await _showVisualStory(t, '/radio', const Size(375, 812));
      final radios = t
          .widgetList<IslandRadioGroup<String>>(
            find.byType(IslandRadioGroup<String>),
          )
          .toList();
      expect(radios[1].value, isNull);
      expect(radios[4].value, '深夜');
      expect(radios[5].size, IslandSize.large);
      expect(radios[6].value, '冬天');
      expect(find.text('已选中: 中午'), findsOneWidget);
    },
  );
  testWidgets(
    'Image captions follow their constrained frame and retain their line metrics',
    (t) async {
      await _showVisualStory(t, '/image', const Size(375, 812));
      final caption = find.text('default（默认）');
      final image = find.byWidgetPredicate(
        (w) => w is IslandImage && w.alt == '默认类型',
      );
      expect(t.getCenter(caption).dx, closeTo(t.getCenter(image).dx, .1));
      expect(
        t.getTopLeft(caption).dy - t.getBottomLeft(image).dy,
        closeTo(6, .1),
      );
      expect(t.getRect(image).width, 293);
      expect(t.getSize(find.text('带年份')).height, 18);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Footer page title differs from its navigation caption', (
    t,
  ) async {
    await _showVisualStory(t, '/footer', const Size(375, 812));
    expect(find.text('Footer 底部装饰'), findsNWidgets(2));
    expect(t.getSize(find.byType(IslandFooter).first).height, 50);
  });
  testWidgets(
    'Background menu action previews sprinkles after navigation commits',
    (t) async {
      await _showVisualStory(t, '/title', const Size(1440, 1000));
      await t.tap(find.text('Background 背景'));
      await t.pumpAndSettle();
      expect(
        t.widget<IslandBackground>(find.byType(IslandBackground).first).type,
        IslandBackgroundType.sprinkles,
      );
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Gallery slash words preserve measured browser line breaks and plain semantics',
    (t) async {
      final semantics = t.ensureSemantics();
      try {
        await _showVisualStory(t, '/notification', const Size(375, 812));
        final intro = find.byType(IslandTypewriter).first;
        expect(t.getSize(intro).height, 84);
        final label = t.getSemantics(intro).label;
        expect(label, contains('success/info/warning/error'));
        expect(label, isNot(contains('\u2060')));
      } finally {
        semantics.dispose();
      }
    },
  );
  testWidgets(
    'Home keeps random wallpaper choices at percentage positions across resize',
    (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(1440, 1000);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Scaffold(
            body: GalleryHome(wallpaperSeed: 17, onNavigate: (_) {}),
          ),
        ),
      );
      await t.pumpAndSettle();
      final icons = find.byWidgetPredicate(
        (w) => w is IslandIcon && w.size > 400,
      );
      final before = [
        for (final e in icons.evaluate())
          t.getCenter(find.byElementPredicate((x) => identical(x, e))),
      ];
      expect(before.length, greaterThanOrEqualTo(5));
      t.view.physicalSize = const Size(720, 500);
      await t.pumpAndSettle();
      final after = [
        for (final e in icons.evaluate())
          t.getCenter(find.byElementPredicate((x) => identical(x, e))),
      ];
      expect(after.length, before.length);
      for (var i = 0; i < after.length; i++) {
        expect(after[i].dx, closeTo(before[i].dx * .5, 8));
        expect(after[i].dy, closeTo(before[i].dy * .5, 8));
      }
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'Skill rule headers keep inline count tags and measured list inset',
    (t) async {
      for (final size in [
        const Size(375, 812),
        const Size(768, 1000),
        const Size(1440, 1000),
      ]) {
        await _showVisualStory(t, '/skill', size);
        final title = find.text('API 纪律');
        final card = find
            .ancestor(of: title, matching: find.byType(IslandCard))
            .first;
        final tag = find
            .ancestor(
              of: find.descendant(of: card, matching: find.text('3 条')),
              matching: find.byType(IslandTag),
            )
            .first;
        final icon = find
            .descendant(of: card, matching: find.byType(IslandIcon))
            .first;
        expect(t.getCenter(tag).dy, closeTo(t.getCenter(title).dy, .1));
        expect(t.getSize(icon), const Size(22, 22));
        final firstRule = find
            .ancestor(
              of: find.text('绝不编造参数；每个参数必须出现在实际公共 Dart 声明中。'),
              matching: find.byType(StoryText),
            )
            .first;
        expect(
          t.getTopLeft(firstRule).dx - t.getTopLeft(card).dx,
          closeTo(38, .1),
        );
        expect(
          t.getTopLeft(firstRule).dy - t.getBottomLeft(tag).dy,
          closeTo(4, .1),
        );
        final scenario = find
            .ancestor(
              of: find.text('Flutter 应用'),
              matching: find.byType(IslandCard),
            )
            .first;
        expect(
          t.getSize(
            find
                .descendant(of: scenario, matching: find.byType(IslandIcon))
                .first,
          ),
          const Size(30, 30),
        );
        expect(t.takeException(), isNull);
      }
    },
  );
}

void _ignoreNavigation(String _) {}

Future<void> _showVisualStory(
  WidgetTester t,
  String path,
  Size viewport,
) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = viewport;
  addTearDown(t.view.resetPhysicalSize);
  addTearDown(t.view.resetDevicePixelRatio);
  var current = path;
  await t.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: IslandLocalizations.delegates,
      supportedLocales: IslandLocalizations.supportedLocales,
      theme: galleryTheme(),
      home: MediaQuery(
        data: MediaQueryData(size: viewport, disableAnimations: true),
        child: StatefulBuilder(
          builder: (_, set) => GalleryPage(
            path: current,
            onNavigate: (next) => set(() => current = next),
          ),
        ),
      ),
    ),
  );
  await t.pumpAndSettle();
}
