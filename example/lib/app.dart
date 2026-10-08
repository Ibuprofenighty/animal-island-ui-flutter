import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'gallery/gallery_shell.dart';
import 'l10n/generated/gallery_localizations.g.dart';
import 'router.dart';

class AnimalIslandGalleryApp extends StatefulWidget {
  final String? initialRoute;

  const AnimalIslandGalleryApp({super.key, this.initialRoute});

  @override
  State<AnimalIslandGalleryApp> createState() => _AnimalIslandGalleryAppState();
}

class _AnimalIslandGalleryAppState extends State<AnimalIslandGalleryApp> {
  late final GalleryRouter _router;
  bool _isDarkMode = false;
  Locale _locale = const Locale('en');
  double _textScale = 1.0;
  bool _reducedMotion = false;

  @override
  void initState() {
    super.initState();
    _router = GalleryRouter(widget.initialRoute ?? '/');
    _router.addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _router.removeListener(_onRouteChanged);
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension = _isDarkMode
        ? AnimalIslandTheme.dark
        : AnimalIslandTheme.light;

    return MaterialApp(
      onGenerateTitle: (context) =>
          GalleryLocalizations.of(context).galleryAppTitle,
      debugShowCheckedModeBanner: false,
      locale: _locale,
      supportedLocales: AnimalLocalizations.supportedLocales,
      localizationsDelegates: const [
        GalleryLocalizations.delegate,
        ...AnimalLocalizations.localizationsDelegates,
      ],
      localeResolutionCallback: (locale, supportedLocales) =>
          resolveAnimalLocale(locale),
      theme: themeExtension.toThemeData(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(_textScale)),
          child: AnimalOverlayHost(child: child ?? const SizedBox.shrink()),
        );
      },
      home: GalleryShell(
        activeRoute: _router.currentRoute,
        onNavigate: _router.navigateTo,
        isDarkMode: _isDarkMode,
        onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
        currentLocale: _locale,
        onLocaleChanged: (loc) => setState(() => _locale = loc),
        textScale: _textScale,
        onTextScaleChanged: (scale) => setState(() => _textScale = scale),
        reducedMotion: _reducedMotion,
        onReducedMotionChanged: (rm) => setState(() => _reducedMotion = rm),
      ),
    );
  }
}
