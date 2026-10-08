import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'animal_localizations_en.g.dart';
import 'animal_localizations_zh.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AnimalLocalizations
/// returned by `AnimalLocalizations.of(context)`.
///
/// Applications need to include `AnimalLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/animal_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AnimalLocalizations.localizationsDelegates,
///   supportedLocales: AnimalLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AnimalLocalizations.supportedLocales
/// property.
abstract class AnimalLocalizations {
  AnimalLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AnimalLocalizations? of(BuildContext context) {
    return Localizations.of<AnimalLocalizations>(context, AnimalLocalizations);
  }

  static const LocalizationsDelegate<AnimalLocalizations> delegate =
      _AnimalLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @now.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @copyFailed.
  ///
  /// In en, this message translates to:
  /// **'Copy Failed'**
  String get copyFailed;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @empty.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get empty;

  /// No description provided for @backToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to Top'**
  String get backToTop;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @footerDefaultText.
  ///
  /// In en, this message translates to:
  /// **'Animal Island UI • Crafted with cozy care'**
  String get footerDefaultText;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @selectPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Please select'**
  String get selectPlaceholder;

  /// No description provided for @datePickerSinglePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get datePickerSinglePlaceholder;

  /// No description provided for @datePickerRangePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get datePickerRangePlaceholder;

  /// No description provided for @datePickerPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get datePickerPreviousYear;

  /// No description provided for @datePickerNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get datePickerNextYear;

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear date'**
  String get clearDate;

  /// No description provided for @timePickerPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get timePickerPlaceholder;

  /// No description provided for @timePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get timePickerTitle;

  /// No description provided for @clearTime.
  ///
  /// In en, this message translates to:
  /// **'Clear time'**
  String get clearTime;

  /// Accessible value and unit for a time-picker wheel item.
  ///
  /// In en, this message translates to:
  /// **'{unit, select, hours{{value, plural, one{{value} hour} other{{value} hours}}} minutes{{value, plural, one{{value} minute} other{{value} minutes}}} seconds{{value, plural, one{{value} second} other{{value} seconds}}} other{{value}}}'**
  String timePickerWheelValue(int value, String unit);

  /// No description provided for @inputClearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear input'**
  String get inputClearLabel;

  /// No description provided for @switchSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchSemanticLabel;

  /// No description provided for @selectClearLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get selectClearLabel;

  /// No description provided for @carouselPreviousSlide.
  ///
  /// In en, this message translates to:
  /// **'Previous slide'**
  String get carouselPreviousSlide;

  /// No description provided for @carouselNextSlide.
  ///
  /// In en, this message translates to:
  /// **'Next slide'**
  String get carouselNextSlide;

  /// Accessible position of a carousel slide.
  ///
  /// In en, this message translates to:
  /// **'Slide {index} of {total}'**
  String carouselSlidePosition(int index, int total);

  /// No description provided for @modalConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get modalConfirm;

  /// No description provided for @modalContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get modalContinue;

  /// No description provided for @modalCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Close modal'**
  String get modalCloseLabel;

  /// No description provided for @modalRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Dialog'**
  String get modalRouteLabel;

  /// No description provided for @drawerRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Drawer'**
  String get drawerRouteLabel;

  /// No description provided for @drawerCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Close drawer'**
  String get drawerCloseLabel;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @circularProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'Circular progress'**
  String get circularProgressLabel;

  /// No description provided for @notificationDismissLabel.
  ///
  /// In en, this message translates to:
  /// **'Dismiss notification'**
  String get notificationDismissLabel;

  /// No description provided for @tableLoadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading table data'**
  String get tableLoadingLabel;

  /// Accessible pagination navigation status.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String paginationNavigation(int current, int total);

  /// No description provided for @paginationPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get paginationPrevious;

  /// No description provided for @paginationNext.
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get paginationNext;

  /// No description provided for @paginationSkipBackward.
  ///
  /// In en, this message translates to:
  /// **'Skip five pages backward'**
  String get paginationSkipBackward;

  /// No description provided for @paginationSkipForward.
  ///
  /// In en, this message translates to:
  /// **'Skip five pages forward'**
  String get paginationSkipForward;

  /// No description provided for @paginationPage.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String paginationPage(int page);

  /// No description provided for @codeCopyLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get codeCopyLabel;

  /// No description provided for @codeCopySemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Copy code to clipboard'**
  String get codeCopySemanticLabel;

  /// No description provided for @codeCopiedSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedSemanticLabel;

  /// No description provided for @codeDefaultLanguage.
  ///
  /// In en, this message translates to:
  /// **'dart'**
  String get codeDefaultLanguage;

  /// No description provided for @tagRemoveLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove tag'**
  String get tagRemoveLabel;

  /// No description provided for @imagePreviewCloseLabel.
  ///
  /// In en, this message translates to:
  /// **'Close preview'**
  String get imagePreviewCloseLabel;

  /// No description provided for @imagePreviewRouteLabel.
  ///
  /// In en, this message translates to:
  /// **'Image preview'**
  String get imagePreviewRouteLabel;

