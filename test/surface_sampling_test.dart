import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:animal_island_ui/src/internal/anchored_panel.dart';

import 'support/frame_sample.dart';

void main() => registerSurfaceSamplingTests();

/// Owns only a deterministic test payload; production treats it as opaque.
class _Patch extends StatelessWidget {
  const _Patch(this.family, this.words, this.boxKey, this.inkKey, this.height);
  final String family, words;
  final GlobalKey boxKey, inkKey;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
    key: boxKey,
    width: 144,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xff000000),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          words,
          key: inkKey,
          style: TextStyle(
            fontFamily: family,
            fontSize: 16,
            height: 1.5,
            color: const Color(0xffffffff),
            decoration: TextDecoration.none,
          ),
        ),
      ),
    ),
  );
}

void registerSurfaceSamplingTests({
  Future<void> Function()? loadFonts,
  String? captureDirectory,
  List<int> sampleTimes = const [16, 32, 64],
  List<double> ratios = const [1, 1.25],
}) {
  setUpAll(
    loadFonts ??
        () async {
          for (final face in [
            ('IslandGalleryControls', 'Arimo-Variable.ttf'),
            ('IslandGallerySans', 'IslandGallerySans-400.ttf'),
          ]) {
            final loader = FontLoader(face.$1);
            loader.addFont(
              File('example/assets/fonts/${face.$2}')
                  .readAsBytes()
                  .then(ByteData.sublistView),
            );
            await loader.load();
          }
        },
  );
  for (final configuration in [
    (Duration.zero, const Offset(0, -6)),
    (const Duration(milliseconds: 200), Offset.zero),
  ]) {
    testWidgets(
      'nonmoving panel retains unfiltered identity ${configuration.$1.inMilliseconds}/${configuration.$2}',
      (t) async {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: AnchoredPanel(
                  open: true,
                  onDismiss: () {},
                  width: 144,
                  estimatedHeight: 40,
                  transitionDuration: configuration.$1,
                  transitionOffset: configuration.$2,
                  anchor: const SizedBox(width: 144, height: 40),
                  panel: const Text('Static panel'),
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
        final target = find.text('Static panel'),
            original = t.getRect(find.text('Static panel'));
        final transform = t.widget<Transform>(
          find.ancestor(of: target, matching: find.byType(Transform)).first,
        );
        expect(transform.filterQuality, isNull);
        expect(transform.transform.storage[12], 0);
        expect(transform.transform.storage[13], 0);
        await t.pump(const Duration(milliseconds: 32));
        expect(t.getRect(target), original);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      },
    );
  }
  for (final kind in [
    'notification',
    'tooltip-y',
    'tooltip-x',
    'anchor',
    'carousel',
  ]) {
    for (final face in [
      ('IslandGalleryControls', 'Calm Motion', 75.0),
      ('IslandGalleryControls', 'Calm Motion', 76.0),
      ('IslandGallerySans', '岛屿设置', 75.0),
      ('IslandGallerySans', '岛屿设置', 76.0),
    ]) {
      for (final ratio in ratios) {
        final label = '$kind-${face.$1}-dpr$ratio-h${face.$3}';
        testWidgets('whole surface sampling $label', (t) async {
          t.view.devicePixelRatio = ratio;
          t.view.physicalSize = Size(800 * ratio, 650 * ratio);
          addTearDown(t.view.resetDevicePixelRatio);
          addTearDown(t.view.resetPhysicalSize);
          final boundary = GlobalKey(), box = GlobalKey(), ink = GlobalKey();
          final controller = IslandNotificationsController();
          final state = ValueNotifier(true);
          addTearDown(controller.dispose);
          addTearDown(state.dispose);
          addTearDown(() async {
            await t.pumpWidget(const SizedBox());
            await t.pumpAndSettle();
          });
          VoidCallback? toggle;
          IslandNotificationHandle? handle;
          final patch = _Patch(face.$1, face.$2, box, ink, face.$3);
          await t.pumpWidget(
            MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: IslandTheme.create(),
              localizationsDelegates: IslandLocalizations.delegates,
              supportedLocales: IslandLocalizations.supportedLocales,
              builder: (_, child) =>
                  RepaintBoundary(key: boundary, child: child!),
              home: Scaffold(
                body: ValueListenableBuilder<bool>(
                  valueListenable: state,
                  builder: (_, visible, child) {
                    if (kind == 'notification') {
                      return IslandNotifications(
                        controller: controller,
                        child: const SizedBox.expand(),
                      );
                    }
                    if (kind.startsWith('tooltip')) {
                      return Center(
                        child: IslandTooltip.click(
                          message: 'Probe',
                          content: patch,
                          placement: kind == 'tooltip-x'
                              ? IslandTooltipPlacement.right
                              : IslandTooltipPlacement.top,
                          builder: (_, action) {
                            toggle = action;
                            return TextButton(
                              onPressed: action,
                              child: const Text('Anchor'),
                            );
                          },
                        ),
                      );
                    }
                    if (kind == 'anchor') {
                      return Center(
                        child: AnchoredPanel(
                          open: visible,
                          onDismiss: () => state.value = false,
                          width: 144,
                          estimatedHeight: 76,
                          transitionDuration: const Duration(milliseconds: 200),
                          anchor: const SizedBox(width: 144, height: 40),
                          panel: patch,
                        ),
                      );
                    }
                    return Center(
                      child: SizedBox(
                        width: 360,
                        child: IslandCarousel<int>(
                          value: visible ? 1 : 0,
                          onChanged: (_) {},
                          showArrows: false,
                          showDots: false,
                          items: [
                            const IslandSlide(
                              value: 0,
                              child: SizedBox(width: 360, height: 200),
                            ),
                            IslandSlide(
                              value: 1,
                              child: SizedBox(
                                width: 360,
                                height: 200,
                                child: Center(child: patch),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          Future<void> change(bool visible) async {
            if (kind == 'notification') {
              if (visible) {
                handle = controller.show(
                  IslandNotification(message: patch, duration: Duration.zero),
                );
              } else {
                handle!.close();
              }
            } else if (kind.startsWith('tooltip')) {
              toggle!();
            } else {
              state.value = visible;
            }
            await t.pump();
            await t.pump();
          }

          if (kind == 'notification' || kind.startsWith('tooltip'))
            await change(true);
          await t.pumpAndSettle();
          final rows = <Map<String, Object?>>[];
          final horizontal = kind == 'tooltip-x' || kind == 'carousel';
          Future<double> sample(String phase, int requestedMs) async {
            final frame = await sampleFrame(t, () => null);
            final result = await t.runAsync(() async {
              final root =
                  boundary.currentContext!.findRenderObject()!
                      as RenderRepaintBoundary;
              final origin = root.localToGlobal(Offset.zero);
              final patchBox =
                  box.currentContext!.findRenderObject()! as RenderBox;
              final textBox =
                  ink.currentContext!.findRenderObject()! as RenderBox;
              Rect rect(RenderBox b) => Rect.fromPoints(
                (b.localToGlobal(Offset.zero) - origin) * ratio,
                (b.localToGlobal(b.size.bottomRight(Offset.zero)) - origin) *
                    ratio,
              );
              final area = rect(patchBox), words = rect(textBox);
              final image = await root.toImage(pixelRatio: ratio);
              final rgba = (await image.toByteData(
                format: ui.ImageByteFormat.rawRgba,
              ))!;
              double channel(int x, int y) {
                expect(x, inInclusiveRange(0, image.width - 1));
                expect(y, inInclusiveRange(0, image.height - 1));
                return rgba.getUint8((y * image.width + x) * 4 + 2).toDouble();
              }

              // Negative derivative of the black patch's edge. Sample near its
              // actual transformed position, away from rounded corners/outer UI.
              final start = horizontal ? area.left : area.top;
              final cross = horizontal ? area.center.dy : area.center.dx;
              var edgeMass = 0.0, edgeMoment = 0.0;
              for (
                var q = (start - 3 * ratio).floor();
                q < (start + 3 * ratio).ceil();
                q++
              ) {
                for (var p = cross.floor() - 3; p < cross.floor() + 3; p++) {
                  final value = horizontal ? channel(q, p) : channel(p, q);
                  final previous = horizontal
                      ? channel(q - 1, p)
                      : channel(p, q - 1);
                  final weight = math.max(0.0, previous - value);
                  edgeMass += weight;
                  edgeMoment += weight * (q + .5);
                }
              }
              expect(
                edgeMass,
                greaterThan(0),
                reason: 'black patch edge must be visible',
              );
              var inkMass = 0.0, inkMoment = 0.0;
              final scan = words.inflate(2 * ratio);
              for (var y = scan.top.floor(); y < scan.bottom.ceil(); y++) {
                for (var x = scan.left.floor(); x < scan.right.ceil(); x++) {
                  final weight = channel(x, y);
                  inkMass += weight;
                  inkMoment += weight * ((horizontal ? x : y) + .5);
                }
              }
              expect(
                inkMass,
                greaterThan(0),
                reason: 'real glyph ink must be visible',
              );
              final edge = edgeMoment / edgeMass, glyph = inkMoment / inkMass;
              rows.add({
                'phase': phase,
                'requested_elapsed_ms': requestedMs,
                'reference_frame_us': frame.stamp.inMicroseconds,
                'binding': t.binding.runtimeType.toString(),
                'axis': horizontal ? 'x' : 'y',
                'edge_centroid': edge,
                'ink_centroid': glyph,
                'relative': glyph - edge,
                'render_target_dpr': ratio,
                'word_bounds': [
                  words.left,
                  words.top,
                  words.right,
                  words.bottom,
                ],
                'text_style': (textBox as RenderParagraph).text.style
                    .toString(),
                'patch_bounds': [area.left, area.top, area.right, area.bottom],
              });
              final out =
                  captureDirectory ??
                  Platform.environment['SURFACE_SAMPLING_EVIDENCE'];
              if (out != null) {
                final dir = Directory('$out/$label')
                  ..createSync(recursive: true);
                final png = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                File('${dir.path}/$phase-$requestedMs.png')
                    .writeAsBytesSync(png!.buffer.asUint8List());
                File('${dir.path}/measurements.json')
                    .writeAsStringSync(jsonEncode(rows));
              }
              image.dispose();
              return glyph - edge;
            });
            return result!;
          }

          final baseline = await sample('rest', 0);
          Future<void> samples(String phase) async {
            var previous = 0;
            for (final ms in sampleTimes) {
              await t.pump(Duration(milliseconds: ms - previous));
              previous = ms;
              await sample(phase, ms);
            }
          }

          await change(false);
          if (kind != 'carousel') await samples('exit');
          await t.pumpAndSettle();
          await change(true);
          await samples('enter');
          if (kind != 'notification') {
            // Begin reversal from a fully open lifetime; a live clock may
            // otherwise correctly finish a short reverse before capture.
            await t.pumpAndSettle();
            await change(false);
            await t.pump(const Duration(milliseconds: 16));
            if (kind != 'carousel') await sample('reverse-out', 16);
            await change(true);
            await samples('reverse-in');
          }
          await t.pumpAndSettle();
          await sample('rest-after', 0);
          final maximum = rows
              .map((x) => ((x['relative']! as double) - baseline).abs())
              .reduce(math.max);
          expect(
            maximum,
            lessThanOrEqualTo(.25),
            reason:
                '$label relative backing/ink displacement; all raw phases retained',
          );
          expect(t.takeException(), isNull);
          await t.pumpWidget(const SizedBox());
          await t.pumpAndSettle();
        });
      }
    }
  }
}
