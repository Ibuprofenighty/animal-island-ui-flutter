import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/clock.dart';
import '../../foundation/theme/components/carousel_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interaction_boundary.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/timing/motion_policy.dart';
import 'carousel_item.dart';
export 'carousel_item.dart';

/// Stable-ID carousel with explicit value ownership and one autoplay scheduler.
/// Controlled gestures only propose an ID; rejection restores the caller's
/// slide. Non-loop autoplay stops on the last slide. Focus, hover, visibility,
/// TickerMode, reduced motion and foreground policy pause decorative work.
class AnimalCarousel extends StatefulWidget {
  /// Immutable snapshot of slides with unique identities.
  final List<AnimalCarouselItem> items;

  /// Controlled current ID, null only when there are no slides.
  final String? activeId;

  /// Uncontrolled initial ID; null starts at the first slide.
  /// Every construction requires an existing ID. Remove deleted defaults when
  /// updating items; valid default changes do not reset mounted selection.
  final String? defaultActiveId;

  /// Proposes one slide ID per user or autoplay action; external updates do not notify.
  final ValueChanged<String>? onChange;

  /// Whether eligible carousels advance periodically.
  final bool autoPlay;

  /// Positive interval between advances, default four seconds.
  final Duration autoPlayInterval;

  /// Whether previous and next controls are visible.
  final bool showArrows;

  /// Whether slide-position controls are visible.
  final bool showDots;

  /// Whether hover pauses autoplay.
  final bool pauseOnHover;

  /// Whether navigation wraps at either end.
  final bool loop;

  /// Owner-provided visibility for decorative work.
  final bool visible;

  /// Injected monotonic clock for autoplay.
  final AnimalClock clock;

  /// Instance visual overrides before component theme and tokens.
  final AnimalCarouselStyle? style;
  final bool _controlled;

  /// Creates a controlled carousel. Unknown IDs and invalid intervals
  /// throw ArgumentError. Delete the active ID and update activeId
  /// together; an empty carousel requires null.
  AnimalCarousel({
    super.key,
    required List<AnimalCarouselItem> items,
    required this.activeId,
    this.onChange,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showArrows = true,
    this.showDots = true,
    this.pauseOnHover = true,
    this.loop = true,
    this.visible = true,
    this.clock = const SystemClock(),
    this.style,
  }) : items = List.unmodifiable(items),
       defaultActiveId = null,
       _controlled = true {
    _validate();
    if (this.items.isEmpty
        ? activeId != null
        : !this.items.any((item) => item.id == activeId)) {
      throw ArgumentError.value(
        activeId,
        'activeId',
        'must identify a slide; null only for empty items',
      );
    }
  }

  /// Creates an uncontrolled carousel. Removing its active slide selects the
  /// first remaining slide without notifying; empty items read no selection.
  /// Clear a deleted defaultActiveId in the same rebuild that removes its item.
  AnimalCarousel.uncontrolled({
    super.key,
    required List<AnimalCarouselItem> items,
    this.defaultActiveId,
    this.onChange,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.showArrows = true,
    this.showDots = true,
    this.pauseOnHover = true,
    this.loop = true,
    this.visible = true,
    this.clock = const SystemClock(),
    this.style,
  }) : items = List.unmodifiable(items),
       activeId = null,
       _controlled = false {
    _validate();
    if (defaultActiveId != null &&
        !this.items.any((item) => item.id == defaultActiveId)) {
      throw ArgumentError.value(
        defaultActiveId,
        'defaultActiveId',
        'must identify a slide',
      );
    }
  }
  void _validate() {
    if (autoPlayInterval <= Duration.zero) {
      throw ArgumentError.value(
        autoPlayInterval,
        'autoPlayInterval',
        'must be positive',
      );
    }
    final ids = <String>{};
    for (final item in items) {
      if (!ids.add(item.id)) {
        throw ArgumentError.value(item.id, 'items', 'IDs must be unique');
      }
    }
  }

  @override
  State<AnimalCarousel> createState() => _AnimalCarouselState();
}

