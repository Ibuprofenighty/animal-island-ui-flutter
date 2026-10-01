import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/models/option.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';
import '../input/input.dart';

/// Animal Island Pill Dropdown / Select component (C16).
///
/// Features:
/// - Smooth MenuAnchor popover dropdown
/// - Option-level [AnimalOption.disabled] support
/// - Quick clear button [allowClear]
/// - Full keyboard accessibility (Tab focus, Enter/Space/Arrows navigation)
class AnimalSelect<T> extends StatefulWidget {
  final T? value;
  final List<AnimalOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? placeholder;
  final bool disabled;
  final bool allowClear;
  final AnimalInputStatus status;
  final FocusNode? focusNode;

  const AnimalSelect({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.placeholder,
    this.disabled = false,
    this.allowClear = false,
    this.status = AnimalInputStatus.normal,
    this.focusNode,
  });

  @override
  State<AnimalSelect<T>> createState() => _AnimalSelectState<T>();
}

class _AnimalSelectState<T> extends State<AnimalSelect<T>> {
  final MenuController _controller = MenuController();
  final List<FocusNode> _optionFocusNodes = <FocusNode>[];
  FocusNode? _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  AnimalOption<T>? get _selectedOption {
    if (widget.value == null) return null;
    for (final opt in widget.options) {
      if (opt.value == widget.value) return opt;
    }
    return null;
  }

  bool get _canInteract => !widget.disabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _syncOptionFocusNodes();
  }

  @override
  void didUpdateWidget(covariant AnimalSelect<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOptionFocusNodes();
  }

  void _syncOptionFocusNodes() {
    while (_optionFocusNodes.length < widget.options.length) {
      _optionFocusNodes.add(FocusNode());
    }
    while (_optionFocusNodes.length > widget.options.length) {
      _optionFocusNodes.removeLast().dispose();
    }
  }

  void _focusInitialMenuOption() {
    final int selectedIndex = widget.options.indexWhere(
      (AnimalOption<T> option) =>
          option.value == widget.value && !widget.disabled && !option.disabled,
    );
    final int focusIndex = selectedIndex >= 0
        ? selectedIndex
        : widget.options.indexWhere(
            (AnimalOption<T> option) => !widget.disabled && !option.disabled,
          );
    if (focusIndex < 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          _controller.isOpen &&
          focusIndex < _optionFocusNodes.length) {
        _optionFocusNodes[focusIndex].requestFocus();
      }
    }, debugLabel: 'AnimalSelect.focusInitialOption');
  }

  @override
  void dispose() {
    for (final FocusNode focusNode in _optionFocusNodes) {
      focusNode.dispose();
    }
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _handleOptionSelected(T val) {
    _controller.close();
    widget.onChanged?.call(val);
  }

  void _handleClear() {
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final localizations = AnimalLocalizations.of(context)!;
    final selected = _selectedOption;
    final hasValue = selected != null;

    final inputBg = widget.disabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceHeader
              : theme.colors.bgInputDisabled)
        : theme.colors.bgInput;

    return MenuAnchor(
      controller: _controller,
      childFocusNode: _effectiveFocusNode,
      onOpen: _focusInitialMenuOption,
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(theme.colors.bgContent),
        elevation: const WidgetStatePropertyAll<double>(4.0),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List<Widget>.generate(widget.options.length, (index) {
              final opt = widget.options[index];
              final isOptSelected = opt.value == widget.value;
              return _SelectMenuOption<T>(
                option: opt,
                selected: isOptSelected,
                disabled: widget.disabled || opt.disabled,
                theme: theme,
                focusNode: _optionFocusNodes[index],
                onPressed: () => _handleOptionSelected(opt.value),
              );
            }),
          ),
        ),
      ],
      builder: (context, controller, child) {
        final focusActive = _isFocused || controller.isOpen;
        Color borderColor = theme.colors.border;
        Color? focusGlowColor;

        if (widget.disabled) {
          borderColor = (theme.colors.brightness == Brightness.dark)
              ? theme.colors.border.withValues(alpha: 0.3)
              : theme.colors.borderLight;
        } else if (widget.status == AnimalInputStatus.error) {
          borderColor = theme.colors.errorText;
          focusGlowColor = theme.colors.errorText.withValues(alpha: 0.45);
        } else if (focusActive) {
          borderColor = theme.colors.focusYellow;
          focusGlowColor = theme.colors.focusYellow.withValues(alpha: 0.45);
        }

        return Row(
          children: [
            Expanded(
              child: InteractiveRegion(
                onPressed: _canInteract
                    ? () {
                        controller.isOpen
                            ? controller.close()
                            : controller.open();
                      }
                    : null,
                enableHaptics: false,
                disabled: !_canInteract,
                focusNode: _effectiveFocusNode,
                semanticLabel:
                    selected?.label ??
                    widget.placeholder ??
                    localizations.selectPlaceholder,
                borderRadius: theme.radii.pillBorder,
                surfaceColor: inputBg,
                border: Border.all(color: borderColor, width: 1.8),
                extraShadows: focusActive || focusGlowColor != null
                    ? [
                        BoxShadow(
                          color:
                              focusGlowColor ??
                              theme.colors.focusYellow.withValues(alpha: 0.45),
                          offset: Offset.zero,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
                padding: EdgeInsets.symmetric(horizontal: theme.spacing.lg),
                onFocusChanged: (focused) =>
                    setState(() => _isFocused = focused),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected?.label ??
                            widget.placeholder ??
                            localizations.selectPlaceholder,
                        style: theme.typography.body.copyWith(
                          color: widget.disabled
                              ? theme.colors.textDisabled
                              : (hasValue
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
                        color: widget.disabled
                            ? theme.colors.textDisabled
                            : theme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.allowClear && hasValue && !widget.disabled)
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

  const _SelectMenuOption({
    required this.option,
    required this.selected,
    required this.disabled,
    required this.theme,
    required this.focusNode,
    required this.onPressed,
  });

  @override
  State<_SelectMenuOption<T>> createState() => _SelectMenuOptionState<T>();
}

class _SelectMenuOptionState<T> extends State<_SelectMenuOption<T>> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final background = widget.selected
        ? theme.colors.primary.withValues(alpha: 0.12)
        : (_isHovered || _isFocused
              ? theme.colors.primary.withValues(alpha: 0.06)
              : Colors.transparent);

    return InteractiveRegion(
      onPressed: widget.disabled ? null : widget.onPressed,
      focusNode: widget.focusNode,
      disabled: widget.disabled,
      focusOnHover: true,
      enableHaptics: false,
      semanticButton: false,
      selected: widget.selected,
      semanticsBuilder: (enabled, visible, activate) => SemanticsProperties(
        role: SemanticsRole.menuItem,
        enabled: enabled,
        hidden: !visible,
        label: widget.option.label,
        selected: widget.selected,
        onTap: activate,
      ),
      surfaceColor: background,
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.lg,
        vertical: theme.spacing.sm,
      ),
      onFocusChanged: (focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.option.icon != null) ...[
              ExcludeSemantics(child: widget.option.icon!),
              SizedBox(width: theme.spacing.sm),
            ],
            Text(
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
            ),
            if (widget.selected) ...[
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
