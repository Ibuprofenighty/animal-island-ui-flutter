import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../shared/catalog.dart';
import '../shared/version.g.dart';
import '../shared/story.dart';
import '../shared/reference_source_link.dart';

/// Same reference composition. Random wallpaper is stable for a page lifetime.
class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key, required this.onNavigate, this.wallpaperSeed});
  final ValueChanged<String> onNavigate;
  final int? wallpaperSeed;
  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome>
    with SingleTickerProviderStateMixin {
  final scroll = ScrollController();
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  );
  List<_Giant>? giants;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.stop();
    } else if (!motion.isAnimating) {
      motion.repeat();
    }
    giants ??= _place(
      MediaQuery.sizeOf(context),
      math.Random(widget.wallpaperSeed),
    );
  }

  @override
  void dispose() {
    scroll.dispose();
    motion.dispose();
    super.dispose();
  }

  List<_Giant> _place(Size viewport, math.Random random) {
    const choices = [
      IslandGlyph.heart,
      IslandGlyph.star,
      IslandGlyph.sun,
      IslandGlyph.moon,
      IslandGlyph.cloud,
      IslandGlyph.rainbow,
      IslandGlyph.flower,
      IslandGlyph.butterfly,
      IslandGlyph.leaf,
      IslandGlyph.tree,
      IslandGlyph.mushroom,
      IslandGlyph.bird,
      IslandGlyph.fish,
      IslandGlyph.sailboat,
      IslandGlyph.balloon,
      IslandGlyph.icecream,
      IslandGlyph.penguin,
      IslandGlyph.apple,
      IslandGlyph.cherry,
      IslandGlyph.lemon,
      IslandGlyph.cactus,
      IslandGlyph.home,
      IslandGlyph.camera,
      IslandGlyph.bell,
      IslandGlyph.globe,
      IslandGlyph.key,
      IslandGlyph.search,
      IslandGlyph.settings,
      IslandGlyph.mail,
      IslandGlyph.phone,
      IslandGlyph.umbrella,
      IslandGlyph.download,
      IslandGlyph.wifi,
      IslandGlyph.headphones,
      IslandGlyph.donut,
      IslandGlyph.strawberry,
      IslandGlyph.watermelon,
      IslandGlyph.ladybug,
      IslandGlyph.bee,
      IslandGlyph.snail,
      IslandGlyph.dog,
      IslandGlyph.fox,
      IslandGlyph.bicycle,
      IslandGlyph.car,
      IslandGlyph.train,
    ];
    final result = <_Giant>[];
    final count = 5 + random.nextInt(4);
    final used = <IslandGlyph>{};
    for (var attempt = 0; attempt < 2000 && result.length < count; attempt++) {
      final size = 430 + random.nextDouble() * 160;
      final centerFraction = Offset(
        .04 + random.nextDouble() * .92,
        .04 + random.nextDouble() * .92,
      );
      final center = Offset(
        centerFraction.dx * viewport.width,
        centerFraction.dy * viewport.height,
      );
      if (result.any(
        (p) =>
            (center - p.centerIn(viewport)).distance < (size + p.size) / 2 + 20,
      ))
        continue;
      var icon = choices[random.nextInt(choices.length)];
      for (var i = 0; i < 200 && used.contains(icon); i++) {
        icon = choices[random.nextInt(choices.length)];
      }
      used.add(icon);
      result.add(
        _Giant(
          centerFraction,
          size,
          (-14 + random.nextDouble() * 28) * math.pi / 180,
          icon,
        ),
      );
    }
    return result;
  }

  static const overviewSummaries = <String, String>{
    "input": "前后缀、一键清空、校验状态",
    "form": "校验规则 / 命令式控制器 / 三种布局",
    "switch": "受控/非受控、自定义文案、加载状态",
    "checkbox": "多选框组件，支持水平/垂直排列",
    "rate": "评分组件，支持悬停预览与只读展示",
    "date-picker": "日期选择与范围选择，年/月/日面板、禁用日期、键盘导航",
    "time-picker": "时间选择，时/分/秒滚选、此刻/确定、步进",
    "time": "实时时钟卡片，星期 + 月日 + HH:MM 每秒刷新",
    "countup": "计分数字滚动，缓动可调，结束可庆祝动效",
    "pagination": "分页组件，每页条数切换、快速跳转",
    "drawer": "下沉景深抽屉，四方向 + 背景下沉",
    "notification": "命令式通知，4 种 type × 6 个 position",
    "loading": "全屏落雪，结束渐变消失",
    "card": "默认/标题两种卡片风格",
    "codeblock": "代码语法高亮组件",
    "background": "奶油/深绿波点 + 彩色针糖 + 12 色 Card pattern 底色壁纸",
    "image": "白色衬板图片，支持懒加载 / 点击预览",
    "avatar": "图片/图标/文字头像，圆形方形，头像组叠加与折叠",
    "badge": "图标/头像右上角角标，封顶数字、小红点、独立使用",
    "carousel": "自动播放、箭头/圆点与键盘导航",
  };

  @override
  Widget build(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final mobile = viewport.width < 768;
    Widget section(String title, String description, Widget child) => Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 960),
        padding: EdgeInsets.symmetric(
          horizontal: mobile ? 16 : 40,
          vertical: mobile ? 32 : 48,
        ),
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  strutStyle: const StrutStyle(
                    fontSize: 24,
                    height: 33 / 24,
                    forceStrutHeight: true,
                  ),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: IslandTokens.light.onCanvas,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  strutStyle: const StrutStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    forceStrutHeight: true,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: IslandTokens.light.onCanvas,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            child,
          ],
        ),
      ),
    );
    Widget grid(List<Widget> children, {double gap = 16}) => LayoutBuilder(
      builder: (_, constraints) {
        final columns = math.max(
          1,
          ((constraints.maxWidth + gap) / (200 + gap)).floor(),
        );
        final width = (constraints.maxWidth - (columns - 1) * gap) / columns;
        return Column(
          spacing: gap,
          children: [
            for (var start = 0; start < children.length; start += columns)
              IntrinsicHeight(
                child: Row(
                  spacing: gap,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (
                      var i = start;
                      i < math.min(start + columns, children.length);
                      i++
                    )
                      SizedBox(width: width, child: children[i]),
                  ],
                ),
              ),
          ],
        );
      },
    );
    final entries = {
      for (final group in galleryGroups.values)
        for (final item in group) item.id: item,
    };
    const overview = [
      'input',
      'form',
      'switch',
      'checkbox',
      'rate',
      'date-picker',
      'time-picker',
      'time',
      'countup',
      'pagination',
      'drawer',
      'notification',
      'loading',
      'card',
      'codeblock',
      'background',
      'image',
      'avatar',
      'badge',
      'carousel',
    ];
    return ColoredBox(
      color: IslandTokens.light.canvas,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: AnimatedBuilder(
                  animation: motion,
                  builder: (_, _) => Stack(
                    clipBehavior: Clip.hardEdge,
                    children: [
                      for (var i = 0; i < giants!.length; i++)
                        Positioned(
                          left:
                              giants![i].centerIn(viewport).dx -
                              giants![i].size / 2,
                          top:
                              giants![i].centerIn(viewport).dy -
                              giants![i].size / 2,
                          child: Transform.rotate(
                            angle: giants![i].angle,
                            child: Transform.translate(
                              offset: Offset(
                                0,
                                -4 +
                                    math.cos(
                                          (motion.value * 30 - i * 1.2) /
                                              (5.5 + i % 3) *
                                              math.pi *
                                              2,
                                        ) *
                                        4,
                              ),
                              child: Opacity(
                                opacity: .68,
                                child: IslandIcon(
                                  giants![i].icon,
                                  size: giants![i].size,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            controller: scroll,
            child: Column(
              children: [
                SizedBox(
                  height: viewport.height,
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 880),
                            child: Align(
                              alignment: mobile
                                  ? Alignment.center
                                  : Alignment.centerLeft,
                              child: SizedBox(
                                width: mobile ? double.infinity : 365,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: mobile
                                      ? CrossAxisAlignment.center
                                      : CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: mobile
                                                ? 'Animal Island UI'
                                                : 'Animal\nIsland UI',
                                          ),
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                left: 8,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xffe6f9f6),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                'v$galleryVersion',
                                                style: TextStyle(
                                                  fontFamily: 'Nunito',
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      IslandTokens.light.link,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: mobile
                                          ? TextAlign.center
                                          : TextAlign.left,
                                      style: TextStyle(
                                        fontFamily: 'GROBOLD',
                                        fontSize: mobile ? 37 : 60,
                                        height: 1.1,
                                        color: IslandTokens.light.onCanvas,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x66000000),
                                            offset: Offset(0, 4),
                                            blurRadius: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    IslandTypewriter(
                                      'Kawaii 风格的 Flutter 组件库，基于 Dart 构建，让 Windows 与 Web 应用充满温暖质感',
                                      speed: const Duration(milliseconds: 60),
                                      style: TextStyle(
                                        fontSize: mobile ? 14 : 17,
                                        height: 1.7,
                                        color: IslandTokens.light.onCanvas,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    IslandButton(
                                      size: IslandSize.large,
                                      variant: IslandButtonVariant.primary,
                                      onPressed: () =>
                                          widget.onNavigate('skill'),
                                      child: const Text('开始使用 →'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () => scroll.animateTo(
                              viewport.height,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '向下滑动',
                                  style: TextStyle(
                                    color: IslandTokens.light.onCanvas,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Icon(
                                  Icons.arrow_downward,
                                  color: IslandTokens.light.onCanvas,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                section(
                  '特性',
                  '为什么选择 animal-island-ui',
                  grid([
                    const _Feature(
                      IslandGlyph.heart,
                      '治愈系风格',
                      'SVG 有机形状裁切，3D 按压按钮，温暖质朴的自然 UI 质感',
                    ),
                    const _Feature(
                      IslandGlyph.star,
                      '40 个组件',
                      'Button / Input / Switch / Modal / Form / Table / Title / Tooltip / Typewriter / Card / Collapse / Cursor / Divider / Footer / Icon / Checkbox / Select / DatePicker / TimePicker / Tabs / CodeBlock / Radio / Tag / Notification / Progress / CountUp',
                    ),
                    const _Feature(
                      IslandGlyph.paintbrush,
                      '主题定制',
                      '作用域主题与组件样式，运行时换肤无需重新构建',
                    ),
                    const _Feature(
                      IslandGlyph.gift,
                      '开箱即用',
                      'Flutter 组件与 Dart 类型接口，Windows + Web 优先',
                    ),
                  ]),
                ),
                section(
                  '组件一览',
                  '详细文档与在线演示请从左侧菜单进入',
                  grid([
                    for (final id in overview)
                      IslandCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entries[id]!.label.split(' ').first,
                              strutStyle: const StrutStyle(
                                fontSize: 15,
                                height: 20 / 15,
                                forceStrutHeight: true,
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: IslandTokens.light.onCanvas,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              overviewSummaries[id]!,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: IslandTokens.light.onCanvas,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ], gap: 12),
                ),
                section(
                  '安装',
                  '一行命令即可安装',
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const IslandCodeBlock(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      style: IslandCodeBlockStyle(
                        textStyle: TextStyle(fontSize: 13, height: 1.8),
                      ),
                      code: 'dependencies:\n  animal_island_ui:\n    path: ../animal_island_ui',
                      language: IslandCodeLanguage.shell,
                      copyable: false,
                    ),
                  ),
                ),
                section(
                  '快速上手',
                  '引入组件即可使用，样式自动加载',
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const IslandCodeBlock(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      style: IslandCodeBlockStyle(
                        textStyle: TextStyle(fontSize: 13, height: 1.8),
                      ),
                      code: "import 'package:animal_island_ui/animal_island_ui.dart';\n\nIslandButton(onPressed: () {}, child: const Text('开始'));",
                      copyable: false,
                    ),
                  ),
                ),
                section(
                  '主题定制',
                  '通过作用域 Theme 实现运行时换肤，无需重新构建',
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const IslandCodeBlock(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      style: IslandCodeBlockStyle(
                        textStyle: TextStyle(fontSize: 13, height: 1.8),
                      ),
                      code: "MaterialApp(\n  theme: IslandTheme.create(),\n  home: const MyPage(),\n)",
                      copyable: false,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: mobile ? 24 : 32,
                      horizontal: mobile ? 16 : 40,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 20,
                          children: [
                            _HomeFooterAction(
                              '组件文档',
                              () => widget.onNavigate('button'),
                            ),
                            const _HomeFooterAction(
                              'GitHub',
                              openReferenceSource,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Flutter + Dart · Reference Gallery',
                          strutStyle: const StrutStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            forceStrutHeight: true,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: IslandTokens.light.onCanvas,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Giant {
  const _Giant(this.centerFraction, this.size, this.angle, this.icon);
  final Offset centerFraction;
  Offset centerIn(Size viewport) => Offset(
    centerFraction.dx * viewport.width,
    centerFraction.dy * viewport.height,
  );
  final double size, angle;
  final IslandGlyph icon;
}

class _Feature extends StatefulWidget {
  const _Feature(this.icon, this.title, this.description);
  final IslandGlyph icon;
  final String title, description;
  @override
  State<_Feature> createState() => _FeatureState();
}

class _FeatureState extends State<_Feature> {
  bool hover = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hover = true),
    onExit: (_) => setState(() => hover = false),
    child: TweenAnimationBuilder<Matrix4>(
      tween: Matrix4Tween(end: Matrix4.translationValues(0, hover ? -4 : 0, 0)),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.linear,
      builder: (_, matrix, child) => Transform(
        transform: matrix,
        filterQuality: FilterQuality.low,

        child: child,
      ),
      child: IslandCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            IslandIcon(widget.icon, size: 42),
            Text(
              widget.title,
              strutStyle: const StrutStyle(
                fontSize: 15,
                height: 22 / 15,
                forceStrutHeight: true,
              ),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: IslandTokens.light.onCanvas,
              ),
            ),
            const SizedBox(height: 6),
            DefaultTextStyle.merge(
              style: TextStyle(
                fontSize: 13,
                height: 1.6,
                color: IslandTokens.light.onCanvas,
              ),
              child: StoryText(
                widget.description,
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeFooterAction extends StatelessWidget {
  const _HomeFooterAction(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      foregroundColor: IslandTokens.light.onCanvas,
      textStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
      ),
    ),
    child: Text(
      label,
      strutStyle: const StrutStyle(
        fontSize: 13,
        height: 20 / 13,
        forceStrutHeight: true,
      ),
    ),
  );
}
