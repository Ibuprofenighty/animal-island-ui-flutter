import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/timing/lifecycle_observer.dart';
import '../../internal/timing/motion_policy.dart';
import '../../foundation/theme/components/switch_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/focus_ring.dart';

/// Size presets for [AnimalSwitch].
///
/// A preset names a step; its metrics come from the active theme. See
/// [AnimalSwitchStyle] for the values a theme or a single switch can override.
enum AnimalSwitchSize { small, defaultSize }

class _SwitchTrackDecoration extends BoxDecoration {
  const _SwitchTrackDecoration({
    required Color color,
    required Border border,
    required BorderRadiusGeometry borderRadius,
    required this.insetShadow,
  }) : super(
         color: color,
         border: border,
         borderRadius: borderRadius,
         boxShadow: const <BoxShadow>[],
       );

  final BoxShadow insetShadow;

  @override
  EdgeInsetsGeometry get padding => border!.dimensions;

  @override
  bool get isComplex => true;

  @override
  Path getClipPath(Rect rect, TextDirection textDirection) => Path()
    ..addRRect(
      (borderRadius ?? BorderRadius.zero)
          .resolve(textDirection)
          .toRRect(rect)
          .scaleRadii(),
    );

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _SwitchTrackPainter(this, onChanged);

  @override
  _SwitchTrackDecoration scale(double factor) => _SwitchTrackDecoration(
    color: Color.lerp(null, color, factor)!,
    border: BoxBorder.lerp(null, border, factor)! as Border,
    borderRadius:
        BorderRadiusGeometry.lerp(null, borderRadius, factor) ??
        BorderRadius.zero,
    insetShadow: insetShadow.scale(factor),
  );

  @override
  _SwitchTrackDecoration? lerpFrom(Decoration? a, double t) => switch (a) {
    null => scale(t),
    _SwitchTrackDecoration() => _lerp(a, this, t),
    _ => null,
  };

  @override
  _SwitchTrackDecoration? lerpTo(Decoration? b, double t) => switch (b) {
    null => scale(1 - t),
    _SwitchTrackDecoration() => _lerp(this, b, t),
    _ => null,
  };

  static _SwitchTrackDecoration _lerp(
    _SwitchTrackDecoration a,
    _SwitchTrackDecoration b,
    double t,
  ) => _SwitchTrackDecoration(
    color: Color.lerp(a.color, b.color, t)!,
    border: BoxBorder.lerp(a.border, b.border, t)! as Border,
    borderRadius:
        BorderRadiusGeometry.lerp(a.borderRadius, b.borderRadius, t) ??
        BorderRadius.zero,
    insetShadow: BoxShadow.lerp(a.insetShadow, b.insetShadow, t)!,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _SwitchTrackDecoration &&
          super == other &&
          insetShadow == other.insetShadow;

  @override
  int get hashCode => Object.hash(super.hashCode, insetShadow);
}

class _SwitchTrackPainter extends BoxPainter {
  _SwitchTrackPainter(this.decoration, [super.onChanged]);

  final _SwitchTrackDecoration decoration;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Size? size = configuration.size;
    if (size == null) return;

    final Rect rect = offset & size;
    final TextDirection? textDirection = configuration.textDirection;
    final BorderRadius resolvedRadius =
        (decoration.borderRadius ?? BorderRadius.zero).resolve(textDirection);
    final RRect track = resolvedRadius.toRRect(rect).scaleRadii();
    final Border trackBorder = decoration.border! as Border;
    final EdgeInsets adjustment =
        EdgeInsets.fromLTRB(
          _opaqueStrokeInset(trackBorder.left),
          _opaqueStrokeInset(trackBorder.top),
          _opaqueStrokeInset(trackBorder.right),
          _opaqueStrokeInset(trackBorder.bottom),
        ) /
        2;
    final Rect fillRect = Rect.fromLTRB(
      rect.left + adjustment.left,
      rect.top + adjustment.top,
      rect.right - adjustment.right,
      rect.bottom - adjustment.bottom,
    );

