part of 'form.dart';

/// Validators return a message for invalid values; null means valid.
typedef IslandFormValidator<T> = FutureOr<String?> Function(
  T? value,
  Map<String, Object?> values,
);

@immutable
class IslandFormValidation {
  IslandFormValidation({
    required Map<String, Object?> values,
    required Map<String, List<String>> errors,
    this.outOfDate = false,
  }) : values = Map.unmodifiable(values),
       errors = Map.unmodifiable(
         errors.map((k, v) => MapEntry(k, List<String>.unmodifiable(v))),
       );
  final Map<String, Object?> values;
  final Map<String, List<String>> errors;
  final bool outOfDate;
  bool get valid => !outOfDate && errors.isEmpty;
}

class _FieldRegistration {
  _FieldRegistration({
    required this.owner,
    required this.validate,
    required this.accepts,
    required this.dependencies,
    required this.scroll,
  });
  final Object owner;
  Future<List<String>> Function(Object?, Map<String, Object?>) validate;
  bool Function(Object?) accepts;
  List<String> dependencies;
  VoidCallback scroll;
  int generation = 0;
}

/// Locally owned form state. A borrowed controller attaches to only one form.
/// Values should be immutable; returned maps cannot be changed.
class IslandFormController extends ChangeNotifier {
  IslandFormController({Map<String, Object?> initialValues = const {}})
    : _initial = Map.of(initialValues),
      _values = Map.of(initialValues);
  final Map<String, Object?> _initial, _values;
  final _fields = <String, _FieldRegistration>{};
  final _errors = <String, List<String>>{};
  final _touched = <String>{}, _validating = <String>{};
  _IslandFormState? _host;
  bool _disposed = false;
  int _revision = 0, _submission = 0;
  Map<String, Object?> get values => Map.unmodifiable(_values);
  T? value<T>(String name) => _values[name] as T?;
  List<String> errors(String name) =>
      List.unmodifiable(_errors[name] ?? const []);
  bool isTouched(String name) => _touched.contains(name);
  bool isValidating(String name) => _validating.contains(name);
  void _check() {
    if (_disposed) throw StateError('IslandFormController has been disposed.');
  }

  void _attach(_IslandFormState host) {
    _check();
    if (_host != null && _host != host)
      throw FlutterError(
        'One IslandFormController can attach to only one IslandForm.',
      );
    _host = host;
  }

  void _detach(_IslandFormState host) {
    if (_host == host) {
      _host = null;
      _submission++;
    }
  }

  void _register(String name, _FieldRegistration field, Object? initial) {
    _check();
    final previous = _fields[name];
    if (previous != null && previous.owner != field.owner)
      throw FlutterError('Duplicate form field name: $name');
    if (!_values.containsKey(name)) {
      _values[name] = initial;
      _initial[name] = initial;
    }
    if (!field.accepts(_values[name]))
      throw FlutterError('Value type does not match form field $name.');
    _fields[name] = field;
    _revision++;
  }

  void _unregister(String name, Object owner) {
    if (_fields[name]?.owner != owner) return;
    _fields.remove(name);
    _validating.remove(name);
    _errors.remove(name);
    _revision++;
  }

  void setValues(Map<String, Object?> updates, {bool userInitiated = false}) {
    _check();
    for (final e in updates.entries) {
      if (_fields[e.key]?.accepts(e.value) == false)
        throw ArgumentError('Value type does not match form field ${e.key}.');
    }
    _revision++;
    _values.addAll(updates);
    final affected = <String>{
      ...updates.keys,
      for (final e in _fields.entries)
        if (e.value.dependencies.any(updates.containsKey)) e.key,
    };
    for (final name in affected) {
      _fields[name]?.generation++;
      _validating.remove(name);
      _errors.remove(name);
    }
    if (userInitiated) _touched.addAll(updates.keys);
    final snapshot = values, revision = _revision;
    notifyListeners();
    if (_disposed || revision != _revision) return;
    if (userInitiated) {
      _host?.widget.onValuesChanged?.call(Map.unmodifiable(updates), snapshot);
      if (!_disposed && revision == _revision)
        unawaited(validate(names: affected));
    }
  }

  void reset({Iterable<String>? names}) {
    _check();
    _revision++;
    _submission++;
    final targets = (names ?? {..._values.keys, ..._fields.keys}).toList();
    for (final name in targets) {
      _values[name] = _initial[name];
      _errors.remove(name);
      _touched.remove(name);
      _validating.remove(name);
      _fields[name]?.generation++;
    }
    notifyListeners();
    if (!_disposed) _host?.widget.onReset?.call();
  }

  Future<IslandFormValidation> validate({Iterable<String>? names}) async {
    _check();
    final revision = _revision, snapshot = values;
    final entries = <String, (_FieldRegistration, int)>{};
    for (final name in (names ?? _fields.keys).toList()) {
      final field = _fields[name];
      if (field == null) continue;
      entries[name] = (field, ++field.generation);
      _touched.add(name);
      _validating.add(name);
    }
    notifyListeners();
    if (_disposed || revision != _revision)
      return IslandFormValidation(
        values: snapshot,
        errors: const {},
        outOfDate: true,
      );
    final results = <String, List<String>>{};
    await Future.wait(
      entries.entries.map((entry) async {
        final issues = await entry.value.$1.validate(
          snapshot[entry.key],
          snapshot,
        );
        if (issues.isNotEmpty) results[entry.key] = issues;
      }),
    );
    final stale =
        _disposed ||
        revision != _revision ||
        entries.entries.any(
          (e) =>
              _fields[e.key] != e.value.$1 ||
              e.value.$1.generation != e.value.$2,
        );
    if (!stale) {
      for (final name in entries.keys) {
        _errors.remove(name);
        _validating.remove(name);
      }
      _errors.addAll(results);
      notifyListeners();
    } else if (!_disposed) {
      // End only the still-owned sessions; newer validators keep their metadata.
      var changed = false;
      for (final e in entries.entries) {
        if (_fields[e.key] == e.value.$1 && e.value.$1.generation == e.value.$2)
          changed = _validating.remove(e.key) || changed;
      }
      if (changed) notifyListeners();
    }
    return IslandFormValidation(
      values: snapshot,
      errors: results,
      outOfDate: stale || _disposed || revision != _revision,
    );
  }

  Future<IslandFormValidation> submit() async {
    _check();
    final host = _host, ticket = ++_submission;
    final result = await validate();
    if (_disposed ||
        ticket != _submission ||
        _host != host ||
        host == null ||
        !host.mounted ||
        host.widget.disabled ||
        result.outOfDate)
      return result;
    if (result.valid) {
      host.widget.onFinish?.call(result.values);
    } else {
      host.widget.onFinishFailed?.call(result);
    }
    return result;
  }

  void scrollToField(String name) {
    _check();
    _fields[name]?.scroll();
  }

  @override
  void dispose() {
    _disposed = true;
    _revision++;
    _submission++;
    _host = null;
    _fields.clear();
    _validating.clear();
    super.dispose();
  }
}
