import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'components_test.dart' show host;

void main() {
  for (final code in ['en', 'zh']) {
    testWidgets('Declared $code delegates and RTL2x narrow owned layout', (
      t,
    ) async {
      t.view.physicalSize = const Size(375, 1400);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      IslandLocalizations? strings;
      TextDirection? direction;
      double? scaled;
      final changes = <IslandPaginationValue>[];
      final zh = code == 'zh';
      final long = zh
          ? '这是一段可以自然换行的较长说明文字，保持调用者内容与布局约束。'
          : 'This longer application description wraps naturally within the caller supplied narrow layout constraints.';
      await t.pumpWidget(
        host(
          Builder(
            builder: (c) {
              strings = IslandLocalizations.of(c);
              direction = Directionality.of(c);
              scaled = MediaQuery.textScalerOf(c).scale(16);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    IslandButton(
                      onPressed: () {},
                      child: Text(
                        zh ? '一段较长的操作说明文字' : 'A longer action description',
                      ),
                    ),
                    const SizedBox(height: 16),
                    IslandCard(child: Text(long)),
                    IslandRadioGroup<String>(
                      vertical: true,
                      options: [
                        IslandOption(
                          value: 'a',
                          label: zh ? '今天去探索' : 'Explore the island today',
                        ),
                        IslandOption(
                          value: 'b',
                          label: zh ? '明天再出发' : 'Explore the island tomorrow',
                        ),
                      ],
                      value: 'a',
                      onChanged: (_) {},
                    ),
                    IslandTextField(
                      label: zh ? '来访者姓名' : 'Visitor name',
                      helper: zh ? '请填写名字，不会发送到服务器。' : 'Enter a name; this example does not send it anywhere.',
                    ),
                    IslandCheckbox(
                      label: zh
                          ? '一个较长的同意选项说明文字'
                          : 'A longer agreement option description',
                      value: false,
                      onChanged: null,
                    ),
                    IslandTabs(
                      items: [
                        IslandTab(
                          value: 0,
                          label: Text(zh ? '今天' : 'Today'),
                          child: const SizedBox(),
                        ),
                        IslandTab(
                          value: 1,
                          label: Text(zh ? '明天' : 'Tomorrow'),
                          child: const SizedBox(),
                        ),
                      ],
                      value: 0,
                      onChanged: (_) {},
                    ),
                    IslandPagination(
                      total: 35,
                      value: const IslandPaginationValue(),
                      onChanged: changes.add,
                    ),
                  ],
                ),
              );
            },
          ),
          locale: Locale(code),
          rtl: true,
          scale: 2,
          dark: true,
        ),
      );
      await t.pumpAndSettle();
      final l = strings!;
      expect(direction, TextDirection.rtl);
      expect(scaled, 32);
      final actual = [
        l.close,
        l.cancel,
        l.confirm,
        l.loading,
        l.pagination,
        l.previousPage,
        l.nextPage,
        l.pageLabel(2),
        l.totalItems(0),
        l.perPage(10),
        l.pageSize,
        l.jumpTo,
        l.pageSuffix,
        l.jumpPage,
        l.noData,
        l.carousel,
        l.previousSlide,
        l.nextSlide,
        l.chooseSlide,
        l.goToSlide(2),
        l.slidePosition(2, 4),
        l.pauseAutoplay,
        l.resumeAutoplay,
        l.play,
        l.pause,
        l.imageFailed,
        l.imagePreview,
        l.closePreview,
        l.viewImage('sample'),
      ];
      expect(
        actual,
        zh
            ? [
                '关闭',
                '取消',
                '确认',
                '加载中',
                '分页',
                '上一页',
                '下一页',
                '第 2 页',
                '共 0 条',
                '10 条/页',
                '选择每页条数',
                '跳至',
                '页',
                '跳转到指定页',
                '暂无数据',
                '轮播图',
                '上一张',
                '下一张',
                '选择轮播页',
                '转到第 2 张',
                '第 2 张，共 4 张',
                '暂停自动播放',
                '继续自动播放',
                '播放',
                '暂停',
                '图片加载失败',
                '图片预览',
                '关闭预览',
                '查看图片：sample',
              ]
            : [
                'Close',
                'Cancel',
                'Confirm',
                'Loading',
                'Pagination',
                'Previous page',
                'Next page',
                'Page 2',
                '0 items',
                '10 / page',
                'Items per page',
                'Go to',
                'page',
                'Jump to page',
                'No data',
                'Carousel',
                'Previous slide',
                'Next slide',
                'Choose slide',
                'Go to slide 2',
                'Slide 2 of 4',
                'Pause autoplay',
                'Resume autoplay',
                'Play',
                'Pause',
                'Image failed to load',
                'Image preview',
                'Close preview',
                'View image: sample',
              ],
      );
      final next = find.byWidgetPredicate(
        (w) =>
            w is Semantics &&
            w.properties.button == true &&
            w.properties.label == (zh ? '下一页' : 'Next page'),
      );
      expect(next, findsOneWidget);
      await t.ensureVisible(next);
      await t.pumpAndSettle();
      await t.tap(next);
      await t.pumpAndSettle();
      expect(changes, [const IslandPaginationValue(page: 2)]);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
    });
  }
}
