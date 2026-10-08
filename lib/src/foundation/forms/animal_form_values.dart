import 'package:flutter/foundation.dart';

import 'animal_field_key.dart';

/// One typed value supplied to an [AnimalFormValues] snapshot.
@immutable
class AnimalFieldValue<T> {
  /// Field identity the value belongs to.
  final AnimalFieldKey<T> key;

  /// Value for [key]; null means no value.
  final T? value;

  /// Creates an entry pairing [key] with [value].
  ///
  /// The value is type-checked and snapshotted when the entry is passed to
  /// [AnimalFormValues.fromEntries].
  const AnimalFieldValue(this.key, this.value);

  AnimalFieldValue<T> _snapshot() {
    // This erased entry boundary validates against the actual key instance
    // before its typed snapshot method can apply a generic argument check.
    key.requireValueType(value);
    return AnimalFieldValue<T>(key, key.snapshotValue(value));
  }
}

/// Immutable values snapshot with typed reads and opaque field identities.
///
/// Values are copied through each key's snapshot contract. This class does not
/// expose an erased key-to-object map, so consumers read values with
/// [valueFor].
@immutable
class AnimalFormValues {
  final Map<AnimalFieldKey<dynamic>, Object?> _values;

  AnimalFormValues._(Map<AnimalFieldKey<dynamic>, Object?> values)
    : _values = Map.unmodifiable(values);

  /// Creates an empty values snapshot.
  factory AnimalFormValues.empty() =>
      AnimalFormValues._(<AnimalFieldKey<dynamic>, Object?>{});

  /// Creates a snapshot from typed entries, rejecting duplicate keys.
  factory AnimalFormValues.fromEntries(
    Iterable<AnimalFieldValue<dynamic>> entries,
  ) {
    final values = <AnimalFieldKey<dynamic>, Object?>{};
    for (final entry in entries) {
      final snapshot = entry._snapshot();
      if (values.containsKey(snapshot.key)) {
        throw StateError('A form values snapshot contains a duplicate key.');
      }
      values[snapshot.key] = snapshot.value;
    }
    return AnimalFormValues._(values);
  }

  /// Number of captured values.
  int get length => _values.length;

  /// Whether this snapshot has no values.
  bool get isEmpty => _values.isEmpty;

  /// Whether this snapshot has at least one value.
  bool get isNotEmpty => _values.isNotEmpty;

  /// Opaque identities present in this snapshot.
  Iterable<AnimalFieldKey<dynamic>> get keys => _values.keys;

  /// Whether [key] is present in this snapshot.
  bool containsKey<T>(AnimalFieldKey<T> key) {
    key.requireRequestedType(T);
    return _values.containsKey(key);
  }

  /// Reads a value using the actual generic type carried by [key].
  T? valueFor<T>(AnimalFieldKey<T> key) {
    key.requireRequestedType(T);
    // Every stored value passed its key's value check when it was captured.
    return _values[key] as T?;
  }
}
