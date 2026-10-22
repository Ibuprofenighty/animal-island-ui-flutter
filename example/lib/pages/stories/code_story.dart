import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class CodeStory extends StatelessWidget {
  const CodeStory({super.key});

  @override
  Widget build(BuildContext context) => const StoryPanel(
    title: 'CodeBlock',
    tags: ["代码高亮"],
    children: [
      const StoryLabel('基础用法', strutStyle: storyCaptionStrut),
      StoryDemoBox(
        margin: EdgeInsets.zero,
        child: const IslandCodeBlock(
          code: "import 'package:animal_island_ui/animal_island_ui.dart';\n\nIslandButton(\n  variant: IslandButtonVariant.primary,\n  onPressed: () {},\n  child: const Text('按钮'),\n);",
        ),
      ),
      const StoryLabel('关闭复制功能', strutStyle: storyCaptionStrut),
      StoryDemoBox(
        margin: EdgeInsets.zero,
        child: const IslandCodeBlock(
          code: 'const copyButton = false;',
          copyable: false,
        ),
      ),
      const StoryLabel('自定义样式', strutStyle: storyCaptionStrut),
      StoryDemoBox(
        margin: EdgeInsets.zero,
        child: const IslandCodeBlock(
          code: "IslandCodeBlock(\n  code: codeString,\n  style: IslandCodeBlockStyle(backgroundColor: Color(0xff242c46)),\n  borderRadius: BorderRadius.all(Radius.circular(5)),\n)",
          style: IslandCodeBlockStyle(backgroundColor: Color(0xff242c46)),
          borderRadius: BorderRadius.all(Radius.circular(5)),
        ),
      ),
      const StoryCode("const IslandCodeBlock(code: 'final value = 42;')"),
      const StoryApi(
        rows: [
          ('code', '代码字符串', 'String', 'required'),
          ('language', '高亮语言', 'IslandCodeLanguage', 'dart'),
          ('style', '完整表面、语法角色与复制状态配方；见组件契约', 'IslandCodeBlockStyle?', 'null'),
          ('borderRadius', '圆角', 'BorderRadius?', 'null'),
          ('margin', '外边距', 'EdgeInsetsGeometry', 'vertical: 14'),
          ('padding', '内容内边距；显式值需给复制按钮留出空间', 'EdgeInsetsGeometry?', 'null'),
          ('copyable', '显示复制按钮', 'bool', 'true'),
          ('onCopied', '复制成功回调', 'ValueChanged<String>?', 'null'),
          ('onCopyError', '复制失败回调', 'ValueChanged<Object>?', 'null'),
        ],
      ),
    ],
  );
}
