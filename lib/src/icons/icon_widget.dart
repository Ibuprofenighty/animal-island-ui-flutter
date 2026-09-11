import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'animal_icons.dart';
import 'svg_data.dart';
import '../tokens/shadows.dart';

export 'animal_icons.dart';

String _colorToHex(Color c) {
  final r = (c.r * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final g = (c.g * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  final b = (c.b * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  return '#$r$g$b';
}

/// Primary Animal Island Icon component.
///
/// Supports:
/// - 101 Kawaii animal island vector illustrations
/// - High-fidelity authentic multi-color fills by default
/// - Custom stroke tint ([color] or [strokeColor]) without destroying multi-color fills
/// - Optional pure monochrome silhouette ([monochrome: true])
/// - Custom dimensions (size, default 24.0)
/// - Optional Q-bounce animation on tap / hover (bounce: true)
class AnimalIcon extends StatefulWidget {
  final AnimalIconName name;
  final String? svg;
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  const AnimalIcon({
    super.key,
    required this.name,
    this.svg,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
    this.focusNode,
  });

  @override
  State<AnimalIcon> createState() => _AnimalIconState();
}

class _AnimalIconState extends State<AnimalIcon> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  FocusNode? _internalFocusNode;
  bool _isFocused = false;
  static final Map<String, String> _svgCache = {};

  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    if (widget.bounce || widget.onTap != null) {
      _initAnimation();
    }
  }

  void _initAnimation() {
    if (_controller != null) return;
    _controller = AnimationController(
      vsync: this,
      duration: AnimalMotion.normal,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.92).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)), weight: 30),
    ]).animate(_controller!);
  }

  @override
  void didUpdateWidget(AnimalIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    final needsAnim = widget.bounce || widget.onTap != null;
    if (needsAnim && _controller == null) {
      _initAnimation();
    } else if (!needsAnim && _controller != null) {
      _controller?.dispose();
      _controller = null;
      _scaleAnimation = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _triggerBounce() {
    _controller?.forward(from: 0.0);
    widget.onTap?.call();
  }

  String _resolveSvgString(AnimalIconName name, double? strokeWidth, Color? effectiveStroke) {
    final hex = effectiveStroke != null ? _colorToHex(effectiveStroke) : '';
    final cacheKey = '${name.name}_${strokeWidth ?? 0}_$hex';
    final cached = _svgCache[cacheKey];
    if (cached != null) return cached;

    String svg = widget.svg ?? animalSvgLookup(name);
    if (svg.isEmpty) return '';

    if (strokeWidth != null) {
      svg = svg.replaceAll(RegExp(r'stroke-width="[^"]+"'), 'stroke-width="$strokeWidth"');
    }

    if (effectiveStroke != null) {
      svg = svg.replaceAll(RegExp(r'stroke="#[0-9a-fA-F]{3,8}"'), 'stroke="$hex"');
    }

    _svgCache[cacheKey] = svg;
    return svg;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStroke = widget.strokeColor ?? (!widget.monochrome ? widget.color : null);
    final svg = _resolveSvgString(widget.name, widget.strokeWidth, effectiveStroke);

    if (svg.isEmpty) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color?.withValues(alpha: 0.2) ?? const Color(0x22000000),
          ),
        ),
      );
    }

    Widget iconWidget = SvgPicture.string(
      svg,
      width: widget.size,
      height: widget.size,
      colorFilter: (widget.monochrome && widget.color != null)
          ? ColorFilter.mode(widget.color!, BlendMode.srcIn)
          : null,
    );

    final hasTap = widget.onTap != null;
    if (widget.bounce || hasTap) {
      iconWidget = FocusableActionDetector(
        focusNode: hasTap ? _effectiveFocusNode : null,
        enabled: hasTap,
        mouseCursor: hasTap ? SystemMouseCursors.click : MouseCursor.defer,
        onShowFocusHighlight: (val) => setState(() => _isFocused = val),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _triggerBounce();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTap: _triggerBounce,
          child: _scaleAnimation != null
              ? ScaleTransition(
                  scale: _scaleAnimation!,
                  child: iconWidget,
                )
              : iconWidget,
        ),
      );
    }

    return Semantics(
      button: hasTap,
      label: widget.name.name,
      child: Container(
        decoration: _isFocused
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFCC00).withValues(alpha: 0.8),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              )
            : null,
        child: iconWidget,
      ),
    );
  }
}

