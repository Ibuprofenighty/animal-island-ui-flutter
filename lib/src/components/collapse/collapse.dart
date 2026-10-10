import 'package:flutter/material.dart';

import '../../foundation/theme/components/collapse_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/interaction_boundary.dart';
import '../../internal/timing/motion_policy.dart';
import 'collapse_item.dart';

export 'collapse_item.dart';

/// Cards with stable identity and controlled or initial-only expansion.
/// Empty or duplicate IDs, unknown expanded IDs and multiple accordion values
/// throw ArgumentError in every build mode. Controlled proposals never commit
/// locally; hidden content retains its state but cannot receive focus or input.
class AnimalCollapse extends StatefulWidget {
  /// Immutable snapshot of the cards in display order.
  final List<AnimalCollapseItem> items;

  /// Whether at most one card may be expanded.
  final bool accordion;

  /// Whether all headers reject activation.
  final bool disabled;

  /// Controlled expanded IDs; null selects uncontrolled ownership.
  final Set<String>? activeIds;

  /// Uncontrolled initial IDs; cannot be supplied with activeIds.
  /// Every construction requires existing IDs. Remove deleted defaults when
  /// updating items; valid default changes do not reset mounted expansion.
  final Set<String>? defaultActiveIds;

  /// Receives one immutable expansion proposal per activation.
  final ValueChanged<Set<String>>? onChanged;

  /// Instance overrides before component theme and tokens.
  final AnimalCollapseStyle? style;

  /// Creates cards with unique nonempty IDs and valid expansion input.
  AnimalCollapse({
    super.key,
    required List<AnimalCollapseItem> items,
    this.accordion = false,
    this.disabled = false,
    Set<String>? activeIds,
    Set<String>? defaultActiveIds,
    this.onChanged,
    this.style,
  }) : items = List.unmodifiable(items),
       activeIds = activeIds == null ? null : Set.unmodifiable(activeIds),
       defaultActiveIds = defaultActiveIds == null
           ? null
           : Set.unmodifiable(defaultActiveIds) {
    final ids = <String>{};
    for (final item in this.items) {
      if (item.id.isEmpty || !ids.add(item.id)) {
        throw ArgumentError.value(
          item.id,
          'items',
          'IDs must be nonempty and unique',
        );
      }
    }
    if (activeIds != null && defaultActiveIds != null) {
      throw ArgumentError(
        'activeIds and defaultActiveIds have different owners',
      );
    }
    final expanded = activeIds ?? defaultActiveIds ?? const <String>{};
    if (!ids.containsAll(expanded) || accordion && expanded.length > 1) {
      throw ArgumentError.value(
        expanded,
        activeIds == null ? 'defaultActiveIds' : 'activeIds',
        'unknown ID or multiple accordion values',
      );
    }
  }

  /// Creates a single question and answer, initially closed unless requested.
  factory AnimalCollapse.single({
    Key? key,
    required Widget question,
    required Widget answer,
    bool defaultExpanded = false,
    bool disabled = false,
    String id = 'single',
    ValueChanged<bool>? onChanged,
    AnimalCollapseStyle? style,
  }) => AnimalCollapse(
    key: key,
    items: [
      AnimalCollapseItem(
        id: id,
        title: question,
        content: answer,
        disabled: disabled,
      ),
    ],
    disabled: disabled,
    defaultActiveIds: defaultExpanded ? {id} : const {},
    style: style,
    onChanged: onChanged == null ? null : (ids) => onChanged(ids.contains(id)),
  );

  @override
  State<AnimalCollapse> createState() => _AnimalCollapseState();
}

class _AnimalCollapseState extends State<AnimalCollapse> {
  Set<String>? _activeIds;
  Set<String> get _expanded => widget.activeIds ?? _activeIds!;

  @override
  void initState() {
    super.initState();
    _activeIds = widget.activeIds == null
        ? widget.defaultActiveIds ?? const {}
        : null;
  }

  @override
  void didUpdateWidget(AnimalCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.activeIds == null) != (widget.activeIds == null)) {
      throw StateError('Collapse ownership cannot change while mounted');
    }
    if (_activeIds != null) {
      final ids = widget.items.map((item) => item.id).toSet();
      _activeIds = Set.unmodifiable(_activeIds!.intersection(ids));
      if (widget.accordion && _activeIds!.length > 1) {
        throw ArgumentError('accordion cannot contain multiple expanded IDs');
      }
    }
  }

  void _toggle(AnimalCollapseItem item) {
    if (widget.disabled || item.disabled) return;
    final next = widget.accordion ? <String>{} : Set<String>.of(_expanded);
    if (_expanded.contains(item.id)) {
      next.remove(item.id);
    } else {
      next.add(item.id);
    }
    final proposal = Set<String>.unmodifiable(next);
    if (_activeIds != null) setState(() => _activeIds = proposal);
    widget.onChanged?.call(proposal);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final style = _resolveCollapseStyle(theme, widget.style);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in widget.items)
          Padding(
            key: ValueKey(item.id),
            padding: EdgeInsets.only(
              bottom: item == widget.items.last ? 0 : style.gap!,
            ),
            child: _CollapseCard(
              item: item,
              expanded: _expanded.contains(item.id),
              disabled: widget.disabled || item.disabled,
              style: style,
              onToggle: () => _toggle(item),
            ),
          ),
      ],
    );
  }
}

