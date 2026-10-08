// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'gallery_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class GalleryLocalizationsEn extends GalleryLocalizations {
  GalleryLocalizationsEn([String locale = 'en']) : super(locale);

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
