import '../foundation/theme.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show listEquals;

import '../foundation/size.dart';
import '../foundation/field_status.dart';
import 'inputs.dart';
part 'form_controller.dart';

enum IslandFormLayout { horizontal, vertical, inline }

enum IslandFormRequiredMark { hidden, required, optional }

class IslandForm extends StatefulWidget {
  const IslandForm({
    super.key,
    required this.children,
    this.controller,
    this.initialValues = const {},
    this.layout = IslandFormLayout.horizontal,
    this.labelAlign,
    this.labelColumns = 5,
    this.controlColumns = 19,
    this.size = IslandSize.middle,
    this.disabled = false,
    this.colon = true,
    this.requiredMark = IslandFormRequiredMark.hidden,
    this.onFinish,
    this.onFinishFailed,
    this.onValuesChanged,
    this.onReset,
  }) : assert(
         labelColumns >= 0 &&
             controlColumns > 0 &&
             labelColumns + controlColumns <= 24,
       );
  final List<Widget> children;
  final IslandFormController? controller;
  final Map<String, Object?> initialValues;
  final IslandFormLayout layout;
  final TextAlign? labelAlign;
  final int labelColumns, controlColumns;
  final IslandSize size;
  final bool disabled, colon;
  final IslandFormRequiredMark requiredMark;
  final ValueChanged<Map<String, Object?>>? onFinish;
  final ValueChanged<IslandFormValidation>? onFinishFailed;
  final void Function(Map<String, Object?> changed, Map<String, Object?> all)?
  onValuesChanged;
  final VoidCallback? onReset;
  static IslandFormController of(BuildContext context) =>
      _FormScope.of(context).owner.controller;
  @override
  State<IslandForm> createState() => _IslandFormState();
}

class _IslandFormState extends State<IslandForm> {
  IslandFormController? owned;
  void checkInitialOwner() {
    if (widget.controller != null && widget.initialValues.isNotEmpty)
      throw ArgumentError('Put initial values in the supplied controller.');
  }

  IslandFormController get controller => widget.controller ?? owned!;
  @override
  void initState() {
    super.initState();
    checkInitialOwner();
    if (widget.controller == null)
      owned = IslandFormController(initialValues: widget.initialValues);
    controller._attach(this);
  }

  @override
  void didUpdateWidget(IslandForm old) {
    super.didUpdateWidget(old);
    checkInitialOwner();
    if (old.controller != widget.controller) {
      (old.controller ?? owned!)._detach(this);
      owned?.dispose();
      owned = widget.controller == null
          ? IslandFormController(initialValues: widget.initialValues)
          : null;
      controller._attach(this);
    }
  }

  @override
  void dispose() {
    controller._detach(this);
    owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _FormScope(
    owner: this,
    controller: controller,
    child: Opacity(
      opacity: widget.disabled ? .6 : 1,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: IslandTheme.of(context).ink,
          fontSize: 14,
          height: 1.6,
        ),
        child: widget.layout == IslandFormLayout.inline
            ? Wrap(spacing: 8, runSpacing: 8, children: widget.children)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < widget.children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    widget.children[i],
                  ],
                ],
              ),
      ),
    ),
  );
}

class _FormScope extends InheritedWidget {
  const _FormScope({
    required this.owner,
    required this.controller,
    required super.child,
  });
  final _IslandFormState owner;
  final IslandFormController controller;
  static _FormScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_FormScope>();
    if (scope == null)
      throw FlutterError(
        'Form fields and items require an IslandForm ancestor.',
      );
    return scope;
  }

  @override
  bool updateShouldNotify(_FormScope old) => true;
}

