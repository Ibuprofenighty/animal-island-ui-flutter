import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/story.dart';
import 'package:island_gallery/shared/theme.dart';

void main() {
  setUpAll(loadGalleryFonts);
  for (final route in [
    'select',
    'date-picker',
    'pagination',
    'image',
    'tooltip',
  ]) {
    testWidgets('$route parent containment at narrow widths and desktop', (
      t,
    ) async {
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetDevicePixelRatio);
      addTearDown(t.view.resetPhysicalSize);
      for (final width in [320.0, 360.0, 375.0, 390.0, 414.0, 1440.0]) {
        t.view.physicalSize = Size(width, 1000);
        await t.pumpWidget(
          MaterialApp(
            theme: galleryTheme(),
            locale: const Locale('zh'),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
            home: GalleryPage(
              key: ValueKey('$route-$width'),
              path: '/$route',
              onNavigate: (_) {},
            ),
          ),
        );
        await t.pumpAndSettle();
        final panel = find.byType(StoryPanel).first;
        final content = t.getRect(panel).deflate(25);
        final controls = find.descendant(
          of: panel,
          matching: find.byWidgetPredicate(
            (w) =>
                w is IslandSelect<String> ||
                w is IslandDatePicker ||
                w is IslandPagination ||
                w is IslandImage,
          ),
        );
        for (final element in controls.evaluate()) {
          final target = find.byElementPredicate((e) => identical(e, element));
          final rect = t.getRect(target);
          expect(
            rect.left,
            greaterThanOrEqualTo(content.left - .001),
            reason: '$route $width ${element.widget.runtimeType} left',
          );
          expect(
            rect.right,
            lessThanOrEqualTo(content.right + .001),
            reason: '$route $width ${element.widget.runtimeType} right',
          );
          if (element.widget is IslandPagination) {
            final actions = find.descendant(
              of: target,
              matching: find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.button == true,
              ),
            );
            for (final action in actions.evaluate()) {
              final r = t.getRect(
                find.byElementPredicate((e) => identical(e, action)),
              );
              expect(r.left, greaterThanOrEqualTo(rect.left - .001));
              expect(r.right, lessThanOrEqualTo(rect.right + .001));
            }
          }
        }
        final heading = find
            .descendant(of: panel, matching: find.byType(IslandTag))
            .first;
        expect(
          t.getRect(heading).right,
          lessThanOrEqualTo(content.right + .001),
        );
        if (route == 'tooltip') {
          final horizontal = find
              .descendant(
                of: panel,
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is SingleChildScrollView &&
                      w.scrollDirection == Axis.horizontal,
                ),
              )
              .first;
          final viewport = t.getRect(horizontal);
          expect(viewport.left, greaterThanOrEqualTo(content.left));
          expect(viewport.right, lessThanOrEqualTo(content.right));
          final right = find.widgetWithText(IslandButton, 'right');
          await t.ensureVisible(right);
          await t.pumpAndSettle();
          final r = t.getRect(right);
          expect(r.left, greaterThanOrEqualTo(viewport.left - .001));
          expect(r.right, lessThanOrEqualTo(viewport.right + .001));
        }
        expect(t.takeException(), isNull);
      }
    });
  }
}
