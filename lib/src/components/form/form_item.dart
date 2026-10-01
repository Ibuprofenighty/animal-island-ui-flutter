import 'package:flutter/material.dart';

import '../../foundation/forms/animal_validation_issue.dart';
import '../../foundation/localization/animal_validation_issue_formatter.dart';
import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import 'form.dart';

/// Animal Island Form Item layout and accessibility wrapper (C20).
///
/// Features:
/// - Single field ownership with type safety via [AnimalFieldKey] or string identifier
/// - Accessible error and help text mapping to the underlying input
/// - Smooth animated height and fade transitions for validation error messages
/// - Responsive layout accommodating long Chinese error strings and 200% font scaling
/// - Fine-grained reactive rebuilding strictly isolated to this field
class AnimalFormItem<T> extends StatefulWidget {
  /// Strongly typed field key identifying this item within the parent [AnimalForm].
  final AnimalFieldKey<T>? fieldKey;

  /// String name identifier for the field (alternative to [fieldKey]).
  final String? name;

  /// Form item label text displayed above the control.
  final String? label;

  /// Custom widget label (overrides [label] if specified).
  final Widget? labelWidget;

  /// Explanatory help or caption text displayed below the field when no error exists.
  final String? help;

  /// Whether to display a cute red required indicator (*) next to the label.
  final bool required;

  /// Validation rules evaluated for this field.
  final List<AnimalRule<T>>? rules;

  /// Optional initial value for this field.
  final T? initialValue;

  /// Optional external [FocusNode] to receive focus on validation error.
  final FocusNode? focusNode;

  /// Typed builder function receiving the active [AnimalFieldBinding].
  final Widget Function(BuildContext context, AnimalFieldBinding<T> binding)?
  builder;

  /// Child widget for direct un-bound usage.
  final Widget? child;

  /// Outer margin around the form item. Default is 16dp bottom spacing.
  final EdgeInsetsGeometry? margin;

  const AnimalFormItem({
    super.key,
    this.fieldKey,
    this.name,
    this.label,
    this.labelWidget,
    this.help,
    this.required = false,
    this.rules,
    this.initialValue,
    this.focusNode,
    this.builder,
    this.child,
    this.margin,
  }) : assert(
         fieldKey != null || name != null || (builder == null),
         'AnimalFormItem must have either fieldKey or name when builder is used.',
       );

  @override
  State<AnimalFormItem<T>> createState() => _AnimalFormItemState<T>();
}

class _AnimalFormItemState<T> extends State<AnimalFormItem<T>> {
  AnimalFormController? _controller;
  FocusNode? _internalFocusNode;
  String? _registeredName;

  String get _effectiveName =>
      widget.fieldKey?.name ?? widget.name ?? '_unnamed_$hashCode';

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newController = AnimalForm.maybeOf(context);
    if (_controller != newController) {
      _unregister();
      _controller = newController;
      _register();
    }
  }

  @override
  void didUpdateWidget(AnimalFormItem<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldName = oldWidget.fieldKey?.name ?? oldWidget.name;
    final newName = widget.fieldKey?.name ?? widget.name;
    if (oldName != newName) {
      _unregister();
      _register();
    } else if (widget.rules != oldWidget.rules ||
        widget.focusNode != oldWidget.focusNode) {
      _controller?.registerField<T>(
        name: _effectiveName,
        initialValue: widget.initialValue,
        rules: widget.rules,
        focusNode: _effectiveFocusNode,
      );
    }
  }

  void _register() {
    if (_controller == null) return;
    _registeredName = _effectiveName;
    _controller!.registerField<T>(
      name: _effectiveName,
      initialValue: widget.initialValue,
      rules: widget.rules,
      focusNode: _effectiveFocusNode,
    );
  }

  void _unregister() {
    if (_controller != null && _registeredName != null) {
      _controller!.unregisterField(_registeredName!);
      _registeredName = null;
    }
  }

  @override
  void dispose() {
    _unregister();
    _internalFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final controller = _controller;

    Widget formContent;
    if (controller != null && widget.builder != null) {
      final listenable = controller.getFieldListenable(_effectiveName);
      if (listenable != null) {
        formContent = AnimatedBuilder(
          animation: listenable,
          builder: (context, _) {
            final binding = AnimalFieldBinding<T>(
              name: _effectiveName,
              value: controller.getValue<T>(_effectiveName),
              error: controller.getFieldError(_effectiveName),
              status: controller.getFieldStatus(_effectiveName),
              dirty:
                  controller.getValue<T>(_effectiveName) != widget.initialValue,
              touched: false,
              onChanged: (val) => controller.setValue<T>(_effectiveName, val),
              onBlur: () => controller.touchField(_effectiveName),
              focusNode: _effectiveFocusNode,
            );
            return _buildItemShell(
              context,
              theme,
              widget.builder!(context, binding),
              binding.error,
            );
          },
        );
      } else {
        final dummyBinding = AnimalFieldBinding<T>(
          name: _effectiveName,
          value: widget.initialValue,
          error: null,
          status: AnimalValidationStatus.idle,
          dirty: false,
          touched: false,
          onChanged: (_) {},
          onBlur: () {},
          focusNode: _effectiveFocusNode,
        );
        formContent = _buildItemShell(
          context,
          theme,
          widget.builder!(context, dummyBinding),
          null,
        );
      }
    } else {
      final error = controller?.getFieldError(_effectiveName);
      formContent = _buildItemShell(
        context,
        theme,
        widget.child ?? const SizedBox.shrink(),
        error,
      );
    }

    return Padding(
      padding: widget.margin ?? EdgeInsets.only(bottom: theme.spacing.lg),
      child: formContent,
    );
  }

  Widget _buildItemShell(
    BuildContext context,
    AnimalIslandTheme theme,
    Widget content,
    AnimalValidationIssue? error,
  ) {
    final hasLabel =
        widget.labelWidget != null ||
        (widget.label != null && widget.label!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel) ...[
          _buildLabel(context, theme),
          SizedBox(height: theme.spacing.sm - theme.spacing.xxs),
        ],
        content,
        _buildFeedback(context, theme, error),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, AnimalIslandTheme theme) {
    if (widget.labelWidget != null) {
      return widget.labelWidget!;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.required) ...[
          Text(
            '* ',
            style: theme.typography.body.copyWith(
              color: theme.colors.errorText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        Flexible(
          child: Text(
            widget.label!,
            style: theme.typography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colors.text,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedback(
    BuildContext context,
    AnimalIslandTheme theme,
    AnimalValidationIssue? error,
  ) {
    final errorText = error == null
        ? null
        : AnimalValidationIssueFormatter.format(
            error,
            AnimalLocalizations.of(context)!,
          );
    final hasError = errorText != null && errorText.isNotEmpty;
    final hasHelp = widget.help != null && widget.help!.isNotEmpty;

    if (!hasError && !hasHelp) {
      return const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: theme.motion.fast * (200 / 150),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      child: hasError
          ? Padding(
              key: const ValueKey('form_item_error'),
              padding: EdgeInsets.only(
                top: theme.spacing.sm - theme.spacing.xxs,
              ),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  errorText,
                  style: theme.typography.caption.copyWith(
                    color: theme.colors.errorText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : (hasHelp
                ? Padding(
                    key: const ValueKey('form_item_help'),
                    padding: EdgeInsets.only(
                      top: theme.spacing.sm - theme.spacing.xxs,
                    ),
                    child: Text(
                      widget.help!,
                      style: theme.typography.caption.copyWith(
                        color: theme.colors.textSecondary,
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
    );
  }
}
