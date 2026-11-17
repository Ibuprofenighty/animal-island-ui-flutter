import 'dart:ui' show ImageFilter, PointMode;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../shared/catalog.dart';
import '../shared/background_preview.dart';
import 'stories/registry.dart';
import 'home.dart';
import '../shared/palette.dart';

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
  /// Easter-egg wallpaper. [_preview] stays set while it fades out so the
  /// reference 0.45s opacity transition has a layer to fade.
  IslandBackgroundType? _preview;
  bool _previewOn = false;
  final _content = ScrollController(), _menu = ScrollController();

  void _showPreview(IslandBackgroundType? type) {
    if (type == null) {
      if (!_previewOn) return;
      setState(() {
        _previewOn = false;
        if (MediaQuery.disableAnimationsOf(context)) _preview = null;
      });
    } else if (_preview != type || !_previewOn) {
      setState(() {
        _preview = type;
        _previewOn = true;
      });
    }
  }

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
      // Leaving a page fades the wallpaper out (reference fadeOutEgg).
      _previewOn = false;
      if (MediaQuery.disableAnimationsOf(context)) _preview = null;
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
          _showPreview(IslandBackgroundType.sprinkles);
      });
    }
  }

  /// Reference sidebar aside: `margin: 12px 0 12px 12px` with
  /// `height: calc(100dvh - 20px)`, so it ends 8px above the viewport. The
  /// mobile drawer reuses it at 240px with its own `4px 0 24px` shadow.
  Widget menu({bool mobile = false}) => Container(
    width: mobile ? 240 : 220,
    margin: const EdgeInsets.fromLTRB(12, 12, 0, 8),
    decoration: BoxDecoration(
      color: GalleryPalette.sidebar,
      border: Border.all(color: GalleryPalette.sidebarBorder, width: 2),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        mobile
            ? const BoxShadow(
                color: GalleryPalette.sidebarShadowMobile,
                offset: Offset(4, 0),
                blurRadius: 24,
              )
            : const BoxShadow(
                color: GalleryPalette.sidebarShadow,
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
            // The reference header is a plain clickable row: no ripple or
            // hover wash. Keyboard focus keeps a visible highlight.
            splashFactory: NoSplash.splashFactory,
            overlayColor: _focusOnlyOverlay,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: GalleryPalette.rule)),
              ),
              child: Row(
                children: [
                  // Reference logo `transform: translateY(-2px)`.
                  Transform.translate(
                    offset: const Offset(0, -2),
                    child: Image.asset(
                      'assets/reference/logo.png',
                      width: 25,
                      height: 25,
                    ),
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
                        child: _menuItem(item),
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
  static final _focusOnlyOverlay = WidgetStateProperty.resolveWith<Color?>(
    (states) => states.contains(WidgetState.focused)
        ? IslandTokens.light.onCanvas.withValues(alpha: .12)
        : Colors.transparent,
  );

  /// Reference S.menuItem: inactive hover paints `#d6dff0` (`all 0.15s`), the
  /// active item stays `#B7C6E5`, and there is no press ripple. The sidebar
  /// Cursor item carries the reference raindrop hover cursor.
  Widget _menuItem(GalleryEntry item) {
    final active = item.id == id;
    Widget button = TextButton(
      onPressed: () => go(item.id),
      style:
          TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            minimumSize: const Size(0, 40),
            visualDensity: VisualDensity.standard,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.fromLTRB(26, 0, 12, 0),
            backgroundColor: active
                ? GalleryPalette.navActive
                : Colors.transparent,
            foregroundColor: IslandTokens.light.onCanvas,
            splashFactory: NoSplash.splashFactory,
            animationDuration: const Duration(milliseconds: 150),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontFamilyFallback: ['IslandGallerySans'],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.focused)
                  ? IslandTokens.light.onCanvas.withValues(alpha: .12)
                  : !active && states.contains(WidgetState.hovered)
                  ? GalleryPalette.navHover
                  : Colors.transparent,
            ),
          ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(child: Text(item.label)),
          if (item.isNew) _NewBadge(active: active),
        ],
      ),
    );
    if (item.id == 'cursor') {
      button = IslandCursor(
        variant: IslandCursorVariant.raindrop,
        child: button,
      );
    }
    return button;
  }

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
          mobile ? 16 : 32,
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
    // Reference App root: the default arrow Cursor covers the whole Gallery.
    return IslandCursor(
      child: IslandDrawerHost(
        child: Scaffold(
          key: _scaffold,
          backgroundColor: IslandTokens.light.canvas,
          appBar: showMobileNavigation
              ? _GalleryMobileHeader(
                  title: info?.title ?? 'Animal Island UI',
                  onBack: () => widget.onNavigate('/'),
                  onMenu: () => _scaffold.currentState!.openDrawer(),
                )
              : null,
          // Reference mobile drawer: the 240px sidebar aside with its 12px
          // margin over an rgba(0,0,0,.35) overlay. The Material Drawer keeps
          // its route semantics and focus scope but paints nothing itself.
          drawerScrimColor: GalleryPalette.drawerScrim,
          drawer: showMobileNavigation
              ? Drawer(
                  width: 252,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  child: menu(mobile: true),
                )
              : null,
          body: BackgroundPreview(
            onPreview: _showPreview,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _GalleryDots()),
                ),
                if (_preview != null)
                  Positioned.fill(
                    // Reference egg overlay: `opacity 0.45s ease` over the
                    // resident dotted wallpaper; decorative, so it may fade.
                    child: TweenAnimationBuilder<double>(
                      // `begin: 0` fades a newly mounted wallpaper in.
                      tween: Tween(begin: 0, end: _previewOn ? 1 : 0),
                      duration: MediaQuery.disableAnimationsOf(context)
                          ? Duration.zero
                          : const Duration(milliseconds: 450),
                      curve: Curves.ease,
                      onEnd: () {
                        if (mounted && !_previewOn) {
                          setState(() => _preview = null);
                        }
                      },
                      builder: (_, opacity, child) =>
                          Opacity(opacity: opacity, child: child),
                      child: IslandBackground(type: _preview!),
                    ),
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
          color: GalleryPalette.headerGlass,
          child: Container(
            height: preferredSize.height,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: GalleryPalette.rule)),
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
    // Reference: a 220x130 `no-repeat` image at left bottom. A wider aside
    // (the 240px drawer) keeps cream to the right of the 220px artwork.
    final y = size.height - 60;
    canvas.drawPath(
      Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(55, y - 30, 110, y)
        ..quadraticBezierTo(165, y + 30, 220, y)
        ..lineTo(220, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = GalleryPalette.sidebarWave,
    );
  }

  @override
  bool shouldRepaint(_MenuWave old) => false;
}

/// Reference S.menuBadge. Inactive: `linear-gradient(135deg,#fc736d,#f7825a)`
/// with a `0 1px 0 rgba(114,93,66,.25)` shadow; active: a white pill with a
/// `.15` shadow. `menuBadgePulse` scales 1 -> 1.08 -> 1 over 1.8s
/// ease-in-out. Text uses the readable danger roles (authorized colour
/// difference from the reference white / #fc736d text); reduced motion holds
/// the resting scale.
class _NewBadge extends StatefulWidget {
  const _NewBadge({required this.active});
  final bool active;
  @override
  State<_NewBadge> createState() => _NewBadgeState();
}

class _NewBadgeState extends State<_NewBadge>
    with SingleTickerProviderStateMixin {
  late final pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      pulse
        ..stop()
        ..value = 0;
    } else if (!pulse.isAnimating) {
      pulse.repeat();
    }
  }

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    // The pulse repeats indefinitely; isolate it so each tick repaints only
    // the badge layer, not the sidebar or page.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: pulse,
        builder: (_, child) {
          final t = pulse.value;
          final rise = Curves.easeInOut.transform(t < .5 ? t * 2 : 2 - t * 2);
          return Transform.scale(scale: 1 + .08 * rise, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
          decoration: BoxDecoration(
            color: active ? GalleryPalette.newBadgeActive : null,
            gradient: active
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      IslandColorway.red.accent,
                      GalleryPalette.newBadgeGradientEnd,
                    ],
                  ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: active
                    ? GalleryPalette.newBadgeShadowActive
                    : GalleryPalette.newBadgeShadow,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            'NEW',
            strutStyle: const StrutStyle(
              fontSize: 9,
              height: 14 / 9,
              forceStrutHeight: true,
            ),
            style: TextStyle(
              fontSize: 9,
              height: 14 / 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
              color: active
                  ? IslandTokens.light.dangerText
                  : IslandTokens.light.onDanger,
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryDots extends CustomPainter {
  const _GalleryDots();
  @override
  void paint(Canvas canvas, Size size) {
    for (final layer in [
      (28.0, 3.0, GalleryPalette.wallpaperLargeDot),
      (14.0, 2.0, GalleryPalette.wallpaperSmallDot),
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
