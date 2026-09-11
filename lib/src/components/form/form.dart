import 'dart:async';
import 'package:flutter/material.dart';
import '../../tokens/theme.dart';
import '../../tokens/typography.dart';

/// Form validation rule types.
enum AnimalRuleType {
  required,
  email,
  url,
  pattern,
  min,
  max,
  length,
  custom,
}

/// A validation rule definition for [AnimalFormItem].
class AnimalRule {
  final AnimalRuleType type;
  final String? message;
  final num? min;
  final num? max;
  final RegExp? pattern;
  final FutureOr<String?> Function(dynamic value)? customValidator;

  const AnimalRule._({
    required this.type,
    this.message,
    this.min,
    this.max,
    this.pattern,
    this.customValidator,
  });

  /// Validates that field is not null, not empty string, and not empty list.
  factory AnimalRule.required({String? message}) => AnimalRule._(
        type: AnimalRuleType.required,
        message: message ?? 'This field is required',
      );

  /// Validates standard email address format.
  factory AnimalRule.email({String? message}) => AnimalRule._(
        type: AnimalRuleType.email,
        message: message ?? 'Please enter a valid email address',
        pattern: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
      );

  /// Validates standard URL format.
  factory AnimalRule.url({String? message}) => AnimalRule._(
        type: AnimalRuleType.url,
        message: message ?? 'Please enter a valid URL',
        pattern: RegExp(r'^(https?:\/\/)[^\s/$.?#].[^\s]*$', caseSensitive: false),
      );

  /// Validates string against regular expression.
  factory AnimalRule.pattern(RegExp pattern, {String? message}) => AnimalRule._(
        type: AnimalRuleType.pattern,
        message: message ?? 'Value does not match required pattern',
        pattern: pattern,
      );

  /// Validates that numeric value or string length >= [min].
  factory AnimalRule.min(num min, {String? message}) => AnimalRule._(
        type: AnimalRuleType.min,
        min: min,
        message: message ?? 'Value must be at least $min',
      );

  /// Validates that numeric value or string length <= [max].
  factory AnimalRule.max(num max, {String? message}) => AnimalRule._(
        type: AnimalRuleType.max,
        max: max,
        message: message ?? 'Value cannot exceed $max',
      );

  /// Validates string or collection length between [min] and [max].
  factory AnimalRule.length({int? min, int? max, String? message}) => AnimalRule._(
        type: AnimalRuleType.length,
        min: min,
        max: max,
        message: message ?? 'Length must be between $min and $max',
      );

  /// Custom synchronous or asynchronous validator function.
  factory AnimalRule.custom(FutureOr<String?> Function(dynamic value) validator) =>
      AnimalRule._(
        type: AnimalRuleType.custom,
        customValidator: validator,
      );

  /// Executes validation logic on [value]. Returns error message if invalid, null if valid.
  Future<String?> validate(dynamic value) async {
    switch (type) {
      case AnimalRuleType.required:
        if (value == null) return message;
        if (value is String && value.trim().isEmpty) return message;
        if (value is Iterable && value.isEmpty) return message;
        if (value is Map && value.isEmpty) return message;
        return null;

      case AnimalRuleType.email:
      case AnimalRuleType.url:
      case AnimalRuleType.pattern:
        if (value == null || (value is String && value.isEmpty)) return null;
        if (value is! String || pattern == null || !pattern!.hasMatch(value)) {
          return message;
        }
        return null;

      case AnimalRuleType.min:
        if (value == null) return null;
        if (value is num && value < min!) return message;
        if (value is String && value.length < min!) return message;
        if (value is Iterable && value.length < min!) return message;
        return null;

      case AnimalRuleType.max:
        if (value == null) return null;
        if (value is num && value > max!) return message;
        if (value is String && value.length > max!) return message;
        if (value is Iterable && value.length > max!) return message;
        return null;

      case AnimalRuleType.length:
        if (value == null) return null;
        int? len;
        if (value is String) {
          len = value.length;
        } else if (value is Iterable) {
          len = value.length;
        } else if (value is Map) {
          len = value.length;
        } else if (value is num) {
          len = value.toString().length;
        }
        if (len != null) {
          if (min != null && len < min!) return message;
          if (max != null && len > max!) return message;
        }
        return null;

      case AnimalRuleType.custom:
        if (customValidator != null) {
          return await customValidator!(value);
        }
        return null;
    }
  }
}

/// Controller managing form state, values, validation rules, and error messages.
class AnimalFormController extends ChangeNotifier {
  final Map<String, dynamic> _values = {};
  final Map<String, String?> _errors = {};
  final Map<String, List<AnimalRule>> _rules = {};
  final Map<String, FocusNode> _focusNodes = {};
  VoidCallback? _onSubmitCallback;

  /// Internal hook to bind [AnimalForm.onSubmit].
  void setSubmitCallback(VoidCallback? callback) {
    _onSubmitCallback = callback;
  }

  /// Current field values map.
  Map<String, dynamic> get values => Map.unmodifiable(_values);

  /// Current field errors map.
  Map<String, String> get errors => Map.fromEntries(
        _errors.entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );

