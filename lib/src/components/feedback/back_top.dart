import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import '../../tokens/theme.dart';
import '../../primitives/pressable.dart';
import '../../icons/icon_widget.dart';

/// Animal Island Back to Top floating button with signature rocket blast-off animation.
class AnimalBackTop extends StatefulWidget {
  /// The scroll controller to monitor and scroll to top.
  final ScrollController scrollController;

  /// Scroll distance in pixels before the button appears (default 400.0).
  final double visibilityHeight;

  /// Alias for [visibilityHeight] for backward compatibility.
  final double? visibilityThreshold;

  /// Duration of the scroll to top animation (default 500ms).
  final Duration duration;

  /// Custom icon widget overriding the default rocket icon.
  final Widget? icon;

  /// Callback when the back-to-top button is clicked.
  final VoidCallback? onClick;

  const AnimalBackTop({
    super.key,
    required this.scrollController,
    this.visibilityHeight = 400.0,
    this.visibilityThreshold,
    this.duration = const Duration(milliseconds: 500),
    this.icon,
    this.onClick,
  });

  @override
  State<AnimalBackTop> createState() => _AnimalBackTopState();
}

class _AnimalBackTopState extends State<AnimalBackTop>
    with SingleTickerProviderStateMixin {
  bool _visible = false;
  late AnimationController _launchController;
  late Animation<double> _launchOffsetY;
  late Animation<double> _launchScale;
  late Animation<double> _launchOpacity;

  double get _effectiveThreshold =>
      widget.visibilityThreshold ?? widget.visibilityHeight;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handleScroll();
    });

    _launchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Blast-off animation curve: subtle anticipation dip, then explosive rocket takeoff up into the sky
    _launchOffsetY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 6.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 6.0, end: -140.0)
            .chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 85,
      ),
    ]).animate(_launchController);

    _launchScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 80,
      ),
    ]).animate(_launchController);

    _launchOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_launchController);

    _launchController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Reset after blast off when scrolled to top
        if (mounted) {
          _launchController.reset();
        }
      }
    });
  }

  @override
  void didUpdateWidget(AnimalBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _launchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!widget.scrollController.hasClients) return;
    final isOver = widget.scrollController.offset > _effectiveThreshold;
    if (isOver != _visible) {
      setState(() => _visible = isOver);
    }
  }

  void _handleClick() {
    widget.onClick?.call();

    // Trigger rocket blast off animation
    _launchController.forward(from: 0.0);

    // Trigger smooth scroll to top
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        0.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final isAnimating = _launchController.isAnimating;
    return IgnorePointer(
      ignoring: !_visible && !isAnimating,
      child: Visibility(
        visible: _visible || isAnimating,
        child: AnimatedScale(
          scale: _visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutBack,
          child: AnimatedBuilder(
            animation: _launchController,
            builder: (context, child) {
              final isLaunching = _launchController.isAnimating;
              final wiggle = isLaunching && _launchController.value < 0.25
                  ? math.sin(_launchController.value * 30 * math.pi) * 3.0
                  : 0.0;

              return Transform.translate(
                offset: Offset(wiggle, _launchOffsetY.value),
                child: Transform.scale(
                  scale: _launchScale.value,
                  child: Opacity(
                    opacity: _launchOpacity.value.clamp(0.0, 1.0),
                    child: child,
                  ),
                ),
              );
            },
            child: AnimalPressable(
              semanticLabel: '回到顶部',
              onPressed: _handleClick,
              depth: 4.0,
              surfaceColor: theme.primary,
              depthColor: theme.primaryActive,
              borderRadius: BorderRadius.circular(24.0),
              padding: const EdgeInsets.all(12.0),
              child: widget.icon ??
                  const RocketIcon(size: 24, color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
      ),
    );
  }
}