    canvas.drawRRect(
      resolvedRadius.toRRect(fillRect).scaleRadii(),
      Paint()..color = decoration.color!,
    );

    final BoxShadow shadow = decoration.insetShadow;
    final double blurOutset = shadow.blurSigma * 3 + shadow.spreadRadius;
    final RRect shadowOuter = track.shift(shadow.offset).inflate(blurOutset);
    final Path shadowRing = Path.combine(
      PathOperation.difference,
      Path()..addRRect(shadowOuter),
      Path()..addRRect(track),
    );
    canvas.save();
    canvas.clipRRect(track);
    canvas.drawPath(
      shadowRing,
      Paint()
        ..color = shadow.color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow.blurSigma),
    );
    canvas.restore();

    trackBorder.paint(
      canvas,
      rect,
      shape: BoxShape.rectangle,
      borderRadius: resolvedRadius,
      textDirection: textDirection,
    );
  }

  double _opaqueStrokeInset(BorderSide side) =>
      side.color.a == 1.0 && side.style == BorderStyle.solid
      ? side.strokeInset
      : 0;
}

/// Animal Island Switch component (C13).
///
/// Features:
/// - Smooth spring physics with tactile haptic feedback
/// - Keyboard accessibility (Tab to focus, Space / Enter to toggle)
/// - Embedded children [checkedChildren] and [unCheckedChildren] inside the track
/// - Asynchronous [loading] indicator inside the thumb
/// - Full theme-aware styling with sunken track
/// - Visual overrides through [style] and
///   `AnimalIslandTheme.components.switchControl`
class AnimalSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final AnimalSwitchSize size;

  /// Visual overrides for this switch; they take precedence over the theme.
  final AnimalSwitchStyle? style;
  final bool disabled;
  final bool readOnly;
  final bool loading;
  final Widget? checkedChildren;
  final Widget? unCheckedChildren;
  final FocusNode? focusNode;

  const AnimalSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = AnimalSwitchSize.defaultSize,
    this.style,
    this.disabled = false,
    this.readOnly = false,
    this.loading = false,
    this.checkedChildren,
    this.unCheckedChildren,
    this.focusNode,
  });

  @override
  State<AnimalSwitch> createState() => _AnimalSwitchState();
}

class _FiniteSwitchWidth extends StatelessWidget {
  const _FiniteSwitchWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints constraints) {
      if (!constraints.hasBoundedWidth || !constraints.maxWidth.isFinite) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('AnimalSwitch requires a finite maximum width.'),
          ErrorDescription(
            'Its adaptive track and labels cannot lay out safely when the '
            'parent passes an unbounded horizontal constraint.',
          ),
          ErrorHint(
            'Use Flexible in a bounded Row, or wrap the switch in a '
            'ConstrainedBox with maxWidth when it is inside horizontal '
            'scrolling content.',
          ),
        ]);
      }
      return child;
    },
  );
}

class _SwitchLabelLayout extends MultiChildRenderObjectWidget {
  const _SwitchLabelLayout({
    required this.minimumTrackWidth,
    required this.minimumTrackHeight,
    required this.thumbRailReservation,
    required this.thumbAtLogicalStart,
    required this.textDirection,
    required super.children,
  });

  final double minimumTrackWidth;
  final double minimumTrackHeight;
  final double thumbRailReservation;
  final bool thumbAtLogicalStart;
  final TextDirection textDirection;

  @override
  _RenderSwitchLabelLayout createRenderObject(BuildContext context) =>
      _RenderSwitchLabelLayout(
        minimumTrackWidth: minimumTrackWidth,
        minimumTrackHeight: minimumTrackHeight,
        thumbRailReservation: thumbRailReservation,
        thumbAtLogicalStart: thumbAtLogicalStart,
        textDirection: textDirection,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSwitchLabelLayout renderObject,
  ) {
    renderObject
      ..minimumTrackWidth = minimumTrackWidth
      ..minimumTrackHeight = minimumTrackHeight
      ..thumbRailReservation = thumbRailReservation
      ..thumbAtLogicalStart = thumbAtLogicalStart
      ..textDirection = textDirection;
  }
}

