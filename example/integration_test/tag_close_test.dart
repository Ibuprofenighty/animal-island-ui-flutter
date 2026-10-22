import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../test/tag_close_test.dart' as scenarios;
import '../../test/owned_surface_contrast_test.dart' as surfaces;
import '../../test/known_surface_states_test.dart' as nested;
import '../../test/icon_paint_test.dart' as icons;
import '../../test/icon_transparent_roles_test.dart' as glyphs;
import '../../test/dialog_route_test.dart' as routes;
import '../../test/select_state_contract_test.dart' as select;
import '../../test/anchor_viewport_test.dart' as bounds;
import '../../test/drawer_test.dart' as drawer;
import '../../test/loading_test.dart' as loading;
import '../test/header_test.dart' as header;
import '../test/dialog_callback_test.dart' as callbacks;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  bounds.registerAnchoredViewportTests(
    capture: (tester, name) async {
      const folder = String.fromEnvironment('ISLAND_SCREENSHOT_DIR');
      if (folder.isEmpty) return;
      final view = tester.binding.renderViews.single;
      final layer = view.debugLayer! as OffsetLayer;
      final image = await layer
          .toImage(Offset.zero & view.size, pixelRatio: 1)
          .timeout(const Duration(seconds: 15));
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await Directory(folder).create(recursive: true);
      await File('$folder/$name.png').writeAsBytes(data!.buffer.asUint8List());
      debugPrint('Captured $name');
    },
  );
  drawer.main();
  loading.main();
  header.main();
  select.main();
  surfaces.registerOwnedSurfaceContrastTests();
  nested.main();
  icons.main();
  glyphs.main();
  routes.main();
  callbacks.main();
  scenarios.registerTagCloseTests(
    capture: (tester, name) async {
      const folder = String.fromEnvironment('ISLAND_SCREENSHOT_DIR');
      if (folder.isEmpty) return;
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(scenarios.tagCloseCaptureKey),
      );
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await Directory(folder).create(recursive: true);
      await File('$folder/$name.png').writeAsBytes(data!.buffer.asUint8List());
      debugPrint('Captured $name');
    },
  );
}
