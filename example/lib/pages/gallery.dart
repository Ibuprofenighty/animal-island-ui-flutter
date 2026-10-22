import 'dart:ui' show ImageFilter, PointMode;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../shared/catalog.dart';
import '../shared/background_preview.dart';
import 'stories/registry.dart';
import 'home.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({
    super.key,
    required this.path,
    required this.onNavigate,
    this.wallpaperSeed,
  });
  final String path;
  final ValueChanged<String> onNavigate;
  final int? wallpaperSeed;
  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  IslandBackgroundType? _preview;
  final _content = ScrollController(), _menu = ScrollController();
  final _scaffold = GlobalKey<ScaffoldState>();
  @override
  void dispose() {
    _content.dispose();
    _menu.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GalleryPage old) {
    super.didUpdateWidget(old);
    if (old.path != widget.path) {
      _preview = null;
      if (_content.hasClients) _content.jumpTo(0);
    }
  }

  String get id => widget.path.replaceFirst('/', '');
  GalleryEntry? get entry {
    for (final group in galleryGroups.values) {
      for (final item in group) {
        if (item.id == id) return item;
      }
    }
    return null;
  }

  void go(String value) {
    _scaffold.currentState?.closeDrawer();
    widget.onNavigate('/$value');
    if (value == 'background') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && id == value)
          setState(() => _preview = IslandBackgroundType.sprinkles);
      });
    }
  }

  Widget menu({bool mobile = false}) => Container(
    width: mobile ? 240 : 220,
    margin: mobile ? EdgeInsets.zero : const EdgeInsets.fromLTRB(12, 12, 0, 12),
    decoration: BoxDecoration(
      color: const Color(0xfffaf8f3),
      border: Border.all(color: const Color(0xfffafafa), width: 2),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1a3d3428),
          offset: Offset(0, 4),
          blurRadius: 16,
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: CustomPaint(
      painter: const _MenuWave(),
      child: Column(
        children: [
          InkWell(
            onTap: () => widget.onNavigate('/'),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xffe8e2d6))),
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/reference/logo.png',
                    width: 25,
                    height: 25,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Animal Island UI',
                    style: TextStyle(
                      fontFamily: 'GROBOLD',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: IslandTokens.light.onCanvas,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _menu,
              padding: const EdgeInsets.only(top: 8, bottom: 82),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final group in galleryGroups.entries) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        '── ${group.key} ──',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .5,
                          color: IslandTokens.light.onCanvas,
                        ),
                      ),
                    ),
                    for (final item in group.value)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          5,
                          1,
                          5,
                          item == group.value.last ? 1 : 0,
                        ),
                        child: TextButton(
                          onPressed: () => go(item.id),
                          style: TextButton.styleFrom(
                            alignment: Alignment.centerLeft,
                            minimumSize: const Size(0, 40),
                            visualDensity: VisualDensity.standard,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: const EdgeInsets.fromLTRB(26, 0, 12, 0),
                            backgroundColor: item.id == id
                                ? const Color(0xffb7c6e5)
                                : Colors.transparent,
                            foregroundColor: IslandTokens.light.onCanvas,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Nunito',
                              fontFamilyFallback: ['IslandGallerySans'],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.label)),
                              if (item.isNew)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff9786b),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: IslandTokens.light.onDanger,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 768;
    final showMobileNavigation = mobile && widget.path != '/';
    final info = entry;
    final colorOrder = [
      IslandPalette.lime,
      IslandPalette.green,
      IslandPalette.pink,
      IslandPalette.purple,
      IslandPalette.blue,
      IslandPalette.yellow,
      IslandPalette.orange,
      IslandPalette.red,
      IslandPalette.yellowGreen,
      IslandPalette.brown,
      IslandPalette.peach,
    ];
    final palette =
        colorOrder[id.codeUnits.fold<int>(0, (a, b) => a + b) %
            colorOrder.length];
    Widget content;
    if (widget.path == '/') {
      content = GalleryHome(
        onNavigate: go,
        wallpaperSeed: widget.wallpaperSeed,
      );
    } else if (info == null) {
      content = const Center(child: Text('页面不存在'));
    } else {
      content = SingleChildScrollView(
        controller: _content,
        padding: EdgeInsets.fromLTRB(
          mobile ? 16 : 40,
          mobile ? 16 : 32,
          mobile ? 16 : 40,
          40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18, bottom: 30),
              child: IslandTitle(
                size: IslandSize.large,
                palette: palette,
                child: Text(info.title),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: IslandTypewriter.builder(
                info.description,
                trigger: info.id,
                speed: const Duration(milliseconds: 30),
                builder: (context, shown) => Text(
                  // Browser text keeps solid ASCII slash words together. The
                  // Typewriter still exposes the original unmodified text.
                  shown.replaceAllMapped(
                    RegExp(r'(?<=[a-zA-Z0-9])/(?=[a-zA-Z0-9])'),
                    (_) => '\u2060/\u2060',
                  ),
                  strutStyle: StrutStyle.fromTextStyle(
                    Theme.of(context).textTheme.bodyMedium!
                        .copyWith(fontSize: 14, height: 1.5),
                    forceStrutHeight: true,
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: IslandTokens.light.onCanvas,
                    backgroundColor: _preview == null
                        ? null
                        : IslandTokens.light.paper,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (storyBuilders[id] != null) storyBuilders[id]!(context),
          ],
        ),
      );
    }
    return IslandDrawerHost(
      child: Scaffold(
        key: _scaffold,
        backgroundColor: const Color(0xff88c9a1),
        appBar: showMobileNavigation
            ? _GalleryMobileHeader(
                title: info?.title ?? 'Animal Island UI',
                onBack: () => widget.onNavigate('/'),
                onMenu: () => _scaffold.currentState!.openDrawer(),
              )
            : null,
        drawer: showMobileNavigation ? Drawer(child: menu(mobile: true)) : null,
        body: BackgroundPreview(
          onPreview: (type) {
            if (_preview != type) setState(() => _preview = type);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: _preview == null
                    ? const CustomPaint(painter: _GalleryDots())
                    : IslandBackground(type: _preview!),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!mobile && widget.path != '/')
                    FocusTraversalGroup(child: menu()),
                  Expanded(
                    child: FocusTraversalGroup(
                      child: PrimaryScrollController(
                        controller: _content,
                        child: content,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Gallery chrome owns the reference header geometry and its menu artwork.
class _GalleryMobileHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const _GalleryMobileHeader({
    required this.title,
    required this.onBack,
    required this.onMenu,
  });

  final String title;
  final VoidCallback onBack, onMenu;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final titleStyle = DefaultTextStyle.of(context).style.copyWith(
      fontSize: 15,
      height: 22 / 15,
      fontWeight: FontWeight.w700,
      color: IslandTokens.light.onCanvas,
    );
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: const Color.fromRGBO(255, 252, 244, .92),
          child: Container(
            height: preferredSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xffe8e2d6))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _GalleryHeaderAction(
                  onPressed: onBack,
                  label: '返回首页',
                  glyph: ExcludeSemantics(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Text(
                        '←',
                        style: TextStyle(
                          fontSize: 20,
                          height: 1,
                          color: IslandTokens.light.onCanvas,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  title,
                  style: titleStyle,
                  strutStyle: StrutStyle.fromTextStyle(
                    titleStyle,
                    forceStrutHeight: true,
                  ),
                ),
                _GalleryHeaderAction(
                  onPressed: onMenu,
                  label: '打开导航',
                  glyph: const ExcludeSemantics(
                    child: SizedBox(
                      // The observed Arial menu advance at 20px, without a
                      // system-font dependency or a missing Unicode glyph.
                      width: 17.96875,
                      height: 20,
                      child: CustomPaint(painter: _GalleryMenuGlyph()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryHeaderAction extends StatelessWidget {
  const _GalleryHeaderAction({
    required this.label,
    required this.onPressed,
    required this.glyph,
  });

  final String label;
  final VoidCallback onPressed;
  final Widget glyph;

  @override
  Widget build(BuildContext context) => IslandTooltip(
    message: label,
    excludeFromSemantics: true,
    child: IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        foregroundColor: IslandTokens.light.onCanvas,
        visualDensity: VisualDensity.standard,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Semantics(label: label, child: glyph),
    ),
  );
}

class _GalleryMenuGlyph extends CustomPainter {
  const _GalleryMenuGlyph();

  @override
  void paint(Canvas canvas, Size size) {
    // Reference Arial ink: equal 14x2px bars, a 6px pitch and a 3.5px
    // first-bar inset within the 20px line box. This is Gallery artwork.
    final paint = Paint()
      ..color = IslandTokens.light.onCanvas
      ..isAntiAlias = false;
    final left = (size.width - 14) / 2;
    for (var row = 0; row < 3; row++) {
      canvas.drawRect(Rect.fromLTWH(left, 3.5 + row * 6, 14, 2), paint);
    }
  }

  @override
  bool shouldRepaint(_GalleryMenuGlyph old) => false;
}

class _MenuWave extends CustomPainter {
  const _MenuWave();
  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height - 60;
    canvas.drawPath(
      Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(55, y - 30, 110, y)
        ..quadraticBezierTo(165, y + 30, 220, y)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xffa2b0e7),
    );
  }

  @override
  bool shouldRepaint(_MenuWave old) => false;
}

class _GalleryDots extends CustomPainter {
  const _GalleryDots();
  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in [
      (28.0, 3.0, const Color(0x665aa069)),
      (14.0, 2.0, const Color(0x4d6eb47d)),
    ]) {
      final points = <Offset>[
        for (double x = 14; x < size.width; x += layer.$1)
          for (double y = 14; y < size.height; y += layer.$1) Offset(x, y),
      ];
      canvas.drawPoints(
        PointMode.points,
        points,
        Paint()
          ..color = layer.$3
          ..strokeWidth = layer.$2
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_GalleryDots old) => false;
}
