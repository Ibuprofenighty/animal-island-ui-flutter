import 'package:flutter/widgets.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

/// Gallery-only coordination. The wallpaper component has no global state.
class BackgroundPreview extends InheritedWidget {
  const BackgroundPreview({
    super.key,
    required this.onPreview,
    required super.child,
  });
  final ValueChanged<IslandBackgroundType?> onPreview;
  static void show(BuildContext context, IslandBackgroundType? type) => context
      .getInheritedWidgetOfExactType<BackgroundPreview>()
      ?.onPreview(type);
  @override
  bool updateShouldNotify(BackgroundPreview old) => old.onPreview != onPreview;
}
