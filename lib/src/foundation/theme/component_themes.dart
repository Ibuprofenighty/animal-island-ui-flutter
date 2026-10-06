import 'package:flutter/foundation.dart';

import 'components/checkbox_theme.dart';
import 'components/date_picker_theme.dart';
import 'components/focus_ring_theme.dart';
import 'components/form_item_theme.dart';
import 'components/input_theme.dart';
import 'components/radio_theme.dart';
import 'components/select_theme.dart';
import 'components/switch_theme.dart';
import 'components/time_picker_theme.dart';

/// Component-level overrides carried by `AnimalIslandTheme.components`.
///
/// Every entry is optional. An absent entry means the component uses defaults
/// derived from the theme's token families, so the presets need no entries.
/// A component with size presets has a `*ThemeData` entry holding a general
/// style and one style per size; other components take their style directly.
@immutable
class AnimalComponentThemes {
  final AnimalFocusRingStyle? focusRing;
  final AnimalInputThemeData? input;
  final AnimalSwitchThemeData? switchControl;
  final AnimalCheckboxThemeData? checkbox;
  final AnimalRadioThemeData? radio;
  final AnimalSelectStyle? select;
  final AnimalDatePickerStyle? datePicker;
  final AnimalTimePickerStyle? timePicker;
  final AnimalFormItemStyle? formItem;

  const AnimalComponentThemes({
    this.focusRing,
    this.input,
    this.switchControl,
    this.checkbox,
    this.radio,
    this.select,
    this.datePicker,
    this.timePicker,
    this.formItem,
  });

  AnimalComponentThemes copyWith({
    AnimalFocusRingStyle? focusRing,
    AnimalInputThemeData? input,
    AnimalSwitchThemeData? switchControl,
    AnimalCheckboxThemeData? checkbox,
    AnimalRadioThemeData? radio,
    AnimalSelectStyle? select,
    AnimalDatePickerStyle? datePicker,
    AnimalTimePickerStyle? timePicker,
    AnimalFormItemStyle? formItem,
  }) => AnimalComponentThemes(
    focusRing: focusRing ?? this.focusRing,
    input: input ?? this.input,
    switchControl: switchControl ?? this.switchControl,
    checkbox: checkbox ?? this.checkbox,
    radio: radio ?? this.radio,
    select: select ?? this.select,
    datePicker: datePicker ?? this.datePicker,
    timePicker: timePicker ?? this.timePicker,
    formItem: formItem ?? this.formItem,
  );

  AnimalComponentThemes lerp(AnimalComponentThemes other, double t) {
    if (t == 0) return this;
    if (t == 1) return other;
    return AnimalComponentThemes(
      focusRing: AnimalFocusRingStyle.lerp(focusRing, other.focusRing, t),
      input: AnimalInputThemeData.lerp(input, other.input, t),
      switchControl: AnimalSwitchThemeData.lerp(
        switchControl,
        other.switchControl,
        t,
      ),
      checkbox: AnimalCheckboxThemeData.lerp(checkbox, other.checkbox, t),
      radio: AnimalRadioThemeData.lerp(radio, other.radio, t),
      select: AnimalSelectStyle.lerp(select, other.select, t),
      datePicker: AnimalDatePickerStyle.lerp(datePicker, other.datePicker, t),
      timePicker: AnimalTimePickerStyle.lerp(timePicker, other.timePicker, t),
      formItem: AnimalFormItemStyle.lerp(formItem, other.formItem, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnimalComponentThemes &&
          focusRing == other.focusRing &&
          input == other.input &&
          switchControl == other.switchControl &&
          checkbox == other.checkbox &&
          radio == other.radio &&
          select == other.select &&
          datePicker == other.datePicker &&
          timePicker == other.timePicker &&
          formItem == other.formItem;

  @override
  int get hashCode => Object.hash(
    focusRing,
    input,
    switchControl,
    checkbox,
    radio,
    select,
    datePicker,
    timePicker,
    formItem,
  );
}
