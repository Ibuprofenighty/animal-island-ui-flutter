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
      final credit = find.text('MIT License · Reference Gallery');
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
          id == 'skill' || id == 'form' || id == 'charts' || id == 'calendar'
              ? findsNothing
              : (id == 'avatar' || id == 'notification'
                    ? findsNWidgets(2)
                    : findsOneWidget),
        );
        if (id == 'form') {
          // Reference Form demo titles its two tables.
          expect(find.text('Form API'), findsOneWidget);
          expect(find.text('FormItem API'), findsOneWidget);
        }
        if (id == 'calendar') {
          // Reference Calendar demo titles its two tables.
          expect(find.text('Calendar API'), findsOneWidget);
          expect(find.text('IslandCalendarEvent'), findsOneWidget);
        }
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

  testWidgets('Home 4.0.0 subtitle, overview entries and GitHub mark', (
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
          child: Scaffold(
            body: GalleryHome(wallpaperSeed: 17, onNavigate: (_) {}),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(
      t
          .widget<IslandTypewriter>(find.byType(IslandTypewriter))
          .style!
          .fontWeight,
      FontWeight.w500,
    );
    final names = [
      for (final card in t.widgetList<IslandCard>(
        find.descendant(
          of: find.byType(GalleryHome),
          matching: find.byType(IslandCard),
        ),
      ))
        if (card.padding ==
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16))
          ((card.child as Column).children.first as Text).data!,
    ];
    expect(names.first, 'Chart');
    expect(names.indexOf('Calendar'), names.indexOf('TimePicker') + 1);
    expect(names.indexOf('NoData'), names.indexOf('Loading') + 1);
    expect(names, hasLength(23));
    final github = find.widgetWithText(TextButton, 'GitHub');
    final mark = find.descendant(
      of: github,
      matching: find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 14 && w.height == 14,
      ),
    );
    expect(mark, findsOneWidget);
    expect(t.getSize(mark), const Size.square(14));
    final label = find.descendant(of: github, matching: find.text('GitHub'));
    expect(t.getTopLeft(label).dx - t.getTopRight(mark).dx, 4);
    expect(t.getCenter(mark).dy, closeTo(t.getCenter(label).dy - 1, .01));
    expect(find.text('MIT License · Reference Gallery'), findsOneWidget);
  });

  testWidgets('Skill page opens under a circle Loading for 2s', (t) async {
    final mounted = t.binding.clock.now();
    await _showVisualStory(t, '/skill', const Size(1440, 1000));
    IslandLoading loading() => t.widget(find.byType(IslandLoading));
    expect(loading().type, IslandLoadingType.circle);
    expect(loading().active, isTrue);
    expect(find.text('快速开始').hitTestable(), findsNothing);
    await t.pump(
      const Duration(milliseconds: 1999) -
          t.binding.clock.now().difference(mounted),
    );
    expect(loading().active, isTrue);
    await t.pump(const Duration(milliseconds: 1));
    expect(loading().active, isFalse);
    await t.pumpAndSettle();
    expect(find.text('快速开始').hitTestable(), findsOneWidget);
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
  testWidgets('Image labels render reference inline code in the code font', (
    t,
  ) async {
    await _showVisualStory(t, '/image', const Size(1440, 1000));
    final codeRuns = <String>[];
    for (final paragraph in t.widgetList<RichText>(find.byType(RichText))) {
      final plain = paragraph.text.toPlainText();
      if (!plain.startsWith('相框类型') && !plain.startsWith('邮票类型')) continue;
      paragraph.text.visitChildren((span) {
        if (span is TextSpan &&
            span.text != null &&
            span.style?.fontFamily == IslandTheme.codeFontFamily) {
          codeRuns.add(span.text!);
        }
        return true;
      });
    }
    // Reference <code> runs; the muted label colour is inherited.
    expect(codeRuns, ['default', 'bordered', 'stampYear']);
  });
  testWidgets('Footer page title differs from its navigation caption', (
    t,
  ) async {
    await _showVisualStory(t, '/footer', const Size(375, 812));
    expect(find.text('Footer 底部装饰'), findsNWidgets(2));
    // Reference .footer: 16px vertical padding around 12px text with no
    // line-height (the font's normal metrics), measured 48 with Gallery fonts.
    expect(t.getSize(find.byType(IslandFooter).first).height, 48);
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

  group('Home reference parity', () {
    Future<void> showHome(WidgetTester t, {bool reduced = true}) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = const Size(1440, 1000);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: Scaffold(
            body: GalleryHome(wallpaperSeed: 17, onNavigate: (_) {}),
          ),
        ),
      );
      if (reduced) {
        await t.pumpAndSettle();
      } else {
        await t.pump();
      }
    }

    Color? colorOf(WidgetTester t, String text) {
      final paragraph = find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().startsWith(text),
      );
      return t.widget<RichText>(paragraph.first).text.style?.color;
    }

    testWidgets('wallpaper text keeps the reference-priority colours', (
      t,
    ) async {
      await showHome(t);
      expect(colorOf(t, 'Animal'), HomeWallpaperInk.cream);
      expect(colorOf(t, '向下滑动'), HomeWallpaperInk.cream);
      expect(colorOf(t, '特性'), HomeWallpaperInk.title);
      expect(colorOf(t, '为什么选择'), HomeWallpaperInk.body);
      expect(colorOf(t, 'MIT License · Reference'), HomeWallpaperInk.body);
      final footer = t.widget<RichText>(
        find.descendant(
          of: find.widgetWithText(TextButton, '组件文档'),
          matching: find.byType(RichText),
        ),
      );
      expect(footer.text.style!.color, HomeWallpaperInk.body);
      expect(
        footer.text.style!.fontFamilyFallback,
        contains('IslandGallerySans'),
        reason: 'the footer label must resolve CJK glyphs',
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('scroll hint has no action and exits past 70px', (t) async {
      await showHome(t);
      double opacity() => t
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.text('向下滑动'),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
      expect(opacity(), 1);
      final scrollable = find.byType(Scrollable).first;
      final position = t.state<ScrollableState>(scrollable).position;
      await t.tap(find.text('向下滑动'), warnIfMissed: false);
      await t.pumpAndSettle();
      expect(position.pixels, 0, reason: 'the reference hint has no action');
      position.jumpTo(60);
      await t.pumpAndSettle();
      expect(opacity(), 1);
      position.jumpTo(71);
      await t.pumpAndSettle();
      expect(opacity(), 0);
      expect(
        t
            .widget<IgnorePointer>(
              find
                  .ancestor(
                    of: find.text('向下滑动'),
                    matching: find.byType(IgnorePointer),
                  )
                  .first,
            )
            .ignoring,
        isTrue,
      );
      position.jumpTo(0);
      await t.pumpAndSettle();
      expect(opacity(), 1);
    });

    testWidgets('scroll hint bounces 8px on the 2s motion clock', (t) async {
      await showHome(t, reduced: false);
      final rest = t.getTopLeft(find.text('向下滑动')).dy;
      await t.pump(const Duration(milliseconds: 1000));
      expect(t.getTopLeft(find.text('向下滑动')).dy, closeTo(rest - 8, .01));
      await t.pump(const Duration(milliseconds: 1000));
      expect(t.getTopLeft(find.text('向下滑动')).dy, closeTo(rest, .01));
      // The bounce keeps the hint opaque (readable motion).
      expect(
        find.ancestor(
          of: find.text('向下滑动'),
          matching: find.byWidgetPredicate(
            (w) => w is Opacity && w.opacity < 1,
          ),
        ),
        findsNothing,
      );
      await t.pumpWidget(const SizedBox());
    });

    testWidgets('feature card hover lifts with shadow and bounces its icon', (
      t,
    ) async {
      await showHome(t, reduced: false);
      final title = find.text('治愈系风格');
      t
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(800);
      await t.pump();
      final rest = t.getTopLeft(title).dy;
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(t.getCenter(title));
      await t.pump();
      await t.pump(const Duration(milliseconds: 200));
      final icon = find.descendant(
        of: find.ancestor(of: title, matching: find.byType(IslandCard)),
        matching: find.byType(IslandIcon),
      );
      double scale() => t
          .widget<Transform>(
            find.ancestor(of: icon, matching: find.byType(Transform)).first,
          )
          .transform
          .getMaxScaleOnAxis();
      expect(scale(), closeTo(1.2, .01), reason: 'iconBounce 50% keyframe');
      await t.pump(const Duration(milliseconds: 250));
      expect(t.getTopLeft(title).dy, closeTo(rest - 4, .01));
      expect(scale(), closeTo(1.1, .001));
      final shadow = t
          .widgetList<DecoratedBox>(
            find.ancestor(of: title, matching: find.byType(DecoratedBox)),
          )
          .map((b) => b.decoration)
          .whereType<BoxDecoration>()
          .expand((d) => d.boxShadow ?? const <BoxShadow>[])
          .toList();
      expect(
        shadow,
        contains(
          const BoxShadow(
            color: Color.fromRGBO(114, 93, 66, .15),
            offset: Offset(0, 8),
            blurRadius: 24,
          ),
        ),
      );
      await mouse.moveTo(Offset.zero);
      await t.pump();
      await t.pump(const Duration(milliseconds: 350));
      expect(t.getTopLeft(title).dy, closeTo(rest, .01));
      expect(scale(), closeTo(1, .001));
      await t.pumpWidget(const SizedBox());
    });
  });

  group('Shared story chrome', () {
    Future<void> showStory(WidgetTester t, Widget child, double width) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(width, 1000);
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        MaterialApp(
          theme: galleryTheme(),
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
    }

    testWidgets('StoryApi titles, centres and sizes columns by content', (
      t,
    ) async {
      const long = '一段很长的说明文字，用来让这一行的说明列在窄宽度下换成多行，从而检查同一行其它单元格的垂直居中位置是否正确';
      await showStory(
        t,
        const StoryApi(
          title: 'FormItem API',
          rows: [('name', long, 'String', '-'), ('a', '短', 'int', '0')],
        ),
        700,
      );
      expect(find.text('FormItem API'), findsOneWidget);
      expect(find.text('API'), findsNothing);
      final desc = t.getRect(find.text(long));
      expect(desc.height, greaterThan(30), reason: 'description wraps');
      expect(t.getCenter(find.text('name')).dy, closeTo(desc.center.dy, 1));
      // Columns follow their content: the long description column is the
      // widest, and the one-word columns are narrower than an even split.
      final prop = t.getTopLeft(find.text('name')).dx;
      final type = t.getTopLeft(find.text('String')).dx;
      final def = t.getTopLeft(find.text('-')).dx;
      expect(desc.left - prop, lessThan(150));
      expect(type - desc.left, greaterThan(def - type));
      // At phone width the table keeps wrapping instead of a fixed minimum.
      await showStory(t, const StoryApi(rows: [('a', '短', 'int', '0')]), 375);
      final viewport = t.getSize(
        find.descendant(
          of: find.byType(StoryApi),
          matching: find.byType(Table),
        ),
      );
      expect(viewport.width, 375 - 40);
    });

    testWidgets('StoryLabel inline code uses the UA monospace 13/16 size', (
      t,
    ) async {
      await showStory(
        t,
        const StoryLabel('可选 stampYear 邮戳', code: {'stampYear'}),
        800,
      );
      final rich = t.widget<RichText>(
        find.descendant(
          of: find.byType(StoryLabel),
          matching: find.byType(RichText),
        ),
      );
      final spans = <TextSpan>[];
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text == 'stampYear') spans.add(span);
        return true;
      });
      expect(spans.single.style!.fontSize, 14 * 13 / 16);
      expect(spans.single.style!.fontFamily, IslandTheme.codeFontFamily);
    });

    testWidgets('StoryApi keeps 说明 readable at 375 and scrolls beyond it', (
      t,
    ) async {
      const desc = '轮播项列表，每一项包含图片、标题和描述文字';
      await showStory(
        t,
        const StoryApi(
          rows: [
            ('semanticLabelBuilder', desc, 'List<IslandSlide<T>>', 'required'),
            ('onPositionChanged', '位置变化', 'IslandNotificationPosition', '-'),
          ],
        ),
        375,
      );
      // Four 13px CJK characters per line plus the 16px cell padding on each
      // side, instead of one character per line.
      final cell = t.getSize(find.text(desc));
      expect(cell.width, greaterThanOrEqualTo(4 * 13 - .5));
      // Five or six lines (kinsoku may carry punctuation), not twenty.
      expect(t.getSize(find.text(desc)).height, lessThan(13 * 1.5 * 8));
      // The wider-than-viewport table scrolls horizontally; 默认值 stays
      // reachable inside the scroll region instead of being pushed out.
      final table = t.getSize(
        find.descendant(
          of: find.byType(StoryApi),
          matching: find.byType(Table),
        ),
      );
      expect(table.width, greaterThan(375 - 40));
      final scroll = find.descendant(
        of: find.byType(StoryApi),
        matching: find.byType(Scrollable),
      );
      await t.drag(scroll, const Offset(-600, 0));
      await t.pumpAndSettle();
      expect(
        t.getRect(find.text('required')).right,
        lessThanOrEqualTo(375 - 20),
      );
    });

    testWidgets('StoryPanel dashed keeps the solid panel geometry', (t) async {
      Future<Rect> heading(bool dashed) async {
        await showStory(
          t,
          StoryPanel(
            title: '许可证',
            dashed: dashed,
            children: const [Text('body')],
          ),
          800,
        );
        return t.getRect(find.text('许可证'));
      }

      final solid = await heading(false);
      expect(
        find.descendant(
          of: find.byType(StoryPanel),
          matching: find.byWidgetPredicate(
            (w) => w is CustomPaint && w.foregroundPainter != null,
          ),
        ),
        findsNothing,
      );
      final dashed = await heading(true);
      expect(dashed, solid);
      final painter =
          t
                  .widget<CustomPaint>(
                    find.ancestor(
                      of: find.text('许可证'),
                      matching: find.byWidgetPredicate(
                        (w) =>
                            w is CustomPaint &&
                            w.foregroundPainter is IslandDashedBorderPainter,
                      ),
                    ),
                  )
                  .foregroundPainter!
              as IslandDashedBorderPainter;
      expect(painter.color, const Color(0xffe8e2d6));
    });

    testWidgets('StoryLabel links open reference anchors', (t) async {
      final semantics = t.ensureSemantics();
      try {
        await showStory(
          t,
          const StoryLabel(
            '图标来自 naive-icons —— 手绘',
            links: {'naive-icons': 'https://example.invalid/naive-icons'},
          ),
          800,
        );
        final link = find.text('naive-icons');
        expect(link, findsOneWidget);
        final style = t.widget<Text>(link).style!;
        expect(style.decoration, TextDecoration.underline);
        expect(style.color, const Color(0xff725d42));
        expect(
          t.getSemantics(link).getSemanticsData().flagsCollection.isLink,
          isTrue,
        );
      } finally {
        semantics.dispose();
      }
    });
  });

  testWidgets('Skill License is dashed and catalog categories are centred', (
    t,
  ) async {
    await _showVisualStory(t, '/skill', const Size(1440, 1000));
    final license = t.widget<StoryPanel>(
      find.ancestor(of: find.text('许可证'), matching: find.byType(StoryPanel)),
    );
    expect(license.dashed, isTrue);
    final general = find.text('General');
    final tag = find.ancestor(of: general, matching: find.byType(IslandTag));
    expect(t.getSize(tag).width, closeTo(128, .01));
    expect(t.getCenter(general).dx, closeTo(t.getCenter(tag).dx, .5));
    expect(t.takeException(), isNull);
  });

  testWidgets('Title Layer and Tab demos use the reference 40px gap', (
    t,
  ) async {
    await _showVisualStory(t, '/title', const Size(1440, 1000));
    for (final pair in [('蜂蜜阳光', '海风信箱'), ('青柠苏打', '热可可')]) {
      final first = find.ancestor(
        of: find.text(pair.$1),
        matching: find.byType(IslandTitle),
      );
      final second = find.ancestor(
        of: find.text(pair.$2),
        matching: find.byType(IslandTitle),
      );
      expect(
        t.getTopLeft(second).dx - t.getTopRight(first).dx,
        closeTo(40, .01),
      );
    }
  });
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
