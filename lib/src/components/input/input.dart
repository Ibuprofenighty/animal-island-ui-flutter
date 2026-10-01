import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/interactive_region.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

/// Semantic status for [AnimalInput].
enum AnimalInputStatus { normal, warning, error }

/// Sizing scales for [AnimalInput].
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

/// Animal Island Pill Input Field (C12).
///
/// Features:
/// - 50px pill shape (`BorderRadius.circular(50)`)
/// - Warm focus ring (`theme.colors.focusYellow`)
/// - Single controller ownership with mutual exclusion between [controller] and [initialValue]
/// - 3D tactile depth shadow when [shadow] is enabled
/// - Accessible clear button with keyboard Enter / Space activation
class AnimalInput extends StatefulWidget {
  final TextEditingController? controller;

  /// The controlled text value for this input.
  final String? value;

  /// The initial text value for uncontrolled usage.
  final String? initialValue;

  /// The placeholder hint text displayed when empty.
  final String? placeholder;

  /// Visual size tier.
  final AnimalInputSize size;

  /// Leading prefix widget (e.g. icon or text).
  final Widget? prefix;

  /// Trailing suffix widget (e.g. icon, action, or character counter).
  final Widget? suffix;

  /// Whether to display a cute clear button when the input is non-empty.
  final bool clearable;

  /// Whether to apply a subtle bottom shadow depth.
  final bool shadow;

  /// Whether the input is disabled.
  final bool disabled;

  /// Whether the input is read-only.
  final bool readOnly;

  /// Whether text is obscured (for password fields).
  final bool obscureText;

  /// Validation and visual status indicator.
  final AnimalInputStatus status;

  /// Callback triggered whenever the text value changes.
  final ValueChanged<String>? onChanged;

  /// Callback triggered when the user submits (presses action/enter).
  final ValueChanged<String>? onSubmitted;

  /// Soft keyboard type.
  final TextInputType keyboardType;

  /// Keyboard action button type.
  final TextInputAction textInputAction;

  /// External focus node.
  final FocusNode? focusNode;

  /// Whether to focus this input automatically on mount.
  final bool autofocus;

  /// Maximum visible text lines.
  final int? maxLines;

  /// Minimum visible text lines.
  final int? minLines;

  /// Input formatters applied to typed text.
  final List<TextInputFormatter>? inputFormatters;

  const AnimalInput({
    super.key,
    this.controller,
    this.value,
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
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
  }) : assert(
         controller == null || (value == null && initialValue == null),
         'Cannot provide both a controller and value/initialValue to AnimalInput.',
       );

  @override
  State<AnimalInput> createState() => _AnimalInputState();
}

class _AnimalInputState extends State<AnimalInput> {
  TextEditingController? _internalController;
  FocusNode? _internalFocusNode;
  FocusNode? _listenedFocusNode;
  bool _isFocused = false;

