import 'package:flutter_test/flutter_test.dart';
import 'package:example/router.dart';

void main() {
  group('GalleryRouter', () {
    test('normalizes empty and hash roots to /', () {
      expect(GalleryRouter.normalizeRoute(''), '/');
      expect(GalleryRouter.normalizeRoute('#'), '/');
      expect(GalleryRouter.normalizeRoute('#/'), '/');
      expect(GalleryRouter.normalizeRoute('/'), '/');
    });

    test('normalizes path strings with and without prefixes', () {
      expect(GalleryRouter.normalizeRoute('#/button'), '/button');
      expect(GalleryRouter.normalizeRoute('button'), '/button');
      expect(
        GalleryRouter.normalizeRoute('/stories/button'),
        '/stories/button',
      );
    });

    test('navigateTo changes currentRoute and notifies listeners', () {
      final router = GalleryRouter();
      expect(router.currentRoute, '/');

      var notificationCount = 0;
      router.addListener(() {
        notificationCount++;
      });

      router.navigateTo('#/stories/form');
      expect(router.currentRoute, '/stories/form');
      expect(notificationCount, 1);

      // Navigating to the same route should be a no-op
      router.navigateTo('/stories/form');
      expect(notificationCount, 1);

      router.navigateTo('/provenance');
      expect(router.currentRoute, '/provenance');
      expect(notificationCount, 2);
    });
  });
}
