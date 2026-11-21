import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../shared/catalog.dart';
import '../shared/version.g.dart';
import '../shared/palette.dart';
import '../shared/story.dart';
import '../shared/reference_source_link.dart';
import '../shared/theme.dart';

/// Reference Home wallpaper text colours (demo/HomePage.tsx). Text over the
/// Home wallpaper is the reference-priority contrast exception in
/// docs/DESIGN.md#home-host-and-photo-gradient. Card text uses the reference
/// values, which pass on the card paper (GalleryPalette.homeCardTitle/Body).
abstract final class HomeWallpaperInk {
  /// Hero title and scroll hint (`#FFF9E6`).
  static const cream = GalleryPalette.homeCream;

  /// Section titles (`#725d42`).
  static const title = GalleryPalette.homeTitle;

  /// Hero subtitle, section descriptions and footer (`#7c5734`).
  static const body = GalleryPalette.homeBody;
}

/// Browser `line-height: normal` for 14px Gallery text (reference Home
/// section descriptions and the component page description): Nunito 14/5,
/// CJK 16/4, so a 21px line with its baseline 16px below the top. The
/// previous forced Nunito struts put it at 15.1 (21px, even leading) and
/// 14.8 (20px), about 1px high.
final galleryNormalLine14 = galleryNormalLine(14);

/// A Gallery page or sidebar scroller with the reference hidden scrollbar
/// (`*::-webkit-scrollbar { display: none; }` in demo/main.tsx). Wheel,
/// keyboard, drag and touch scrolling are unchanged. The platform bar is
/// dropped for this scroller only: its child gets the inherited scroll
/// behavior back, so component scroll areas keep their own bars.
class GalleryScrollView extends StatelessWidget {
  const GalleryScrollView({
    super.key,
    required this.controller,
    this.padding,
    this.clipBehavior = Clip.hardEdge,
    required this.child,
  });

  final ScrollController controller;
  final EdgeInsetsGeometry? padding;

  /// [Clip.none] lets content scrolled past the top keep painting under an
  /// overlaid header.
  final Clip clipBehavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final behavior = ScrollConfiguration.of(context);
    return ScrollConfiguration(
      behavior: behavior.copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: controller,
        padding: padding,
        clipBehavior: clipBehavior,
        child: ScrollConfiguration(behavior: behavior, child: child),
      ),
    );
  }
}

/// Same reference composition. Random wallpaper is stable for a page lifetime.
class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key, required this.onNavigate, this.wallpaperSeed});
  final ValueChanged<String> onNavigate;
  final int? wallpaperSeed;
  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

const _cycle = 4290;

