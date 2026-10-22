import '../internal/light_surface_scope.dart';
import '../foundation/theme.dart';

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../internal/content_scope.dart';
import '../internal/action_surface.dart';
import '../internal/organic_bubble.dart';
import 'actions.dart';
import 'cursor.dart';

enum IslandModalVariant { game, normal }

/// Presentation and explicit slots. The parent decides whether Escape commits.
class IslandModal extends StatelessWidget {
  const IslandModal({
    super.key,
    required this.child,
    this.title,
    this.semanticLabel,
    this.actions = const [],
    this.variant = IslandModalVariant.game,
    this.width = 520,
    this.onClose,
  }) : assert(width > 0 && width < double.infinity);
  final Widget child;
  final Widget? title;
  final String? semanticLabel;
  final List<Widget> actions;
  final IslandModalVariant variant;
  final double width;

  /// Escape intent; the reference has no visible close button.
  final VoidCallback? onClose;
  @override
  Widget build(BuildContext context) {
    final game = variant == IslandModalVariant.game;
    final content = LightSurfaceScope(
      child: Container(
        width: width,
        padding: game
            ? const EdgeInsets.fromLTRB(48, 48, 48, 32)
            : const EdgeInsets.fromLTRB(35, 40, 35, 25),
        color: const Color(0xfff7f3df),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ContentScope(
                  textStyle: const TextStyle(
                    fontSize: 28,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff725d42),
                  ),
                  child: Semantics(
                    container: true,
                    header: true,
                    child: title!,
                  ),
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: ContentScope(
                  textStyle: TextStyle(
                    color: IslandTokens.light.muted,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.6,
                  ),
                  child: child,
                ),
              ),
            ),
            if (actions.isNotEmpty)
              Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: actions,
              ),
          ],
        ),
      ),
    );
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              onClose?.call();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          skipTraversal: true,
          child: Dialog(
            semanticsRole: ui.SemanticsRole.none,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 32,
            ),
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              scopesRoute: true,
              namesRoute: semanticLabel != null,
              role: ui.SemanticsRole.dialog,
              label: semanticLabel,
              child: IslandCursor(
                child: game
                    ? ClipPath(
                        clipper: const OrganicBubbleClip(),
                        child: content,
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              offset: Offset(0, 18),
                              blurRadius: 50,
                              spreadRadius: -12,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: content,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<T?> showIslandModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Widget? title,
  String? semanticLabel,
  List<Widget> Function(BuildContext)? actions,
  IslandModalVariant variant = IslandModalVariant.game,
  bool dismissible = true,
  Color barrierColor = const Color(0x59000000),
  double width = 520,
}) {
  final navigator = Navigator.of(context, rootNavigator: true);
  final themes = InheritedTheme.capture(from: context, to: navigator.context);
  final reduced = MediaQuery.disableAnimationsOf(context);
  late final _IslandModalRoute<T> route;
  void close() {
    if (!route.isActive) return;
    if (route.isCurrent) {
      navigator.pop();
    } else {
      navigator.removeRoute(route);
    }
  }

  route = _IslandModalRoute<T>(
    dismissible: dismissible,
    color: barrierColor,
    reduced: reduced,
    page: (ctx) => themes.wrap(
      _ModalFocusEntry(
        child: IslandModal(
          title: title,
          semanticLabel: semanticLabel,
          width: width,
          variant: variant,
          onClose: close,
          actions:
              actions?.call(ctx) ??
              [
                IslandButton(
                  variant: IslandButtonVariant.primary,
                  onPressed: close,
                  child: const Text('取消'),
                ),
                IslandButton(
                  variant: IslandButtonVariant.primary,
                  onPressed: close,
                  child: const Text('确定'),
                ),
              ],
          child: builder(ctx),
        ),
      ),
    ),
  );
  return navigator.push(route);
}

class _IslandModalRoute<T> extends RawDialogRoute<T> {
  _IslandModalRoute({
    required WidgetBuilder page,
    required bool dismissible,
    required Color color,
    required this.reduced,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             ClosedLoopTraversal(child: page(context)),
         barrierDismissible: dismissible,
         barrierColor: color,
         barrierLabel: '关闭',
         transitionDuration: const Duration(milliseconds: 300),
         traversalEdgeBehavior: TraversalEdgeBehavior.closedLoop,
       );
  final bool reduced;
  bool settling = false;
  @override
  Duration get transitionDuration =>
      reduced ? Duration.zero : super.transitionDuration;
  @override
  Widget buildModalBarrier() => IslandCursor(child: super.buildModalBarrier());

  @override
  Duration get reverseTransitionDuration => Duration.zero;
  @override
  Curve get barrierCurve => const Interval(0, 5 / 6, curve: Curves.ease);
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final reduce = reduced || MediaQuery.disableAnimationsOf(context);
    if (reduce && animation.value < 1 && !settling) {
      settling = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        settling = false;
        if (isActive &&
            context.mounted &&
            MediaQuery.disableAnimationsOf(context))
          controller?.value = 1;
      });
    }
    final progress = reduce
        ? const AlwaysStoppedAnimation<double>(1)
        : animation.drive(CurveTween(curve: Curves.ease));
    return ScaleTransition(
      scale: progress.drive(Tween(begin: .92, end: 1.0)),
      child: child,
    );
  }
}

class _ModalFocusEntry extends StatefulWidget {
  const _ModalFocusEntry({required this.child});
  final Widget child;
  @override
  State<_ModalFocusEntry> createState() => _ModalFocusEntryState();
}

class _ModalFocusEntryState extends State<_ModalFocusEntry> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).nextFocus();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
