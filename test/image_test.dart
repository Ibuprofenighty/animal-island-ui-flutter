import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));
Finder button(String label) => find.byWidgetPredicate(
  (w) =>
      w is Semantics &&
      w.properties.button == true &&
      w.properties.label == label,
);
ui.Image picture() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 40, 20),
    Paint()..color = Colors.teal,
  );
  final drawing = recorder.endRecording();
  final image = drawing.toImageSync(40, 20);
  drawing.dispose();
  return image;
}

class _Photo extends ImageProvider<_Photo> {
  _Photo(this.image);
  final ui.Image image;
  int loads = 0;
  @override
  Future<_Photo> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);
  @override
  ImageStreamCompleter loadImage(_Photo key, ImageDecoderCallback decode) {
    loads++;
    return OneFrameImageStreamCompleter(
      SynchronousFuture(ImageInfo(image: image.clone())),
    );
  }
}

void main() {
  testWidgets(
    'stamp mask removes external filter shadows and includes corner perforations',
    (t) async {
      final key = GlobalKey();
      final photo = _Photo(picture());
      await t.pumpWidget(
        host(
          RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 260,
              height: 204,
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: IslandImage(
                    image: photo,
                    alt: 'Stamp',
                    width: 210,
                    height: 154,
                    variant: IslandImageVariant.stamp,
                    preview: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final data = await t.runAsync(() async {
        final shot =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 1);
        final bytes = await shot.toByteData(format: ui.ImageByteFormat.rawRgba);
        shot.dispose();
        return bytes!;
      });
      List<int> rgb(int x, int y) => [
        for (var c = 0; c < 3; c++) data!.getUint8((y * 260 + x) * 4 + c),
      ];
      debugPrint(
        'STAMP_PIXELS outside=${rgb(130, 190)} corner=${rgb(26, 25)} hole=${rgb(26, 38)} paper=${rgb(26, 46)}',
      );
      expect(rgb(130, 190), [
        255,
        255,
        255,
      ], reason: 'Reference filter output is clipped by its final mask.');
      expect(rgb(26, 25), [
        255,
        255,
        255,
      ], reason: 'The centered repeat has a partial circle at y=-3.');
      expect(rgb(26, 38), [
        255,
        255,
        255,
      ], reason: 'A5px-radius side hole is centered at y13.');
      expect(rgb(26, 46), [
        251,
        250,
        245,
      ], reason: 'The untouched paper between holes retains its warm fill.');
      await t.pumpWidget(const SizedBox());
      await t.pump();
      photo.image.dispose();
    },
  );

  testWidgets(
    'preview closes with Escape, restores trigger focus, and does not fire image callbacks twice',
    (t) async {
      final image = picture(), source = _Photo(picture());
      var loaded = 0;
      await t.pumpWidget(
        host(
          IslandImage(
            image: source,
            alt: 'Coast',
            width: 200,
            height: 120,
            onLoaded: () => loaded++,
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(loaded, 1);
      await t.tap(button('Coast'));
      await t.pumpAndSettle();
      expect(button('Close preview'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      expect(FocusManager.instance.primaryFocus?.context, isNotNull);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(button('Close preview'), findsNothing);
      expect(loaded, 1);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(button('Close preview'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      source.image.dispose();
      image.dispose();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('lazy image does not resolve offscreen and loads near viewport', (
    t,
  ) async {
    final image = picture(), source = _Photo(picture());
    final scroll = ScrollController();
    await t.pumpWidget(
      host(
        SingleChildScrollView(
          controller: scroll,
          child: Column(
            children: [
              const SizedBox(height: 1600),
              IslandImage(image: source, lazy: true, width: 200, height: 100),
            ],
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    expect(source.loads, 0);
    scroll.jumpTo(scroll.position.maxScrollExtent);
    await t.pumpAndSettle();
    expect(source.loads, 1);
    await t.pumpWidget(const SizedBox());
    scroll.dispose();
    source.image.dispose();
    image.dispose();
  });
  testWidgets(
    'failed source is noninteractive and replacing it resets callbacks',
    (t) async {
      var errors = 0;
      var path = 'missing-first.png';
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (c, s) {
              update = s;
              return IslandImage(
                image: AssetImage(path),
                alt: 'Photo',
                width: 200,
                height: 100,
                variant: IslandImageVariant.stamp,
                onError: (_, __) => errors++,
              );
            },
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(errors, 1);
      expect(find.text('Image failed to load'), findsOneWidget);
      expect(button('Photo'), findsNothing);
      update(() => path = 'missing-second.png');
      await t.pumpAndSettle();
      expect(errors, 2);
    },
  );
  testWidgets('source replacement removes only its own preview route', (
    t,
  ) async {
    final a = _Photo(picture()), b = _Photo(picture());
    var source = a;
    late StateSetter update;
    late BuildContext page;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (c, s) {
            page = c;
            update = s;
            return IslandImage(
              image: source,
              alt: 'Photo',
              width: 200,
              height: 100,
            );
          },
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(button('Photo'));
    await t.pumpAndSettle();
    showDialog<void>(
      context: page,
      builder: (_) => const AlertDialog(content: Text('Independent dialog')),
    );
    await t.pumpAndSettle();
    update(() => source = b);
    await t.pumpAndSettle();
    expect(find.text('Independent dialog'), findsOneWidget);
    expect(button('Close preview'), findsNothing);
    await t.pumpWidget(const SizedBox());
    await t.pumpAndSettle();
    a.image.dispose();
    b.image.dispose();
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'preview close keeps the16px crossed mark and150ms reversible hover scale',
    (t) async {
      final photo = _Photo(picture());
      await t.pumpWidget(
        host(IslandImage(image: photo, alt: 'Coast', width: 200, height: 120)),
      );
      await t.pumpAndSettle();
      await t.tap(button('Coast'));
      await t.pumpAndSettle();
      final close = button('Close preview');
      final mark = find.descendant(
        of: close,
        matching: find.byWidgetPredicate(
          (w) => w is CustomPaint && w.size == const Size.square(16),
        ),
      );
      expect(mark, findsOneWidget);
      expect(t.getSize(mark), const Size.square(16));
      final scale = find.descendant(
        of: close,
        matching: find.byType(ScaleTransition),
      );
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(close));
      await t.pump();
      await t.pump(const Duration(milliseconds: 75));
      expect(
        t.widget<ScaleTransition>(scale).scale.value,
        closeTo(1 + .06 * Curves.ease.transform(.5), .0001),
      );
      final before = t.widget<ScaleTransition>(scale).scale.value;
      await mouse.moveTo(Offset.zero);
      await t.pump();
      expect(
        t.widget<ScaleTransition>(scale).scale.value,
        closeTo(before, .0001),
      );
      await t.pump(const Duration(milliseconds: 150));
      expect(t.widget<ScaleTransition>(scale).scale.value, 1);
      await mouse.removePointer();
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      photo.image.dispose();
    },
  );
}
