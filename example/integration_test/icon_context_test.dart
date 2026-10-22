import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('All canonical glyphs on real light dark and Card backplanes', (
    t,
  ) async {
    const size = Size(1440, 1000);
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = size;
    await binding.setSurfaceSize(size);
    final folder = Directory(
      const String.fromEnvironment('ISLAND_SCREENSHOT_DIR'),
    );
    expect(folder.path, isNotEmpty);
    await folder.create(recursive: true);
    final observations = <Map<String, Object?>>[];
    final glyphs = IslandGlyph.values.toList()
      ..sort((a, b) => a.assetName.compareTo(b.assetName));
    for (final context in [
      'light-canvas',
      'light-paper',
      'dark-canvas',
      'dark-paper',
      for (final c in IslandColorway.values) 'card-${c.name}',
    ]) {
      final dark = context.startsWith('dark');
      final theme = IslandTheme.create(
        brightness: dark ? Brightness.dark : Brightness.light,
      );
      final tokens = dark ? IslandTokens.dark : IslandTokens.light;
      final key = GlobalKey();
      Widget content = LayoutBuilder(
        builder: (_, c) => Wrap(
          children: [
            for (final glyph in glyphs)
              SizedBox(
                width: c.maxWidth / 12,
                height: 68,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IslandIcon(glyph, key: ValueKey(glyph), size: 48),
                    Text(
                      glyph.assetName,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        fontFamily: IslandTheme.codeFontFamily,
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
      if (context.startsWith('card-')) {
        final colorway = IslandColorway.values.firstWhere(
          (c) => context == 'card-${c.name}',
        );
        content = IslandCard(
          pattern: colorway,
          padding: const EdgeInsets.all(16),
          child: content,
        );
      } else {
        content = ColoredBox(
          color: context.endsWith('paper') ? tokens.paper : tokens.canvas,
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        );
      }
      await t.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: theme,
            home: Scaffold(body: content),
          ),
        ),
      );
      await t.runAsync(() async {
        for (final element in find.byType(SvgPicture).evaluate()) {
          final data = await vg.loadPicture(
            (element.widget as SvgPicture).bytesLoader,
            element,
          );
          data.picture.dispose();
        }
      });
      await t.pump();
      await t.pump(const Duration(milliseconds: 32));
      expect(t.takeException(), isNull, reason: context);
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 1);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await File('${folder.path}/$context.png')
          .writeAsBytes(png!.buffer.asUint8List());
      observations.add({
        'context': context,
        'size': [size.width, size.height],
        'glyphs': [
          for (final glyph in glyphs)
            {
              'name': glyph.assetName,
              'rect': (() {
                final r = t.getRect(find.byKey(ValueKey(glyph)));
                return [r.left, r.top, r.width, r.height];
              })(),
              'inherited_color': IconTheme.of(
                t.element(find.byKey(ValueKey(glyph))),
              ).color?.toARGB32(),
            },
        ],
      });
      await File('${folder.path}/observations.json')
          .writeAsString(jsonEncode(observations));
    }
  });
}
