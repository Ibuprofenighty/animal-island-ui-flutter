import 'dart:async';
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../primitives/pressable.dart';

/// Cozy Animal Island swipeable Carousel / Slider.
class AnimalCarousel extends StatefulWidget {
  /// List of slide widgets to display.
  final List<Widget> items;

  /// Height of the slide viewport.
  final double height;

  /// Controlled active slide index.
  final int? activeIndex;

  /// Initial slide index in uncontrolled mode.
  final int defaultActiveIndex;

  /// Callback when the active slide index changes.
  final ValueChanged<int>? onChange;

  /// Whether slides advance automatically.
  final bool autoPlay;

  /// Autoplay advance interval (default 4 seconds).
  final Duration autoPlayInterval;

  /// Whether to show previous/next arrow buttons.
  final bool showArrows;

  /// Whether to show bottom dot/pill indicators.
  final bool showDots;

  /// Whether hovering pauses autoplay.
  final bool pauseOnHover;

  /// Whether carousel wraps seamlessly from end to beginning.
  final bool loop;

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
  });

  @override
  State<AnimalCarousel> createState() => _AnimalCarouselState();
}

class _AnimalCarouselState extends State<AnimalCarousel> {
  late PageController _pageController;
  late int _currentIndex;
  Timer? _timer;
  bool _isHovered = false;

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
    _restartTimer();
  }

  @override
  void didUpdateWidget(AnimalCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.isNotEmpty && _currentIndex >= widget.items.length) {
      _currentIndex = widget.items.length - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(_currentIndex);
      }
    } else if (widget.items.isEmpty) {
      _currentIndex = 0;
    }

    if (widget.activeIndex != null && widget.activeIndex != _currentIndex) {
      _currentIndex = widget.activeIndex!.clamp(0, (widget.items.length - 1).clamp(0, 999999));
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: AnimalMotion.normal,
          curve: AnimalMotion.ease,
        );
      }
    }

    if (oldWidget.autoPlay != widget.autoPlay ||
        oldWidget.autoPlayInterval != widget.autoPlayInterval ||
        oldWidget.items.length != widget.items.length) {
      _restartTimer();
    }
  }

  void _restartTimer() {
    _timer?.cancel();
    if (widget.autoPlay && widget.items.length > 1 && !_isHovered) {
      _timer = Timer.periodic(widget.autoPlayInterval, (_) {
        if (!mounted || widget.items.length <= 1) return;
        final nextIndex = (_currentIndex + 1);
        if (nextIndex >= widget.items.length && !widget.loop) {
          _timer?.cancel();
          return;
        }
        final targetIndex = nextIndex % widget.items.length;
        _goToPage(targetIndex);
      });
    }
  }

  void _goToPage(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: AnimalMotion.normal,
      curve: AnimalMotion.ease,
    );
  }

  void _handlePageChanged(int index) {
    setState(() => _currentIndex = index);
    widget.onChange?.call(index);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    if (widget.items.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No carousel items',
            style: AnimalTypography.body.copyWith(
              color: theme.textSecondary,
            ),
          ),
        ),
      );
    }

    Widget viewport = PageView.builder(
      controller: _pageController,
      itemCount: widget.items.length,
      onPageChanged: _handlePageChanged,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ClipRRect(
            borderRadius: AnimalRadii.cardBorder,
            child: widget.items[index],
          ),
        );
      },
    );

    if (widget.showArrows && widget.items.length > 1) {
      final btnSurface = theme.isDark ? theme.surfaceHeader : const Color(0xEEFFFFFF);
      final btnDepth = theme.isDark ? theme.border : const Color(0xFFD4C9B4);

      viewport = Stack(
        alignment: Alignment.center,
        children: [
          viewport,
          // Left chevron button
          Positioned(
            left: 12.0,
            child: AnimalPressable(
              semanticLabel: 'Previous slide',
              onPressed: () {
                final prev = _currentIndex - 1;
                if (prev >= 0) {
                  _goToPage(prev);
                } else if (widget.loop) {
                  _goToPage(widget.items.length - 1);
                }
              },
              depth: 2.0,
              surfaceColor: btnSurface,
              depthColor: btnDepth,
              borderRadius: BorderRadius.circular(20.0),
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.chevron_left_rounded,
                size: 22.0,
                color: theme.text,
              ),
            ),
          ),
          // Right chevron button
          Positioned(
            right: 12.0,
            child: AnimalPressable(
              semanticLabel: 'Next slide',
              onPressed: () {
                final next = _currentIndex + 1;
                if (next < widget.items.length) {
                  _goToPage(next);
                } else if (widget.loop) {
                  _goToPage(0);
                }
              },
              depth: 2.0,
              surfaceColor: btnSurface,
              depthColor: btnDepth,
              borderRadius: BorderRadius.circular(20.0),
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 22.0,
                color: theme.text,
              ),
            ),
          ),
        ],
      );
    }

    if (widget.pauseOnHover) {
      viewport = MouseRegion(
        onEnter: (_) {
          _isHovered = true;
          _timer?.cancel();
        },
        onExit: (_) {
          _isHovered = false;
          _restartTimer();
        },
        child: viewport,
      );
    }

    final totalDots = widget.items.length;
    const maxVisibleDots = 7;
    int startDot = 0;
    int endDot = totalDots;
    if (totalDots > maxVisibleDots) {
      startDot = (_currentIndex - (maxVisibleDots ~/ 2)).clamp(0, totalDots - maxVisibleDots);
      endDot = startDot + maxVisibleDots;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: widget.height, child: viewport),
        if (widget.showDots && widget.items.length > 1) ...[
          const SizedBox(height: 12.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int index = startDot; index < endDot; index++) ...[
                Builder(builder: (context) {
                  final isSelected = index == _currentIndex;
                  final isEdge = totalDots > maxVisibleDots && (index == startDot || index == endDot - 1);
                  final dotWidth = isSelected ? 24.0 : (isEdge ? 5.0 : 8.0);
                  final dotHeight = isEdge && !isSelected ? 5.0 : 8.0;

                  return _CarouselDot(
                    index: index,
                    totalDots: totalDots,
                    isSelected: isSelected,
                    dotWidth: dotWidth,
                    dotHeight: dotHeight,
                    theme: theme,
                    onTap: () => _goToPage(index),
                  );
                }),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _CarouselDot extends StatefulWidget {
  final int index;
  final int totalDots;
  final bool isSelected;
  final double dotWidth;
  final double dotHeight;
  final AnimalIslandTheme theme;
  final VoidCallback onTap;

  const _CarouselDot({
    required this.index,
    required this.totalDots,
    required this.isSelected,
    required this.dotWidth,
    required this.dotHeight,
    required this.theme,
    required this.onTap,
  });

  @override
  State<_CarouselDot> createState() => _CarouselDotState();
}

class _CarouselDotState extends State<_CarouselDot> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      onShowFocusHighlight: (f) => setState(() => _isFocused = f),
      mouseCursor: SystemMouseCursors.click,
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) => widget.onTap(),
        ),
      },
      child: Semantics(
        button: true,
        selected: widget.isSelected,
        label: 'Slide ${widget.index + 1} of ${widget.totalDots}',
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AnimalMotion.fast,
            curve: AnimalMotion.ease,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: widget.dotWidth,
            height: widget.dotHeight,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.theme.primary
                  : (_isFocused
                      ? widget.theme.focusYellow
                      : (widget.theme.isDark ? widget.theme.border : AnimalColors.borderLight)),
              borderRadius: AnimalRadii.pillBorder,
              boxShadow: _isFocused
                  ? [
                      BoxShadow(
                        color: widget.theme.focusYellow.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

