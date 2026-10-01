import 'package:flutter/foundation.dart';

class GalleryRouter extends ChangeNotifier {
  String _currentRoute = '/';

  String get currentRoute => _currentRoute;

  GalleryRouter([String initialRoute = '/']) {
    _currentRoute = normalizeRoute(initialRoute);
  }

  void navigateTo(String route) {
    final normalized = normalizeRoute(route);
    if (_currentRoute != normalized) {
      _currentRoute = normalized;
      notifyListeners();
    }
  }

  static String normalizeRoute(String route) {
    if (route.isEmpty || route == '#' || route == '#/') {
      return '/';
    }
    if (route.startsWith('#/')) {
      return route.substring(1);
    }
    if (route.startsWith('#')) {
      return route.substring(1);
    }
    if (!route.startsWith('/')) {
      return '/$route';
    }
    return route;
  }
}