  TextEditingController get _effectiveController =>
      widget.controller ??
      (_internalController ??= TextEditingController(
        text: widget.value ?? widget.initialValue,
      ));

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _listenToFocusNode(_effectiveFocusNode);
  }

  @override
  void didUpdateWidget(covariant AnimalInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextFocusNode = _effectiveFocusNode;
    if (!identical(nextFocusNode, _listenedFocusNode)) {
      _listenedFocusNode?.removeListener(_handleFocusChange);
      _listenToFocusNode(nextFocusNode);
      _isFocused = nextFocusNode.hasFocus;
    }
    if (widget.controller == null &&
        widget.value != null &&
        widget.value != oldWidget.value &&
        widget.value != _effectiveController.text) {
      _effectiveController.text = widget.value!;
    }
  }

  void _listenToFocusNode(FocusNode focusNode) {
    _listenedFocusNode = focusNode;
    focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted && _isFocused != _effectiveFocusNode.hasFocus) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _listenedFocusNode?.removeListener(_handleFocusChange);
    _listenedFocusNode = null;
    _internalFocusNode?.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveStatus = widget.status;

    Color borderColor = theme.colors.border;
    Color? focusGlowColor;

    if (widget.disabled) {
      borderColor = (theme.colors.brightness == Brightness.dark)
          ? theme.colors.border.withValues(alpha: 0.3)
          : theme.colors.borderLight;
    } else if (effectiveStatus == AnimalInputStatus.error) {
      borderColor = theme.colors.errorText;
      focusGlowColor = theme.colors.errorText.withValues(alpha: 0.45);
    } else if (effectiveStatus == AnimalInputStatus.warning) {
      borderColor = theme.colors.warningText;
      focusGlowColor = theme.colors.warningText.withValues(alpha: 0.45);
    } else if (_isFocused) {
      borderColor = theme.colors.focusYellow;
      focusGlowColor = theme.colors.focusYellow.withValues(alpha: 0.45);
    }

    final shadows = <BoxShadow>[
      if (widget.shadow && !widget.disabled) theme.shadows.input3d,
      if (_isFocused || effectiveStatus != AnimalInputStatus.normal)
        BoxShadow(
          color:
              focusGlowColor ??
              theme.colors.focusYellow.withValues(alpha: 0.45),
          offset: Offset.zero,
          blurRadius: 4,
          spreadRadius: 2,
        ),
    ];

    final inputBg = widget.disabled
        ? ((theme.colors.brightness == Brightness.dark)
              ? theme.colors.surfaceHeader
              : theme.colors.bgInputDisabled)
        : theme.colors.bgInput;

    return AnimatedContainer(
      duration: theme.motion.fast,
      curve: theme.motion.ease,
      height: widget.maxLines == 1 ? widget.size.height : null,
      decoration: BoxDecoration(
        color: inputBg,
        borderRadius: widget.maxLines == 1
            ? theme.radii.pillBorder
            : theme.radii.tooltipBorder,
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: shadows,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: widget.size.padding,
        vertical: widget.maxLines == 1 ? 0 : theme.spacing.sm,
      ),
      alignment: Alignment.center,
      child: Row(
        children: [
          if (widget.prefix != null) ...[
            widget.prefix!,
            SizedBox(width: theme.spacing.sm),
          ],
          Expanded(
            child: TextField(
              controller: _effectiveController,
              focusNode: _effectiveFocusNode,
              enabled: !widget.disabled,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              autofocus: widget.autofocus,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              inputFormatters: widget.inputFormatters,
              onChanged: (text) {
                widget.onChanged?.call(text);
                setState(() {});
              },
              onSubmitted: (text) {
                widget.onSubmitted?.call(text);
              },
              style: theme.typography.body.copyWith(
                color: widget.disabled
                    ? theme.colors.textDisabled
                    : theme.colors.text,
                fontSize: widget.size.fontSize,
              ),
              cursorColor: theme.colors.text,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: widget.placeholder,
                hintStyle: theme.typography.body.copyWith(
                  color: widget.disabled
                      ? theme.colors.textDisabled
                      : theme.colors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontSize: widget.size.fontSize - 1.0,
                ),
              ),
            ),
          ),
          if (widget.clearable &&
              _effectiveController.text.isNotEmpty &&
              !widget.disabled)
            _InputClearButton(
              iconSize: widget.size.iconSize,
              iconColor: theme.colors.textSecondary,
              onClear: () {
                _effectiveController.clear();
                widget.onChanged?.call('');
                setState(() {});
              },
            ),
          if (widget.suffix != null) ...[
            SizedBox(width: theme.spacing.sm),
            widget.suffix!,
          ],
        ],
      ),
    );
  }
}

class _InputClearButton extends StatelessWidget {
  final VoidCallback onClear;
  final double iconSize;
  final Color iconColor;

  const _InputClearButton({
    required this.onClear,
    required this.iconSize,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    return InteractiveRegion(
      onPressed: onClear,
      enableHaptics: false,
      semanticLabel: AnimalLocalizations.of(context)!.inputClearLabel,
      surfaceColor: Colors.transparent,
      minimumHitSize: 48,
      padding: EdgeInsets.symmetric(horizontal: theme.spacing.xs),
      child: AnimalIcon(
        data: AnimalIcons.close,
        size: iconSize,
        color: iconColor,
      ),
    );
  }
}
