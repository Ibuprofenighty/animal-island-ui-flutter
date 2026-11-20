import '../foundation/localizations.dart';
import '../foundation/recipes/input.dart';
import '../foundation/theme.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../foundation/field_status.dart';
import '../foundation/size.dart';
import '../internal/action_surface.dart';
import '../internal/choice_control.dart';
import '../internal/focus_outline.dart';

class IslandTextField extends StatefulWidget {
  const IslandTextField({
    super.key,
    required this.label,
    this.controller,
    this.focusNode,
    this.hint,
    this.helper,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.size = IslandSize.middle,
    this.shadow = false,
    this.allowClear = false,
    this.prefix,
    this.suffix,
    this.status = IslandFieldStatus.normal,
    this.showLabel = true,
  });
  final String label;
  final String? hint, helper;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged, onSubmitted;
  final bool enabled, readOnly, obscureText, shadow, allowClear, showLabel;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final AutovalidateMode autovalidateMode;
  final IslandSize size;
  final IslandFieldStatus status;
  final Widget? prefix, suffix;
  @override
  State<IslandTextField> createState() => _IslandTextFieldState();
}

class _IslandTextFieldState extends State<IslandTextField> {
  bool _hovered = false;
  TextEditingController? _owned;
  FocusNode? _ownedFocus;
  FocusNode get focus => widget.focusNode ?? _ownedFocus!;
  late final String initialText;
  TextEditingController get editing => widget.controller ?? _owned!;
  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _owned = TextEditingController();
    initialText = editing.text;
    if (widget.focusNode == null) _ownedFocus = FocusNode();
    focus.addListener(_changed);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant IslandTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownedFocus!).removeListener(_changed);
      _ownedFocus?.dispose();
      _ownedFocus = widget.focusNode == null ? FocusNode() : null;
      focus.addListener(_changed);
    }
    if (old.controller != widget.controller) {
      final previous = old.controller?.value ?? _owned!.value;
      _owned?.dispose();
      _owned = widget.controller == null
          ? TextEditingController.fromValue(previous)
          : null;
    }
  }

  @override
  void dispose() {
    focus.removeListener(_changed);
    _ownedFocus?.dispose();
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _InputField(
    controller: editing,
    initialValue: initialText,
    validator: widget.validator,
    enabled: widget.enabled,
    autovalidateMode: widget.autovalidateMode,
    onChanged: widget.onChanged,
    builder: (field) => buildField(context, field),
  );

  Widget buildField(BuildContext context, FormFieldState<String> field) {
    final tokens = IslandTheme.of(context);
    final font = switch (widget.size) {
      IslandSize.small => 12.0,
      IslandSize.middle => 14.0,
      IslandSize.large => 16.0,
    };
    final padding = switch (widget.size) {
      IslandSize.small => 14.0,
      IslandSize.middle => 18.0,
      IslandSize.large => 22.0,
    };
    final targetHeight = switch (widget.size) {
      IslandSize.small => 32.0,
      IslandSize.middle => 40.0,
      IslandSize.large => 48.0,
    };
    const lineHeight = 1.5715;
    const disabledText = InputColors.disabledText;
    final colors = InputColors.of(context, tokens);
    final errorColor = colors.error;
    final warningColor = colors.warning;
    final borderColor = field.hasError
        ? errorColor
        : switch (widget.status) {
            IslandFieldStatus.error => errorColor,
            IslandFieldStatus.warning => warningColor,
            IslandFieldStatus.normal => tokens.outline,
          };
    final statusColor = field.hasError
        ? errorColor
        : switch (widget.status) {
            IslandFieldStatus.error => errorColor,
            IslandFieldStatus.warning => warningColor,
            IslandFieldStatus.normal => null,
          };
    // Reference `.wrapper` shadow: status fields always carry a 3px status
    // bar (`.wrapper-error/-warning` win over `.wrapper-no-shadow`); a
    // `shadow` field draws 2/3/4px by size and a 3px darker bar on hover.
    final (Color, double)? bar = !widget.enabled
        ? null
        : statusColor != null
        ? (statusColor, 3)
        : !widget.shadow
        ? null
        : _hovered
        ? (colors.barHover, 3)
        : (
            colors.bar,
            switch (widget.size) {
              IslandSize.small => 2.0,
              IslandSize.middle => 3.0,
              IslandSize.large => 4.0,
            },
          );
    final reduced = MediaQuery.disableAnimationsOf(context);
    final field0 = Container(
      foregroundDecoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: widget.enabled
              ? BorderSide(
                  color: field.hasError
                      ? errorColor
                      : focus.hasFocus
                      ? tokens.focus
                      : borderColor,
                  width: focus.hasFocus ? 2 : 1,
                )
              : BorderSide.none,
        ),
      ),
      decoration: BoxDecoration(
        color: widget.enabled ? tokens.inputSurface : InputColors.disabledFill,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextField(
        controller: editing,
        focusNode: focus,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        maxLines: widget.maxLines,
        textAlignVertical: TextAlignVertical.center,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        style: TextStyle(
          fontSize: font,
          fontWeight: FontWeight.w500,
          height: lineHeight,
          letterSpacing: font * .01,
          color: widget.enabled ? tokens.ink : disabledText,
        ),
        decoration: InputDecoration(
          visualDensity: VisualDensity.standard,
          constraints: BoxConstraints(minHeight: targetHeight),
          isDense: true,
          filled: false,
          hint: widget.hint == null
              ? null
              : ExcludeSemantics(
                  child: Text(
                    widget.hint!,
                    maxLines: widget.maxLines,
                    softWrap: widget.maxLines != 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: font,
                      height: lineHeight,
                      letterSpacing: font * .01,
                      color: widget.enabled ? tokens.muted : disabledText,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
          hintFadeDuration: Duration.zero,
          hintStyle: TextStyle(
            fontSize: font,
            color: widget.enabled ? tokens.muted : disabledText,
            fontWeight: FontWeight.w400,
          ),
          // Wrapper padding plus the reference input's 2px UA inline padding.
          contentPadding: EdgeInsetsDirectional.symmetric(
            horizontal: padding + 2,
            vertical: (targetHeight - (font * lineHeight).roundToDouble()) / 2,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          prefixIcon: widget.prefix == null
              ? null
              : Padding(
                  padding: EdgeInsetsDirectional.only(start: padding, end: 6),
                  child: widget.prefix,
                ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon:
              (widget.suffix != null ||
                  (widget.allowClear &&
                      editing.text.isNotEmpty &&
                      !widget.readOnly &&
                      widget.enabled))
              ? Padding(
                  padding: EdgeInsetsDirectional.only(end: padding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.allowClear &&
                          editing.text.isNotEmpty &&
                          !widget.readOnly &&
                          widget.enabled)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 4),
                          child: ActionSurface(
                            label: IslandLocalizations.of(context).clear,
                            onActivate: () {
                              editing.clear();
                              widget.onChanged?.call('');
                            },
                            // Reference `.clear`: 150ms hover background;
                            // focus-visible 2px outline, offset 1px.
                            // The focus ring itself switches atomically.
                            builder: (_, states) => Container(
                              foregroundDecoration: FocusOutline(
                                const CircleBorder(),
                                states.contains(WidgetState.focused)
                                    ? tokens.ink
                                    : Colors.transparent,
                                width: 2,
                                offset: 1,
                              ),
                              child: AnimatedContainer(
                                duration: reduced
                                    ? Duration.zero
                                    : const Duration(milliseconds: 150),
                                width: 20,
                                height: 20,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: states.contains(WidgetState.hovered)
                                      ? tokens.ink.withValues(alpha: .1)
                                      : tokens.ink.withValues(alpha: 0),
                                ),
                                child: ExcludeSemantics(
                                  child: Text(
                                    '×',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          states.contains(WidgetState.hovered)
                                          ? tokens.ink
                                          : tokens.muted,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.suffix != null)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(start: 6),
                          child: widget.suffix!,
                        ),
                    ],
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
      ),
    );
    // The bar is a separate decorative layer under the opaque fill, so only
    // the shadow eases (reference `transition: all .25s`); fill, border and
    // text stay atomic. A status bar appears without interpolation.
    final input = MouseRegion(
      cursor: widget.enabled ? MouseCursor.defer : SystemMouseCursors.forbidden,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Opacity(
        opacity: widget.enabled ? 1 : .6,
        child: AnimatedContainer(
          duration: reduced || statusColor != null
              ? Duration.zero
              : const Duration(milliseconds: 250),
          curve: const Cubic(.4, 0, .2, 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: bar?.$1 ?? tokens.outline.withValues(alpha: 0),
                offset: Offset(0, bar?.$2 ?? 0),
              ),
            ],
          ),
          child: field0,
        ),
      ),
    );
    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabel) ...[
            ExcludeSemantics(
              child: ColoredBox(
                color: tokens.paper,
                child: Text(widget.label, style: TextStyle(color: tokens.ink)),
              ),
            ),
            const SizedBox(height: 8),
          ],
          input,
          if (field.errorText != null || widget.helper != null)
            ColoredBox(
              color: tokens.paper,
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(padding, 4, padding, 0),
                child: Semantics(
                  liveRegion: field.hasError,
                  child: Text(
                    field.errorText ?? widget.helper!,
                    maxLines: 3,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: field.hasError ? tokens.dangerText : tokens.muted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Form owns validation; this adapter synchronizes the single borrowed controller.
class _InputField extends FormField<String> {
  _InputField({
    required this.controller,
    required super.initialValue,
    required super.validator,
    required super.enabled,
    required super.autovalidateMode,
    required this.onChanged,
    required super.builder,
  });
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  @override
  FormFieldState<String> createState() => _InputFieldState();
}

class _InputFieldState extends FormFieldState<String> {
  _InputField get input => widget as _InputField;
  @override
  void initState() {
    super.initState();
    input.controller.addListener(sync);
  }

  void sync() {
    if (input.controller.text != value) didChange(input.controller.text);
  }

  @override
  void didUpdateWidget(_InputField old) {
    super.didUpdateWidget(old);
    if (old.controller != input.controller) {
      old.controller.removeListener(sync);
      input.controller.addListener(sync);
      setValue(input.controller.text);
    }
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (input.controller.text != value)
      input.controller.value = TextEditingValue(text: value ?? '');
  }

  @override
  void reset() {
    input.controller.value = TextEditingValue(text: widget.initialValue ?? '');
    super.reset();
    input.onChanged?.call(input.controller.text);
  }

  @override
  void dispose() {
    input.controller.removeListener(sync);
    super.dispose();
  }
}

class IslandCheckbox extends StatelessWidget {
  const IslandCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.size = IslandSize.middle,
  });
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final IslandSize size;
  @override
  Widget build(BuildContext context) => ChoiceControl(
    label: label,
    checked: value,
    size: size,
    onActivate: onChanged == null ? null : () => onChanged!(!value),
  );
}

class IslandSwitch extends StatelessWidget {
  const IslandSwitch({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.small = false,
    this.busy = false,
    this.checkedLabel,
    this.uncheckedLabel,
    this.showLabel = true,
  });
  final String label;
  final bool value, small, busy, showLabel;
  final ValueChanged<bool>? onChanged;
  final String? checkedLabel, uncheckedLabel;
  @override
  Widget build(BuildContext context) {
    final h = small ? 20.0 : 28.0;
    final w = small ? 38.0 : 52.0;
    final thumb = small ? 14.0 : 21.0;
    final text = (value ? checkedLabel : uncheckedLabel) ?? '';
    final border = IslandTheme.borderWidth(context, 2.5);
    final reduced = MediaQuery.disableAnimationsOf(context);
    final duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 250);
    const curve = Cubic(.4, 0, .2, 1);
    return ActionSurface(
      button: false,
      toggled: value,
      label: label,
      onActivate: busy || onChanged == null ? null : () => onChanged!(!value),
      builder: (_, states) {
        final hover =
            !busy && onChanged != null && states.contains(WidgetState.hovered);
        // Reference `.switch-loading { opacity: .7 }` wins over
        // `.switch-disabled { opacity: .5 }`. Disabled dims the whole group
        // (exempt). Busy dims only the track decoration and thumb, composited
        // over the reference #f8f8f0 page so the opaque in-track text keeps
        // its readable backing on any host; the text itself never dims.
        final decorationOpacity = busy ? .7 : 1.0;
        return ExcludeSemantics(
          child: Opacity(
            opacity: !busy && onChanged == null ? .5 : 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: BoxConstraints(minWidth: w),
                  height: h,
                  foregroundDecoration: FocusOutline(
                    const StadiumBorder(),
                    states.contains(WidgetState.focused)
                        ? IslandTheme.of(context).focus
                        : Colors.transparent,
                    width: 2,
                    offset: 2,
                  ),
                  child: Stack(
                    fit: StackFit.passthrough,
                    children: [
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: const StadiumBorder(),
                            color: busy
                                ? SwitchColors.busyBase
                                : Colors.transparent,
                          ),
                          child: Opacity(
                            opacity: decorationOpacity,
                            // Track fill/border ease with the reference
                            // `transition: all .25s`; every intermediate
                            // border keeps the 3:1 boundary. The focus ring
                            // above switches atomically.
                            child: AnimatedContainer(
                              duration: duration,
                              curve: curve,
                              decoration: BoxDecoration(
                                color: value
                                    ? (hover
                                          ? SwitchColors.trackOnHover
                                          : SwitchColors.trackOn)
                                    : SwitchColors.trackOff,
                                borderRadius: BorderRadius.circular(50),
                                // Unchecked rest: reference #c4b89e (1.8:1)
                                // OKLCH-deepened in hue to the 3:1 boundary
                                // #978b73; hover darkens to muted. Checked
                                // keeps the darkest onLeaf boundary; its
                                // hover delta is the fill.
                                border: Border.all(
                                  color: value
                                      ? IslandTokens.light.onLeaf
                                      : hover
                                      ? IslandTokens.light.muted
                                      : SwitchColors.trackOffBorder,
                                  width: border,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(border),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: value
                                    ? (small ? 6 : 8)
                                    : (small ? 20 : 28),
                                right: value
                                    ? (small ? 20 : 28)
                                    : (small ? 6 : 8),
                              ),
                              child: SizedBox(
                                height: h - border * 2,
                                child: Center(
                                  widthFactor: 1,
                                  child: Text(
                                    text,
                                    softWrap: false,
                                    style: TextStyle(
                                      fontSize: small ? 9 : 11,
                                      height: 1,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: (small ? 9 : 11) * .02,
                                      color: IslandTokens.light.onLeaf,
                                      shadows: const [
                                        Shadow(
                                          color: SwitchColors.textShadow,
                                          offset: Offset(0, 1),
                                          blurRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: small ? 1 : 2,
                                  right: small ? 2 : 3,
                                ),
                                child: AnimatedAlign(
                                  duration: duration,
                                  curve: curve,
                                  alignment: value
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Opacity(
                                    opacity: decorationOpacity,
                                    child: AnimatedContainer(
                                      duration: duration,
                                      curve: curve,
                                      width: thumb,
                                      height: thumb,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: SwitchColors.thumb,
                                        // Reference `.handle` #c4b89e /
                                        // checked #6fba2c, each deepened in
                                        // hue to 3:1 on the thumb fill.
                                        border: Border.all(
                                          color: value
                                              ? SwitchColors.thumbBorderOn
                                              : SwitchColors.thumbBorderOff,
                                          width: border,
                                        ),
                                      ),
                                      child: busy
                                          ? OverflowBox(
                                              minWidth: 11,
                                              maxWidth: 11,
                                              minHeight: 11,
                                              maxHeight: 11,
                                              child: _SwitchSpinner(
                                                checked: value,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Flexible(child: Text(label)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SwitchSpinner extends StatefulWidget {
  const _SwitchSpinner({required this.checked});
  final bool checked;
  @override
  State<_SwitchSpinner> createState() => _SwitchSpinnerState();
}

class _SwitchSpinnerState extends State<_SwitchSpinner>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      motion.stop();
      motion.value = 0;
    } else if (!motion.isAnimating) {
      motion.repeat();
    }
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
    turns: motion,
    child: CustomPaint(
      size: const Size.square(11),
      painter: _SwitchRing(
        widget.checked ? SwitchColors.spinnerOn : SwitchColors.spinnerOff,
      ),
    ),
  );
}

class _SwitchRing extends CustomPainter {
  const _SwitchRing(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawArc(
      (Offset.zero & size).deflate(1),
      math.pi / 4,
      math.pi * 1.5,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SwitchRing old) => old.color != color;
}
