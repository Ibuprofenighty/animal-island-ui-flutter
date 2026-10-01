import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Gallery loads package fonts and OFL from its offline bundle', (
    WidgetTester tester,
  ) async {
    final List<dynamic> manifest = jsonDecode(
      await rootBundle.loadString('FontManifest.json'),
    ) as List<dynamic>;
    final Map<String, dynamic> nunito = _fontRecord(
      manifest,
      AnimalThemeTypography.standard.fontFamily,
    );
    final Map<String, dynamic> noto = _fontRecord(
      manifest,
      AnimalThemeTypography.standard.fontFamilyFallback.first,
    );
    final String nunitoManifestAsset = _singleAsset(nunito);
    final String notoManifestAsset = _singleAsset(noto);
    expect(
      nunitoManifestAsset,
      'packages/animal_island_ui/assets/fonts/Nunito%5Bwght%5D.ttf',
    );
    expect(
      notoManifestAsset,
      'packages/animal_island_ui/assets/fonts/NotoSansSC%5Bwght%5D.ttf',
    );
    final String nunitoAsset = Uri.decodeComponent(nunitoManifestAsset);
    final String notoAsset = Uri.decodeComponent(notoManifestAsset);

    final ByteData nunitoData = await rootBundle.load(nunitoAsset);
    final ByteData notoData = await rootBundle.load(notoAsset);
    expect(nunitoData.lengthInBytes, greaterThan(100000));
    expect(notoData.lengthInBytes, greaterThan(10000000));
    expect(
      Uint8List.view(
        nunitoData.buffer,
        nunitoData.offsetInBytes,
        nunitoData.lengthInBytes,
      ),
      File('../assets/fonts/Nunito[wght].ttf').readAsBytesSync(),
    );
    expect(
      Uint8List.view(
        notoData.buffer,
        notoData.offsetInBytes,
        notoData.lengthInBytes,
      ),
      File('../assets/fonts/NotoSansSC[wght].ttf').readAsBytesSync(),
    );

    final String nunitoLicense = await rootBundle.loadString(
      'packages/animal_island_ui/assets/licenses/OFL-Nunito.txt',
    );
    final String notoLicense = await rootBundle.loadString(
      'packages/animal_island_ui/assets/licenses/OFL-NotoSansSC.txt',
    );
    expect(nunitoLicense, contains('SIL OPEN FONT LICENSE'));
    expect(notoLicense, contains('SIL OPEN FONT LICENSE'));

    await tester.runAsync(() async {
      await (FontLoader(
        AnimalThemeTypography.standard.fontFamily,
      )..addFont(Future.value(nunitoData))).load();
      await (FontLoader(
        AnimalThemeTypography.standard.fontFamilyFallback.first,
      )..addFont(Future.value(notoData))).load();

      const List<FontWeight> requestedWeights = <FontWeight>[
        FontWeight.w400,
        FontWeight.w500,
        FontWeight.w600,
        FontWeight.w700,
        FontWeight.w900,
      ];
      final Uint8List ahemLatin = (await _raster(
        'Ahem',
        'M',
        FontWeight.w400,
      )).pixels;
      final List<Uint8List> latinWeightRasters = <Uint8List>[];
      for (final FontWeight weight in requestedWeights) {
        final _RasterObservation witness = await _raster(
          AnimalThemeTypography.standard.fontFamily,
          'M',
          weight,
        );
        expect(witness.size.width, greaterThan(0));
        latinWeightRasters.add(witness.pixels);
      }
      expect(latinWeightRasters.first, isNot(orderedEquals(ahemLatin)));
      expect(latinWeightRasters.map(base64Encode).toSet(), hasLength(5));

      final Uint8List ahemHan = (await _raster(
        'Ahem',
        '岛',
        FontWeight.w400,
      )).pixels;
      final List<Uint8List> chineseWeightRasters = <Uint8List>[];
      for (final FontWeight weight in requestedWeights) {
        final _RasterObservation witness = await _raster(
          AnimalThemeTypography.standard.fontFamilyFallback.first,
          '岛',
          weight,
        );
        expect(witness.size.width, greaterThan(0));
        chineseWeightRasters.add(witness.pixels);
      }
      expect(chineseWeightRasters.first, isNot(orderedEquals(ahemHan)));
      expect(chineseWeightRasters.map(base64Encode).toSet(), hasLength(5));

      final Uint8List missingFromNunito = (await _raster(
        AnimalThemeTypography.standard.fontFamily,
        '岛',
        FontWeight.w600,
        fontFamilyFallback: <String>[
          AnimalThemeTypography.standard.fontFamilyFallback.first,
        ],
      )).pixels;
      final Uint8List explicitNoto = (await _raster(
        AnimalThemeTypography.standard.fontFamilyFallback.first,
        '岛',
        FontWeight.w600,
      )).pixels;
      expect(
        missingFromNunito,
        orderedEquals(explicitNoto),
        reason: 'a Han glyph absent from Nunito must be drawn by bundled Noto Sans SC',
      );

      final String longMixedText = List<String>.filled(
        12,
        'Animal Island 海岛风格组件库支持中英文混排与长文本展示',
      ).join(' ');
      final _RasterObservation longText = await _raster(
        AnimalThemeTypography.standard.fontFamily,
        longMixedText,
        FontWeight.w500,
        fontFamilyFallback: <String>[
          ...AnimalThemeTypography.standard.fontFamilyFallback,
        ],
        maxWidth: 280,
        maxLines: 4,
        imageHeight: 220,
        fontSize: 24,
      );
      expect(longText.didExceedMaxLines, isTrue);
      expect(longText.lineCount, 4);
      expect(longText.size.width, lessThanOrEqualTo(280));
      expect(longText.size.height, lessThanOrEqualTo(220));
      expect(longText.pixels.any((int value) => value < 255), isTrue);

      final Uint8List unassignedCodepoint = (await _raster(
        AnimalThemeTypography.standard.fontFamily,
        String.fromCharCode(0x10ffff),
        FontWeight.w400,
        fontFamilyFallback: <String>[
          ...AnimalThemeTypography.standard.fontFamilyFallback,
        ],
      )).pixels;
      expect(unassignedCodepoint, hasLength(100 * 64 * 4));
    });
  });
}

