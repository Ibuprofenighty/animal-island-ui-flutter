import 'package:flutter/material.dart';

import '../../foundation/models/option.dart';
import '../../foundation/theme/components/tabs_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../internal/timing/motion_policy.dart';
import 'tab_indicator.dart';
import 'tab_item.dart';
export 'tab_item.dart';

/// Controlled stable-ID tabs with one roving Tab stop.
/// Arrows, Home and End move focus and propose an enabled ID. Selection and
/// its indicator stay with selectedId until the caller accepts the proposal.
class AnimalTabs extends StatefulWidget {
  /// Immutable snapshot of unique tab identities in display order.
  final List<AnimalTabItem> tabs;

  /// Selected enabled ID, or null for no selection including an empty bar.
  final String? selectedId;

  /// Receives an enabled ID once per activation or focus-navigation change.
  final ValueChanged<String> onChanged;

  /// Whether natural-width tabs scroll; false shares the available width.
  final bool scrollable;

  /// Instance overrides before component theme and tokens.
  final AnimalTabsStyle? style;

  /// Creates a bar. Duplicate, unknown or disabled selected IDs throw
  /// ArgumentError; removing the selection requires an atomic caller update.
  AnimalTabs({
    super.key,
    required List<AnimalTabItem> tabs,
    required this.selectedId,
    required this.onChanged,
    this.scrollable = true,
    this.style,
  }) : tabs = List.unmodifiable(tabs) {
    final ids = <String>{};
    for (final tab in this.tabs) {
      if (!ids.add(tab.id)) {
        throw ArgumentError.value(tab.id, 'tabs', 'IDs must be unique');
      }
    }
    if (selectedId != null &&
        !this.tabs.any((tab) => tab.id == selectedId && !tab.disabled)) {
      throw ArgumentError.value(
        selectedId,
        'selectedId',
        'must identify an enabled tab',
      );
    }
  }
  @override
  State<AnimalTabs> createState() => _AnimalTabsState();
}

class _AnimalTabsState extends State<AnimalTabs> {
  final Map<String, GlobalKey> _tabKeys = {};
  final GlobalKey _stackKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  Rect? _indicatorRect;
  bool _scheduled = false;
  double? _lastWidth;
  void _syncKeys() {
    final ids = widget.tabs.map((tab) => tab.id).toSet();
    _tabKeys.removeWhere((id, _) => !ids.contains(id));
    for (final id in ids) {
      _tabKeys.putIfAbsent(id, GlobalKey.new);
    }
  }

  @override
  void initState() {
    super.initState();
    _syncKeys();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Child layout can change without changing bar constraints or identity.
    // Subscribe so post-layout geometry follows live text and direction changes.
    MediaQuery.textScalerOf(context);
    Directionality.of(context);
    _scheduleMeasurement();
  }

  @override
  void didUpdateWidget(AnimalTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncKeys();
    final labelsChanged =
        oldWidget.tabs.length != widget.tabs.length ||
        Iterable<int>.generate(widget.tabs.length).any(
          (i) =>
              oldWidget.tabs[i].label != widget.tabs[i].label ||
              oldWidget.tabs[i].icon != widget.tabs[i].icon ||
              oldWidget.tabs[i].id != widget.tabs[i].id,
        );
    if (labelsChanged ||
        oldWidget.selectedId != widget.selectedId ||
        oldWidget.style != widget.style ||
        oldWidget.scrollable != widget.scrollable) {
      _scheduleMeasurement();
    }
  }

