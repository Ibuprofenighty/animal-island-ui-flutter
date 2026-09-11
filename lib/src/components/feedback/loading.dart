import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';

/// Loading indicator types for [AnimalLoading].
enum AnimalLoadingType {
  /// Rotating cute leaf spinner.
  spinner,

  /// Signature Animal Island falling snowflakes with organic drift.
  snowflake,

  /// Three cute jumping/bouncing island pebbles.
  dots,
}

/// SOTA Animal Island loading component.
///
/// Supports inline spinner, cute jumping dots, signature falling snowflakes overlay,
/// and imperative [AnimalLoading.show] / [AnimalLoading.hide] global portal.
class AnimalLoading extends StatefulWidget {
  /// Loading animation style.
  final AnimalLoadingType type;

  /// Diameter of the spinner or dot cluster.
  final double size;

  /// Primary color of the loading indicator (defaults to theme.primary).
  final Color? color;

  /// Optional tip text displayed beneath the indicator.
  final String? tip;

  /// Custom tip widget overriding [tip].
  final Widget? tipWidget;

  /// Whether the loading covers full screen/container with translucent backdrop.
  final bool fullScreen;

  /// Background barrier color when [fullScreen] is true.
  final Color? barrierColor;

  /// Number of snowflake particles (only used when [type] is [AnimalLoadingType.snowflake]).
  final int snowCount;

  const AnimalLoading({
    super.key,
    this.type = AnimalLoadingType.spinner,
    this.size = 36.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
    this.snowCount = 36,
  });

  /// Named constructor for rotating leaf spinner.
  const AnimalLoading.spinner({
    super.key,
    this.size = 36.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
  })  : type = AnimalLoadingType.spinner,
        snowCount = 0;

  /// Named constructor for signature falling snowflake particles.
  const AnimalLoading.snowflake({
    super.key,
    this.size = 48.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
    this.snowCount = 40,
  }) : type = AnimalLoadingType.snowflake;

  /// Named constructor for jumping dots.
  const AnimalLoading.dots({
    super.key,
    this.size = 32.0,
    this.color,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.barrierColor,
  })  : type = AnimalLoadingType.dots,
        snowCount = 0;

  // ---------------------------------------------------------------------------
  // Imperative Global Overlay API
  // ---------------------------------------------------------------------------

  static OverlayEntry? _globalEntry;

  /// Displays an imperative full-screen loading overlay.
  static void show(
    BuildContext context, {
    String? tip,
    Widget? tipWidget,
    AnimalLoadingType type = AnimalLoadingType.snowflake,
    Color? barrierColor,
  }) {
    hide();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final entry = OverlayEntry(
      builder: (ctx) => AnimalLoading(
        type: type,
        tip: tip,
        tipWidget: tipWidget,
        fullScreen: true,
        barrierColor: barrierColor,
      ),
    );

    _globalEntry = entry;
    overlay.insert(entry);
  }

  /// Removes any currently visible global loading overlay.
  static void hide() {
    if (_globalEntry != null) {
      if (_globalEntry!.mounted) {
        _globalEntry!.remove();
      }
      _globalEntry = null;
    }
  }

  @override
  State<AnimalLoading> createState() => _AnimalLoadingState();
}