  /// No description provided for @imagePreviewSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'{label}, click to preview'**
  String imagePreviewSemanticLabel(String label);

  /// No description provided for @imagePreviewDefaultSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview image'**
  String get imagePreviewDefaultSemanticLabel;

  /// No description provided for @currentTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Current time'**
  String get currentTimeLabel;

  /// Accessible remaining-time announcement for a countdown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No time remaining} one{{count} second remaining} other{{count} seconds remaining}}'**
  String countdownRemaining(int count);

  /// No description provided for @countdownUnitDays.
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get countdownUnitDays;

  /// No description provided for @countdownUnitHours.
  ///
  /// In en, this message translates to:
  /// **'HOURS'**
  String get countdownUnitHours;

  /// No description provided for @countdownUnitMinutes.
  ///
  /// In en, this message translates to:
  /// **'MINS'**
  String get countdownUnitMinutes;

  /// No description provided for @countdownUnitSeconds.
  ///
  /// In en, this message translates to:
  /// **'SECS'**
  String get countdownUnitSeconds;

  /// No description provided for @validationEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmail;

  /// No description provided for @validationUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get validationUrl;

  /// No description provided for @validationPattern.
  ///
  /// In en, this message translates to:
  /// **'Value does not match the required pattern'**
  String get validationPattern;

  /// No description provided for @validationMinimum.
  ///
  /// In en, this message translates to:
  /// **'Value must be at least {value}'**
  String validationMinimum(num value);

  /// No description provided for @validationMaximum.
  ///
  /// In en, this message translates to:
  /// **'Value cannot exceed {value}'**
  String validationMaximum(num value);

  /// No description provided for @validationLengthMinimum.
  ///
  /// In en, this message translates to:
  /// **'Length must be at least {minimum}'**
  String validationLengthMinimum(int minimum);

  /// No description provided for @validationLengthMaximum.
  ///
  /// In en, this message translates to:
  /// **'Length cannot exceed {maximum}'**
  String validationLengthMaximum(int maximum);

  /// No description provided for @validationLengthRange.
  ///
  /// In en, this message translates to:
  /// **'Length must be between {minimum} and {maximum}'**
  String validationLengthRange(int minimum, int maximum);

  /// No description provided for @validationFailure.
  ///
  /// In en, this message translates to:
  /// **'Validation could not be completed'**
  String get validationFailure;

  /// Localized accessible name for a canonical interactive icon used without an explicit caller label.
  ///
  /// In en, this message translates to:
  /// **'{icon, select, airplane{Airplane} anchor{Anchor} apple{Apple} balloon{Balloon} bear{Bear} bee{Bee} bell{Bell} bicycle{Bicycle} bird{Bird} book{Book} bookmark{Bookmark} bulb{Light bulb} butterfly{Butterfly} cactus{Cactus} cake{Cake} calendar{Calendar} camera{Camera} candle{Candle} car{Car} cart{Cart} cat{Cat} chat{Chat} check{Check} cherry{Cherry} clock{Clock} close{Close} cloud{Cloud} code{Code} coffee{Coffee} compass{Compass} creditCard{Credit card} dog{Dog} donut{Doughnut} download{Download} edit{Edit} eye{Eye} file{File} fish{Fish} flag{Flag} flame{Flame} flower{Flower} folder{Folder} fox{Fox} frog{Frog} gift{Gift} globe{Globe} headphones{Headphones} heart{Heart} home{Home} icecream{Ice cream} image{Image} key{Key} ladybug{Ladybug} lamp{Lamp} leaf{Leaf} lemon{Lemon} location{Location} lock{Lock} magnet{Magnet} mail{Mail} map{Map} mic{Microphone} moon{Moon} mushroom{Mushroom} music{Music} owl{Owl} paintbrush{Paintbrush} pencil{Pencil} penguin{Penguin} phone{Phone} play{Play} plus{Plus} rabbit{Rabbit} rainbow{Rainbow} refresh{Refresh} rocket{Rocket} sailboat{Sailboat} save{Save} search{Search} settings{Settings} share{Share} shoppingBag{Shopping bag} smile{Smile} snail{Snail} snowflake{Snowflake} star{Star} strawberry{Strawberry} sun{Sun} tag{Tag} thermometer{Thermometer} thumbsUp{Thumbs up} train{Train} trash{Trash} tree{Tree} trophy{Trophy} umbrella{Umbrella} upload{Upload} user{User} video{Video} watermelon{Watermelon} wifi{Wi-Fi} other{Icon}}'**
  String iconSemanticName(String icon);
}

class _AnimalLocalizationsDelegate
    extends LocalizationsDelegate<AnimalLocalizations> {
  const _AnimalLocalizationsDelegate();

  @override
  Future<AnimalLocalizations> load(Locale locale) {
    return SynchronousFuture<AnimalLocalizations>(
      lookupAnimalLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AnimalLocalizationsDelegate old) => false;
}

AnimalLocalizations lookupAnimalLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AnimalLocalizationsEn();
    case 'zh':
      return AnimalLocalizationsZh();
  }

  throw FlutterError(
    'AnimalLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
