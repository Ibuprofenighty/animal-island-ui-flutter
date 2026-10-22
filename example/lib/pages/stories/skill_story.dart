import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:math' as math;

import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class SkillStory extends StatelessWidget {
  const SkillStory({super.key});
  static Color get ink => IslandTokens.light.ink;
  Widget prose(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      height: 1.8,
      color: IslandTokens.light.muted,
    ),
  );
  Widget section(String title, List<String> tags, List<Widget> children) =>
      StoryPanel(
        title: title,
        tags: tags,
        children: [const SizedBox(height: 10), ...children],
      );
  Widget code(String text) => IslandCodeBlock(
    code: text,
    language: IslandCodeLanguage.shell,
    copyable: false,
    margin: EdgeInsets.zero,
    style: const IslandCodeBlockStyle(
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.7,
      ),
    ),
  );
  Widget grid(List<Widget> items, double minimum, {double gap = 12}) =>
      LayoutBuilder(
        builder: (context, c) {
          final columns = ((c.maxWidth + gap) / (minimum + gap)).floor().clamp(
            1,
            items.length,
          );
          final width = (c.maxWidth - gap * (columns - 1)) / columns;
          return Column(
            spacing: gap,
            children: [
              for (var start = 0; start < items.length; start += columns)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: gap,
                    children: [
                      for (
                        var i = start;
                        i < start + columns && i < items.length;
                        i++
                      )
                        SizedBox(width: width, child: items[i]),
                    ],
                  ),
                ),
            ],
          );
        },
      );
  Widget cardHead(
    String title,
    IslandGlyph icon, {
    double iconSize = 26,
    Widget? trailing,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      spacing: 8,
      children: [
        IslandIcon(icon, size: iconSize),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
  Widget chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xfff8f8f0),
      border: Border.all(color: const Color(0xffe8e2d6)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(text, style: TextStyle(fontSize: 12, color: ink)),
  );
  Widget step(int number, String title, String text, [String? shell]) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 8,
    children: [
      Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color(0xff19c8b9),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$number',
          style: TextStyle(
            color: IslandTokens.light.onLeaf,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ink,
              ),
            ),
            const SizedBox(height: 6),
            prose(text),
            const SizedBox(height: 10),
            if (shell != null) code(shell),
          ],
        ),
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 16,
    children: [
      section(
        'animal-island-ui-flutter',
        ["AI Skill", "可安装"],
        [
          prose(
            '一个可安装的编码助手技能，教会 AI 代理（Claude Code、Codex、Cursor 等兼容 SKILL.md 的代理）按治愈系海岛风格搭建 UI：暖色羊皮纸背景、大地色文字、薄荷主色、胶囊形状与 3D 游戏按钮质感。技能与物理模板配套，约束代理如何扩展组件并核对 Gallery。',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final label in [
                'Flutter + Dart',
                '40 个组件目标',
                'Windows + Web',
                'MIT License',
              ])
                IslandTag(
                  size: IslandSize.small,
                  variant: IslandTagVariant.outlined,
                  child: Text(label),
                ),
            ],
          ),
        ],
      ),
      section(
        '快速开始',
        ["3 步"],
        [
          const SizedBox(height: 12),
          step(
            1,
            '安装技能',
            '把项目 skills/animal-island-ui-flutter/ 目录复制到代理的 skills 位置；项目内版本与公共 API 同步。',
            '# PowerShell：复制配套技能到本机代理目录\nCopy-Item -Recurse skills/animal-island-ui-flutter ~/.agents/skills/',
          ),
          const SizedBox(height: 12),
          step(
            2,
            '正常提需求',
            '描述中指定 animal_island_ui 和要完成的页面，代理先读取组件合约及实际导出的 Dart API。',
            '# 对话里直接说即可\n用 animal_island_ui 做一个居民档案页：头像卡、里程进度、装备清单\n按现有公共模式新增组件，保留父子级状态和事件边界',
          ),
          const SizedBox(height: 12),
          step(
            3,
            '按规则验收',
            '产出必须匹配参考 Gallery，受控值由父级提交，子控件保留自身动作和样式。编译、测试、视觉与发布验收分别记录；不能把页面存在当作验收通过。',
          ),
        ],
      ),
      section(
        '工作原理',
        ["Workflow"],
        [
          prose('技能是纯文本知识包，没有可执行代码，也不会常驻上下文 —— 代理按下面五步按需消费它：'),
          const SizedBox(height: 14),
          grid(
            [
              for (final item in [
                (
                  IslandGlyph.shoppingBag,
                  IslandColorway.blue,
                  '装载',
                  '技能是纯文本知识包，安装后位于代理的 skills 目录。',
                ),
                (
                  IslandGlyph.chat,
                  IslandColorway.orange,
                  '触发',
                  '代理按 SKILL.md 的 description 匹配当前请求，命中才加载正文。',
                ),
                (
                  IslandGlyph.globe,
                  IslandColorway.yellow,
                  '路由',
                  '消费组件读取公共 API；扩展组件先读取对应合约与架构边界。',
                ),
                (
                  IslandGlyph.book,
                  IslandColorway.teal,
                  '对照 API',
                  '合法参数、默认值和状态转换逐项对照实际声明，杜绝凭印象编造。',
                ),
                (
                  IslandGlyph.paintbrush,
                  IslandColorway.brown,
                  '产出',
                  '按参考 Gallery 与公共模式实现，并逐项验证 Windows 和 Web。',
                ),
              ])
                IslandCard(
                  pattern: item.$2,
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cardHead(item.$3, item.$1),
                      prose(item.$4),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
            ],
            180,
            gap: 20,
          ),
        ],
      ),
      section(
        '两种使用场景',
        ["Scenarios"],
        [
          prose('代理先判断场景，再读对应入口；两个场景共用组件目录与硬性规则。'),
          const SizedBox(height: 14),
          grid([
            for (final item in [
              (
                'Flutter 应用',
                IslandGlyph.code,
                IslandColorway.teal,
                '使用包内公共组件和 IslandTokens 构建页面，业务状态留在宿主。',
                'docs/API.md',
              ),
              (
                '扩展组件库',
                IslandGlyph.file,
                IslandColorway.yellow,
                '先定义合约与所有权，复用已有完整公共模式，再实现组件和展示页。',
                'components/<id>/contract.json',
              ),
            ])
              IslandCard(
                colorway: item.$3,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cardHead(item.$1, item.$2, iconSize: 30),
                    prose(item.$4),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final agent in ['Claude Code', 'Codex', 'Cursor'])
                          chip(agent),
                      ],
                    ),
                    const SizedBox(height: 8),
                    chip(item.$5),
                  ],
                ),
              ),
          ], 260),
        ],
      ),
      section(
        '目录结构',
        ["Layout"],
        [
          code(
            'animal_island_ui/\n├── lib/animal_island_ui.dart    # 唯一公开入口\n├── components/<id>/contract.json  # 组件合约\n├── example/lib/                   # app / pages / shared\n└── skills/animal-island-ui-flutter/\n    ├── SKILL.md                   # 方法与工作流\n    └── SKILL.zh-CN.md             # 中文审阅镜像',
          ),
        ],
      ),
      section(
        '组件目录',
        ["40 Components"],
        [
          prose(
            '合约位于 components/<id>/contract.json；公共 API 以 Dart 导出声明为准。未通过对照验收的组件保持 experimental。',
          ),
          const SizedBox(height: 14),
          Column(
            spacing: 8,
            children: [
              for (final row in [
                (
                  'General',
                  IslandColorway.teal,
                  'Button · Typewriter · Cursor',
                  'general',
                ),
                (
                  'Layout',
                  IslandColorway.yellow,
                  'Card · Title · Divider · Collapse · Tabs',
                  'layout',
                ),
                (
                  'Form controls',
                  IslandColorway.blue,
                  'Input · Switch · Checkbox · Radio · Rate · Select',
                  'controls',
                ),
                ('Upload', IslandColorway.peach, 'Upload', 'upload'),
                (
                  'Date & time pickers',
                  IslandColorway.yellowGreen,
                  'DatePicker · TimePicker',
                  'date-time',
                ),
                ('Form container', IslandColorway.pink, 'Form', 'form'),
                (
                  'Overlays',
                  IslandColorway.purple,
                  'Modal · Drawer · Tooltip',
                  'overlays',
                ),
                (
                  'Feedback',
                  IslandColorway.orange,
                  'Progress · Skeleton · BackTop · Loading · Countdown · Time',
                  'feedback',
                ),
                (
                  'Notification',
                  IslandColorway.red,
                  'Notification',
                  'notification',
                ),
                (
                  'Data displays',
                  IslandColorway.green,
                  'Table · CodeBlock · Tag · Badge · Pagination',
                  'data',
                ),
                ('Count-up score', IslandColorway.teal, 'CountUp', 'countup'),
                (
                  'Media',
                  IslandColorway.lime,
                  'Image · Avatar · Carousel',
                  'media',
                ),
                (
                  'Decorative',
                  IslandColorway.brown,
                  'Footer · Divider · Cursor · Typewriter · Background',
                  'decorative',
                ),
              ])
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xfff8f8f0),
                    border: Border.all(color: const Color(0xffe8e2d6)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _CatalogRow(
                    direction: Directionality.of(context),
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 128),
                        child: IslandTag(
                          colorway: row.$2,
                          variant: IslandTagVariant.soft,
                          child: Text(row.$1),
                        ),
                      ),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final name in row.$3.split(' · '))
                            IslandTag(
                              size: IslandSize.small,
                              variant: IslandTagVariant.outlined,
                              child: Text(name),
                            ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xfff0e8d8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          row.$4,
                          strutStyle: const StrutStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            forceStrutHeight: true,
                          ),
                          style: TextStyle(
                            fontFamily: IslandTheme.codeFontFamily,
                            fontSize: 12,
                            height: 16 / 12,
                            color: IslandTokens.light.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      section(
        '设计令牌',
        ["IslandTokens"],
        [
          prose(
            '以下色值直接读取 IslandTokens.light，与产品共用一套语义配色。装饰色与承载文字的颜色分别配对；完整状态仍需逐组件验收。',
          ),
          const SizedBox(height: 14),
          for (final group in <String, Map<String, Color>>{
            '主色与交互 primary / interaction': {
              'leaf': IslandTokens.light.leaf,
              'onLeaf': IslandTokens.light.onLeaf,
              'leafHover': IslandTokens.light.leafHover,
              'leafPressed': IslandTokens.light.leafPressed,
              'link': IslandTokens.light.link,
              'linkHover': IslandTokens.light.linkHover,
              'linkPressed': IslandTokens.light.linkPressed,
              'focus': IslandTokens.light.focus,
            },
            '状态色 status': {
              'sun': IslandTokens.light.sun,
              'onSun': IslandTokens.light.onSun,
              'warning': IslandTokens.light.warning,
              'danger': IslandTokens.light.danger,
              'onDanger': IslandTokens.light.onDanger,
              'dangerText': IslandTokens.light.dangerText,
              'dangerHover': IslandTokens.light.dangerHover,
              'dangerPressed': IslandTokens.light.dangerPressed,
            },
            '文字与表面 text / surface': {
              'ink': IslandTokens.light.ink,
              'muted': IslandTokens.light.muted,
              'onCanvas': IslandTokens.light.onCanvas,
              'canvas': IslandTokens.light.canvas,
              'paper': IslandTokens.light.paper,
              'inputSurface': IslandTokens.light.inputSurface,
              'outline': IslandTokens.light.outline,
            },
          }.entries) ...[
            StoryLabel(group.key),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final token in group.value.entries)
                  Container(
                    width: 116,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xfff8f8f0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(height: 56, color: token.value),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                token.key,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: ink,
                                ),
                              ),
                              Text(
                                '#${token.value.toARGB32().toRadixString(16).substring(2)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: IslandTokens.light.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          for (final row in {
            '圆角': ['16', '18', '24'],
            '间距': ['4', '8', '12', '16', '24'],
            '阴影': ['small', 'base', 'large'],
            '字体': ['Nunito + Noto Sans SC', '12', '14', '16'],
          }.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      row.key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ink,
                      ),
                    ),
                  ),
                  for (final label in row.value)
                    IslandTag(
                      size: IslandSize.small,
                      variant: IslandTagVariant.soft,
                      child: Text(label),
                    ),
                ],
              ),
            ),
        ],
      ),
      section(
        '硬性规则',
        ["Hard Rules"],
        [
          prose('违反以下规则视为 bug，代理不得越界：'),
          const SizedBox(height: 14),
          grid([
            for (final rule in [
              (
                'API 纪律',
                IslandGlyph.book,
                IslandColorway.red,
                [
                  '绝不编造参数；每个参数必须出现在实际公共 Dart 声明中。',
                  '受控值由父级提交；回调是变更请求，父级拒绝后不得私自改变展示值。',
                  '优先公共组件；子插槽保留显式样式、焦点、键和事件。',
                ],
              ),
              (
                '导入与工程',
                IslandGlyph.map,
                IslandColorway.blue,
                [
                  '只从包根导入，Gallery 保持 app / pages / shared。',
                  '新增组件先定义合约与 owner，复用已有完整公共模式。',
                  '资源由创建者释放，外部传入的控制器和节点仅借用。',
                ],
              ),
              (
                '色彩与字体',
                IslandGlyph.paintbrush,
                IslandColorway.pink,
                [
                  '按参考 Gallery 的暖色文字、羊皮纸和薄荷色实现。',
                  '焦点样式按控件合约，不使用默认冷蓝色替代。',
                  '字体为 Nunito + Noto Sans SC；代码区之外不使用等宽字体。',
                ],
              ),
              (
                '形状与质感',
                IslandGlyph.pencil,
                IslandColorway.yellow,
                [
                  '按钮和输入框保持参考胶囊；各组件按自己的真实半径绘制。',
                  '3D 堆叠阴影属于 primary / danger-primary 按钮；不得套用到所有控件。',
                  'Modal 保留有机裁切，Title 保留燕尾丝带。',
                ],
              ),
              (
                '图标与动效',
                IslandGlyph.camera,
                IslandColorway.teal,
                [
                  '使用经过来源记录的 IslandGlyph；不得用 emoji 随意替换。',
                  '尊重减少动态效果设置；关闭或销毁后取消自己拥有的延迟工作。',
                ],
              ),
            ])
              IslandCard(
                variant: IslandCardVariant.dashed,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cardHead(
                      rule.$1,
                      rule.$2,
                      iconSize: 22,
                      trailing: IslandTag(
                        size: IslandSize.small,
                        variant: IslandTagVariant.soft,
                        colorway: rule.$3,
                        child: Text('${rule.$4.length} 条'),
                      ),
                    ),
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.9,
                        color: IslandTokens.light.muted,
                      ),
                      child: Column(
                        spacing: 6,
                        children: [
                          for (final text in rule.$4)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  child: StoryText('•'),
                                ),
                                Expanded(child: StoryText(text)),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ], 300),
        ],
      ),
      section(
        '许可证',
        ["License"],
        [
          prose(
            '新的 Dart 实现与配套技能采用 MIT License，可使用、修改与分发，包括商业用途。字体、图标及照片保留各自授权与来源记录。发布前仍须完成 Windows / Web 对照和商用验收；完整条款见 LICENSE 与 docs/RIGHTS.md。',
          ),
        ],
      ),
    ],
  );
}

