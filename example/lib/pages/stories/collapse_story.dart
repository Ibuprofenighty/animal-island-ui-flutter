import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class CollapseStory extends StatelessWidget {
  const CollapseStory({super.key});
  Widget limited(Widget child) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 720),
    child: child,
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Collapse',
    tags: ["FAQ"],
    children: [
      const StoryLabel(
        '基础用法',
        strutStyle: StrutStyle(
          fontSize: 14,
          height: 1.5,
          forceStrutHeight: true,
        ),
      ),
      limited(
        const Column(
          children: [
            IslandCollapse.uncontrolled(
              question: StoryText('1個島嶼可以登錄多少名用戶?'),
              answer: StoryText('1座島嶼最多可以容納8位居民（用戶）。'),
            ),
            IslandCollapse.uncontrolled(
              question: StoryText('可以多少人一起玩?'),
              answer: StoryText('同住1個島的居民可以最多4人一起遊玩。透過通訊最多8人一起遊玩。'),
            ),
          ],
        ),
      ),
      const StoryLabel('defaultExpanded 默认展开'),
      limited(
        const IslandCollapse.uncontrolled(
          question: StoryText('这个问题默认展开'),
          answer: StoryText('答案已经展示出来了！可以点击收起。'),
          initialExpanded: true,
        ),
      ),
      const StoryLabel('disabled 禁用状态'),
      limited(
        const IslandCollapse.uncontrolled(
          question: StoryText('这个问题已被禁用（无法展开）'),
          answer: StoryText('这段文字不应该被看到。'),
          disabled: true,
        ),
      ),
      const StoryCode("""IslandCollapse.uncontrolled(
  question: Text('问题'),
  answer: Text('回答内容'),
)
IslandCollapse.uncontrolled(
  question: Text('默认展开'),
  answer: Text('答案'),
  initialExpanded: true,
)
IslandCollapse.uncontrolled(
  question: Text('禁用'),
  answer: Text('答案'),
  disabled: true,
)"""),
      const StoryApi(
        rows: [
          ('question *', '问题标题', 'Widget', '—'),
          ('answer *', '答案内容', 'Widget', '—'),
          ('initialExpanded', '非受控初始展开', 'bool', 'false'),
          ('expanded', '受控展开状态', 'bool', '—'),
          ('onExpandedChanged', '请求展开状态变化', 'ValueChanged<bool>?', '—'),
          ('disabled', '是否禁用', 'bool', 'false'),
          ('focusNode', '借用标题焦点节点', 'FocusNode?', '—'),
        ],
      ),
    ],
  );
}
