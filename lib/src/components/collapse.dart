import 'package:flutter/material.dart';

import '../foundation/icon.dart';
import '../foundation/theme.dart';
import '../internal/action_surface.dart';
import '../internal/content_scope.dart';
import '../internal/focus_outline.dart';

/// Disclosure owns visibility; opaque question/answer slots retain their state
/// and explicit styling. Controlled requests never commit without host input.
class IslandCollapse extends StatefulWidget {
  const IslandCollapse({
    super.key,
    required this.question,
    required this.answer,
    required bool expanded,
    required this.onExpandedChanged,
    this.disabled = false,
    this.focusNode,
  }) : expanded = expanded,
       initialExpanded = false;

  const IslandCollapse.uncontrolled({
    super.key,
    required this.question,
    required this.answer,
    this.initialExpanded = false,
    this.onExpandedChanged,
    this.disabled = false,
    this.focusNode,
  }) : expanded = null;

  final Widget question, answer;
  final bool? expanded;
  final bool initialExpanded, disabled;
  final ValueChanged<bool>? onExpandedChanged;

  /// Borrowed from the caller; never disposed by this component.
  final FocusNode? focusNode;

  @override
  State<IslandCollapse> createState() => _IslandCollapseState();
}

class _IslandCollapseState extends State<IslandCollapse>
    with TickerProviderStateMixin {
  late bool inner = widget.initialExpanded;
  bool get expanded => widget.expanded ?? inner;
  late final AnimationController motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    value: expanded ? 1 : 0,
  );
  late final AnimationController detailMotion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: expanded ? 1 : 0,
  );
  double? motionTarget;
  final answerFocus = FocusNode(skipTraversal: true);
  FocusNode? ownedHeader;
  FocusNode get header => widget.focusNode ?? (ownedHeader ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    sync();
  }

  void sync() {
    if (!expanded && answerFocus.hasFocus) header.requestFocus();
    final target = expanded ? 1.0 : 0.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.value = target;
      detailMotion.value = target;
    } else if (motionTarget != target) {
      // Start each transition from its rendered value, including reversals.
      // animateTo shortens a reversal by the remaining normalized distance.
      motion.animateTo(target, curve: const Cubic(.4, 0, .2, 1));
      detailMotion.animateTo(target, curve: const Cubic(.4, 0, .2, 1));
    }
    motionTarget = target;
  }

  @override
  void didUpdateWidget(IslandCollapse old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      ownedHeader?.dispose();
      ownedHeader = null;
    }
    sync();
  }

  void toggle() {
    if (widget.disabled) return;
    final next = !expanded;
    if (widget.expanded == null) {
      setState(() => inner = next);
      sync();
    }
    widget.onExpandedChanged?.call(next);
  }

  @override
  void dispose() {
    detailMotion.dispose();
    motion.dispose();
    answerFocus.dispose();
    ownedHeader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = IslandTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: widget.disabled ? .6 : 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.paper,
            border: Border.all(color: tokens.outline, width: 2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ActionSurface(
                    expanded: expanded,
                    focusNode: header,
                    onActivate: widget.disabled ? null : toggle,
                    builder: (context, states) => DecoratedBox(
                      decoration: FocusOutline(
                        const RoundedRectangleBorder(),
                        states.contains(WidgetState.focused)
                            ? tokens.focus
                            : Colors.transparent,
                        width: 1,
                        offset: -1,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            ExcludeSemantics(
                              child: AnimatedBuilder(
                                animation: detailMotion,
                                builder: (_, child) => Transform.rotate(
                                  angle: detailMotion.value * 3.141592653589793,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color.lerp(
                                        tokens.leaf,
                                        const Color(0xff50b9ab),
                                        detailMotion.value,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x4d19c8b9),
                                          offset: Offset(0, 2),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      expanded ? '−' : '+',
                                      style: TextStyle(
                                        fontSize: 18,
                                        height: 1,
                                        fontWeight: FontWeight.w700,
                                        color: tokens.onLeaf,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ContentScope(
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: tokens.ink,
                                ),
                                child: widget.question,
                              ),
                            ),
                            const SizedBox(width: 12),
                            ExcludeSemantics(
                              child: AnimatedBuilder(
                                animation: detailMotion,
                                builder: (_, child) => Transform.rotate(
                                  angle: detailMotion.value * .7853981633974483,
                                  child: child,
                                ),
                                child: const SizedBox(
                                  height: 25,
                                  child: Center(
                                    child: IslandIcon(
                                      IslandGlyph.fish,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: detailMotion,
                    builder: (context, _) => ClipRect(
                      child: ConstrainedBox(
                        // CSS grid items retain their padding as a minimum
                        // track size even while the fractional row collapses.
                        constraints: BoxConstraints(
                          minHeight: 24 * detailMotion.value,
                        ),
                        child: SizeTransition(
                          sizeFactor: motion,
                          alignment: Alignment.topCenter,
                          child: ExcludeSemantics(
                            excluding: !expanded,
                            child: ExcludeFocus(
                              excluding: !expanded,
                              child: IgnorePointer(
                                ignoring: !expanded,
                                child: Focus(
                                  focusNode: answerFocus,
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      24,
                                      0,
                                      24,
                                      24 * detailMotion.value,
                                    ),
                                    child: ContentScope(
                                      textStyle: TextStyle(
                                        fontSize: 14,
                                        height: 1.7,
                                        color: tokens.muted,
                                      ),
                                      child: Align(
                                        alignment:
                                            AlignmentDirectional.centerStart,
                                        child: widget.answer,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
