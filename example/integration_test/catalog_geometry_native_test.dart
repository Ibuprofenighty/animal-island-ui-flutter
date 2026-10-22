import 'package:integration_test/integration_test.dart';

import '../test/catalog_geometry_test.dart' as geometry;
import '../../test/icon_context_contrast_test.dart' as icon_contexts;
import '../../test/filled_glyph_roles_test.dart' as filled_roles;
import '../../test/catalog_layout_contract_test.dart' as library_layout;
import '../../test/carousel_test.dart' as carousel;
import '../test/gallery_palette_test.dart' as gallery_palette;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  geometry.main();
  icon_contexts.main();
  filled_roles.main();
  library_layout.main();
  carousel.main();
  gallery_palette.carouselCaptionContrastOracle();
  gallery_palette.homeWallpaperContrastOracle();
}
