import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../tokens/radii.dart';
import '../tokens/shadows.dart';
import '../tokens/theme.dart';

/// Low-level primitive providing tactile 3D game button press physics.
///
/// Features:
/// - Smooth 3D depth sinking on press
/// - Hardware haptic feedback (`HapticFeedback.lightImpact()`)
/// - Cubic-bezier spring recoil (`AnimalMotion.ease`)
/// - Full keyboard accessibility (Tab focus, Enter/Space activation)
/// - Full screen-reader Semantics with onTap/onLongPress action bindings
class AnimalPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final double depth;
  final Color surfaceColor;
  final Color? depthColor;
  final BorderRadius borderRadius;
  final Border? border;
  final List<BoxShadow>? extraShadows;
  final EdgeInsetsGeometry? padding;
  final bool enableHaptics;
  final bool disabled;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final bool? selected;

  const AnimalPressable({
    super.key,
    required this.child,
    required this.onPressed,
    this.onLongPress,
    this.depth = 4.0,
    required this.surfaceColor,
    this.depthColor,
    this.borderRadius = AnimalRadii.pillBorder,
    this.border,
    this.extraShadows,
    this.padding,
    this.enableHaptics = true,
    this.disabled = false,
    this.focusNode,
    this.semanticLabel,
    this.selected,
  });

  @override
  State<AnimalPressable> createState() => _AnimalPressableState();
}

class _AnimalPressableState extends State<AnimalPressable> {
  bool _isPressed = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  bool get _canPress => !widget.disabled && widget.onPressed != null;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant AnimalPressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      if (oldWidget.focusNode == null) {
        _focusNode.removeListener(_handleFocusChange);
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
      _isFocused = _focusNode.hasFocus;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_canPress) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_canPress) return;
    setState(() => _isPressed = false);
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    if (!_canPress) return;
    setState(() => _isPressed = false);
  }

  void _triggerPressAction() {
    if (!_canPress) return;
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
    setState(() => _isPressed = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isPressed = false);
        widget.onPressed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveDepth = widget.disabled ? 0.0 : widget.depth;
    final double currentTop = _isPressed ? effectiveDepth : 0.0;
    final double bottomMargin = _isPressed ? 0.0 : effectiveDepth;

    final shadows = <BoxShadow>[
      if (widget.extraShadows != null) ...widget.extraShadows!,
      if (!_isPressed && effectiveDepth > 0 && widget.depthColor != null)
        BoxShadow(
          color: widget.depthColor!,
          offset: Offset(0, effectiveDepth),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      if (_isFocused && !widget.disabled)
        BoxShadow(
          color: theme.focusYellow.withValues(alpha: 0.6),
          offset: Offset.zero,
          blurRadius: 4,
          spreadRadius: 2,
        ),
    ];

    return Semantics(
      button: true,
      enabled: _canPress,
      label: widget.semanticLabel,
      selected: widget.selected,
      onTap: _canPress ? _triggerPressAction : null,
      onLongPress: _canPress && widget.onLongPress != null ? widget.onLongPress : null,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        enabled: _canPress,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) => _triggerPressAction(),
          ),
        },
        child: MouseRegion(
          cursor: _canPress ? SystemMouseCursors.click : (widget.disabled ? SystemMouseCursors.forbidden : MouseCursor.defer),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: _canPress ? widget.onLongPress : null,
            child: Padding(
              padding: EdgeInsets.only(top: currentTop, bottom: bottomMargin),
              child: AnimatedContainer(
                duration: AnimalMotion.fast,
                curve: AnimalMotion.ease,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.surfaceColor,
                  borderRadius: widget.borderRadius,
                  border: widget.border,
                  boxShadow: shadows,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
