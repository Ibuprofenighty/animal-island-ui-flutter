import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'gallery_localizations_en.g.dart';
import 'gallery_localizations_zh.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of GalleryLocalizations
/// returned by `GalleryLocalizations.of(context)`.
///
/// Applications need to include `GalleryLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/gallery_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: GalleryLocalizations.localizationsDelegates,
///   supportedLocales: GalleryLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the GalleryLocalizations.supportedLocales
/// property.
abstract class GalleryLocalizations {
  GalleryLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static GalleryLocalizations of(BuildContext context) {
    return Localizations.of<GalleryLocalizations>(
      context,
      GalleryLocalizations,
    )!;
  }

  static const LocalizationsDelegate<GalleryLocalizations> delegate =
      _GalleryLocalizationsDelegate();

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

  /// No description provided for @galleryAppTitle.
  ///
  /// In en, this message translates to:
  /// **'Animal Island UI Gallery'**
  String get galleryAppTitle;

  /// No description provided for @galleryBrandName.
  ///
  /// In en, this message translates to:
  /// **'Animal Island UI'**
  String get galleryBrandName;

  /// No description provided for @gallerySearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search the gallery'**
  String get gallerySearchTooltip;

  /// No description provided for @gallerySearchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get gallerySearchAction;

  /// No description provided for @galleryLocaleSwitch.
  ///
  /// In en, this message translates to:
  /// **'Switch language'**
  String get galleryLocaleSwitch;

  /// No description provided for @galleryLocaleSwitchValue.
  ///
  /// In en, this message translates to:
  /// **'EN / 中文'**
  String get galleryLocaleSwitchValue;

  /// No description provided for @galleryTextScaleTooltip.
  ///
  /// In en, this message translates to:
  /// **'Text scale multiplier'**
  String get galleryTextScaleTooltip;

  /// No description provided for @galleryReducedMotionOn.
  ///
  /// In en, this message translates to:
  /// **'Motion: reduced'**
  String get galleryReducedMotionOn;

  /// No description provided for @galleryReducedMotionOff.
  ///
  /// In en, this message translates to:
  /// **'Motion: normal'**
  String get galleryReducedMotionOff;

  /// No description provided for @galleryThemeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Toggle theme'**
  String get galleryThemeTooltip;

  /// No description provided for @galleryThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get galleryThemeDark;

  /// No description provided for @galleryThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get galleryThemeLight;

  /// No description provided for @galleryCategoryExplore.
  ///
  /// In en, this message translates to:
  /// **'Explore & Evidence'**
  String get galleryCategoryExplore;

  /// No description provided for @galleryCategoryRecipes.
  ///
  /// In en, this message translates to:
  /// **'Interactive Recipes (E2E)'**
  String get galleryCategoryRecipes;

  /// No description provided for @galleryCategoryGeneral.
  ///
  /// In en, this message translates to:
  /// **'1. General'**
  String get galleryCategoryGeneral;

  /// No description provided for @galleryCategoryLayout.
  ///
  /// In en, this message translates to:
  /// **'2. Structure & Layout'**
  String get galleryCategoryLayout;

  /// No description provided for @galleryCategoryNavigation.
  ///
  /// In en, this message translates to:
  /// **'3. Navigation'**
  String get galleryCategoryNavigation;

  /// No description provided for @galleryCategoryFormControls.
  ///
  /// In en, this message translates to:
  /// **'4. Form Controls'**
  String get galleryCategoryFormControls;

  /// No description provided for @galleryCategoryFormEngine.
  ///
  /// In en, this message translates to:
  /// **'5. Form Engine'**
  String get galleryCategoryFormEngine;

  /// No description provided for @galleryCategoryOverlays.
  ///
  /// In en, this message translates to:
  /// **'6. Overlays'**
  String get galleryCategoryOverlays;

