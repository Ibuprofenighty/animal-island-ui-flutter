import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/option.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../input/input.dart';

/// A controlled select whose menu preserves unknown caller values.
class AnimalSelect<T> extends StatefulWidget {
  final T? value;
  final List<AnimalOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final bool disabled;
  final bool readOnly;
  final bool allowClear;
  final AnimalInputStatus status;
  final FocusNode? focusNode;

  AnimalSelect({
    super.key,
    required this.value,
    required List<AnimalOption<T>> options,
    required this.onChanged,
    this.placeholder,
    this.disabled = false,
    this.readOnly = false,
    this.allowClear = false,
    this.status = AnimalInputStatus.normal,
    this.focusNode,
  }) : options = snapshotUniqueOptions<T>(options, owner: 'AnimalSelect');

  @override
  State<AnimalSelect<T>> createState() => _AnimalSelectState<T>();
}

class _AnimalSelectState<T> extends State<AnimalSelect<T>> {
  static const double _maximumMenuHeight = 320;

  final MenuController _controller = MenuController();
  final ScrollController _menuScrollController = ScrollController();
  final Map<T, FocusNode> _optionFocusNodes = <T, FocusNode>{};
  FocusNode? _internalFocusNode;
  bool _isFocused = false;
  T? _pendingFocusValue;
  bool _hasPendingFocusValue = false;
  int _focusRequestGeneration = 0;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  AnimalOption<T>? get _selectedOption {
    for (final AnimalOption<T> option in widget.options) {
      if (option.value == widget.value) return option;
    }
    return null;
  }

  bool get _canOpen =>
      !widget.disabled && !widget.readOnly && widget.onChanged != null;

  bool get _cannotActivate =>
      widget.disabled || (widget.onChanged == null && !widget.readOnly);

  bool _isOptionEnabled(AnimalOption<T> option) => _canOpen && !option.disabled;

