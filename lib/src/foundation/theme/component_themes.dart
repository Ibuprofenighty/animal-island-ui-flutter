import 'package:flutter/foundation.dart';

import 'components/checkbox_theme.dart';
import 'components/date_picker_theme.dart';
import 'components/drawer_theme.dart';
import 'components/focus_ring_theme.dart';
import 'components/form_item_theme.dart';
import 'components/input_theme.dart';
import 'components/loading_theme.dart';
import 'components/modal_theme.dart';
import 'components/notification_theme.dart';
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
  final AnimalNotificationStyle? notification;
  final AnimalLoadingStyle? loading;
  final AnimalModalStyle? modal;
  final AnimalDrawerStyle? drawer;

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
    this.notification,
    this.loading,
    this.modal,
    this.drawer,
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
    AnimalNotificationStyle? notification,
    AnimalLoadingStyle? loading,
    AnimalModalStyle? modal,
    AnimalDrawerStyle? drawer,
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
    notification: notification ?? this.notification,
    loading: loading ?? this.loading,
    modal: modal ?? this.modal,
    drawer: drawer ?? this.drawer,
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
      notification: AnimalNotificationStyle.lerp(
        notification,
        other.notification,
        t,
      ),
      loading: AnimalLoadingStyle.lerp(loading, other.loading, t),
      modal: AnimalModalStyle.lerp(modal, other.modal, t),
      drawer: AnimalDrawerStyle.lerp(drawer, other.drawer, t),
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
          formItem == other.formItem &&
          notification == other.notification &&
          loading == other.loading &&
          modal == other.modal &&
          drawer == other.drawer;

  @override
  int get hashCode => Object.hashAll(<Object?>[
    focusRing,
    input,
    switchControl,
    checkbox,
    radio,
    select,
    datePicker,
    timePicker,
    formItem,
    notification,
    loading,
    modal,
    drawer,
  ]);
}