class _GalleryHomeState extends State<GalleryHome>
    with SingleTickerProviderStateMixin {
  final scroll = ScrollController();
  late final motion = AnimationController(
    vsync: this,
    // The icons float on 5.5s, 6.5s and 7.5s cycles (reference `iconFloat`)
    // and the scroll hint bounces every 2s; 4290s is their common period, so
    // the repeat has no phase jump.
    duration: const Duration(seconds: _cycle),
  );
  List<_Giant>? giants;

  /// Reference `iconFloat ${5.5 + i % 3}s ease-in-out ${-i * 1.2}s infinite`:
  /// 0 -> -8px -> 0, each half eased, started `i * 1.2`s into its cycle.
  static double _float(double value, int i) {
    final phase = (value * _cycle + i * 1.2) / (5.5 + i % 3) % 1;
    final half = phase < .5 ? phase * 2 : (1 - phase) * 2;
    return -8 * Curves.easeInOut.transform(half);
  }

  /// Reference hint lifecycle: visible until the page scrolls past 70px.
  bool showScrollHint = true;
  @override
  void initState() {
    super.initState();
    scroll.addListener(() {
      final show = scroll.offset <= 70;
      if (show != showScrollHint) setState(() => showScrollHint = show);
    });
  }

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
      IslandGlyph.coffee,
      IslandGlyph.music,
      IslandGlyph.snowflake,
      IslandGlyph.gift,
      IslandGlyph.rocket,
      IslandGlyph.bear,
      IslandGlyph.cat,
      IslandGlyph.rabbit,
      IslandGlyph.frog,
      IslandGlyph.owl,
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
    "charts": "19 种海岛统计图，趋势、占比、分布、仪表盘与地图",
    "input": "前后缀、一键清空、校验状态",
    "form": "校验规则 / 命令式控制器 / 三种布局",
    "switch": "受控/非受控、自定义文案、加载状态",
    "checkbox": "多选框组件，支持水平/垂直排列",
    "rate": "评分组件，支持悬停预览与只读展示",
    "date-picker": "日期选择与范围选择，年/月/日面板、禁用日期、键盘导航",
    "time-picker": "时间选择，时/分/秒滚选、此刻/确定、步进",
    "calendar": "轻量月面板日历，事项通知与跨日期连续条",
    "time": "实时时钟卡片，星期 + 月日 + HH:MM 每秒刷新",
    "countup": "计分数字滚动，缓动可调，结束可庆祝动效",
    "pagination": "分页组件，每页条数切换、快速跳转",
    "drawer": "下沉景深抽屉，四方向 + 背景下沉",
    "notification": "命令式通知，4 种 type × 6 个 position",
    "loading": "全屏落雪，结束渐变消失",
    "no-data": "海岛空态、搜索无结果、自定义文案与恢复操作",
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
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: HomeWallpaperInk.title,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  strutStyle: galleryNormalLine14,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: HomeWallpaperInk.body,
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
                              offset: Offset(0, _float(motion.value, i)),
                              child: Opacity(
                                opacity: .68,
                                child: IslandIcon(
                                  giants![i].icon,
                                  size: giants![i].size,
                                  color: GalleryPalette.homeGiantIcon,
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
          GalleryScrollView(
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
                                                color: GalleryPalette
                                                    .homeVersionBadge,
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
                                        color: HomeWallpaperInk.cream,
                                        shadows: const [
                                          Shadow(
                                            color:
                                                GalleryPalette.homeHeroShadow,
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
                                        fontWeight: FontWeight.w500,
                                        color: HomeWallpaperInk.body,
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
                          // Reference hint: pointer cursor without an action,
                          // a 2s ease-in-out bounce on the page motion clock,
                          // and a 0.3s exit once the page scrolls past 70px.
                          // The bounce keeps the text opaque (readable motion).
                          child: IgnorePointer(
                            ignoring: !showScrollHint,
                            child: AnimatedOpacity(
                              opacity: showScrollHint ? 1 : 0,
                              duration: MediaQuery.disableAnimationsOf(context)
                                  ? Duration.zero
                                  : const Duration(milliseconds: 300),
                              curve: Curves.ease,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: AnimatedBuilder(
                                  animation: motion,
                                  builder: (_, child) {
                                    final phase =
                                        (motion.value * _cycle % 2) / 2;
                                    final rise = Curves.easeInOut.transform(
                                      phase < .5 ? phase * 2 : 2 - phase * 2,
                                    );
                                    return Transform.translate(
                                      offset: Offset(
                                        0,
                                        showScrollHint &&
                                                !MediaQuery.disableAnimationsOf(
                                                  context,
                                                )
                                            ? -8 * rise
                                            : 0,
                                      ),
                                      child: child,
                                    );
                                  },
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        '向下滑动',
                                        style: TextStyle(
                                          color: HomeWallpaperInk.cream,
                                          fontSize: 12,
                                          shadows: [
                                            Shadow(
                                              color:
                                                  GalleryPalette.homeHintShadow,
                                              offset: Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox.square(
                                        dimension: 16,
                                        child: CustomPaint(
                                          painter: _ScrollHintArrow(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
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
                      '43 个组件',
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
                    for (final MapEntry(key: id, value: summary)
                        in overviewSummaries.entries)
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: GalleryPalette.homeCardTitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Reference `.compDesc` `line-height: 1.5`: a
                            // fixed 18px line box for mixed Latin/CJK runs.
                            Text(
                              summary,
                              strutStyle: const StrutStyle(
                                fontSize: 12,
                                height: 1.5,
                                forceStrutHeight: true,
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: GalleryPalette.homeCardBody,
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
                      code: '# 在 pubspec.yaml 中添加依赖\ndependencies:\n  animal_island_ui:\n    path: ../animal_island_ui',
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
                      code: "// 1. 引入组件\nimport 'package:animal_island_ui/animal_island_ui.dart';\n\nIslandButton(onPressed: () {}, child: const Text('开始'));",
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
                      code: "// 覆盖主题变量\nMaterialApp(\n  theme: IslandTheme.create(),\n  home: const MyPage(),\n)",
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
                              leading: _GitHubMark(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'MIT License · Reference Gallery',
                          textAlign: TextAlign.center,
                          strutStyle: StrutStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            forceStrutHeight: true,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: HomeWallpaperInk.body,
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

/// Reference FeatureCard hover: the card lifts 4px with a decorative
/// `0 8px 24px rgba(114,93,66,.15)` shadow (`all 0.3s ease`); the icon plays
/// `iconBounce` (0.4s: scale 1 -> 1.2 / -5deg -> 1.1 / -4deg) and returns to
/// rest over 0.3s ease on exit. Reduced motion settles the same end states.
class _FeatureState extends State<_Feature>
    with SingleTickerProviderStateMixin {
  bool hover = false;
  late final icon = AnimationController(vsync: this);
  bool entering = false;
  (double, double) exitFrom = (1, 0);

  (double, double) iconPose() {
    final t = icon.value;
    if (entering) {
      if (t < .5) {
        final k = Curves.ease.transform(t * 2);
        return (1 + .2 * k, -5 * k);
      }
      final k = Curves.ease.transform(t * 2 - 1);
      return (1.2 - .1 * k, -5 + k);
    }
    final k = Curves.ease.transform(t);
    return (exitFrom.$1 + (1 - exitFrom.$1) * k, exitFrom.$2 * (1 - k));
  }

  void setHover(bool value) {
    if (value == hover) return;
    final reduced = MediaQuery.disableAnimationsOf(context);
    setState(() {
      hover = value;
      if (!value) exitFrom = iconPose();
      entering = value;
    });
    icon.duration = Duration(milliseconds: value ? 400 : 300);
    if (reduced) {
      icon.value = 1;
    } else {
      icon.forward(from: 0);
    }
  }

  @override
  void dispose() {
    icon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setHover(true),
    onExit: (_) => setHover(false),
    child: TweenAnimationBuilder<double>(
      tween: Tween(end: hover ? 1 : 0),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 300),
      curve: Curves.ease,
      builder: (_, lift, child) => Transform(
        transform: Matrix4.translationValues(0, -4 * lift, 0),
        filterQuality: FilterQuality.low,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              if (lift > 0)
                BoxShadow(
                  color: GalleryPalette.homeCardLift.withValues(
                    alpha: .15 * lift,
                  ),
                  offset: Offset(0, 8 * lift),
                  blurRadius: 24 * lift,
                ),
            ],
          ),
          child: child,
        ),
      ),
      child: IslandCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: icon,
              builder: (_, child) {
                final pose = iconPose();
                return Transform.rotate(
                  angle: pose.$2 * math.pi / 180,
                  child: Transform.scale(scale: pose.$1, child: child),
                );
              },
              child: IslandIcon(widget.icon, size: 42),
            ),
            Text(
              widget.title,
              strutStyle: const StrutStyle(
                fontSize: 15,
                height: 22 / 15,
                forceStrutHeight: true,
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: GalleryPalette.homeCardTitle,
              ),
            ),
            const SizedBox(height: 6),
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                color: GalleryPalette.homeCardBody,
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

/// Reference S.footerLink: `inline-flex`, centred, 4px gap before the label.
class _HomeFooterAction extends StatelessWidget {
  const _HomeFooterAction(this.label, this.onPressed, {this.leading});
  final String label;
  final VoidCallback onPressed;
  final Widget? leading;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: onPressed,
    style:
        TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: HomeWallpaperInk.body,
          // Reference footer links are plain pointer spans: no hover wash or
          // ripple. Keyboard focus keeps a visible highlight.
          splashFactory: NoSplash.splashFactory,
          textStyle: const TextStyle(
            fontFamily: 'Nunito',
            // The style replaces the theme label style, so it restates the CJK
            // fallback; without it 组件文档 has no glyphs.
            fontFamilyFallback: ['IslandGallerySans'],
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.focused)
                ? HomeWallpaperInk.body.withValues(alpha: .12)
                : Colors.transparent,
          ),
        ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        ?leading,
        Text(
          label,
          strutStyle: const StrutStyle(
            fontSize: 13,
            height: 20 / 13,
            forceStrutHeight: true,
          ),
        ),
      ],
    ),
  );
}

/// The footer GitHub link mark: a decorative 14px vector beside the label,
/// raised 1px, in the link colour. Path data is the inline SVG in the
/// reference demo/HomePage.tsx (v4.0.0) on its 16-unit viewBox.
class _GitHubMark extends StatelessWidget {
  const _GitHubMark();
  @override
  Widget build(BuildContext context) => Transform.translate(
    offset: const Offset(0, -1),
    child: const SizedBox.square(
      dimension: 14,
      child: CustomPaint(painter: _GitHubMarkPainter()),
    ),
  );
}

class _GitHubMarkPainter extends CustomPainter {
  const _GitHubMarkPainter();

  static const pathData =
      'M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 '
      '0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13'
      '-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66'
      '.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15'
      '-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27s1.36.09'
      ' 2 .27c1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82'
      ' 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01'
      ' 2.2 0 .21.15.46.55.38A8.01 8.01 0 0 0 16 8c0-4.42-3.58-8-8-8z';

  /// Parses the commands this path uses: M, C/c, S/s, A and Z.
  static final Path mark = () {
    final path = Path();
    final tokens = RegExp(r'[MCcSsAZz]|[+-]?(?:\d+\.?\d*|\.\d+)')
        .allMatches(pathData)
        .map((m) => m[0]!)
        .toList();
    var i = 0;
    var command = '';
    var current = Offset.zero;
    var control = Offset.zero;
    double next() => double.parse(tokens[i++]);
    while (i < tokens.length) {
      if (RegExp(r'[A-Za-z]').hasMatch(tokens[i])) command = tokens[i++];
      final relative = command == command.toLowerCase() ? current : Offset.zero;
      switch (command.toUpperCase()) {
        case 'M':
          current = relative + Offset(next(), next());
          path.moveTo(current.dx, current.dy);
          control = current;
        case 'C':
          final c1 = relative + Offset(next(), next());
          final c2 = relative + Offset(next(), next());
          final end = relative + Offset(next(), next());
          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
          control = c2;
          current = end;
        case 'S':
          final c1 = current * 2 - control;
          final c2 = relative + Offset(next(), next());
          final end = relative + Offset(next(), next());
          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
          control = c2;
          current = end;
        case 'A':
          final radius = Radius.elliptical(next(), next());
          final rotation = next();
          final largeArc = next() != 0;
          final clockwise = next() != 0;
          current = relative + Offset(next(), next());
          path.arcToPoint(
            current,
            radius: radius,
            rotation: rotation,
            largeArc: largeArc,
            clockwise: clockwise,
          );
          control = current;
        case 'Z':
          path.close();
      }
    }
    return path;
  }();

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 16)
      ..drawPath(mark, Paint()..color = HomeWallpaperInk.body);
  }

  @override
  bool shouldRepaint(_GitHubMarkPainter old) => false;
}

/// Reference scroll-hint arrow: `M12 5v14M5 12l7 7 7-7`, stroke 2 on a 24
/// viewBox drawn at 16px, round caps and joins.
class _ScrollHintArrow extends CustomPainter {
  const _ScrollHintArrow();
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.drawPath(
      Path()
        ..moveTo(12 * s, 5 * s)
        ..lineTo(12 * s, 19 * s)
        ..moveTo(5 * s, 12 * s)
        ..lineTo(12 * s, 19 * s)
        ..lineTo(19 * s, 12 * s),
      Paint()
        ..color = HomeWallpaperInk.cream
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_ScrollHintArrow old) => false;
}