/// Layout-only wrapper. Child widgets remain opaque and own their actions.
class IslandFormItem extends StatelessWidget {
  const IslandFormItem({
    super.key,
    required this.child,
    this.label,
    this.help,
    this.error,
    this.required = false,
    this.requiredMark,
    this.colon,
    this.layout,
    this.labelColumns,
    this.controlColumns,
    this.noStyle = false,
    this.hidden = false,
    this.labelFor,
  });
  final Widget child;
  final String? label, error;
  final Widget? help;
  final bool required, noStyle, hidden;
  final bool? colon;
  final IslandFormRequiredMark? requiredMark;
  final IslandFormLayout? layout;
  final int? labelColumns, controlColumns;
  final VoidCallback? labelFor;
  @override
  Widget build(BuildContext context) {
    final form = _FormScope.of(context).owner.widget;
    if (hidden) return const SizedBox.shrink();
    final control = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: child,
        ),
        if (error != null || help != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 22),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: error != null
                      ? IslandTheme.of(context).dangerText
                      : IslandTheme.of(context).muted,
                ),
                child: error == null
                    ? help!
                    : Semantics(liveRegion: true, child: Text(error!)),
              ),
            ),
          ),
      ],
    );
    if (noStyle) return control;
    final orientation = layout ?? form.layout;
    final mark = requiredMark ?? form.requiredMark;
    final font = switch (form.size) {
      IslandSize.small => 12.0,
      IslandSize.middle => 14.0,
      IslandSize.large => 16.0,
    };
    final labelWidget = GestureDetector(
      onTap: labelFor,
      child: SizedBox(
        height: MediaQuery.textScalerOf(context).scale(font) * 1.6,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: double.infinity,
            child: Text.rich(
              TextSpan(
                children: [
                  if (required && mark != IslandFormRequiredMark.hidden)
                    TextSpan(
                      text: '* ',
                      style: TextStyle(
                        color: IslandTheme.of(context).dangerText,
                      ),
                    ),
                  TextSpan(text: label ?? ''),
                  if (!required && mark == IslandFormRequiredMark.optional)
                    TextSpan(
                      text: '（选填）',
                      style: TextStyle(color: IslandTheme.of(context).muted),
                    ),
                  if ((colon ?? form.colon) && label?.isNotEmpty == true)
                    const TextSpan(
                      text: ':',
                      style: TextStyle(letterSpacing: 2),
                    ),
                ],
              ),
              strutStyle: StrutStyle.fromTextStyle(
                DefaultTextStyle.of(context).style.copyWith(
                  fontSize: font,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
                forceStrutHeight: true,
              ),
              textAlign:
                  form.labelAlign ??
                  (orientation == IslandFormLayout.horizontal
                      ? TextAlign.right
                      : TextAlign.left),
              style: TextStyle(
                fontSize: font,
                fontWeight: FontWeight.w400,
                height: 1.6,
                color: IslandTheme.of(context).ink,
              ),
            ),
          ),
        ),
      ),
    );
    if (orientation != IslandFormLayout.horizontal)
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null && label!.isNotEmpty) ...[
            labelWidget,
            const SizedBox(height: 6),
          ],
          control,
        ],
      );
    final labels = labelColumns ?? form.labelColumns,
        controls = controlColumns ?? form.controlColumns;
    return LayoutBuilder(
      builder: (context, c) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: c.maxWidth * labels / 24,
            child: label == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: labelWidget,
                  ),
          ),
          SizedBox(width: c.maxWidth * controls / 24, child: control),
        ],
      ),
    );
  }
}

@immutable
class IslandFormBinding<T> {
  const IslandFormBinding({
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.size,
    required this.errors,
    required this.validating,
    required this.submit,
  });
  final T? value;
  final ValueChanged<T?> onChanged;
  final bool enabled, validating;
  final IslandSize size;
  final List<String> errors;
  final VoidCallback submit;
  IslandFieldStatus get status =>
      errors.isEmpty ? IslandFieldStatus.normal : IslandFieldStatus.error;
}

class IslandFormField<T> extends StatefulWidget {
  const IslandFormField({
    super.key,
    required this.name,
    required this.builder,
    this.initialValue,
    this.label,
    this.help,
    this.required = false,
    this.validators = const [],
    this.dependencies = const [],
    this.normalize,
    this.enabled,
    this.size,
    this.layout,
    this.labelColumns,
    this.controlColumns,
    this.hidden = false,
    this.noStyle = false,
    this.onLabelPressed,
  });
  final VoidCallback? onLabelPressed;
  final String name;
  final T? initialValue;
  final Widget Function(BuildContext, IslandFormBinding<T>) builder;
  final String? label;
  final Widget? help;
  final bool required, hidden, noStyle;
  final List<IslandFormValidator<T>> validators;
  final List<String> dependencies;
  final T? Function(T? value, T? previous, Map<String, Object?> values)?
  normalize;
  final bool? enabled;
  final IslandSize? size;
  final IslandFormLayout? layout;
  final int? labelColumns, controlColumns;
  @override
  State<IslandFormField<T>> createState() => _IslandFormFieldState<T>();
}

class _IslandFormFieldState<T> extends State<IslandFormField<T>> {
  IslandFormController? controller;
  _FormScope? scope;
  late final _FieldRegistration registration = _FieldRegistration(
    owner: this,
    accepts: (v) => v == null || v is T,
    validate: validate,
    dependencies: widget.dependencies,
    scroll: () {
      if (mounted)
        Scrollable.ensureVisible(
          context,
          alignment: .5,
          duration: const Duration(milliseconds: 200),
        );
    },
  );
  Future<List<String>> validate(
    Object? raw,
    Map<String, Object?> values,
  ) async {
    final rules = List<IslandFormValidator<T>>.of(widget.validators);
    final errors = <String>[];
    for (final rule in rules) {
      try {
        final message = await rule(raw as T?, values);
        if (message != null && message.isNotEmpty) errors.add(message);
      } catch (_) {
        errors.add('暂时无法完成校验');
      }
    }
    return errors;
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scope = _FormScope.of(context);
    final next = scope!.controller;
    if (next != controller) {
      controller?.removeListener(changed);
      controller?._unregister(widget.name, this);
      controller = next;
      next._register(widget.name, registration, widget.initialValue);
      next.addListener(changed);
    }
  }

