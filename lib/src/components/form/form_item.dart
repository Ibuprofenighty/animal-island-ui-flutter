import 'package:flutter/material.dart';

import '../../foundation/forms/animal_field_binding.dart';
import '../../foundation/forms/animal_field_key.dart';
import '../../foundation/forms/animal_validation_issue.dart';
import '../../foundation/localization/animal_validation_issue_formatter.dart';
import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/form/form_scope.dart';
import 'form_controller.dart';
import 'validation.dart';

/// Form field layout and accessibility wrapper backed by one live registration.
class AnimalFormItem<T> extends StatefulWidget {
  final AnimalFieldKey<T> fieldKey;
  final String? label;
  final Widget? labelWidget;
  final String? help;
  final bool required;
  final List<AnimalRule<T>>? rules;
  final T? initialValue;

  /// Explicit text-field opt-in. The caller retains ownership of this buffer.
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final Widget Function(BuildContext context, AnimalFieldBinding<T> binding)
  builder;
  final EdgeInsetsGeometry? margin;

  const AnimalFormItem({
    super.key,
    required this.fieldKey,
    this.label,
    this.labelWidget,
    this.help,
    this.required = false,
    this.rules,
    this.initialValue,
    this.textController,
    this.focusNode,
    required this.builder,
    this.margin,
  });

  @override
  State<AnimalFormItem<T>> createState() => _AnimalFormItemState<T>();
}

class _AnimalFormItemState<T> extends State<AnimalFormItem<T>> {
  AnimalFormController? _controller;
  AnimalFieldRegistration<T>? _registration;
  FocusNode? _internalFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_internalFocusNode ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AnimalFormScope.maybeOf<AnimalFormController>(context);
    if (scope == null) {
      throw StateError(
        'AnimalFormItem requires an enclosing AnimalForm owner.',
      );
    }
    _validateTextConfiguration(scope);
    final owner = scope.owner;
    if (!identical(_controller, owner) || _registration == null) {
      _unregister();
      _controller = owner;
      _register(owner, scope);
    }
  }

  @override
  void didUpdateWidget(AnimalFormItem<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final scope = AnimalFormScope.maybeOf<AnimalFormController>(context);
    if (scope != null) _validateTextConfiguration(scope);
    final keyChanged =
        oldWidget.fieldKey != widget.fieldKey ||
        oldWidget.fieldKey.runtimeType != widget.fieldKey.runtimeType;
    final textControllerChanged = !identical(
      oldWidget.textController,
      widget.textController,
    );
    if (keyChanged || textControllerChanged) {
      _unregister();
      final scope = AnimalFormScope.maybeOf<AnimalFormController>(context);
      final controller = _controller;
      if (scope == null || controller == null) {
        throw StateError(
          'AnimalFormItem requires an enclosing AnimalForm owner.',
        );
      }
      _register(controller, scope);
      return;
    }

    if (oldWidget.rules != widget.rules ||
        oldWidget.focusNode != widget.focusNode) {
      final controller = _controller;
      final registration = _registration;
      if (controller == null || registration == null) {
        throw StateError('AnimalFormItem has no active field registration.');
      }
      controller.updateFieldRegistration<T>(
        registration,
        rules: widget.rules ?? <AnimalRule<T>>[],
        focusNode: _effectiveFocusNode,
      );
    }
  }

  void _register(
    AnimalFormController controller,
    AnimalFormScope<AnimalFormController> scope,
  ) {
    widget.fieldKey.requireRequestedType(T);
    final textController = widget.textController;
    if (textController != null) {
      _validateTextConfiguration(scope);
      _registration = controller.registerTextField(
        key: widget.fieldKey as AnimalFieldKey<String>,
        textController: textController,
        rules: widget.rules?.cast<AnimalRule<String>>(),
        focusNode: _effectiveFocusNode,
      ) as AnimalFieldRegistration<T>;
      return;
    }

    final initialValue = scope.initialValues.containsKey(widget.fieldKey)
        ? scope.initialValues.valueFor(widget.fieldKey)
        : widget.initialValue;
    _registration = controller.registerField<T>(
      key: widget.fieldKey,
      initialValue: initialValue,
      rules: widget.rules,
      focusNode: _effectiveFocusNode,
    );
  }

  void _validateTextConfiguration(AnimalFormScope<AnimalFormController> scope) {
    if (widget.textController == null) return;
    if (T != String) {
      throw ArgumentError(
        'AnimalFormItem.textController requires AnimalFormItem<String>.',
      );
    }
    if (widget.initialValue != null) {
      throw ArgumentError(
        'Text fields take their initial value from textController.',
      );
    }
    if (scope.initialValues.containsKey(widget.fieldKey)) {
      throw ArgumentError(
        'Form.initialValues cannot initialize a textController field.',
      );
    }
  }

  void _unregister() {
    final controller = _controller;
    final registration = _registration;
    if (controller != null && registration != null) {
      controller.unregisterField<T>(registration);
    }
    _registration = null;
  }

  @override
  void deactivate() {
    // Retain the one record for a GlobalKey reparent; a distinct replacement
    // may take it over with a new generation before this State is disposed.
    _registration?.deactivate();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    final registration = _registration;
    if (registration != null && !registration.activate()) {
      _registration = null;
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
    final registration = _registration;
    if (controller == null || registration == null) {
      throw StateError('AnimalFormItem has no active field registration.');
    }

    return Padding(
      padding: widget.margin ?? EdgeInsets.only(bottom: theme.spacing.lg),
      child: AnimatedBuilder(
        animation: registration,
        builder: (context, _) {
          final binding = controller.bindingFor<T>(registration);
          return _buildItemShell(
            context,
            theme,
            widget.builder(context, binding),
            binding.error,
          );
        },
      ),
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
    if (widget.labelWidget != null) return widget.labelWidget!;

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

    if (!hasError && !hasHelp) return const SizedBox.shrink();

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