class _CollapseCard extends StatefulWidget {
  const _CollapseCard({
    required this.item,
    required this.expanded,
    required this.disabled,
    required this.style,
    required this.onToggle,
  });
  final AnimalCollapseItem item;
  final bool expanded;
  final bool disabled;
  final AnimalCollapseStyle style;
  final VoidCallback onToggle;
  @override
  State<_CollapseCard> createState() => _CollapseCardState();
}

class _CollapseCardState extends State<_CollapseCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    final states = <WidgetState>{
      if (widget.disabled) WidgetState.disabled,
      if (_hovered) WidgetState.hovered,
    };
    final duration = AnimalMotionPolicy.shouldAnimate(context)
        ? s.duration!
        : Duration.zero;
    return Container(
      decoration: BoxDecoration(
        color: s.backgroundColor,
        borderRadius: s.borderRadius,
        border: Border.all(color: s.borderColor!, width: s.borderWidth!),
        boxShadow: widget.disabled ? null : [s.shadow!],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InteractiveRegion(
            disabled: widget.disabled,
            expanded: widget.expanded,
            enableHaptics: false,
            onPressed: widget.onToggle,
            borderRadius: s.borderRadius,
            child: InteractionBoundary(
              onHoverChanged: (value) => setState(() => _hovered = value),
              child: Container(
                padding: s.headerPadding,
                color: s.headerBackgroundColor!.resolve(states),
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: s.textStyle!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: s.textColor!.resolve(states),
                        ),
                        child: widget.item.title,
                      ),
                    ),
                    if (widget.item.extra != null) ...[
                      SizedBox(width: s.iconGap),
                      widget.item.extra!,
                    ],
                    SizedBox(width: s.iconGap),
                    AnimatedRotation(
                      turns: widget.expanded ? 0.5 : 0,
                      duration: duration,
                      curve: s.curve!,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: s.iconSize,
                        color: s.iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: duration,
            curve: widget.expanded ? s.curve! : s.curve!.flipped,
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: widget.expanded ? 1 : 0,
                child: TickerMode(
                  enabled: widget.expanded,
                  child: ExcludeSemantics(
                    excluding: !widget.expanded,
                    child: ExcludeFocus(
                      excluding: !widget.expanded,
                      child: IgnorePointer(
                        ignoring: !widget.expanded,
                        child: Container(
                          width: double.infinity,
                          padding: s.contentPadding,
                          decoration: BoxDecoration(
                            color: s.contentBackgroundColor,
                            border: Border(
                              top: BorderSide(
                                color: s.borderColor!.withValues(alpha: .5),
                                width: 1,
                              ),
                            ),
                          ),
                          child: DefaultTextStyle(
                            style: s.textStyle!.copyWith(
                              color: s.contentTextColor,
                            ),
                            child: widget.item.content,
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
    );
  }
}

AnimalCollapseStyle _resolveCollapseStyle(
  AnimalIslandTheme theme,
  AnimalCollapseStyle? instance,
) {
  final component = theme.components.collapse;
  final merged = (instance ?? AnimalCollapseStyle()).merge(component);
  return merged
      .merge(
        AnimalCollapseStyle(
          backgroundColor: theme.colors.bgContent,
          borderColor: theme.colors.border,
          borderWidth: 1.5,
          borderRadius: theme.radii.cardBorder,
          shadow: theme.shadows.softElevation,
          headerPadding: EdgeInsets.symmetric(
            horizontal: theme.spacing.lg,
            vertical: theme.spacing.md,
          ),
          contentPadding: EdgeInsets.all(theme.spacing.lg),
          gap: theme.spacing.sm,
          iconGap: theme.spacing.sm,
          iconSize: 20,
          iconColor: theme.colors.textSecondary,
          textStyle: theme.typography.body,
          contentBackgroundColor: theme.colors.surfaceAlt.withValues(alpha: .4),
          contentTextColor: theme.colors.text,
          duration: theme.motion.normal,
          curve: theme.motion.spring,
        ),
      )
      .copyWith(
        headerBackgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              instance?.headerBackgroundColor?.resolve(states) ??
              component?.headerBackgroundColor?.resolve(states) ??
              (states.contains(WidgetState.disabled)
                  ? theme.colors.surfaceAlt.withValues(alpha: .5)
                  : states.contains(WidgetState.hovered)
                  ? theme.colors.surfaceAlt
                  : theme.colors.bgContent),
        ),
        textColor: WidgetStateProperty.resolveWith(
          (states) =>
              instance?.textColor?.resolve(states) ??
              component?.textColor?.resolve(states) ??
              (states.contains(WidgetState.disabled)
                  ? theme.colors.textSecondary
                  : theme.colors.text),
        ),
      );
}
