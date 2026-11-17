import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class LoadingStory extends StatefulWidget {
  const LoadingStory({super.key});
  @override
  State<LoadingStory> createState() => _LoadingStoryState();
}

class _LoadingStoryState extends State<LoadingStory> {
  bool active = false;
  String? tip;
  Duration delay = Duration.zero;
  IslandLoadingType type = IslandLoadingType.snow;
  bool showBoat = true;
  Timer? timer;
  void play({
    String? text,
    int delayMs = 0,
    int durationMs = 2400,
    IslandLoadingType type = IslandLoadingType.snow,
    bool showBoat = true,
  }) {
    timer?.cancel();
    setState(() {
      tip = text;
      delay = Duration(milliseconds: delayMs);
      this.type = type;
      this.showBoat = showBoat;
      active = true;
    });
    timer = Timer(Duration(milliseconds: durationMs), () {
      if (mounted) setState(() => active = false);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Widget button(String label, VoidCallback action) =>
      IslandButton(onPressed: action, child: Text(label));
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Loading',
    tags: ["全屏落雪", "圆形扩散展开", "渐变消失"],
    children: [
      const StoryLabel(
        "形态切换 — type='snow' 是全屏落雪，type='circle' 关闭时从中心圆形扩散展开，右下角有一艘随波逐流的帆船",
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          button('落雪型', () => play()),
          button('圆形展开型', () => play(type: IslandLoadingType.circle)),
          button(
            '圆形展开型 · 带提示文字',
            () => play(type: IslandLoadingType.circle, text: '正在驶向岛屿…'),
          ),
          button(
            '圆形展开型 · 不显示帆船',
            () => play(type: IslandLoadingType.circle, showBoat: false),
          ),
        ],
      ),
      const SizedBox(height: 20),
      const StoryLabel('基础播放 — 点击后全屏落雪覆盖 2.4s，结束时渐变消失'),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          button('纯落雪', () => play()),
          button('带提示文字', () => play(text: '正在连接岛屿…')),
          button('delay 300ms', () => play(text: '等雪停…', delayMs: 300)),
          button('fadeDuration 1.2s', () => play(text: '慢速渐隐')),
        ],
      ),
      const SizedBox(height: 20),
      const StoryLabel(
        'delay 防闪烁 — 快速结束时（600ms 模拟加载）无 delay 的落雪会闪一下，delay 300ms 的几乎不出现',
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          button(
            '模拟 600ms 加载（无 delay）',
            () => play(text: '无 delay', durationMs: 600),
          ),
          button(
            '模拟 600ms 加载（delay 300ms）',
            () => play(text: 'delay 300ms', delayMs: 300, durationMs: 600),
          ),
        ],
      ),
      const SizedBox(height: 20),
      const StoryCode("""// 全屏落雪（默认形态）
IslandLoading(active: active)

// 圆形扩散展开，右下角带一艘帆船
IslandLoading(
  active: active,
  type: IslandLoadingType.circle,
  tip: Text('正在驶向岛屿…'),
)

// 只要圆形展开，不要帆船
IslandLoading(
  active: active,
  type: IslandLoadingType.circle,
  showBoat: false,
)

// 中央提示文字
IslandLoading(active: active, tip: Text('正在连接岛屿…'))
IslandLoading(active: active, delay: Duration(milliseconds: 300))
IslandLoading(active: active, fadeDuration: Duration(milliseconds: 1200))"""),
      const StoryApi(
        rows: [
          (
            'type',
            '加载屏形态：snow 全屏落雪 / circle 圆形扩散展开',
            'IslandLoadingType',
            'snow',
          ),
          ('showBoat', 'circle 形态下是否显示帆船；false 时只留遮罩背景', 'bool', 'true'),
          ('active', '控制开启关闭；退出期间提示与底板不透明，继续阻挡背景操作', 'bool', 'true'),
          ('tip', '中央提示文字', 'Widget?', '—'),
          ('delay', '延迟显示，避免快速结束时闪烁', 'Duration', 'zero'),
          (
            'fadeDuration',
            '雪花装饰退出及整体移除时长；circle 下为圆形扩散展开的时长',
            'Duration',
            '600ms',
          ),
          ('semanticLabel', '辅助技术状态名称', 'String?', '本地化默认'),
        ],
      ),
      IslandLoading(
        type: type,
        showBoat: showBoat,
        active: active,
        tip: tip == null ? null : Text(tip!),
        delay: delay,
        fadeDuration: Duration(milliseconds: tip == '慢速渐隐' ? 1200 : 600),
      ),
    ],
  );
}
