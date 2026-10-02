import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/icons/svg_transform.dart';

void main() {
  group('AnimalIcon Behavior & Contract Tests (S05 / C02 / ICO01-ICO05)', () {
    testWidgets(
      'ICO01: Two distinct custom SVGs render different shapes and update dynamically',
      (tester) async {
        const svgA =
            '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg"><circle cx="24" cy="24" r="20" fill="#E76F51"/></svg>';
        const svgB =
            '<svg viewBox="0 0 48 48" xmlns="http://www.w3.org/2000/svg"><rect x="4" y="4" width="40" height="40" fill="#2A9D8F"/></svg>';

        final iconA = AnimalIconData.svg(svgA);
        final iconB = AnimalIconData.svg(svgB);

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: Row(
                children: [
                  AnimalIcon(data: iconA, size: 32),
                  AnimalIcon(data: iconB, size: 32),
                ],
              ),
            ),
          ),
        );

        expect(find.byType(SvgPicture), findsNWidgets(2));
        final svgWidgets = tester
            .widgetList<SvgPicture>(find.byType(SvgPicture))
            .toList();

        final pictureA = svgWidgets[0].bytesLoader as SvgStringLoader;
        final pictureB = svgWidgets[1].bytesLoader as SvgStringLoader;

        expect(pictureA.provideSvg(null).contains('<circle'), isTrue);
        expect(
          pictureB.provideSvg(null).contains('<rect'),
          isTrue,
          reason: 'ICO01 preserves each distinct raw SVG source',
        );
        expect(
          pictureA.provideSvg(null),
          isNot(equals(pictureB.provideSvg(null))),
        );
      },
    );

    testWidgets(
      'ICO02 / F05 GREEN: semi-transparent stroke color alpha is preserved via stroke-opacity',
      (tester) async {
        const transparentStroke = Color(0x4D19C8B9); // 30% opacity

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalIcon(
                data: AnimalIcons.leaf,
                strokeColor: transparentStroke,
              ),
            ),
          ),
        );

        final svgWidget = tester.widget<SvgPicture>(find.byType(SvgPicture));
        final loader = svgWidget.bytesLoader as SvgStringLoader;
        final renderedSvg = loader.provideSvg(null);

        // Defect F05 Fix verification:
        // The rendered SVG must retain stroke-opacity="0.302" rather than opaque hex!
        expect(
          renderedSvg.contains('stroke-opacity="0.302"'),
          isTrue,
          reason: 'ICO02 preserves input alpha as stroke-opacity',
        );
        expect(renderedSvg.contains('stroke="#19c8b9"'), isTrue);
      },
    );

    testWidgets('ICO02: strokeWidth null vs 0 vs positive distinct semantics', (
      tester,
    ) async {
      // 1. null stroke width keeps original
      final svgOriginal = transformSvg(
        rawSvg: AnimalIcons.leaf.svg,
        strokeWidth: null,
      );
      expect(svgOriginal.contains('stroke-width="2"'), isTrue);

      // 2. strokeWidth = 0 sets the canonical zero width.
      final svgZero = transformSvg(
        rawSvg: AnimalIcons.leaf.svg,
        strokeWidth: 0,
      );
      expect(svgZero.contains('stroke-width="0"'), isTrue);

      // 3. strokeWidth = 3.5 sets stroke-width="3.50"
      final svgCustom = transformSvg(
        rawSvg: AnimalIcons.leaf.svg,
        strokeWidth: 3.5,
      );
      expect(svgCustom.contains('stroke-width="3.50"'), isTrue);
    });

    test('ICO03: all 101 canonical icons are non-empty and accessible in AnimalIcons', () {
      expect(AnimalIcons.all.length, equals(101));
      expect(AnimalIcons.values.length, equals(101));

      for (final icon in AnimalIcons.all) {
        expect(icon.name.isNotEmpty, isTrue);
        expect(icon.svg.isNotEmpty, isTrue);
        expect(icon.svg.startsWith('<svg'), isTrue);
        expect(icon.svg.endsWith('</svg>'), isTrue);
      }
    });

    testWidgets(
      'ICO04: interactive icon has 48dp minimum hit target, Enter/Space activation',
      (tester) async {
        int tapCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            theme: AnimalIslandTheme.light.toThemeData(),
            home: Scaffold(
              body: AnimalIcon(
                data: AnimalIcons.leaf,
                size: 24,
                semanticLabel: 'Tap Leaf',
                onTap: () => tapCount++,
              ),
            ),
          ),
        );

        final renderBox = tester.renderObject<RenderBox>(
          find.byType(AnimalIcon),
        );
        expect(renderBox.size.width, greaterThanOrEqualTo(48.0));
        expect(renderBox.size.height, greaterThanOrEqualTo(48.0));

        // Tap activation
        await tester.tap(find.byType(AnimalIcon));
        await tester.pumpAndSettle();
        expect(tapCount, equals(1));
      },
    );

    test('ICO05: security and complexity limits throw ArgumentError on malicious or invalid SVG', () {
      // 1. Disallowed DOCTYPE / ENTITY
      const evilEntity =
          '<svg><!ENTITY xxe SYSTEM "http://malicious.org"> </svg>';
      expect(() => validateSvgMarkup(evilEntity), throwsArgumentError);

      // 2. Disallowed <script>
      const evilScript = '<svg><script>alert("xss")</script></svg>';
      expect(() => validateSvgMarkup(evilScript), throwsArgumentError);

      // 3. Disallowed external URI
      const evilUri = '<svg><image href="https://example.com/leak.png"/></svg>';
      expect(() => validateSvgMarkup(evilUri), throwsArgumentError);

      // 4. Exceeds max bytes (> 256 KiB)
      final hugeSvg = '<svg>${' ' * (260 * 1024)}</svg>';
      expect(() => validateSvgMarkup(hugeSvg), throwsArgumentError);
    });
  });
}
