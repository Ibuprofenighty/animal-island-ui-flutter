import 'dart:ui';

import '../field_status.dart';
import '../palette.dart';

/// Shared DatePicker/TimePicker recipe: trigger, panel, footer and cells.
/// These pickers keep a fixed light surface in every theme.
abstract final class PickerColors {
  // Trigger.
  static const triggerFill = Primitive.sand986;
  static const triggerFillDisabled = Primitive.sand931;
  static const triggerOpenGlow = Primitive.yellow866A15;

  /// Reference `.wrapper-disabled .value/.placeholder`; disabled controls
  /// are exempt from the text contrast budget.
  static const disabledText = Primitive.sand786;

  /// Underline under the 1.5px trigger outline, or null for none. Error
  /// #c94444 (4.6:1 on the fill); warning #dba90e deepens in hue to #af8600
  /// (3.2:1). Hover/focus and open cues are decorative and keep the reference.
  static Color? triggerUnderline(
    IslandFieldStatus status, {
    required bool open,
    required bool active,
  }) => switch (status) {
    IslandFieldStatus.error => Primitive.red574,
    IslandFieldStatus.warning => Primitive.yellow642,
    IslandFieldStatus.normal =>
      open
          ? Primitive.yellow795
          : active
          ? Primitive.sand786
          : null,
  };

  /// Clear glyph and its circular hover fill (reference `.clear:hover`).
  static const clearHover = Primitive.brown492;
  static const clearHoverFill = Primitive.brown492A10;

  // Panel.
  static const panelFill = Primitive.neutral994;
  static const panelBorder = Primitive.sand899;
  static const panelShadow = Primitive.brown331A12;
  static const footerDivider = Primitive.sand933;

  /// Footer secondary/hover fill and the primary action's rest fill.
  static const footerActionFill = Primitive.brown492A10;
  static const footerPrimaryHoverInk = Primitive.neutral1000;

  /// Confirm hover: the DatePicker reference #796c5a, shared by TimePicker
  /// (its own #8a7b66 gives white text only 4.1:1).
  static const confirmHover = Primitive.sand538;

  // Calendar and time cells.
  static const text = Primitive.brown492;
  static const rangeDivider = Primitive.sand899;
  static const navHoverFill = Primitive.brown492A10;
  static const headingHoverFill = Primitive.teal967;
  static const dayDisabled = Primitive.sand839;
  static const daySelected = Primitive.teal750;
  static const daySelectedHover = Primitive.teal790;
  static const dayHover = Primitive.teal967;
  static const rangeSelected = Primitive.yellow844;
  static const rangeSelectedHover = Primitive.yellow820;
  static const rangeHover = Primitive.yellow886;

  /// Reference `.dayCellRangeStart/End` 1px white contour (decorative).
  static const rangeEndpointRing = Primitive.neutral1000;
  static const timeSelected = Primitive.yellow820;
  static const timeHover = Primitive.yellow886;
}
