import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../interaction/focus_return.dart';

/// Builds the page of one Modal, Drawer or image preview presentation.
typedef AnimalRoutePageBuilder<T> = Widget Function(
  BuildContext context,
  AnimalRouteSession<T> session,
);

/// One presentation of a Modal, Drawer or image preview route and its single
/// result.
///
/// The session is the shared result and focus mechanism of every route:
///
/// * [close] completes the route with a typed result; [dismiss] completes it
///   without one. Escape, system back and the barrier dismiss through the
///   route's pop disposition, which follows the same rules.
/// * [confirm] runs one pending confirmation gate. While it is pending every
///   other close, dismissal and confirmation request is ignored.
/// * Closing removes exactly this route from the Navigator that holds it, even
///   when other routes were pushed above it.
/// * The result is delivered exactly once, also when the Navigator disposes
///   the route without popping it, and focus then returns to the control that
///   was focused when the route opened.
final class AnimalRouteSession<T> {
  AnimalRouteSession._(this._focusReturn);

  final AnimalFocusReturn _focusReturn;
  final Completer<T?> _result = Completer<T?>();
  late final _AnimalRoute<T> _route;
  bool _busy = false;
  bool _closing = false;

  /// Whether a confirmation gate is pending.
  bool get isBusy => _busy;

  /// Whether the route has started closing or has delivered its result.
  bool get isClosed => _closing || _result.isCompleted;

  /// Closes the route with [result] unless it is busy or already closed.
  void close(T result) => _closeIfIdle(result);

  /// Closes the route without a result unless it is busy or already closed.
  void dismiss() => _closeIfIdle(null);

  /// Runs [gate] as the only pending confirmation.
  ///
  /// The route closes with [result] only when [gate] yields true; false keeps
  /// it open. A thrown error keeps it open and is returned so the caller can
  /// present it; the confirmation may then be retried. Returns null without
  /// calling [gate] while another confirmation is pending or after closing.
  Future<Object?> confirm(FutureOr<bool> Function() gate, T result) async {
    if (_busy || isClosed) return null;
    _busy = true;
    try {
      final bool accepted = await gate();
      if (accepted) _pop(result);
      return null;
    } catch (error) {
      return error;
    } finally {
      _busy = false;
    }
  }

  void _closeIfIdle(T? result) {
    if (_busy || isClosed) return;
    _pop(result);
  }

  void _pop(T? result) {
    if (isClosed) return;
    final NavigatorState? navigator = _route.navigator;
    if (navigator == null || !_route.isActive) return;
    _closing = true;
    if (_route.isCurrent) {
      navigator.pop<T>(result);
    } else {
      navigator.removeRoute<T>(_route, result);
    }
  }

  void _deliver(T? result) {
    if (_result.isCompleted) return;
    _closing = true;
    _result.complete(result);
    _focusReturn.restore();
  }
}

/// Pushes one Modal, Drawer or image preview route on the nearest Navigator
/// of [context].
///
/// There is no root-navigator fallback: a route presented from a nested
/// Navigator belongs to, and closes on, that Navigator. The route is named
/// once by [routeLabel], and the dismiss barrier follows the active
/// application locale for the lifetime of the route. When [maskClosable] is
/// false a barrier tap is ignored; Escape and system back still dismiss
/// through the session rules.
Future<T?> presentAnimalRoute<T>({
  required BuildContext context,
  required AnimalRoutePageBuilder<T> builder,
  required RouteTransitionsBuilder transitionBuilder,
  required Duration transitionDuration,
  required Color barrierColor,
  required bool maskClosable,
  required String Function(BuildContext context) routeLabel,
}) {
  final NavigatorState navigator = Navigator.of(context);
  final AnimalLocalizations localizations = AnimalLocalizations.of(context)!;
  final AnimalRouteSession<T> session = AnimalRouteSession<T>._(
    AnimalFocusReturn.capture(),
  );
  session._route = _AnimalRoute<T>(
    session: session,
    builder: builder,
    transitionBuilder: transitionBuilder,
    transitionDuration: transitionDuration,
    barrierColor: barrierColor,
    maskClosable: maskClosable,
    initialBarrierLabel: localizations.dismiss,
    routeLabel: routeLabel,
  );
  unawaited(navigator.push<T>(session._route));
  return session._result.future;
}

class _AnimalRoute<T> extends PopupRoute<T> {
  _AnimalRoute({
    required this.session,
    required this.builder,
    required this.transitionBuilder,
    required this.transitionDuration,
    required this.barrierColor,
    required this.maskClosable,
    required this.initialBarrierLabel,
    required this.routeLabel,
  }) : super(
         // Tab and arrow traversal wrap inside the route, so focus never
         // reaches the routes below it while it is open.
         traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
         directionalTraversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
       );

  final AnimalRouteSession<T> session;
  final AnimalRoutePageBuilder<T> builder;
  final RouteTransitionsBuilder transitionBuilder;
  final bool maskClosable;
  final String initialBarrierLabel;
  final String Function(BuildContext context) routeLabel;

  @override
  final Duration transitionDuration;

  @override
  final Color barrierColor;

  // Escape is enabled through the route's dismiss action and, like system
  // back and the barrier, passes through [popDisposition]. The barrier itself
  // honours [maskClosable] in [buildModalBarrier].
  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel {
    final NavigatorState? currentNavigator = navigator;
    if (currentNavigator == null) return initialBarrierLabel;
    return AnimalLocalizations.of(currentNavigator.context)?.dismiss ??
        initialBarrierLabel;
  }

  @override
  RoutePopDisposition get popDisposition =>
      session.isBusy ? RoutePopDisposition.doNotPop : super.popDisposition;

  @override
  Widget buildModalBarrier() {
    final Color color = barrierColor;
    if (color.a != 0 && !offstage) {
      final Animation<Color?> animated = animation!.drive(
        ColorTween(
          begin: color.withValues(alpha: 0),
          end: color,
        ).chain(CurveTween(curve: barrierCurve)),
      );
      return AnimatedModalBarrier(
        color: animated,
        dismissible: maskClosable,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
      );
    }
    return ModalBarrier(
      dismissible: maskClosable,
      semanticsLabel: barrierLabel,
      barrierSemanticsDismissible: semanticsDismissible,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: routeLabel(context),
      child: Builder(builder: (context) => builder(context, session)),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) => transitionBuilder(context, animation, secondaryAnimation, child);

  @override
  void didComplete(T? result) {
    super.didComplete(result);
    session._deliver(result);
  }

  @override
  void dispose() {
    session._deliver(null);
    super.dispose();
  }
}
