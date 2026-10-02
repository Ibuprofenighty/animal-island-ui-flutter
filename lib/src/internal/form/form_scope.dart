import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_form_values.dart';

/// Lower-level form scope contract; it knows only the owner and typed defaults.
class AnimalFormScope<TOwner extends Listenable> extends InheritedWidget {
  final TOwner owner;
  final AnimalFormValues initialValues;

  const AnimalFormScope({
    super.key,
    required this.owner,
    required this.initialValues,
    required super.child,
  });

  static AnimalFormScope<TOwner>? maybeOf<TOwner extends Listenable>(
    BuildContext context,
  ) => context.dependOnInheritedWidgetOfExactType<AnimalFormScope<TOwner>>();

  @override
  bool updateShouldNotify(AnimalFormScope<TOwner> oldWidget) =>
      owner != oldWidget.owner ||
      !identical(initialValues, oldWidget.initialValues);
}
