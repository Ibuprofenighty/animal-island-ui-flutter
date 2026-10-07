// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'animal_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AnimalLocalizationsEn extends AnimalLocalizations {
  AnimalLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get clear => 'Clear';

  @override
  String get now => 'Now';

  @override
  String get today => 'Today';

  @override
  String get copied => 'Copied!';

  @override
  String get copyFailed => 'Copy Failed';

  @override
  String get loading => 'Loading...';

  @override
  String get empty => 'No Data';

  @override
  String get backToTop => 'Back to Top';

  @override
  String get requiredField => 'This field is required';

  @override
  String get footerDefaultText => 'Animal Island UI • Crafted with cozy care';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get selectPlaceholder => 'Please select';

  @override
  String get datePickerSinglePlaceholder => 'Select date';

  @override
  String get datePickerRangePlaceholder => 'Select date range';

  @override
  String get datePickerPreviousYear => 'Previous year';

  @override
  String get datePickerNextYear => 'Next year';

  @override
  String get clearDate => 'Clear date';

  @override
  String get timePickerPlaceholder => 'Select time';

  @override
  String get timePickerTitle => 'Select time';

  @override
  String get clearTime => 'Clear time';

  @override
  String timePickerWheelValue(int value, String unit) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value hours',
      one: '$value hour',
    );
    String _temp1 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value minutes',
      one: '$value minute',
    );
    String _temp2 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value seconds',
      one: '$value second',
    );
    String _temp3 = intl.Intl.selectLogic(unit, {
      'hours': '$_temp0',
      'minutes': '$_temp1',
      'seconds': '$_temp2',
      'other': '$value',
    });
    return '$_temp3';
  }

  @override
  String get inputClearLabel => 'Clear input';

  @override
  String get switchSemanticLabel => 'Switch';

  @override
  String get selectClearLabel => 'Clear selection';

  @override
  String get carouselPreviousSlide => 'Previous slide';

  @override
  String get carouselNextSlide => 'Next slide';

  @override
  String carouselSlidePosition(int index, int total) {
    return 'Slide $index of $total';
  }

  @override
  String get modalConfirm => 'Confirm';

  @override
  String get modalContinue => 'Continue';

  @override
  String get modalCloseLabel => 'Close modal';

  @override
  String get modalRouteLabel => 'Dialog';

  @override
  String get drawerRouteLabel => 'Drawer';

  @override
  String get drawerCloseLabel => 'Close drawer';

  @override
  String get progressLabel => 'Progress';

  @override
  String get circularProgressLabel => 'Circular progress';

  @override
  String get notificationDismissLabel => 'Dismiss notification';

  @override
  String get tableLoadingLabel => 'Loading table data';

  @override
  String paginationNavigation(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get paginationPrevious => 'Previous page';

  @override
  String get paginationNext => 'Next page';

  @override
  String get paginationSkipBackward => 'Skip five pages backward';

  @override
  String get paginationSkipForward => 'Skip five pages forward';

  @override
  String paginationPage(int page) {
    return 'Page $page';
  }

  @override
  String get codeCopyLabel => 'Copy';

  @override
  String get codeCopySemanticLabel => 'Copy code to clipboard';

  @override
  String get codeCopiedSemanticLabel => 'Code copied to clipboard';

  @override
  String get codeDefaultLanguage => 'dart';

  @override
  String get tagRemoveLabel => 'Remove tag';

  @override
  String get imagePreviewCloseLabel => 'Close preview';

  @override
  String get imagePreviewRouteLabel => 'Image preview';

  @override
  String imagePreviewSemanticLabel(String label) {
    return '$label, click to preview';
  }

  @override
  String get imagePreviewDefaultSemanticLabel => 'Preview image';

  @override
  String get currentTimeLabel => 'Current time';

  @override
  String countdownRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds remaining',
      one: '$count second remaining',
      zero: 'No time remaining',
    );
    return '$_temp0';
  }

  @override
  String get countdownUnitDays => 'DAYS';

  @override
  String get countdownUnitHours => 'HOURS';

  @override
  String get countdownUnitMinutes => 'MINS';

  @override
  String get countdownUnitSeconds => 'SECS';

  @override
  String get validationEmail => 'Please enter a valid email address';

  @override
  String get validationUrl => 'Please enter a valid URL';

  @override
  String get validationPattern => 'Value does not match the required pattern';

  @override
  String validationMinimum(num value) {
    return 'Value must be at least $value';
  }

  @override
  String validationMaximum(num value) {
    return 'Value cannot exceed $value';
  }

  @override
  String validationLengthMinimum(int minimum) {
    return 'Length must be at least $minimum';
  }

  @override
  String validationLengthMaximum(int maximum) {
    return 'Length cannot exceed $maximum';
  }

  @override
  String validationLengthRange(int minimum, int maximum) {
    return 'Length must be between $minimum and $maximum';
  }

  @override
  String get validationFailure => 'Validation could not be completed';

  @override
  String iconSemanticName(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'airplane': 'Airplane',
      'anchor': 'Anchor',
      'apple': 'Apple',
      'balloon': 'Balloon',
      'bear': 'Bear',
      'bee': 'Bee',
      'bell': 'Bell',
      'bicycle': 'Bicycle',
      'bird': 'Bird',
      'book': 'Book',
      'bookmark': 'Bookmark',
      'bulb': 'Light bulb',
      'butterfly': 'Butterfly',
      'cactus': 'Cactus',
      'cake': 'Cake',
      'calendar': 'Calendar',
      'camera': 'Camera',
      'candle': 'Candle',
      'car': 'Car',
      'cart': 'Cart',
      'cat': 'Cat',
      'chat': 'Chat',
      'check': 'Check',
      'cherry': 'Cherry',
      'clock': 'Clock',
      'close': 'Close',
      'cloud': 'Cloud',
      'code': 'Code',
      'coffee': 'Coffee',
      'compass': 'Compass',
      'creditCard': 'Credit card',
      'dog': 'Dog',
      'donut': 'Doughnut',
      'download': 'Download',
      'edit': 'Edit',
      'eye': 'Eye',
      'file': 'File',
      'fish': 'Fish',
      'flag': 'Flag',
      'flame': 'Flame',
      'flower': 'Flower',
      'folder': 'Folder',
      'fox': 'Fox',
      'frog': 'Frog',
      'gift': 'Gift',
      'globe': 'Globe',
      'headphones': 'Headphones',
      'heart': 'Heart',
      'home': 'Home',
      'icecream': 'Ice cream',
      'image': 'Image',
      'key': 'Key',
      'ladybug': 'Ladybug',
      'lamp': 'Lamp',
      'leaf': 'Leaf',
      'lemon': 'Lemon',
      'location': 'Location',
      'lock': 'Lock',
      'magnet': 'Magnet',
      'mail': 'Mail',
      'map': 'Map',
      'mic': 'Microphone',
      'moon': 'Moon',
      'mushroom': 'Mushroom',
      'music': 'Music',
      'owl': 'Owl',
      'paintbrush': 'Paintbrush',
      'pencil': 'Pencil',
      'penguin': 'Penguin',
      'phone': 'Phone',
      'play': 'Play',
      'plus': 'Plus',
      'rabbit': 'Rabbit',
      'rainbow': 'Rainbow',
      'refresh': 'Refresh',
      'rocket': 'Rocket',
      'sailboat': 'Sailboat',
      'save': 'Save',
      'search': 'Search',
      'settings': 'Settings',
      'share': 'Share',
      'shoppingBag': 'Shopping bag',
      'smile': 'Smile',
      'snail': 'Snail',
      'snowflake': 'Snowflake',
      'star': 'Star',
      'strawberry': 'Strawberry',
      'sun': 'Sun',
      'tag': 'Tag',
      'thermometer': 'Thermometer',
      'thumbsUp': 'Thumbs up',
      'train': 'Train',
      'trash': 'Trash',
      'tree': 'Tree',
      'trophy': 'Trophy',
      'umbrella': 'Umbrella',
      'upload': 'Upload',
      'user': 'User',
      'video': 'Video',
      'watermelon': 'Watermelon',
      'wifi': 'Wi-Fi',
      'other': 'Icon',
    });
    return '$_temp0';
  }

  @override
  String get galleryAppTitle => 'Animal Island UI Gallery';

  @override
  String get galleryBrandName => 'Animal Island UI';

  @override
  String get gallerySearchTooltip => 'Search the gallery';

  @override
  String get gallerySearchAction => 'Search';

  @override
  String get galleryLocaleSwitch => 'Switch language';

  @override
  String get galleryLocaleSwitchValue => 'EN / 中文';

  @override
  String get galleryTextScaleTooltip => 'Text scale multiplier';

  @override
  String get galleryReducedMotionOn => 'Motion: reduced';

  @override
  String get galleryReducedMotionOff => 'Motion: normal';

  @override
  String get galleryThemeTooltip => 'Toggle theme';

  @override
  String get galleryThemeDark => 'Dark';

  @override
  String get galleryThemeLight => 'Light';

  @override
  String get galleryCategoryExplore => 'Explore & Evidence';

  @override
  String get galleryCategoryRecipes => 'Interactive Recipes (E2E)';

  @override
  String get galleryCategoryGeneral => '1. General';

  @override
  String get galleryCategoryLayout => '2. Structure & Layout';

  @override
  String get galleryCategoryNavigation => '3. Navigation';

  @override
  String get galleryCategoryFormControls => '4. Form Controls';

  @override
  String get galleryCategoryFormEngine => '5. Form Engine';

  @override
  String get galleryCategoryOverlays => '6. Overlays';

  @override
  String get galleryCategoryFeedback => '7. Feedback & Animation';

  @override
  String get galleryCategoryNotifications => '8. Notification';

  @override
  String get galleryCategoryDataDisplay => '9. Data Display';

  @override
  String get galleryCategoryDecorative => '10. Decorative';

  @override
  String get galleryOverviewNav => 'Overview';

  @override
  String galleryCount(int count) {
    return '$count';
  }

  @override
  String get galleryRecipeBadge => 'E2E';

  @override
  String get galleryDevelopmentCandidateBadge => 'Development candidate';

  @override
  String galleryTextScaleValue(num scale) {
    final intl.NumberFormat scaleNumberFormat =
        intl.NumberFormat.decimalPatternDigits(
          locale: localeName,
          decimalDigits: 1,
        );
    final String scaleString = scaleNumberFormat.format(scale);

    return '$scaleString×';
  }

  @override
  String get galleryIconsNav => '101 Vector Icons';

  @override
  String get galleryProvenanceNav => 'Build Provenance';

  @override
  String get galleryRecipeFormNav => 'Form & Async Validation';

  @override
  String get galleryRecipeOverlayNav => 'Overlay Orchestration';

  @override
  String get galleryRecipeTableNav => 'Data Table & Gallery';

  @override
  String get galleryComponentC01 => 'Button (C01)';

  @override
  String get galleryComponentC02 => 'Icon (C02)';

  @override
  String get galleryComponentC03 => 'Typewriter (C03)';

  @override
  String get galleryComponentC04 => 'Cursor (C04)';

  @override
  String get galleryComponentC05 => 'Card (C05)';

  @override
  String get galleryComponentC06 => 'Title (C06)';

  @override
  String get galleryComponentC07 => 'Divider (C07)';

  @override
  String get galleryComponentC08 => 'Background (C08)';

  @override
  String get galleryComponentC09 => 'Collapse (C09)';

  @override
  String get galleryComponentC10 => 'Tabs (C10)';

  @override
  String get galleryComponentC11 => 'Carousel (C11)';

  @override
  String get galleryComponentC12 => 'Input (C12)';

  @override
  String get galleryComponentC13 => 'Switch (C13)';

  @override
  String get galleryComponentC14 => 'Checkbox (C14)';

  @override
  String get galleryComponentC15 => 'Radio (C15)';

  @override
  String get galleryComponentC16 => 'Select (C16)';

  @override
  String get galleryComponentC17 => 'DatePicker (C17)';

  @override
  String get galleryComponentC18 => 'TimePicker (C18)';

  @override
  String get galleryComponentC19 => 'Form (C19)';

  @override
  String get galleryComponentC20 => 'FormItem (C20)';

  @override
  String get galleryComponentC21 => 'Modal (C21)';

  @override
  String get galleryComponentC22 => 'Drawer (C22)';

  @override
  String get galleryComponentC23 => 'Tooltip (C23)';

  @override
  String get galleryComponentC24 => 'Progress (C24)';

  @override
  String get galleryComponentC25 => 'Loading (C25)';

  @override
  String get galleryComponentC26 => 'Skeleton (C26)';

  @override
  String get galleryComponentC27 => 'BackTop (C27)';

  @override
  String get galleryComponentC28 => 'Countdown (C28)';

  @override
  String get galleryComponentC29 => 'Time (C29)';

  @override
  String get galleryComponentC30 => 'Notification (C30)';

  @override
  String get galleryComponentC31 => 'Table (C31)';

  @override
  String get galleryComponentC32 => 'Pagination (C32)';

  @override
  String get galleryComponentC33 => 'CodeBlock (C33)';

  @override
  String get galleryComponentC34 => 'Tag (C34)';

  @override
  String get galleryComponentC35 => 'Image (C35)';

  @override
  String get galleryComponentC36 => 'Footer (C36)';

  @override
  String get galleryWelcomeTitle => 'Welcome to Animal Island UI';

  @override
  String get galleryWelcomeSubtitle =>
      'A cozy Kawaii component library for enterprise-grade Flutter applications';

  @override
  String get galleryMetricComponents => 'Catalog Components';

  @override
  String get galleryMetricIcons => 'Canonical SVG Icons';

  @override
  String get galleryRecipesTitle => 'Interactive End-to-End Recipes';

  @override
  String get galleryRecipeFormTitle => 'Form & Async Validation';

  @override
  String get galleryRecipeFormDescription =>
      'Comprehensive form lifecycle with typed keys, async concurrency and auto-focus error resolution.';

  @override
  String get galleryRecipeOverlayTitle => 'Overlay Orchestration';

  @override
  String get galleryRecipeOverlayDescription =>
      'Concurrent notification queuing, modal dialogues, slide-out drawer, and loading mask coordination.';

  @override
  String get galleryRecipeTableTitle => 'Data Table & Gallery';

  @override
  String get galleryRecipeTableDescription =>
      'Virtual 1,000-row lazy table with sorting, pagination controls, code copying, and lightbox image preview.';

  @override
  String get galleryExploreCategoriesTitle => 'Explore Component Categories';

  @override
  String get galleryChipButton => 'Button';

  @override
  String get galleryChipIcons => '101 Icons Gallery';

  @override
  String get galleryChipTypewriter => 'Typewriter';

  @override
  String get galleryChipInputForms => 'Input & Forms';

  @override
  String get galleryChipDateTime => 'Date & Time Pickers';

  @override
  String get galleryChipModal => 'Modal & Dialogue';

  @override
  String get galleryChipTable => 'Virtual Table';

  @override
  String get galleryChipPagination => 'Pagination';

  @override
  String get galleryChipCodeBlock => 'Code Block';

  @override
  String get galleryChipImage => 'Image & Lightbox';

  @override
  String get galleryChipTabs => 'Tabs & Collapse';

  @override
  String get galleryChipNotifications => 'Notification Host';

  @override
  String get galleryDemoBadge => 'Demo';

  @override
  String get galleryLaunchRecipe => 'Launch Recipe';

  @override
  String get galleryNotFoundTitle => '404: Lost on the Island';

  @override
  String galleryNotFoundRoute(String route) {
    return 'No component story found at route \"$route\"';
  }

  @override
  String get galleryReturnOverview => 'Return to Overview';

  @override
  String get provenanceUnavailable =>
      'This build carries no build identity stamp.';

  @override
  String get provenanceTitle => 'Build Provenance & Rights Ledger';

  @override
  String get provenanceDescription =>
      'This page shows the identity stamped into this build and the project targets. Current acceptance is determined by candidate evidence.';

  @override
  String get provenanceReleaseIdentity => 'Build Identity';

  @override
  String get provenancePackageIdentity => 'Package Identity';

  @override
  String provenancePackageValue(String packageName, String version) {
    return '$packageName v$version';
  }

  @override
  String get provenanceSourceCommit => 'Source Git Commit';

  @override
  String get provenanceBuildSdk => 'Build Flutter SDK';

  @override
  String provenanceSdkValue(String flutterVersion, String dartVersion) {
    return 'Flutter $flutterVersion (Dart $dartVersion)';
  }

  @override
  String get provenanceUpstreamValue => 'guokaigdg/animal-island-ui';

  @override
  String get provenanceApiHash => 'Public API Signature SHA-256';

  @override
  String get provenanceUpstream => 'Upstream Design System';

  @override
  String get provenanceLicense => 'License Specification';

  @override
  String provenanceLicenseValue(String license) {
    return '$license (Non-Commercial Attribution)';
  }
}