  void _scheduleMeasurement() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      final tabContext = _tabKeys[widget.selectedId]?.currentContext;
      final tabBox = tabContext?.findRenderObject() as RenderBox?;
      final stackBox =
          _stackKey.currentContext?.findRenderObject() as RenderBox?;
      final rect =
          tabBox != null &&
              stackBox != null &&
              tabBox.hasSize &&
              stackBox.hasSize
          ? tabBox.localToGlobal(Offset.zero, ancestor: stackBox) & tabBox.size
          : null;
      if (rect != _indicatorRect) setState(() => _indicatorRect = rect);
      if (tabContext != null && widget.scrollable) {
        final style = _resolveTabsStyle(
          AnimalIslandTheme.of(context),
          widget.style,
        );
        Scrollable.ensureVisible(
          tabContext,
          alignment: .5,
          duration: AnimalMotionPolicy.shouldAnimate(context)
              ? style.duration!
              : Duration.zero,
          curve: style.curve!,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveTabsStyle(
      AnimalIslandTheme.of(context),
      widget.style,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (_lastWidth != constraints.maxWidth) {
          _lastWidth = constraints.maxWidth;
          _scheduleMeasurement();
        }
        return Container(
          padding: style.padding,
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: style.borderRadius,
            border: Border.all(
              color: style.borderColor!,
              width: style.borderWidth!,
            ),
          ),
          child: OptionGroupFocus<String>(
            options: [
              for (final tab in widget.tabs)
                AnimalOption(
                  value: tab.id,
                  label: tab.label,
                  disabled: tab.disabled,
                ),
            ],
            direction: Axis.horizontal,
            roving: true,
            selectedValue: widget.selectedId,
            disabled: false,
            onNavigate: widget.onChanged,
            itemBuilder: (context, option, node) {
              final tab = widget.tabs.firstWhere(
                (tab) => tab.id == option.value,
              );
              final selected = tab.id == widget.selectedId;
              final states = <WidgetState>{
                if (selected) WidgetState.selected,
                if (tab.disabled) WidgetState.disabled,
              };
              final color = style.textColor!.resolve(states);
              return InteractiveRegion(
                onKeyEvent: optionGroupKeyEvent,
                key: _tabKeys[tab.id],
                focusNode: node,
                selected: selected,
                disabled: tab.disabled,
                enableHaptics: false,
                semanticLabel: tab.label,
                onPressed: () => widget.onChanged(tab.id),
                borderRadius: style.borderRadius,
                child: Container(
                  padding: style.tabPadding,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        IconTheme(
                          data: IconThemeData(
                            color: color,
                            size: style.iconSize,
                          ),
                          child: tab.icon!,
                        ),
                        SizedBox(width: style.iconGap),
                      ],
                      Flexible(
                        child: Text(
                          tab.label,
                          style: style.textStyle!.copyWith(
                            color: color,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            layoutBuilder: (context, children) {
              final content = Stack(
                key: _stackKey,
                children: [
                  AnimalTabIndicator(targetRect: _indicatorRect, style: style),
                  Row(
                    mainAxisSize: widget.scrollable
                        ? MainAxisSize.min
                        : MainAxisSize.max,
                    children: [
                      for (final child in children)
                        if (widget.scrollable)
                          child
                        else
                          Expanded(child: child),
                    ],
                  ),
                ],
              );
              return widget.scrollable
                  ? SingleChildScrollView(
                      controller: _scrollController,
                      scrollDirection: Axis.horizontal,
                      child: content,
                    )
                  : content;
            },
          ),
        );
      },
    );
  }
}

AnimalTabsStyle _resolveTabsStyle(
  AnimalIslandTheme theme,
  AnimalTabsStyle? instance,
) {
  final component = theme.components.tabs;
  return (instance ?? AnimalTabsStyle())
      .merge(component)
      .merge(
        AnimalTabsStyle(
          backgroundColor: theme.colors.surfaceAlt,
          borderColor: theme.colors.border,
          borderWidth: 1.5,
          borderRadius: theme.radii.pillBorder,
          padding: EdgeInsets.all(theme.spacing.xs),
          tabPadding: EdgeInsets.symmetric(
            horizontal: theme.spacing.lg,
            vertical: theme.spacing.sm,
          ),
          iconGap: theme.spacing.xs,
          iconSize: 16,
          textStyle: theme.typography.body,
          indicatorColor: theme.colors.primary,
          shadow: theme.shadows.button3d,
          duration: theme.motion.normal,
          curve: theme.motion.spring,
        ),
      )
      .copyWith(
        textColor: WidgetStateProperty.resolveWith(
          (states) =>
              instance?.textColor?.resolve(states) ??
              component?.textColor?.resolve(states) ??
              (states.contains(WidgetState.disabled)
                  ? theme.colors.textSecondary.withValues(alpha: .4)
                  : states.contains(WidgetState.selected)
                  ? theme.colors.onPrimary
                  : theme.colors.text),
        ),
      );
}
