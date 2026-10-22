import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/pages/stories/registry.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Windows engine renders registered Gallery and exercises shared overlays',
    (tester) async {
      await binding.setSurfaceSize(const Size(1440, 1000));
      addTearDown(() => binding.setSurfaceSize(null));
      final boundaryKey = GlobalKey();
      var path = '/select';
      var reduced = true;
      late StateSetter configure;
      late StateSetter navigate;
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: StatefulBuilder(
            builder: (context, configureState) {
              configure = configureState;
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                locale: const Locale('zh'),
                localizationsDelegates: IslandLocalizations.delegates,
                supportedLocales: IslandLocalizations.supportedLocales,
                theme: galleryTheme(),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: reduced),
                  child: child!,
                ),
                home: StatefulBuilder(
                  builder: (_, set) {
                    navigate = set;
                    return GalleryPage(
                      path: path,
                      onNavigate: (next) => set(() => path = next),
                    );
                  },
                ),
              );
            },
          ),
        ),
      );
      Future<void> advance() async {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
      }

      Future<void> readyVisibleImages() async {
        final viewport = Offset.zero & tester.getSize(find.byKey(boundaryKey));
        final images = find.byType(Image).evaluate().where((element) {
          final image = element.widget as Image;
          if (image.image is! AssetImage) return false;
          if ([
            'no-such-image.png',
            'assets/missing-avatar.png',
          ].contains((image.image as AssetImage).assetName))
            return false;
          final rect = tester.getRect(
            find.byElementPredicate((e) => identical(e, element)),
          );
          return rect.overlaps(viewport);
        }).toList();
        final errors = <Object>[];
        await tester.runAsync(() async {
          await Future.wait(
            images.map(
              (element) => precacheImage(
                (element.widget as Image).image,
                element,
                onError: (error, _) => errors.add(error),
              ),
            ),
          ).timeout(const Duration(seconds: 20));
        });
        await tester.pump();
        expect(
          errors,
          isEmpty,
          reason:
              'Visible packaged images must decode before a visual capture.',
        );
      }

      Future<void> capture(String name) async {
        await readyVisibleImages();
        const folder = String.fromEnvironment('ISLAND_SCREENSHOT_DIR');
        if (folder.isEmpty) return;
        final directory = Directory(folder);
        await directory.create(recursive: true);
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary
            .toImage(pixelRatio: 1)
            .timeout(const Duration(seconds: 15));
        final data = await image
            .toByteData(format: ui.ImageByteFormat.png)
            .timeout(const Duration(seconds: 15));
        image.dispose();
        await File('${directory.path}/$name.png')
            .writeAsBytes(data!.buffer.asUint8List());
        debugPrint('Captured $name');
      }

      for (final id in storyBuilders.keys) {
        navigate(() => path = '/$id');
        await advance();
        expect(tester.takeException(), isNull, reason: id);
        if (id == 'table') {
          final rows = find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.role == ui.SemanticsRole.row,
          );
          expect(tester.getRect(rows.at(0)).top, closeTo(355, .1));
          expect(tester.getRect(rows.at(0)).height, closeTo(53, .1));
          expect(tester.getRect(rows.at(1)).height, closeTo(50.390625, .1));
          expect(tester.getRect(rows.at(5)).bottom, closeTo(659.953125, .1));
        }
        if (id == 'countup') {
          await tester.pump();
          await tester.pump(const Duration(seconds: 3));
          expect(
            find.text('1,320'),
            findsWidgets,
            reason: 'Capture the completed initial score, not its first animation tick.',
          );
        }
        await capture(id);

        if (id == 'skeleton') {
          final paragraph = find.byWidgetPredicate(
            (w) =>
                w is IslandSkeleton &&
                w.variant == IslandSkeletonVariant.paragraph,
          );
          expect(tester.getSize(paragraph), const Size(198, 86));
          configure(() => reduced = false);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 800));
          await capture('skeleton-active-sweep');
          await tester.tap(find.byType(IslandSwitch));
          await tester.pump();
          expect(find.text('输入框已加载'), findsOneWidget);
          expect(find.text('头像已加载'), findsOneWidget);
          expect(paragraph, findsOneWidget);
          await capture('skeleton-loaded');
          configure(() => reduced = true);
          await advance();
        }
        if (id == 'title') {
          configure(() => reduced = false);
          await tester.pump();
          final leaf = find.text('双层纸');
          final before = tester.getRect(leaf);
          final mouse = await tester.createGesture(
            kind: ui.PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(before.center);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));
          await capture('title-hover-100ms');
          await tester.pump(const Duration(milliseconds: 100));
          expect(
            tester.getRect(leaf).width / before.width,
            closeTo(1.06, .001),
          );
          await capture('title-hover-200ms');
          await mouse.removePointer();
          configure(() => reduced = true);
          await advance();
        }
        if (id == 'checkbox' || id == 'radio') {
          configure(() => reduced = false);
          await tester.pump();
          await tester.tap(find.text(id == 'radio' ? '夏天' : '森林').first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 240));
          await capture('$id-splash-240ms');
          await tester.pump(const Duration(milliseconds: 360));
          await capture('$id-selected-600ms');
          configure(() => reduced = true);
          await advance();
        }
        if (id == 'rate') {
          configure(() => reduced = false);
          await tester.pump();
          await tester.tap(find.bySemanticsLabel('5 星').first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 60));
          await capture('rate-stagger-60ms');
          await tester.pump(const Duration(milliseconds: 180));
          await capture('rate-splash-240ms');
          await tester.pump(const Duration(milliseconds: 360));
          await capture('rate-selected-600ms');
          configure(() => reduced = true);
          await advance();
        }
        if (id == 'switch') {
          configure(() => reduced = false);
          await tester.pump();
          await tester.tap(find.byType(IslandSwitch).first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 125));
          await capture('switch-125ms');
          await tester.pump(const Duration(milliseconds: 125));
          await capture('switch-250ms');
          configure(() => reduced = true);
          await advance();
        }
        if (id == 'tag') {
          expect(
            tester
                .getSemantics(find.text('4 variants'))
                .getSemanticsData()
                .hasAction(ui.SemanticsAction.tap),
            isFalse,
          );
          final closeActions = find.descendant(
            of: find.byType(IslandTag),
            matching: find.bySemanticsLabel('close'),
          );
          final close = closeActions.first;
          await Scrollable.ensureVisible(tester.element(close), alignment: .5);
          await advance();
          expect(find.text('Apple'), findsOneWidget);
          await capture('tag-closable');
          await tester.tap(close);
          await advance();
          expect(find.text('Apple'), findsNothing);
          expect(closeActions, findsNWidgets(6));
          await capture('tag-closed');
        }
        if (id == 'button') {
          expect(
            tester
                .getSemantics(find.text('6 types'))
                .getSemanticsData()
                .hasAction(ui.SemanticsAction.tap),
            isFalse,
          );
          expect(
            tester
                .getSemantics(find.text('Disabled'))
                .getSemanticsData()
                .hasAction(ui.SemanticsAction.tap),
            isFalse,
          );
          final label = find.text('Default');
          final base = tester.getRect(label);
          final mouse = await tester.createGesture(
            kind: ui.PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(base.center);
          await advance();
          expect(tester.getRect(label).top, closeTo(base.top - 1, .1));
          await capture('button-default-hover');
          await mouse.down(base.center);
          await advance();
          expect(tester.getRect(label).top, closeTo(base.top, .1));
          await capture('button-default-pressed');
          await mouse.up();
          final text = find.text('Text', skipOffstage: false).first;
          final textBase = tester.getRect(text);
          await mouse.moveTo(textBase.center);
          await advance();
          expect(tester.getRect(text), textBase);
          await capture('button-text-hover');
          await mouse.removePointer();
          await tester.pump();
        }
        if (id == 'table') {
          final rows = find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.role == ui.SemanticsRole.row,
          );
          final bounds = tester.getRect(rows.at(1));
          final pointer = await tester.createGesture(
            kind: ui.PointerDeviceKind.mouse,
          );
          await pointer.addPointer(location: Offset.zero);
          await pointer.moveTo(Offset(bounds.right - 40, bounds.center.dy));
          await tester.pump();
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          final pixel =
              (bounds.center.dy.floor() * image.width +
                  (bounds.right - 40).floor()) *
              4;
          expect(
            [
              bytes!.getUint8(pixel),
              bytes.getUint8(pixel + 1),
              bytes.getUint8(pixel + 2),
            ],
            [214, 240, 234],
          );
          image.dispose();
          expect(tester.getRect(rows.at(1)), bounds);
          await capture('table-hover');
          await pointer.removePointer();
          await tester.pump();
        }
      }
      navigate(() => path = '/date-picker');
      await advance();
      await tester.tap(find.bySemanticsLabel(RegExp(r'^选择日期(?:\n|$)')).first);
      await tester.pumpAndSettle();
      await capture('date-picker-open');
      await tester.tap(
        find.bySemanticsLabel(RegExp(r'^2026年8月13日(?:\n|$)')).first,
      );
      await tester.tap(find.text('确定').last);
      await tester.pumpAndSettle();
      expect(find.text('2026-08-13'), findsWidgets);
      await capture('date-picker-selected');
      navigate(() => path = '/form');
      await advance();
      await Scrollable.ensureVisible(
        tester.element(find.widgetWithText(IslandButton, '登录')),
        alignment: .4,
      );
      await tester.tap(find.widgetWithText(IslandButton, '登录'));
      await tester.pumpAndSettle();
      expect(find.text('请输入用户名'), findsWidgets);
      await capture('form-errors');
      navigate(() => path = '/upload');
      await advance();
      await tester.tap(find.bySemanticsLabel('删除 海岛全景.png'));
      await tester.pumpAndSettle();
      expect(find.text('海岛全景.png'), findsNothing);
      expect(find.text('露营清单.pdf'), findsOneWidget);
      await capture('upload-remove');
      navigate(() => path = '/cursor');
      await advance();
      final cursorMouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await cursorMouse.addPointer(location: Offset.zero);
      for (final label in ['鼠标移入此区域将显示自定义光标', '鼠标移入此区域将显示雨滴光标']) {
        await Scrollable.ensureVisible(
          tester.element(find.text(label)),
          alignment: .5,
        );
        await advance();
        final point = tester.getCenter(find.text(label));
        await cursorMouse.moveTo(point);
        await tester.pumpAndSettle();
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final raster = await boundary.toImage(pixelRatio: 1);
        final bytes = await raster.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final drop = label.contains('雨滴');
        final x = (point.dx + 2).round();
        final y = (point.dy + (drop ? 16 : 10)).round();
        final index = (y * raster.width + x) * 4;
        final rgb =
            bytes!.getUint8(index) << 16 |
            bytes.getUint8(index + 1) << 8 |
            bytes.getUint8(index + 2);
        raster.dispose();
        expect(
          rgb,
          drop ? 0x74ccff : 0xfff7e6,
          reason: 'Visible cursor pixels for $label',
        );
        await capture(
          label.contains('雨滴') ? 'cursor-raindrop' : 'cursor-arrow',
        );
      }
      await cursorMouse.removePointer();
      navigate(() => path = '/drawer');
      configure(() => reduced = false);
      await advance();
      for (final entry in const {
        '右侧抽屉': '岛屿设置',
        '左侧抽屉': '居民名单',
        '顶部抽屉': '通知公告',
        '底部抽屉': '快捷操作',
        '关闭景深': '无景深',
      }.entries) {
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 5),
        );
        final trigger = find.widgetWithText(IslandButton, entry.key).first;
        expect(trigger.hitTestable(), findsOneWidget, reason: entry.key);
        await tester.tap(trigger);
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 5),
        );
        expect(find.text(entry.value), findsOneWidget, reason: entry.key);
        expect(
          find.byWidgetPredicate((w) => w is IslandDrawer && w.open),
          findsOneWidget,
        );
        await capture('drawer-${entry.key}');
        if (entry.key == '右侧抽屉') {
          expect(tester.getRect(find.text(entry.value)).top, 24);
          expect(tester.getRect(find.text(entry.value)).height, 42);
          final drawerMouse = await tester.createGesture(
            kind: ui.PointerDeviceKind.mouse,
          );
          await drawerMouse.addPointer(location: const Offset(1200, 400));
          await tester.pumpAndSettle();
          await capture('drawer-cursor-panel');
          await tester.tap(find.text(entry.value));
          await tester.pumpAndSettle();
          expect(find.text(entry.value), findsOneWidget);
          await drawerMouse.moveTo(const Offset(500, 500));
          await tester.pumpAndSettle();
          await capture('drawer-cursor-mask');
          await tester.tapAt(const Offset(500, 500));
          await drawerMouse.removePointer();
        } else if (entry.key == '左侧抽屉') {
          await tester.tap(find.widgetWithText(IslandButton, '确定'));
        } else if (entry.key == '顶部抽屉') {
          await tester.tap(
            find.descendant(
              of: find.byWidgetPredicate(
                (w) =>
                    w is Semantics &&
                    w.properties.role == ui.SemanticsRole.dialog,
              ),
              matching: find.bySemanticsLabel('关闭'),
            ),
          );
        } else {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        }
        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 5),
        );
        expect(find.text(entry.value), findsNothing, reason: entry.key);
        expect(
          find.byWidgetPredicate((w) => w is IslandDrawer && w.open),
          findsNothing,
        );
        expect(tester.takeException(), isNull, reason: entry.key);
      }
      configure(() => reduced = true);
      await advance();
      navigate(() => path = '/tooltip');
      await advance();
      final tooltipMouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await tooltipMouse.addPointer(location: Offset.zero);
      for (final label in [
        'Hover 我',
        'default',
        'default 无边框',
        'island 有边框',
        'island 无边框',
        'top-start',
        'top',
        'top-end',
        'left-start',
        'left',
        'left-end',
        'right-start',
        'right',
        'right-end',
        'bottom-start',
        'bottom',
        'bottom-end',
      ]) {
        debugPrint('Tooltip $label: scroll');
        final anchor = find.text(label).first;
        await Scrollable.ensureVisible(
          tester.element(anchor),
          alignment: .5,
        ).timeout(const Duration(seconds: 10));
        await advance();
        debugPrint('Tooltip $label: enter');
        await tooltipMouse
            .moveTo(tester.getCenter(anchor))
            .timeout(const Duration(seconds: 10));
        await advance();
        expect(tester.takeException(), isNull, reason: 'tooltip $label');
        await capture('tooltip-${label.replaceAll(' ', '-')}');
        debugPrint('Tooltip $label: leave');
        await tooltipMouse
            .moveTo(Offset.zero)
            .timeout(const Duration(seconds: 10));
        await advance();
      }
      await tooltipMouse.removePointer();
      navigate(() => path = '/notification');
      await advance();
      await tester.ensureVisible(find.text('duration=0(不自动关闭)'));
      await tester.tap(find.text('duration=0(不自动关闭)'));
      await advance();
      expect(find.text('永不自动关闭(手动 × 关闭)'), findsOneWidget);
      await capture('notification-persistent');
      await tester.tap(find.text('×'));
      final notificationExit = Stopwatch()..start();
      while (find.text('永不自动关闭(手动 × 关闭)').evaluate().isNotEmpty &&
          notificationExit.elapsed < const Duration(seconds: 5)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await advance();
      expect(find.text('永不自动关闭(手动 × 关闭)'), findsNothing);
      await tester.ensureVisible(find.text('自定义 closeIcon'));
      await tester.tap(find.text('自定义 closeIcon'));
      await advance();
      expect(find.text('CLOSE'), findsOneWidget);
      expect(tester.getSize(find.text('CLOSE')).height, closeTo(11, .1));
      await capture('notification-custom-close');
      for (
        var i = 0;
        i < 80 && !Focus.of(tester.element(find.text('CLOSE'))).hasPrimaryFocus;
        i++
      ) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(
        Focus.of(tester.element(find.text('CLOSE'))).hasPrimaryFocus,
        isTrue,
      );
      await capture('notification-close-focus');
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await advance();
      expect(find.text('CLOSE'), findsNothing);
      navigate(() => path = '/image');
      await advance();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == '点击预览大图',
        ),
      );
      await advance();
      await capture('image-preview');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await advance();
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == '关闭预览',
        ),
        findsNothing,
      );
      navigate(() => path = '/carousel');
      await advance();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == '下一张',
        ),
      );
      await advance();
      await capture('carousel-next');
      navigate(() => path = '/countup');
      await advance();
      await tester.tap(find.text('捡到木头 +15'));
      await advance();
      await capture('countup-wood');

      navigate(() => path = '/pagination');
      await advance();
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.button == true &&
              w.properties.label == '10 条/页',
        ),
      );
      await advance();
      await capture('pagination-size-open');
      await tester.tap(find.text('50 条/页'));
      await advance();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.button == true &&
              w.properties.label == '50 条/页',
        ),
        findsOneWidget,
      );
      await capture('pagination-size-changed');
      navigate(() => path = '/table');
      await advance();
      await tester.tap(find.text('斑马纹 ✓'));
      await advance();
      expect(find.text('斑马纹 ✗'), findsOneWidget);
      await capture('table-unstriped');
      await tester.tap(find.text('斑马纹 ✗'));
      await advance();
      await tester.tap(find.text('模拟加载'));
      await advance();
      await capture('table-loading');
      final tableCompletion = Stopwatch()..start();
      while (find.text('加载中...').evaluate().isNotEmpty &&
          tableCompletion.elapsed < const Duration(seconds: 10)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('模拟加载'), findsOneWidget);

      navigate(() => path = '/select');
      await advance();
      await tester.tap(find.text('鲈鱼'));
      await advance();
      expect(find.text('鲷鱼'), findsOneWidget);
      final selectOption = find
          .ancestor(of: find.text('鲷鱼'), matching: find.byType(MouseRegion))
          .first;
      expect(
        tester.getRect(selectOption),
        const Rect.fromLTWH(459, 291, 102, 41),
      );
      await capture('select-open');
      final selectMouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await selectMouse.addPointer(location: Offset.zero);
      await selectMouse.moveTo(tester.getCenter(find.text('鲷鱼')));
      await advance();
      await capture('select-option-hover');
      await selectMouse.removePointer();
      await tester.tap(find.text('鲷鱼'));
      await advance();
      expect(find.text('鲷鱼'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final searchField = find.byType(TextField).first;
      await Scrollable.ensureVisible(
        tester.element(searchField),
        alignment: .5,
      );
      await tester.tap(searchField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('鲈鱼'));
      await tester.pumpAndSettle();
      await tester.enterText(searchField, '无结果');
      await tester.pumpAndSettle();
      final searchList = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.role == ui.SemanticsRole.list,
      );
      expect(searchList, findsOneWidget);
      expect(
        find.descendant(of: searchList, matching: find.text('暂无数据')),
        findsOneWidget,
      );
      await capture('select-search-empty');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('神仙鱼'), findsOneWidget);
      expect(tester.widget<TextField>(searchField).controller!.text, '鲈鱼');
      await capture('select-search-reset');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.text('神仙鱼'), findsNothing);

      configure(() => reduced = true);
      navigate(() => path = '/modal');
      await advance();
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
          tester.getTopLeft(find.widgetWithText(IslandButton, entry.$1)).dy,
          entry.$2,
          reason: entry.$1,
        );
      }

      for (final entry in [
        ('异形 Modal', 'game', 217.0),
        ('基础 Modal', 'basic', 217.0),
        ('带标题 Modal', 'title', 266.0),
        ('自定义 Footer', 'custom', 234.0),
        ('关闭打字机效果', 'weather', 234.0),
        ('浅色遮罩', 'light', 234.0),
        ('深色遮罩', 'dark', 266.0),
      ]) {
        final trigger = find.widgetWithText(IslandButton, entry.$1);
        if (trigger.hitTestable().evaluate().isEmpty)
          await tester.ensureVisible(trigger);
        await tester.tap(trigger);
        await tester.pumpAndSettle();
        final clip = find.descendant(
          of: find.byType(IslandModal),
          matching: find.byType(ClipPath),
        );
        expect(tester.getSize(clip), Size(520, entry.$3));
        await capture('modal-${entry.$2}');
        if (entry.$2 == 'light') {
          final modalMouse = await tester.createGesture(
            kind: ui.PointerDeviceKind.mouse,
          );
          await modalMouse.addPointer(location: const Offset(720, 500));
          await tester.pumpAndSettle();
          await modalMouse.moveTo(const Offset(1200, 120));
          await tester.pumpAndSettle();
          await modalMouse.down(const Offset(1200, 120));
          await modalMouse.up();
          await modalMouse.removePointer();
        } else {
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        }
        await tester.pumpAndSettle();
        expect(find.byType(IslandModal), findsNothing);
      }

      navigate(() => path = '/time-picker');
      await advance();
      await tester.tap(find.text('09:30:00').first);
      await advance();
      expect(find.text('确定'), findsOneWidget);
      await capture('time-picker-open');
      await tester.tap(find.bySemanticsLabel(RegExp(r'^1 秒')));
      await advance();
      await tester.tap(find.text('确定'));
      await advance();
      expect(find.text('09:30:01'), findsOneWidget);
      expect(tester.takeException(), isNull);

      navigate(() => path = '/collapse');
      await advance();
      final disclosure = find.text('1個島嶼可以登錄多少名用戶?');
      ui.Tristate expansion() => tester
          .getSemantics(disclosure)
          .getSemanticsData()
          .flagsCollection
          .isExpanded;
      expect(expansion(), ui.Tristate.isFalse);
      await tester.tap(disclosure);
      await advance();
      expect(expansion(), ui.Tristate.isTrue);
      await capture('collapse-expanded');
      expect(
        tester.getSize(find.byType(SizeTransition).first).height,
        greaterThan(24),
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      await advance();
      expect(expansion(), ui.Tristate.isFalse);
      await capture('collapse-keyboard-closed');
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await advance();
      expect(expansion(), ui.Tristate.isTrue);
      final disabledDisclosure = find.text('这个问题已被禁用（无法展开）');
      await tester.tap(disabledDisclosure);
      await advance();
      expect(
        tester
            .getSemantics(disabledDisclosure)
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isFalse,
      );
      expect(tester.takeException(), isNull);

      navigate(() => path = '/loading');
      await advance();
      await tester.tap(find.text('带提示文字'));
      await advance();
      expect(find.text('正在连接岛屿…'), findsOneWidget);
      await capture('loading-active');
      // Real engine timers/fades advance over frames, unlike fake widget time.
      final completion = Stopwatch()..start();
      while (find.text('正在连接岛屿…').evaluate().isNotEmpty &&
          completion.elapsed < const Duration(seconds: 10)) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('正在连接岛屿…'), findsNothing);

      navigate(() => path = '/backtop');
      await advance();
      await advance();
      await capture('backtop-bottom');
      final backAction = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == '返回顶部',
      );
      final backBounds = tester.getRect(backAction);
      final backFocus = tester
          .widget<FocusableActionDetector>(
            find.descendant(
              of: backAction,
              matching: find.byType(FocusableActionDetector),
            ),
          )
          .focusNode!;
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      backFocus.requestFocus();
      await tester.pump();
      expect(tester.getRect(backAction), backBounds);
      await capture('backtop-focused');
      configure(() => reduced = false);
      await tester.pump();
      final backMouse = await tester.createGesture(
        kind: ui.PointerDeviceKind.mouse,
      );
      await backMouse.addPointer(location: Offset.zero);
      await backMouse.moveTo(backBounds.center);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await capture('backtop-hover-150ms');
      await tester.pump(const Duration(milliseconds: 150));
      await capture('backtop-hover-300ms');
      await backMouse.removePointer();
      configure(() => reduced = true);
      await advance();
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.button == true &&
              widget.properties.label == '返回顶部',
        ),
      );
      await advance();
      await capture('backtop-top');
      expect(tester.takeException(), isNull);
      navigate(() => path = '/');
      await advance();
      await capture('home');
      navigate(() => path = '/skill');
      await advance();
      // Live binding surface constraints and platform metrics are separate.
      // Override both so MediaQuery breakpoints see the captured viewport.
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await binding.setSurfaceSize(const Size(375, 812));
      navigate(() => path = '/');
      configure(() => reduced = true);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('返回首页'), findsNothing);
      expect(find.bySemanticsLabel('打开导航'), findsNothing);
      await capture('home-375');
      expect(tester.takeException(), isNull, reason: 'home-375');
      await tester.tap(find.widgetWithText(IslandButton, '开始使用 →'));
      await tester.pumpAndSettle();
      expect(path, '/skill');
      await capture('skill-375');
      expect(tester.takeException(), isNull, reason: 'skill-375');
      for (final id in storyBuilders.keys.where((id) => id != 'skill')) {
        navigate(() => path = '/$id');
        await advance();
        if (id == 'countup') {
          await tester.pump();
          await tester.pump(const Duration(seconds: 3));
          expect(find.text('1,320'), findsWidgets);
        }
        expect(tester.takeException(), isNull, reason: '$id-375 default');
        await capture('$id-375');
      }
      navigate(() => path = '/select');
      await tester.pumpAndSettle();
      await tester.tap(find.text('鲈鱼'));
      await tester.pumpAndSettle();
      final narrowList = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.role == ui.SemanticsRole.list,
      );
      final narrowRect = tester.getRect(narrowList);
      expect(narrowRect.left, closeTo(203, .1));
      expect(narrowRect.width, closeTo(102, .1));
      expect(narrowRect.right, lessThanOrEqualTo(375));
      expect(narrowRect.top, greaterThanOrEqualTo(0));
      expect(narrowRect.bottom, lessThanOrEqualTo(812));
      debugPrint('SELECT375_GEOMETRY=$narrowRect');
      final narrowFields = find.byType(IslandSelect<String>);
      expect(
        tester.getRect(narrowFields.at(1)),
        const Rect.fromLTWH(58, 505, 140, 41),
      );
      expect(
        tester.getRect(narrowFields.at(2)),
        const Rect.fromLTWH(214, 505, 140, 41),
      );
      await capture('select-375-open');
      expect(tester.takeException(), isNull, reason: 'select-375-open');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(narrowList, findsNothing);
      await capture('select-375-closed');
      expect(tester.takeException(), isNull, reason: 'select-375-closed');
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(narrowList, findsOneWidget);
      await capture('select-375-reopen');
      expect(tester.takeException(), isNull, reason: 'select-375-reopen');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      navigate(() => path = '/tag');
      configure(() => reduced = true);
      await tester.pumpAndSettle();
      expect(
        MediaQuery.sizeOf(tester.element(find.byType(GalleryPage))),
        const Size(375, 812),
      );
      final narrowSmall = find.widgetWithText(IslandTag, 'small');
      expect(tester.getTopLeft(narrowSmall), const Offset(41, 467));
      expect(tester.getSize(narrowSmall).height, 24);
      await capture('tag-375');
      navigate(() => path = '/collapse');
      await tester.pumpAndSettle();
      final narrowCollapse = find.byType(IslandCollapse).first;
      expect(tester.getTopLeft(narrowCollapse), const Offset(41, 324));
      expect(tester.getSize(narrowCollapse).height - 12, closeTo(80.78125, .1));
      await capture('collapse-375-closed');
      await tester.tap(find.text('1個島嶼可以登錄多少名用戶?'));
      await tester.pumpAndSettle();
      expect(
        tester
            .getSemantics(find.text('1個島嶼可以登錄多少名用戶?'))
            .getSemanticsData()
            .flagsCollection
            .isExpanded,
        ui.Tristate.isTrue,
      );
      expect(tester.getSize(narrowCollapse).height - 12, closeTo(152.375, .1));
      await capture('collapse-375-expanded');
      expect(tester.takeException(), isNull);
      navigate(() => path = '/modal');
      await tester.pumpAndSettle();
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
        if (trigger.hitTestable().evaluate().isEmpty)
          await tester.ensureVisible(trigger);
        await tester.tap(trigger);
        await tester.pumpAndSettle();
        final clip = find.descendant(
          of: find.byType(IslandModal),
          matching: find.byType(ClipPath),
        );
        expect(tester.getSize(clip).width, 343);
        if (label == '带标题 Modal') expect(tester.getSize(clip).height, 330);
        await capture('modal-375-$label');
        await tester.tap(
          find.widgetWithText(
            IslandButton,
            label == '自定义 Footer' ? '确认搬家' : '确定',
          ),
        );
        await tester.pumpAndSettle();
        expect(find.byType(IslandModal), findsNothing);
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    },
  );
}
