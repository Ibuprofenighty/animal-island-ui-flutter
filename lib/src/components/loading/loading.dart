import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/loading_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../icons/icon.dart';
import '../../icons/icon_data.dart';
import '../../icons/icons.g.dart';
import '../../internal/interaction/focus_return.dart';
import '../../internal/timing/motion_policy.dart';
import '../overlay_host/overlay_host.dart';
import 'loading_painter.dart';

export 'loading_painter.dart';

/// Supported animation types for [AnimalLoading].
enum AnimalLoadingType {
  /// Rotating island leaf indicator.
  spinner,

  /// Rotating snowflake; full-screen mode adds falling snowflake particles.
  snowflake,

  /// Three bouncing dot bubbles.
  dots,
}

/// Handle to one full-screen loading occurrence shown by [AnimalLoading.show].
///
/// The occurrence belongs to the [AnimalOverlayHost] it was shown in. [close]
/// is its only close: it is idempotent and safe before the occurrence reaches
/// its first frame. Removing the host also closes it.
final class AnimalLoadingHandle {
  AnimalLoadingHandle._(this._occurrence);

  final AnimalOverlayEntryHandle _occurrence;

  /// Whether this occurrence has been closed, by [close] or by its host.
  bool get isClosed => _occurrence.isClosed;

  /// Closes this occurrence. Repeated calls are ignored.
  void close() => _occurrence.close();
}

/// Animal Island loading indicator (C25).
///
/// Renders inline as a spinner, snowflake or dots indicator, or as a
/// full-screen barrier that blocks the controls it covers. Use [show] to
/// display a full-screen loading in the nearest [AnimalOverlayHost].
class AnimalLoading extends StatefulWidget {
  /// Smallest accepted [snowCount].
  static const int minSnowCount = 1;

  /// Largest accepted [snowCount].
  static const int maxSnowCount = 100;

  /// Indicator animation.
  final AnimalLoadingType type;

  /// Indicator size: 40 for the spinner, 48 for the snowflake and 32 for the
  /// dots by default.
  final double size;

  /// Text shown in a pill below the indicator and announced as its label.
  final String? tip;

  /// Custom content shown below the indicator instead of [tip].
  final Widget? tipWidget;

  /// Whether the loading covers its area with a barrier that blocks input.
  final bool fullScreen;

  /// Number of falling particles of a full-screen snowflake loading, from
  /// [minSnowCount] to [maxSnowCount]. Other values throw a [RangeError].
  final int snowCount;

  /// Seed of the particle layout, for a reproducible snowfall.
  final int? snowSeed;

  /// Visual overrides for this indicator, including its color and the
  /// full-screen barrier color; see [AnimalLoadingStyle].
  final AnimalLoadingStyle? style;

  AnimalLoading({
    super.key,
    this.type = AnimalLoadingType.spinner,
    this.size = 40.0,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    int snowCount = 40,
    this.snowSeed,
    this.style,
  }) : snowCount = _checkSnowCount(snowCount);

  /// Spinner indicator.
  const AnimalLoading.spinner({
    super.key,
    this.size = 40.0,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.style,
  }) : type = AnimalLoadingType.spinner,
       snowCount = 0,
       snowSeed = null;

  /// Snowflake indicator with falling particles in full-screen mode.
  AnimalLoading.snowflake({
    super.key,
    this.size = 48.0,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    int snowCount = 40,
    this.snowSeed,
    this.style,
  }) : type = AnimalLoadingType.snowflake,
       snowCount = _checkSnowCount(snowCount);

  /// Bouncing dots indicator.
  const AnimalLoading.dots({
    super.key,
    this.size = 32.0,
    this.tip,
    this.tipWidget,
    this.fullScreen = false,
    this.style,
  }) : type = AnimalLoadingType.dots,
       snowCount = 0,
       snowSeed = null;

  static int _checkSnowCount(int value) => RangeError.checkValueInInterval(
    value,
    minSnowCount,
    maxSnowCount,
    'snowCount',
  );

