import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/input_theme.dart';
import '../../foundation/theme/components/style_values.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/interaction/icon_action.dart';
import '../../internal/interaction/field_status.dart';
import '../../icons/icon.dart';
import '../../icons/icons.g.dart';

/// Semantic status for [AnimalInput].
enum AnimalInputStatus { normal, warning, error }

/// Size presets for [AnimalInput].
///
/// A preset names a step; its metrics come from the active theme. See
/// [AnimalInputStyle] for the values a theme or a single input can override.
enum AnimalInputSize { small, middle, large }

/// Animal Island Pill Input Field (C12).
///
/// Features:
/// - Pill shape from `theme.radii.pill`
/// - The library focus color on the focused border
/// - Visual overrides through [style] and `AnimalIslandTheme.components.input`
/// - One caller-owned editing buffer borrowed for this input's lifetime
/// - 3D tactile depth shadow when [shadow] is enabled
/// - Accessible clear button with keyboard Enter / Space activation
class AnimalInput extends StatefulWidget {
  /// The caller-owned text and editing state shown by this input.
  ///
  /// The input listens to but never disposes this controller.
  final TextEditingController controller;

  /// The placeholder hint text displayed when empty.
  final String? placeholder;

  /// Visual size tier.
  final AnimalInputSize size;

  /// Overrides for this input, taking precedence over the theme.
  final AnimalInputStyle? style;

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
    required this.controller,
    this.placeholder,
    this.size = AnimalInputSize.middle,
    this.style,
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
  });

  @override
  State<AnimalInput> createState() => _AnimalInputState();
}

