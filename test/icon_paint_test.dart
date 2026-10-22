import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'counter_audit_test.dart' show pixel;
import 'palette_contrast_test.dart' show host, readable;

void main() {
  test(
    'all163 public glyphs bijectively map to packaged SVGs and decode strictly',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final names = IslandGlyph.values.map((g) => g.assetName).toSet();
      expect(IslandGlyph.values.length, 163);
      expect(names.length, 163);
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final actual = manifest
          .listAssets()
          .where(
            (p) =>
                (p.startsWith('packages/animal_island_ui/assets/icons/') ||
                    p.startsWith('assets/icons/')) &&
                p.endsWith('.svg'),
          )
          .map((p) => p.split('/').last.replaceFirst('.svg', ''))
          .toSet();
      expect(actual, names);
      for (final name in names) {
        final picture = await vg.loadPicture(
          SvgAssetLoader(
            'assets/icons/$name.svg',
            packageName: 'animal_island_ui',
          ),
          null,
        );
        expect(picture.size, const Size(48, 48), reason: name);
        picture.picture.dispose();
      }
    },
  );

  testWidgets(
    'seven monochrome core raster strokes follow inherited and explicit paint',
    (t) async {
      final semantics = t.ensureSemantics();
      try {
        final positions = <IslandGlyph, Offset>{
          IslandGlyph.menu: const Offset(24, 15),
          IslandGlyph.chevronDown: const Offset(24, 30),
          IslandGlyph.chevronLeft: const Offset(18, 24),
          IslandGlyph.chevronRight: const Offset(30, 24),
          IslandGlyph.chevronUp: const Offset(24, 18),
          IslandGlyph.link: const Offset(24, 14),
          IslandGlyph.unlink: const Offset(21, 11),
        };
        for (final e in positions.entries) {
          for (final brightness in Brightness.values) {
            for (final explicit in [false, true]) {
              final boundary = GlobalKey();
              final expected = explicit
                  ? Colors.purple
                  : brightness == Brightness.dark
                  ? IslandTokens.dark.ink
                  : const Color(0xff2a2a2a);
              final bg = brightness == Brightness.dark
                  ? IslandTokens.dark.paper
                  : IslandTokens.light.paper;
              await t.pumpWidget(
                host(
                  RepaintBoundary(
                    key: boundary,
                    child: Container(
                      decoration: BoxDecoration(color: bg),
                      child: IslandIcon(
                        e.key,
                        size: 48,
                        color: explicit ? Colors.purple : null,
                        semanticLabel: 'Meaningful glyph',
                      ),
                    ),
                  ),
                  brightness: brightness,
                ),
              );
              await t.pumpAndSettle();
              final top = t.getTopLeft(find.byType(IslandIcon));
              final actual = await pixel(t, boundary, top + e.value);
              expect(
                actual.toARGB32(),
                expected.toARGB32(),
                reason: '${e.key} $brightness explicit=$explicit',
              );
              if (!explicit) readable(actual, bg, minimum: 3);
              expect(find.bySemanticsLabel('Meaningful glyph'), findsOneWidget);
            }
          }
        }
      } finally {
        semantics.dispose();
      }
    },
  );
}
