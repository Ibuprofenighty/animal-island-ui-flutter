import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/timing/motion_policy.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import 'loading_painter.dart';

export 'loading_painter.dart';

/// Supported animation types for [AnimalLoading].
enum AnimalLoadingType {
  /// Rotating island leaf / arc indicator.
  spinner,

  /// Fullscreen or local falling winter snowflake particles.
  snowflake,

  /// Three cute bouncing dot bubbles.
  dots,
}

/// Lifecycle-safe handle representing an active global or host loading overlay (F14 fix).
///
/// Ensures closing before first frame, duplicate releases, or host unmounts are 100% leak-free.
class AnimalLoadingHandle {
  final VoidCallback _onClose;
  bool _isClosed = false;

  AnimalLoadingHandle._(this._onClose);

  /// Whether this loading handle has already been dismissed.
  bool get isClosed => _isClosed;

  /// Dismisses and releases the loading overlay. Safe to call multiple times or before first frame.
  void close() {
    if (_isClosed) return;
    _isClosed = true;
    _onClose();
  }

  /// Alias for [close].
  void release() => close();
}

/// Animal Island Loading indicator and imperative overlay portal (C25).
///
/// Features:
/// - 3 visual styles: Spinner, Snowflake (with deterministic seed support), Dots
/// - Imperative full-screen overlay with leak-free [AnimalLoadingHandle] (F14 fix)
/// - Accessible screen reader announcements and reduced-motion policy compliance
class AnimalLoading extends StatefulWidget {
  final AnimalLoadingType type;
  final double size;
  final Color? color;
  final String? tip;
  final Widget? tipWidget;
  final bool fullScreen;
  final Color? barrierColor;
  final int snowCount;
  final int? snowSeed;

  const AnimalLoading({
    super.key,
    this.type = AnimalLoadingType.spinner,
    this.size = 40.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
    int snowCount = 40,
    this.snowSeed,
  }) : snowCount = snowCount < 1 ? 1 : (snowCount > 100 ? 100 : snowCount);

  /// Named constructor for spinner indicator.
  const AnimalLoading.spinner({
    super.key,
    this.size = 40.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
  }) : type = AnimalLoadingType.spinner,
       snowCount = 0,
       snowSeed = null;

  /// Named constructor for snowflake winter particle loading.
  const AnimalLoading.snowflake({
    super.key,
    this.size = 48.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
    int snowCount = 40,
    this.snowSeed,
  }) : type = AnimalLoadingType.snowflake,
       snowCount = snowCount < 1 ? 1 : (snowCount > 100 ? 100 : snowCount);

  /// Named constructor for jumping dots.
  const AnimalLoading.dots({
    super.key,
    this.size = 32.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
  }) : type = AnimalLoadingType.dots,
       snowCount = 0,
       snowSeed = null;

  // ---------------------------------------------------------------------------
  // Imperative Overlay API with F14 Lifecycle Handle
  // ---------------------------------------------------------------------------

  static final List<AnimalLoadingHandle> _activeHandles = [];

  /// Displays an imperative full-screen loading overlay.
  ///
  /// Returns an [AnimalLoadingHandle] that can be released idempotently at any time.
  static AnimalLoadingHandle show(
    BuildContext context, {
    String? tip,
    Widget? tipWidget,
    AnimalLoadingType type = AnimalLoadingType.snowflake,
    Color? barrierColor,
    int snowCount = 40,
    int? snowSeed,
  }) {
    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ?? Overlay.of(context);

    bool dismissed = false;
    OverlayEntry? entry;

    void cleanup() {
      if (entry != null) {
        if (entry!.mounted) {
          entry!.remove();
        }
        entry = null;
      }
    }

    late final AnimalLoadingHandle handle;
    handle = AnimalLoadingHandle._(() {
      dismissed = true;
      cleanup();
      _activeHandles.remove(handle);
    });

    _activeHandles.add(handle);

    entry = OverlayEntry(
      builder: (ctx) {
        if (dismissed) {
          WidgetsBinding.instance.addPostFrameCallback((_) => cleanup());
          return const SizedBox.shrink();
        }
        return AnimalLoading(
          type: type,
          tip: tip,
          tipWidget: tipWidget,
          fullScreen: true,
          barrierColor: barrierColor,
          snowCount: snowCount,
          snowSeed: snowSeed,
        );
      },
    );

    overlay.insert(entry!);
    return handle;
  }