class _AnimalInputState extends State<AnimalInput> {
  FocusNode? _internalFocusNode;
  TextEditingController? _listenedController;
  FocusNode? _listenedFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _listenToFocusNode(_effectiveFocusNode);
    _listenToController(widget.controller);
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
    if (!identical(widget.controller, _listenedController)) {
      _listenedController?.removeListener(_handleControllerChange);
      _listenToController(widget.controller);
    }
  }

  void _listenToController(TextEditingController controller) {
    _listenedController = controller;
    controller.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    if (mounted) setState(() {});
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
    _listenedController?.removeListener(_handleControllerChange);
    _listenedController = null;
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final effectiveStatus = widget.status;
    final _ResolvedInputStyle resolved = _ResolvedInputStyle.resolve(
      theme: theme,
      size: widget.size,
      style: widget.style,
      status: effectiveStatus,
      disabled: widget.disabled,
      focused: _isFocused,
    );
    final Color borderColor = resolved.borderColor;

    final shadows = <BoxShadow>[
      if (widget.shadow && !widget.disabled) resolved.depthShadow,
      if (resolved.glow case final BoxShadow glow) glow,
    ];

    final bool showClearAction =
        widget.clearable &&
        widget.controller.text.isNotEmpty &&
        !widget.disabled &&
        !widget.readOnly;

    return AnimatedContainer(
      duration: theme.motion.fast,
      curve: theme.motion.ease,
      constraints: BoxConstraints(minHeight: resolved.minHeight),
      decoration: BoxDecoration(
        color: resolved.backgroundColor,
        borderRadius: widget.maxLines == 1
            ? resolved.borderRadius
            : resolved.multilineBorderRadius,
        border: Border.all(color: borderColor, width: resolved.borderWidth),
        boxShadow: shadows,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: resolved.horizontalPadding,
        vertical: widget.maxLines == 1 ? 0 : resolved.multilineVerticalPadding,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int boundedAdornmentCount =
              (widget.prefix == null ? 0 : 1) + (widget.suffix == null ? 0 : 1);
          final int gapCount =
              boundedAdornmentCount + (showClearAction ? 1 : 0);
          final double clearWidth = showClearAction
              ? animalIconActionWidth(
                  iconSize: resolved.clearIconSize,
                  padding: resolved.clearButtonPadding,
                  textDirection: Directionality.of(context),
                )
              : 0.0;
          final double minimumEditorWidth = resolved.fontSize * 4;
          final double maxAdornmentWidth = boundedAdornmentCount == 0
              ? 0
              : math.min(
                  constraints.maxWidth * 0.25,
                  math.max(
                    0,
                    (constraints.maxWidth -
                            minimumEditorWidth -
                            clearWidth -
                            resolved.adornmentGap * gapCount) /
                        boundedAdornmentCount,
                  ),
                );

          Widget boundedAdornment(Widget child) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxAdornmentWidth),
            child: child,
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.prefix != null) ...[
                boundedAdornment(widget.prefix!),
                SizedBox(width: resolved.adornmentGap),
              ],
              Expanded(
                child: Semantics(
                  validationResult: effectiveStatus == AnimalInputStatus.error
                      ? SemanticsValidationResult.invalid
                      : SemanticsValidationResult.none,
                  child: TextField(
                    controller: widget.controller,
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
                    },
                    onSubmitted: (text) {
                      widget.onSubmitted?.call(text);
                    },
                    style: resolved.textStyle,
                    cursorColor: resolved.cursorColor,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: widget.placeholder,
                      hintStyle: resolved.hintStyle,
                    ),
                  ),
                ),
              ),
              if (showClearAction) ...[
                SizedBox(width: resolved.adornmentGap),
                AnimalIconAction(
                  onPressed: () {
                    widget.controller.clear();
                    widget.onChanged?.call('');
                  },
                  semanticLabel: AnimalLocalizations.of(context)!
                      .inputClearLabel,
                  padding: resolved.clearButtonPadding,
                  borderRadius: resolved.clearButtonBorderRadius,
                  backgroundColor: resolved.clearButtonBackgroundColor,
                  icon: AnimalIcon(
                    data: AnimalIcons.close,
                    size: resolved.clearIconSize,
                    color: resolved.clearIconColor,
                  ),
                ),
              ],
              if (widget.suffix != null) ...[
                SizedBox(width: resolved.adornmentGap),
                boundedAdornment(widget.suffix!),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// The one place [AnimalInput] turns its layers into concrete values.
///
/// Precedence: the input's own style, then the theme's size-specific style,
/// then the theme's general style, then defaults derived from theme tokens.
class _ResolvedInputStyle {
  final double minHeight;
  final double horizontalPadding;
  final double adornmentGap;
  final double multilineVerticalPadding;
  final EdgeInsetsGeometry clearButtonPadding;
  final BorderRadius clearButtonBorderRadius;
  final WidgetStateProperty<Color> clearButtonBackgroundColor;
  final double clearIconSize;
  final TextStyle textStyle;
  final double fontSize;
  final TextStyle hintStyle;
  final Color backgroundColor;
  final Color borderColor;

  /// Focus or status glow; null when the field has none.
  final BoxShadow? glow;
  final Color cursorColor;
  final Color clearIconColor;
  final double borderWidth;
  final BorderRadius borderRadius;
  final BorderRadius multilineBorderRadius;
  final BoxShadow depthShadow;

  const _ResolvedInputStyle._({
    required this.minHeight,
    required this.horizontalPadding,
    required this.adornmentGap,
    required this.multilineVerticalPadding,
    required this.clearButtonPadding,
    required this.clearButtonBorderRadius,
    required this.clearButtonBackgroundColor,
    required this.clearIconSize,
    required this.textStyle,
    required this.fontSize,
    required this.hintStyle,
    required this.backgroundColor,
    required this.borderColor,
    required this.glow,
    required this.cursorColor,
    required this.clearIconColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.multilineBorderRadius,
    required this.depthShadow,
  });

  /// Default metrics per size. Font sizes scale `typography.body` by these
  /// registered ratios, so the standard 14 logical-pixel body gives 13/15/17.
  static ({
    double minHeight,
    double padding,
    double clearIconSize,
    double factor,
  })
  _metrics(AnimalInputSize size) => switch (size) {
    AnimalInputSize.small => (
      minHeight: 34,
      padding: 14,
      clearIconSize: 14,
      factor: 13 / 14,
    ),
    AnimalInputSize.middle => (
      minHeight: 44,
      padding: 18,
      clearIconSize: 16,
      factor: 15 / 14,
    ),
    AnimalInputSize.large => (
      minHeight: 52,
      padding: 22,
      clearIconSize: 18,
      factor: 17 / 14,
    ),
  };

  static _ResolvedInputStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalInputSize size,
    required AnimalInputStyle? style,
    required AnimalInputStatus status,
    required bool disabled,
    required bool focused,
  }) {
    final AnimalInputThemeData? themed = theme.components.input;
    final AnimalInputStyle? sized = switch (size) {
      AnimalInputSize.small => themed?.smallStyle,
      AnimalInputSize.middle => themed?.middleStyle,
      AnimalInputSize.large => themed?.largeStyle,
    };
    final AnimalInputStyle merged = (style ?? AnimalInputStyle())
        .merge(sized)
        .merge(themed?.style);

    final colors = theme.colors;
    final bool dark = colors.brightness == Brightness.dark;
    final Set<WidgetState> states = <WidgetState>{
      if (disabled) WidgetState.disabled,
      if (focused) WidgetState.focused,
      if (status == AnimalInputStatus.error) WidgetState.error,
    };
    final metrics = _metrics(size);

    final AnimalFieldTriggerStatus trigger = resolveFieldTriggerStatus(
      theme: theme,
      states: states,
      warning: status == AnimalInputStatus.warning,
      borderColor: merged.borderColor,
      warningColor: merged.warningColor,
      glowColor: merged.glowColor,
    );

    final TextStyle baseText = theme.typography.resolve(
      theme.typography.body
          .apply(fontSizeFactor: metrics.factor)
          .merge(merged.textStyle),
    );
    final TextStyle textStyle = baseText.copyWith(
      color:
          merged.textColor?.resolve(states) ??
          (disabled ? colors.textDisabled : colors.text),
    );
    final double fontSize = AnimalStyleValues.fontSizeOf(textStyle);
    final TextStyle hintStyle = baseText
        .copyWith(
          fontWeight: FontWeight.w400,
          // One logical pixel smaller, but never below half the text size.
          fontSize: math.max(fontSize - 1, fontSize / 2),
        )
        .merge(merged.placeholderTextStyle)
        .copyWith(
          color:
              merged.placeholderTextColor?.resolve(states) ??
              (disabled ? colors.textDisabled : colors.textSecondary),
        );

    return _ResolvedInputStyle._(
      minHeight: merged.minHeight ?? metrics.minHeight,
      horizontalPadding: merged.horizontalPadding ?? metrics.padding,
      adornmentGap: merged.adornmentGap ?? theme.spacing.sm,
      multilineVerticalPadding:
          merged.multilineVerticalPadding ?? theme.spacing.sm,
      clearButtonPadding:
          merged.clearButtonPadding ??
          EdgeInsets.symmetric(horizontal: theme.spacing.xs),
      clearButtonBorderRadius:
          merged.clearButtonBorderRadius ?? theme.radii.pillBorder,
      clearButtonBackgroundColor: resolveIconActionBackground(
        merged.clearButtonBackgroundColor,
        idle: const Color(0x00000000),
        hovered: const Color(0x00000000),
      ),
      clearIconSize: merged.clearIconSize ?? metrics.clearIconSize,
      textStyle: textStyle,
      fontSize: fontSize,
      hintStyle: hintStyle,
      backgroundColor:
          merged.backgroundColor?.resolve(states) ??
          (disabled
              ? (dark ? colors.surfaceHeader : colors.bgInputDisabled)
              : colors.bgInput),
      borderColor: trigger.border,
      glow: trigger.glow,
      cursorColor: merged.cursorColor ?? colors.text,
      clearIconColor: merged.clearIconColor ?? colors.textSecondary,
      borderWidth: merged.borderWidth ?? 1.8,
      borderRadius: merged.borderRadius ?? theme.radii.pillBorder,
      multilineBorderRadius:
          merged.multilineBorderRadius ?? theme.radii.tooltipBorder,
      depthShadow: merged.depthShadow ?? theme.shadows.input3d,
    );
  }
}
