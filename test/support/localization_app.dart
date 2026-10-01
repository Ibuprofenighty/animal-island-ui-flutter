import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';

/// Mutable locale owner for mounted localization tests.
class LocalizationTestController extends ChangeNotifier {
  LocalizationTestController({Locale? initialLocale}) : _locale = initialLocale;

  Locale? _locale;

  Locale? get locale => _locale;

  set locale(Locale? next) {
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
  }
}

/// A real Material localization host that rebuilds in place when its locale
/// changes. Component tests should keep this host mounted while switching the
/// controller to verify live updates rather than remounting the component.
class AnimalLocalizationTestApp extends StatelessWidget {
  const AnimalLocalizationTestApp({
    required this.controller,
    required this.child,
    this.theme,
    super.key,
  });

  final LocalizationTestController controller;
  final Widget child;
  final ThemeData? theme;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => MaterialApp(
      locale: controller.locale,
      localizationsDelegates: AnimalLocalizations.localizationsDelegates,
      supportedLocales: AnimalLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) =>
          resolveAnimalLocale(locale),
      theme: theme ?? AnimalIslandTheme.light.toThemeData(),
      home: child,
    ),
  );
}
