import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';

class _PrevTabIntent extends Intent {
  const _PrevTabIntent();
}

class _NextTabIntent extends Intent {
  const _NextTabIntent();
}

/// Specification for each tab in [AnimalTabs].
class AnimalTabItem {
  final String label;
  final Widget? icon;
  final bool disabled;

  const AnimalTabItem({
    required this.label,
    this.icon,
    this.disabled = false,
  });
}

/// Animal Island Pill Tab Bar.
///
/// Features responsive horizontal scrolling, animated physical sliding pill indicator,
/// item disabled states, arrow key navigation, and pointer cursors.
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
  late List<GlobalKey> _keys;
  Rect? _indicatorRect;
  final GlobalKey _containerKey = GlobalKey();
  bool _isTabBarFocused = false;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.tabs.length, (_) => GlobalKey());
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void didUpdateWidget(covariant AnimalTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _keys = List.generate(widget.tabs.length, (_) => GlobalKey());
    }
    if (oldWidget.selectedIndex != widget.selectedIndex || oldWidget.tabs.length != widget.tabs.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
    }
  }

  void _updateIndicator() {
    if (!mounted || widget.selectedIndex < 0 || widget.selectedIndex >= _keys.length) return;
    final tabCtx = _keys[widget.selectedIndex].currentContext;
    final containerCtx = _containerKey.currentContext;
    if (tabCtx != null && containerCtx != null) {
      final tabBox = tabCtx.findRenderObject() as RenderBox?;
      final containerBox = containerCtx.findRenderObject() as RenderBox?;
      if (tabBox != null && containerBox != null && tabBox.hasSize && containerBox.hasSize) {
        final topLeft = tabBox.localToGlobal(Offset.zero, ancestor: containerBox);
        final newRect = topLeft & tabBox.size;
        if (_indicatorRect != newRect) {
          setState(() {
            _indicatorRect = newRect;
          });
        }
      }
    }
  }

  void _selectPrev() {
    for (int i = widget.selectedIndex - 1; i >= 0; i--) {
      if (!widget.tabs[i].disabled) {
        widget.onChanged(i);
        break;
      }
    }
  }

  void _selectNext() {
    for (int i = widget.selectedIndex + 1; i < widget.tabs.length; i++) {
      if (!widget.tabs[i].disabled) {
        widget.onChanged(i);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);

    Widget tabsContent = Stack(
      children: [
        if (_indicatorRect != null)
          AnimatedPositioned(
            duration: AnimalMotion.normal,
            curve: AnimalMotion.spring,
            left: _indicatorRect!.left,
            top: _indicatorRect!.top,
            width: _indicatorRect!.width,
            height: _indicatorRect!.height,
            child: Container(
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: AnimalRadii.pillBorder,
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryActive.withValues(alpha: 0.4),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        Row(
          key: _containerKey,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.tabs.length, (index) {
            final isSelected = index == widget.selectedIndex;
            final tab = widget.tabs[index];
            final isDisabled = tab.disabled;

            Color textColor;
            if (isDisabled) {
              textColor = theme.textDisabled;
            } else if (isSelected) {
              textColor = const Color(0xFFFFFFFF);
            } else {
              textColor = theme.text;
            }

            return FocusableActionDetector(
              key: _keys[index],
              enabled: !isDisabled,
              mouseCursor: isDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    if (!isDisabled) widget.onChanged(index);
                    return null;
                  },
                ),
              },
              child: Semantics(
                selected: isSelected,
                enabled: !isDisabled,
                button: true,
                label: tab.label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isDisabled ? null : () => widget.onChanged(index),
                  child: AnimatedContainer(
                    duration: AnimalMotion.fast,
                    curve: AnimalMotion.ease,
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: (_indicatorRect == null && isSelected) ? theme.primary : const Color(0x00000000),
                      borderRadius: AnimalRadii.pillBorder,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (tab.icon != null) ...[
                          tab.icon!,
                          const SizedBox(width: 6.0),
                        ],
                        Text(
                          tab.label,
                          style: AnimalTypography.button.copyWith(
                            color: textColor,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );

    if (widget.scrollable) {
      tabsContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: tabsContent,
      );
    }

    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowLeft): _PrevTabIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): _NextTabIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _PrevTabIntent: CallbackAction<_PrevTabIntent>(
            onInvoke: (_) {
              _selectPrev();
              return null;
            },
          ),
          _NextTabIntent: CallbackAction<_NextTabIntent>(
            onInvoke: (_) {
              _selectNext();
              return null;
            },
          ),
        },
        child: Focus(
          onFocusChange: (val) => setState(() => _isTabBarFocused = val),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: theme.isDark ? theme.surfaceHeader : AnimalColors.bgDisabled,
              borderRadius: AnimalRadii.pillBorder,
              border: Border.all(
                color: _isTabBarFocused
                    ? theme.focusYellow
                    : (theme.isDark ? theme.border : AnimalColors.borderLight),
                width: 1.2,
              ),
              boxShadow: _isTabBarFocused
                  ? [
                      BoxShadow(
                        color: theme.focusYellow.withValues(alpha: 0.55),
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: tabsContent,
          ),
        ),
      ),
    );
  }
}

