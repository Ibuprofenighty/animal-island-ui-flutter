import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'pages/gallery.dart';
import 'shared/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    for (final item in <(String, String)>[
      ('Nunito', 'packages/animal_island_ui/assets/licenses/nunito.txt'),
      ('Noto Sans SC', 'assets/fonts/OFL.txt'),
      ('Fira Code', 'packages/animal_island_ui/assets/licenses/firacode.txt'),
      ('Arimo', 'packages/animal_island_ui/assets/licenses/arimo.txt'),
      (
        'Naive Icons',
        'packages/animal_island_ui/assets/licenses/naive-icons.txt',
      ),
      (
        'Animal Island reference',
        'packages/animal_island_ui/assets/licenses/reference-gallery.txt',
      ),
    ]) {
      yield LicenseEntryWithLineBreaks([
        item.$1,
      ], await rootBundle.loadString(item.$2));
    }
  });
  runApp(const IslandGallery());
}

class IslandGallery extends StatefulWidget {
  const IslandGallery({super.key});
  @override
  State<IslandGallery> createState() => _IslandGalleryState();
}

class _IslandGalleryState extends State<IslandGallery> {
  final _router = _GalleryRouter();
  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Animal Island UI',
    debugShowCheckedModeBanner: false,
    theme: galleryTheme(),
    locale: const Locale('zh'),
    supportedLocales: IslandLocalizations.supportedLocales,
    localizationsDelegates: IslandLocalizations.delegates,
    routerDelegate: _router,
    routeInformationParser: const _GalleryParser(),
  );
}

class _GalleryParser extends RouteInformationParser<String> {
  const _GalleryParser();
  @override
  Future<String> parseRouteInformation(RouteInformation route) async =>
      route.uri.path;
  @override
  RouteInformation restoreRouteInformation(String path) =>
      RouteInformation(uri: Uri.parse(path));
}

class _GalleryRouter extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  @override
  final navigatorKey = GlobalKey<NavigatorState>();
  String path = '/';
  @override
  String get currentConfiguration => path;
  void go(String value) {
    if (path == value) return;
    path = value;
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(String value) async {
    path = value;
  }

  @override
  Widget build(BuildContext context) => Navigator(
    key: navigatorKey,
    pages: [
      MaterialPage<void>(
        key: const ValueKey('gallery'),
        child: GalleryPage(path: path, onNavigate: go),
      ),
    ],
    onDidRemovePage: (_) {},
  );
}
