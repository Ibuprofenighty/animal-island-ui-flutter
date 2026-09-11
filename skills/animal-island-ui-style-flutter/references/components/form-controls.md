# Form Controls Reference

## Option Model
```dart
class AnimalOption<T> {
  final T value;
  final String label;
  final bool disabled;
  final Widget? icon;
  const AnimalOption({required this.value, required this.label, this.disabled = false, this.icon});
}
```

## Input
```dart
AnimalInput({
  Key? key,
  TextEditingController? controller,
  String? initialValue,
  String? placeholder,
  AnimalInputSize size = AnimalInputSize.middle, // small: 34, middle: 44, large: 52
  Widget? prefix,
  Widget? suffix,
  bool clearable = false,
  bool shadow = false,
  bool disabled = false,
  bool readOnly = false,
  bool obscureText = false,
  AnimalInputStatus status = AnimalInputStatus.normal,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  TextInputType keyboardType = TextInputType.text,
  TextInputAction textInputAction = TextInputAction.done,
  FocusNode? focusNode,
})
```

## Switch
```dart
AnimalSwitch({
  Key? key,
  required bool value,
  required ValueChanged<bool>? onChanged,
  AnimalSwitchSize size = AnimalSwitchSize.defaultSize, // small: 46x26, defaultSize: 58x32
  bool disabled = false,
  bool loading = false,
  Widget? checkedChildren,
  Widget? unCheckedChildren,
  FocusNode? focusNode,
})
```

## Checkbox
```dart
AnimalCheckbox({
  Key? key,
  required bool value,
  required ValueChanged<bool>? onChanged,
  Widget? label,
  bool disabled = false,
  AnimalCheckboxSize size = AnimalCheckboxSize.middle, // small: 18, middle: 22, large: 26
  FocusNode? focusNode,
})

AnimalCheckboxGroup<T>({
  Key? key,
  required List<AnimalOption<T>> options,
  required List<T> value,
  ValueChanged<List<T>>? onChanged,
  Axis direction = Axis.horizontal,
  bool disabled = false,
  AnimalCheckboxSize size = AnimalCheckboxSize.middle,
  double spacing = 16.0,
  FocusNode? focusNode,
})
```

## Radio
```dart
AnimalRadio<T>({
  Key? key,
  required T value,
  required T? groupValue,
  required ValueChanged<T>? onChanged,
  Widget? label,
  bool disabled = false,
  AnimalRadioSize size = AnimalRadioSize.middle, // small: 18, middle: 22, large: 26
  Color? activeColor,
  FocusNode? focusNode,
})

AnimalRadioGroup<T>({
  Key? key,
  required List<AnimalOption<T>> options,
  required T? value,
  ValueChanged<T>? onChanged,
  Axis direction = Axis.horizontal,
  bool disabled = false,
  AnimalRadioSize size = AnimalRadioSize.middle,
  double spacing = 16.0,
  Color? activeColor,
  FocusNode? focusNode,
})
```

## Select
```dart
AnimalSelect<T>({
  Key? key,
  required T? value,
  required List<AnimalOption<T>> options,
  required ValueChanged<T?>? onChanged,
  String placeholder = 'Please select',
  bool disabled = false,
  bool allowClear = false,
  AnimalInputStatus status = AnimalInputStatus.normal,
  FocusNode? focusNode,
})
```

## DatePicker
```dart
AnimalDatePicker({
  Key? key,
  DateTime? value,
  DateTimeRange? rangeValue,
  bool range = false,
  AnimalDatePickerMode picker = AnimalDatePickerMode.date, // date | month
  ValueChanged<DateTime?>? onChanged,
  ValueChanged<DateTimeRange?>? onRangeChanged,
  DateTime? firstDate,
  DateTime? lastDate,
  bool Function(DateTime date)? disabledDate,
  bool showToday = true,
  bool allowClear = true,
  bool disabled = false,
  FocusNode? focusNode,
})

// Popover: AnimalDatePicker.popover({Key? key, DateTime? value, DateTimeRange? rangeValue, bool range = false, AnimalDatePickerMode picker = AnimalDatePickerMode.date, ValueChanged<DateTime?>? onChanged, ValueChanged<DateTimeRange?>? onRangeChanged, DateTime? firstDate, DateTime? lastDate, bool Function(DateTime date)? disabledDate, String? placeholder, bool showToday = true, bool allowClear = true, bool disabled = false, AnimalInputStatus status = AnimalInputStatus.normal, FocusNode? focusNode})
```

## TimePicker
```dart
AnimalTimePicker({
  Key? key,
  required TimeOfDay? value,
  required ValueChanged<TimeOfDay?>? onChanged,
  int? second,
  void Function(int? hour, int? minute, int? second)? onFullTimeChanged,
  String format = 'HH:mm',
  int hourStep = 1,
  int minuteStep = 1,
  int secondStep = 1,
  bool showNow = true,
  bool allowClear = true,
  bool disabled = false,
  FocusNode? focusNode,
})

// Popover: AnimalTimePicker.popover({Key? key, TimeOfDay? value, int? second, ValueChanged<TimeOfDay?>? onChanged, void Function(int? hour, int? minute, int? second)? onFullTimeChanged, String format = 'HH:mm', int hourStep = 1, int minuteStep = 1, int secondStep = 1, String? placeholder, bool showNow = true, bool allowClear = true, bool disabled = false, AnimalInputStatus status = AnimalInputStatus.normal, FocusNode? focusNode})
```
