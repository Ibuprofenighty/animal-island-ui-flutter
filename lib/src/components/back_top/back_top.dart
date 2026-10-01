import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/interactive_region.dart';

/// Animal Island Back to Top floating button with signature rocket blast-off animation (C27).
///
/// Features:
/// - Smooth scroll threshold detection via [ScrollController].
/// - Signature rocket blast-off animation with anticipation dip and skyward ascent.
/// - Full accessibility: [InteractiveRegion] with keyboard activation (`Enter` / `Space`)
///   and clean single-layer semantics.
/// - Hit-test protection: uses [IgnorePointer] and zero opacity when below threshold (BTP01).
/// - Safe lifecycle: detaches listeners cleanly without disposing external controllers (BTP02).
class AnimalBackTop extends StatefulWidget {
  final ScrollController scrollController;
  final double visibilityHeight;
  final Duration duration;
  final Widget? icon;
  final VoidCallback? onClick;

  const AnimalBackTop({
    super.key,
    required this.scrollController,
    this.visibilityHeight = 400.0,
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

    // Blast-off animation sequence: subtle anticipation dip, then explosive rocket takeoff
    _launchOffsetY = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 6.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 6.0,
          end: -140.0,
        ).chain(CurveTween(curve: Curves.easeInQuad)),
        weight: 85,
      ),
    ]).animate(_launchController);

    _launchScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 0.5,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 80,
      ),
    ]).animate(_launchController);

    _launchOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_launchController);
  }

  @override
  void didUpdateWidget(covariant AnimalBackTop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController.removeListener(_handleScroll);
      widget.scrollController.addListener(_handleScroll);
      _handleScroll();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleScroll();
      });
    }
    if (oldWidget.visibilityHeight != widget.visibilityHeight) {
      _handleScroll();
    }
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_handleScroll);
    _launchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!mounted) return;
    final shouldBeVisible =
        widget.scrollController.hasClients &&
        widget.scrollController.offset >= widget.visibilityHeight;

    if (_visible != shouldBeVisible) {
      setState(() {
        _visible = shouldBeVisible;
      });
      if (!_visible && _launchController.isAnimating) {
        _launchController.reset();
      }
    }
  }

  void _scrollToTop() {
    if (!widget.scrollController.hasClients) return;
    if (_launchController.isAnimating) return;

    widget.onClick?.call();

    // Trigger explosive rocket blast-off animation
    _launchController.forward(from: 0.0).then((_) {
      if (mounted) {
        _launchController.reset();
      }
    });

    widget.scrollController.animateTo(
      0.0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: theme.motion.normal,
      curve: theme.motion.ease,
      child: AnimatedBuilder(
        animation: _launchController,
        builder: (context, child) {
          final double offsetY = _launchController.isAnimating
              ? _launchOffsetY.value
              : 0.0;
          final double scale = _launchController.isAnimating
              ? _launchScale.value
              : 1.0;
          final double launchOpacity = _launchController.isAnimating
              ? _launchOpacity.value
              : 1.0;

          return Transform.translate(
            offset: Offset(0, offsetY),
            child: Transform.scale(
              scale: scale,
              child: Opacity(opacity: launchOpacity, child: child),
            ),
          );
        },
        child: InteractiveRegion(
          onPressed: _visible ? _scrollToTop : null,
          visible: _visible,
          depth: 3.0,
          surfaceColor: theme.colors.bgContent,
          borderRadius: theme.radii.pillBorder,
          padding: EdgeInsets.all(theme.spacing.md),
          semanticLabel: AnimalLocalizations.of(context)!.backToTop,
          child:
              widget.icon ??
              AnimalIcon(
                data: AnimalIcons.rocket,
                size: 24.0,
                color: theme.colors.primaryText,
              ),
        ),
      ),
    );
  }
}
