import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/option.dart';
import '../../foundation/theme/components/select_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/focus_ring.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../internal/interaction/option_group_focus.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../input/input.dart';

/// A controlled select whose menu preserves unknown caller values.
///
/// Visual overrides come from [style] and `AnimalIslandTheme.components.select`.
class AnimalSelect<T> extends StatefulWidget {
  final T? value;
  final List<AnimalOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final bool disabled;
  final bool readOnly;
  final bool allowClear;
  final AnimalInputStatus status;

  /// Overrides for this select, taking precedence over the theme.
  final AnimalSelectStyle? style;
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
    this.style,
    this.focusNode,
  }) : options = snapshotUniqueOptions<T>(options, owner: 'AnimalSelect');

  @override
  State<AnimalSelect<T>> createState() => _AnimalSelectState<T>();
}

class _AnimalSelectState<T> extends State<AnimalSelect<T>> {
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

  _ResolvedSelectStyle get _resolvedStyle => _ResolvedSelectStyle.resolve(
    theme: AnimalIslandTheme.of(context),
    style: widget.style,
  );

  double _optionExtentFor(_ResolvedSelectStyle resolved) {
    final TextPainter lineMetrics = TextPainter(
      text: TextSpan(style: resolved.optionTextStyle),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 2,
    );
    final double contentHeight = lineMetrics.preferredLineHeight * 2;
    lineMetrics.dispose();
    return math.max(
      _ResolvedSelectStyle.minimumOptionExtent,
      contentHeight + resolved.optionPadding.vertical,
    );
  }