  /// Shows a full-screen loading in the nearest [AnimalOverlayHost].
  ///
  /// Returns the occurrence's [AnimalLoadingHandle]; call
  /// [AnimalLoadingHandle.close] to remove it. Throws a [FlutterError] when
  /// [context] has no host and a [RangeError] for an invalid [snowCount],
  /// before anything is shown.
  static AnimalLoadingHandle show(
    BuildContext context, {
    String? tip,
    Widget? tipWidget,
    AnimalLoadingType type = AnimalLoadingType.snowflake,
    int snowCount = 40,
    int? snowSeed,
    AnimalLoadingStyle? style,
  }) {
    final AnimalOverlayController host = AnimalOverlayHost.of(context);
    final AnimalLoading loading = AnimalLoading(
      type: type,
      tip: tip,
      tipWidget: tipWidget,
      fullScreen: true,
      snowCount: snowCount,
      snowSeed: snowSeed,
      style: style,
    );
    return AnimalLoadingHandle._(host.show(builder: (_, _) => loading));
  }

  @override
  State<AnimalLoading> createState() => _AnimalLoadingState();
}

class _AnimalLoadingState extends State<AnimalLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  List<SnowflakeParticle>? _snowflakes;
  final FocusScopeNode _focusScope = FocusScopeNode(
    debugLabel: 'AnimalLoading full-screen scope',
  );
  AnimalFocusReturn? _focusReturn;
  bool _ownsFocus = false;

  @override
  void initState() {
    super.initState();
    _syncParticles();
    if (widget.fullScreen) _captureFocus();
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
        oldWidget.fullScreen != widget.fullScreen ||
        oldWidget.snowCount != widget.snowCount ||
        oldWidget.snowSeed != widget.snowSeed) {
      _syncParticles();
    }
    if (oldWidget.type != widget.type) _syncAnimation();
    if (!oldWidget.fullScreen && widget.fullScreen) _captureFocus();
    if (oldWidget.fullScreen && !widget.fullScreen) _restoreFocus();
  }

  /// Moves keyboard focus off the covered controls into the barrier's scope.
  ///
  /// `FocusScope.autofocus` alone keeps an existing focus, which would leave
  /// a covered control reachable from the keyboard.
  void _captureFocus() {
    _focusReturn = AnimalFocusReturn.capture();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.fullScreen) _focusScope.requestFocus();
    });
  }

  /// Returns focus to the control that held it before the barrier appeared.
  void _restoreFocus() {
    _focusReturn?.restore();
    _focusReturn = null;
  }

  @override
  void deactivate() {
    // Descendants deactivate after this state, so the scope still has focus.
    _ownsFocus = _focusScope.hasFocus;
    super.deactivate();
  }

  /// Keeps particles only while a full-screen snowflake loading paints them.
  void _syncParticles() {
    _snowflakes =
        widget.fullScreen && widget.type == AnimalLoadingType.snowflake
        ? SnowflakeParticle.generate(widget.snowCount, seed: widget.snowSeed)
        : null;
  }

  /// Reuses the state's single controller for every type and motion policy.
  void _syncAnimation() {
    _controller.duration = _ResolvedLoadingStyle.cycle(
      AnimalIslandTheme.of(context),
      widget.type,
    );
    if (AnimalMotionPolicy.shouldAnimate(context)) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    if (_ownsFocus) _restoreFocus();
    _focusScope.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ResolvedLoadingStyle resolved = _ResolvedLoadingStyle.resolve(
      theme: AnimalIslandTheme.of(context),
      style: widget.style,
    );
    final localizations = AnimalLocalizations.of(context)!;

    final Widget core = switch (widget.type) {
      AnimalLoadingType.spinner => _buildRotating(
        AnimalIcons.leaf,
        resolved.color,
      ),
      AnimalLoadingType.snowflake => _buildRotating(
        AnimalIcons.snowflake,
        resolved.color,
      ),
      AnimalLoadingType.dots => _buildDots(resolved.color),
    };

    final String? tip = widget.tip;
    final Widget? tipWidget = widget.tipWidget;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        core,
        if (tipWidget != null) ...[
          SizedBox(height: resolved.tipGap),
          tipWidget,
        ] else if (tip != null && tip.isNotEmpty) ...[
          SizedBox(height: resolved.tipGap),
          Container(
            padding: resolved.tipPadding,
            decoration: BoxDecoration(
              color: resolved.tipBackgroundColor,
              borderRadius: resolved.tipBorderRadius,
              border: Border.all(
                color: resolved.tipBorderColor,
                width: resolved.tipBorderWidth,
              ),
              boxShadow: [resolved.tipShadow],
            ),
            // The enclosing Semantics label announces the tip once.
            child: Semantics(
              excludeSemantics: true,
              child: Text(tip, style: resolved.tipTextStyle),
            ),
          ),
        ],
      ],
    );

    final String label = tip ?? localizations.loading;
    if (!widget.fullScreen) {
      return Semantics(label: label, child: content);
    }

    final List<SnowflakeParticle>? snowflakes = _snowflakes;
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: label,
      child: FocusScope(
        node: _focusScope,
        autofocus: true,
        child: Material(
          color: resolved.barrierColor,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ModalBarrier(dismissible: false),
              if (snowflakes != null)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: SnowflakeOverlayPainter(
                      snowflakes: snowflakes,
                      progress: _controller.value,
                      color: resolved.snowflakeColor,
                    ),
                  ),
                ),
              Center(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRotating(AnimalIconData icon, Color color) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Transform.rotate(
        angle: _controller.value * 2 * math.pi,
        child: AnimalIcon(data: icon, size: widget.size, color: color),
      ),
    );
  }

  Widget _buildDots(Color color) {
    // Dot geometry is proportional to the indicator size.
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

/// The single resolution of [AnimalLoading] visuals.
///
/// Precedence: the widget's `style`, then
/// `AnimalIslandTheme.components.loading`, then defaults derived from the
/// theme tokens.
class _ResolvedLoadingStyle {
  final Color color;
  final double tipGap;
  final EdgeInsetsGeometry tipPadding;
  final TextStyle tipTextStyle;
  final Color tipBackgroundColor;
  final Color tipBorderColor;
  final double tipBorderWidth;
  final BorderRadius tipBorderRadius;
  final BoxShadow tipShadow;
  final Color barrierColor;
  final Color snowflakeColor;

  const _ResolvedLoadingStyle._({
    required this.color,
    required this.tipGap,
    required this.tipPadding,
    required this.tipTextStyle,
    required this.tipBackgroundColor,
    required this.tipBorderColor,
    required this.tipBorderWidth,
    required this.tipBorderRadius,
    required this.tipShadow,
    required this.barrierColor,
    required this.snowflakeColor,
  });

  /// One animation cycle per type, scaled from the theme motion tokens.
  static Duration cycle(AnimalIslandTheme theme, AnimalLoadingType type) =>
      type == AnimalLoadingType.snowflake
      ? theme.motion.slow * (10000 / 350)
      : theme.motion.normal * (1200 / 250);

  static _ResolvedLoadingStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalLoadingStyle? style,
  }) {
    final AnimalLoadingStyle merged = (style ?? AnimalLoadingStyle()).merge(
      theme.components.loading,
    );
    final colors = theme.colors;
    final spacing = theme.spacing;
    final bool dark = colors.brightness == Brightness.dark;

    return _ResolvedLoadingStyle._(
      color: merged.color ?? colors.primaryText,
      tipGap: merged.tipGap ?? spacing.md,
      tipPadding:
          merged.tipPadding ??
          EdgeInsets.symmetric(
            horizontal: spacing.md + spacing.xxs,
            vertical: spacing.sm - spacing.xxs,
          ),
      tipTextStyle: theme.typography
          .resolve(
            theme.typography.caption
                .copyWith(fontWeight: FontWeight.w700)
                .merge(merged.tipTextStyle),
          )
          .copyWith(color: merged.tipTextColor ?? colors.text),
      tipBackgroundColor:
          merged.tipBackgroundColor ?? colors.bgContent.withValues(alpha: 0.9),
      tipBorderColor:
          merged.tipBorderColor ?? (dark ? colors.border : colors.borderLight),
      tipBorderWidth: merged.tipBorderWidth ?? 1.2,
      tipBorderRadius: merged.tipBorderRadius ?? theme.radii.pillBorder,
      tipShadow: merged.tipShadow ?? theme.shadows.softElevation,
      barrierColor:
          merged.barrierColor ??
          colors.bg.withValues(alpha: dark ? 0.67 : 0.53),
      snowflakeColor: merged.snowflakeColor ?? colors.info,
    );
  }
}