// Three explicit Gallery slots: fixed category, flexible component-chip group,
// then a quiet path. The last slot wraps only when their intrinsic minima need it.
class _CatalogRow extends MultiChildRenderObjectWidget {
  const _CatalogRow({required this.direction, required super.children});
  final TextDirection direction;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCatalogRow(direction);
  @override
  void updateRenderObject(BuildContext context, _RenderCatalogRow object) {
    object.direction = direction;
  }
}

class _CatalogData extends ContainerBoxParentData<RenderBox> {}

class _RenderCatalogRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _CatalogData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _CatalogData> {
  _RenderCatalogRow(this._direction);
  TextDirection _direction;
  set direction(TextDirection value) {
    if (value == _direction) return;
    _direction = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _CatalogData) child.parentData = _CatalogData();
  }

  Size layoutRow(BoxConstraints constraints, {bool dry = false}) {
    final children = getChildrenAsList();
    assert(children.length == 3);
    Size measure(RenderBox child, BoxConstraints offered) {
      if (dry) return child.getDryLayout(offered);
      child.layout(offered, parentUsesSize: true);
      return child.size;
    }

    final category = measure(
      children[0],
      BoxConstraints(maxWidth: constraints.maxWidth),
    );
    final path = measure(
      children[2],
      BoxConstraints(maxWidth: constraints.maxWidth),
    );
    final minimum = children[1].getMinIntrinsicWidth(double.infinity);
    final inline =
        category.width + minimum + path.width + 16 <= constraints.maxWidth;
    final offered = math.max(
      0.0,
      constraints.maxWidth - category.width - (inline ? path.width + 16 : 8),
    );
    final group = measure(children[1], BoxConstraints.tightFor(width: offered));
    final topHeight = math.max(category.height, group.height);
    final height = inline
        ? math.max(topHeight, path.height)
        : topHeight + 8 + path.height;
    final result = constraints.constrain(Size(constraints.maxWidth, height));
    if (!dry) {
      void place(int index, double x, double y, Size actual) {
        (children[index].parentData! as _CatalogData).offset = Offset(
          _direction == TextDirection.ltr ? x : result.width - x - actual.width,
          y,
        );
      }

      place(
        0,
        0,
        (height - (inline ? 0 : path.height + 8) - category.height) / 2,
        category,
      );
      place(
        1,
        category.width + 8,
        (height - (inline ? 0 : path.height + 8) - group.height) / 2,
        group,
      );
      place(
        2,
        inline ? category.width + group.width + 16 : 0,
        inline ? (height - path.height) / 2 : topHeight + 8,
        path,
      );
    }
    return result;
  }

  @override
  double computeMinIntrinsicWidth(double height) => getChildrenAsList().fold(
    0.0,
    (width, c) => math.max(width, c.getMinIntrinsicWidth(height)),
  );
  @override
  double computeMaxIntrinsicWidth(double height) =>
      16 +
      getChildrenAsList().fold(
        0.0,
        (width, c) => width + c.getMaxIntrinsicWidth(height),
      );
  @override
  double computeMinIntrinsicHeight(double width) =>
      layoutRow(BoxConstraints(maxWidth: width), dry: true).height;
  @override
  double computeMaxIntrinsicHeight(double width) =>
      computeMinIntrinsicHeight(width);
  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      layoutRow(constraints, dry: true);
  @override
  void performLayout() {
    size = layoutRow(constraints);
  }

  @override
  void paint(PaintingContext context, Offset offset) =>
      defaultPaint(context, offset);
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}
