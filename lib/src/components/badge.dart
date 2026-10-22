import '../internal/content_scope.dart';
import 'tooltip.dart';
import '../internal/surface_motion.dart';

import 'package:flutter/material.dart';

import '../foundation/colorway.dart';

enum IslandBadgeSize { small, medium }

/// Indicator and wrapped child are distinct slots. Neither is rewritten.
class IslandBadge extends StatelessWidget {
  const IslandBadge({
    super.key,
    this.count,
    this.text,
    this.indicator,
    this.child,
    this.overflowCount = 99,
    this.showZero = false,
    this.dot = false,
    this.size = IslandBadgeSize.medium,
    this.color = IslandColorway.red,
    this.semanticLabel,
  }) : assert(
         (count == null ? 0 : 1) +
                 (text == null ? 0 : 1) +
                 (indicator == null ? 0 : 1) <=
             1,
       );
  final num? count;
  final String? text;
  final Widget? indicator, child;
  final num overflowCount;
  final bool showZero, dot;
  final IslandBadgeSize size;
  final IslandColorway color;
  final String? semanticLabel;
  @override
  Widget build(BuildContext context) {
    final numeric = count ?? num.tryParse(text?.trim() ?? '');
    final raw = text ?? count?.toString();
    final display = numeric != null && numeric > overflowCount
        ? '$overflowCount+'
        : raw;
    final zero = display == '0';
    final point = dot && !zero;
    final empty = indicator == null && (raw == null || raw.trim().isEmpty);
    final hidden = !point && (empty || zero && !showZero);
    Widget wrap(Widget? badge) {
      if (child == null) return badge ?? const SizedBox.shrink();
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child!,
          if (badge != null)
            Positioned(
              top: 0,
              right: 0,
              child: FractionalTranslation(
                translation: const Offset(.5, -.5),
                child: badge,
              ),
            ),
        ],
      );
    }

    if (hidden) return wrap(null);
    final circle =
        indicator == null &&
        display != null &&
        display.trim().isNotEmpty &&
        display.trim().length <= 2 &&
        !(display.trim().length == 2 &&
            RegExp(r'[\u2E80-\u9FFF\uF900-\uFAFF\uFF00-\uFFEF]')
                .hasMatch(display));
    final height = point
        ? 10.0
        : size == IslandBadgeSize.small
        ? 16.0
        : 20.0;
    final foreground = color.onAccent;
    Widget badge = Container(
      height: height,
      width: point || circle ? height : null,
      constraints: BoxConstraints(minWidth: height),
      padding: point || circle
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal: size == IslandBadgeSize.small ? 4 : 6,
            ),
      decoration: BoxDecoration(
        color: color.accent,
        border: Border.all(
          color: point
              ? color.onAccent
              : child == null
              ? Colors.transparent
              : const Color(0xfff8f8f0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: child == null
            ? null
            : const [
                BoxShadow(
                  color: Color(0x0f3d3428),
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
      ),
      child: point
          ? null
          : Center(
              widthFactor: 1,
              child: ContentScope(
                textStyle: TextStyle(
                  fontSize: size == IslandBadgeSize.small ? 9 : 10,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                  letterSpacing: 0,
                ),
                child: indicator ?? Text(display!),
              ),
            ),
    );
    if (raw != null && !point)
      badge = IslandTooltip(message: raw, child: badge);
    badge = Semantics(
      label: semanticLabel ?? (point ? '有新消息' : raw),
      child: ExcludeSemantics(child: badge),
    );
    badge = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      child: badge,
      builder: (_, v, child) => SurfaceMotion(
        progress: v,
        pulse: true,
        alignment: Alignment.topRight,
        child: child!,
      ),
    );
    return wrap(badge);
  }
}