class _SwitchLabelParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderSwitchLabelLayout extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _SwitchLabelParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _SwitchLabelParentData> {
  _RenderSwitchLabelLayout({
    required this._minimumTrackWidth,
    required this._minimumTrackHeight,
    required this._thumbRailReservation,
    required this._thumbAtLogicalStart,
    required this._textDirection,
  });

  double _minimumTrackWidth;
  double get minimumTrackWidth => _minimumTrackWidth;
  set minimumTrackWidth(double value) {
    if (_minimumTrackWidth == value) return;
    _minimumTrackWidth = value;
    markNeedsLayout();
  }

  double _minimumTrackHeight;
  double get minimumTrackHeight => _minimumTrackHeight;
  set minimumTrackHeight(double value) {
    if (_minimumTrackHeight == value) return;
    _minimumTrackHeight = value;
    markNeedsLayout();
  }

  double _thumbRailReservation;
  double get thumbRailReservation => _thumbRailReservation;
  set thumbRailReservation(double value) {
    if (_thumbRailReservation == value) return;
    _thumbRailReservation = value;
    markNeedsLayout();
  }

  bool _thumbAtLogicalStart;
  bool get thumbAtLogicalStart => _thumbAtLogicalStart;
  set thumbAtLogicalStart(bool value) {
    if (_thumbAtLogicalStart == value) return;
    _thumbAtLogicalStart = value;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  TextDirection get textDirection => _textDirection;
  set textDirection(TextDirection value) {
    if (_textDirection == value) return;
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _SwitchLabelParentData) {
      child.parentData = _SwitchLabelParentData();
    }
  }

  @override
  void performLayout() {
    assert(childCount == 2);
    final double availableTrackWidth = constraints.maxWidth;
    final double availableLabelWidth =
        (availableTrackWidth - thumbRailReservation)
            .clamp(0.0, double.infinity)
            .toDouble();
    final BoxConstraints labelConstraints = BoxConstraints(
      maxWidth: availableLabelWidth,
      maxHeight: constraints.maxHeight,
    );
    final List<RenderBox> labels = <RenderBox>[];
    double labelWidth = 0;
    double labelHeight = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      child.layout(labelConstraints, parentUsesSize: true);
      labels.add(child);
      if (child.size.width > labelWidth) labelWidth = child.size.width;
      if (child.size.height > labelHeight) labelHeight = child.size.height;
      child = childAfter(child);
    }

    size = constraints.constrain(
      Size(
        minimumTrackWidth > thumbRailReservation + labelWidth
            ? minimumTrackWidth
            : thumbRailReservation + labelWidth,
        minimumTrackHeight > labelHeight ? minimumTrackHeight : labelHeight,
      ),
    );

    final bool alignToPhysicalRight =
        (thumbAtLogicalStart && textDirection == TextDirection.ltr) ||
        (!thumbAtLogicalStart && textDirection == TextDirection.rtl);
    final bool physicalSlotStartsAtZero =
        (thumbAtLogicalStart && textDirection == TextDirection.rtl) ||
        (!thumbAtLogicalStart && textDirection == TextDirection.ltr);
    for (final RenderBox label in labels) {
      final double left = alignToPhysicalRight
          ? size.width - label.size.width
          : (physicalSlotStartsAtZero ? 0 : thumbRailReservation);
      final _SwitchLabelParentData parentData =
          label.parentData! as _SwitchLabelParentData;
      parentData.offset = Offset(left, (size.height - label.size.height) / 2);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);
}