  /// No description provided for @galleryCategoryFeedback.
  ///
  /// In en, this message translates to:
  /// **'7. Feedback & Animation'**
  String get galleryCategoryFeedback;

  /// No description provided for @galleryCategoryNotifications.
  ///
  /// In en, this message translates to:
  /// **'8. Notification'**
  String get galleryCategoryNotifications;

  /// No description provided for @galleryCategoryDataDisplay.
  ///
  /// In en, this message translates to:
  /// **'9. Data Display'**
  String get galleryCategoryDataDisplay;

  /// No description provided for @galleryCategoryDecorative.
  ///
  /// In en, this message translates to:
  /// **'10. Decorative'**
  String get galleryCategoryDecorative;

  /// No description provided for @galleryOverviewNav.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get galleryOverviewNav;

  /// A numeric catalog count shown in the gallery without a localized noun.
  ///
  /// In en, this message translates to:
  /// **'{count}'**
  String galleryCount(int count);

  /// No description provided for @galleryRecipeBadge.
  ///
  /// In en, this message translates to:
  /// **'E2E'**
  String get galleryRecipeBadge;

  /// No description provided for @galleryDevelopmentCandidateBadge.
  ///
  /// In en, this message translates to:
  /// **'Development candidate'**
  String get galleryDevelopmentCandidateBadge;

  /// Current gallery text scale multiplier value.
  ///
  /// In en, this message translates to:
  /// **'{scale}×'**
  String galleryTextScaleValue(num scale);

  /// No description provided for @galleryIconsNav.
  ///
  /// In en, this message translates to:
  /// **'101 Vector Icons'**
  String get galleryIconsNav;

  /// No description provided for @galleryProvenanceNav.
  ///
  /// In en, this message translates to:
  /// **'Build Provenance'**
  String get galleryProvenanceNav;

  /// No description provided for @galleryRecipeFormNav.
  ///
  /// In en, this message translates to:
  /// **'Form & Async Validation'**
  String get galleryRecipeFormNav;

  /// No description provided for @galleryRecipeOverlayNav.
  ///
  /// In en, this message translates to:
  /// **'Overlay Orchestration'**
  String get galleryRecipeOverlayNav;

  /// No description provided for @galleryRecipeTableNav.
  ///
  /// In en, this message translates to:
  /// **'Data Table & Gallery'**
  String get galleryRecipeTableNav;

  /// No description provided for @galleryComponentC01.
  ///
  /// In en, this message translates to:
  /// **'Button (C01)'**
  String get galleryComponentC01;

  /// No description provided for @galleryComponentC02.
  ///
  /// In en, this message translates to:
  /// **'Icon (C02)'**
  String get galleryComponentC02;

  /// No description provided for @galleryComponentC03.
  ///
  /// In en, this message translates to:
  /// **'Typewriter (C03)'**
  String get galleryComponentC03;

  /// No description provided for @galleryComponentC04.
  ///
  /// In en, this message translates to:
  /// **'Cursor (C04)'**
  String get galleryComponentC04;

  /// No description provided for @galleryComponentC05.
  ///
  /// In en, this message translates to:
  /// **'Card (C05)'**
  String get galleryComponentC05;

  /// No description provided for @galleryComponentC06.
  ///
  /// In en, this message translates to:
  /// **'Title (C06)'**
  String get galleryComponentC06;

  /// No description provided for @galleryComponentC07.
  ///
  /// In en, this message translates to:
  /// **'Divider (C07)'**
  String get galleryComponentC07;

  /// No description provided for @galleryComponentC08.
  ///
  /// In en, this message translates to:
  /// **'Background (C08)'**
  String get galleryComponentC08;

  /// No description provided for @galleryComponentC09.
  ///
  /// In en, this message translates to:
  /// **'Collapse (C09)'**
  String get galleryComponentC09;

  /// No description provided for @galleryComponentC10.
  ///
  /// In en, this message translates to:
  /// **'Tabs (C10)'**
  String get galleryComponentC10;