  @override
  void didUpdateWidget(IslandFormField<T> old) {
    super.didUpdateWidget(old);
    if (old.name != widget.name) {
      controller!._unregister(old.name, this);
      controller!._register(widget.name, registration, widget.initialValue);
    }
    if (!listEquals(old.validators, widget.validators) ||
        !listEquals(old.dependencies, widget.dependencies)) {
      registration.generation++;
      controller!._revision++;
      controller!._errors.remove(widget.name);
      controller!._validating.remove(widget.name);
    }
    registration.dependencies = widget.dependencies;
  }

  @override
  void dispose() {
    controller?.removeListener(changed);
    controller?._unregister(widget.name, this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller!, form = scope!.owner.widget;
    final enabled = widget.enabled ?? !form.disabled;
    final binding = IslandFormBinding<T>(
      value: c.value<T>(widget.name),
      enabled: enabled,
      size: widget.size ?? form.size,
      errors: c.errors(widget.name),
      validating: c.isValidating(widget.name),
      submit: () {
        if (enabled) unawaited(c.submit());
      },
      onChanged: (next) {
        if (!enabled) return;
        final value = widget.normalize == null
            ? next
            : widget.normalize!(next, c.value<T>(widget.name), c.values);
        c.setValues({widget.name: value}, userInitiated: true);
      },
    );
    return IslandFormItem(
      label: widget.label,
      labelFor: enabled ? widget.onLabelPressed : null,
      help: widget.help,
      error: binding.errors.firstOrNull,
      required: widget.required,
      hidden: widget.hidden,
      noStyle: widget.noStyle,
      layout: widget.layout,
      labelColumns: widget.labelColumns,
      controlColumns: widget.controlColumns,
      child: widget.builder(context, binding),
    );
  }
}

/// Explicit text adapter: owns its editor, synchronizes form values without
/// recreating the child, and never guesses the type of an arbitrary child.
class IslandFormTextField extends StatefulWidget {
  const IslandFormTextField({
    super.key,
    required this.name,
    required this.label,
    this.initialValue,
    this.hint,
    this.required = false,
    this.obscureText = false,
    this.validators = const [],
    this.dependencies = const [],
    this.normalize,
    this.enabled,
    this.size,
    this.focusNode,
    this.help,
  });
  final String name, label;
  final String? initialValue, hint;
  final bool required, obscureText;
  final List<IslandFormValidator<String>> validators;
  final List<String> dependencies;
  final String? Function(String?, String?, Map<String, Object?>)? normalize;
  final bool? enabled;
  final IslandSize? size;
  final FocusNode? focusNode;
  final Widget? help;
  @override
  State<IslandFormTextField> createState() => _IslandFormTextFieldState();
}

class _IslandFormTextFieldState extends State<IslandFormTextField> {
  FocusNode? owned;
  FocusNode get focus => widget.focusNode ?? owned!;
  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) owned = FocusNode();
  }

  @override
  void didUpdateWidget(IslandFormTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      owned?.dispose();
      owned = widget.focusNode == null ? FocusNode() : null;
    }
  }

  @override
  void dispose() {
    owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IslandFormField<String>(
    name: widget.name,
    label: widget.label,
    onLabelPressed: focus.requestFocus,
    initialValue: widget.initialValue,
    required: widget.required,
    validators: widget.validators,
    dependencies: widget.dependencies,
    normalize: widget.normalize,
    enabled: widget.enabled,
    size: widget.size,
    help: widget.help,
    builder: (context, binding) => _FormTextEditor(
      binding: binding,
      label: widget.label,
      hint: widget.hint,
      obscureText: widget.obscureText,
      focusNode: focus,
    ),
  );
}

class _FormTextEditor extends StatefulWidget {
  const _FormTextEditor({
    required this.binding,
    required this.label,
    required this.hint,
    required this.obscureText,
    this.focusNode,
  });
  final IslandFormBinding<String> binding;
  final String label;
  final String? hint;
  final bool obscureText;
  final FocusNode? focusNode;
  @override
  State<_FormTextEditor> createState() => _FormTextEditorState();
}

class _FormTextEditorState extends State<_FormTextEditor> {
  late final editing = TextEditingController(text: widget.binding.value ?? '');
  @override
  void didUpdateWidget(_FormTextEditor old) {
    super.didUpdateWidget(old);
    final text = widget.binding.value ?? '';
    if (editing.text != text)
      editing.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
  }

  @override
  void dispose() {
    editing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IslandTextField(
    label: widget.label,
    showLabel: false,
    controller: editing,
    focusNode: widget.focusNode,
    hint: widget.hint,
    obscureText: widget.obscureText,
    enabled: widget.binding.enabled,
    size: widget.binding.size,
    status: widget.binding.status,
    shadow: widget.binding.errors.isNotEmpty,
    onChanged: widget.binding.onChanged,
    onSubmitted: (_) => widget.binding.submit(),
  );
}
