import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// A caller-supplied outlined shape can contain open, short or multiple contours.
class _PathBorder extends OutlinedBorder {
  const _PathBorder(this.path);
  final Path? path;
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      path ??
      (Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top)
        ..lineTo(rect.right, rect.bottom)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top));
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);
  @override
  _PathBorder copyWith({BorderSide? side}) => this;
  @override
  ShapeBorder scale(double t) => this;
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}
}

Future<Uint8List> _raster(void Function(Canvas) draw, {double dpr = 1}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..scale(dpr);
  canvas.drawColor(Colors.white, BlendMode.src);
  draw(canvas);
  final picture = recorder.endRecording();
  final image = await picture.toImage((32 * dpr).round(), (24 * dpr).round());
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
      .buffer
      .asUint8List();
  image.dispose();
  picture.dispose();
  return bytes;
}

Paint _ink([double width = 2]) => Paint()
  ..color = Colors.black
  ..style = PaintingStyle.stroke
  ..strokeWidth = width;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('short, exact and partial trailing dashes match analytic line segments', () async {
    // Explicit expected endpoints are independent of the path-metric algorithm.
    for (final sample in <(double, List<(double, double)>)>[
      (2.5, [(2, 2.5)]),
      (6, [(2, 6)]),
      (7, [(2, 6)]),
      (10, [(2, 6)]),
      (11, [(2, 6), (10, 11)]),
      (20, [(2, 6), (10, 14), (18, 20)]),
    ]) {
      for (final dpr in [1.0, 1.25, 2.0]) {
        final path = Path()
          ..moveTo(2, 4)
          ..lineTo(sample.$1, 4);
        final painter = IslandDashedBorderPainter(
          shape: _PathBorder(path),
          color: Colors.black,
          strokeWidth: 2,
        );
        final actual = await _raster(
          (canvas) => painter.paint(canvas, const Size(32, 24)),
          dpr: dpr,
        );
        final expected = await _raster((canvas) {
          for (final segment in sample.$2) {
            canvas.drawLine(
              Offset(segment.$1, 4),
              Offset(segment.$2, 4),
              _ink(),
            );
          }
        }, dpr: dpr);
        expect(
          actual,
          orderedEquals(expected),
          reason: 'end=${sample.$1} DPR=$dpr',
        );
      }
    }
  });

  test(
    'open contours reset phase and stay open; empty contours paint nothing',
    () async {
      final path = Path()
        ..moveTo(2, 4)
        ..lineTo(20, 4)
        ..moveTo(2, 10)
        ..lineTo(4, 10)
        ..moveTo(4, 16)
        ..lineTo(15, 16)
        ..moveTo(28, 20);
      final actual = await _raster(
        (canvas) => IslandDashedBorderPainter(
          shape: _PathBorder(path),
          color: Colors.black,
          strokeWidth: 2,
        ).paint(canvas, const Size(32, 24)),
      );
      final expected = await _raster((canvas) {
        for (final line in <(Offset, Offset)>[
          (const Offset(2, 4), const Offset(6, 4)),
          (const Offset(10, 4), const Offset(14, 4)),
          (const Offset(18, 4), const Offset(20, 4)),
          (const Offset(2, 10), const Offset(4, 10)),
          (const Offset(4, 16), const Offset(8, 16)),
          (const Offset(12, 16), const Offset(15, 16)),
        ]) {
          canvas.drawLine(line.$1, line.$2, _ink());
        }
      });
      expect(actual, orderedEquals(expected));
      final empty = await _raster(
        (canvas) => IslandDashedBorderPainter(
          shape: _PathBorder(Path()),
          color: Colors.black,
        ).paint(canvas, const Size(32, 24)),
      );
      expect(empty, orderedEquals(await _raster((_) {})));
      // Distinguishing controls represent the actual error classes, without a
      // second dashed renderer or any modification of production source.
      for (final wrong in <void Function(Canvas)>[
        (canvas) => canvas.drawRect(
          const Rect.fromLTWH(18, 3, 2, 2),
          Paint()..color = Colors.white,
        ),
        (canvas) =>
            canvas.drawLine(const Offset(8, 16), const Offset(12, 16), _ink()),
        (canvas) =>
            canvas.drawLine(const Offset(20, 4), const Offset(2, 4), _ink()),
      ]) {
        final mutated = await _raster((canvas) {
          final imagePath = Path()
            ..moveTo(2, 4)
            ..lineTo(6, 4)
            ..moveTo(10, 4)
            ..lineTo(14, 4)
            ..moveTo(18, 4)
            ..lineTo(20, 4)
            ..moveTo(2, 10)
            ..lineTo(4, 10)
            ..moveTo(4, 16)
            ..lineTo(8, 16)
            ..moveTo(12, 16)
            ..lineTo(15, 16);
          canvas.drawPath(imagePath, _ink());
          wrong(canvas);
        });
        expect(mutated, isNot(orderedEquals(actual)));
      }
    },
  );

  test(
    'shape inset, gap zero and hairline width retain Canvas geometry',
    () async {
      for (final width in [0.0, 1.0, 1.5, 2.0, 4.0]) {
        for (final dpr in [1.0, 1.25, 2.0]) {
          final actual = await _raster(
            (canvas) => IslandDashedBorderPainter(
              shape: const _PathBorder(null),
              color: Colors.black,
              strokeWidth: width,
              dash: 1000,
              gap: 0,
            ).paint(canvas, const Size(32, 24)),
            dpr: dpr,
          );
          final inset = width / 2;
          final expected = await _raster(
            (canvas) => canvas.drawPath(
              Path()
                ..moveTo(inset, inset)
                ..lineTo(32 - inset, inset)
                ..lineTo(32 - inset, 24 - inset)
                ..lineTo(inset, 24 - inset)
                ..lineTo(inset, inset),
              _ink(width),
            ),
            dpr: dpr,
          );
          expect(
            actual,
            orderedEquals(expected),
            reason: 'width=$width DPR=$dpr',
          );
          expect(actual, isNot(orderedEquals(await _raster((_) {}, dpr: dpr))));
        }
      }
      final actual = await _raster(
        (canvas) => IslandDashedBorderPainter(
          shape: _PathBorder(
            Path()
              ..moveTo(2, 4)
              ..lineTo(20, 4),
          ),
          color: Colors.black,
          strokeWidth: 2,
          dash: 3,
          gap: 0,
        ).paint(canvas, const Size(32, 24)),
      );
      final expected = await _raster(
        (canvas) =>
            canvas.drawLine(const Offset(2, 4), const Offset(20, 4), _ink()),
      );
      expect(actual, orderedEquals(expected));
    },
  );

  test('invalid public stroke recipes fail constructor assertions', () {
    for (final dash in [0.0, -1.0, double.infinity, double.nan]) {
      expect(
        () => IslandDashedBorderPainter(
          shape: const StadiumBorder(),
          color: Colors.black,
          dash: dash,
        ),
        throwsAssertionError,
      );
    }
    for (final value in [-1.0, double.infinity, double.nan]) {
      expect(
        () => IslandDashedBorderPainter(
          shape: const StadiumBorder(),
          color: Colors.black,
          gap: value,
        ),
        throwsAssertionError,
      );
      expect(
        () => IslandDashedBorderPainter(
          shape: const StadiumBorder(),
          color: Colors.black,
          strokeWidth: value,
        ),
        throwsAssertionError,
      );
    }
  });

  testWidgets(
    'every stroke input repaints without replacing opaque content or focus',
    (t) async {
      final controller = TextEditingController(text: 'Stable');
      final focus = FocusNode();
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      final boundary = GlobalKey();
      var calls = 0;
      late StateSetter update;
      var color = Colors.black;
      var width = 2.0;
      var dash = 4.0;
      var gap = 4.0;
      OutlinedBorder shape = const RoundedRectangleBorder();
      final child = TextField(
        controller: controller,
        focusNode: focus,
        showCursor: false,
        onChanged: (_) => calls++,
      );
      await t.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (_, set) {
                  update = set;
                  return RepaintBoundary(
                    key: boundary,
                    child: SizedBox(
                      width: 160,
                      height: 80,
                      child: CustomPaint(
                        foregroundPainter: IslandDashedBorderPainter(
                          shape: shape,
                          color: color,
                          strokeWidth: width,
                          dash: dash,
                          gap: gap,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: child,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await t.pump();
      controller.selection = const TextSelection(
        baseOffset: 1,
        extentOffset: 4,
      );
      await t.pump();
      final editable = t.state(find.byType(EditableText));
      Future<Uint8List> bytes() async {
        return (await t.runAsync(() async {
          final image =
              await (boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary)
                  .toImage();
          final result = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!.buffer.asUint8List();
          image.dispose();
          return result;
        }))!;
      }

      var previous = await bytes();
      for (final change in <VoidCallback>[
        () => color = Colors.red,
        () => width = 4,
        () => dash = 6,
        () => gap = 2,
        () => shape = const StadiumBorder(),
      ]) {
        update(change);
        await t.pump();
        final next = await bytes();
        expect(next, isNot(orderedEquals(previous)));
        previous = next;
        expect(t.state(find.byType(EditableText)), same(editable));
        expect(focus.hasPrimaryFocus, isTrue);
        expect(controller.text, 'Stable');
        expect(
          controller.selection,
          const TextSelection(baseOffset: 1, extentOffset: 4),
        );
        expect(calls, 0);
        expect(t.takeException(), isNull);
      }
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
}
