import 'support/frame_sample.dart';

import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Widget host(Widget child, {bool reduced = false}) => MaterialApp(
  theme: IslandTheme.create(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: child),
    ),
  ),
);
Color textColor(WidgetTester t) =>
    (t
                .widget<RichText>(
                  find.descendant(
                    of: find.text('Action'),
                    matching: find.byType(RichText),
                  ),
                )
                .text
            as TextSpan)
        .style!
        .color!;

void main() {
  setUp(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional,
  );
  tearDown(
    () => FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.automatic,
  );
  for (final row
      in const <
        (IslandButtonVariant, bool, Color, Color, Color, Color, double, double)
      >[
        (
          IslandButtonVariant.normal,
          false,
          Color(0xff005e56),
          Color(0xff005249),
          Color(0xfff8f8f0),
          Color(0xfff8f8f0),
          -1,
          0,
        ),
        (
          IslandButtonVariant.dashed,
          false,
          Color(0xff005e56),
          Color(0xff005249),
          Color(0xfff8f8f0),
          Color(0xfff8f8f0),
          -1,
          0,
        ),
        (
          IslandButtonVariant.primary,
          false,
          Color(0xff714821),
          Color(0xff714821),
          Color(0xfff8f8f0),
          Color(0xfff8f8f0),
          -1,
          2,
        ),
        (
          IslandButtonVariant.text,
          false,
          Color(0xff714821),
          Color(0xff714821),
          Color(0xfff0e8d8),
          Color(0xffe9ddc6),
          0,
          0,
        ),
        (
          IslandButtonVariant.primary,
          true,
          Color(0xff2a1010),
          Color(0xff2a1010),
          Color(0xffe87878),
          Color(0xffd85555),
          -1,
          2,
        ),
      ]) {
    testWidgets(
      'reference motion and authorized hover/press ${row.$1.name} danger=${row.$2}',
      (t) async {
        final boundary = GlobalKey();
        await t.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: host(
              IslandButton(
                variant: row.$1,
                danger: row.$2,
                onPressed: () {},
                child: const Text('Action'),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final initial = t.getRect(find.text('Action'));
        final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(initial.center);
        await t.pumpAndSettle();
        expect(textColor(t), row.$3);
        expect(
          t.getRect(find.text('Action')).top,
          closeTo(initial.top + row.$7, .001),
        );
        Future<Color> pixel() async => (await t.runAsync(() async {
          final render =
              boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await render.toImage(pixelRatio: 1);
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          final bounds = t.getRect(find.text('Action'));
          final pos =
              ((bounds.top - 5).floor() * image.width +
                  bounds.center.dx.floor()) *
              4;
          final color = Color.fromARGB(
            data!.getUint8(pos + 3),
            data.getUint8(pos),
            data.getUint8(pos + 1),
            data.getUint8(pos + 2),
          );
          image.dispose();
          return color;
        }))!;

        expect(await pixel(), row.$5);
        await mouse.down(initial.center);
        await t.pumpAndSettle();
        expect(textColor(t), row.$4);
        expect(
          t.getRect(find.text('Action')).top,
          closeTo(initial.top + row.$8, .001),
        );
        expect(await pixel(), row.$6);
        await mouse.up();
        await mouse.removePointer();
        await t.pumpAndSettle();
        expect(t.getRect(find.text('Action')), initial);
      },
    );
  }
  testWidgets(
    'link and danger text keep their authorized readable foreground and stay still',
    (t) async {
      for (final danger in [false, true]) {
        await t.pumpWidget(
          host(
            IslandButton(
              variant: IslandButtonVariant.link,
              danger: danger,
              onPressed: () {},
              child: const Text('Action'),
            ),
          ),
        );
        final rect = t.getRect(find.text('Action'));
        final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
        await mouse.addPointer(location: Offset.zero);
        await mouse.moveTo(rect.center);
        await t.pumpAndSettle();
        expect(
          textColor(t),
          danger ? IslandTokens.light.dangerText : IslandTokens.light.linkHover,
        );
        expect(t.getRect(find.text('Action')), rect);
        await mouse.down(rect.center);
        await t.pumpAndSettle();
        expect(
          textColor(t),
          danger
              ? IslandTokens.light.dangerText
              : IslandTokens.light.linkPressed,
        );
        expect(t.getRect(find.text('Action')), rect);
        await mouse.up();
        await mouse.removePointer();
        await t.pumpAndSettle();
      }
    },
  );
  testWidgets(
    'hover uses an atomic readable color pair and retains the 250ms cubic position',
    (t) async {
      await t.pumpWidget(
        host(IslandButton(onPressed: () {}, child: const Text('Action'))),
      );
      final base = t.getRect(find.text('Action'));
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(base.center);
      await t.pump();
      const curve = Cubic(.4, 0, .2, 1);
      // Live bindings may render while a gesture/pump Future is awaiting.
      // Infer the sampled phase from visible position, then use actual frame
      // timestamps; a125ms pump request is exact only under the fake clock.
      final textBox = t.renderObject<RenderBox>(find.text('Action'));
      final first = await sampleFrame(
        t,
        () => textBox.localToGlobal(Offset.zero).dy,
      );
      final initialFraction = (base.top - first.value).clamp(0.0, 1.0);
      var low = 0.0, high = 1.0;
      for (var i = 0; i < 40; i++) {
        final mid = (low + high) / 2;
        if (curve.transform(mid) < initialFraction) {
          low = mid;
        } else {
          high = mid;
        }
      }
      await t.pump(const Duration(milliseconds: 125));
      final last = await sampleFrame(
        t,
        () => textBox.localToGlobal(Offset.zero).dy,
      );
      final elapsed = last.stamp - first.stamp;
      final phase = ((low + high) / 2 + elapsed.inMicroseconds / 250000).clamp(
        0.0,
        1.0,
      );
      final fraction = curve.transform(phase);
      expect(last.value, closeTo(base.top - fraction, .001));
      expect(textColor(t), const Color(0xff005e56));
      await mouse.removePointer();
      await t.pumpAndSettle();
    },
  );
  testWidgets(
    'keyboard focus outline is outside without changing slot geometry',
    (t) async {
      final boundary = GlobalKey();
      await t.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: host(
            IslandButton(
              variant: IslandButtonVariant.text,
              onPressed: () {},
              child: const Text('Action'),
            ),
            reduced: true,
          ),
        ),
      );
      final button = t.getRect(find.byType(IslandButton));
      final content = t.getRect(find.text('Action'));
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pumpAndSettle();
      expect(t.getRect(find.text('Action')), content);
      await t.runAsync(() async {
        final image =
            await (boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        List<int> pixel(int y) {
          final p = (y * image.width + button.center.dx.floor()) * 4;
          return [
            bytes!.getUint8(p),
            bytes.getUint8(p + 1),
            bytes.getUint8(p + 2),
          ];
        }

        expect(pixel((button.top - 3).floor()), [0, 86, 79]);
        expect(pixel((button.top - 1).floor()), [255, 255, 255]);
        image.dispose();
      });
    },
  );
  testWidgets(
    'busy donut is 28px, rotates counterclockwise in 2.5s and honors reduced motion',
    (t) async {
      Widget button() => IslandButton(
        busy: true,
        onPressed: () {},
        child: const Text('Action'),
      );
      await t.pumpWidget(host(button()));
      await t.pump();
      final glyph = find.byWidgetPredicate(
        (w) => w is IslandIcon && w.glyph == IslandGlyph.donut,
      );
      expect(t.getSize(glyph), const Size(28, 28));
      final turns = t
          .widget<RotationTransition>(
            find.descendant(
              of: find.byType(IslandButton),
              matching: find.byType(RotationTransition),
            ),
          )
          .turns;
      final first = await sampleFrame(t, () => turns.value);
      await t.pump(const Duration(milliseconds: 625));
      final last = await sampleFrame(t, () => turns.value);
      final elapsed = last.stamp - first.stamp;
      final distance = (first.value - last.value) % 1;
      final expected = (elapsed.inMicroseconds / 2500000) % 1;
      expect(distance, closeTo(expected, .0001));
      await t.pumpWidget(host(button(), reduced: true));
      await t.pump();
      expect(turns.value, 0);
      await t.pump(const Duration(seconds: 1));
      expect(turns.value, 0);
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'dashed reserves its border and child state survives hover press and busy',
    (t) async {
      const key = ValueKey('opaque');
      Widget button(IslandButtonVariant variant, {bool busy = false}) =>
          IslandButton(
            variant: variant,
            busy: busy,
            onPressed: () {},
            child: const _Child(key: key),
          );
      await t.pumpWidget(
        host(button(IslandButtonVariant.normal), reduced: true),
      );
      final width = t.getSize(find.byType(IslandButton)).width;
      final state = t.state(find.byType(_Child));
      await t.pumpWidget(
        host(button(IslandButtonVariant.dashed), reduced: true),
      );
      expect(t.getSize(find.byType(IslandButton)).width, width);
      await t.tap(find.text('Action'));
      await t.pump();
      expect(t.state(find.byType(_Child)), same(state));
      await t.pumpWidget(
        host(button(IslandButtonVariant.dashed, busy: true), reduced: true),
      );
      expect(t.state(find.byType(_Child)), same(state));
      expect(textColor(t), Colors.purple);
    },
  );
}

class _Child extends StatefulWidget {
  const _Child({super.key});
  @override
  State<_Child> createState() => _ChildState();
}

class _ChildState extends State<_Child> {
  @override
  Widget build(BuildContext context) =>
      const Text('Action', style: TextStyle(color: Colors.purple));
}
