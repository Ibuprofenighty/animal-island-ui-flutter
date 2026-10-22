import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class RateStory extends StatefulWidget {
  const RateStory({super.key});
  @override
  State<RateStory> createState() => _RateStoryState();
}

class _RateStoryState extends State<RateStory> {
  int score = 3, clearable = 4, countScore = 7;
  static const descriptions = ['还没有评分', '不太满意', '一般般', '还不错', '很满意', '超级喜欢！'];

  Widget caption(String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text.rich(
      strutStyle: const StrutStyle(
        fontSize: 13,
        height: 20 / 13,
        forceStrutHeight: true,
      ),
      TextSpan(
        text: '当前评分：',
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              color: IslandTokens.light.link,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      style: TextStyle(fontSize: 13, color: IslandTokens.light.muted),
    ),
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Rate',
    tags: ["评分"],
    children: [
      const StoryLabel('基础用法（受控）— 点击星星评分', strutStyle: storyCaptionStrut),
      caption(descriptions[score]),
      StoryDemoBox(
        margin: const EdgeInsets.only(top: 4),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: IslandRate(
            value: score,
            onChanged: (v) => setState(() => score = v),
            size: IslandSize.large,
            semanticLabel: '岛屿满意度',
          ),
        ),
      ),
      const StoryLabel(
        '悬停预览 + 再次点击清空（allowClear 默认开启）',
        strutStyle: storyCaptionStrut,
      ),
      caption('$clearable 星'),
      StoryDemoBox(
        margin: const EdgeInsets.only(top: 4),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: IslandRate(
            value: clearable,
            onChanged: (v) => setState(() => clearable = v),
            size: IslandSize.large,
          ),
        ),
      ),
      const StoryLabel('allowClear=false — 再次点击同一颗星不清空'),
      const StoryDemoBox(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.only(bottom: 6),
          child: IslandRate(
            initialValue: 3,
            allowClear: false,
            size: IslandSize.large,
          ),
        ),
      ),
      const StoryLabel('三种尺寸', strutStyle: storyCaptionStrut),
      const StoryDemoBox(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            IslandRate(initialValue: 5, size: IslandSize.small),
            IslandRate(initialValue: 4),
            IslandRate(initialValue: 3, size: IslandSize.large),
          ],
        ),
      ),
      const StoryLabel('自定义星星数量（count=10）', strutStyle: storyCaptionStrut),
      caption('$countScore / 10'),
      StoryDemoBox(
        margin: const EdgeInsets.only(top: 4),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: IslandRate(
            count: 10,
            value: countScore,
            onChanged: (v) => setState(() => countScore = v),
          ),
        ),
      ),
      const StoryLabel('只读 — 用于展示已有评分，不响应点击与悬停', strutStyle: storyCaptionStrut),
      const StoryDemoBox(
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 14,
          children: [
            IslandRate(
              initialValue: 5,
              readOnly: true,
              semanticLabel: '海岛驿站评分',
            ),
            IslandRate(
              initialValue: 3,
              readOnly: true,
              size: IslandSize.small,
              semanticLabel: '椰子摊评分',
            ),
            IslandRate(
              initialValue: 2,
              readOnly: true,
              size: IslandSize.large,
              semanticLabel: '沙滩躺椅评分',
            ),
          ],
        ),
      ),
      const StoryCode(
        'IslandRate(value: score, onChanged: (value) => setState(() => score = value))\nconst IslandRate(initialValue: 4, size: IslandSize.large)',
      ),
      const StoryApi(
        rows: [
          ('value', '受控评分，父级决定是否提交', 'int?', 'null'),
          ('initialValue', '非受控初值', 'int', '0'),
          ('count', '星星总数', 'int', '5'),
          ('size', '尺寸', 'IslandSize', 'middle'),
          ('readOnly', '只读展示', 'bool', 'false'),
          ('allowClear', '再次激活当前值清空', 'bool', 'true'),
          ('semanticLabel', '评分区域名称', 'String', '评分'),
          ('onChanged', '变化请求', 'ValueChanged<int>?', 'null'),
        ],
      ),
    ],
  );
}
