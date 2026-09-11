import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';

/// Item specification for [AnimalCollapse].
class AnimalCollapseItem {
  /// Question or title widget.
  final Widget title;

  /// Answer or content widget.
  final Widget content;

  /// Whether initially expanded.
  final bool isExpanded;

  /// Whether this specific item is disabled.
  final bool disabled;

  const AnimalCollapseItem({
    required this.title,
    required this.content,
    this.isExpanded = false,
    this.disabled = false,
  });
}

/// Animal Island Accordion / Collapse component.
///
/// Features animated expand/collapse, accordion single-expand mode,
/// disabled states, and didUpdateWidget synchronization.
class AnimalCollapse extends StatefulWidget {
  final List<AnimalCollapseItem> items;
  final bool accordion;
  final bool disabled;

  const AnimalCollapse({
    super.key,
    required this.items,
    this.accordion = false,
    this.disabled = false,
  });

  /// Convenient constructor for a single question/answer collapse card.
  factory AnimalCollapse.single({
    Key? key,
    required Widget question,
    required Widget answer,
    bool defaultExpanded = false,
    bool disabled = false,
  }) {
    return AnimalCollapse(
      key: key,
      items: [
        AnimalCollapseItem(
          title: question,
          content: answer,
          isExpanded: defaultExpanded,
          disabled: disabled,
        ),
      ],
      disabled: disabled,
    );
  }

  @override
  State<AnimalCollapse> createState() => _AnimalCollapseState();
}

class _AnimalCollapseState extends State<AnimalCollapse> {
  late List<bool> _expanded;
  int? _focusedIndex;

  @override
  void initState() {
    super.initState();
    _initExpanded();
  }

  @override
  void didUpdateWidget(AnimalCollapse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _initExpanded();
    } else {
      for (int i = 0; i < widget.items.length; i++) {
        if (oldWidget.items[i].isExpanded != widget.items[i].isExpanded) {
          _expanded[i] = widget.items[i].isExpanded;
        }
      }
    }
  }

  void _initExpanded() {
    _expanded = widget.items.map((e) => e.isExpanded).toList();
  }

  void _toggle(int index) {
    if (widget.disabled || widget.items[index].disabled) return;
    setState(() {
      if (widget.accordion) {
        for (int i = 0; i < _expanded.length; i++) {
          _expanded[i] = (i == index) ? !_expanded[i] : false;
        }
      } else {
        _expanded[index] = !_expanded[index];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        final isOpen = index < _expanded.length ? _expanded[index] : false;
        final isItemDisabled = widget.disabled || item.disabled;
        final isItemFocused = _focusedIndex == index;

        return Container(
          margin: const EdgeInsets.only(bottom: 8.0),
          decoration: BoxDecoration(
            color: isItemDisabled
                ? (theme.isDark ? theme.surfaceAlt : AnimalColors.bgDisabled)
                : theme.bgContent,
            borderRadius: AnimalRadii.cardBorder,
            border: Border.all(
              color: isItemFocused
                  ? theme.focusYellow
                  : (theme.isDark ? theme.border : AnimalColors.borderLight),
              width: 1.5,
            ),
            boxShadow: isItemFocused
                ? [
                    BoxShadow(
                      color: theme.focusYellow.withValues(alpha: 0.5),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Semantics(
                button: true,
                expanded: isOpen,
                enabled: !isItemDisabled,
                child: FocusableActionDetector(
                  enabled: !isItemDisabled,
                  mouseCursor: isItemDisabled
                      ? SystemMouseCursors.forbidden
                      : SystemMouseCursors.click,
                  onShowFocusHighlight: (val) {
                    setState(() {
                      _focusedIndex = val ? index : null;
                    });
                  },
                  actions: {
                    ActivateIntent: CallbackAction<ActivateIntent>(
                      onInvoke: (_) {
                        _toggle(index);
                        return null;
                      },
                    ),
                  },
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: isItemDisabled ? null : () => _toggle(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DefaultTextStyle(
                              style: AnimalTypography.heading.copyWith(
                                fontSize: 16.0,
                                color: isItemDisabled ? theme.textDisabled : theme.text,
                              ),
                              child: item.title,
                            ),
                          ),
                          AnimatedRotation(
                            turns: isOpen ? 0.25 : 0.0,
                            duration: AnimalMotion.normal,
                            curve: AnimalMotion.ease,
                            child: PlayIcon(
                              size: 14,
                              color: isItemDisabled ? theme.textDisabled : theme.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ExcludeSemantics(
                excluding: !isOpen,
                child: AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 18.0, bottom: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 8.0),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.isDark
                                ? theme.border.withValues(alpha: 0.3)
                                : AnimalColors.bgSecondary,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: DefaultTextStyle(
                        style: AnimalTypography.body.copyWith(
                          color: isItemDisabled ? theme.textDisabled : theme.textBody,
                        ),
                        child: item.content,
                      ),
                    ),
                  ),
                  crossFadeState: isOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: AnimalMotion.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

