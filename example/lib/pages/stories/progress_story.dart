import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

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
                style: TextStyle(fontSize: 13, color: Color(0xff725d42)),
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xff725d42),
                  thumbColor: const Color(0xff725d42),
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  value: percent,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (v) => setState(() => percent = v),
                ),
              ),
            ),
            SizedBox(
              width: 48,
              child: Text(
                '${percent.round()}%',
                textAlign: TextAlign.right,
                style: TextStyle(
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
      const StoryApi(
        rows: [
          ('percent', '当前百分比，自动限制到 0–100', 'double', 'required'),
          ('label', '辅助技术标签', 'String', 'required'),
          ('size', '尺寸', 'IslandSize', 'middle'),
          ('showInfo', '右侧显示进度文案', 'bool', 'true'),
          ('scene', '从左揭开的场景图', 'IslandScene?', 'null'),
          ('infoBuilder / semanticValue', '显示内容 / 读屏值', 'callbacks', 'null'),
          ('duration', '宽度过渡时长', 'Duration', '600ms'),
        ],
      ),
    ],
  );
}
