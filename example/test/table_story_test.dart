import 'dart:ui' as ui;

import 'support/gallery_fonts.dart';

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/gallery.dart';
import 'package:island_gallery/shared/theme.dart';

Future<void> pumpStory(WidgetTester t, double width) async {
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
        key: ValueKey('table-$width'),
        path: '/table',
        onNavigate: (_) {},
      ),
    ),
  );
  await t.pumpAndSettle();
}

Finder header(String title) => find.ancestor(
  of: find.text(title),
  matching: find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.role == ui.SemanticsRole.columnHeader,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadGalleryFonts);
  tearDown(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  });

  testWidgets('at 375 the tables run past their wrapper to its outer edge', (
    t,
  ) async {
    // Reference table-375-0/1: the card content is x 41-334; the table
    // starts inside the 6px wrapper padding (岛民 ink at 67) and its
    // `喜欢的水果` header runs to the wrapper's outer edge at 334, where it
    // is cut square, not at the padding edge (328, the previous clip).
    await pumpStory(t, 375);
    final count = t
        .widgetList(find.byWidgetPredicate((w) => w is IslandTable))
        .length;
    expect(count, 2);
    for (var i = 0; i < count; i++) {
      final table = t.getRect(
        find.byWidgetPredicate((w) => w is IslandTable).at(i),
      );
      expect(table.left, 41, reason: 'table $i');
      expect(table.right, 334, reason: 'table $i');
      final viewport = t.getRect(
        find
            .descendant(
              of: find.byWidgetPredicate((w) => w is IslandTable).at(i),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      expect(viewport.left, 41, reason: 'viewport $i');
      expect(viewport.right, 334, reason: 'viewport $i');
      expect(t.getRect(header('岛民').at(i)).left, 47, reason: 'start $i');
      expect(
        t.getRect(header('喜欢的水果').at(i)).right,
        greaterThan(334),
        reason: 'overflow $i',
      );
    }
    expect(t.takeException(), isNull);
  });
}
