import 'package:flutter/foundation.dart';

/// A strongly typed field identifier and type-token for form fields in [AnimalForm].
///
/// Encapsulates the field's unique name along with its value type [T], preventing
/// type mismatch and runtime casting errors across form interactions.
@immutable
class AnimalFieldKey<T> {
  /// The unique string identifier for the field within a form.
  final String name;

  /// Creates a type-safe [AnimalFieldKey] with the specified [name].
  const AnimalFieldKey(this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalFieldKey<T> &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => Object.hash(name, T);

  @override
  String toString() => 'AnimalFieldKey<$T>($name)';
}
