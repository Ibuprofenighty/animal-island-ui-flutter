import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('Time story shows the reference 4.0.0 demos within the page', (
    t,
  ) async {
    for (final width in [1440.0, 375.0]) {
      t.view.physicalSize = Size(width, width == 375 ? 812 : 1000);
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: IslandLocalizations.delegates,
          supportedLocales: IslandLocalizations.supportedLocales,
          theme: galleryTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: GalleryPage(
            key: ValueKey('time-$width'),
            path: '/time',
            onNavigate: (_) {},
          ),
        ),
      );
      await t.pumpAndSettle();
      final times = t.widgetList<IslandTime>(find.byType(IslandTime)).toList();
      expect(
        [
          for (final time in times)
            (time.variant, time.locale, time.weekdayFormat, time.dateFormat),
        ],
        [
          (IslandTimeVariant.normal, IslandTimeLocale.en, 'dddd', null),
          (IslandTimeVariant.game, IslandTimeLocale.en, 'dddd', null),
          (IslandTimeVariant.game, IslandTimeLocale.zhCn, 'dddd', null),
          (IslandTimeVariant.normal, IslandTimeLocale.zhCn, 'dddd', null),
          (IslandTimeVariant.normal, IslandTimeLocale.en, 'ddd', 'YYYY/MM/DD'),
          (IslandTimeVariant.normal, IslandTimeLocale.zhCn, 'ddd', 'YYYY年M月D日'),
          (IslandTimeVariant.normal, IslandTimeLocale.en, 'dddd', null),
        ],
        reason: '$width',
      );
      for (final time in find.byType(IslandTime).evaluate()) {
        final rect = t.getRect(find.byWidget(time.widget));
        expect(rect.left, greaterThanOrEqualTo(0), reason: '$width');
        expect(rect.right, lessThanOrEqualTo(width), reason: '$width');
      }
      expect(t.takeException(), isNull);
    }
    await t.pumpWidget(const SizedBox());
  });
}
