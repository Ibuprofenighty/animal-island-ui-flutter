/// Animal Island UI - A cozy Kawaii component library for Flutter.
///
/// Ported with enterprise-grade standards from guokaigdg/animal-island-ui.
///
/// Features:
/// - 36 Production-grade UI components
/// - 101 Native cute vector island icons
/// - 7 Canonical Design Laws & 14 Visual Hard Rules
/// - 3D tactile press depth & spring physics
library;

// =============================================================================
// 1. Design Tokens & Foundation Models
// =============================================================================
export 'src/foundation/theme/colors.dart'
    show AnimalThemeColors, AnimalTileColor, AnimalTileColors;
export 'src/foundation/theme/typography.dart' show AnimalThemeTypography;
export 'src/foundation/theme/shadows.dart' show AnimalThemeShadows;
export 'src/foundation/theme/radii.dart' show AnimalThemeRadii;
export 'src/foundation/theme/spacing.dart' show AnimalThemeSpacing;
export 'src/foundation/theme/motion.dart' show AnimalThemeMotion;
export 'src/foundation/theme/theme.dart' show AnimalIslandTheme;
export 'src/foundation/forms/animal_validation_issue.dart'
    show AnimalValidationIssue, AnimalValidationIssueKind;
export 'src/foundation/localization/animal_locale_resolution.dart'
    show resolveAnimalLocale;
export 'src/foundation/localization/generated/animal_localizations.g.dart'
    show AnimalLocalizations, lookupAnimalLocalizations;
export 'src/foundation/models/option.dart' show AnimalOption;
export 'src/foundation/models/date.dart' show AnimalDate, AnimalDateRange;
export 'src/foundation/models/time.dart' show AnimalTimeValue;
export 'src/foundation/models/clock.dart' show AnimalClock, SystemClock;

// =============================================================================
// 2. Overlay Realm & Scoped Host
// =============================================================================
export 'src/components/overlay_host/overlay_host.dart'
    show
        AnimalOverlayController,
        AnimalOverlayEntryHandle,
        AnimalOverlayEntryState,
        AnimalOverlayHost;

// =============================================================================
// 3. 101 Vector Icons
// =============================================================================
export 'src/icons/icon.dart' show AnimalIcon;
export 'src/icons/icon_data.dart' show AnimalIconData;
export 'src/icons/icons.g.dart' show AnimalIcons;

// =============================================================================
// 4. Canonical Component Categories (9 Distinct Design System Categories)
// =============================================================================

// Category 1: General (Button, Cursor, Typewriter, Icon)
export 'src/components/button/button.dart'
    show AnimalButton, AnimalButtonSize, AnimalButtonTone, AnimalButtonVariant;
export 'src/components/cursor/cursor.dart' show AnimalCursor, AnimalCursorType;
export 'src/components/typewriter/typewriter.dart' show AnimalTypewriter;

// Category 2: Structure & Navigation (Card, Title, Divider, Background, Collapse, Tabs, Carousel)
export 'src/components/card/card.dart'
    show AnimalCard, AnimalCardPattern, AnimalCardType;
export 'src/components/title/title.dart' show AnimalTitle, AnimalTitleSize;
export 'src/components/divider/divider.dart'
    show AnimalDivider, AnimalDividerType;
export 'src/components/background/background.dart'
    show AnimalBackground, AnimalBackgroundType;
export 'src/components/collapse/collapse.dart'
    show AnimalCollapse, AnimalCollapseItem;
export 'src/components/tabs/tabs.dart' show AnimalTabItem, AnimalTabs;
export 'src/components/carousel/carousel.dart' show AnimalCarousel;

// Category 3: Form Controls (Input, Switch, Checkbox, Radio, Select, DatePicker, TimePicker)
export 'src/components/input/input.dart'
    show AnimalInput, AnimalInputSize, AnimalInputStatus;
export 'src/components/switch/switch.dart' show AnimalSwitch, AnimalSwitchSize;
export 'src/components/checkbox/checkbox.dart'
    show AnimalCheckbox, AnimalCheckboxSize;
export 'src/components/checkbox/checkbox_group.dart' show AnimalCheckboxGroup;
export 'src/components/radio/radio.dart' show AnimalRadio, AnimalRadioSize;
export 'src/components/radio/radio_group.dart' show AnimalRadioGroup;
export 'src/components/select/select.dart' show AnimalSelect;
export 'src/components/date_picker/date_picker.dart'
    show AnimalDatePicker, AnimalDatePickerMode;
export 'src/components/time_picker/time_picker.dart' show AnimalTimePicker;

// Category 4: Form Container (Form, FormItem, Controller, Bindings, Validation)
export 'src/components/form/form.dart' show AnimalForm;
export 'src/components/form/form_controller.dart'
    show AnimalFormController, AnimalSubmitResult, AnimalSubmitStatus;
export 'src/components/form/form_item.dart' show AnimalFormItem;
export 'src/components/form/field_key.dart' show AnimalFieldKey;
export 'src/components/form/field_binding.dart' show AnimalFieldBinding;
export 'src/components/form/validation.dart'
    show AnimalRule, AnimalRuleType, AnimalValidationStatus;

// Category 5: Overlays (Modal, Drawer, Tooltip)
export 'src/components/modal/modal.dart' show AnimalModal;
export 'src/components/drawer/drawer.dart'
    show AnimalDrawer, AnimalDrawerPlacement;
export 'src/components/tooltip/tooltip.dart'
    show AnimalTooltip, AnimalTooltipVariant;

// Category 6: Feedback & Animation (Progress, Loading, Skeleton, BackTop, Countdown, Time)
export 'src/components/progress/progress.dart'
    show
        AnimalProgress,
        AnimalProgressInfoPosition,
        AnimalProgressSize,
        AnimalProgressStatus;
export 'src/components/loading/loading.dart'
    show AnimalLoading, AnimalLoadingHandle, AnimalLoadingType;
export 'src/components/skeleton/skeleton.dart'
    show AnimalSkeleton, AnimalSkeletonVariant;
export 'src/components/back_top/back_top.dart' show AnimalBackTop;
export 'src/components/countdown/countdown.dart'
    show AnimalCountdown, AnimalCountdownSize, AnimalCountdownVariant;
export 'src/components/time/time.dart' show AnimalTime;

// Category 7: Notification (Notification Imperative API & Portal)
export 'src/components/notification/notification.dart'
    show
        AnimalNotification,
        AnimalNotificationPlacement,
        AnimalNotificationType;

// Category 8: Data Display (Table, Pagination, CodeBlock, Tag, Image)
export 'src/components/table/table.dart'
    show AnimalTable, AnimalTableRowBuilder, AnimalTableRowKey;
export 'src/components/table/table_column.dart' show AnimalTableColumn;
export 'src/components/pagination/pagination.dart' show AnimalPagination;
export 'src/components/code_block/code_block.dart' show AnimalCodeBlock;
export 'src/components/tag/tag.dart'
    show AnimalTag, AnimalTagSize, AnimalTagVariant;
export 'src/components/image/image.dart' show AnimalImage, AnimalImageVariant;

// Category 9: Decorative (Footer)
export 'src/components/footer/footer.dart' show AnimalFooter, AnimalFooterType;
