import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/home.dart';

// Reference `iconFloat ${5.5 + i % 3}s ease-in-out ${-i * 1.2}s infinite`:
// translateY 0 -> -8px -> 0.
void main() {
  testWidgets('Home background icons float on their own cycle without a '
      'jump', (t) async {
    t.view.physicalSize = const Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: GalleryHome(onNavigate: (_) {}, wallpaperSeed: 42),
        ),
      ),
    );
    final icons = find.byWidgetPredicate(
      (w) => w is Opacity && w.opacity == .68,
    );
    expect(icons, findsAtLeastNWidgets(3));
    List<Offset> places() => [
      for (var i = 0; i < 3; i++) t.getTopLeft(icons.at(i)),
    ];
    // Each icon is rotated, so its float is a distance along its own axis.
    final start = places();
    double moved(int i) => (places()[i] - start[i]).distance;

    // Icon 0 starts its 5.5s cycle at rest and is 8px away half-way through.
    await t.pump(const Duration(milliseconds: 2750));
    expect(moved(0), moreOrLessEquals(8, epsilon: .01));
    // Three quarters through, the eased return is half done: 4px.
    await t.pump(const Duration(milliseconds: 1375));
    expect(moved(0), moreOrLessEquals(4, epsilon: .05));
    await t.pump(const Duration(milliseconds: 1375));
    expect(moved(0), moreOrLessEquals(0, epsilon: .01));
    // Icons 1 and 2 run 6.5s and 7.5s cycles, 1.2s and 2.4s ahead: icon 1
    // peaks at 3.25 - 1.2 + 6.5 = 8.55s, icon 2 at 3.75 - 2.4 + 7.5 = 8.85s.
    final lift1 = 8 * Curves.easeInOut.transform(1.2 / 6.5 * 2);
    final lift2 = 8 * Curves.easeInOut.transform(2.4 / 7.5 * 2);
    await t.pump(const Duration(milliseconds: 3050));
    expect(moved(1), moreOrLessEquals(8 - lift1, epsilon: .01));
    await t.pump(const Duration(milliseconds: 300));
    expect(moved(2), moreOrLessEquals(8 - lift2, epsilon: .01));
    await t.pump(const Duration(seconds: 20));
    // No frame-to-frame jump around the former 30s wrap.
    var last = places();
    for (var i = 0; i < 400; i++) {
      await t.pump(const Duration(milliseconds: 16));
      final now = places();
      for (var k = 0; k < 3; k++) {
        expect((now[k] - last[k]).distance, lessThan(.2), reason: 'icon $k');
      }
      last = now;
    }
    await t.pumpWidget(const SizedBox());
  });
}
