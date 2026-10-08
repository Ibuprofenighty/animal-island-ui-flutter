import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_form_values.dart';
import '../../internal/form/form_scope.dart';
import 'form_controller.dart';

/// Animal Island form container and owner-scope composition point.
class AnimalForm extends StatefulWidget {
  /// Caller-owned controller for this form.
  ///
  /// When null, the form creates and disposes its own controller. The form
  /// never disposes a controller supplied here.
  final AnimalFormController? controller;

  /// Subtree containing the form's `AnimalFormItem` widgets.
  final Widget child;

  /// Initial values for non-text fields, keyed by field identity.
  ///
  /// A value here takes precedence over `AnimalFormItem.initialValue`. Text
  /// fields take their initial value from their text controller instead and
  /// reject an entry here. Null means no initial values.
  final AnimalFormValues? initialValues;

  /// Called with a fresh values snapshot whenever the controller notifies its
  /// listeners.
  final ValueChanged<AnimalFormValues>? onChanged;

  /// Submit handler that [AnimalFormController.submit] uses when it is called
  /// without its own `onSubmit`.
  ///
  /// Returning true accepts the snapshot; false rejects it.
  final FutureOr<bool> Function(AnimalFormValues values)? onSubmit;

  /// Creates a form scope around [child].
  const AnimalForm({
    super.key,
    this.controller,
    required this.child,
    this.initialValues,
    this.onChanged,
    this.onSubmit,
  });

  /// Resolves the nearest form owner or throws when the context has no form.
  static AnimalFormController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw StateError(
        'AnimalForm.of() requires a context below an AnimalForm widget.',
      );
    }
    return controller;
  }

  /// Resolves the nearest form owner, if present.
  static AnimalFormController? maybeOf(BuildContext context) {
    return AnimalFormScope.maybeOf<AnimalFormController>(context)?.owner;
  }

  @override
  State<AnimalForm> createState() => _AnimalFormState();
}

class _AnimalFormState extends State<AnimalForm> {
  static final AnimalFormValues _emptyInitialValues = AnimalFormValues.empty();
  AnimalFormController? _internalController;

  AnimalFormController get _effectiveController =>
      widget.controller ?? (_internalController ??= AnimalFormController());

  @override
  void initState() {
    super.initState();
    final controller = _effectiveController;
    controller.defaultSubmitHandler = widget.onSubmit;
    controller.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(AnimalForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      final AnimalFormController oldController =
          oldWidget.controller ?? _internalController!;
      oldController.removeListener(_handleControllerChange);
      if (oldController.defaultSubmitHandler == oldWidget.onSubmit) {
        oldController.defaultSubmitHandler = null;
      }
      if (oldWidget.controller == null) {
        oldController.dispose();
        _internalController = null;
      }
      final newController = _effectiveController;
      newController.defaultSubmitHandler = widget.onSubmit;
      newController.addListener(_handleControllerChange);
    } else if (widget.onSubmit != oldWidget.onSubmit) {
      _effectiveController.defaultSubmitHandler = widget.onSubmit;
    }
  }

  void _handleControllerChange() {
    widget.onChanged?.call(_effectiveController.values);
  }

  @override
  void dispose() {
    final controller = _effectiveController;
    controller.removeListener(_handleControllerChange);
    if (controller.defaultSubmitHandler == widget.onSubmit) {
      controller.defaultSubmitHandler = null;
    }
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimalFormScope<AnimalFormController>(
      owner: _effectiveController,
      initialValues: widget.initialValues ?? _emptyInitialValues,
      child: widget.child,
    );
  }
}
