import 'package:flutter/material.dart';
import '../../tokens/colors.dart';
import '../../tokens/radii.dart';
import '../../tokens/shadows.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';
import '../../icons/icon_widget.dart';
import '../form/form.dart';

enum AnimalInputStatus {
  normal,
  warning,
  error,
}

enum AnimalInputSize {
  small(height: 34.0, fontSize: 13.0, padding: 14.0, iconSize: 14.0),
  middle(height: 44.0, fontSize: 15.0, padding: 18.0, iconSize: 16.0),
  large(height: 52.0, fontSize: 17.0, padding: 22.0, iconSize: 18.0);

  final double height;
  final double fontSize;
  final double padding;
  final double iconSize;

  const AnimalInputSize({
    required this.height,
    required this.fontSize,
    required this.padding,
    required this.iconSize,
  });
}

/// Animal Island Pill Input Field.
///
/// Strictly adheres to canonical design laws:
/// - 50px pill shape (`BorderRadius.circular(50)`)
/// - Warm yellow focus ring (`theme.focusYellow`)
/// - Background is `#fffbe7` (warm cream)
/// - Default shadow is `false`. When `shadow: true`, adds 3D tactile depth
/// - Seamless full integration with [AnimalFormItem] blur validation and error shaking
class AnimalInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String? placeholder;
  final AnimalInputSize size;
  final Widget? prefix;
  final Widget? suffix;
  final bool clearable;
  final bool shadow;
  final bool disabled;
  final bool readOnly;
  final bool obscureText;
  final AnimalInputStatus status;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FocusNode? focusNode;

  const AnimalInput({
    super.key,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.size = AnimalInputSize.middle,
    this.prefix,
    this.suffix,
    this.clearable = false,
    this.shadow = false,
    this.disabled = false,
    this.readOnly = false,
    this.obscureText = false,
    this.status = AnimalInputStatus.normal,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.focusNode,
  });

  @override
  State<AnimalInput> createState() => _AnimalInputState();
}

class _AnimalInputState extends State<AnimalInput> {
  late TextEditingController _controller;
  FocusNode? _internalFocusNode;
  FocusNode? _currentFocusNode;
  bool _isFocused = false;
  bool _initializedFromForm = false;

  FocusNode get _effectiveFocusNode {
    final formItem = AnimalFormItemScope.of(context);
    return widget.focusNode ?? formItem?.focusNode ?? (_internalFocusNode ??= FocusNode());
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_handleTextChange);
    if (widget.focusNode != null) {
      _currentFocusNode = widget.focusNode;
      _currentFocusNode!.addListener(_handleFocusChange);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFocusNode();
    final formItem = AnimalFormItemScope.of(context);
    if (widget.controller == null && formItem != null) {
      final formVal = formItem.currentValue?.toString() ?? '';
      if (!_isFocused && _controller.text != formVal) {
        _controller.text = formVal;
        _initializedFromForm = true;
      } else if (!_initializedFromForm && formVal.isNotEmpty && _controller.text.isEmpty) {
        _controller.text = formVal;
        _initializedFromForm = true;
      }
    }
  }

  void _syncFocusNode() {
    final effectiveNode = _effectiveFocusNode;
    if (_currentFocusNode != effectiveNode) {
      _currentFocusNode?.removeListener(_handleFocusChange);
      _currentFocusNode = effectiveNode;
      _currentFocusNode!.addListener(_handleFocusChange);
      _isFocused = _currentFocusNode!.hasFocus;
    }
  }