  /// No description provided for @galleryComponentC11.
  ///
  /// In en, this message translates to:
  /// **'Carousel (C11)'**
  String get galleryComponentC11;

  /// No description provided for @galleryComponentC12.
  ///
  /// In en, this message translates to:
  /// **'Input (C12)'**
  String get galleryComponentC12;

  /// No description provided for @galleryComponentC13.
  ///
  /// In en, this message translates to:
  /// **'Switch (C13)'**
  String get galleryComponentC13;

  /// No description provided for @galleryComponentC14.
  ///
  /// In en, this message translates to:
  /// **'Checkbox (C14)'**
  String get galleryComponentC14;

  /// No description provided for @galleryComponentC15.
  ///
  /// In en, this message translates to:
  /// **'Radio (C15)'**
  String get galleryComponentC15;

  /// No description provided for @galleryComponentC16.
  ///
  /// In en, this message translates to:
  /// **'Select (C16)'**
  String get galleryComponentC16;

  /// No description provided for @galleryComponentC17.
  ///
  /// In en, this message translates to:
  /// **'DatePicker (C17)'**
  String get galleryComponentC17;

  /// No description provided for @galleryComponentC18.
  ///
  /// In en, this message translates to:
  /// **'TimePicker (C18)'**
  String get galleryComponentC18;

  /// No description provided for @galleryComponentC19.
  ///
  /// In en, this message translates to:
  /// **'Form (C19)'**
  String get galleryComponentC19;

  /// No description provided for @galleryComponentC20.
  ///
  /// In en, this message translates to:
  /// **'FormItem (C20)'**
  String get galleryComponentC20;

  /// No description provided for @galleryComponentC21.
  ///
  /// In en, this message translates to:
  /// **'Modal (C21)'**
  String get galleryComponentC21;

  /// No description provided for @galleryComponentC22.
  ///
  /// In en, this message translates to:
  /// **'Drawer (C22)'**
  String get galleryComponentC22;

  /// No description provided for @galleryComponentC23.
  ///
  /// In en, this message translates to:
  /// **'Tooltip (C23)'**
  String get galleryComponentC23;

  /// No description provided for @galleryComponentC24.
  ///
  /// In en, this message translates to:
  /// **'Progress (C24)'**
  String get galleryComponentC24;

  /// No description provided for @galleryComponentC25.
  ///
  /// In en, this message translates to:
  /// **'Loading (C25)'**
  String get galleryComponentC25;

  /// No description provided for @galleryComponentC26.
  ///
  /// In en, this message translates to:
  /// **'Skeleton (C26)'**
  String get galleryComponentC26;

  /// No description provided for @galleryComponentC27.
  ///
  /// In en, this message translates to:
  /// **'BackTop (C27)'**
  String get galleryComponentC27;

  /// No description provided for @galleryComponentC28.
  ///
  /// In en, this message translates to:
  /// **'Countdown (C28)'**
  String get galleryComponentC28;

  /// No description provided for @galleryComponentC29.
  ///
  /// In en, this message translates to:
  /// **'Time (C29)'**
  String get galleryComponentC29;

  /// No description provided for @galleryComponentC30.
  ///
  /// In en, this message translates to:
  /// **'Notification (C30)'**
  String get galleryComponentC30;

  /// No description provided for @galleryComponentC31.
  ///
  /// In en, this message translates to:
  /// **'Table (C31)'**
  String get galleryComponentC31;

  /// No description provided for @galleryComponentC32.
  ///
  /// In en, this message translates to:
  /// **'Pagination (C32)'**
  String get galleryComponentC32;

  /// No description provided for @galleryComponentC33.
  ///
  /// In en, this message translates to:
  /// **'CodeBlock (C33)'**
  String get galleryComponentC33;

  /// No description provided for @galleryComponentC34.
  ///
  /// In en, this message translates to:
  /// **'Tag (C34)'**
  String get galleryComponentC34;

