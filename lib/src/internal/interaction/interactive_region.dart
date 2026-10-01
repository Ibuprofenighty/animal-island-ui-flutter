import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../foundation/theme/theme.dart';
import 'focus_ring.dart';

typedef InteractiveSemanticsBuilder = SemanticsProperties Function(
  bool enabled,
  bool visible,
  VoidCallback? activate,
);

/// Owns pointer, keyboard, and accessibility activation for one leaf target.
///
/// Component state and group navigation stay with the owning component. This
/// widget only owns activation, focus lifecycle, hit-target sizing, and focus
/// presentation.
class InteractiveRegion extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double depth;
  final Color? surfaceColor;
  final BoxShadow? depthShadow;
  final BorderRadius? borderRadius;
  final Border? border;
  final List<BoxShadow>? extraShadows;
  final EdgeInsetsGeometry? padding;
  final bool enableHaptics;
  final bool disabled;
  final bool busy;
  final bool visible;
  final bool focusOnHover;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final bool semanticButton;
  final bool semanticContainer;
  final bool? selected;
  final bool? checked;
  final bool? mixed;
  final bool? toggled;
  final bool? expanded;
  final bool inMutuallyExclusiveGroup;
  final String? semanticValue;
  final InteractiveSemanticsBuilder? semanticsBuilder;
  final FocusOnKeyEventCallback? onKeyEvent;
  final ValueChanged<bool>? onFocusChanged;
  final double minimumHitSize;

  const InteractiveRegion({
    super.key,
    required this.child,
    required this.onPressed,
    this.depth = 0,
    this.surfaceColor,
    this.depthShadow,
    this.borderRadius,
    this.border,
    this.extraShadows,
    this.padding,
    this.enableHaptics = true,
    this.disabled = false,
    this.busy = false,
    this.visible = true,
    this.focusOnHover = false,
    this.focusNode,
    this.semanticLabel,
    this.semanticButton = true,
    this.semanticContainer = false,
    this.selected,
    this.checked,
    this.mixed,
    this.toggled,
    this.expanded,
    this.inMutuallyExclusiveGroup = false,
    this.semanticValue,
    this.semanticsBuilder,
    this.onKeyEvent,
    this.onFocusChanged,
    this.minimumHitSize = 48,
  }) : assert(minimumHitSize >= 48);

  @override
  State<InteractiveRegion> createState() => _InteractiveRegionState();
}

class _InteractiveRegionState extends State<InteractiveRegion> {
  bool _isPointerPressed = false;
  bool _isFocused = false;
  bool _invalidKeySequence = false;
  int _generation = 0;
  int? _pointerGeneration;
  int? _keyGeneration;
  LogicalKeyboardKey? _armedKey;
  final Set<LogicalKeyboardKey> _keysDown = <LogicalKeyboardKey>{};
  FocusNode? _internalFocusNode;
  FocusNode? _listenedFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  bool get _canActivate =>
      widget.visible &&
      !widget.disabled &&
      !widget.busy &&
      widget.onPressed != null;

  static const List<LogicalKeyboardKey> _activationKeys = <LogicalKeyboardKey>[
    LogicalKeyboardKey.enter,
    LogicalKeyboardKey.numpadEnter,
    LogicalKeyboardKey.space,
  ];

  @override
  void initState() {
    super.initState();
    _attachFocusListener(_effectiveFocusNode);
  }

  @override
  void didUpdateWidget(covariant InteractiveRegion oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newFocusNode = _effectiveFocusNode;
    if (!identical(newFocusNode, _listenedFocusNode)) {
      final oldHasFocus = _isFocused;
      _detachFocusListener();
      _attachFocusListener(newFocusNode);
      _isFocused = newFocusNode.hasFocus;
      _cancelPendingActivation();
      if (oldHasFocus != _isFocused) {
        widget.onFocusChanged?.call(_isFocused);
      }
    }
    if (widget.onPressed != oldWidget.onPressed ||
        widget.disabled != oldWidget.disabled ||
        widget.busy != oldWidget.busy ||
        widget.visible != oldWidget.visible) {
      _cancelPendingActivation();
    }
    if (!widget.visible && _effectiveFocusNode.hasFocus) {
      _effectiveFocusNode.unfocus();
    }
  }

  void _attachFocusListener(FocusNode node) {
    _listenedFocusNode = node;
    node.addListener(_handleFocusChanged);
    _isFocused = node.hasFocus;
  }

  void _detachFocusListener() {
    _listenedFocusNode?.removeListener(_handleFocusChanged);
    _listenedFocusNode = null;
  }

  @override
  void dispose() {
    _detachFocusListener();
    _internalFocusNode?.dispose();
    _clearPendingActivation();
    super.dispose();
  }

