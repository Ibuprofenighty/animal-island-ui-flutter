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
}
