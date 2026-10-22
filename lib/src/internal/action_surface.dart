import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'presentation_focus.dart';

/// Common activation behavior. Appearance stays with the owning component.
class ActionSurface extends StatefulWidget {
  const ActionSurface({
    super.key,
    required this.builder,
    required this.onActivate,
    this.focusNode,
    this.onKeyboardActivate,
    this.autofocus = false,
    this.label,
    this.selected,
    this.checked,
    this.toggled,
    this.inMutuallyExclusiveGroup = false,
    this.expanded,
    this.button = true,
    this.passiveHover = false,
    this.isolateChildFocus = false,
    this.mouseCursor,
  });

  /// One per-state precedence rule; explicit transparent values are present.
  static T resolveStyleValue<T>(
    Set<WidgetState> states,
    WidgetStateProperty<T?>? instance,
    WidgetStateProperty<T?>? theme,
    T fallback,
  ) => instance?.resolve(states) ?? theme?.resolve(states) ?? fallback;

  final Widget Function(BuildContext, Set<WidgetState>) builder;
  final VoidCallback? onActivate;
  final VoidCallback? onKeyboardActivate;
  final FocusNode? focusNode;
  final bool autofocus, button;
  final bool inMutuallyExclusiveGroup;

  /// Observe hover without inventing an action or a focus target.
  final bool passiveHover;

  /// Fixed anatomy for composite parents: their action is not the owner of
  /// independently focusable child controls.
  final bool isolateChildFocus;

  final MouseCursor? mouseCursor;
  final String? label;
  final bool? selected, checked, toggled, expanded;
  @override
  State<ActionSurface> createState() => _ActionSurfaceState();
}

class _ActionSurfaceState extends State<ActionSurface> {
  bool _hover = false, _focus = false, _press = false;
  FocusNode? _ownedFocus;
  int _presentationGeneration = 0;
  FocusNode get node => widget.focusNode ?? _ownedFocus!;
  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) _ownedFocus = FocusNode();
  }

  @override
  void dispose() {
    _presentationGeneration++;
    _ownedFocus?.dispose();
    super.dispose();
  }

  void _dispatch({bool keyboard = false}) {
    if (keyboard && !node.hasPrimaryFocus) return;
    if (widget.onActivate != null) {
      node.requestFocus();
      (keyboard
          ? widget.onKeyboardActivate ?? widget.onActivate!
          : widget.onActivate!)();
    }
  }

  void pressed(bool value) {
    if (mounted && _press != value) setState(() => _press = value);
  }

  @override
  void didUpdateWidget(covariant ActionSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _presentationGeneration++;
      _ownedFocus?.dispose();
      _ownedFocus = widget.focusNode == null ? FocusNode() : null;
    }
    if (oldWidget.isolateChildFocus != widget.isolateChildFocus) {
      _presentationGeneration++;
    }
    if (widget.onActivate == null) _press = false;
    if (widget.isolateChildFocus &&
        (oldWidget.onActivate == null) != (widget.onActivate == null)) {
      final childFocus = FocusManager.instance.primaryFocus;
      if (childFocus != null &&
          !identical(childFocus, node) &&
          containsFocus(childFocus)) {
        final generation = ++_presentationGeneration;
        settlePresentationFocus(
          current: () =>
              mounted &&
              generation == _presentationGeneration &&
              childFocus.canRequestFocus &&
              containsFocus(childFocus),
        );
      }
    }
  }

  bool containsFocus(FocusNode focus) {
    var contained = false;
    focus.context?.visitAncestorElements((element) {
      if (identical(element, context)) {
        contained = true;
        return false;
      }
      return true;
    });
    return contained;
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onActivate != null;
    final states = <WidgetState>{
      if (!enabled) WidgetState.disabled,
      if (_hover && (enabled || widget.passiveHover)) WidgetState.hovered,
      if (_focus) WidgetState.focused,
      if (_press && enabled) WidgetState.pressed,
      if (widget.selected == true) WidgetState.selected,
    };
    return Semantics(
      container:
          widget.button || widget.checked != null || widget.toggled != null,
      button: widget.button,
      enabled: widget.button || widget.checked != null || widget.toggled != null
          ? enabled
          : null,
      label: widget.label,
      selected: widget.selected,
      checked: widget.checked,
      toggled: widget.toggled,
      inMutuallyExclusiveGroup: widget.inMutuallyExclusiveGroup,
      expanded: widget.expanded,
      child: MouseRegion(
        cursor:
            widget.mouseCursor ??
            (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: FocusableActionDetector(
          enabled: enabled,
          focusNode: node,
          autofocus: widget.autofocus,
          onShowFocusHighlight: (v) => setState(() => _focus = v),
          shortcuts: const {
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: {
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                _dispatch(keyboard: true);
                return null;
              },
            ),
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? () => _dispatch() : null,
            onTapDown: enabled ? (_) => pressed(true) : null,
            onTapUp: enabled ? (_) => pressed(false) : null,
            onTapCancel: enabled ? () => pressed(false) : null,
            child: widget.isolateChildFocus
                ? Focus(
                    parentNode:
                        Focus.maybeOf(context, scopeOk: true) ??
                        FocusManager.instance.rootScope,
                    includeSemantics: false,
                    canRequestFocus: false,
                    skipTraversal: true,
                    child: widget.builder(context, states),
                  )
                : widget.builder(context, states),
          ),
        ),
      ),
    );
  }
}

/// Owns modal Tab events and a skipped focus target for empty content.
/// The existing FocusScope retains order/policy; opaque child focus wins.
class ClosedLoopTraversal extends StatefulWidget {
  const ClosedLoopTraversal({super.key, required this.child});
  final Widget child;
  @override
  State<ClosedLoopTraversal> createState() => _ClosedLoopTraversalState();
}

class _ClosedLoopTraversalState extends State<ClosedLoopTraversal> {
  final fallback = FocusNode(skipTraversal: true);
  FocusScopeNode? scope;
  bool pending = false;
  bool get closed =>
      scope?.traversalEdgeBehavior == TraversalEdgeBehavior.closedLoop;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = FocusScope.of(context);
    if (next != scope) {
      scope?.removeListener(scheduleEmptyFocus);
      scope = next;
      scope!.addListener(scheduleEmptyFocus);
    }
    scheduleEmptyFocus();
  }

  void scheduleEmptyFocus() {
    if (pending || !closed || scope?.hasPrimaryFocus != true) return;
    pending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pending = false;
      if (mounted &&
          closed &&
          scope?.hasPrimaryFocus == true &&
          fallback.context != null &&
          fallback.canRequestFocus) {
        fallback.requestFocus();
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void move(bool forward) {
    final node = FocusManager.instance.primaryFocus;
    if (node == null || node is FocusScopeNode) return;
    if (forward) {
      node.nextFocus();
    } else {
      node.previousFocus();
    }
  }

  @override
  void dispose() {
    scope?.removeListener(scheduleEmptyFocus);
    fallback.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Actions(
    actions: {
      if (closed) ...{
        NextFocusIntent: CallbackAction<NextFocusIntent>(
          onInvoke: (_) {
            move(true);
            return null;
          },
        ),
        PreviousFocusIntent: CallbackAction<PreviousFocusIntent>(
          onInvoke: (_) {
            move(false);
            return null;
          },
        ),
      },
    },
    child: Focus(
      focusNode: fallback,
      canRequestFocus: closed,
      skipTraversal: true,
      includeSemantics: false,
      child: widget.child,
    ),
  );
}