  void _handleFocusChanged() {
    if (!mounted) return;
    final hasFocus = _effectiveFocusNode.hasFocus;
    if (!hasFocus) _cancelPendingActivation();
    if (_isFocused != hasFocus) {
      setState(() => _isFocused = hasFocus);
      widget.onFocusChanged?.call(hasFocus);
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (_activationKeys.contains(event.logicalKey)) {
      return _handleActivationKey(event);
    }
    return widget.onKeyEvent?.call(node, event) ?? KeyEventResult.ignored;
  }

  KeyEventResult _handleActivationKey(KeyEvent event) {
    final key = event.logicalKey;
    if (event is KeyDownEvent) {
      if (!_canActivate) return KeyEventResult.handled;
      if (_keysDown.isEmpty) {
        _generation++;
        _keyGeneration = _generation;
        _armedKey = key;
        _invalidKeySequence = false;
        _playHaptic();
        setState(() {});
      } else if (!_keysDown.contains(key)) {
        _invalidKeySequence = true;
      }
      _keysDown.add(key);
      return KeyEventResult.handled;
    }
    if (event is KeyRepeatEvent) return KeyEventResult.handled;
    if (event is KeyUpEvent) {
      final wasDown = _keysDown.remove(key);
      if (!wasDown && _keysDown.isNotEmpty) {
        _invalidKeySequence = true;
      }
      final canComplete =
          wasDown &&
          !_invalidKeySequence &&
          _armedKey == key &&
          _keyGeneration == _generation &&
          _keysDown.isEmpty &&
          _canActivate &&
          _effectiveFocusNode.hasFocus;
      if (_keysDown.isEmpty) {
        _armedKey = null;
        _keyGeneration = null;
        _invalidKeySequence = false;
      }
      if (mounted) setState(() {});
      if (canComplete) _activate();
      return KeyEventResult.handled;
    }
    return KeyEventResult.handled;
  }

  void _handlePointerDown(TapDownDetails details) {
    if (!_canActivate) return;
    if (_keysDown.isNotEmpty) _cancelKeyboardActivation();
    _generation++;
    _pointerGeneration = _generation;
    _isPointerPressed = true;
    if (!_effectiveFocusNode.hasFocus) _effectiveFocusNode.requestFocus();
    _playHaptic();
    setState(() {});
  }

  void _handlePointerCancel() {
    if (!_isPointerPressed && _pointerGeneration == null) return;
    _cancelPointerActivation();
    if (mounted) setState(() {});
  }

  void _handlePointerTap() {
    final shouldActivate =
        _isPointerPressed && _pointerGeneration == _generation && _canActivate;
    _cancelPointerActivation();
    if (mounted) setState(() {});
    if (shouldActivate) _activate();
  }

  void _handleSemanticsTap() {
    if (!_canActivate) return;
    _cancelPendingActivation();
    _playHaptic();
    _activate();
  }

  void _activate() {
    if (!_canActivate || !mounted) return;
    widget.onPressed?.call();
  }

  void _playHaptic() {
    if (widget.enableHaptics) HapticFeedback.lightImpact();
  }

  void _cancelKeyboardActivation() {
    _keysDown.clear();
    _armedKey = null;
    _keyGeneration = null;
    _invalidKeySequence = false;
  }

  void _cancelPointerActivation() {
    _isPointerPressed = false;
    _pointerGeneration = null;
  }

  void _clearPendingActivation() {
    _cancelPointerActivation();
    _cancelKeyboardActivation();
  }

  void _cancelPendingActivation() {
    final hadPendingPress = _isPointerPressed || _keysDown.isNotEmpty;
    _generation++;
    _clearPendingActivation();
    if (mounted && hadPendingPress) setState(() {});
  }

  void _handleHover(PointerEnterEvent event) {
    if (widget.focusOnHover && _canActivate) {
      _effectiveFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final radius = widget.borderRadius ?? theme.radii.pillBorder;
    final effectiveDepth = _canActivate ? widget.depth : 0.0;
    final pressed = _isPointerPressed || _keysDown.isNotEmpty;
    final top = pressed ? effectiveDepth : 0.0;
    final bottom = pressed ? 0.0 : effectiveDepth;
    final shadows = <BoxShadow>[
      if (widget.extraShadows != null) ...widget.extraShadows!,
      if (!pressed && effectiveDepth > 0 && widget.depthShadow != null)
        widget.depthShadow!,
    ];

    final onActivate = _canActivate ? _handleSemanticsTap : null;
    final properties =
        widget.semanticsBuilder?.call(
          _canActivate,
          widget.visible,
          onActivate,
        ) ??
        SemanticsProperties(
          button: widget.semanticButton,
          enabled: _canActivate,
          hidden: !widget.visible,
          label: widget.semanticLabel,
          selected: widget.selected,
          checked: widget.checked,
          mixed: widget.mixed,
          toggled: widget.toggled,
          expanded: widget.expanded,
          inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup,
          value: widget.semanticValue,
          onTap: onActivate,
        );

    Widget body = AnimatedContainer(
      duration: theme.motion.fast,
      curve: theme.motion.ease,
      constraints: BoxConstraints(
        minWidth: widget.minimumHitSize,
        minHeight: widget.minimumHitSize,
      ),
      margin: EdgeInsets.only(top: top, bottom: bottom),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.surfaceColor,
        borderRadius: radius,
        border: widget.border,
        boxShadow: shadows,
      ),
      child: widget.child,
    );
    body = AnimalFocusRing(
      focused: _isFocused,
      borderRadius: radius,
      child: body,
    );

    return Semantics.fromProperties(
      container: widget.semanticContainer,
      explicitChildNodes: widget.semanticContainer,
      excludeSemantics: properties.label != null && !widget.semanticContainer,
      properties: properties,
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: Focus(
          focusNode: _effectiveFocusNode,
          canRequestFocus: _canActivate,
          skipTraversal: !_canActivate,
          onKeyEvent: _handleKeyEvent,
          child: MouseRegion(
            cursor: _canActivate
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: _handleHover,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              excludeFromSemantics: true,
              onTapDown: _canActivate ? _handlePointerDown : null,
              onTap: _canActivate ? _handlePointerTap : null,
              onTapCancel: _handlePointerCancel,
              child: body,
            ),
          ),
        ),
      ),
    );
  }
}