/// Standalone AirplaneIcon widget.
class AirplaneIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const AirplaneIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.airplane,
      svg: animalSvgAirplane,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone AnchorIcon widget.
class AnchorIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const AnchorIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.anchor,
      svg: animalSvgAnchor,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone AppleIcon widget.
class AppleIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const AppleIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.apple,
      svg: animalSvgApple,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BalloonIcon widget.
class BalloonIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BalloonIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.balloon,
      svg: animalSvgBalloon,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BearIcon widget.
class BearIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BearIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bear,
      svg: animalSvgBear,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BeeIcon widget.
class BeeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BeeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bee,
      svg: animalSvgBee,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BellIcon widget.
class BellIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BellIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bell,
      svg: animalSvgBell,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BicycleIcon widget.
class BicycleIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BicycleIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bicycle,
      svg: animalSvgBicycle,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BirdIcon widget.
class BirdIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BirdIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bird,
      svg: animalSvgBird,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BookIcon widget.
class BookIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BookIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.book,
      svg: animalSvgBook,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BookmarkIcon widget.
class BookmarkIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BookmarkIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bookmark,
      svg: animalSvgBookmark,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone BulbIcon widget.
class BulbIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const BulbIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.bulb,
      svg: animalSvgBulb,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ButterflyIcon widget.
class ButterflyIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ButterflyIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.butterfly,
      svg: animalSvgButterfly,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CactusIcon widget.
class CactusIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CactusIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.cactus,
      svg: animalSvgCactus,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CakeIcon widget.
class CakeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CakeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.cake,
      svg: animalSvgCake,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CalendarIcon widget.
class CalendarIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CalendarIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.calendar,
      svg: animalSvgCalendar,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CameraIcon widget.
class CameraIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CameraIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.camera,
      svg: animalSvgCamera,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CandleIcon widget.
class CandleIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CandleIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.candle,
      svg: animalSvgCandle,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CarIcon widget.
class CarIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CarIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.car,
      svg: animalSvgCar,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CartIcon widget.
class CartIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CartIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.cart,
      svg: animalSvgCart,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CatIcon widget.
class CatIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CatIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.cat,
      svg: animalSvgCat,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ChatIcon widget.
class ChatIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ChatIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.chat,
      svg: animalSvgChat,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CheckIcon widget.
class CheckIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CheckIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.check,
      svg: animalSvgCheck,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CherryIcon widget.
class CherryIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CherryIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.cherry,
      svg: animalSvgCherry,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ClockIcon widget.
class ClockIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ClockIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.clock,
      svg: animalSvgClock,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CloseIcon widget.
class CloseIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CloseIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.close,
      svg: animalSvgClose,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CloudIcon widget.
class CloudIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CloudIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.cloud,
      svg: animalSvgCloud,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CodeIcon widget.
class CodeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CodeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.code,
      svg: animalSvgCode,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CoffeeIcon widget.
class CoffeeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CoffeeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.coffee,
      svg: animalSvgCoffee,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CompassIcon widget.
class CompassIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CompassIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.compass,
      svg: animalSvgCompass,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone CreditCardIcon widget.
class CreditCardIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const CreditCardIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.creditCard,
      svg: animalSvgCreditCard,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone DogIcon widget.
class DogIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const DogIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.dog,
      svg: animalSvgDog,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone DonutIcon widget.
class DonutIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const DonutIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.donut,
      svg: animalSvgDonut,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone DownloadIcon widget.
class DownloadIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const DownloadIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.download,
      svg: animalSvgDownload,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone EditIcon widget.
class EditIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const EditIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.edit,
      svg: animalSvgEdit,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone EyeIcon widget.
class EyeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const EyeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.eye,
      svg: animalSvgEye,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FileIcon widget.
class FileIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FileIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.file,
      svg: animalSvgFile,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FishIcon widget.
class FishIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FishIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.fish,
      svg: animalSvgFish,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FlagIcon widget.
class FlagIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FlagIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.flag,
      svg: animalSvgFlag,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FlameIcon widget.
class FlameIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FlameIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.flame,
      svg: animalSvgFlame,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FlowerIcon widget.
class FlowerIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FlowerIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.flower,
      svg: animalSvgFlower,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FolderIcon widget.
class FolderIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FolderIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.folder,
      svg: animalSvgFolder,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FoxIcon widget.
class FoxIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FoxIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.fox,
      svg: animalSvgFox,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone FrogIcon widget.
class FrogIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const FrogIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.frog,
      svg: animalSvgFrog,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone GiftIcon widget.
class GiftIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const GiftIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.gift,
      svg: animalSvgGift,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone GlobeIcon widget.
class GlobeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const GlobeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.globe,
      svg: animalSvgGlobe,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone HeadphonesIcon widget.
class HeadphonesIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const HeadphonesIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.headphones,
      svg: animalSvgHeadphones,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone HeartIcon widget.
class HeartIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const HeartIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.heart,
      svg: animalSvgHeart,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone HomeIcon widget.
class HomeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const HomeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.home,
      svg: animalSvgHome,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone IcecreamIcon widget.
class IcecreamIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const IcecreamIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.icecream,
      svg: animalSvgIcecream,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone AnimalImageIcon widget (disambiguated from flutter/material.dart).
class AnimalImageIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const AnimalImageIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.image,
      svg: animalSvgImage,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone KeyIcon widget.
class KeyIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const KeyIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.key,
      svg: animalSvgKey,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone LadybugIcon widget.
class LadybugIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const LadybugIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.ladybug,
      svg: animalSvgLadybug,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone LampIcon widget.
class LampIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const LampIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.lamp,
      svg: animalSvgLamp,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone LeafIcon widget.
class LeafIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const LeafIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.leaf,
      svg: animalSvgLeaf,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone LemonIcon widget.
class LemonIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const LemonIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.lemon,
      svg: animalSvgLemon,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone LocationIcon widget.
class LocationIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const LocationIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.location,
      svg: animalSvgLocation,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone LockIcon widget.
class LockIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const LockIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.lock,
      svg: animalSvgLock,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MagnetIcon widget.
class MagnetIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MagnetIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.magnet,
      svg: animalSvgMagnet,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MailIcon widget.
class MailIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MailIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.mail,
      svg: animalSvgMail,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MapIcon widget.
class MapIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MapIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.map,
      svg: animalSvgMap,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MicIcon widget.
class MicIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MicIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.mic,
      svg: animalSvgMic,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MoonIcon widget.
class MoonIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MoonIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.moon,
      svg: animalSvgMoon,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MushroomIcon widget.
class MushroomIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MushroomIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.mushroom,
      svg: animalSvgMushroom,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone MusicIcon widget.
class MusicIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const MusicIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.music,
      svg: animalSvgMusic,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone OwlIcon widget.
class OwlIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const OwlIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.owl,
      svg: animalSvgOwl,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone PaintbrushIcon widget.
class PaintbrushIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const PaintbrushIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.paintbrush,
      svg: animalSvgPaintbrush,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone PencilIcon widget.
class PencilIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const PencilIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.pencil,
      svg: animalSvgPencil,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone PenguinIcon widget.
class PenguinIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const PenguinIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.penguin,
      svg: animalSvgPenguin,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone PhoneIcon widget.
class PhoneIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const PhoneIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.phone,
      svg: animalSvgPhone,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone PlayIcon widget.
class PlayIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const PlayIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.play,
      svg: animalSvgPlay,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone PlusIcon widget.
class PlusIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const PlusIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.plus,
      svg: animalSvgPlus,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone RabbitIcon widget.
class RabbitIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const RabbitIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.rabbit,
      svg: animalSvgRabbit,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone RainbowIcon widget.
class RainbowIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const RainbowIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.rainbow,
      svg: animalSvgRainbow,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone RefreshIcon widget.
class RefreshIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const RefreshIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.refresh,
      svg: animalSvgRefresh,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone RocketIcon widget.
class RocketIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const RocketIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.rocket,
      svg: animalSvgRocket,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SailboatIcon widget.
class SailboatIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SailboatIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.sailboat,
      svg: animalSvgSailboat,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SaveIcon widget.
class SaveIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SaveIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.save,
      svg: animalSvgSave,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SearchIcon widget.
class SearchIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SearchIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.search,
      svg: animalSvgSearch,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SettingsIcon widget.
class SettingsIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SettingsIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.settings,
      svg: animalSvgSettings,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ShareIcon widget.
class ShareIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ShareIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.share,
      svg: animalSvgShare,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ShoppingBagIcon widget.
class ShoppingBagIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ShoppingBagIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.shoppingBag,
      svg: animalSvgShoppingBag,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SmileIcon widget.
class SmileIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SmileIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.smile,
      svg: animalSvgSmile,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SnailIcon widget.
class SnailIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SnailIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.snail,
      svg: animalSvgSnail,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SnowflakeIcon widget.
class SnowflakeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SnowflakeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.snowflake,
      svg: animalSvgSnowflake,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone StarIcon widget.
class StarIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const StarIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.star,
      svg: animalSvgStar,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone StrawberryIcon widget.
class StrawberryIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const StrawberryIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.strawberry,
      svg: animalSvgStrawberry,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone SunIcon widget.
class SunIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const SunIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.sun,
      svg: animalSvgSun,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone TagIcon widget.
class TagIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const TagIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.tag,
      svg: animalSvgTag,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ThermometerIcon widget.
class ThermometerIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ThermometerIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.thermometer,
      svg: animalSvgThermometer,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone ThumbsUpIcon widget.
class ThumbsUpIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const ThumbsUpIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.thumbsUp,
      svg: animalSvgThumbsUp,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone TrainIcon widget.
class TrainIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const TrainIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.train,
      svg: animalSvgTrain,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone TrashIcon widget.
class TrashIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const TrashIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.trash,
      svg: animalSvgTrash,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone TreeIcon widget.
class TreeIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const TreeIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.tree,
      svg: animalSvgTree,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone TrophyIcon widget.
class TrophyIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const TrophyIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.trophy,
      svg: animalSvgTrophy,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone UmbrellaIcon widget.
class UmbrellaIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const UmbrellaIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.umbrella,
      svg: animalSvgUmbrella,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone UploadIcon widget.
class UploadIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const UploadIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.upload,
      svg: animalSvgUpload,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone UserIcon widget.
class UserIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const UserIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.user,
      svg: animalSvgUser,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone VideoIcon widget.
class VideoIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const VideoIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.video,
      svg: animalSvgVideo,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone WatermelonIcon widget.
class WatermelonIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const WatermelonIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.watermelon,
      svg: animalSvgWatermelon,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

/// Standalone WifiIcon widget.
class WifiIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? strokeColor;
  final double? strokeWidth;
  final bool monochrome;
  final bool bounce;
  final VoidCallback? onTap;

  const WifiIcon({
    super.key,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimalIcon(
      name: AnimalIconName.wifi,
      svg: animalSvgWifi,
      size: size,
      color: color,
      strokeColor: strokeColor,
      strokeWidth: strokeWidth,
      monochrome: monochrome,
      bounce: bounce,
      onTap: onTap,
    );
  }
}