class _AnimalLoadingState extends State<AnimalLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_SnowflakeParticle>? _snowflakes;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.type == AnimalLoadingType.snowflake
          ? const Duration(seconds: 10)
          : const Duration(milliseconds: 1200),
    )..repeat();

    if (widget.type == AnimalLoadingType.snowflake) {
      _initSnowflakes();
    }
  }

  @override
  void didUpdateWidget(AnimalLoading oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type ||
        (widget.type == AnimalLoadingType.snowflake &&
            oldWidget.snowCount != widget.snowCount)) {
      if (widget.type == AnimalLoadingType.snowflake) {
        _controller.duration = const Duration(seconds: 10);
        _initSnowflakes();
      } else {
        _controller.duration = const Duration(milliseconds: 1200);
        _snowflakes = null;
      }
      _controller.repeat();
    }
  }

  void _initSnowflakes() {
    final rand = math.Random();
    _snowflakes = List.generate(widget.snowCount, (index) {
      return _SnowflakeParticle(
        x: rand.nextDouble(),
        y: rand.nextDouble(),
        speed: 0.15 + rand.nextDouble() * 0.45,
        radius: 2.0 + rand.nextDouble() * 4.5,
        swayAmplitude: 0.02 + rand.nextDouble() * 0.05,
        swayFrequency: 2.0 + rand.nextDouble() * 4.0,
        swayPhase: rand.nextDouble() * math.pi * 2,
        opacity: 0.35 + rand.nextDouble() * 0.55,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final indicatorColor = widget.color ?? theme.primary;

    Widget core;
    switch (widget.type) {
      case AnimalLoadingType.spinner:
        core = _buildSpinner(indicatorColor);
        break;
      case AnimalLoadingType.snowflake:
        core = _buildSnowflake(context, theme, indicatorColor);
        break;
      case AnimalLoadingType.dots:
        core = _buildDots(indicatorColor);
        break;
    }

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        core,
        if (widget.tipWidget != null) ...[
          const SizedBox(height: 12.0),
          widget.tipWidget!,
        ] else if (widget.tip != null && widget.tip!.isNotEmpty) ...[
          const SizedBox(height: 12.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: theme.bgContent.withValues(alpha: 0.9),
              borderRadius: AnimalRadii.pillBorder,
              border: Border.all(
                color: theme.isDark ? theme.border : AnimalColors.borderLight,
                width: 1.2,
              ),
              boxShadow: const [AnimalShadows.softElevation],
            ),
            child: Text(
              widget.tip!,
              style: AnimalTypography.caption.copyWith(
                color: theme.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );

    if (!widget.fullScreen) {
      return Semantics(
        label: widget.tip ?? '加载中',
        child: content,
      );
    }

    final defaultBarrier = theme.isDark
        ? const Color(0xAA1C1814)
        : const Color(0x88FAF7F0);

    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: widget.tip ?? '加载中',
      child: FocusScope(
        autofocus: true,
        child: Material(
          color: widget.barrierColor ?? defaultBarrier,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ModalBarrier(dismissible: false),
              if (widget.type == AnimalLoadingType.snowflake && _snowflakes != null)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _SnowflakeOverlayPainter(
                        snowflakes: _snowflakes!,
                        progress: _controller.value,
                        isDark: theme.isDark,
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

  Widget _buildSpinner(Color indicatorColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: LeafIcon(
        size: widget.size,
        color: indicatorColor,
      ),
    );
  }

  Widget _buildSnowflake(
    BuildContext context,
    AnimalIslandTheme theme,
    Color indicatorColor,
  ) {
    if (widget.fullScreen) {
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pulse = 0.95 + 0.08 * math.sin(_controller.value * 4 * math.pi);
          return Transform.scale(
            scale: pulse,
            child: Container(
              width: widget.size + 24,
              height: widget.size + 24,
              decoration: BoxDecoration(
                color: theme.bgContent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.isDark ? theme.border : AnimalColors.borderLight,
                  width: 1.5,
                ),
                boxShadow: const [AnimalShadows.softElevation],
              ),
              alignment: Alignment.center,
              child: Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: SnowflakeIcon(
                  size: widget.size,
                  color: indicatorColor,
                ),
              ),
            ),
          );
        },
      );
    }

    return SizedBox(
      width: widget.size * 2.2,
      height: widget.size * 1.5,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _SnowflakeOverlayPainter(
              snowflakes: _snowflakes ?? [],
              progress: _controller.value,
              isDark: theme.isDark,
            ),
            child: Center(
              child: Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: SnowflakeIcon(
                  size: widget.size,
                  color: indicatorColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDots(Color indicatorColor) {
    final dotSize = widget.size * 0.3;
    return SizedBox(
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final phase = (_controller.value + index * 0.22) % 1.0;
              final offsetY = -math.sin(phase * math.pi) * (widget.size * 0.35);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                transform: Matrix4.translationValues(0, offsetY.clamp(-widget.size, 0), 0),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: indicatorColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: indicatorColor.withValues(alpha: 0.35),
                      offset: const Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _SnowflakeParticle {
  final double x;
  final double y;
  final double speed;
  final double radius;
  final double swayAmplitude;
  final double swayFrequency;
  final double swayPhase;
  final double opacity;

  const _SnowflakeParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.radius,
    required this.swayAmplitude,
    required this.swayFrequency,
    required this.swayPhase,
    required this.opacity,
  });
}

class _SnowflakeOverlayPainter extends CustomPainter {
  final List<_SnowflakeParticle> snowflakes;
  final double progress;
  final bool isDark;

  _SnowflakeOverlayPainter({
    required this.snowflakes,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()..style = PaintingStyle.fill;
    final baseColor = isDark ? const Color(0xFFE8F4F8) : const Color(0xFFFFFFFF);
    final glowColor = isDark ? const Color(0x667DD3FC) : const Color(0x44BAE6FD);

    for (final flake in snowflakes) {
      final currentY = ((flake.y + progress * flake.speed) % 1.0) * size.height;
      final sway = math.sin(progress * math.pi * 2 * flake.swayFrequency + flake.swayPhase) *
          flake.swayAmplitude *
          size.width;
      final currentX = (flake.x * size.width + sway) % size.width;

      // Glow halo
      paint.color = glowColor.withValues(alpha: flake.opacity * 0.5);
      canvas.drawCircle(Offset(currentX, currentY), flake.radius * 1.5, paint);

      // Core particle
      paint.color = baseColor.withValues(alpha: flake.opacity);
      canvas.drawCircle(Offset(currentX, currentY), flake.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowflakeOverlayPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}
