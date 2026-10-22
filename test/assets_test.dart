import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final scene in IslandScene.values) {
    test(
      'packaged scene ${scene.assetName} fully decodes without relaxed parser limits',
      () async {
        final picture = await vg.loadPicture(
          SvgAssetLoader(
            'assets/scenes/${scene.assetName}.svg',
            packageName: 'animal_island_ui',
          ),
          null,
        );
        expect(picture.size.width, greaterThan(0));
        expect(picture.size.height, greaterThan(0));
        picture.picture.dispose();
      },
    );
  }
}