  double get _optionExtent => _optionExtentFor(_resolvedStyle);

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
    final AnimalLocalizations localizations = AnimalLocalizations.of(context)!;
    final _ResolvedSelectStyle resolved = _resolvedStyle;
    final double optionExtent = _optionExtentFor(resolved);
    final AnimalOption<T>? selected = _selectedOption;
    final bool hasKnownValue = selected != null;
    final bool hasUnknownValue = widget.value != null && selected == null;
    final String visibleLabel =
        selected?.label ??
        widget.placeholder ??
        localizations.selectPlaceholder;
    final double menuWidth = math.min(
      resolved.menuMaxWidth,
      math.max(
        1,
        MediaQuery.sizeOf(context).width - _ResolvedSelectStyle.viewportMargin,
      ),
    );
    final double menuHeight = math.min(
      resolved.menuMaxHeight,
      math.max(1, widget.options.length * optionExtent),
    );

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
        backgroundColor: WidgetStatePropertyAll<Color>(
          resolved.menuBackgroundColor,
        ),
        elevation: WidgetStatePropertyAll<double>(resolved.menuElevation),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: resolved.menuBorderRadius,
            side: BorderSide(
              color: resolved.menuBorderColor,
              width: resolved.menuBorderWidth,
            ),
          ),
        ),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(vertical: resolved.menuVerticalPadding),
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
                  resolved: resolved,
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
            final bool invalid =
                widget.status == AnimalInputStatus.error || hasUnknownValue;
            final Set<WidgetState> states = <WidgetState>{
              if (_cannotActivate) WidgetState.disabled,
              if (focusActive) WidgetState.focused,
              if (invalid) WidgetState.error,
              if (hasKnownValue) WidgetState.selected,
            };
            final bool showGlow = focusActive || (invalid && !_cannotActivate);

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
                    borderRadius: resolved.borderRadius,
                    surfaceColor: resolved.backgroundColor(states),
                    border: Border.all(
                      color: resolved.borderColor(states),
                      width: resolved.borderWidth,
                    ),
                    extraShadows: showGlow
                        ? <BoxShadow>[
                            BoxShadow(
                              color: resolved.glowColor(states),
                              offset: Offset.zero,
                              blurRadius: _ResolvedSelectStyle.glowBlurRadius,
                              spreadRadius:
                                  _ResolvedSelectStyle.glowSpreadRadius,
                            ),
                          ]
                        : null,
                    padding: EdgeInsets.symmetric(
                      horizontal: resolved.horizontalPadding,
                    ),
                    selected: hasKnownValue,
                    expanded: controller.isOpen,
                    onFocusChanged: (bool focused) =>
                        setState(() => _isFocused = focused),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            visibleLabel,
                            style: resolved.textStyle.copyWith(
                              color: resolved.textColor(states),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        AnimatedRotation(
                          turns: controller.isOpen ? 0.5 : 0,
                          duration: resolved.arrowTurnDuration,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: resolved.arrowIconSize,
                            color: resolved.arrowIconColor(states),
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
                      size: resolved.clearIconSize,
                      color: resolved.clearIconColor,
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
  final _ResolvedSelectStyle resolved;
  final FocusNode focusNode;
  final VoidCallback onPressed;
  final FocusOnKeyEventCallback onKeyEvent;

  const _SelectMenuOption({
    super.key,
    required this.option,
    required this.selected,
    required this.disabled,
    required this.resolved,
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
    final _ResolvedSelectStyle resolved = widget.resolved;
    final Set<WidgetState> states = <WidgetState>{
      if (widget.disabled) WidgetState.disabled,
      if (widget.selected) WidgetState.selected,
      if (_isHovered) WidgetState.hovered,
      if (_isFocused) WidgetState.focused,
    };
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
      surfaceColor: resolved.optionBackgroundColor(states),
      borderRadius: resolved.optionBorderRadius,
      padding: resolved.optionPadding,
      onFocusChanged: (bool focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            if (widget.option.icon != null) ...<Widget>[
              ExcludeSemantics(child: widget.option.icon!),
              SizedBox(width: resolved.optionIconGap),
            ],
            Expanded(
              child: Text(
                widget.option.label,
                style: resolved.optionLabelStyle(states),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.selected) ...<Widget>[
              SizedBox(width: resolved.checkIconGap),
              AnimalIcon(
                data: AnimalIcons.check,
                size: resolved.checkIconSize,
                color: resolved.checkIconColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The one place [AnimalSelect] turns its layers into concrete values.
///
/// Precedence: the select's own style, then the theme's select style, then
/// defaults derived from theme tokens. State-dependent colors are resolved per
/// build from the merged style.
class _ResolvedSelectStyle {
  /// Accessibility floor for each option row; not a style field.
  static const double minimumOptionExtent = 48;

  /// Space the menu keeps from the viewport edges combined.
  static const double viewportMargin = 24;

  /// Geometry of the focus and validation glow around the trigger.
  static const double glowBlurRadius = 4;
  static const double glowSpreadRadius = 2;

  /// Opacity of the default glow relative to the border color it follows.
  static const double _glowAlpha = 0.45;

  final AnimalIslandTheme theme;
  final AnimalSelectStyle style;
  final Color focusColor;

  final TextStyle textStyle;
  final double borderWidth;
  final BorderRadius borderRadius;
  final double horizontalPadding;
  final double arrowIconSize;
  final double clearIconSize;
  final Color clearIconColor;
  final Color menuBackgroundColor;
  final Color menuBorderColor;
  final double menuBorderWidth;
  final BorderRadius menuBorderRadius;
  final double menuElevation;
  final double menuVerticalPadding;
  final double menuMaxWidth;
  final double menuMaxHeight;

  /// Unselected option label style, also used to size option rows.
  final TextStyle optionTextStyle;
  final TextStyle selectedOptionTextStyle;
  final BorderRadius optionBorderRadius;
  final EdgeInsetsGeometry optionPadding;
  final double optionIconGap;
  final double checkIconGap;
  final double checkIconSize;
  final Color checkIconColor;

  const _ResolvedSelectStyle._({
    required this.theme,
    required this.style,
    required this.focusColor,
    required this.textStyle,
    required this.borderWidth,
    required this.borderRadius,
    required this.horizontalPadding,
    required this.arrowIconSize,
    required this.clearIconSize,
    required this.clearIconColor,
    required this.menuBackgroundColor,
    required this.menuBorderColor,
    required this.menuBorderWidth,
    required this.menuBorderRadius,
    required this.menuElevation,
    required this.menuVerticalPadding,
    required this.menuMaxWidth,
    required this.menuMaxHeight,
    required this.optionTextStyle,
    required this.selectedOptionTextStyle,
    required this.optionBorderRadius,
    required this.optionPadding,
    required this.optionIconGap,
    required this.checkIconGap,
    required this.checkIconSize,
    required this.checkIconColor,
  });

  static _ResolvedSelectStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalSelectStyle? style,
  }) {
    final AnimalSelectStyle merged = (style ?? AnimalSelectStyle()).merge(
      theme.components.select,
    );
    final colors = theme.colors;
    final spacing = theme.spacing;
    final typography = theme.typography;

    // The trigger label is typography.body scaled by 15/14 (15 at the
    // standard 14 logical-pixel body).
    final TextStyle textStyle = typography.resolve(
      typography.body.apply(fontSizeFactor: 15 / 14).merge(merged.textStyle),
    );
    // Option labels are typography.body: normal weight, and w600 when
    // selected. A weight in optionTextStyle applies to both.
    final TextStyle optionTextStyle = typography.resolve(
      typography.body
          .copyWith(fontWeight: FontWeight.normal)
          .merge(merged.optionTextStyle),
    );
    final TextStyle selectedOptionTextStyle = typography.resolve(
      typography.body
          .copyWith(fontWeight: FontWeight.w600)
          .merge(merged.optionTextStyle)
          .merge(merged.selectedOptionTextStyle),
    );

    return _ResolvedSelectStyle._(
      theme: theme,
      style: merged,
      focusColor: resolveFocusRing(theme).color,
      textStyle: textStyle,
      borderWidth: merged.borderWidth ?? 1.8,
      borderRadius: merged.borderRadius ?? theme.radii.pillBorder,
      horizontalPadding: merged.horizontalPadding ?? spacing.lg,
      arrowIconSize: merged.arrowIconSize ?? 18,
      clearIconSize: merged.clearIconSize ?? 16,
      clearIconColor: merged.clearIconColor ?? colors.textSecondary,
      menuBackgroundColor: merged.menuBackgroundColor ?? colors.bgContent,
      menuBorderColor: merged.menuBorderColor ?? colors.border,
      menuBorderWidth: merged.menuBorderWidth ?? 1.5,
      menuBorderRadius: merged.menuBorderRadius ?? theme.radii.tooltipBorder,
      menuElevation: merged.menuElevation ?? 4,
      menuVerticalPadding: merged.menuVerticalPadding ?? spacing.xs,
      menuMaxWidth: merged.menuMaxWidth ?? 320,
      menuMaxHeight: merged.menuMaxHeight ?? 320,
      optionTextStyle: optionTextStyle,
      selectedOptionTextStyle: selectedOptionTextStyle,
      optionBorderRadius:
          merged.optionBorderRadius ??
          const BorderRadius.all(Radius.circular(4)),
      optionPadding:
          merged.optionPadding ??
          EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.sm),
      optionIconGap: merged.optionIconGap ?? spacing.sm,
      checkIconGap: merged.checkIconGap ?? spacing.md,
      checkIconSize: merged.checkIconSize ?? 16,
      checkIconColor: merged.checkIconColor ?? colors.primaryText,
    );
  }

  bool get _dark => theme.colors.brightness == Brightness.dark;

  /// Duration of the arrow's open and close turn: the theme's normal motion.
  Duration get arrowTurnDuration => theme.motion.normal;

  Color backgroundColor(Set<WidgetState> states) {
    final colors = theme.colors;
    return style.backgroundColor?.resolve(states) ??
        (states.contains(WidgetState.disabled)
            ? (_dark ? colors.surfaceHeader : colors.bgInputDisabled)
            : colors.bgInput);
  }

  Color borderColor(Set<WidgetState> states) {
    final Color? custom = style.borderColor?.resolve(states);
    if (custom != null) return custom;
    final colors = theme.colors;
    if (states.contains(WidgetState.disabled)) {
      return _dark ? colors.border.withValues(alpha: 0.3) : colors.borderLight;
    }
    if (states.contains(WidgetState.error)) return colors.errorText;
    if (states.contains(WidgetState.focused)) return focusColor;
    return colors.border;
  }

  Color glowColor(Set<WidgetState> states) {
    final Color? custom = style.glowColor?.resolve(states);
    if (custom != null) return custom;
    final bool invalid =
        states.contains(WidgetState.error) &&
        !states.contains(WidgetState.disabled);
    return (invalid ? theme.colors.errorText : focusColor).withValues(
      alpha: _glowAlpha,
    );
  }

  Color textColor(Set<WidgetState> states) {
    final Color? custom = style.textColor?.resolve(states);
    if (custom != null) return custom;
    final colors = theme.colors;
    if (states.contains(WidgetState.disabled)) return colors.textDisabled;
    return states.contains(WidgetState.selected)
        ? colors.text
        : colors.textSecondary;
  }

  Color arrowIconColor(Set<WidgetState> states) =>
      style.arrowIconColor?.resolve(states) ??
      (states.contains(WidgetState.disabled)
          ? theme.colors.textDisabled
          : theme.colors.textSecondary);

  Color optionBackgroundColor(Set<WidgetState> states) {
    final Color? custom = style.optionBackgroundColor?.resolve(states);
    if (custom != null) return custom;
    final Color primary = theme.colors.primary;
    if (states.contains(WidgetState.selected)) {
      return primary.withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.hovered) ||
        states.contains(WidgetState.focused)) {
      return primary.withValues(alpha: 0.06);
    }
    return Colors.transparent;
  }

  TextStyle optionLabelStyle(Set<WidgetState> states) {
    final colors = theme.colors;
    final bool selected = states.contains(WidgetState.selected);
    final Color color =
        style.optionTextColor?.resolve(states) ??
        (states.contains(WidgetState.disabled)
            ? colors.textDisabled
            : (selected ? colors.primaryText : colors.text));
    return (selected ? selectedOptionTextStyle : optionTextStyle).copyWith(
      color: color,
    );
  }
}
