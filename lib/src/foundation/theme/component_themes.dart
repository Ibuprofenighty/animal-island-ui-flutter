import 'package:flutter/foundation.dart';

import 'components/collapse_theme.dart';
import 'components/tabs_theme.dart';
import 'components/carousel_theme.dart';
import 'components/table_theme.dart';
import 'components/pagination_theme.dart';
import 'components/checkbox_theme.dart';
import 'components/countdown_theme.dart';
import 'components/date_picker_theme.dart';
import 'components/drawer_theme.dart';
import 'components/focus_ring_theme.dart';
import 'components/form_item_theme.dart';
import 'components/input_theme.dart';
import 'components/loading_theme.dart';
import 'components/modal_theme.dart';
import 'components/notification_theme.dart';
import 'components/progress_theme.dart';
import 'components/radio_theme.dart';
import 'components/select_theme.dart';
import 'components/skeleton_theme.dart';
import 'components/switch_theme.dart';
import 'components/time_picker_theme.dart';
import 'components/time_theme.dart';
import 'components/typewriter_theme.dart';

/// Component-level overrides carried by `AnimalIslandTheme.components`.
///
/// Every entry is optional. An absent entry means the component uses defaults
/// derived from the theme's token families, so the presets need no entries.
/// A component with size presets has a `*ThemeData` entry holding a general
/// style and one style per size; other components take their style directly.
@immutable
class AnimalComponentThemes {
  /// Overrides for the focus ring drawn by focusable components.
  final AnimalFocusRingStyle? focusRing;

  /// Overrides for `AnimalInput`.
  final AnimalInputThemeData? input;

  /// Overrides for `AnimalSwitch`.
  final AnimalSwitchThemeData? switchControl;

  /// Overrides for `AnimalCheckbox`.
  final AnimalCheckboxThemeData? checkbox;

  /// Overrides for `AnimalRadio`.
  final AnimalRadioThemeData? radio;

  /// Overrides for `AnimalSelect`.
  final AnimalSelectStyle? select;

  /// Overrides for `AnimalDatePicker`.
  final AnimalDatePickerStyle? datePicker;

  /// Overrides for `AnimalTimePicker`.
  final AnimalTimePickerStyle? timePicker;

  /// Overrides for `AnimalFormItem`.
  final AnimalFormItemStyle? formItem;

  /// Overrides for notifications shown through `AnimalNotification`.
  final AnimalNotificationStyle? notification;

  /// Overrides for `AnimalLoading`.
  final AnimalLoadingStyle? loading;

  /// Overrides for `AnimalModal`.
  final AnimalModalStyle? modal;

  /// Overrides for `AnimalDrawer`.
  final AnimalDrawerStyle? drawer;

  /// Overrides for `AnimalTypewriter`.
  final AnimalTypewriterStyle? typewriter;

  /// Overrides for `AnimalProgress`.
  final AnimalProgressThemeData? progress;

  /// Overrides for `AnimalSkeleton`.
  final AnimalSkeletonStyle? skeleton;

  /// Overrides for `AnimalCountdown`.
  final AnimalCountdownThemeData? countdown;

  /// Overrides for `AnimalTime`.
  final AnimalTimeStyle? time;

  /// Overrides for AnimalCollapse.
  final AnimalCollapseStyle? collapse;

  /// Overrides for AnimalTabs.
  final AnimalTabsStyle? tabs;

  /// Overrides for AnimalCarousel.
  final AnimalCarouselStyle? carousel;

  /// Overrides for AnimalTable.
  final AnimalTableStyle? table;

  /// Overrides for AnimalPagination.
  final AnimalPaginationStyle? pagination;

  /// Creates component overrides; every entry defaults to null.
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
    this.typewriter,
    this.progress,
    this.skeleton,
    this.countdown,
    this.time,
    this.collapse,
    this.tabs,
    this.carousel,
    this.table,
    this.pagination,
  });

  /// Returns a copy of these overrides with the given fields replaced.
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
    AnimalTypewriterStyle? typewriter,
    AnimalProgressThemeData? progress,
    AnimalSkeletonStyle? skeleton,
    AnimalCountdownThemeData? countdown,
    AnimalTimeStyle? time,
    AnimalCollapseStyle? collapse,
    AnimalTabsStyle? tabs,
    AnimalCarouselStyle? carousel,
    AnimalTableStyle? table,
    AnimalPaginationStyle? pagination,
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
    typewriter: typewriter ?? this.typewriter,
    progress: progress ?? this.progress,
    skeleton: skeleton ?? this.skeleton,
    countdown: countdown ?? this.countdown,
    time: time ?? this.time,
    collapse: collapse ?? this.collapse,
    tabs: tabs ?? this.tabs,
    carousel: carousel ?? this.carousel,
    table: table ?? this.table,
    pagination: pagination ?? this.pagination,
  );

  /// Linearly interpolates each entry between these overrides and [other].
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
      typewriter: AnimalTypewriterStyle.lerp(typewriter, other.typewriter, t),
      progress: AnimalProgressThemeData.lerp(progress, other.progress, t),
      skeleton: AnimalSkeletonStyle.lerp(skeleton, other.skeleton, t),
      countdown: AnimalCountdownThemeData.lerp(countdown, other.countdown, t),
      time: AnimalTimeStyle.lerp(time, other.time, t),
      collapse: AnimalCollapseStyle.lerp(collapse, other.collapse, t),
      tabs: AnimalTabsStyle.lerp(tabs, other.tabs, t),
      carousel: AnimalCarouselStyle.lerp(carousel, other.carousel, t),
      table: AnimalTableStyle.lerp(table, other.table, t),
      pagination: AnimalPaginationStyle.lerp(pagination, other.pagination, t),
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
          drawer == other.drawer &&
          typewriter == other.typewriter &&
          progress == other.progress &&
          skeleton == other.skeleton &&
          countdown == other.countdown &&
          time == other.time &&
          collapse == other.collapse &&
          tabs == other.tabs &&
          carousel == other.carousel &&
          table == other.table &&
          pagination == other.pagination;

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
    typewriter,
    progress,
    skeleton,
    countdown,
    time,
    collapse,
    tabs,
    carousel,
    table,
    pagination,
  ]);
}
