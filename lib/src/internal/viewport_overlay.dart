import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Viewport-wide presentation has Overlay-owned semantics, independent of a
/// zero-size/offscreen trigger. Anchored panels intentionally use OverlayPortal.
/// Captures framework themes, locale, direction and media. Resolve application
/// provider values in the host before passing opaque content into this surface.
class ViewportOverlay extends StatefulWidget {
  const ViewportOverlay({
    super.key,
    required this.visible,
    required this.builder,
    this.decorative = false,
    this.blocksBackgroundSemantics = false,
    this.followsRoute = false,
  });
  final bool visible;

  /// Page-level surface (Drawer, BackTop): the entry stays directly above the
  /// route that presents it, so a route pushed later (a Modal) covers it.
  /// Other surfaces (Cursor, Notification, Loading) stay above every route.
  final bool followsRoute;

  /// A library route reports a Navigator change. The Navigator moves every
  /// non-route entry above all routes on each update; route-following
  /// surfaces return to their place before the next frame.
  static void routesChanged() => _restackSoon(force: true);

  /// Pure paint: exclude the entire entry, including framework wrapper semantics.
  final bool decorative;

  /// Must surround captured locale semantics so blocking reaches older entries.
  /// The surface owner decides when its background is unavailable.
  final bool blocksBackgroundSemantics;
  final WidgetBuilder builder;
  @override
  State<ViewportOverlay> createState() => _ViewportOverlayState();
}

/// Route-following surfaces with an inserted entry, in insertion order.
final _followers = <_ViewportOverlayState>[];
bool _restackQueued = false;

/// Restacks before the next frame when called between frames, otherwise
/// after the current one. [force] skips the order check: between frames the
/// render tree does not show a Navigator change yet.
void _restackSoon({required bool force}) {
  if (_followers.isEmpty) return;
  if (force) _restackForced = true;
  if (_restackQueued) return;
  _restackQueued = true;
  void run() {
    _restackQueued = false;
    final forced = _restackForced;
    _restackForced = false;
    _restack(force: forced);
  }

  final scheduler = SchedulerBinding.instance;
  if (scheduler.schedulerPhase == SchedulerPhase.idle) {
    scheduleMicrotask(() {
      if (scheduler.schedulerPhase == SchedulerPhase.idle) {
        run();
      } else {
        scheduler.addPostFrameCallback((_) => run());
      }
    });
  } else {
    scheduler.addPostFrameCallback((_) => run());
  }
  scheduler.ensureVisualUpdate();
}

bool _restackForced = false;

/// The child of [theater] that contains [context]'s render object.
RenderObject? _theaterChild(RenderObject theater, BuildContext? context) {
  if (context == null || !context.mounted) return null;
  var node = context.findRenderObject();
  while (node != null && node.parent != theater) {
    node = node.parent;
  }
  return node;
}

/// Whether every follower is painted directly above its presenting route (or
/// the previous follower of that route). Null while the render tree cannot
/// tell.
bool? _ordered() {
  final top = <ModalRoute<dynamic>, RenderObject>{};
  for (final follower in _followers) {
    final route = follower.presenter();
    if (route == null) continue;
    final theater = follower.owner?.context.findRenderObject();
    if (theater == null) return null;
    final self = _theaterChild(theater, follower.entryContext);
    final below = top[route] ?? _theaterChild(theater, route.subtreeContext);
    final data = self?.parentData;
    if (below == null || data is! ContainerParentDataMixin<RenderBox>) {
      return null;
    }
    if (data.previousSibling != below) return false;
    top[route] = self!;
  }
  return true;
}

/// Places every follower directly above its presenting route, keeping the
/// insertion order of followers that share a route. Entries keep their state.
void _restack({required bool force}) {
  if (!force && _ordered() != false) return;
  final top = <ModalRoute<dynamic>, OverlayEntry>{};
  for (final follower in _followers) {
    final route = follower.presenter();
    if (route == null) continue;
    final entry = follower.entry!;
    entry.remove();
    follower.owner!.insert(
      entry,
      above: top[route] ?? route.overlayEntries.last,
    );
    top[route] = entry;
  }
}

class _ViewportOverlayState extends State<ViewportOverlay> {
  OverlayEntry? entry;
  OverlayState? owner;
  BuildContext? entryContext;
  bool scheduled = false;
  void schedule() {
    if (scheduled) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (!mounted) return;
      final nextOwner = Overlay.of(context, rootOverlay: true);
      if (!widget.visible || nextOwner != owner) remove();
      owner = nextOwner;
      if (!widget.visible) return;
      if (entry == null) {
        entry = OverlayEntry(
          builder: (entryContext) {
            // The Overlay rebuilds its entries after every reorder.
            if (widget.followsRoute) {
              this.entryContext = entryContext;
              _restackSoon(force: false);
            }
            final media = MediaQuery.of(context);
            return BlockSemantics(
              blocking: widget.blocksBackgroundSemantics,
              child: ExcludeSemantics(
                excluding: widget.decorative,
                child: IgnorePointer(
                  ignoring: widget.decorative,
                  child: Focus(
                    includeSemantics: false,
                    // Visual placement belongs to Overlay; keyboard traversal remains
                    // in the presenting route's scope. This node is borrowed.
                    parentNode: FocusScope.of(context),
                    canRequestFocus: false,
                    skipTraversal: true,
                    child: InheritedTheme.captureAll(
                      context,
                      Localizations.override(
                        context: context,
                        child: Directionality(
                          textDirection: Directionality.of(context),
                          child: LayoutBuilder(
                            builder: (overlayContext, constraints) =>
                                MediaQuery(
                                  data: media.copyWith(
                                    size: constraints.biggest,
                                  ),
                                  child: Material(
                                    type: MaterialType.transparency,
                                    animationDuration: Duration.zero,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Builder(builder: widget.builder),
                                      ],
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
        owner!.insert(entry!);
        if (widget.followsRoute) {
          _followers.add(this);
          _restack(force: true);
        }
      } else {
        entry!.markNeedsBuild();
      }
    });
  }

  /// The active route in [owner] that presents this surface.
  ModalRoute<dynamic>? presenter() {
    final owner = this.owner;
    if (!mounted || entry == null || owner == null || !owner.mounted) {
      return null;
    }
    BuildContext at = context;
    while (true) {
      final route = ModalRoute.of(at);
      final navigator = route?.navigator;
      if (route == null || navigator == null || !route.isActive) return null;
      if (navigator.overlay == owner) {
        final entries = route.overlayEntries;
        return entries.isEmpty || !entries.last.mounted ? null : route;
      }
      at = navigator.context;
    }
  }

  void remove() {
    _followers.remove(this);
    entry?.remove();
    entry?.dispose();
    entry = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    schedule();
  }

  @override
  void didUpdateWidget(ViewportOverlay old) {
    super.didUpdateWidget(old);
    schedule();
  }

  @override
  void dispose() {
    remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Register dependencies so frozen theme captures refresh while open.
    Theme.of(context);
    IconTheme.of(context);
    DefaultTextStyle.of(context);
    return const SizedBox.shrink();
  }
}
