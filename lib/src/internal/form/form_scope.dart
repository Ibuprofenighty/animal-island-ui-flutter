import 'package:flutter/widgets.dart';

import '../../foundation/forms/animal_form_values.dart';

/// Lower-level form scope contract; it knows only the owner and typed defaults.
class AnimalFormScope<TOwner extends Listenable> extends InheritedWidget {
  /// Form owner that descendant fields register with.
  final TOwner owner;

  /// Typed default values the form provides to its fields.
  final AnimalFormValues initialValues;

  /// Creates a scope that exposes [owner] and [initialValues] to [child].
  const AnimalFormScope({
    super.key,
    required this.owner,
    required this.initialValues,
    required super.child,
  });

  /// Returns the nearest scope whose owner is a [TOwner] and makes [context]
  /// depend on it, or null when there is none.
  static AnimalFormScope<TOwner>? maybeOf<TOwner extends Listenable>(
    BuildContext context,
  ) => context.dependOnInheritedWidgetOfExactType<AnimalFormScope<TOwner>>();

  @override
  bool updateShouldNotify(AnimalFormScope<TOwner> oldWidget) =>
      owner != oldWidget.owner ||
      !identical(initialValues, oldWidget.initialValues);
}
