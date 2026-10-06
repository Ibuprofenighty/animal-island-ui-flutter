import 'package:flutter/material.dart';

import '../../foundation/forms/animal_field_binding.dart';
import '../../foundation/forms/animal_field_key.dart';
import '../../foundation/forms/animal_validation_issue.dart';
import '../../foundation/localization/animal_validation_issue_formatter.dart';
import '../../foundation/localization/generated/animal_localizations.g.dart';
import '../../foundation/theme/components/form_item_theme.dart';
import '../../foundation/theme/theme.dart';
import '../../internal/form/form_scope.dart';
import 'form_controller.dart';
import 'validation.dart';

/// Form field layout and accessibility wrapper backed by one live registration.
///
/// Visual overrides come from [style] and `AnimalIslandTheme.components.formItem`;
/// see [AnimalFormItemStyle].
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

  /// Visual overrides for this item; they take precedence over the theme.
  final AnimalFormItemStyle? style;

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
    this.style,
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
    final resolved = _ResolvedFormItemStyle.resolve(
      theme: theme,
      style: widget.style,
    );
    final controller = _controller;
    final registration = _registration;
    if (controller == null || registration == null) {
      throw StateError('AnimalFormItem has no active field registration.');
    }

    return Padding(
      padding: widget.margin ?? EdgeInsets.only(bottom: resolved.bottomMargin),
      child: AnimatedBuilder(
        animation: registration,
        builder: (context, _) {
          final binding = controller.bindingFor<T>(registration);
          return _buildItemShell(
            context,
            resolved,
            widget.builder(context, binding),
            binding.error,
          );
        },
      ),
    );
  }

  Widget _buildItemShell(
    BuildContext context,
    _ResolvedFormItemStyle resolved,
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
          _buildLabel(context, resolved),
          SizedBox(height: resolved.labelGap),
        ],
        content,
        _buildFeedback(context, resolved, error),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, _ResolvedFormItemStyle resolved) {
    if (widget.labelWidget != null) return widget.labelWidget!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.required) ...[
          Text('* ', style: resolved.requiredMarkTextStyle),
        ],
        Flexible(child: Text(widget.label!, style: resolved.labelTextStyle)),
      ],
    );
  }

  Widget _buildFeedback(
    BuildContext context,
    _ResolvedFormItemStyle resolved,
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
      duration: resolved.feedbackDuration,
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
              padding: EdgeInsets.only(top: resolved.feedbackGap),
              child: Semantics(
                liveRegion: true,
                child: Text(errorText, style: resolved.errorTextStyle),
              ),
            )
          : (hasHelp
                ? Padding(
                    key: const ValueKey('form_item_help'),
                    padding: EdgeInsets.only(top: resolved.feedbackGap),
                    child: Text(widget.help!, style: resolved.helpTextStyle),
                  )
                : const SizedBox.shrink()),
    );
  }
}

/// The one place [AnimalFormItem] turns its layers into concrete values.
///
/// Precedence: the item's own style, then the theme's form-item style, then
/// defaults derived from theme tokens.
class _ResolvedFormItemStyle {
  final TextStyle labelTextStyle;
  final TextStyle requiredMarkTextStyle;
  final TextStyle helpTextStyle;
  final TextStyle errorTextStyle;
  final double labelGap;
  final double feedbackGap;
  final double bottomMargin;
  final Duration feedbackDuration;

  const _ResolvedFormItemStyle._({
    required this.labelTextStyle,
    required this.requiredMarkTextStyle,
    required this.helpTextStyle,
    required this.errorTextStyle,
    required this.labelGap,
    required this.feedbackGap,
    required this.bottomMargin,
    required this.feedbackDuration,
  });

  static _ResolvedFormItemStyle resolve({
    required AnimalIslandTheme theme,
    required AnimalFormItemStyle? style,
  }) {
    final AnimalFormItemStyle merged = (style ?? AnimalFormItemStyle()).merge(
      theme.components.formItem,
    );
    final colors = theme.colors;
    final typography = theme.typography;
    // Label and feedback lines sit one step below spacing.sm; the spacing
    // scale is validated as ordered, so the difference is never negative.
    final double gap = theme.spacing.sm - theme.spacing.xxs;

    TextStyle text(TextStyle base, TextStyle? override) =>
        typography.resolve(base.merge(override));

    return _ResolvedFormItemStyle._(
      labelTextStyle: text(
        typography.body.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.text,
        ),
        merged.labelTextStyle,
      ),
      requiredMarkTextStyle: text(
        typography.body.copyWith(
          color: colors.errorText,
          fontWeight: FontWeight.bold,
        ),
        merged.requiredMarkTextStyle,
      ),
      helpTextStyle: text(
        typography.caption.copyWith(color: colors.textSecondary),
        merged.helpTextStyle,
      ),
      errorTextStyle: text(
        typography.caption.copyWith(
          color: colors.errorText,
          fontWeight: FontWeight.w500,
        ),
        merged.errorTextStyle,
      ),
      labelGap: merged.labelGap ?? gap,
      feedbackGap: merged.feedbackGap ?? gap,
      bottomMargin: merged.bottomMargin ?? theme.spacing.lg,
      feedbackDuration:
          merged.feedbackDuration ?? theme.motion.fast * (200 / 150),
    );
  }
}
