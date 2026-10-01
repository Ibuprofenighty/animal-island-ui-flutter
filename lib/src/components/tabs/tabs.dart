import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../internal/interaction/interactive_region.dart';
import '../../foundation/theme/theme.dart';
import 'tab_indicator.dart';
import 'tab_item.dart';

export 'tab_indicator.dart';
export 'tab_item.dart';

class _PrevTabIntent extends Intent {
  const _PrevTabIntent();
}

class _NextTabIntent extends Intent {
  const _NextTabIntent();
}

class _FirstTabIntent extends Intent {
  const _FirstTabIntent();
}

class _LastTabIntent extends Intent {
  const _LastTabIntent();
}

/// Animal Island Pill Tab Bar (C10).
///
/// Features:
/// - Layout-driven indicator positioning. Geometry is recalculated when tab labels,
///   parent constraints, text scaling, locale, or selected index changes.
/// - Full keyboard accessibility: Left / Right arrows (with RTL awareness), Home, End,
///   Enter, and Space.
/// - Tab item focus and activate intent.
/// - Requests `Scrollable.ensureVisible` for the active tab. Narrow-layout auto-scroll
///   is not yet guaranteed.
/// - Safe boundary handling for 0 tabs, all-disabled tabs, or external index changes.
class AnimalTabs extends StatefulWidget {
  final List<AnimalTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool scrollable;

  const AnimalTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.scrollable = true,
  });

  @override
  State<AnimalTabs> createState() => _AnimalTabsState();
}

class _AnimalTabsState extends State<AnimalTabs> {
  late List<GlobalKey> _tabKeys;
  final GlobalKey _stackKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  Rect? _indicatorRect;
  bool _isScheduled = false;

  @override
  void initState() {
    super.initState();
    _recreateKeys();
    _scheduleIndicatorUpdate();
  }

  void _recreateKeys() {
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-measure indicator when MediaQuery (e.g. font scale, window resize) changes
    _scheduleIndicatorUpdate();
  }

  @override
  void didUpdateWidget(covariant AnimalTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    var needsRecreateKeys = false;
    var needsUpdate = false;

    if (oldWidget.tabs.length != widget.tabs.length) {
      needsRecreateKeys = true;
      needsUpdate = true;
    } else {
      // Check if any tab label or icon changed (F26 core requirement)
      for (int i = 0; i < widget.tabs.length; i++) {
        if (oldWidget.tabs[i].label != widget.tabs[i].label ||
            oldWidget.tabs[i].disabled != widget.tabs[i].disabled) {
          needsUpdate = true;
          break;
        }
      }
    }

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      needsUpdate = true;
    }

