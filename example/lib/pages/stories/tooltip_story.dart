import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TooltipStory extends StatelessWidget {
  const TooltipStory({super.key});
  Widget box(Widget child) => StoryDemoBox(child: child);
  Widget button(String label) => IslandButton(
    size: IslandSize.small,
    onPressed: () {},
    child: Text(label),
  );
  Widget sample(
    String label,
    String message, {
    IslandTooltipPlacement placement = IslandTooltipPlacement.top,
    IslandTooltipVariant variant = IslandTooltipVariant.normal,
    bool bordered = true,
    Widget? content,
  }) => IslandTooltip(
    message: message,
    placement: placement,
    variant: variant,
    bordered: bordered,
    content: content,
    child: button(label),
  );
  Widget direction(IslandTooltipPlacement p) {
    final label = p.name
        .replaceAll('Start', '-start')
        .replaceAll('End', '-end');
    return sample(
      label,
      p.index < 6 ? label : '$label\n箭头在${p.index < 9 ? '右' : '左'}侧\n指向触发按钮',
      placement: p,
    );
  }

  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Tooltip',
    tags: ["气泡提示"],
    children: [
      const StoryLabel('基础用法 — hover 触发'),
      box(
        Align(
          alignment: Alignment.centerLeft,
          child: IslandTooltip(
            message: '提示文字',
            child: IslandButton(
              size: IslandSize.small,
              variant: IslandButtonVariant.primary,
              onPressed: () {},
              child: const Text('Hover 我'),
            ),
          ),
        ),
      ),
      const StoryLabel('风格 — island 不规则气泡'),
      box(
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            sample('default', '标准矩形气泡'),
            sample('default 无边框', '无边框矩形', bordered: false),
            sample(
              'island 有边框',
              '钓到石头了！\n竟然连这种都能钓起来…',
              variant: IslandTooltipVariant.island,
              content: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '钓到'),
                    TextSpan(
                      text: '石头',
                      style: TextStyle(color: Color(0xffd4834a)),
                    ),
                    TextSpan(text: '了！\n竟然连这种都能钓起来…'),
                  ],
                ),
              ),
            ),
            sample(
              'island 无边框',
              '无边框有机气泡\n圆点指示方向',
              variant: IslandTooltipVariant.island,
              bordered: false,
            ),
          ],
        ),
      ),
      const StoryLabel('12 个方向'),
      box(
        LayoutBuilder(
          builder: (_, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      direction(IslandTooltipPlacement.topStart),
                      direction(IslandTooltipPlacement.top),
                      direction(IslandTooltipPlacement.topEnd),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 48,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          direction(IslandTooltipPlacement.leftStart),
                          direction(IslandTooltipPlacement.left),
                          direction(IslandTooltipPlacement.leftEnd),
                        ],
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xfff0e8d8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '12\nplacements',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: IslandTokens.light.muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        spacing: 12,
                        children: [
                          direction(IslandTooltipPlacement.rightStart),
                          direction(IslandTooltipPlacement.right),
                          direction(IslandTooltipPlacement.rightEnd),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      direction(IslandTooltipPlacement.bottomStart),
                      direction(IslandTooltipPlacement.bottom),
                      direction(IslandTooltipPlacement.bottomEnd),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      const StoryLabel('触发方式 — click'),
      box(
        Align(
          alignment: Alignment.centerLeft,
          child: IslandTooltip.click(
            message: '点击触发，再点关闭',
            placement: IslandTooltipPlacement.bottom,
            builder: (context, toggle) => IslandButton(
              size: IslandSize.small,
              onPressed: toggle,
              child: const Text('Click 触发'),
            ),
          ),
        ),
      ),
      const StoryLabel('触发方式 — focus'),
      box(
        Align(
          alignment: Alignment.centerLeft,
          child: IslandTooltip(
            message: '聚焦时显示',
            trigger: IslandTooltipTrigger.focus,
            placement: IslandTooltipPlacement.right,
            child: SizedBox(
              width: 194,
              height: 40,
              child: TextField(
                style: const TextStyle(fontSize: 14, color: Color(0xff725d42)),
                decoration: InputDecoration(
                  visualDensity: VisualDensity.standard,
                  constraints: const BoxConstraints(minHeight: 40),
                  hintText: '点击输入框聚焦',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xfff7f3df),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Color(0xffc4b89e),
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Color(0xffc4b89e),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      const StoryLabel('多行内容', strutStyle: storyCaptionStrut),
      box(
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            sample('多行 JSX', '第一行文字\n第二行文字\n第三行文字'),
            sample(r'换行符 \n', '第一行\n第二行\n第三行'),
            sample(
              '自动换行长文本',
              '这是一段比较长的提示文字，用来测试 Tooltip 的自动换行效果。当文字超过最大宽度时会自动换行。',
            ),
          ],
        ),
      ),
      const StoryCode("""IslandTooltip(
  message: '提示文字',
  child: IslandButton(onPressed: action, child: Text('Hover 我')),
)
IslandTooltip.click(
  message: '点击触发',
  builder: (context, toggle) => IslandButton(
    onPressed: toggle, child: Text('Click'),
  ),
)
IslandTooltip(
  message: '聚焦时显示',
  trigger: IslandTooltipTrigger.focus,
  placement: IslandTooltipPlacement.right,
  child: TextField(),
)"""),
      const StoryApi(
        rows: [
          ('message *', '辅助技术提示文本；默认显示内容', 'String', '—'),
          ('content', '可选的富文本展示插槽', 'Widget?', 'null'),
          ('placement', '十二个方向；只在越界时约束实际弹层', 'IslandTooltipPlacement', 'top'),
          ('trigger', '悬停或聚焦；点击使用 .click', 'IslandTooltipTrigger', 'hover'),
          ('variant', '矩形 / 有机气泡', 'IslandTooltipVariant', 'normal'),
          ('bordered', '气泡和箭头边框', 'bool', 'true'),
          ('child', '保留自身事件和焦点的触发元素', 'Widget', '—'),
          (
            'builder',
            '.click：显式组合 toggle 和子元素事件',
            'Widget Function(BuildContext, VoidCallback)',
            '—',
          ),
        ],
      ),
    ],
  );
}