  /// Removes all currently active global loading overlays.
  static void hide([BuildContext? context]) {
    for (final handle in List<AnimalLoadingHandle>.from(_activeHandles)) {
      handle.close();
    }
    _activeHandles.clear();
  }

  @override
  State<AnimalLoading> createState() => _AnimalLoadingState();
}

class _AnimalLoadingState extends State<AnimalLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<SnowflakeParticle>? _snowflakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration.zero);

    if (widget.type == AnimalLoadingType.snowflake) {
      _initSnowflakes();
    }
  }

  void _syncAnimation() {
    final theme = AnimalIslandTheme.of(context);
    _controller.duration = widget.type == AnimalLoadingType.snowflake
        ? theme.motion.slow * (10000 / 350)
        : theme.motion.normal * (1200 / 250);
    if (AnimalMotionPolicy.shouldAnimate(context)) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(AnimalLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        (widget.type == AnimalLoadingType.snowflake &&
            (oldWidget.snowCount != widget.snowCount ||
                oldWidget.snowSeed != widget.snowSeed))) {
      if (widget.type == AnimalLoadingType.snowflake) {
        _initSnowflakes();
      } else {
        _snowflakes = null;
      }
      _syncAnimation();
    }
  }

  void _initSnowflakes() {
    _snowflakes = SnowflakeParticle.generate(
      widget.snowCount,
      seed: widget.snowSeed,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final indicatorColor = widget.color ?? theme.colors.primaryText;

    Widget core;
    switch (widget.type) {
      case AnimalLoadingType.spinner:
        core = _buildSpinner(indicatorColor);
      case AnimalLoadingType.snowflake:
        core = _buildSnowflake(context, theme, indicatorColor);
      case AnimalLoadingType.dots:
        core = _buildDots(indicatorColor);
    }

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        core,
        if (widget.tipWidget != null) ...[
          SizedBox(height: theme.spacing.md),
          widget.tipWidget!,
        ] else if (widget.tip != null && widget.tip!.isNotEmpty) ...[
          SizedBox(height: theme.spacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: theme.spacing.md + theme.spacing.xxs,
              vertical: theme.spacing.sm - theme.spacing.xxs,
            ),
            decoration: BoxDecoration(
              color: theme.colors.bgContent.withValues(alpha: 0.9),
              borderRadius: theme.radii.pillBorder,
              border: Border.all(
                color: theme.colors.brightness == Brightness.dark
                    ? theme.colors.border
                    : theme.colors.borderLight,
                width: 1.2,
              ),
              boxShadow: [theme.shadows.softElevation],
            ),
            child: Semantics(
              excludeSemantics: true,
              child: Text(
                widget.tip!,
                style: theme.typography.caption.copyWith(
                  color: theme.colors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    if (!widget.fullScreen) {
      return Semantics(
        label: widget.tip ?? localizations.loading,
        child: content,
      );
    }

    final defaultBarrier = theme.colors.bg.withValues(
      alpha: theme.colors.brightness == Brightness.dark ? 0.67 : 0.53,
    );

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: widget.tip ?? localizations.loading,
      child: FocusScope(
        autofocus: true,
        child: Material(
          color: widget.barrierColor ?? defaultBarrier,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ModalBarrier(dismissible: false),
              if (widget.type == AnimalLoadingType.snowflake &&
                  _snowflakes != null)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: SnowflakeOverlayPainter(
                        snowflakes: _snowflakes!,
                        progress: _controller.value,
                        color: theme.colors.info,
                      ),
                    );
                  },
                ),
              Center(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner(Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: AnimalIcon(
            data: AnimalIcons.leaf,
            size: widget.size,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildSnowflake(
    BuildContext context,
    AnimalIslandTheme theme,
    Color color,
  ) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final angle = _controller.value * 2 * math.pi;
        return Transform.rotate(
          angle: angle,
          child: AnimalIcon(
            data: AnimalIcons.snowflake,
            size: widget.size,
            color: color,
          ),
        );
      },
    );
  }

  Widget _buildDots(Color color) {
    final dotSize = widget.size * 0.28;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final shift = i * 0.25;
            final progress = (_controller.value + shift) % 1.0;
            final bounce = -math.sin(progress * math.pi) * (widget.size * 0.35);

            return Transform.translate(
              offset: Offset(0, bounce.clamp(-widget.size * 0.4, 0.0)),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: dotSize * 0.25),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            );
          }),
        );
      },
    );
  }
}
