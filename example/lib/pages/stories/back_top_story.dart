import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import 'residents.dart';

class BackTopStory extends StatefulWidget {
  const BackTopStory({super.key});
  @override
  State<BackTopStory> createState() => _BackTopStoryState();
}

class _BackTopStoryState extends State<BackTopStory> {
  Timer? initialScroll;
  @override
  void initState() {
    super.initState();
    initialScroll = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final controller = PrimaryScrollController.maybeOf(context);
      if (controller == null || !controller.hasClients) return;
      if (MediaQuery.disableAnimationsOf(context)) {
        controller.jumpTo(controller.position.maxScrollExtent);
      } else {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    initialScroll?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'BackTop',
    tags: ["返回顶部", "上箭头"],
    children: [
      Text(
        '页面已自动滚动到底部，点击右下角的上箭头返回顶部。',
        style: TextStyle(
          fontSize: 14,
          height: 1.6,
          color: IslandTokens.light.muted,
        ),
      ),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xfff0e8d8),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'visibilityHeight=400',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Text(
            ' 意味着滚动超过 400px 后图标出现。',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: IslandTokens.light.muted,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      const StoryLabel('动物岛民列表 — 共 50 位'),
      for (var i = 0; i < residents.length; i++) ...[
        if (i > 0) const SizedBox(height: 12),
        IslandCard(
          pattern: IslandColorway.values[i % IslandColorway.values.length],
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0x73ffffff),
                ),
                child: Text(
                  residents[i].$2[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff725d42),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          residents[i].$1,
                          strutStyle: const StrutStyle(
                            fontSize: 15,
                            height: 22 / 15,
                            forceStrutHeight: true,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 1,
                            horizontal: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x59ffffff),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${residents[i].$3} · ${residents[i].$4}',
                            strutStyle: const StrutStyle(
                              fontSize: 11,
                              height: 17 / 11,
                              forceStrutHeight: true,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      residents[i].$5,
                      strutStyle: const StrutStyle(
                        fontSize: 13,
                        height: 20 / 13,
                        forceStrutHeight: true,
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
      const IslandBackTop(),
      const StoryCode("""// Uses the nearest PrimaryScrollController.
IslandBackTop(visibilityHeight: 400)
IslandBackTop(duration: Duration(milliseconds: 800))

// Explicit borrowed scroll container.
IslandBackTop(controller: scrollController, visibilityHeight: 200)"""),
      const StoryApi(
        rows: [
          ('visibilityHeight', '滚动多少 px 后显示', 'double', '400'),
          (
            'controller',
            '借用滚动容器；只连接一个视口',
            'ScrollController?',
            'PrimaryScrollController',
          ),
          ('focusNode', '借用按钮焦点节点', 'FocusNode?', 'null'),
          ('duration', '滚动动画时长', 'Duration', '300ms'),
          ('onPressed', '点击回调', 'VoidCallback?', '—'),
          ('right / bottom', '相对当前 Overlay 的位置', 'double', '24 / 32'),
          ('semanticLabel', '按钮辅助技术名称', 'String', '返回顶部'),
        ],
      ),
    ],
  );
}