  /// Returns value for a specific field [name].
  dynamic getFieldValue(String name) => _values[name];

  /// Returns all field values.
  Map<String, dynamic> getFieldsValue() => Map.unmodifiable(_values);

  /// Sets single field value and triggers validation if [validate] is true.
  void setFieldValue(String name, dynamic value, {bool validate = true}) {
    _values[name] = value;
    if (validate && _rules.containsKey(name)) {
      validateField(name);
    } else {
      notifyListeners();
    }
  }

  /// Sets multiple field values simultaneously.
  void setFieldsValue(Map<String, dynamic> values, {bool validate = false}) {
    _values.addAll(values);
    if (validate) {
      validateFields();
    } else {
      notifyListeners();
    }
  }

  /// Returns error string for field [name] if invalid, or null.
  String? getFieldError(String name) => _errors[name];

  /// Resets fields to null or initial state and clears all errors.
  void resetFields([List<String>? names]) {
    if (names != null) {
      for (final n in names) {
        _values.remove(n);
        _errors.remove(n);
      }
    } else {
      _values.clear();
      _errors.clear();
    }
    notifyListeners();
  }

  /// Registers field with rules and optional focus node.
  void registerField(
    String name, {
    List<AnimalRule>? rules,
    dynamic initialValue,
    FocusNode? focusNode,
  }) {
    if (rules != null) _rules[name] = rules;
    if (initialValue != null && !_values.containsKey(name)) {
      _values[name] = initialValue;
    }
    if (focusNode != null) _focusNodes[name] = focusNode;
  }

  /// Unregisters field when removed from widget tree.
  void unregisterField(String name) {
    _rules.remove(name);
    _errors.remove(name);
    _focusNodes.remove(name);
    notifyListeners();
  }

  /// Validates a single field [name]. Returns error string or null.
  Future<String?> validateField(String name) async {
    final rules = _rules[name];
    if (rules == null || rules.isEmpty) {
      _errors.remove(name);
      notifyListeners();
      return null;
    }
    final value = _values[name];
    for (final rule in rules) {
      final err = await rule.validate(value);
      if (err != null) {
        _errors[name] = err;
        notifyListeners();
        return err;
      }
    }
    _errors.remove(name);
    notifyListeners();
    return null;
  }

  /// Validates all registered fields or a subset in [names].
  /// Returns true if all valid, false otherwise.
  Future<bool> validateFields([List<String>? names]) async {
    final fieldsToValidate = names ?? _rules.keys.toList();
    bool allValid = true;
    String? firstErrorField;

    for (final name in fieldsToValidate) {
      final err = await validateField(name);
      if (err != null) {
        allValid = false;
        firstErrorField ??= name;
      }
    }

    if (firstErrorField != null && _focusNodes.containsKey(firstErrorField)) {
      _focusNodes[firstErrorField]?.requestFocus();
    }

    return allValid;
  }

  /// Validates all fields and triggers form submission if valid.
  Future<bool> submit() async {
    final isValid = await validateFields();
    if (isValid) {
      _onSubmitCallback?.call();
    }
    return isValid;
  }
}

/// Form inherited scope providing controller access down widget hierarchy.
class _AnimalFormScope extends InheritedNotifier<AnimalFormController> {
  const _AnimalFormScope({
    required AnimalFormController super.notifier,
    required super.child,
  });
}

/// Scope exposed by [AnimalFormItem] to let child input controls bind automatically.
class AnimalFormItemScope extends InheritedWidget {
  final String? name;
  final bool hasError;
  final String? errorText;
  final ValueChanged<dynamic>? onChanged;
  final VoidCallback? onBlur;
  final dynamic initialValue;
  final dynamic currentValue;
  final FocusNode? focusNode;

  const AnimalFormItemScope({
    super.key,
    required this.name,
    required this.hasError,
    required this.errorText,
    required this.onChanged,
    required this.onBlur,
    this.initialValue,
    this.currentValue,
    this.focusNode,
    required super.child,
  });

  static AnimalFormItemScope? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AnimalFormItemScope>();

  @override
  bool updateShouldNotify(covariant AnimalFormItemScope oldWidget) =>
      oldWidget.hasError != hasError ||
      oldWidget.errorText != errorText ||
      oldWidget.name != name ||
      oldWidget.initialValue != initialValue ||
      oldWidget.currentValue != currentValue ||
      oldWidget.onBlur != onBlur ||
      oldWidget.focusNode != focusNode;
}

/// Animal Island Form container component.
class AnimalForm extends StatefulWidget {
  final AnimalFormController? controller;
  final Widget child;
  final ValueChanged<Map<String, dynamic>>? onChanged;
  final VoidCallback? onSubmit;

  const AnimalForm({
    super.key,
    this.controller,
    required this.child,
    this.onChanged,
    this.onSubmit,
  });

  static AnimalFormController? of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_AnimalFormScope>();
    return scope?.notifier;
  }

  @override
  State<AnimalForm> createState() => _AnimalFormState();
}

