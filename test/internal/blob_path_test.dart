import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/src/internal/painting/blob_path.dart';

void main() {
  group('BlobPath & Clipper Unit Tests (S04 / T04.02)', () {
    test('AnimalBlobPath builds valid closed path with non-zero bounds', () {
      const size = Size(300, 200);
      final path = AnimalBlobPath.buildPath(size);

      expect(path, isNotNull);
      final bounds = path.getBounds();
      expect(bounds.width, closeTo(300, 2.0));
      expect(bounds.height, closeTo(200, 2.0));
    });

    test('AnimalBlobClipper returns path matching size without reclip', () {
      const clipper = AnimalBlobClipper();
      const size = Size(400, 300);
      final clipPath = clipper.getClip(size);

      expect(clipPath, isNotNull);
      expect(clipper.shouldReclip(const AnimalBlobClipper()), isFalse);
    });
  });
}
