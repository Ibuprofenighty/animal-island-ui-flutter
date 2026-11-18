import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/stories/form_story.dart';
import 'package:island_gallery/shared/palette.dart';
import 'package:island_gallery/shared/theme.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

void main() {
  testWidgets(
    'Form liveValues line keeps the reference hue at 4.5:1 over its card',
    (t) async {
      t.view.physicalSize = const Size(1440, 3000);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: IslandLocalizations.delegates,
          supportedLocales: IslandLocalizations.supportedLocales,
          theme: galleryTheme(),
          home: const Scaffold(body: SingleChildScrollView(child: FormStory())),
        ),
      );
      await t.pumpAndSettle();
      final line = find.textContaining('liveValues:');
      final color = (t.renderObject<RenderParagraph>(line).text as TextSpan)
          .style!
          .color!;
      expect(color, GalleryPalette.formLiveValues);
      // Reference `#5b8def` sits on the orange pattern card `#fff0e8`
      // (2.90:1); the same-hue value passes there and over the card's
      // darkest dot pixel `#fadfd1`.
      expect(contrast(color, const Color(0xfffff0e8)), greaterThan(5.1));
      expect(
        contrast(color, const Color(0xfffadfd1)),
        greaterThanOrEqualTo(4.5),
      );
      final card = t.widget<IslandCard>(
        find.ancestor(of: line, matching: find.byType(IslandCard)),
      );
      expect(card.pattern, IslandColorway.orange);
    },
  );
}
