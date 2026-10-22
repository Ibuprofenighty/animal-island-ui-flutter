import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../../test/surface_sampling_test.dart' as sampling;

import 'package:animal_island_ui/src/internal/anchored_panel.dart';

import '../test/support/gallery_fonts.dart';
import '../test/carousel_sampling_test.dart' as photos;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  const output = String.fromEnvironment('SURFACE_SAMPLING_EVIDENCE');
  final timingRows = <Map<String, Object?>>[];
  void collectTimings(List<ui.FrameTiming> frames) {
    for (final frame in frames) {
      timingRows.add({
        'build_us': frame.buildDuration.inMicroseconds,
        'raster_us': frame.rasterDuration.inMicroseconds,
        'total_span_us': frame.totalSpan.inMicroseconds,
      });
    }
  }

  binding.addTimingsCallback(collectTimings);
  final engineView = ui.PlatformDispatcher.instance.implicitView;
  if (output.isNotEmpty) {
    Directory(output).createSync(recursive: true);
    File('$output/native-environment.json').writeAsStringSync(
      jsonEncode({
        'engine_view_device_pixel_ratio': engineView?.devicePixelRatio,
        'engine_view_physical_size': engineView == null
            ? null
            : [engineView.physicalSize.width, engineView.physicalSize.height],
        'display_device_pixel_ratio': engineView?.display.devicePixelRatio,
        'display_size': engineView == null
            ? null
            : [engineView.display.size.width, engineView.display.size.height],
        'os': Platform.operatingSystemVersion,
        'scope': 'Before TestFlutterView metric overrides. Flutter engine client surface and display report; not OS outer-window bounds, desktop screenshot or physical presentationFPS.',
      }),
    );
  }
  sampling.registerSurfaceSamplingTests(
    loadFonts: loadGalleryFonts,
    captureDirectory: output.isEmpty ? null : output,
    sampleTimes: const [16],
    ratios: const [1],
  );
  photos.registerCarouselConsumerCaptures(
    captureDirectory: output.isEmpty ? null : output,
  );
  for (final kind in ['date', 'range', 'time']) {
    testWidgets(
      'native $kind panel retains focus and value through close/reopen',
      (t) async {
        final focus = FocusNode();
        addTearDown(focus.dispose);
        var proposals = 0;
        final initial = DateTime(2026, 10, 20);
        final Widget picker = switch (kind) {
          'time' => IslandTimePicker.uncontrolled(
            initialValue: const IslandTimeValue(12, 30),
            focusNode: focus,
            onChanged: (_) => proposals++,
          ),
          'range' => IslandDatePicker.rangeUncontrolled(
            initialValue: DateTimeRange(
              start: initial,
              end: initial.add(const Duration(days: 2)),
            ),
            focusNode: focus,
            onChanged: (_) => proposals++,
          ),
          _ => IslandDatePicker.uncontrolled(
            initialValue: initial,
            focusNode: focus,
            onChanged: (_) => proposals++,
          ),
        };
        await t.pumpWidget(
          MaterialApp(
            theme: IslandTheme.create(),
            localizationsDelegates: IslandLocalizations.delegates,
            supportedLocales: IslandLocalizations.supportedLocales,
            home: Scaffold(body: Center(child: picker)),
          ),
        );
        await t.pumpAndSettle();
        final finder = kind == 'time'
            ? find.byType(IslandTimePicker)
            : find.byType(IslandDatePicker);
        final labels = t
            .widgetList<Text>(
              find.descendant(of: finder, matching: find.byType(Text)),
            )
            .map((x) => x.data)
            .toList();
        for (var repeat = 0; repeat < 2; repeat++) {
          await t.tap(finder);
          await t.pumpAndSettle();
          expect(
            t.widget<AnchoredPanel>(find.byType(AnchoredPanel)).open,
            isTrue,
          );
          await t.sendKeyEvent(LogicalKeyboardKey.escape);
          await t.pumpAndSettle();
          expect(
            t.widget<AnchoredPanel>(find.byType(AnchoredPanel)).open,
            isFalse,
          );
          expect(focus.hasFocus, isTrue);
          expect(
            t
                .widgetList<Text>(
                  find.descendant(of: finder, matching: find.byType(Text)),
                )
                .map((x) => x.data)
                .toList(),
            labels,
          );
        }
        expect(proposals, 0);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      },
    );
  }
  tearDownAll(() {
    binding.removeTimingsCallback(collectTimings);
    if (output.isNotEmpty) {
      File('$output/native-debug-frame-timings.json').writeAsStringSync(
        jsonEncode({
          'scope': 'Debug/onlyPumps finite named tests, window scene timings only; not all toImage work, production profiling, input latency, or physicalFPS acceptance. No new performance threshold.',
          'frames': timingRows,
        }),
      );
    }
  });
}
