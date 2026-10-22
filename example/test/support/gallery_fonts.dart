import 'dart:convert';

import 'package:flutter/services.dart';

Future<void>? _loaded;

/// Test hosts load exactly the fonts generated from the app/package pubspecs.
/// This fixture owns no parallel family/weight/asset recipe.
Future<void> loadGalleryFonts() => _loaded ??= _load();

Future<void> _load() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font in (entry['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}