  /// No description provided for @galleryComponentC35.
  ///
  /// In en, this message translates to:
  /// **'Image (C35)'**
  String get galleryComponentC35;

  /// No description provided for @galleryComponentC36.
  ///
  /// In en, this message translates to:
  /// **'Footer (C36)'**
  String get galleryComponentC36;

  /// No description provided for @galleryWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Animal Island UI'**
  String get galleryWelcomeTitle;

  /// No description provided for @galleryWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A cozy Kawaii component library for enterprise-grade Flutter applications'**
  String get galleryWelcomeSubtitle;

  /// No description provided for @galleryMetricComponents.
  ///
  /// In en, this message translates to:
  /// **'Catalog Components'**
  String get galleryMetricComponents;

  /// No description provided for @galleryMetricIcons.
  ///
  /// In en, this message translates to:
  /// **'Canonical SVG Icons'**
  String get galleryMetricIcons;

  /// No description provided for @galleryRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive End-to-End Recipes'**
  String get galleryRecipesTitle;

  /// No description provided for @galleryRecipeFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Form & Async Validation'**
  String get galleryRecipeFormTitle;

  /// No description provided for @galleryRecipeFormDescription.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive form lifecycle with typed keys, async concurrency and auto-focus error resolution.'**
  String get galleryRecipeFormDescription;

  /// No description provided for @galleryRecipeOverlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Overlay Orchestration'**
  String get galleryRecipeOverlayTitle;

  /// No description provided for @galleryRecipeOverlayDescription.
  ///
  /// In en, this message translates to:
  /// **'Concurrent notification queuing, modal dialogues, slide-out drawer, and loading mask coordination.'**
  String get galleryRecipeOverlayDescription;

  /// No description provided for @galleryRecipeTableTitle.
  ///
  /// In en, this message translates to:
  /// **'Data Table & Gallery'**
  String get galleryRecipeTableTitle;

  /// No description provided for @galleryRecipeTableDescription.
  ///
  /// In en, this message translates to:
  /// **'Virtual 1,000-row lazy table with sorting, pagination controls, code copying, and lightbox image preview.'**
  String get galleryRecipeTableDescription;

  /// No description provided for @galleryExploreCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore Component Categories'**
  String get galleryExploreCategoriesTitle;

  /// No description provided for @galleryChipButton.
  ///
  /// In en, this message translates to:
  /// **'Button'**
  String get galleryChipButton;

  /// No description provided for @galleryChipIcons.
  ///
  /// In en, this message translates to:
  /// **'101 Icons Gallery'**
  String get galleryChipIcons;

  /// No description provided for @galleryChipTypewriter.
  ///
  /// In en, this message translates to:
  /// **'Typewriter'**
  String get galleryChipTypewriter;

  /// No description provided for @galleryChipInputForms.
  ///
  /// In en, this message translates to:
  /// **'Input & Forms'**
  String get galleryChipInputForms;

  /// No description provided for @galleryChipDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time Pickers'**
  String get galleryChipDateTime;

  /// No description provided for @galleryChipModal.
  ///
  /// In en, this message translates to:
  /// **'Modal & Dialogue'**
  String get galleryChipModal;

  /// No description provided for @galleryChipTable.
  ///
  /// In en, this message translates to:
  /// **'Virtual Table'**
  String get galleryChipTable;

  /// No description provided for @galleryChipPagination.
  ///
  /// In en, this message translates to:
  /// **'Pagination'**
  String get galleryChipPagination;

  /// No description provided for @galleryChipCodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code Block'**
  String get galleryChipCodeBlock;

  /// No description provided for @galleryChipImage.
  ///
  /// In en, this message translates to:
  /// **'Image & Lightbox'**
  String get galleryChipImage;

  /// No description provided for @galleryChipTabs.
  ///
  /// In en, this message translates to:
  /// **'Tabs & Collapse'**
  String get galleryChipTabs;