    if (needsRecreateKeys) {
      _recreateKeys();
    }
    if (needsUpdate) {
      _scheduleIndicatorUpdate();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleIndicatorUpdate() {
    if (_isScheduled) return;
    _isScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isScheduled = false;
      if (!mounted) return;
      _updateIndicator();
    });
  }

  void _updateIndicator() {
    if (!mounted || widget.tabs.isEmpty) {
      if (_indicatorRect != null) {
        setState(() => _indicatorRect = null);
      }
      return;
    }

    final safeIndex = widget.selectedIndex.clamp(0, widget.tabs.length - 1);
    if (safeIndex >= _tabKeys.length) return;

    final tabCtx = _tabKeys[safeIndex].currentContext;
    final stackCtx = _stackKey.currentContext;

    if (tabCtx != null && stackCtx != null) {
      final tabBox = tabCtx.findRenderObject() as RenderBox?;
      final stackBox = stackCtx.findRenderObject() as RenderBox?;

      if (tabBox != null &&
          stackBox != null &&
          tabBox.hasSize &&
          stackBox.hasSize) {
        final topLeft = tabBox.localToGlobal(Offset.zero, ancestor: stackBox);
        final newRect = topLeft & tabBox.size;
        if (_indicatorRect != newRect) {
          setState(() {
            _indicatorRect = newRect;
          });
        }

        // Auto-scroll into view if scrollable
        if (widget.scrollable && mounted) {
          Scrollable.ensureVisible(
            tabCtx,
            duration: AnimalIslandTheme.of(context).motion.normal,
            curve: AnimalIslandTheme.of(context).motion.ease,
            alignment: 0.5,
          );
        }
      }
    }
  }

  void _selectPrev(bool isRtl) {
    if (isRtl) {
      _step(1);
    } else {
      _step(-1);
    }
  }

  void _selectNext(bool isRtl) {
    if (isRtl) {
      _step(-1);
    } else {
      _step(1);
    }
  }

  void _step(int direction) {
    if (widget.tabs.isEmpty) return;
    int next = widget.selectedIndex + direction;
    while (next >= 0 && next < widget.tabs.length) {
      if (!widget.tabs[next].disabled) {
        widget.onChanged(next);
        return;
      }
      next += direction;
    }
  }

  void _selectFirst() {
    for (int i = 0; i < widget.tabs.length; i++) {
      if (!widget.tabs[i].disabled) {
        widget.onChanged(i);
        return;
      }
    }
  }

  void _selectLast() {
    for (int i = widget.tabs.length - 1; i >= 0; i--) {
      if (!widget.tabs[i].disabled) {
        widget.onChanged(i);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Trigger indicator recalculation on parent layout width change
        _scheduleIndicatorUpdate();

        Widget tabContent = Stack(
          key: _stackKey,
          children: [
            AnimalTabIndicator(targetRect: _indicatorRect, theme: theme),
            Row(
              mainAxisSize: widget.scrollable
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              children: [
                for (int i = 0; i < widget.tabs.length; i++) ...[
                  if (!widget.scrollable)
                    Expanded(child: _buildTabItem(context, i, theme))
                  else
                    _buildTabItem(context, i, theme),
                ],
              ],
            ),
          ],
        );

        if (widget.scrollable) {
          tabContent = SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: tabContent,
          );
        }

        return Container(
          padding: EdgeInsets.all(theme.spacing.xs),
          decoration: BoxDecoration(
            color: theme.colors.surfaceAlt,
            borderRadius: theme.radii.pillBorder,
            border: Border.all(color: theme.colors.border, width: 1.5),
          ),
          child: Shortcuts(
            shortcuts: <ShortcutActivator, Intent>{
              LogicalKeySet(LogicalKeyboardKey.arrowLeft):
                  const _PrevTabIntent(),
              LogicalKeySet(LogicalKeyboardKey.arrowRight):
                  const _NextTabIntent(),
              LogicalKeySet(LogicalKeyboardKey.home): const _FirstTabIntent(),
              LogicalKeySet(LogicalKeyboardKey.end): const _LastTabIntent(),
            },
            child: Actions(
              actions: <Type, Action<Intent>>{
                _PrevTabIntent: CallbackAction<_PrevTabIntent>(
                  onInvoke: (_) {
                    _selectPrev(isRtl);
                    return null;
                  },
                ),
                _NextTabIntent: CallbackAction<_NextTabIntent>(
                  onInvoke: (_) {
                    _selectNext(isRtl);
                    return null;
                  },
                ),
                _FirstTabIntent: CallbackAction<_FirstTabIntent>(
                  onInvoke: (_) {
                    _selectFirst();
                    return null;
                  },
                ),
                _LastTabIntent: CallbackAction<_LastTabIntent>(
                  onInvoke: (_) {
                    _selectLast();
                    return null;
                  },
                ),
              },
              child: tabContent,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    int index,
    AnimalIslandTheme theme,
  ) {
    final tab = widget.tabs[index];
    final isSelected = index == widget.selectedIndex;
    final isDisabled = tab.disabled;

    final textColor = isDisabled
        ? theme.colors.textSecondary.withValues(alpha: 0.4)
        : (isSelected ? theme.colors.onPrimary : theme.colors.text);

    return InteractiveRegion(
      key: index < _tabKeys.length ? _tabKeys[index] : null,
      onPressed: isDisabled ? null : () => widget.onChanged(index),
      disabled: isDisabled,
      enableHaptics: false,
      selected: isSelected,
      semanticLabel: tab.label,
      borderRadius: theme.radii.pillBorder,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.sm,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tab.icon != null) ...[
              IconTheme(
                data: IconThemeData(color: textColor, size: 16.0),
                child: tab.icon!,
              ),
              SizedBox(width: theme.spacing.xs),
            ],
            Text(
              tab.label,
              style: theme.typography.body.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
