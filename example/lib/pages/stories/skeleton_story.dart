import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class SkeletonStory extends StatefulWidget {
  const SkeletonStory({super.key});
  @override
  State<SkeletonStory> createState() => _SkeletonStoryState();
}

class _SkeletonStoryState extends State<SkeletonStory> {
  bool loading = true;
  Widget card(BuildContext context, String label, Widget child) => Container(
    width: 240,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xfffafaf5),
      border: Border.all(
        color: const Color(0xffe8dcc8),
        width: IslandTheme.borderWidth(context, 1.5),
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          strutStyle: const StrutStyle(
            fontSize: 13,
            height: 18 / 13,
            forceStrutHeight: true,
          ),
          style: TextStyle(
            fontSize: 13,
            height: 18 / 13,
            fontWeight: FontWeight.w600,
            color: IslandTokens.light.muted,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Skeleton',
    tags: ["骨架屏", "加载占位"],
    children: [
      const StoryLabel('loading 切换'),
      Row(
        children: [
          IslandSwitch(
            label: 'loading',
            showLabel: false,
            value: loading,
            onChanged: (v) => setState(() => loading = v),
          ),
          const SizedBox(width: 12),
          Text(loading ? '加载中' : '已加载', style: const TextStyle(fontSize: 13)),
        ],
      ),
      const SizedBox(height: 16),
      const StoryLabel('variant — 四种变体'),
      Wrap(
        spacing: 32,
        runSpacing: 32,
        children: [
          card(
            context,
            'text',
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IslandSkeleton(loading: loading),
                FractionallySizedBox(
                  widthFactor: .8,
                  child: IslandSkeleton(loading: loading),
                ),
                FractionallySizedBox(
                  widthFactor: .6,
                  child: IslandSkeleton(loading: loading),
                ),
              ],
            ),
          ),
          card(
            context,
            'circle',
            IslandSkeleton(
              loading: loading,
              variant: IslandSkeletonVariant.circle,
              width: 56,
            ),
          ),
          card(
            context,
            'rect',
            IslandSkeleton(
              loading: loading,
              variant: IslandSkeletonVariant.rect,
              width: 200,
              height: 120,
            ),
          ),
          card(
            context,
            'paragraph',
            IslandSkeleton(
              loading: loading,
              variant: IslandSkeletonVariant.paragraph,
              rows: 4,
            ),
          ),
        ],
      ),
      const StoryLabel(
        'Skeleton.Button / Skeleton.Input / Skeleton.Avatar',
        lineHeight: 20 / 14,
      ),
      Wrap(
        spacing: 32,
        runSpacing: 32,
        children: [
          card(
            context,
            'Button',
            loading
                ? const IslandSkeletonButton()
                : IslandButton(onPressed: () {}, child: const Text('加载完成')),
          ),
          card(
            context,
            'Input',
            loading ? const IslandSkeletonInput() : const Text('输入框已加载'),
          ),
          card(
            context,
            'Avatar',
            loading
                ? const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      IslandSkeletonAvatar(size: IslandSize.small),
                      IslandSkeletonAvatar(),
                      IslandSkeletonAvatar(size: IslandSize.large),
                    ],
                  )
                : const Text('头像已加载'),
          ),
        ],
      ),
      const StoryLabel('loading=false 时直接渲染 children'),
      IslandSkeleton(
        loading: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffe6f9f6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '内容已加载，骨架屏自动隐藏',
            strutStyle: const StrutStyle(
              fontSize: 16,
              height: 25 / 16,
              forceStrutHeight: true,
            ),
            style: TextStyle(
              fontSize: 16,
              height: 25 / 16,
              color: IslandTokens.light.link,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      const StoryCode(
        'IslandSkeleton(loading: loading, child: content)\nconst IslandSkeleton(variant: IslandSkeletonVariant.paragraph, rows: 4)\nconst IslandSkeletonButton()',
      ),
      const StoryApi(
        rows: [
          ('loading', '显示占位；有 child 时可切换', 'bool', 'true'),
          ('variant', '四种变体', 'IslandSkeletonVariant', 'text'),
          ('active', '流光动画，遵循减少动态效果设置', 'bool', 'true'),
          ('width / height / radius', '显式尺寸与圆角', 'double?', 'null'),
          ('rows', '段落行数', 'int', '3'),
          ('rowWidths', '各行宽度比例', 'List<double>?', '1/.92/.84/.76/.68'),
          ('child', '加载后内容，不改写子组件', 'Widget?', 'null'),
        ],
      ),
    ],
  );
}