class _AnimalCarouselState extends State<AnimalCarousel> {
  late final PageController _pages;
  late final AnimalMotionScheduler _scheduler;
  late final AnimalPeriodicRegistration _autoplay;
  String? _uncontrolledId;
  bool _focused = false;
  bool _hovered = false;
  bool _moving = false;
  int _movement = 0;
  int _policyRevision = 0;
  String? get _id => widget._controlled ? widget.activeId : _uncontrolledId;
  int get _index => widget.items.indexWhere((item) => item.id == _id);
  @override
  void initState() {
    super.initState();
    if (!widget._controlled) {
      _uncontrolledId = widget.defaultActiveId ?? widget.items.firstOrNull?.id;
    }
    _pages = PageController(initialPage: _index < 0 ? 0 : _index);
    _scheduler = AnimalMotionScheduler(clock: widget.clock);
    _autoplay = _scheduler.schedulePeriodic(
      interval: widget.autoPlayInterval,
      eligible: false,
      onTick: (_) => _step(1),
    );
    _scheduler.setPolicyChangedListener(() {
      _syncEligibility();
      _scheduleOwnerMovement(immediate: true);
      setState(() => _policyRevision++);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncEligibility();
    if (!AnimalMotionPolicy.shouldAnimate(context, visible: widget.visible)) {
      _scheduleOwnerMovement(immediate: true);
    }
  }

  @override
  void didUpdateWidget(AnimalCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._controlled != widget._controlled) {
      throw StateError('Carousel ownership cannot change while mounted');
    }
    if (!widget._controlled &&
        !widget.items.any((item) => item.id == _uncontrolledId)) {
      _uncontrolledId = widget.items.firstOrNull?.id;
    }
    if (oldWidget.clock != widget.clock) _scheduler.updateClock(widget.clock);
    if (oldWidget.autoPlayInterval != widget.autoPlayInterval) {
      _autoplay.updateInterval(widget.autoPlayInterval);
    }
    final orderChanged =
        oldWidget.items.length != widget.items.length ||
        Iterable<int>.generate(widget.items.length)
            .any((i) => oldWidget.items[i].id != widget.items[i].id);
    if (orderChanged ||
        oldWidget.activeId != widget.activeId ||
        !AnimalMotionPolicy.shouldAnimate(context, visible: widget.visible)) {
      _scheduleOwnerMovement(immediate: orderChanged);
    }
    _syncEligibility();
  }

  void _scheduleOwnerMovement({bool immediate = false}) {
    _moving = true;
    final movement = ++_movement;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || movement != _movement) return;
      if (_index < 0) {
        _moving = false;
      } else {
        _moveToOwner(immediate: immediate);
      }
    });
  }

  void _syncEligibility() {
    _autoplay.setEligible(
      widget.autoPlay &&
          widget.items.length > 1 &&
          (widget.loop || _index < widget.items.length - 1) &&
          AnimalMotionPolicy.decorativeContextEligible(
            context,
            focused: _focused,
            hovered: _hovered && widget.pauseOnHover,
            visible: widget.visible,
          ),
    );
  }

  void _moveToOwner({bool immediate = false}) {
    if (!_pages.hasClients || _index < 0) return;
    final movement = ++_movement;
    _moving = true;
    final style = _resolveCarouselStyle(
      AnimalIslandTheme.of(context),
      widget.style,
    );
    if (immediate ||
        !AnimalMotionPolicy.shouldAnimate(context, visible: widget.visible) ||
        style.duration == Duration.zero) {
      _pages.jumpToPage(_index);
      _moving = false;
    } else {
      _pages
          .animateToPage(_index, duration: style.duration!, curve: style.curve!)
          .then((_) {
            if (mounted && movement == _movement) _moving = false;
          });
    }
  }

  void _request(int index, {bool gesture = false}) {
    if (index < 0 || index >= widget.items.length || index == _index) return;
    final id = widget.items[index].id;
    if (!widget._controlled) {
      setState(() => _uncontrolledId = id);
      _syncEligibility();
      if (!gesture) _moveToOwner();
    } else if (gesture) {
      _moving = true;
      final movement = ++_movement;
      // Reconcile after a synchronous parent acceptance has rebuilt. An
      // external update supersedes this callback; rejection restores the
      // authoritative slide without resetting an accepted gesture first.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && movement == _movement) _moveToOwner();
      });
    }
    widget.onChange?.call(id);
  }

  void _step(int direction) {
    if (widget.items.length <= 1) return;
    final target = _index + direction;
    if (target >= 0 && target < widget.items.length) {
      _request(target);
    } else if (widget.loop) {
      _request(target < 0 ? widget.items.length - 1 : 0);
    }
  }

  @override
  void dispose() {
    _movement++;
    _scheduler.dispose();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveCarouselStyle(
      AnimalIslandTheme.of(context),
      widget.style,
    );
    final copy = AnimalLocalizations.of(context)!;
    final animate = AnimalMotionPolicy.shouldAnimate(
      context,
      visible: widget.visible,
    );
    if (widget.items.isEmpty) {
      return SizedBox(
        height: style.height,
        child: Container(
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: style.borderRadius,
            border: Border.all(
              color: style.borderColor!,
              width: style.borderWidth!,
            ),
          ),
        ),
      );
    }
    final indices = {
      for (var i = 0; i < widget.items.length; i++)
        ValueKey(widget.items[i].id): i,
    };
    return InteractionBoundary(
      onFocusChanged: (value) {
        _focused = value;
        _syncEligibility();
      },
      onHoverChanged: (value) {
        _hovered = value;
        _syncEligibility();
      },
      child: SizedBox(
        height: style.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pages,
              itemCount: widget.items.length,
              findChildIndexCallback: (key) => indices[key],
              onPageChanged: (index) {
                if (!_moving) _request(index, gesture: true);
              },
              itemBuilder: (context, index) => ClipRRect(
                key: ValueKey(widget.items[index].id),
                borderRadius: style.borderRadius!,
                child: widget.items[index].child,
              ),
            ),
            if (widget.showArrows && widget.items.length > 1) ...[
              PositionedDirectional(
                start: style.controlInset,
                child: InteractiveRegion(
                  disabled: !widget.loop && _index == 0,
                  onPressed: () => _step(-1),
                  semanticLabel: copy.carouselPreviousSlide,
                  surfaceColor: style.arrowBackgroundColor,
                  borderRadius: BorderRadius.circular(style.arrowIconSize!),
                  padding: style.controlPadding,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: style.arrowIconSize,
                    color: style.arrowColor,
                  ),
                ),
              ),
              PositionedDirectional(
                end: style.controlInset,
                child: InteractiveRegion(
                  disabled: !widget.loop && _index == widget.items.length - 1,
                  onPressed: () => _step(1),
                  semanticLabel: copy.carouselNextSlide,
                  surfaceColor: style.arrowBackgroundColor,
                  borderRadius: BorderRadius.circular(style.arrowIconSize!),
                  padding: style.controlPadding,
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: style.arrowIconSize,
                    color: style.arrowColor,
                  ),
                ),
              ),
            ],
            if (widget.showDots && widget.items.length > 1)
              Positioned(
                left: style.controlInset,
                right: style.controlInset,
                bottom: style.controlInset,
                child: Center(
                  child: Container(
                    padding: style.dotPadding,
                    decoration: BoxDecoration(
                      color: style.dotBackgroundColor,
                      borderRadius: style.dotBorderRadius,
                      boxShadow: [style.shadow!],
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var i = 0; i < widget.items.length; i++) ...[
                            if (i > 0) SizedBox(width: style.dotGap),
                            InteractiveRegion(
                              selected: i == _index,
                              onPressed: () => _request(i),
                              enableHaptics: false,
                              semanticLabel: copy.carouselSlidePosition(
                                i + 1,
                                widget.items.length,
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  key: ValueKey((animate, _policyRevision)),
                                  duration: animate
                                      ? style.dotDuration!
                                      : Duration.zero,
                                  curve: style.curve!,
                                  width: i == _index
                                      ? style.activeDotWidth
                                      : style.dotSize,
                                  height: style.dotSize,
                                  decoration: BoxDecoration(
                                    color: i == _index
                                        ? style.activeDotColor
                                        : style.dotColor,
                                    borderRadius: BorderRadius.circular(
                                      style.dotSize! / 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

AnimalCarouselStyle _resolveCarouselStyle(
  AnimalIslandTheme theme,
  AnimalCarouselStyle? instance,
) => (instance ?? AnimalCarouselStyle())
    .merge(theme.components.carousel)
    .merge(
      AnimalCarouselStyle(
        height: 200,
        backgroundColor: theme.colors.surfaceAlt,
        borderColor: theme.colors.border,
        borderWidth: 1,
        borderRadius: theme.radii.cardBorder,
        dotBorderRadius: theme.radii.pillBorder,
        arrowColor: theme.colors.text,
        arrowBackgroundColor: theme.colors.bgContent,
        arrowIconSize: 20,
        controlInset: theme.spacing.md,
        controlPadding: EdgeInsets.all(theme.spacing.sm),
        dotColor: theme.colors.textSecondary,
        activeDotColor: theme.colors.primaryText,
        dotSize: 8,
        activeDotWidth: 20,
        dotGap: theme.spacing.xs,
        dotPadding: EdgeInsets.symmetric(
          horizontal: theme.spacing.sm,
          vertical: theme.spacing.xs,
        ),
        dotBackgroundColor: theme.colors.bgContent.withValues(alpha: .75),
        shadow: theme.shadows.softElevation,
        duration: theme.motion.normal,
        dotDuration: theme.motion.fast,
        curve: theme.motion.ease,
      ),
    );