class _AnimalFormState extends State<AnimalForm> {
  AnimalFormController? _internalController;
  late AnimalFormController _effectiveController;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = AnimalFormController();
      _effectiveController = _internalController!;
    } else {
      _effectiveController = widget.controller!;
    }
    _effectiveController.setSubmitCallback(widget.onSubmit);
    _effectiveController.addListener(_handleControllerChange);
  }

  @override
  void didUpdateWidget(covariant AnimalForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _effectiveController.removeListener(_handleControllerChange);
      if (widget.controller == null) {
        _internalController = AnimalFormController();
        _effectiveController = _internalController!;
      } else {
        if (_internalController != null) {
          _internalController!.dispose();
          _internalController = null;
        }
        _effectiveController = widget.controller!;
      }
      _effectiveController.setSubmitCallback(widget.onSubmit);
      _effectiveController.addListener(_handleControllerChange);
    } else if (oldWidget.onSubmit != widget.onSubmit) {
      _effectiveController.setSubmitCallback(widget.onSubmit);
    }
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleControllerChange);
    if (_internalController != null) {
      _internalController!.dispose();
      _internalController = null;
    }
    super.dispose();
  }

  void _handleControllerChange() {
    widget.onChanged?.call(_effectiveController.getFieldsValue());
  }

  @override
  Widget build(BuildContext context) {
    return _AnimalFormScope(
      notifier: _effectiveController,
      child: widget.child,
    );
  }
}

/// Animal Island Form Item layout component with label, validation rules,
/// and animated error feedback.
class AnimalFormItem extends StatefulWidget {
  final String? name;
  final String? label;
  final bool? required;
  final List<AnimalRule>? rules;
  final Widget child;
  final String? helperText;
  final dynamic initialValue;
  final FocusNode? focusNode;

  const AnimalFormItem({
    super.key,
    this.name,
    this.label,
    this.required,
    this.rules,
    required this.child,
    this.helperText,
    this.initialValue,
    this.focusNode,
  });

  @override
  State<AnimalFormItem> createState() => _AnimalFormItemState();
}

class _AnimalFormItemState extends State<AnimalFormItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late FocusNode _focusNode;
  AnimalFormController? _attachedController;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -4.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registerWithController();
    _checkAndTriggerShake();
  }

  @override
  void didUpdateWidget(covariant AnimalFormItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (oldWidget.focusNode == null) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
    }
    if (widget.name != oldWidget.name && oldWidget.name != null) {
      _attachedController?.unregisterField(oldWidget.name!);
    }
    _registerWithController();
    _checkAndTriggerShake();
  }

  void _registerWithController() {
    final controller = AnimalForm.of(context);
    if (controller != _attachedController) {
      if (_attachedController != null && widget.name != null) {
        _attachedController!.unregisterField(widget.name!);
      }
      _attachedController = controller;
    }
    if (widget.name != null && _attachedController != null) {
      _attachedController!.registerField(
        widget.name!,
        rules: widget.rules,
        initialValue: widget.initialValue,
        focusNode: _focusNode,
      );
    }
  }

  @override
  void dispose() {
    if (widget.name != null) {
      _attachedController?.unregisterField(widget.name!);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  void _checkAndTriggerShake() {
    final formController = AnimalForm.of(context);
    final currentError = widget.name != null && formController != null
        ? formController.getFieldError(widget.name!)
        : null;
    if (currentError != null && currentError != _lastError) {
      _lastError = currentError;
      _shakeController.forward(from: 0.0);
    } else if (currentError == null) {
      _lastError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AnimalIslandTheme.of(context);
    final formController = AnimalForm.of(context);

    final errorText = widget.name != null && formController != null
        ? formController.getFieldError(widget.name!)
        : null;

    final currentValue = widget.name != null && formController != null
        ? formController.getFieldValue(widget.name!)
        : widget.initialValue;

    final isRequired = widget.required ??
        (widget.rules?.any((r) => r.type == AnimalRuleType.required) ?? false);

    return AnimalFormItemScope(
      name: widget.name,
      hasError: errorText != null,
      errorText: errorText,
      initialValue: widget.initialValue,
      currentValue: currentValue,
      focusNode: _focusNode,
      onChanged: (val) {
        if (widget.name != null && formController != null) {
          formController.setFieldValue(widget.name!, val);
        }
      },
      onBlur: () {
        if (widget.name != null && formController != null) {
          formController.validateField(widget.name!);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.label != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRequired) ...[
                    Text(
                      '* ',
                      style: TextStyle(
                        color: theme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                  Text(
                    widget.label!,
                    style: AnimalTypography.subheading.copyWith(
                      fontSize: 14.0,
                      color: theme.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6.0),
            ],
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) => Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: child,
              ),
              child: widget.child,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: errorText != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 14,
                            color: theme.error,
                          ),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              errorText,
                              style: AnimalTypography.caption.copyWith(
                                color: theme.error,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : (widget.helperText != null
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                          child: Text(
                            widget.helperText!,
                            style: AnimalTypography.caption.copyWith(
                              color: theme.textSecondary,
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
            ),
          ],
        ),
      ),
    );
  }
}
