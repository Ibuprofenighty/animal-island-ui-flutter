import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class ModalStory extends StatelessWidget {
  const ModalStory({super.key});
  @override
  Widget build(BuildContext context) {
    void open({
      String? title,
      String? text,
      bool play = true,
      Color barrier = const Color(0x59000000),
      bool custom = false,
    }) {
      showIslandModal<void>(
        context: context,
        title: title == null
            ? null
            : Builder(
                builder: (context) =>
                    Text(title, strutStyle: storyTextStrut(context)),
              ),
        semanticLabel: title,
        barrierColor: barrier,
        actions: custom
            ? (ctx) => [
                IslandButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('再想想'),
                ),
                IslandButton(
                  variant: IslandButtonVariant.primary,
                  danger: true,
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('确认搬家'),
                ),
              ]
            : null,
        builder: (_) => text == null
            ? const _FishingCopy()
            : IslandTypewriter.builder(
                text,
                builder: (context, shown) => shown.isEmpty
                    ? const SizedBox.shrink()
                    : Text(shown, strutStyle: storyTextStrut(context)),
                play: play,
                speed: const Duration(milliseconds: 80),
              ),
      );
    }

    return StoryPanel(
      title: 'Modal',
      tags: ["弹窗"],
      children: [
        const StoryLabel('异形弹窗 (game)', strutStyle: _labelMetrics),
        primary('异形 Modal', action: () => open()),
        const StoryLabel('基础弹窗', strutStyle: _labelMetrics),
        storyRow([
          primary('基础 Modal', action: () => open()),
          IslandButton(
            onPressed: () => open(
              title: '博物馆捐赠',
              text: '是否愿意将这条鱼捐赠给博物馆呢？海獭馆长会好好照顾它的！这可是博物馆的新展品哦~',
            ),
            child: const Text('带标题 Modal'),
          ),
          IslandButton(
            variant: IslandButtonVariant.dashed,
            onPressed: () => open(
              title: '确认操作',
              text: '确定要让这位居民搬走吗？这个操作不可撤销。',
              custom: true,
            ),
            child: const Text('自定义 Footer'),
          ),
        ]),
        const StoryLabel('关闭打字机效果', strutStyle: _labelMetrics),
        primary(
          '关闭打字机效果',
          action: () => open(
            play: false,
            title: '天气预报',
            text: '明天天气晴朗，气温 20-28°C，适合外出活动！',
          ),
        ),
        const StoryLabel('自定义遮罩样式', strutStyle: _labelMetrics),
        storyRow([
          primary(
            '浅色遮罩',
            action: () => open(
              title: '浅色遮罩',
              text: '这是一个浅色遮罩的弹窗，遮罩几乎透明。',
              barrier: const Color(0x14000000),
            ),
          ),
          primary(
            '深色遮罩',
            action: () => open(
              title: '深色遮罩',
              text: '这是一个深色遮罩的弹窗，背景更暗、聚焦感更强。',
              barrier: const Color(0xbf000000),
            ),
          ),
        ]),
        const StoryCode(r"""import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void openModal(BuildContext context) {
  showIslandModal<void>(
    context: context,
    builder: (_) => const IslandTypewriter(
      'Modal 内容', speed: Duration(milliseconds: 80),
    ),
  );
}

// 异形弹窗（默认 game）
void openGame(BuildContext context) {
  showIslandModal<void>(
    context: context,
    variant: IslandModalVariant.game,
    builder: (_) => const Text('异形弹窗内容'),
  );
}

// 带标题、自定义 Footer
void openConfirmation(BuildContext context) {
  showIslandModal<void>(
    context: context,
    title: const Text('确认'),
    semanticLabel: '确认',
    actions: (dialogContext) => [
      IslandButton(
        onPressed: () => Navigator.of(dialogContext).pop(),
        child: const Text('自定义按钮'),
      ),
    ],
    builder: (_) => const Text('内容'),
  );
}

// 无 Footer、关闭打字机效果、自定义遮罩
void openPlain(BuildContext context) {
  showIslandModal<void>(
    context: context,
    actions: (_) => [],
    barrierColor: const Color(0x14000000),
    builder: (_) => const Text('直接显示全部内容'),
  );
}"""),

        const StoryApi(
          rows: [
            (
              "child / title / actions",
              "正文、标题与底部操作",
              "Widget / Widget? / List<Widget>",
              "required / null / []",
            ),
            ("variant", "游戏异形或普通圆角", "IslandModalVariant", "game"),
            ("width", "弹窗目标宽度", "double", "520"),
            ("semanticLabel", "对话框无障碍名称", "String?", "null"),
            ("onClose", "Esc 关闭意图回调", "VoidCallback?", "null"),
            ("showIslandModal", "路由、遮罩与焦点循环", "Future<T?>", "—"),
            (
              "IslandDialogRoute",
              "自有提示/预览的共享不透明位移路由",
              "DialogRoute<T>",
              "根Navigator",
            ),
            (
              "dismissible / barrierColor",
              "遮罩关闭与颜色",
              "bool / Color",
              "true / #59000000",
            ),
          ],
        ),
      ],
    );
  }
}

// The story owns copy/line composition; the public Typewriter owns one timeline.
class _FishingCopy extends StatelessWidget {
  const _FishingCopy();
  @override
  Widget build(BuildContext context) => IslandTypewriter.builder(
    '钓到石头了!竟然连这种都能钓起来...',
    speed: const Duration(milliseconds: 80),
    builder: (context, shown) {
      final first = shown.characters.take(6).toString();
      final second = shown.characters.skip(6).toString();
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (first.isNotEmpty)
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: first.characters.take(2).toString()),
                  TextSpan(
                    text: first.characters.skip(2).take(2).toString(),
                    style: TextStyle(color: IslandTokens.light.warning),
                  ),
                  TextSpan(text: first.characters.skip(4).toString()),
                ],
              ),
              strutStyle: storyTextStrut(context),
              textAlign: TextAlign.center,
            ),
          if (shown.characters.length >= 6) const SizedBox(height: 8),
          if (second.isNotEmpty)
            Text(
              second,
              strutStyle: storyTextStrut(context),
              textAlign: TextAlign.center,
            ),
        ],
      );
    },
  );
}

const _labelMetrics = StrutStyle(
  fontSize: 14,
  height: 1.5,
  forceStrutHeight: true,
);