  double get _optionExtent {
    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final TextPainter lineMetrics = TextPainter(
      text: TextSpan(style: theme.typography.resolve(theme.typography.body)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
    );
    final double contentHeight = lineMetrics.preferredLineHeight * 2;
    lineMetrics.dispose();
    return math.max(48, contentHeight + theme.spacing.sm * 2);
  }

  @override
  void initState() {
    super.initState();
    _syncOptionFocusNodes();
  }

  @override
  void didUpdateWidget(covariant AnimalSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    T? previouslyFocusedValue;
    bool hadFocusedOption = false;
    for (final AnimalOption<T> option in oldWidget.options) {
      if (_optionFocusNodes[option.value]?.hasFocus == true) {
        previouslyFocusedValue = option.value;
        hadFocusedOption = true;
        break;
      }
    }
    _syncOptionFocusNodes();
    if (_controller.isOpen) {
      if (!_canOpen || !widget.options.any(_isOptionEnabled)) {
        _controller.close();
      } else {
        AnimalOption<T>? targetOption;
        if (_hasPendingFocusValue) {
          targetOption = _optionForValue(_pendingFocusValue);
        }
        if (hadFocusedOption) {
          targetOption ??= _optionForValue(previouslyFocusedValue);
        }
        targetOption ??= _initialFocusableOption;
        if (targetOption != null) _focusMenuOptionValue(targetOption.value);
      }
    }
  }

  AnimalOption<T>? _optionForValue(T? identity) {
    for (final AnimalOption<T> option in widget.options) {
      if (option.value == identity && _isOptionEnabled(option)) return option;
    }
    return null;
  }

  void _cancelPendingFocusRequest() {
    _focusRequestGeneration++;
    _hasPendingFocusValue = false;
  }

  void _syncOptionFocusNodes() {
    final Set<T> identities = widget.options
        .map((AnimalOption<T> option) => option.value)
        .toSet();
    final List<T> removed = _optionFocusNodes.keys
        .where((T identity) => !identities.contains(identity))
        .toList(growable: false);
    for (final T identity in removed) {
      _optionFocusNodes.remove(identity)?.dispose();
    }
    for (final AnimalOption<T> option in widget.options) {
      _optionFocusNodes.putIfAbsent(
        option.value,
        () => FocusNode(debugLabel: 'AnimalSelect(${option.value})'),
      );
    }
  }

  AnimalOption<T>? get _initialFocusableOption {
    final AnimalOption<T>? selected = _selectedOption;
    if (selected != null && _isOptionEnabled(selected)) return selected;
    for (final AnimalOption<T> option in widget.options) {
      if (_isOptionEnabled(option)) return option;
    }
    return null;
  }

  void _focusMenuOptionValue(T identity) {
    final int requestGeneration = ++_focusRequestGeneration;
    _pendingFocusValue = identity;
    _hasPendingFocusValue = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (requestGeneration != _focusRequestGeneration ||
          !mounted ||
          !_controller.isOpen ||
          !_menuScrollController.hasClients) {
        return;
      }
      final int currentIndex = widget.options.indexWhere(
        (AnimalOption<T> option) =>
            option.value == identity && _isOptionEnabled(option),
      );
      if (currentIndex < 0) {
        _hasPendingFocusValue = false;
        return;
      }
      final double targetOffset = (currentIndex * _optionExtent).clamp(
        0,
        _menuScrollController.position.maxScrollExtent,
      );
      _menuScrollController.jumpTo(targetOffset);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (requestGeneration != _focusRequestGeneration ||
            !mounted ||
            !_controller.isOpen) {
          return;
        }
        final AnimalOption<T>? currentOption = _optionForValue(identity);
        if (currentOption == null) {
          _hasPendingFocusValue = false;
          return;
        }
        _optionFocusNodes[currentOption.value]?.requestFocus();
        _hasPendingFocusValue = false;
      }, debugLabel: 'AnimalSelect.focusVisibleOption');
      // addPostFrameCallback does not request another frame. A zero-offset
      // focus request would otherwise remain queued until unrelated work
      // schedules one, leaving the trigger as the active keyboard target.
      WidgetsBinding.instance.ensureVisualUpdate();
    }, debugLabel: 'AnimalSelect.scrollToOption');
    // Scheduling a post-frame callback does not create a frame. Arrow-key
    // events may leave the scheduler idle, so request the frame that performs
    // the first identity check and scroll.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _focusInitialMenuOption() {
    final AnimalOption<T>? target = _initialFocusableOption;
    if (target != null) _focusMenuOptionValue(target.value);
  }

  @override
  void dispose() {
    _cancelPendingFocusRequest();
    for (final FocusNode focusNode in _optionFocusNodes.values) {
      focusNode.dispose();
    }
    _menuScrollController.dispose();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleOptionSelected(T value) {
    if (!_canOpen) return;
    AnimalOption<T>? currentOption;
    for (final AnimalOption<T> option in widget.options) {
      if (option.value == value) {
        currentOption = option;
        break;
      }
    }
    if (currentOption == null || !_isOptionEnabled(currentOption)) return;
    _controller.close();
    widget.onChanged?.call(value);
  }

  void _handleClear() {
    if (!_canOpen || widget.value == null) return;
    widget.onChanged?.call(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _effectiveFocusNode.requestFocus();
    }, debugLabel: 'AnimalSelect.restoreFocusAfterClear');
  }

  KeyEventResult _handleOptionKey(int currentIndex, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final List<int> enabledIndices = <int>[
      for (int index = 0; index < widget.options.length; index++)
        if (_isOptionEnabled(widget.options[index])) index,
    ];
    if (enabledIndices.isEmpty) return KeyEventResult.ignored;
    int position = enabledIndices.indexOf(currentIndex);
    if (position < 0) position = 0;
    final LogicalKeyboardKey key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      position = (position + 1) % enabledIndices.length;
    } else if (key == LogicalKeyboardKey.arrowUp) {
      position = (position - 1 + enabledIndices.length) % enabledIndices.length;
    } else if (key == LogicalKeyboardKey.home) {
      position = 0;
    } else if (key == LogicalKeyboardKey.end) {
      position = enabledIndices.length - 1;
    } else {
      return KeyEventResult.ignored;
    }
    _focusMenuOptionValue(widget.options[enabledIndices[position]].value);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final AnimalIslandTheme theme = AnimalIslandTheme.of(context);
    final AnimalLocalizations localizations = AnimalLocalizations.of(context)!;
    final double optionExtent = _optionExtent;
    final AnimalOption<T>? selected = _selectedOption;
    final bool hasKnownValue = selected != null;
    final bool hasUnknownValue = widget.value != null && selected == null;
    final String visibleLabel =
        selected?.label ??
        widget.placeholder ??
        localizations.selectPlaceholder;
    final double menuWidth = math.min(
      320,
      math.max(1, MediaQuery.sizeOf(context).width - 24),
    );
    final double menuHeight = math.min(
      _maximumMenuHeight,
      math.max(1, widget.options.length * optionExtent),
    );
    final Color inputBackground = _cannotActivate
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceHeader
              : theme.colors.bgInputDisabled)
        : theme.colors.bgInput;

    return MenuAnchor(
      controller: _controller,
      childFocusNode: _effectiveFocusNode,
      onOpen: _focusInitialMenuOption,
      onClose: () {
        _cancelPendingFocusRequest();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _effectiveFocusNode.requestFocus();
        }, debugLabel: 'AnimalSelect.restoreFocusAfterClose');
      },
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(theme.colors.bgContent),
        elevation: const WidgetStatePropertyAll<double>(4),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: theme.radii.tooltipBorder,
            side: BorderSide(color: theme.colors.border, width: 1.5),
          ),
        ),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: theme.spacing.xs),
        ),
      ),
      menuChildren: <Widget>[
        Semantics(
          role: SemanticsRole.menu,
          container: true,
          explicitChildNodes: true,
          child: SizedBox(
            width: menuWidth,
            height: menuHeight,
            child: ListView.builder(
              controller: _menuScrollController,
              itemCount: widget.options.length,
              itemExtent: optionExtent,
              padding: EdgeInsets.zero,
              itemBuilder: (BuildContext context, int index) {
                final AnimalOption<T> option = widget.options[index];
                return _SelectMenuOption<T>(
                  key: ValueKey<T>(option.value),
                  option: option,
                  selected: option.value == widget.value,
                  disabled: !_isOptionEnabled(option),
                  theme: theme,
                  focusNode: _optionFocusNodes[option.value]!,
                  onPressed: () => _handleOptionSelected(option.value),
                  onKeyEvent: (_, KeyEvent event) =>
                      _handleOptionKey(index, event),
                );
              },
            ),
          ),
        ),
      ],
      builder:
          (BuildContext context, MenuController controller, Widget? child) {
            final bool focusActive = _isFocused || controller.isOpen;
            Color borderColor = theme.colors.border;
            Color? focusGlowColor;
            if (_cannotActivate) {
              borderColor = (theme.colors.brightness == Brightness.dark)
                  ? theme.colors.border.withValues(alpha: 0.3)
                  : theme.colors.borderLight;
            } else if (widget.status == AnimalInputStatus.error ||
                hasUnknownValue) {
              borderColor = theme.colors.errorText;
              focusGlowColor = theme.colors.errorText.withValues(alpha: 0.45);
            } else if (focusActive) {
              borderColor = theme.colors.focusYellow;
              focusGlowColor = theme.colors.focusYellow.withValues(alpha: 0.45);
            }

            return Row(
              children: <Widget>[
                Expanded(
                  child: InteractiveRegion(
                    onPressed: () {
                      if (!_canOpen) return;
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
                    enableHaptics: false,
                    disabled: _cannotActivate,
                    readOnly: widget.readOnly,
                    focusNode: _effectiveFocusNode,
                    semanticLabel: visibleLabel,
                    semanticValue: hasUnknownValue
                        ? visibleLabel
                        : selected?.label,
                    invalid:
                        hasUnknownValue ||
                        widget.status == AnimalInputStatus.error,
                    borderRadius: theme.radii.pillBorder,
                    surfaceColor: inputBackground,
                    border: Border.all(color: borderColor, width: 1.8),
                    extraShadows: focusActive || focusGlowColor != null
                        ? <BoxShadow>[
                            BoxShadow(
                              color:
                                  focusGlowColor ??
                                  theme.colors.focusYellow.withValues(
                                    alpha: 0.45,
                                  ),
                              offset: Offset.zero,
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                    padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
                    selected: hasKnownValue,
                    expanded: controller.isOpen,
                    onFocusChanged: (bool focused) =>
                        setState(() => _isFocused = focused),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            visibleLabel,
                            style: theme.typography.body.copyWith(
                              color: _cannotActivate
                                  ? theme.colors.textDisabled
                                  : (hasKnownValue
                                        ? theme.colors.text
                                        : theme.colors.textSecondary),
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: controller.isOpen ? 0.5 : 0,
                          duration: theme.motion.normal,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: _cannotActivate
                                ? theme.colors.textDisabled
                                : theme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (widget.allowClear && widget.value != null && _canOpen)
                  InteractiveRegion(
                    onPressed: _handleClear,
                    enableHaptics: false,
                    semanticLabel: localizations.selectClearLabel,
                    surfaceColor: Colors.transparent,
                    child: AnimalIcon(
                      data: AnimalIcons.close,
                      size: 16,
                      color: theme.colors.textSecondary,
                    ),
                  ),
              ],
            );
          },
    );
  }
}

class _SelectMenuOption<T> extends StatefulWidget {
  final AnimalOption<T> option;
  final bool selected;
  final bool disabled;
  final AnimalIslandTheme theme;
  final FocusNode focusNode;
  final VoidCallback onPressed;
  final FocusOnKeyEventCallback onKeyEvent;

  const _SelectMenuOption({
    super.key,
    required this.option,
    required this.selected,
    required this.disabled,
    required this.theme,
    required this.focusNode,
    required this.onPressed,
    required this.onKeyEvent,
  });

  @override
  State<_SelectMenuOption<T>> createState() => _SelectMenuOptionState<T>();
}

class _SelectMenuOptionState<T> extends State<_SelectMenuOption<T>> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final AnimalIslandTheme theme = widget.theme;
    final Color background = widget.selected
        ? theme.colors.primary.withValues(alpha: 0.12)
        : (_isHovered || _isFocused
              ? theme.colors.primary.withValues(alpha: 0.06)
              : Colors.transparent);
    return InteractiveRegion(
      onPressed: widget.disabled ? null : widget.onPressed,
      focusNode: widget.focusNode,
      onKeyEvent: widget.onKeyEvent,
      disabled: widget.disabled,
      focusOnHover: true,
      enableHaptics: false,
      semanticButton: false,
      selected: widget.selected,
      minimumHitSize: 48,
      semanticsBuilder: (bool enabled, bool visible, VoidCallback? activate) =>
          SemanticsProperties(
            role: SemanticsRole.menuItem,
            enabled: enabled,
            hidden: !visible,
            label: widget.option.semanticLabel ?? widget.option.label,
            selected: widget.selected,
            onTap: activate,
          ),
      surfaceColor: background,
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.lg,
        vertical: theme.spacing.sm,
      ),
      onFocusChanged: (bool focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (widget.option.icon != null) ...<Widget>[
              ExcludeSemantics(child: widget.option.icon!),
              SizedBox(width: theme.spacing.sm),
            ],
            Expanded(
              child: Text(
                widget.option.label,
                style: theme.typography.body.copyWith(
                  color: widget.disabled
                      ? theme.colors.textDisabled
                      : (widget.selected
                            ? theme.colors.primaryText
                            : theme.colors.text),
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.selected) ...<Widget>[
              SizedBox(width: theme.spacing.md),
              AnimalIcon(
                data: AnimalIcons.check,
                size: 16,
                color: theme.colors.primaryText,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