class _AnimalSwitchState extends State<AnimalSwitch>
    with SingleTickerProviderStateMixin {
  static const double _labelFadeOutEnd = 0.12;
  static const double _thumbArrivalPhase = 0.78;

  FocusNode? _internalFocusNode;
  bool _isFocused = false;
  late final AnimalLifecycleObserver _lifecycleObserver;
  late final AnimationController _transitionController;
  bool _transitioning = false;
  bool _transitionFromValue = false;
  bool _transitionToValue = false;
  bool _transitionStartsBlank = false;
  double _transitionInitialLabelOpacity = 1;
  double _thumbFromProgress = 0;
  double _thumbTargetProgress = 0;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _canInteract =>
      !_isDisabled && !widget.readOnly && widget.onChanged != null;

  bool get _isDisabled =>
      widget.disabled ||
      widget.loading ||
      (widget.onChanged == null && !widget.readOnly);

  @override
  void initState() {
    super.initState();
    _thumbFromProgress = widget.value ? 1 : 0;
    _thumbTargetProgress = _thumbFromProgress;
    _transitionFromValue = widget.value;
    _transitionToValue = widget.value;
    _transitionController = AnimationController(
      vsync: this,
      duration: Duration.zero,
    )..addStatusListener(_handleTransitionStatus);
    _lifecycleObserver = AnimalLifecycleObserver(
      onStateChanged: _handleLifecycleState,
    )..attach();
  }

  void _handleLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    setState(() {
      if (state != AppLifecycleState.resumed && _transitioning) {
        _finishTransitionImmediately();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_transitioning && !AnimalMotionPolicy.shouldAnimate(context)) {
      _finishTransitionImmediately();
    }
  }

  @override
  void didUpdateWidget(covariant AnimalSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _beginTransition(from: oldWidget.value, to: widget.value);
    }
  }

  void _handleTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !_transitioning || !mounted) {
      return;
    }
    setState(() {
      _transitioning = false;
      _transitionStartsBlank = false;
      _transitionInitialLabelOpacity = 1;
      _thumbFromProgress = _thumbTargetProgress;
    });
  }

  void _finishTransitionImmediately() {
    _transitionController.stop();
    _transitioning = false;
    _transitionStartsBlank = false;
    _transitionInitialLabelOpacity = 1;
    _thumbFromProgress = _thumbTargetProgress;
    _transitionController.value = 1;
  }

  void _beginTransition({required bool from, required bool to}) {
    final bool interruptedTransition = _transitioning;
    final double previousPhase = _transitionController.value;
    final theme = AnimalIslandTheme.of(context);
    bool? visibleLabelValue;
    double visibleLabelOpacity = 0;
    if (!interruptedTransition) {
      visibleLabelValue = from;
      visibleLabelOpacity = 1;
    } else if (previousPhase < _labelFadeOutEnd) {
      visibleLabelValue = _transitionFromValue;
      final double previousFade = theme.motion.ease
          .transform(previousPhase / _labelFadeOutEnd)
          .clamp(0.0, 1.0)
          .toDouble();
      visibleLabelOpacity = _transitionInitialLabelOpacity * (1 - previousFade);
    } else if (previousPhase >= _thumbArrivalPhase) {
      visibleLabelValue = _transitionToValue;
      visibleLabelOpacity = theme.motion.ease
          .transform(
            (previousPhase - _thumbArrivalPhase) / (1 - _thumbArrivalPhase),
          )
          .clamp(0.0, 1.0)
          .toDouble();
    }
    if (visibleLabelOpacity <= 0.001) visibleLabelValue = null;
    final double currentProgress = _currentThumbProgress;
    _transitionController.stop();
    _transitionFromValue = visibleLabelValue ?? from;
    _transitionToValue = to;
    _transitionStartsBlank = visibleLabelValue == null;
    _transitionInitialLabelOpacity = visibleLabelOpacity;
    _thumbFromProgress = currentProgress;
    _thumbTargetProgress = to ? 1 : 0;

    final Duration duration = theme.motion.normal;
    if (!AnimalMotionPolicy.shouldAnimate(context) ||
        duration == Duration.zero) {
      _finishTransitionImmediately();
      return;
    }

    _transitioning = true;
    _transitionController.duration = duration;
    _transitionController.forward(from: 0);
  }

  double _progressAt(double phase, Curve curve) {
    if (!_transitioning) return _thumbTargetProgress;
    final double movementPhase =
        ((phase - _labelFadeOutEnd) / (_thumbArrivalPhase - _labelFadeOutEnd))
            .clamp(0.0, 1.0)
            .toDouble();
    final double curvedPhase = curve
        .transform(movementPhase)
        .clamp(0.0, 1.0)
        .toDouble();
    return _thumbFromProgress +
        (_thumbTargetProgress - _thumbFromProgress) * curvedPhase;
  }

  double get _currentThumbProgress => _progressAt(
    _transitionController.value,
    AnimalIslandTheme.of(context).motion.spring,
  );

  double _labelOpacity(bool checked, double phase, Curve curve) {
    if (!_transitioning) return checked == widget.value ? 1 : 0;
    if (phase < _labelFadeOutEnd) {
      if (_transitionStartsBlank || checked != _transitionFromValue) return 0;
      final double fade = curve.transform(phase / _labelFadeOutEnd);
      return (_transitionInitialLabelOpacity * (1 - fade))
          .clamp(0.0, 1.0)
          .toDouble();
    }
    if (phase < _thumbArrivalPhase || checked != _transitionToValue) {
      return 0;
    }
    final double fade = curve.transform(
      (phase - _thumbArrivalPhase) / (1 - _thumbArrivalPhase),
    );
    return fade.clamp(0.0, 1.0).toDouble();
  }

  @override
  void dispose() {
    _lifecycleObserver.detach();
    _transitionController
      ..removeStatusListener(_handleTransitionStatus)
      ..dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!_canInteract) return;
    widget.onChanged!(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final bool effectiveChecked = widget.value;
    final _ResolvedSwitchStyle resolved = _ResolvedSwitchStyle.resolve(
      theme: theme,
      size: widget.size,
      style: widget.style,
      checked: effectiveChecked,
      disabled: _isDisabled,
    );

    final double padding = resolved.thumbInset;
    final double thumbRailReservation =
        resolved.thumbSize + padding * 2 + resolved.labelGap;
    final bool hasLabels =
        widget.checkedChildren != null || widget.unCheckedChildren != null;
    final Duration animationDuration = AnimalMotionPolicy.shouldAnimate(context)
        ? theme.motion.normal
        : Duration.zero;

    Widget switchLabel({
      required double opacity,
      required TextStyle style,
      required Widget child,
    }) {
      final bool active = opacity >= 0.5;
      return TickerMode(
        enabled: active,
        child: ExcludeFocus(
          excluding: !active,
          child: IgnorePointer(
            ignoring: !active,
            child: ExcludeSemantics(
              excluding: !active,
              child: Opacity(
                opacity: opacity,
                child: DefaultTextStyle(style: style, child: child),
              ),
            ),
          ),
        ),
      );
    }

    final Widget thumb = Container(
      width: resolved.thumbSize,
      height: resolved.thumbSize,
      decoration: BoxDecoration(
        color: resolved.thumbColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: resolved.thumbBorderColor,
          width: resolved.thumbBorderWidth,
        ),
        boxShadow: const <BoxShadow>[],
      ),
      alignment: Alignment.center,
      child: widget.loading
          ? SizedBox(
              width: resolved.loadingIndicatorSize,
              height: resolved.loadingIndicatorSize,
              child: CircularProgressIndicator(
                strokeWidth: resolved.loadingStrokeWidth,
                valueColor: AlwaysStoppedAnimation<Color>(
                  resolved.loadingIndicatorColor,
                ),
              ),
            )
          : null,
    );

    return InteractiveRegion(
      onPressed: _handleToggle,
      disabled: _isDisabled,
      readOnly: widget.readOnly,
      focusNode: _effectiveFocusNode,
      onFocusChanged: (focused) => setState(() => _isFocused = focused),
      semanticButton: false,
      semanticLabel: AnimalLocalizations.of(context)!.switchSemanticLabel,
      toggled: effectiveChecked,
      child: _FiniteSwitchWidth(
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Container(
            foregroundDecoration: _isFocused
                ? BoxDecoration(
                    borderRadius: resolved.borderRadius,
                    border: Border.all(
                      color: resolved.focusColor,
                      width: resolved.focusBorderWidth,
                    ),
                  )
                : null,
            child: AnimatedContainer(
              duration: animationDuration,
              curve: theme.motion.ease,
              decoration: _SwitchTrackDecoration(
                color: resolved.trackColor,
                borderRadius: resolved.borderRadius,
                border: Border.all(
                  color: resolved.trackBorderColor,
                  width: resolved.trackBorderWidth,
                ),
                insetShadow: resolved.trackInsetShadow,
              ),
              child: AnimatedBuilder(
                animation: _transitionController,
                builder: (BuildContext context, Widget? _) {
                  final double phase = _transitionController.value;
                  final double thumbProgress = _progressAt(
                    phase,
                    theme.motion.spring,
                  );
                  final bool labelLayoutValue =
                      !_transitioning || phase >= _labelFadeOutEnd
                      ? effectiveChecked
                      : _transitionFromValue;

                  final Widget sizingContent;
                  if (hasLabels) {
                    sizingContent = _SwitchLabelLayout(
                      minimumTrackWidth: resolved.width,
                      minimumTrackHeight: resolved.height,
                      thumbRailReservation: thumbRailReservation,
                      thumbAtLogicalStart: !labelLayoutValue,
                      textDirection: Directionality.of(context),
                      children: <Widget>[
                        switchLabel(
                          opacity: _labelOpacity(
                            true,
                            phase,
                            theme.motion.ease,
                          ),
                          style: resolved.checkedLabelStyle,
                          child:
                              widget.checkedChildren ?? const SizedBox.shrink(),
                        ),
                        switchLabel(
                          opacity: _labelOpacity(
                            false,
                            phase,
                            theme.motion.ease,
                          ),
                          style: resolved.uncheckedLabelStyle,
                          child:
                              widget.unCheckedChildren ??
                              const SizedBox.shrink(),
                        ),
                      ],
                    );
                  } else {
                    sizingContent = SizedBox(
                      width: resolved.width,
                      height: resolved.height,
                    );
                  }

                  return Stack(
                    children: <Widget>[
                      sizingContent,
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: Align(
                            alignment: AlignmentDirectional.lerp(
                              AlignmentDirectional.centerStart,
                              AlignmentDirectional.centerEnd,
                              thumbProgress,
                            )!,
                            child: thumb,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The switch's visual values, resolved once per build.
///
/// Precedence: the switch's own style, then the theme's size-specific style,
/// then the theme's general style, then defaults derived from theme tokens.
class _ResolvedSwitchStyle {
  final double width;
  final double height;
  final double thumbSize;
  final double thumbInset;
  final double labelGap;
  final double trackBorderWidth;
  final double thumbBorderWidth;
  final double focusBorderWidth;
  final double loadingStrokeWidth;
  final double loadingIndicatorSize;
  final BorderRadius borderRadius;
  final TextStyle checkedLabelStyle;
  final TextStyle uncheckedLabelStyle;
  final Color trackColor;
  final Color trackBorderColor;
  final Color thumbColor;
  final Color thumbBorderColor;
  final Color loadingIndicatorColor;
  final Color focusColor;
  final BoxShadow trackInsetShadow;

  const _ResolvedSwitchStyle._({
    required this.width,
    required this.height,
    required this.thumbSize,
    required this.thumbInset,
    required this.labelGap,
    required this.trackBorderWidth,
    required this.thumbBorderWidth,
    required this.focusBorderWidth,
    required this.loadingStrokeWidth,
    required this.loadingIndicatorSize,
    required this.borderRadius,
    required this.checkedLabelStyle,
    required this.uncheckedLabelStyle,
    required this.trackColor,
    required this.trackBorderColor,
    required this.thumbColor,
    required this.thumbBorderColor,
    required this.loadingIndicatorColor,
    required this.focusColor,
    required this.trackInsetShadow,
  });

  /// Default metrics per size. Label font sizes scale `typography.body` by
  /// these registered ratios, so the standard 14 logical-pixel body gives
  /// 11/13.
  static ({double width, double height, double thumbSize, double factor})
  _metrics(AnimalSwitchSize size) => switch (size) {
    AnimalSwitchSize.small => (
      width: 46,
      height: 26,
      thumbSize: 18,
      factor: 11 / 14,
    ),
    AnimalSwitchSize.defaultSize => (
      width: 58,
      height: 32,
      thumbSize: 24,
      factor: 13 / 14,
    ),
  };

  /// Loading indicator diameter as a fraction of the thumb diameter.
  static const double _loadingIndicatorRatio = 0.6;

  static _ResolvedSwitchStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalSwitchSize size,
    required AnimalSwitchStyle? style,
    required bool checked,
    required bool disabled,
  }) {
    final AnimalSwitchThemeData? themed = theme.components.switchControl;
    final AnimalSwitchStyle? sized = switch (size) {
      AnimalSwitchSize.small => themed?.smallStyle,
      AnimalSwitchSize.defaultSize => themed?.defaultSizeStyle,
    };
    final AnimalSwitchStyle merged = (style ?? AnimalSwitchStyle())
        .merge(sized)
        .merge(themed?.style);

    final colors = theme.colors;
    final bool dark = colors.brightness == Brightness.dark;
    final Set<WidgetState> states = <WidgetState>{
      if (checked) WidgetState.selected,
      if (disabled) WidgetState.disabled,
    };
    final metrics = _metrics(size);

    final Color neutralBorder = dark ? colors.border : colors.borderLight;
    final Color defaultBorder = !disabled && checked
        ? colors.success
        : neutralBorder;

    final double height = merged.height ?? metrics.height;
    final double thumbSize = merged.thumbSize ?? metrics.thumbSize;
    final double inset = (height - thumbSize) / 2;

    final TextStyle baseLabel = theme.typography.resolve(
      theme.typography.body
          .apply(fontSizeFactor: metrics.factor)
          .copyWith(fontWeight: FontWeight.bold)
          .merge(merged.labelTextStyle),
    );
    Color labelTextColor(bool labelChecked) =>
        merged.labelTextColor?.resolve(<WidgetState>{
          if (labelChecked) WidgetState.selected,
          if (disabled) WidgetState.disabled,
        }) ??
        (labelChecked ? colors.onSuccess : colors.textSecondary);

    return _ResolvedSwitchStyle._(
      width: merged.width ?? metrics.width,
      height: height,
      thumbSize: thumbSize,
      thumbInset: inset > 0 ? inset : 0,
      labelGap: merged.labelGap ?? 4,
      trackBorderWidth: merged.trackBorderWidth ?? 1.5,
      thumbBorderWidth: merged.thumbBorderWidth ?? 1.2,
      focusBorderWidth: merged.focusBorderWidth ?? 2,
      loadingStrokeWidth: merged.loadingStrokeWidth ?? 2,
      loadingIndicatorSize: thumbSize * _loadingIndicatorRatio,
      borderRadius: merged.borderRadius ?? BorderRadius.circular(999),
      checkedLabelStyle: baseLabel.copyWith(color: labelTextColor(true)),
      uncheckedLabelStyle: baseLabel.copyWith(color: labelTextColor(false)),
      trackColor:
          merged.trackColor?.resolve(states) ??
          (disabled
              ? (dark ? colors.surfaceAlt : colors.bgDisabled)
              : (checked ? colors.success : colors.bgSecondary)),
      trackBorderColor:
          merged.trackBorderColor?.resolve(states) ?? defaultBorder,
      thumbColor:
          merged.thumbColor?.resolve(states) ??
          (disabled ? colors.surfaceHeader : colors.bgContent),
      thumbBorderColor:
          merged.thumbBorderColor?.resolve(states) ?? defaultBorder,
      loadingIndicatorColor:
          merged.loadingIndicatorColor?.resolve(states) ??
          (checked ? colors.onSuccess : colors.textSecondary),
      focusColor: resolveFocusRing(theme).color,
      trackInsetShadow:
          merged.trackInsetShadow ??
          theme.shadows.softElevation.copyWith(
            offset: Offset.zero,
            spreadRadius: 0,
          ),
    );
  }
}
