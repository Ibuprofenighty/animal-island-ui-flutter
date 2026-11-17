import 'dart:math' as math;
import 'dart:ui' as ui;

import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

// Reference demo `.my-time` (demo/components/Time/index.tsx).
const _stops = [
  (0.0, Color(0xff0f4c46)),
  (.55, Color(0xff00766b)),
  (1.0, Color(0xff19c8b9)),
];

/// CSS `linear-gradient(160deg, …)` colour at [p] inside [box].
Color _cssGradientAt(Rect box, Offset p) {
  const a = 160 * math.pi / 180;
  final length =
      (box.width * math.sin(a)).abs() + (box.height * math.cos(a)).abs();
  final d = p - box.center;
  final t = ((d.dx * math.sin(a) - d.dy * math.cos(a)) / length + .5).clamp(
    0.0,
    1.0,
  );
  for (var i = 1; i < _stops.length; i++) {
    final (end, to) = _stops[i];
    final (start, from) = _stops[i - 1];
    if (t <= end) return Color.lerp(from, to, (t - start) / (end - start))!;
  }
  return _stops.last.$2;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  Widget gallery(double width) => MaterialApp(
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
  );

  testWidgets('Time story shows the reference 4.0.0 demos within the page', (
    t,
  ) async {
    for (final width in [1440.0, 375.0]) {
      t.view.physicalSize = Size(width, width == 375 ? 812 : 1000);
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(gallery(width));
      await t.pumpAndSettle();
      final times = t.widgetList<IslandTime>(find.byType(IslandTime)).toList();
      expect(
        [
          for (final time in times)
            (
              time.variant,
              time.locale,
              time.weekdayFormat,
              time.dateFormat,
              time.style != null,
            ),
        ],
        [
          (IslandTimeVariant.normal, IslandTimeLocale.en, 'dddd', null, false),
          (IslandTimeVariant.game, IslandTimeLocale.en, 'dddd', null, false),
          (IslandTimeVariant.game, IslandTimeLocale.zhCn, 'dddd', null, false),
          (
            IslandTimeVariant.normal,
            IslandTimeLocale.zhCn,
            'dddd',
            null,
            false,
          ),
          (
            IslandTimeVariant.normal,
            IslandTimeLocale.en,
            'ddd',
            'YYYY/MM/DD',
            false,
          ),
          (
            IslandTimeVariant.normal,
            IslandTimeLocale.zhCn,
            'ddd',
            'YYYY年M月D日',
            false,
          ),
          (IslandTimeVariant.normal, IslandTimeLocale.en, 'dddd', null, true),
        ],
        reason: '$width',
      );
      expect(times.last.semanticLabel, '岛屿时间');
      for (final time in find.byType(IslandTime).evaluate()) {
        final rect = t.getRect(find.byWidget(time.widget));
        expect(rect.left, greaterThanOrEqualTo(0), reason: '$width');
        expect(rect.right, lessThanOrEqualTo(width), reason: '$width');
      }
      expect(t.takeException(), isNull);
    }
    await t.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Time custom demo reproduces the reference .my-time with readable inks',
    (t) async {
      t.view.physicalSize = const Size(1440, 1000);
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(gallery(1440));
      await t.pumpAndSettle();
      final style = t
          .widgetList<IslandTime>(find.byType(IslandTime))
          .last
          .style!;
      expect(style.clockColor, const Color(0xfffffdf4));
      expect(style.weekdayColor, const Color(0xffffd166));
      expect(style.separatorColor, const Color(0xffe0bd75));
      expect(style.capsuleColor, const Color(0xff3d2a17));
      // The demo leaves `--animal-text-color-secondary` (#9f927d, 4.46:1 on
      // the capsule); lightened in hue to 4.5:1.
      expect(style.dateColor, const Color(0xffa0937e));
      expect(style.fontFamily, 'IslandGallerySans');
      expect(style.capsuleFontSize, 15);
      expect(style.padding, const EdgeInsets.fromLTRB(36, 24, 36, 18));
      final surface = style.decoration! as BoxDecoration;
      expect(surface.borderRadius, BorderRadius.circular(28));
      expect(surface.boxShadow, const [
        BoxShadow(
          color: Color(0x470f4c46),
          offset: Offset(0, 14),
          blurRadius: 30,
        ),
      ]);
      final gradient = surface.gradient! as LinearGradient;
      expect(gradient.colors, [for (final s in _stops) s.$2]);
      expect(gradient.stops, [for (final s in _stops) s.$1]);
      for (final ink in [style.weekdayColor!, style.dateColor!]) {
        expect(contrast(ink, style.capsuleColor!), greaterThanOrEqualTo(4.5));
      }

      // The painted gradient follows CSS 160deg geometry.
      final boundary = GlobalKey();
      await t.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: MaterialApp(
            theme: galleryTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: IslandTime(
                  now: () => DateTime(2026, 6, 8, 9, 30),
                  style: style,
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final box = t.getRect(find.byType(IslandTime));
      final probes = [
        Offset(box.left + 6, box.center.dy),
        Offset(box.right - 6, box.center.dy),
        Offset(box.center.dx, box.top + 6),
        Offset(box.center.dx, box.bottom - 6),
      ];
      final painted = (await t.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final out = [
          for (final p in probes)
            [
              for (var c = 0; c < 3; c++)
                bytes!.getUint8(
                  (p.dy.floor() * image.width + p.dx.floor()) * 4 + c,
                ),
            ],
        ];
        image.dispose();
        return out;
      }))!;
      for (var i = 0; i < probes.length; i++) {
        final p = probes[i];
        final expected = _cssGradientAt(
          box,
          Offset(p.dx.floor() + .5, p.dy.floor() + .5),
        );
        final channels = [expected.r, expected.g, expected.b];
        for (var c = 0; c < 3; c++) {
          expect(
            painted[i][c],
            closeTo(channels[c] * 255, 2),
            reason: '$p channel $c',
          );
        }
      }

      // Clock ink against the lightest gradient point under the clock.
      final clock = t
          .getRect(find.text('09'))
          .expandToInclude(t.getRect(find.text('30')));
      var lightest = 0.0;
      for (final corner in [
        clock.topLeft,
        clock.topRight,
        clock.bottomLeft,
        clock.bottomRight,
      ]) {
        lightest = math.max(
          lightest,
          _cssGradientAt(box, corner).computeLuminance(),
        );
      }
      final under = _cssGradientAt(box, clock.bottomRight);
      expect(under.computeLuminance(), lightest);
      // The clock ink cannot lighten further, so the 55% stop is deepened.
      expect(contrast(style.clockColor!, _stops[1].$2), greaterThan(4.5));
      expect(
        contrast(style.clockColor!, under),
        greaterThanOrEqualTo(4.5),
        reason: 'clock on ${under.toARGB32().toRadixString(16)}',
      );
      await t.pumpWidget(const SizedBox());
    },
  );
}
