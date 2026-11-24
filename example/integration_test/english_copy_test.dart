import 'dart:io';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// The English copy of the open panels, which the Gallery capture does not
/// reach: every scene must lay out without an overflow at desktop and phone
/// widths. With `ISLAND_SCREENSHOT_DIR` each scene is also written as a PNG.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const folder = String.fromEnvironment('ISLAND_SCREENSHOT_DIR');
  final boundary = GlobalKey();

  Future<void> host(WidgetTester t, Size size, Widget child) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = size;
    await binding.setSurfaceSize(size);
    await t.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          key: UniqueKey(),
          debugShowCheckedModeBanner: false,
          locale: const Locale('en'),
          supportedLocales: IslandLocalizations.supportedLocales,
          localizationsDelegates: IslandLocalizations.delegates,
          theme: IslandTheme.create(),
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> shot(WidgetTester t, String name) async {
    await t.pumpAndSettle();
    expect(t.takeException(), isNull, reason: name);
    if (folder.isEmpty) return;
    await Directory(folder).create(recursive: true);
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage(pixelRatio: 1);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    await File('$folder/$name.png').writeAsBytes(png!.buffer.asUint8List());
  }

  for (final size in const [Size(1440, 900), Size(375, 812)]) {
    final w = size.width.toInt();
    testWidgets('English picker, select and modal panels fit at $w', (t) async {
      final day = DateTime(2026, 9, 23);
      await host(
        t,
        size,
        IslandDatePicker(value: day, onChanged: (_) {}, allowClear: true),
      );
      await t.tap(find.byType(IslandDatePicker));
      await shot(t, 'date-day-$w');
      expect(find.text('Today'), findsOneWidget);
      // The title opens the year view; a year opens its months.
      await t.tap(find.text('Sep 2026'));
      await shot(t, 'date-year-$w');
      expect(find.text('2020 - 2029'), findsOneWidget);
      await t.tap(find.text('2026'));
      await shot(t, 'date-month-$w');
      expect(find.text('Sep'), findsOneWidget);

      await host(
        t,
        size,
        IslandDatePicker.range(
          value: DateTimeRange(start: day, end: DateTime(2026, 10, 2)),
          onChanged: (_) {},
        ),
      );
      await t.tap(find.byType(IslandDatePicker));
      await shot(t, 'date-range-$w');

      await host(t, size, IslandTimePicker(value: null, onChanged: (_) {}));
      await t.tap(find.byType(IslandTimePicker));
      await shot(t, 'time-$w');
      for (final text in ['Hour', 'Min', 'Sec', 'Now', 'OK']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }

      await host(
        t,
        size,
        IslandSelect<int>(options: const [], value: null, onChanged: (_) {}),
      );
      await t.tap(find.byType(IslandSelect<int>));
      await shot(t, 'select-empty-$w');
      expect(find.text('No data'), findsOneWidget);

      await host(t, size, const SizedBox());
      showIslandModal<void>(
        context: t.element(find.byType(SizedBox).first),
        title: const Text('Leave the island?'),
        builder: (_) => const Text('Unsaved changes will be lost.'),
      );
      await shot(t, 'modal-$w');
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  }
}
