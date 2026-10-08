import 'package:flutter/foundation.dart';

/// Opaque, typed identity for one field in an [AnimalFormController].
///
/// A key's identity is the key object itself. [debugLabel] is diagnostic text
/// only; it never participates in lookup, equality, or registration ownership.
/// This class is final so external libraries cannot replace its identity
/// semantics by extending or implementing it.
@immutable
final class AnimalFieldKey<T> {
  /// Diagnostic label shown by [toString]; never used for identity.
  final String? debugLabel;
  final T? Function(T?)? _snapshot;

  /// Creates a key for scalar (non-collection) values.
  ///
  /// Snapshotting a List, Set or Map value through this key throws a
  /// [StateError]; use [list], [set], [map] or [withSnapshot] for collections.
  // A const constructor would canonicalize keys and collapse owner identity.
  // ignore: prefer_const_constructors_in_immutables
  AnimalFieldKey({this.debugLabel}) : _snapshot = null;

  // ignore: prefer_const_constructors_in_immutables
  AnimalFieldKey._({this.debugLabel, required T? Function(T?) this._snapshot});

  /// Creates a key with a caller-supplied deep immutable snapshot operation.
  ///
  /// Use this for nested collections. The callback must copy and freeze every
  /// mutable collection reachable from the value.
  static AnimalFieldKey<T> withSnapshot<T>({
    String? debugLabel,
    required T? Function(T?) snapshot,
  }) => AnimalFieldKey<T>._(debugLabel: debugLabel, snapshot: snapshot);

  /// Creates a key for list values and preserves the element type in snapshots.
  /// Nested collection elements are rejected; use [withSnapshot] to deep-copy.
  static AnimalFieldKey<List<E>> list<E>({String? debugLabel}) =>
      AnimalFieldKey<List<E>>._(
        debugLabel: debugLabel,
        snapshot: (value) => value == null
            ? null
            : List<E>.unmodifiable(_requireFlatCollection(value)),
      );

  /// Creates a key for set values and preserves the element type in snapshots.
  /// Nested collection elements are rejected; use [withSnapshot] to deep-copy.
  static AnimalFieldKey<Set<E>> set<E>({String? debugLabel}) =>
      AnimalFieldKey<Set<E>>._(
        debugLabel: debugLabel,
        snapshot: (value) => value == null
            ? null
            : Set<E>.unmodifiable(_requireFlatCollection(value)),
      );

  /// Creates a key for map values and preserves both generic types in snapshots.
  /// Nested collection keys or values are rejected; use [withSnapshot] to deep-copy.
  static AnimalFieldKey<Map<K, V>> map<K, V>({String? debugLabel}) =>
      AnimalFieldKey<Map<K, V>>._(
        debugLabel: debugLabel,
        snapshot: (value) => value == null
            ? null
            : Map<K, V>.unmodifiable(_requireFlatMap(value)),
      );

  // The guards read the key's runtime generic type, so they stay instance
  // members; [AnimalFieldKeyContract] exposes them inside the package.
  void _requireRequestedType(Type requestedType) {
    if (requestedType != T) {
      throw StateError(
        'The requested field type does not match this key instance.',
      );
    }
  }

  void _requireValueType(Object? value) {
    if (value != null && value is! T) {
      throw StateError('The value does not match the field key type.');
    }
  }

  // The runtime parameter type T? already rejects a value of another type.
  T? _snapshotValue(T? value) {
    if (value == null) return null;
    final snapshot = _snapshot;
    if (snapshot == null && (value is List || value is Set || value is Map)) {
      throw StateError(
        'Collection field keys require a typed immutable snapshot strategy.',
      );
    }
    return snapshot == null ? value : snapshot(value);
  }

  static Iterable<E> _requireFlatCollection<E>(Iterable<E> values) {
    for (final Object? value in values) {
      if (value is List || value is Set || value is Map) {
        throw StateError(
          'Nested collections require an explicit deep snapshot strategy.',
        );
      }
    }
    return values;
  }

  static Map<K, V> _requireFlatMap<K, V>(Map<K, V> values) {
    for (final entry in values.entries.cast<MapEntry<Object?, Object?>>()) {
      if (entry.key is List ||
          entry.key is Set ||
          entry.key is Map ||
          entry.value is List ||
          entry.value is Set ||
          entry.value is Map) {
        throw StateError(
          'Nested collections require an explicit deep snapshot strategy.',
        );
      }
    }
    return values;
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => identityHashCode(this);

  @override
  String toString() => 'AnimalFieldKey<$T>(${debugLabel ?? 'opaque identity'})';
}

/// Runtime type guards of [AnimalFieldKey] for the form controller and value
/// snapshots.
///
/// Package-internal: the root library exports [AnimalFieldKey] without this
/// extension.
extension AnimalFieldKeyContract<T> on AnimalFieldKey<T> {
  /// Fails if a caller has widened this key to a different static type.
  void requireRequestedType(Type requestedType) =>
      _requireRequestedType(requestedType);

  /// Fails if [value] does not have this key instance's actual value type.
  void requireValueType(Object? value) => _requireValueType(value);

  /// Returns a defensive immutable snapshot with the type selected by this key.
  T? snapshotValue(T? value) => _snapshotValue(value);
}