  @override
  void didUpdateWidget(covariant AnimalInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleTextChange);
      if (oldWidget.controller == null) {
        _controller.removeListener(_handleTextChange);
        _controller.dispose();
      }
      _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
      _controller.addListener(_handleTextChange);
    }
    if (widget.focusNode != oldWidget.focusNode) {
      _syncFocusNode();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _currentFocusNode?.removeListener(_handleFocusChange);
    _internalFocusNode?.dispose();
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChange() {
    if (widget.clearable && mounted) {
      setState(() {});
    }
  }

  void _handleFocusChange() {
    if (mounted) {
      final hasFocus = _currentFocusNode?.hasFocus ?? false;
      setState(() => _isFocused = hasFocus);
      if (!hasFocus) {
        final formItem = AnimalFormItemScope.of(context);
        formItem?.onBlur?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formItem = AnimalFormItemScope.of(context);

    final effectiveStatus = (widget.status == AnimalInputStatus.normal && formItem?.hasError == true)
        ? AnimalInputStatus.error
        : widget.status;

    Color borderColor = theme.isDark ? theme.border : AnimalColors.borderLight;
    Color? focusGlowColor;

    if (effectiveStatus == AnimalInputStatus.error) {
      borderColor = theme.error;
      focusGlowColor = theme.error.withValues(alpha: 0.35);
    } else if (effectiveStatus == AnimalInputStatus.warning) {
      borderColor = theme.warning;
      focusGlowColor = theme.warning.withValues(alpha: 0.4);
    } else if (_isFocused) {
      borderColor = theme.focusYellow;
      focusGlowColor = theme.focusYellow.withValues(alpha: 0.45);
    }

    final shadows = <BoxShadow>[
      if (widget.shadow && !widget.disabled)
        AnimalShadows.input3d,
      if (_isFocused || effectiveStatus != AnimalInputStatus.normal)
        BoxShadow(
          color: focusGlowColor ?? theme.focusYellow.withValues(alpha: 0.45),
          offset: Offset.zero,
          blurRadius: 4,
          spreadRadius: 2,
        ),
    ];

    final inputBg = widget.disabled
        ? (theme.isDark ? theme.surfaceHeader : AnimalColors.bgInputDisabled)
        : theme.bgInput;

    return AnimatedContainer(
      duration: AnimalMotion.fast,
      curve: AnimalMotion.ease,
      height: widget.size.height,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: AnimalRadii.pillBorder,
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: shadows,
      ),
      padding: EdgeInsets.symmetric(horizontal: widget.size.padding),
      alignment: Alignment.center,
      child: Row(
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _effectiveFocusNode,
              enabled: !widget.disabled,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: (text) {
                formItem?.onChanged?.call(text);
                widget.onChanged?.call(text);
              },
              onSubmitted: (text) {
                widget.onSubmitted?.call(text);
                final controller = AnimalForm.of(context);
                controller?.submit();
              },
              style: AnimalTypography.bodyFor(context).copyWith(
                color: widget.disabled ? theme.textDisabled : theme.text,
                fontSize: widget.size.fontSize,
              ),
              cursorColor: theme.text,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: AnimalTypography.bodyFor(context).copyWith(
                  color: theme.textDisabled,
                  fontWeight: FontWeight.w400,
                  fontSize: widget.size.fontSize - 1.0,
                ),
              ),
            ),
          ),
          if (widget.clearable && _controller.text.isNotEmpty && !widget.disabled)
            _InputClearButton(
              iconSize: widget.size.iconSize,
              iconColor: theme.textSecondary,
              onClear: () {
                _controller.clear();
                formItem?.onChanged?.call('');
                widget.onChanged?.call('');
                setState(() {});
              },
            ),
          if (widget.suffix != null) ...[
            const SizedBox(width: 8),
            widget.suffix!,
          ],
        ],
      ),
    );
  }
}

class _InputClearButton extends StatefulWidget {
  final VoidCallback onClear;
  final double iconSize;
  final Color iconColor;

  const _InputClearButton({
    required this.onClear,
    required this.iconSize,
    required this.iconColor,
  });

  @override
  State<_InputClearButton> createState() => _InputClearButtonState();
}

class _InputClearButtonState extends State<_InputClearButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (val) => setState(() => _isFocused = val),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onClear();
            return null;
          },
        ),
      },
      child: Semantics(
        button: true,
        label: 'Clear input',
        child: GestureDetector(
          onTap: widget.onClear,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            decoration: _isFocused
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.focusYellow.withValues(alpha: 0.55),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : null,
            child: CloseIcon(size: widget.iconSize, color: widget.iconColor),
          ),
        ),
      ),
    );
  }
}
