import 'package:flutter/widgets.dart';

/// Resolves device or caller locales to the package's supported language set.
///
/// Chinese regional locales use the Chinese catalog. English regional locales
/// and unknown languages use English, which is the explicit default.
Locale resolveAnimalLocale(Locale? requestedLocale) =>
    requestedLocale?.languageCode == 'zh'
    ? const Locale('zh')
    : const Locale('en');
