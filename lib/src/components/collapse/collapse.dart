import 'package:flutter/material.dart';

import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import 'collapse_item.dart';

export 'collapse_item.dart';

/// Animal Island Accordion / Collapse component (C09).
///
/// Features:
/// - Defect F27 resolved: Stable item ID architecture with controlled `activeIds`
///   and `onChanged`, preventing state-scrambling during item reordering, filtering, or insertion.
/// - Accordion mode: Guarantees at most one item expanded at a time.
/// - Uncontrolled & controlled expansion states.
/// - Full keyboard accessibility (`Enter` / `Space`) and screen-reader semantics.
/// - Inactive content is completely isolated from keyboard focus and semantics tree.
class AnimalCollapse extends StatefulWidget {
  final List<AnimalCollapseItem> items;
  final bool accordion;
  final bool disabled;
  final Set<String>? activeIds;
  final Set<String>? defaultActiveIds;
  final ValueChanged<Set<String>>? onChanged;

  const AnimalCollapse({
    super.key,
    required this.items,
    this.accordion = false,
    this.disabled = false,
    this.activeIds,
    this.defaultActiveIds,
    this.onChanged,
  });

  /// Convenient constructor for a single question/answer collapse card.
  factory AnimalCollapse.single({
    Key? key,
    required Widget question,
    required Widget answer,
    bool defaultExpanded = false,
    bool disabled = false,
    String id = 'single',
    ValueChanged<bool>? onChanged,
  }) {
    return AnimalCollapse(
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
      defaultActiveIds: defaultExpanded ? {id} : const <String>{},
      onChanged: onChanged != null
          ? (ids) => onChanged(ids.contains(id))
          : null,
    );
  }

  @override
  State<AnimalCollapse> createState() => _AnimalCollapseState();
}

class _AnimalCollapseState extends State<AnimalCollapse> {
  late Set<String> _internalActiveIds;

  bool get _isControlled => widget.activeIds != null;

  Set<String> get _effectiveActiveIds => widget.activeIds ?? _internalActiveIds;

  @override
  void initState() {
    super.initState();
    _internalActiveIds = widget.defaultActiveIds != null
        ? Set<String>.from(widget.defaultActiveIds!)
        : <String>{};
  }

  String _resolveId(AnimalCollapseItem item, int index) {
    if (item.id.isNotEmpty) return item.id;
    return 'collapse_item_$index';
  }

  void _handleToggle(String id, bool itemDisabled) {
    if (widget.disabled || itemDisabled) return;

    final current = Set<String>.from(_effectiveActiveIds);
    final isExpanded = current.contains(id);
    final Set<String> next;

    if (widget.accordion) {
      next = isExpanded ? <String>{} : <String>{id};
    } else {
      if (isExpanded) {
        current.remove(id);
      } else {
        current.add(id);
      }
      next = current;
    }

    if (!_isControlled) {
      setState(() {
        _internalActiveIds = next;
      });
    }
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.items.length; i++) ...[
          if (i > 0) SizedBox(height: theme.spacing.sm),
          _CollapseCard(
            item: widget.items[i],
            id: _resolveId(widget.items[i], i),
            isExpanded: _effectiveActiveIds.contains(
              _resolveId(widget.items[i], i),
            ),
            parentDisabled: widget.disabled,
            theme: theme,
            onToggle: (id) => _handleToggle(id, widget.items[i].disabled),
          ),
        ],
      ],
    );
  }
}

class _CollapseCard extends StatefulWidget {
  final AnimalCollapseItem item;
  final String id;
  final bool isExpanded;
  final bool parentDisabled;
  final AnimalIslandTheme theme;
  final ValueChanged<String> onToggle;

  const _CollapseCard({
    required this.item,
    required this.id,
    required this.isExpanded,
    required this.parentDisabled,
    required this.theme,
    required this.onToggle,
  });

  @override
  State<_CollapseCard> createState() => _CollapseCardState();
}

class _CollapseCardState extends State<_CollapseCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _expandAnimation;
  bool _isHovered = false;
  bool _isFocused = false;

  bool get _effectiveDisabled => widget.parentDisabled || widget.item.disabled;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.theme.motion.normal,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.theme.motion.spring,
    );
    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _CollapseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.theme.motion != oldWidget.theme.motion) {
      _controller.duration = widget.theme.motion.normal;
      _expandAnimation.dispose();
      _expandAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.theme.motion.spring,
      );
    }
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandAnimation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final isExpanded = widget.isExpanded;
    final isDisabled = _effectiveDisabled;

    final headerBg = isDisabled
        ? theme.colors.surfaceAlt.withValues(alpha: 0.5)
        : (_isHovered ? theme.colors.surfaceAlt : theme.colors.bgContent);

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.bgContent,
        borderRadius: theme.radii.cardBorder,
        border: Border.all(
          color: _isFocused ? theme.colors.focusYellow : theme.colors.border,
          width: _isFocused ? 2.0 : 1.5,
        ),
        boxShadow: isDisabled ? null : [theme.shadows.softElevation],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InteractiveRegion(
            onPressed: isDisabled ? null : () => widget.onToggle(widget.id),
            enableHaptics: false,
            disabled: isDisabled,
            expanded: isExpanded,
            borderRadius: theme.radii.cardBorder,
            onFocusChanged: (focused) => setState(() => _isFocused = focused),
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: theme.spacing.lg,
                  vertical: theme.spacing.md,
                ),
                color: headerBg,
                child: Row(
                  children: [
                    Expanded(
                      child: DefaultTextStyle(
                        style: theme.typography.body.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDisabled
                              ? theme.colors.textSecondary
                              : theme.colors.text,
                        ),
                        child: widget.item.title,
                      ),
                    ),
                    if (widget.item.extra != null) ...[
                      SizedBox(width: theme.spacing.sm),
                      widget.item.extra!,
                    ],
                    SizedBox(width: theme.spacing.sm),
                    RotationTransition(
                      turns: Tween<double>(
                        begin: 0.0,
                        end: 0.5,
                      ).animate(_expandAnimation),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: isDisabled
                            ? theme.colors.textSecondary.withValues(alpha: 0.5)
                            : theme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              alignment: Alignment.topCenter,
              child: TickerMode(
                enabled: isExpanded,
                child: ExcludeSemantics(
                  excluding: !isExpanded,
                  child: FocusScope(
                    canRequestFocus: isExpanded,
                    child: Container(
                      padding: EdgeInsets.all(theme.spacing.lg),
                      decoration: BoxDecoration(
                        color: theme.colors.surfaceAlt.withValues(alpha: 0.4),
                        border: Border(
                          top: BorderSide(
                            color: theme.colors.border.withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: DefaultTextStyle(
                        style: theme.typography.body.copyWith(
                          color: isDisabled
                              ? theme.colors.textSecondary
                              : theme.colors.text,
                        ),
                        child: widget.item.content,
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
