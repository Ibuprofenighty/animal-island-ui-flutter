import 'package:flutter/widgets.dart';

/// Removes exactly the caller's route after tree mutations finish. Never pops
/// an unrelated route that another owner may have placed above it.
void dismissOwnedRouteAfterFrame(Route<dynamic> route) {
  final navigator = route.navigator;
  if (navigator == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (navigator.mounted && route.isActive) navigator.removeRoute(route);
  });
}
