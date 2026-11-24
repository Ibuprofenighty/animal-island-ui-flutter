import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);

  testWidgets('the reminder demo uses the reference text style and names', (
    t,
  ) async {
    final handle = t.ensureSemantics();
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
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
        home: GalleryPage(path: '/countdown', onNavigate: (_) {}),
      ),
    );
    await t.pump(const Duration(milliseconds: 500));

    // Reference `textStyle` / `captionStyle`: 13px at weight 400.
    for (final text in [
      '剩余 60 秒转橙、10 秒转红；最后 5 秒数字轻抖。',
      '默认提醒：60 秒橙 / 10 秒红',
      '关闭提醒：保留原配色',
      '自定义提醒：20 秒暖棕 / 5 秒莓红',
      '抖动提醒：最后 5 秒轻抖',
    ]) {
      final style = t
          .widget<RichText>(
            find.descendant(
              of: find.text(text),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!;
      expect(style.fontSize, 13, reason: text);
      expect(style.fontWeight, FontWeight.w400, reason: text);
    }
    // Reference `aria-label`s of the section and its four countdowns.
    for (final label in [
      '倒计时颜色提醒演示',
      '默认提醒倒计时',
      '无提醒倒计时',
      '自定义提醒倒计时',
      '抖动提醒倒计时',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget, reason: label);
    }
    await t.pumpWidget(const SizedBox());
    handle.dispose();
  });
}
