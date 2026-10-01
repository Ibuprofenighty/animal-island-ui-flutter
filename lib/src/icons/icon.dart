import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../foundation/localization/generated/animal_localizations.g.dart';
import '../foundation/theme/theme.dart';
import '../internal/interaction/interactive_region.dart';
import '../internal/timing/motion_policy.dart';
import 'icon_data.dart';
import 'svg_transform.dart';

/// Single, production-grade Animal Island Icon renderer.
///
/// Features:
/// - Renders any canonical [AnimalIconData] or custom SVG markup
/// - Preserves authentic multi-color fills by default
/// - Safe alpha-aware stroke tinting via [strokeColor] (Defect F05 fix)
/// - Optional pure monochrome silhouette via [monochrome: true]
/// - Micro-tactile bounce animation ([bounce: true]), automatically respecting
///   the system's Reduced Motion preferences
/// - Accessible touch target (48dp hit region) and keyboard activation (Enter/Space)
///   when [onTap] is provided
/// - Decorative semantics suppression by default unless [semanticLabel] is specified
class AnimalIcon extends StatefulWidget {
  /// The icon data descriptor to render.
  final AnimalIconData data;

  /// Width and height dimension in logical pixels. Default is 24.0.
  final double size;

  /// Tint color for monochrome mode, or fallback stroke color.
  final Color? color;

  /// Explicit stroke tint overriding the default dark outline while preserving multi-color fills.
  final Color? strokeColor;

  /// Custom stroke width overriding the SVG default. A value of 0 removes strokes.
  final double? strokeWidth;

  /// Whether to render the icon as a monochrome silhouette. Default is false.
  final bool monochrome;

  /// Whether to play a playful bouncy spring animation on tap. Default is false.
  final bool bounce;

  /// Optional tap callback. When provided, the icon becomes interactive with
  /// a 48dp minimum hit area and full keyboard focus/action support.
  final VoidCallback? onTap;

  /// Optional external [FocusNode] when interactive.
  final FocusNode? focusNode;

  /// Optional accessibility label for screen readers.
  final String? semanticLabel;

  /// Creates a canonical [AnimalIcon].
  const AnimalIcon({
    super.key,
    required this.data,
    this.size = 24.0,
    this.color,
    this.strokeColor,
    this.strokeWidth,
    this.monochrome = false,
    this.bounce = false,
    this.onTap,
    this.focusNode,
    this.semanticLabel,
  }) : assert(size >= 0, 'AnimalIcon size cannot be negative.');

  @override
  State<AnimalIcon> createState() => _AnimalIconState();
}

class _AnimalIconState extends State<AnimalIcon>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scaleAnimation;
  Duration? _motionDuration;
  Curve? _motionEase;
  Curve? _motionSpring;
  void _initAnimation() {
    if (_controller != null) return;
    _controller = AnimationController(vsync: this, duration: _motionDuration!);
    _scaleAnimation = _createScaleAnimation();
  }

  Animation<double> _createScaleAnimation() => TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.25,
      ).chain(CurveTween(curve: _motionEase!)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.25,
        end: 0.92,
      ).chain(CurveTween(curve: _motionEase!)),
      weight: 30,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.92,
        end: 1.0,
      ).chain(CurveTween(curve: _motionSpring!)),
      weight: 30,
    ),
  ]).animate(_controller!);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final motion = AnimalIslandTheme.of(context).motion;
    _motionDuration = motion.normal;
    _motionEase = motion.ease;
    _motionSpring = motion.spring;
    if (widget.bounce) {
      if (_controller == null) {
        _initAnimation();
      } else {
        _controller!.duration = motion.normal;
        _scaleAnimation = _createScaleAnimation();
      }
    }
  }

  @override
  void didUpdateWidget(AnimalIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.bounce && _controller == null) {
      _initAnimation();
    } else if (!widget.bounce && _controller != null) {
      _controller?.dispose();
      _controller = null;
      _scaleAnimation = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _triggerTap() {
    if (widget.onTap == null) return;
    if (widget.bounce && AnimalMotionPolicy.shouldAnimate(context)) {
      _controller?.forward(from: 0.0);
    }
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStroke =
        widget.strokeColor ?? (!widget.monochrome ? widget.color : null);
    final effectiveTint = widget.color ?? widget.strokeColor;

    final transformedSvg = transformSvg(
      rawSvg: widget.data.svg,
      strokeColor: effectiveStroke,
      strokeWidth: widget.strokeWidth,
    );

    Widget coreGraphic = SvgPicture.string(
      transformedSvg,
      width: widget.size,
      height: widget.size,
      fit: BoxFit.contain,
      colorFilter: (widget.monochrome && effectiveTint != null)
          ? ColorFilter.mode(effectiveTint, BlendMode.srcIn)
          : null,
    );

    if (widget.bounce &&
        _scaleAnimation != null &&
        AnimalMotionPolicy.shouldAnimate(context)) {
      coreGraphic = ScaleTransition(
        scale: _scaleAnimation!,
        child: coreGraphic,
      );
    }

    final isInteractive = widget.onTap != null;
    final effectiveLabel = widget.semanticLabel ?? widget.data.semanticLabel;

    if (!isInteractive) {
      if (effectiveLabel != null && effectiveLabel.isNotEmpty) {
        return Semantics(
          label: effectiveLabel,
          image: true,
          child: coreGraphic,
        );
      }
      return ExcludeSemantics(excluding: true, child: coreGraphic);
    }

    // Interactive icon: 48dp touch target, focus ring, keyboard action (ICO04)
    return InteractiveRegion(
      onPressed: _triggerTap,
      enableHaptics: false,
      focusNode: widget.focusNode,
      semanticLabel:
          effectiveLabel ??
          AnimalLocalizations.of(context)!.iconSemanticName(widget.data.name),
      child: Center(child: coreGraphic),
    );
  }
}
