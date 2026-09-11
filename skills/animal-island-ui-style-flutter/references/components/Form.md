# Form Container Reference

## Form

```dart
AnimalForm({
  Key? key,
  AnimalFormController? controller,
  ValueChanged<Map<String, dynamic>>? onChanged,
  VoidCallback? onSubmit,
  required Widget child,
})
```

`AnimalFormController` methods:
- `validateFields([List<String>? names]) -> Future<bool>`
- `validateField(String name) -> Future<String?>`
- `getFieldValue(String name) -> dynamic`
- `getFieldsValue() -> Map<String, dynamic>`
- `setFieldValue(String name, dynamic value, {bool validate = true})`
- `setFieldsValue(Map<String, dynamic> values, {bool validate = false})`
- `getFieldError(String name) -> String?`
- `resetFields([List<String>? names])`

## FormItem

```dart
AnimalFormItem({
  Key? key,
  String? name,
  String? label,
  bool? required,
  List<AnimalRule>? rules,
  String? helperText,
  dynamic initialValue,
  required Widget child,
})
```

`AnimalRule` factories:
- `AnimalRule.required({String? message})`
- `AnimalRule.email({String? message})`
- `AnimalRule.url({String? message})`
- `AnimalRule.pattern(RegExp pattern, {String? message})`
- `AnimalRule.min(num min, {String? message})`
- `AnimalRule.max(num max, {String? message})`
- `AnimalRule.length({int? min, int? max, String? message})`
- `AnimalRule.custom(FutureOr<String?> Function(dynamic value) validator)`