  /// No description provided for @galleryChipNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification Host'**
  String get galleryChipNotifications;

  /// No description provided for @galleryDemoBadge.
  ///
  /// In en, this message translates to:
  /// **'Demo'**
  String get galleryDemoBadge;

  /// No description provided for @galleryLaunchRecipe.
  ///
  /// In en, this message translates to:
  /// **'Launch Recipe'**
  String get galleryLaunchRecipe;

  /// No description provided for @galleryNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'404: Lost on the Island'**
  String get galleryNotFoundTitle;

  /// No description provided for @galleryNotFoundRoute.
  ///
  /// In en, this message translates to:
  /// **'No component story found at route \"{route}\"'**
  String galleryNotFoundRoute(String route);

  /// No description provided for @galleryReturnOverview.
  ///
  /// In en, this message translates to:
  /// **'Return to Overview'**
  String get galleryReturnOverview;

  /// No description provided for @provenanceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This build carries no build identity stamp.'**
  String get provenanceUnavailable;

  /// No description provided for @provenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Build Provenance & Rights Ledger'**
  String get provenanceTitle;

  /// No description provided for @provenanceDescription.
  ///
  /// In en, this message translates to:
  /// **'This page shows the identity stamped into this build and the project targets. Current acceptance is determined by candidate evidence.'**
  String get provenanceDescription;

  /// No description provided for @provenanceReleaseIdentity.
  ///
  /// In en, this message translates to:
  /// **'Build Identity'**
  String get provenanceReleaseIdentity;

  /// No description provided for @provenancePackageIdentity.
  ///
  /// In en, this message translates to:
  /// **'Package Identity'**
  String get provenancePackageIdentity;

  /// No description provided for @provenancePackageValue.
  ///
  /// In en, this message translates to:
  /// **'{packageName} v{version}'**
  String provenancePackageValue(String packageName, String version);

  /// No description provided for @provenanceSourceCommit.
  ///
  /// In en, this message translates to:
  /// **'Source Git Commit'**
  String get provenanceSourceCommit;

  /// No description provided for @provenanceBuildSdk.
  ///
  /// In en, this message translates to:
  /// **'Build Flutter SDK'**
  String get provenanceBuildSdk;

  /// No description provided for @provenanceSdkValue.
  ///
  /// In en, this message translates to:
  /// **'Flutter {flutterVersion} (Dart {dartVersion})'**
  String provenanceSdkValue(String flutterVersion, String dartVersion);

  /// No description provided for @provenanceUpstreamValue.
  ///
  /// In en, this message translates to:
  /// **'guokaigdg/animal-island-ui'**
  String get provenanceUpstreamValue;

  /// No description provided for @provenanceApiHash.
  ///
  /// In en, this message translates to:
  /// **'Public API Signature SHA-256'**
  String get provenanceApiHash;

  /// No description provided for @provenanceUpstream.
  ///
  /// In en, this message translates to:
  /// **'Upstream Design System'**
  String get provenanceUpstream;

  /// No description provided for @provenanceLicense.
  ///
  /// In en, this message translates to:
  /// **'License Specification'**
  String get provenanceLicense;

  /// No description provided for @provenanceLicenseValue.
  ///
  /// In en, this message translates to:
  /// **'{license} (Non-Commercial Attribution)'**
  String provenanceLicenseValue(String license);
}

class _GalleryLocalizationsDelegate
    extends LocalizationsDelegate<GalleryLocalizations> {
  const _GalleryLocalizationsDelegate();

  @override
  Future<GalleryLocalizations> load(Locale locale) {
    return SynchronousFuture<GalleryLocalizations>(
      lookupGalleryLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_GalleryLocalizationsDelegate old) => false;
}

GalleryLocalizations lookupGalleryLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return GalleryLocalizationsEn();
    case 'zh':
      return GalleryLocalizationsZh();
  }

  throw FlutterError(
    'GalleryLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
