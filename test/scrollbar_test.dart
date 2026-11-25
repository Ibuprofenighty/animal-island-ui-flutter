import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {Brightness brightness = Brightness.light}) =>
    MaterialApp(
      theme: IslandTheme.create(brightness: brightness),
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    );

Widget rows(int count) => Column(
  children: [
    for (var i = 0; i < count; i++)
      SizedBox(width: 200, height: 40, child: Text('row $i')),
  ],
);

RawScrollbar bar(WidgetTester t, {int index = 0}) => t.widget<RawScrollbar>(
  find
      .descendant(
        of: find.byType(IslandScrollbar),
        matching: find.byWidgetPredicate((w) => w is RawScrollbar),
      )
      .at(index),
);

// The painter draws its track first, transparent unless the track is shown;
// the thumb is the second rounded rectangle.
void main() {
  testWidgets('a vertical area scrolls, shows an 8px pill and takes its '
      'thickness out of the content', (t) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      host(
        IslandScrollbar(
          width: 240,
          height: 200,
          verticalController: controller,
          child: const SizedBox(height: 600, child: Placeholder()),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(IslandScrollbar)), const Size(240, 200));
    expect(t.getSize(find.byType(Placeholder)).width, 232);
    expect(controller.position.maxScrollExtent, 400);
    final thumb = bar(t);
    expect(thumb.thickness, 8);
    expect(thumb.radius, const Radius.circular(4));
    expect(thumb.thumbVisibility, isTrue);
    expect(thumb.thumbColor, IslandTokens.light.outline);
    expect(thumb.trackVisibility, isFalse);
    expect(
      find.byWidgetPredicate((w) => w is RawScrollbar),
      paints
        ..rrect()
        ..rrect(
          rrect: RRect.fromRectAndRadius(
            const Rect.fromLTWH(232, 0, 8, 200 * 200 / 600),
            const Radius.circular(4),
          ),
          color: IslandTokens.light.outline,
        ),
    );
    controller.jumpTo(120);
    await t.pump();
    expect(t.getTopLeft(find.byType(Placeholder)).dy, -120);
  });

  testWidgets('content that fits has no thumb and no gutter', (t) async {
    await t.pumpWidget(
      host(
        const IslandScrollbar(
          width: 240,
          height: 200,
          child: SizedBox(height: 100, child: Placeholder()),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(Placeholder)).width, 240);
    expect(
      find.byWidgetPredicate((w) => w is RawScrollbar),
      isNot(paints..rrect()),
    );
  });

  testWidgets('without a height the area takes its content, up to maxHeight', (
    t,
  ) async {
    Widget build(int count) =>
        host(IslandScrollbar(width: 240, maxHeight: 120, child: rows(count)));
    await t.pumpWidget(build(2));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(IslandScrollbar)).height, 80);
    await t.pumpWidget(build(6));
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(IslandScrollbar)).height, 120);
    expect(bar(t).controller!.position.maxScrollExtent, 120);
  });

  testWidgets('a horizontal area scrolls sideways with the thumb below', (
    t,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      host(
        IslandScrollbar(
          width: 200,
          direction: IslandScrollbarDirection.horizontal,
          horizontalController: controller,
          child: const SizedBox(width: 500, height: 30, child: Placeholder()),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(t.getSize(find.byType(IslandScrollbar)), const Size(200, 38));
    expect(controller.position.maxScrollExtent, 300);
    expect(bar(t).scrollbarOrientation, ScrollbarOrientation.bottom);
    expect(
      find.byWidgetPredicate((w) => w is RawScrollbar),
      paints
        ..rrect()
        ..rrect(
          rrect: RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 30, 80, 8),
            const Radius.circular(4),
          ),
        ),
    );
  });

  testWidgets('both axes scroll and the two thumbs leave the corner free', (
    t,
  ) async {
    final vertical = ScrollController(), horizontal = ScrollController();
    addTearDown(vertical.dispose);
    addTearDown(horizontal.dispose);
    await t.pumpWidget(
      host(
        IslandScrollbar(
          width: 200,
          height: 100,
          direction: IslandScrollbarDirection.both,
          verticalController: vertical,
          horizontalController: horizontal,
          child: const SizedBox(width: 400, height: 300, child: Placeholder()),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(vertical.position.maxScrollExtent, 300 - 92);
    expect(horizontal.position.maxScrollExtent, 400 - 192);
    expect(bar(t, index: 0).padding, const EdgeInsets.only(bottom: 8));
    expect(bar(t, index: 1).padding, const EdgeInsets.only(right: 8));
  });

  testWidgets('showTrack, thumbColor and thumbSize restyle the bar', (t) async {
    await t.pumpWidget(
      host(
        IslandScrollbar(
          width: 240,
          height: 200,
          showTrack: true,
          thumbColor: IslandTokens.light.leaf,
          thumbSize: 12,
          child: const SizedBox(height: 600),
        ),
      ),
    );
    await t.pumpAndSettle();
    final thumb = bar(t);
    expect(thumb.thickness, 12);
    expect(thumb.thumbColor, IslandTokens.light.leaf);
    expect(thumb.trackColor, const Color(0xfff0e8d8));
    expect(thumb.trackRadius, const Radius.circular(6));
  });

  testWidgets('the thumb darkens under the pointer over 200ms', (t) async {
    await t.pumpWidget(
      host(
        const IslandScrollbar(
          width: 240,
          height: 200,
          child: SizedBox(height: 600),
        ),
      ),
    );
    await t.pumpAndSettle();
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: const Offset(100, 100));
    await mouse.moveTo(const Offset(236, 20));
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));
    expect(
      find.byWidgetPredicate((w) => w is RawScrollbar),
      paints
        ..rrect()
        ..rrect(color: const Color(0xff794f27)),
    );
    await mouse.moveTo(const Offset(100, 100));
    await t.pump();
    await t.pump(const Duration(milliseconds: 200));
    expect(
      find.byWidgetPredicate((w) => w is RawScrollbar),
      paints
        ..rrect()
        ..rrect(color: IslandTokens.light.outline),
    );
  });

  testWidgets('the area is a focus stop and the keys scroll it', (t) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      host(
        IslandScrollbar(
          width: 240,
          height: 200,
          verticalController: controller,
          child: const SizedBox(height: 600),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await t.pumpAndSettle();
    expect(controller.offset, greaterThan(0));
    await t.sendKeyEvent(LogicalKeyboardKey.end);
    await t.pumpAndSettle();
    expect(controller.offset, 400);
  });

  testWidgets('a wheel at the end of the area does not move the page', (
    t,
  ) async {
    final page = ScrollController(), inner = ScrollController();
    addTearDown(page.dispose);
    addTearDown(inner.dispose);
    await t.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            controller: page,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IslandScrollbar(
                  width: 240,
                  height: 200,
                  verticalController: inner,
                  child: const SizedBox(height: 300),
                ),
                const SizedBox(height: 2000),
              ],
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    pointer.hover(const Offset(100, 100));
    await t.sendEventToBinding(pointer.scroll(const Offset(0, 500)));
    await t.pump();
    expect(inner.offset, 100);
    await t.sendEventToBinding(pointer.scroll(const Offset(0, 500)));
    await t.pump();
    expect(inner.offset, 100);
    expect(page.offset, 0);
    pointer.hover(const Offset(100, 400));
    await t.sendEventToBinding(pointer.scroll(const Offset(0, 500)));
    await t.pump();
    expect(page.offset, 500);
  });

  testWidgets('the dark theme uses its own outline and canvas', (t) async {
    await t.pumpWidget(
      host(
        const IslandScrollbar(
          width: 240,
          height: 200,
          showTrack: true,
          child: SizedBox(height: 600),
        ),
        brightness: Brightness.dark,
      ),
    );
    await t.pumpAndSettle();
    expect(bar(t).thumbColor, IslandTokens.dark.outline);
    expect(bar(t).trackColor, IslandTokens.dark.canvas);
  });
}
