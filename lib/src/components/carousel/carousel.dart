import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/timing/motion_policy.dart';

/// Cozy Animal Island swipeable Carousel / Slider (C11).
///
/// Features:
/// - Smooth page swiping with PageController.
/// - Autoplay that automatically pauses when `TickerMode` is disabled (e.g. backgrounded or obscured),
///   on mouse hover, or when focused.
/// - Controlled and uncontrolled active index support.
/// - Accessible arrow controls and keyboard-accessible dot indicators.
class AnimalCarousel extends StatefulWidget {
  final List<Widget> items;
  final double height;
  final int? activeIndex;
  final int defaultActiveIndex;
  final ValueChanged<int>? onChange;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool showArrows;
  final bool showDots;
  final bool pauseOnHover;
  final bool loop;

  /// Owner-provided visibility for autoplay; it does not hide layout.
  final bool visible;

  /// Clock used to measure autoplay elapsed time. Defaults to [SystemClock].
  final AnimalClock clock;

  const AnimalCarousel({
    super.key,
    required this.items,
    this.height = 200.0,
    this.activeIndex,
    this.defaultActiveIndex = 0,
    this.onChange,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showArrows = true,
    this.showDots = true,
    this.pauseOnHover = true,
    this.loop = true,
    this.visible = true,
    this.clock = const SystemClock(),
  });

  @override
  State<AnimalCarousel> createState() => _AnimalCarouselState();
}

class _AnimalCarouselState extends State<AnimalCarousel> {
  late PageController _pageController;
  late int _currentIndex;
  late AnimalMotionScheduler _motionScheduler;
  late AnimalMotionRegistration _autoplay;
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _isControlled => widget.activeIndex != null;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.activeIndex ?? widget.defaultActiveIndex;
    if (widget.items.isNotEmpty) {
      _currentIndex = _currentIndex.clamp(0, widget.items.length - 1);
    } else {
      _currentIndex = 0;
    }
    _pageController = PageController(initialPage: _currentIndex);
    _motionScheduler = AnimalMotionScheduler(clock: widget.clock);
    _autoplay = _motionScheduler.schedulePeriodic(
      interval: widget.autoPlayInterval,
      work: AnimalScheduledWork.decorative,
      eligible: false,
      onTick: (_, _) => _next(),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAutoplayEligibility();
  }

  @override
  void didUpdateWidget(AnimalCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clock != widget.clock) {
      _motionScheduler.updateClock(widget.clock);
    }
    if (widget.items.isNotEmpty && _currentIndex >= widget.items.length) {
      _currentIndex = widget.items.length - 1;
    }

    if (_isControlled &&
        widget.activeIndex != null &&
        widget.activeIndex != _currentIndex) {
      _currentIndex = widget.activeIndex!.clamp(
        0,
        widget.items.isNotEmpty ? widget.items.length - 1 : 0,
      );
      if (_pageController.hasClients &&
          _pageController.page?.round() != _currentIndex) {
        _animateToPage(_currentIndex);
      }
    }

    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.items.length != widget.items.length) {
      _autoplay.updateInterval(widget.autoPlayInterval);
    }
    _syncAutoplayEligibility();
  }

  @override
  void dispose() {
    _motionScheduler.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _syncAutoplayEligibility() {
    _autoplay.setEligible(
      widget.autoPlay &&
          widget.items.length > 1 &&
          AnimalMotionPolicy.decorativeContextEligible(
            context,
            focused: _isFocused,
            hovered: _isHovered && widget.pauseOnHover,
            visible: widget.visible,
          ),
    );
  }

  void _onPageChanged(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
    widget.onChange?.call(index);
  }

  void _animateToPage(int index) {
    final motion = AnimalIslandTheme.of(context).motion;
    _pageController.animateToPage(
      index,
      duration: motion.normal,
      curve: motion.ease,
    );
  }

  void _prev() {
    if (widget.items.length <= 1) return;
    if (_currentIndex > 0) {
      _animateToPage(_currentIndex - 1);
    } else if (widget.loop) {
      _animateToPage(widget.items.length - 1);
    }
  }

  void _next() {
    if (widget.items.length <= 1) return;
    if (_currentIndex < widget.items.length - 1) {
      _animateToPage(_currentIndex + 1);
    } else if (widget.loop) {
      _animateToPage(0);
    }
  }

  void _goTo(int index) {
    if (index < 0 || index >= widget.items.length || index == _currentIndex) {
      return;
    }
    _animateToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;

    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colors.surfaceAlt,
            borderRadius: theme.radii.cardBorder,
            border: Border.all(color: theme.colors.border),
          ),
        ),
      );
    }

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (bool focused) {
        if (_isFocused == focused) return;
        _isFocused = focused;
        _syncAutoplayEligibility();
      },
      child: MouseRegion(
        onEnter: (_) {
          if (_isHovered) return;
          _isHovered = true;
          _syncAutoplayEligibility();
        },
        onExit: (_) {
          if (!_isHovered) return;
          _isHovered = false;
          _syncAutoplayEligibility();
        },
        child: SizedBox(
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: theme.radii.cardBorder,
                    child: widget.items[index],
                  );
                },
              ),
              if (widget.showArrows && widget.items.length > 1) ...[
                Positioned(
                  left: theme.spacing.md,
                  child: InteractiveRegion(
                    depth: 2.0,
                    surfaceColor: theme.colors.bgContent,
                    borderRadius: theme.radii.pillBorder,
                    padding: EdgeInsets.all(theme.spacing.sm),
                    semanticLabel: localizations.carouselPreviousSlide,
                    onPressed: _prev,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 20.0,
                      color: theme.colors.text,
                    ),
                  ),
                ),
                Positioned(
                  right: theme.spacing.md,
                  child: InteractiveRegion(
                    depth: 2.0,
                    surfaceColor: theme.colors.bgContent,
                    borderRadius: theme.radii.pillBorder,
                    padding: EdgeInsets.all(theme.spacing.sm),
                    semanticLabel: localizations.carouselNextSlide,
                    onPressed: _next,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      size: 20.0,
                      color: theme.colors.text,
                    ),
                  ),
                ),
              ],
              if (widget.showDots && widget.items.length > 1)
                Positioned(
                  bottom: theme.spacing.md,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: theme.spacing.sm,
                      vertical: theme.spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.bgContent.withValues(alpha: 0.75),
                      borderRadius: theme.radii.pillBorder,
                      boxShadow: [theme.shadows.softElevation],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < widget.items.length; i++) ...[
                          if (i > 0) SizedBox(width: theme.spacing.xs),
                          _DotIndicator(
                            index: i,
                            total: widget.items.length,
                            isSelected: i == _currentIndex,
                            theme: theme,
                            onTap: () => _goTo(i),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int index;
  final int total;
  final bool isSelected;
  final AnimalIslandTheme theme;
  final VoidCallback onTap;

  const _DotIndicator({
    required this.index,
    required this.total,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveRegion(
      onPressed: onTap,
      enableHaptics: false,
      selected: isSelected,
      semanticLabel: AnimalLocalizations.of(context)!
          .carouselSlidePosition(index + 1, total),
      minimumHitSize: 48,
      child: Center(
        child: AnimatedContainer(
          duration: theme.motion.fast,
          curve: theme.motion.ease,
          width: isSelected ? 20.0 : 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colors.primaryText
                : theme.colors.textSecondary,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      ),
    );
  }
}
