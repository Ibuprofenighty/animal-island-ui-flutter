import '../internal/light_surface_scope.dart';
import '../foundation/recipes/drawer.dart';
import '../foundation/theme.dart';

import 'dart:math' as math;
import 'dart:ui' show SemanticsRole;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import '../internal/viewport_overlay.dart';
import 'cursor.dart';

enum IslandDrawerPlacement { left, right, top, bottom }

/// Explicit owner of the background affected by descendant drawers.
/// Install below the Navigator's Overlay, around the page that should recede.
class IslandDrawerHost extends StatefulWidget {
  const IslandDrawerHost({
    super.key,
    required this.child,
    this.backgroundColor = DrawerColors.hostBackplane,
  });

  /// Backplane exposed when the page recedes.
  final Color backgroundColor;
  final Widget child;
  @override
  State<IslandDrawerHost> createState() => _IslandDrawerHostState();
}

class _IslandDrawerHostState extends State<IslandDrawerHost> {
  final active = <Object, bool>{}, pending = <Object, (bool, bool)>{};
  bool scheduled = false;
  void update(Object owner, bool open, bool depth) {
    pending[owner] = (open, depth);
    if (scheduled) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!mounted) return;
      final wasOpen = active.isNotEmpty, wasDepth = active.values.any((v) => v);
      for (final e in pending.entries) {
        if (e.value.$1) {
          active[e.key] = e.value.$2;
        } else {
          active.remove(e.key);
        }
      }
      pending.clear();
      if (wasOpen != active.isNotEmpty ||
          wasDepth != active.values.any((v) => v))
        setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final depth =
        active.values.any((v) => v) && !MediaQuery.disableAnimationsOf(context);
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 360);
    return _DrawerScope(
      owner: this,
      child: IgnorePointer(
        ignoring: active.isNotEmpty,
        child: ExcludeFocus(
          excluding: active.isNotEmpty,
          child: ExcludeSemantics(
            excluding: active.isNotEmpty,
            child: ColoredBox(
              color: widget.backgroundColor,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: depth ? 1 : 0),
                duration: duration,
                curve: const Cubic(.2, 0, .2, 1),
                builder: (context, t, child) => Transform.scale(
                  scale: 1 - .06 * t,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14 * t),
                    child: child,
                  ),
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

class _DrawerScope extends InheritedWidget {
  const _DrawerScope({required this.owner, required super.child});
  final _IslandDrawerHostState owner;
  @override
  bool updateShouldNotify(_DrawerScope old) => old.owner != owner;
}

/// Controlled viewport drawer. Closed content remains mounted.
class IslandDrawer extends StatefulWidget {
  const IslandDrawer({
    super.key,
    required this.open,
    required this.onClose,
    required this.child,
    this.title,
    this.footer,
    this.placement = IslandDrawerPlacement.right,
    this.width = 378,
    this.height = 300,
    this.maskClosable = true,
    this.pushBackground = true,
    this.closeLabel = '关闭',
    this.semanticLabel,
  });
  final bool open, maskClosable, pushBackground;
  final VoidCallback? onClose;
  final Widget child;
  final Widget? title, footer;
  final IslandDrawerPlacement placement;
  final double width, height;
  final String closeLabel;
  final String? semanticLabel;
  @override
  State<IslandDrawer> createState() => _IslandDrawerState();
}

class _IslandDrawerState extends State<IslandDrawer>
    with SingleTickerProviderStateMixin {
  late final motion =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 360),
      )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed && mounted) setState(() {});
      });
  late final panelMotion = CurvedAnimation(
    parent: motion,
    curve: const Cubic(.2, 0, .2, 1),
    reverseCurve: const Cubic(.2, 0, .2, 1).flipped,
  );
  late final maskMotion = CurvedAnimation(
    parent: motion,
    curve: Curves.ease,
    reverseCurve: Curves.ease.flipped,
  );
  final scope = FocusScopeNode(
    traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
  );
  final closeFocus = FocusNode();
  FocusNode? returnFocus;
  _IslandDrawerHostState? host;
  int focusGeneration = 0;
  bool initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = context
        .dependOnInheritedWidgetOfExactType<_DrawerScope>()
        ?.owner;
    if (next == null)
      throw FlutterError(
        'IslandDrawer requires an IslandDrawerHost below the Navigator Overlay.',
      );
    if (next != host) {
      host?.update(this, false, false);
      host = next;
    }
    host!.update(this, widget.open, widget.pushBackground);
    if (!initialized) {
      initialized = true;
      syncEscape();
      transition();
    } else if (MediaQuery.disableAnimationsOf(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && MediaQuery.disableAnimationsOf(context)) {
          final target = widget.open ? 1.0 : 0.0;
          if (motion.value != target || motion.isAnimating)
            motion.value = target;
        }
      });
    }
  }

  @override
  void didUpdateWidget(IslandDrawer old) {
    super.didUpdateWidget(old);
    host?.update(this, widget.open, widget.pushBackground);
    if (old.open != widget.open) transition(duringBuild: true);
    syncEscape();
  }

  void afterLayout(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) callback();
      });
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  /// Reduced motion jumps to [target]. The panel's builder lives in the
  /// viewport overlay, outside the caller's subtree, so a jump requested while
  /// the caller rebuilds is applied after that frame instead of notifying a
  /// non-descendant during build.
  void jump(double target, {required bool duringBuild}) {
    if (!duringBuild) {
      motion.value = target;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && (widget.open ? 1.0 : 0.0) == target) motion.value = target;
    });
  }

  void transition({bool duringBuild = false}) {
    final generation = ++focusGeneration;
    if (widget.open) {
      returnFocus = FocusManager.instance.primaryFocus;
      if (MediaQuery.disableAnimationsOf(context)) {
        jump(1, duringBuild: duringBuild);
      } else {
        motion.forward();
      }
      afterLayout(() {
        if (generation != focusGeneration || !widget.open) return;
        if (widget.onClose != null && widget.title != null) {
          closeFocus.requestFocus();
        } else {
          scope.requestFocus();
        }
      });
    } else {
      if (MediaQuery.disableAnimationsOf(context)) {
        jump(0, duringBuild: duringBuild);
      } else {
        motion.reverse();
      }
      final target = returnFocus;
      afterLayout(() {
        if (generation == focusGeneration &&
            !widget.open &&
            target?.context != null &&
            target!.canRequestFocus)
          target.requestFocus();
      });
    }
  }

  // Reference listens for Escape on `document` while open. Inside the panel
  // the scoped Focus handler owns Escape; this covers focus that left it
  // (e.g. after a pointer interaction elsewhere).
  bool escapeOutside(KeyEvent event) {
    if (!mounted ||
        !widget.open ||
        widget.onClose == null ||
        event is! KeyDownEvent ||
        event.logicalKey != LogicalKeyboardKey.escape ||
        scope.hasFocus) {
      return false;
    }
    widget.onClose!();
    return true;
  }

  bool listening = false;
  void syncEscape() {
    final want = widget.open && widget.onClose != null;
    if (want == listening) return;
    listening = want;
    if (want) {
      HardwareKeyboard.instance.addHandler(escapeOutside);
    } else {
      HardwareKeyboard.instance.removeHandler(escapeOutside);
    }
  }

  @override
  void dispose() {
    if (listening) HardwareKeyboard.instance.removeHandler(escapeOutside);
    focusGeneration++;
    host?.update(this, false, false);
    panelMotion.dispose();
    maskMotion.dispose();
    motion.dispose();
    scope.dispose();
    closeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ViewportOverlay(
    visible: true,
    decorative: !widget.open,
    followsRoute: true,
    builder: (context) {
      final size = MediaQuery.sizeOf(context);
      final horizontal =
          widget.placement == IslandDrawerPlacement.left ||
          widget.placement == IslandDrawerPlacement.right;
      final direction = switch (widget.placement) {
        IslandDrawerPlacement.left => const Offset(-1, 0),
        IslandDrawerPlacement.right => const Offset(1, 0),
        IslandDrawerPlacement.top => const Offset(0, -1),
        IslandDrawerPlacement.bottom => const Offset(0, 1),
      };
      final radius = switch (widget.placement) {
        IslandDrawerPlacement.left => const BorderRadius.horizontal(
          right: Radius.circular(20),
        ),
        IslandDrawerPlacement.right => const BorderRadius.horizontal(
          left: Radius.circular(20),
        ),
        IslandDrawerPlacement.top => const BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
        IslandDrawerPlacement.bottom => const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      };
      final panel = FocusScope(
        node: scope,
        child: ClosedLoopTraversal(
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: (_, event) {
              if (widget.open &&
                  event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.escape) {
                widget.onClose?.call();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Semantics(
              role: SemanticsRole.dialog,
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: widget.semanticLabel,
              child: LightSurfaceScope(
                child: Container(
                  width: horizontal
                      ? math.min(widget.width, math.max(0, size.width - 32))
                      : size.width,
                  height: horizontal
                      ? size.height
                      : math.min(widget.height, math.max(0, size.height - 32)),
                  decoration: BoxDecoration(
                    color: DrawerColors.panel,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: DrawerColors.panelShadow,
                        offset: direction * -12,
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: radius,
                    child: Column(
                      children: [
                        if (widget.title case final title?)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ContentScope(
                                    textStyle: const TextStyle(
                                      fontSize: 28,
                                      height: 1.5,
                                      fontWeight: FontWeight.w700,
                                      color: DrawerColors.title,
                                    ),
                                    child: Semantics(
                                      headingLevel: 2,
                                      child: title,
                                    ),
                                  ),
                                ),
                                ActionSurface(
                                  label: widget.closeLabel,
                                  focusNode: closeFocus,
                                  onActivate: widget.onClose,
                                  // Reference `.close` `transition: all 0.2s`
                                  // (CSS ease); reduced motion settles.
                                  builder: (context, states) =>
                                      AnimatedContainer(
                                        duration:
                                            MediaQuery.disableAnimationsOf(
                                              context,
                                            )
                                            ? Duration.zero
                                            : const Duration(milliseconds: 200),
                                        curve: Curves.ease,
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:
                                              states.contains(
                                                WidgetState.hovered,
                                              )
                                              ? DrawerColors.closeHoverFill
                                              : Colors.transparent,
                                          border:
                                              states.contains(
                                                WidgetState.focused,
                                              )
                                              ? Border.all(
                                                  color:
                                                      IslandTokens.light.focus,
                                                  width: 2,
                                                )
                                              : null,
                                        ),
                                        child: AnimatedDefaultTextStyle(
                                          duration:
                                              MediaQuery.disableAnimationsOf(
                                                context,
                                              )
                                              ? Duration.zero
                                              : const Duration(
                                                  milliseconds: 200,
                                                ),
                                          curve: Curves.ease,
                                          style: DefaultTextStyle.of(context)
                                              .style
                                              .copyWith(
                                                fontSize: 22,
                                                height: 1,
                                                color:
                                                    states.contains(
                                                      WidgetState.hovered,
                                                    )
                                                    ? DrawerColors.closeHover
                                                    : DrawerColors.close,
                                              ),
                                          child: const ExcludeSemantics(
                                            child: Text('×'),
                                          ),
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: ContentScope(
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                                color: IslandTokens.light.muted,
                              ),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: widget.child,
                              ),
                            ),
                          ),
                        ),
                        if (widget.footer != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: widget.footer,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return AnimatedBuilder(
        animation: motion,
        builder: (context, child) {
          final t = panelMotion.value;
          return Offstage(
            offstage: !widget.open && motion.isDismissed,
            child: IgnorePointer(
              ignoring: !widget.open,
              child: ExcludeFocus(
                excluding: !widget.open,
                child: ExcludeSemantics(
                  excluding: !widget.open,
                  child: IslandCursor(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            excludeFromSemantics: true,
                            behavior: HitTestBehavior.opaque,
                            onTap: widget.maskClosable ? widget.onClose : null,
                            child: ColoredBox(
                              color: DrawerColors.mask.withValues(
                                alpha: .18 * maskMotion.value,
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment(direction.dx, direction.dy),
                          child: FractionalTranslation(
                            translation: direction * (1 - t),
                            child: child,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: panel,
      );
    },
  );
}