Map<String, dynamic> _fontRecord(List<dynamic> manifest, String family) {
  final List<Map<String, dynamic>> matches = manifest
      .whereType<Map<dynamic, dynamic>>()
      .map(
        (Map<dynamic, dynamic> value) => <String, dynamic>{
          for (final MapEntry<dynamic, dynamic> entry in value.entries)
            if (entry.key is String) entry.key! as String: entry.value,
        },
      )
      .where((Map<String, dynamic> value) => value['family'] == family)
      .toList(growable: false);
  expect(matches, hasLength(1), reason: 'FontManifest.json family $family');
  return matches.single;
}

String _singleAsset(Map<String, dynamic> font) {
  final List<dynamic> entries = font['fonts'] as List<dynamic>;
  expect(entries, hasLength(1), reason: 'one variable-font asset per family');
  final Object? asset = (entries.single as Map<dynamic, dynamic>)['asset'];
  expect(asset, isA<String>());
  return asset! as String;
}

Future<_RasterObservation> _raster(
  String family,
  String text,
  FontWeight weight, {
  List<String> fontFamilyFallback = const <String>[],
  double maxWidth = 100,
  int maxLines = 1,
  int imageHeight = 64,
  double fontSize = 48,
}) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final ui.Canvas canvas = ui.Canvas(recorder)
    ..drawColor(const ui.Color(0xffffffff), ui.BlendMode.src);
  final TextPainter painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: const Color(0xff000000),
        fontFamily: family,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        fontWeight: weight,
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
    ellipsis: maxLines > 1 ? '…' : null,
  )..layout(maxWidth: maxWidth);
  painter.paint(canvas, Offset.zero);
  final Size size = painter.size;
  final bool didExceedMaxLines = painter.didExceedMaxLines;
  final int lineCount = painter.computeLineMetrics().length;
  painter.dispose();
  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = await picture.toImage(maxWidth.ceil(), imageHeight);
  picture.dispose();
  final ByteData? raw = await image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );
  image.dispose();
  if (raw == null) throw StateError('font raster did not produce pixels');
  return _RasterObservation(
    Uint8List.fromList(
      Uint8List.view(raw.buffer, raw.offsetInBytes, raw.lengthInBytes),
    ),
    size,
    didExceedMaxLines,
    lineCount,
  );
}

class _RasterObservation {
  const _RasterObservation(
    this.pixels,
    this.size,
    this.didExceedMaxLines,
    this.lineCount,
  );

  final Uint8List pixels;
  final Size size;
  final bool didExceedMaxLines;
  final int lineCount;
}
