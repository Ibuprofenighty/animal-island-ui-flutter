import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_form_values.dart';
import '../../internal/form/form_scope.dart';
import 'form_controller.dart';

/// Animal Island form container and owner-scope composition point.
class AnimalForm extends StatefulWidget {
  final AnimalFormController? controller;
  final Widget child;
  final AnimalFormValues? initialValues;
  final ValueChanged<AnimalFormValues>? onChanged;
  final FutureOr<bool> Function(AnimalFormValues values)? onSubmit;

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
      final oldController = oldWidget.controller ?? _internalController;
      oldController?.removeListener(_handleControllerChange);
      if (oldController?.defaultSubmitHandler == oldWidget.onSubmit) {
        oldController?.defaultSubmitHandler = null;
      }
      if (oldWidget.controller == null) {
        _internalController?.dispose();
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
    final controller = widget.controller ?? _internalController;
    controller?.removeListener(_handleControllerChange);
    if (controller?.defaultSubmitHandler == widget.onSubmit) {
      controller?.defaultSubmitHandler = null;
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
