import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class DrawerStory extends StatefulWidget {
  const DrawerStory({super.key});
  @override
  State<DrawerStory> createState() => _DrawerStoryState();
}

class _DrawerStoryState extends State<DrawerStory> {
  int? opened;
  void close() => setState(() => opened = null);
  Widget heading(String value) => Builder(
    builder: (context) => Text(value, strutStyle: storyTextStrut(context)),
  );
  Widget paragraph(String first, [String? second]) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 20),
      Text(first),
      const SizedBox(height: 20),
      if (second != null) ...[Text(second), const SizedBox(height: 20)],
    ],
  );
  @override
  Widget build(BuildContext context) => Column(
    children: [
      StoryPanel(
        title: 'Drawer',
        tags: ["下沉景深抽屉"],
        children: [
          const StoryLabel('四个方向', strutStyle: storyCaptionStrut),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final entry in ['右侧抽屉', '左侧抽屉', '顶部抽屉', '底部抽屉'].indexed)
                IslandButton(
                  variant: IslandButtonVariant.primary,
                  onPressed: () => setState(() => opened = entry.$1),
                  child: Text(entry.$2),
                ),
            ],
          ),
          const StoryLabel('关闭景深', strutStyle: storyCaptionStrut),
          IslandButton(
            variant: IslandButtonVariant.primary,
            onPressed: () => setState(() => opened = 4),
            child: const Text('关闭景深'),
          ),
          const StoryCode("""IslandDrawerHost(
  child: page, // Owns only this background, below Navigator's Overlay.
)
// Inside the host's page:
IslandDrawer(
  open: open,
  title: Text('岛屿设置'),
  semanticLabel: '岛屿设置',
  onClose: () => setState(() => open = false),
  child: Text('背景会下沉，突出抽屉主体。'),
)"""),
          const StoryApi(
            rows: [
              ('open *', '父级控制是否可见', 'bool', '—'),
              ('title', '标题插槽', 'Widget?', 'null'),
              ('closeLabel', '标题栏关闭按钮名称', 'String', '关闭'),
              ('semanticLabel', '独立的对话框语义名称', 'String?', 'null'),
              ('placement', '四个方向', 'IslandDrawerPlacement', 'right'),
              ('width', '左右抽屉宽度', 'double', '378'),
              ('height', '上下抽屉高度', 'double', '300'),
              ('maskClosable', '点击遮罩请求关闭', 'bool', 'true'),
              ('pushBackground', '背景下沉景深', 'bool', 'true'),
              ('footer', '独立底部插槽', 'Widget?', 'null'),
              ('onClose *', '请求关闭；父级提交状态', 'VoidCallback?', '—'),
              ('child *', '保留状态的正文', 'Widget', '—'),
              ('IslandDrawerHost', '明确拥有背景的宿主', 'Widget', '必需'),
            ],
          ),
        ],
      ),
      IslandDrawer(
        open: opened == 0,
        onClose: close,
        semanticLabel: '岛屿设置',
        title: heading('岛屿设置'),
        child: paragraph(
          '打开时背景内容会下沉并降亮，突出抽屉主体，形成景深层次。',
          '适合放置设置项、详情面板等较长的辅助内容。',
        ),
      ),
      IslandDrawer(
        open: opened == 1,
        onClose: close,
        semanticLabel: '居民名单',
        title: heading('居民名单'),
        placement: IslandDrawerPlacement.left,
        footer: Wrap(
          spacing: 12,
          children: [
            IslandButton(onPressed: close, child: const Text('取消')),
            IslandButton(onPressed: close, child: const Text('确定')),
          ],
        ),
        child: paragraph('左侧滑入的抽屉，背景同样下沉。可放置导航或筛选条件。'),
      ),
      IslandDrawer(
        open: opened == 2,
        onClose: close,
        semanticLabel: '通知公告',
        title: heading('通知公告'),
        placement: IslandDrawerPlacement.top,
        child: paragraph('从顶部下滑的抽屉，适合放置通知、公告或全局提示。'),
      ),
      IslandDrawer(
        open: opened == 3,
        onClose: close,
        semanticLabel: '快捷操作',
        title: heading('快捷操作'),
        placement: IslandDrawerPlacement.bottom,
        child: paragraph('从底部弹出的抽屉，适合放置快捷操作菜单。'),
      ),
      IslandDrawer(
        open: opened == 4,
        onClose: close,
        semanticLabel: '无景深',
        title: heading('无景深'),
        pushBackground: false,
        child: paragraph('pushBackground={false} 时退化为普通遮罩抽屉，背景不下沉。'),
      ),
    ],
  );
}
