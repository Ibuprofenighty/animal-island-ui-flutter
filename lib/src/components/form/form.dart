import 'dart:async';

import 'package:flutter/widgets.dart';

import 'form_controller.dart';

export '../../foundation/models/option.dart';
export 'field_binding.dart';
export 'field_key.dart';
export 'form_controller.dart';
export 'form_item.dart';
export 'validation.dart';

/// Animal Island Form Container component (C19).
///
/// Features:
/// - Single-track typed form architecture with [AnimalFormController]
/// - Revision and epoch based concurrency and race-condition immunity (F06 resolved)
/// - Fine-grained field-level reactive binding via [AnimalFieldBinding]
/// - Automatic keyboard focus routing to the first invalid field upon validation failure
class AnimalForm extends StatefulWidget {
  /// The form controller managing state, validation, and lifecycle.
  /// If null, an internal controller is created and managed automatically.
  final AnimalFormController? controller;

  /// Child hierarchy containing form items and controls.
  final Widget child;

  /// Optional initial values map to populate the controller upon initialization.
  final Map<String, dynamic>? initialValues;

  /// Callback triggered whenever any field value inside the form changes.
  final ValueChanged<Map<String, dynamic>>? onChanged;

  /// Form submission handler invoked when [AnimalFormController.submit] succeeds.
  final FutureOr<void> Function(Map<String, dynamic> values)? onSubmit;

  const AnimalForm({
    super.key,
    this.controller,
    required this.child,
    this.initialValues,
    this.onChanged,
    this.onSubmit,
  });

  /// Resolves the nearest [AnimalFormController] in the widget tree, or throws a [StateError].
  static AnimalFormController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw StateError(
        'AnimalForm.of() called with a context that does not contain an AnimalForm.\n'
        'Ensure that your form item or control is nested inside an AnimalForm widget.',
      );
    }
    return controller;
  }

  /// Resolves the nearest [AnimalFormController] in the widget tree, or returns null.
  static AnimalFormController? maybeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AnimalFormScope>();
    return scope?.controller;
  }

  @override
  State<AnimalForm> createState() => _AnimalFormState();
}

class _AnimalFormState extends State<AnimalForm> {
  AnimalFormController? _internalController;

  AnimalFormController get _effectiveController =>
      widget.controller ?? (_internalController ??= AnimalFormController());

  @override
  void initState() {
    super.initState();
    _applyInitialValues();
    _effectiveController.defaultSubmitHandler = widget.onSubmit;
    _effectiveController.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(AnimalForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_handleControllerChange);
      if (oldWidget.controller?.defaultSubmitHandler == oldWidget.onSubmit) {
        oldWidget.controller?.defaultSubmitHandler = null;
      }
      _internalController?.removeListener(_handleControllerChange);

      if (widget.controller == null && _internalController == null) {
        _internalController = AnimalFormController();
      }

      _effectiveController.addListener(_handleControllerChange);
      _applyInitialValues();
    }
    _effectiveController.defaultSubmitHandler = widget.onSubmit;
  }

  void _applyInitialValues() {
    if (widget.initialValues != null) {
      for (final entry in widget.initialValues!.entries) {
        _effectiveController.registerField<dynamic>(
          name: entry.key,
          initialValue: entry.value,
        );
      }
    }
  }

  void _handleControllerChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(_effectiveController.values);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_handleControllerChange);
    if (widget.controller?.defaultSubmitHandler == widget.onSubmit) {
      widget.controller?.defaultSubmitHandler = null;
    }
    _internalController?.removeListener(_handleControllerChange);
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimalFormScope(
      controller: _effectiveController,
      child: widget.child,
    );
  }
}

class _AnimalFormScope extends InheritedWidget {
  final AnimalFormController controller;

  const _AnimalFormScope({required this.controller, required super.child});

  @override
  bool updateShouldNotify(_AnimalFormScope oldWidget) =>
      controller != oldWidget.controller;
}
