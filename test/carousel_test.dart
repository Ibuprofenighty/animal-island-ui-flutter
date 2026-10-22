import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'counter_audit_test.dart' show pixel;
import 'foundation_test.dart' show contrast;

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 600, child: child)),
);
Finder button(String label) => find.byWidgetPredicate(
  (w) =>
      w is Semantics &&
      w.properties.button == true &&
      w.properties.label == label,
);
List<IslandSlide<String>> slides(List<String> ids) => [
  for (final id in ids)
    IslandSlide(
      value: id,
      child: SizedBox(height: id == 'a' ? 200 : 300, child: _Counter(id)),
    ),
];
void main() {
  testWidgets(
    'stable slides retain child state on switch/reorder and inactive content is not focusable',
    (t) async {
      var ids = ['a', 'b'];
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandCarousel.uncontrolled(items: slides(ids));
            },
          ),
        ),
      );
      await t.tap(find.text('a:0'));
      await t.pump();
      expect(find.text('a:1'), findsOneWidget);
      expect(t.getSize(find.byType(IslandCarousel<String>)).height, 200);
      await t.tap(button('Next slide'));
      await t.pumpAndSettle();
      expect(t.getSize(find.byType(IslandCarousel<String>)).height, 300);
      final traversal = t.semantics
          .simulatedAccessibilityTraversal()
          .map((n) => n.getSemanticsData().label)
          .join(' ');
      expect(traversal, contains('b:0'));
      expect(traversal, isNot(contains('a:1')));
      update(() => ids = ['b', 'a']);
      await t.pumpAndSettle();
      await t.tap(button('Next slide'));
      await t.pumpAndSettle();
      expect(find.text('a:1'), findsOneWidget);
      expect(t.getSize(find.byType(IslandCarousel<String>)).height, 200);
      update(() => ids = []);
      await t.pumpAndSettle();
      expect(button('Next slide'), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'controlled rejection, keyboard edges and borrowed focus ownership',
    (t) async {
      final focus = FocusNode();
      final requests = <String>[];
      await t.pumpWidget(
        host(
          IslandCarousel(
            items: slides(['a', 'b', 'c']),
            value: 'a',
            onChanged: requests.add,
            focusNode: focus,
            loop: false,
          ),
        ),
      );
      focus.requestFocus();
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.end);
      await t.pumpAndSettle();
      expect(requests, ['c']);
      expect(
        t.widget<Semantics>(button('Go to slide 1')).properties.selected,
        isTrue,
      );
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pump();
      expect(requests, ['c', 'b']);
      await t.pumpWidget(const SizedBox());
      focus.requestFocus();
      focus.dispose();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'autoplay pauses for focus and user stop, resumes explicitly and cancels on removal',
    (t) async {
      final changes = <String>[];
      final focus = FocusNode();
      await t.pumpWidget(
        host(
          IslandCarousel.uncontrolled(
            items: slides(['a', 'b']),
            autoplay: true,
            interval: const Duration(seconds: 1),
            onChanged: changes.add,
            focusNode: focus,
          ),
        ),
      );
      await t.pump(const Duration(seconds: 1));
      await t.pump(const Duration(milliseconds: 400));
      expect(changes, ['b']);
      focus.requestFocus();
      await t.pump();
      await t.pump(const Duration(seconds: 4));
      expect(changes, ['b']);
      await t.tap(button('Resume autoplay'));
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(changes, ['b', 'a']);
      await t.tap(button('Pause autoplay'));
      await t.pump();
      await t.pump(const Duration(seconds: 4));
      expect(changes.length, 2);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 5));
      focus.dispose();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'nonloop autoplay stops on last slide and child text arrows retain editing behavior',
    (t) async {
      final changes = <String>[];
      final input = TextEditingController(text: 'abc');
      await t.pumpWidget(
        host(
          IslandCarousel.uncontrolled(
            items: [
              IslandSlide(
                value: 'a',
                child: TextField(controller: input),
              ),
              const IslandSlide(value: 'b', child: SizedBox(height: 200)),
            ],
            autoplay: true,
            loop: false,
            interval: const Duration(seconds: 1),
            onChanged: changes.add,
          ),
        ),
      );
      await t.tap(find.byType(TextField));
      await t.pump();
      input.selection = const TextSelection.collapsed(offset: 2);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await t.pump();
      expect(input.selection.baseOffset, 1);
      expect(changes, isEmpty);
      FocusManager.instance.primaryFocus?.unfocus();
      await t.pump();
      await t.pump(const Duration(seconds: 1));
      expect(changes, ['b']);
      await t.pump(const Duration(seconds: 4));
      expect(changes, ['b']);
      await t.pumpWidget(const SizedBox());
      input.dispose();
    },
  );
  testWidgets(
    'Carousel region focus paints its external contour and hands off without relayout',
    (t) async {
      for (final brightness in Brightness.values) {
        final key = GlobalKey(), region = FocusNode(), child = FocusNode();
        final tokens = brightness == Brightness.dark
            ? IslandTokens.dark
            : IslandTokens.light;
        await t.pumpWidget(_focusHost(brightness, key, region, child));
        await t.pumpAndSettle();
        final target = find.byType(IslandCarousel<String>);
        final rect = t.getRect(target);
        final point = rect.topCenter - const Offset(0, 4);
        expect(await pixel(t, key, point), tokens.canvas);
        region.requestFocus();
        await t.pumpAndSettle();
        expect(await pixel(t, key, point), tokens.focus);
        expect(
          contrast(await pixel(t, key, point), tokens.canvas),
          greaterThanOrEqualTo(3),
        );
        expect(t.getRect(target), rect);
        child.requestFocus();
        await t.pumpAndSettle();
        expect(region.hasFocus, isTrue);
        expect(region.hasPrimaryFocus, isFalse);
        expect(await pixel(t, key, point), tokens.canvas);
        expect(t.getRect(target), rect);
        region.requestFocus();
        await t.pumpAndSettle();
        expect(await pixel(t, key, point), tokens.focus);
        await t.pumpWidget(const SizedBox());
        region.requestFocus();
        region.dispose();
        child.dispose();
        expect(t.takeException(), isNull);
      }
    },
  );
  testWidgets(
    'Carousel controls paint external backed focus contours over opaque photos',
    (t) async {
      final oldHighlight = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = oldHighlight);
      for (final brightness in Brightness.values) {
        final key = GlobalKey(), region = FocusNode(), child = FocusNode();
        await t.pumpWidget(_focusHost(brightness, key, region, child));
        await t.pumpAndSettle();
        final target = find.byType(IslandCarousel<String>);
        final rect = t.getRect(target);
        for (final name in ['Next slide', 'Go to slide 1', 'Resume autoplay']) {
          final control = button(name);
          final box = t.getRect(control);
          await t.tap(control);
          await t.pumpAndSettle();
          final ink = await pixel(t, key, box.topCenter - const Offset(0, 3));
          final backing = await pixel(
            t,
            key,
            box.topCenter - const Offset(0, 5),
          );
          expect(
            ink,
            IslandTokens.light.focus,
            reason: '$brightness $name external outline',
          );
          expect(
            backing,
            isNot(Colors.black),
            reason: '$brightness $name backed edge',
          );
          expect(contrast(ink, backing), greaterThanOrEqualTo(3));
          expect(t.getRect(target), rect);
        }
        await t.pumpWidget(const SizedBox());
        region.dispose();
        child.dispose();
        expect(t.takeException(), isNull);
      }
    },
  );
}

class _Counter extends StatefulWidget {
  const _Counter(this.name);
  final String name;
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int n = 0;
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton(
      onPressed: () => setState(() => n++),
      child: Text('${widget.name}:$n'),
    ),
  );
}

Widget _focusHost(
  Brightness brightness,
  GlobalKey boundary,
  FocusNode region,
  FocusNode child,
) {
  final tokens = brightness == Brightness.dark
      ? IslandTokens.dark
      : IslandTokens.light;
  return MaterialApp(
    theme: IslandTheme.create(brightness: brightness),
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: boundary,
          child: SizedBox(
            width: 400,
            height: 280,
            child: ColoredBox(
              color: tokens.canvas,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: 320,
                    height: 180,
                    child: IslandCarousel<String>.uncontrolled(
                      focusNode: region,
                      autoplay: true,
                      interval: const Duration(minutes: 1),
                      items: [
                        IslandSlide(
                          value: 'a',
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: ColoredBox(
                              color: Colors.black,
                              child: Center(
                                child: IslandButton(
                                  focusNode: child,
                                  onPressed: () {},
                                  child: const Text('Nested'),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const IslandSlide(
                          value: 'b',
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: ColoredBox(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
