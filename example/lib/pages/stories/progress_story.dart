import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import '../../shared/palette.dart';

class ProgressStory extends StatefulWidget {
  const ProgressStory({super.key});
  @override
  State<ProgressStory> createState() => _ProgressStoryState();
}

class _ProgressStoryState extends State<ProgressStory> {
  double percent = 45, upload = 0, experience = 72;
  bool uploading = false;
  Timer? timer, finish;
  @override
  void dispose() {
    timer?.cancel();
    finish?.cancel();
    super.dispose();
  }

  void start() {
    timer?.cancel();
    finish?.cancel();
    setState(() {
      upload = 0;
      uploading = true;
    });
    timer = Timer.periodic(const Duration(milliseconds: 220), (timer) {
      setState(() => upload = (upload + 5).clamp(0, 100));
      if (upload >= 100) {
        timer.cancel();
        finish = Timer(
          const Duration(milliseconds: 600),
          () => setState(() => uploading = false),
        );
      }
    });
  }

  Widget bars(List<Widget> children) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 720),
    child: Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i != 0) const SizedBox(height: 14),
          children[i],
        ],
      ],
    ),
  );
  Widget caption(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: IslandTokens.light.muted,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Progress',
    tags: ["进度条", "场景图"],
    children: [
      const StoryLabel('经典场景 — 上传 / 经验 / 任务', strutStyle: storyCaptionStrut),
      bars([
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            caption('岛屿截图上传'),
            IslandProgress(
              percent: upload,
              label: '岛屿截图上传',
              infoBuilder: (v) => Text(v >= 100 ? '上传完成 ✓' : '${v.round()}%'),
            ),
            const SizedBox(height: 8),
            IslandButton(
              size: IslandSize.small,
              variant: IslandButtonVariant.primary,
              onPressed: uploading ? null : start,
              child: Text(uploading ? '上传中…' : '开始上传'),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            caption('岛屿评价经验'),
            IslandProgress(
              percent: experience,
              label: '岛屿评价经验',
              infoBuilder: (v) => Text('${(v * 50).round()} / 5000 星'),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                IslandButton(
                  child: const Text('−10'),
                  size: IslandSize.small,
                  onPressed: () => setState(
                    () => experience = (experience - 10).clamp(0, 100),
                  ),
                ),
                IslandButton(
                  child: const Text('+10'),
                  size: IslandSize.small,
                  onPressed: () => setState(
                    () => experience = (experience + 10).clamp(0, 100),
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            caption('今日 DIY 任务'),
            IslandProgress(
              percent: 6,
              label: '今日 DIY 任务',
              infoBuilder: (v) => Text('${(v / 10).round()} / 10'),
            ),
          ],
        ),
      ]),
      const StoryLabel('基础用法', strutStyle: storyCaptionStrut),
      bars([
        for (final value in [25.0, 50.0, 100.0])
          IslandProgress(percent: value, label: '基础进度'),
      ]),
      const StoryLabel('size — 三档尺寸'),
      bars([
        for (final size in IslandSize.values)
          IslandProgress(percent: 50, label: '尺寸', size: size),
      ]),
      const StoryLabel('variant — fill 背景场景图（当前进度区域显示场景，从左揭开）'),
      bars([
        for (final scene in IslandScene.values)
          IslandProgress(percent: 70, label: scene.assetName, scene: scene),
      ]),
      const StoryLabel('受控 — 滑块驱动 percent (0–100,自动 clamp)'),
      SizedBox(
        height: 22,
        child: Row(
          spacing: 12,
          children: [
            const SizedBox(
              width: 56,
              child: Text(
                'percent:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: GalleryPalette.storyInk,
                ),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: GalleryPalette.storyInk,
                  thumbColor: GalleryPalette.storyInk,
                  // Native range input: no tick marks, ~16px thumb.
                  tickMarkShape: SliderTickMarkShape.noTickMark,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  value: percent,
                  min: 0,
                  max: 100,
                  // Integer steps like the reference parseInt(range.value).
                  onChanged: (v) => setState(() => percent = v.roundToDouble()),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${percent.round()}%',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 16,
                  height: 22 / 16,
                  color: IslandTokens.light.link,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      IslandProgress(percent: percent, label: '受控进度'),
      const StoryLabel('duration=0 — 关闭 fill 宽度动画'),
      IslandProgress(percent: percent, label: '静态进度', duration: Duration.zero),
      const StoryLabel('showInfo=false — 只渲染条,不带文字'),
      bars([
        const IslandProgress(percent: 66, label: '无可见文字的进度', showInfo: false),
      ]),
      const StoryCode(
        "IslandProgress(\n  percent: percent,\n  label: '上传进度',\n  scene: IslandScene.forestGrove,\n)\nIslandProgress(\n  percent: 50,\n  label: '任务进度',\n  infoBuilder: (p) => Text('\${(p / 10).round()} / 10'),\n)",
      ),
      const _ProgressAppearanceDemo(),
      const StoryApi(
        rows: [
          ('percent', '当前百分比，自动限制到 0–100', 'double', 'required'),
          ('label', '辅助技术标签', 'String', 'required'),
          ('size', '尺寸', 'IslandSize', 'middle'),
          ('showInfo', '右侧显示进度文案', 'bool', 'true'),
          ('color', '填充颜色，保留高光；scene 优先', 'Color?', '薄荷渐变'),
          ('wave', '叠加双层海浪，可与颜色或场景图组合', 'bool', 'false'),
          ('animated', '海浪动画；0% / 100% 自动静止', 'bool', 'true'),
          ('scene', '从左揭开的场景图，优先于 color', 'IslandScene?', 'null'),
          ('infoBuilder / semanticValue', '显示内容 / 读屏值', 'callbacks', 'null'),
          ('duration', '宽度过渡时长；海浪由 animated 控制', 'Duration', '600ms'),
        ],
      ),
    ],
  );
}

/// Separate colour and wave example with its own percent, so the start,
/// middle and complete states can be compared independently.
class _ProgressAppearanceDemo extends StatefulWidget {
  const _ProgressAppearanceDemo();
  @override
  State<_ProgressAppearanceDemo> createState() =>
      _ProgressAppearanceDemoState();
}

class _ProgressAppearanceDemoState extends State<_ProgressAppearanceDemo> {
  double percent = 45;
  bool animated = true;
  Widget column(List<Widget> children) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 720),
    child: Column(spacing: 14, children: children),
  );
  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: '新增颜色与海浪进度演示',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '新增示例：进度配色与海浪',
          strutStyle: StrutStyle(
            fontSize: 18,
            height: 1.5,
            forceStrutHeight: true,
          ),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: GalleryPalette.storyInk,
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final value in [0.0, 45.0, 100.0])
              IslandButton(
                size: IslandSize.small,
                onPressed: () => setState(() => percent = value),
                child: Text('${value.round()}%'),
              ),
            IslandButton(
              size: IslandSize.small,
              onPressed: () => setState(() => animated = !animated),
              child: Text(animated ? '暂停海浪' : '播放海浪'),
            ),
          ],
        ),
        const StoryLabel('自定义颜色，完成后保持原色'),
        column([
          for (final (colorway, label) in [
            (IslandColorway.orange, '蜜桃色进度'),
            (IslandColorway.green, '草绿色进度'),
            (IslandColorway.purple, '紫色进度'),
          ])
            IslandProgress(
              percent: percent,
              color: colorway.accent,
              label: label,
            ),
        ]),
        const StoryLabel('海浪三档尺寸，0% / 100% 自动静止'),
        column([
          IslandProgress(
            percent: percent,
            wave: true,
            animated: animated,
            size: IslandSize.small,
            label: '小号海浪进度',
          ),
          IslandProgress(
            percent: percent,
            wave: true,
            animated: animated,
            label: '海浪进度',
          ),
          IslandProgress(
            percent: percent,
            wave: true,
            animated: animated,
            size: IslandSize.large,
            color: IslandColorway.teal.accent,
            label: '大号海浪进度',
          ),
        ]),
        const StoryCode(
          "IslandProgress(\n"
          "  percent: 45,\n"
          "  color: IslandColorway.teal.accent,\n"
          "  wave: true,\n"
          "  label: '薄荷色海浪进度',\n"
          ")\n"
          "IslandProgress(\n"
          "  percent: 45,\n"
          "  wave: true,\n"
          "  animated: false,\n"
          "  label: '静态海浪进度',\n"
          ")",
        ),
      ],
    ),
  );
}
