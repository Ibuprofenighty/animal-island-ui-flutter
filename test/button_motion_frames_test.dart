import 'support/frame_sample.dart';

import 'dart:io';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => registerButtonMotionTests();

void registerButtonMotionTests({
  String fontAsset = 'assets/fonts/FiraCode-Variable.ttf',
  String? captureDirectory,
}) {
  setUpAll(() async {
    final loader = FontLoader(IslandTheme.codeFontFamily);
    loader.addFont(rootBundle.load(fontAsset));
    await loader.load();
  });
  for (final ratio in [1.0, 1.25, 2.0]) {
    for (final dark in [false, true]) {
      for (final reduced in [false, true]) {
        final label =
            'primary-${dark ? 'dark' : 'light'}-dpr$ratio-reduced$reduced';
        testWidgets('rigid button pixel motion $label', (t) async {
          t.view.devicePixelRatio = ratio;
          t.view.physicalSize = Size(800 * ratio, 600 * ratio);
          addTearDown(t.view.resetDevicePixelRatio);
          addTearDown(t.view.resetPhysicalSize);
          final strategy = FocusManager.instance.highlightStrategy;
          FocusManager.instance.highlightStrategy =
              FocusHighlightStrategy.alwaysTouch;
          addTearDown(() => FocusManager.instance.highlightStrategy = strategy);
          final boundary = GlobalKey();
          await t.pumpWidget(
            MaterialApp(
              theme: IslandTheme.create(
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              builder: (_, child) => MediaQuery(
                data: MediaQueryData(
                  size: const Size(800, 600),
                  devicePixelRatio: ratio,
                  disableAnimations: reduced,
                ),
                child: child!,
              ),
              home: Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: RepaintBoundary(
                    key: boundary,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IslandButton(
                        variant: IslandButtonVariant.primary,
                        onPressed: () {},
                        child: const Text(
                          'Action',
                          style: TextStyle(
                            fontFamily: IslandTheme.codeFontFamily,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          await t.pumpAndSettle();
          final origin = t.getTopLeft(find.byKey(boundary));
          final word = t.getRect(find.text('Action')).shift(-origin);
          final button = t.getRect(find.byType(IslandButton)).shift(-origin);
          Rect physical(Rect rect) => Rect.fromLTRB(
            rect.left * ratio,
            rect.top * ratio,
            rect.right * ratio,
            rect.bottom * ratio,
          );
          final pixelWord = physical(word), pixelButton = physical(button);
          final rows = <Map<String, Object?>>[];
          Future<double> sample(String phase, int time) async {
            final referenceFrame = await sampleFrame(t, () => null);
            final result = await t.runAsync(() async {
              final image =
                  await (boundary.currentContext!.findRenderObject()!
                          as RenderRepaintBoundary)
                      .toImage(pixelRatio: ratio);
              final data = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              double centroid(Rect area, double cutoff, {bool darker = true}) {
                var mass = 0.0, moment = 0.0;
                for (var y = area.top.floor(); y < area.bottom.ceil(); y++) {
                  for (var x = area.left.floor(); x < area.right.ceil(); x++) {
                    final i = (y * image.width + x) * 4;
                    final intensity =
                        (data.getUint8(i) +
                            data.getUint8(i + 1) +
                            data.getUint8(i + 2)) /
                        3;
                    final weight =
                        (darker ? cutoff - intensity : intensity - cutoff)
                            .clamp(0.0, 255.0);
                    mass += weight;
                    moment += weight * (y + .5);
                  }
                }
                expect(mass, greaterThan(0));
                return moment / mass;
              }

              // The alpha derivative locates the backing edge without shadow or color
              // thresholds. Ink uses its exact flat paper luminance, so bilinear image
              // sampling remains linear instead of clipping low-coverage glyph pixels.
              var edgeMass = 0.0, edgeMoment = 0.0;
              for (
                var y = pixelButton.top.floor() - (4 * ratio).ceil();
                y < pixelButton.top.ceil() + (5 * ratio).ceil();
                y++
              ) {
                for (
                  var x = pixelButton.center.dx.floor() - 6;
                  x < pixelButton.center.dx.floor() + 6;
                  x++
                ) {
                  final alpha = data.getUint8((y * image.width + x) * 4 + 3);
                  final above = data.getUint8(
                    ((y - 1) * image.width + x) * 4 + 3,
                  );
                  final delta = (alpha - above).clamp(0, 255).toDouble();
                  edgeMass += delta;
                  edgeMoment += delta * (y + .5);
                }
              }
              expect(edgeMass, greaterThan(0));
              final edge = edgeMoment / edgeMass;
              final flat =
                  (((button.top + 7) * ratio).floor() * image.width +
                      (button.center.dx * ratio).floor()) *
                  4;
              final paper =
                  (data.getUint8(flat) +
                      data.getUint8(flat + 1) +
                      data.getUint8(flat + 2)) /
                  3;
              // Dark paper can be darker than ink: use a linear signed contrast mass.
              final inkIsDarker = !dark;
              final ink = centroid(
                pixelWord.inflate(3 * ratio),
                paper,
                darker: inkIsDarker,
              );
              final entry = {
                'phase': phase,
                'requested_elapsed_ms': time,
                'capture_reference_frame_us':
                    referenceFrame.stamp.inMicroseconds,
                'binding': t.binding.runtimeType.toString(),
                'edge_centroid': edge,
                'ink_centroid': ink,
                'relative_y': ink - edge,
                'render_target_dpr': ratio,
                'dark': dark,
                'reduced': reduced,
              };
              rows.add(entry);
              final root =
                  captureDirectory ??
                  Platform.environment['BUTTON_MOTION_EVIDENCE'];
              final out = root == null ? null : '$root/$label';
              if (out != null) {
                Directory(out).createSync(recursive: true);
                final png = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                File('$out/$phase-$time.png')
                    .writeAsBytesSync(png!.buffer.asUint8List());
                File('$out/measurements.json')
                    .writeAsStringSync(jsonEncode(rows));
              }
              image.dispose();
              return ink - edge;
            });
            return result!;
          }

          final base = await sample('rest', 0);
          final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
          await mouse.addPointer(location: Offset.zero);
          for (final phase in [
            'enter',
            'exit',
            'enter-reverse',
            'exit-reverse',
            'enter-press',
            'press',
            'release',
            'exit-after-release',
          ]) {
            if (phase == 'press') {
              await mouse.down(word.center + origin);
            } else if (phase == 'release') {
              await mouse.up();
            } else {
              await mouse.moveTo(
                phase.startsWith('enter') ? word.center + origin : Offset.zero,
              );
            }
            await t.pump();
            var elapsed = 0;
            for (final time
                in phase.endsWith('reverse')
                    ? [0, 16, 32, 64]
                    : [0, 16, 32, 64, 96, 128, 176, 224, 250]) {
              await t.pump(Duration(milliseconds: time - elapsed));
              elapsed = time;
              final relative = await sample(phase, time);
              expect(
                relative,
                closeTo(base, .25),
                reason: '$phase at $time ms: backing/ink relative shift',
              );
            }
          }
          await mouse.removePointer();
          await t.pumpAndSettle();
        });
      }
    }
  }
}
