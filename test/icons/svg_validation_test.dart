import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/src/icons/icon_data.dart';
import 'package:animal_island_ui/src/icons/icons.g.dart';
import 'package:animal_island_ui/src/icons/svg_transform.dart';

import '../../tool/src/icons_generation.dart';

void main() {
  test('SVG parser accepts all canonical sources and 64 sibling paths', () {
    expect(AnimalIcons.all, hasLength(101));
    for (final AnimalIconData icon in AnimalIcons.all) {
      expect(
        () => validateSvgMarkup(icon.svg),
        returnsNormally,
        reason: icon.name,
      );
    }

    final String siblingPaths =
        '<svg viewBox="0 0 64 1">${'<path d="M0 0"/>' * 64}</svg>';
    expect(() => validateSvgMarkup(siblingPaths), returnsNormally);
    expect(
      () => validateSvgMarkup('<?xml version="1.0" encoding="UTF-8"?><svg/>'),
      returnsNormally,
    );

    final String references =
        '<svg xmlns="http://www.w3.org/2000/svg">'
        '<defs><path id="marker" d="M0 0"/></defs>'
        '<use href="#marker"/></svg>';
    expect(() => validateSvgMarkup(references), returnsNormally);
    expect(
      () => validateSvgMarkup('<svg transform="translate(1, 2) rotate(45)"/>'),
      returnsNormally,
    );
    const String xlinkReference =
        '<svg xmlns:xlink="http://www.w3.org/1999/xlink">'
        '<path id="marker" d="M0 0"/><use xlink:href="#marker"/></svg>';
    expect(() => validateSvgMarkup(xlinkReference), returnsNormally);
  });

  test('SVG parser enforces byte, element, and tree-depth limits', () {
    final String maxBytes = '<svg>${' ' * (maxSvgBytes - 11)}</svg>';
    expect(maxBytes.length, maxSvgBytes);
    expect(() => validateSvgMarkup(maxBytes), returnsNormally);
    final String utf8MaxBytes =
        '<svg><!--${'é' * ((maxSvgBytes - 18) ~/ 2)}--></svg>';
    expect(utf8MaxBytes.length, lessThan(maxSvgBytes));
    expect(utf8.encode(utf8MaxBytes), hasLength(maxSvgBytes));
    expect(() => validateSvgMarkup(utf8MaxBytes), returnsNormally);
    expect(
      () => validateSvgMarkup('<svg>${' ' * (maxSvgBytes - 10)}</svg>'),
      throwsArgumentError,
    );
    expect(
      () => validateSvgMarkup(
        '<svg><!--${'é' * ((maxSvgBytes - 18) ~/ 2 + 1)}--></svg>',
      ),
      throwsArgumentError,
    );
    final String oversizedSvg = '<svg>${' ' * (maxSvgBytes - 10)}</svg>';
    SvgTransformCache.set(
      SvgTransformKey(rawSvg: oversizedSvg),
      'must-not-bypass-validation',
    );
    expect(
      () => transformSvg(rawSvg: oversizedSvg),
      throwsArgumentError,
      reason: 'the UTF-8 bound is checked before a cache lookup',
    );
    SvgTransformCache.clear();

    final String maxElements = '<svg>${'<path/>' * (maxSvgElements - 1)}</svg>';
    expect(() => validateSvgMarkup(maxElements), returnsNormally);
    expect(
      () => validateSvgMarkup('<svg>${'<path/>' * maxSvgElements}</svg>'),
      throwsArgumentError,
    );

    final String depth64 =
        '${'<g>' * (maxSvgDepth - 1)}'
        '${'</g>' * (maxSvgDepth - 1)}';
    expect(() => validateSvgMarkup('<svg>$depth64</svg>'), returnsNormally);
    final String depth65 =
        '${'<g>' * maxSvgDepth}'
        '${'</g>' * maxSvgDepth}';
    expect(() => validateSvgMarkup('<svg>$depth65</svg>'), throwsArgumentError);
  });

  test('SVG parser rejects malformed XML, declarations, links, and unsafe vocabulary', () {
    const List<String> rejected = <String>[
      '',
      '<circle cx="1" cy="1" r="1"/>',
      '<svg><path></svg>',
      '<svg><path>',
      '<svg/><svg/>',
      '<svg viewBox=0/>',
      '<svg viewBox="0 0 1 1" viewBox="0 0 2 2"/>',
      '<svg viewBox="0 0 1 1"fill="none"/>',
      '<svg>&unknown;</svg>',
      '<!DOCTYPE svg [<!ENTITY xxe SYSTEM "file:///secret">]><svg/>',
      '<svg><script>alert(1)</script></svg>',
      '<svg><foreignObject/></svg>',
      '<svg onload="alert(1)"/>',
      '<svg style="fill:url(https://example.com/a.svg#x)"/>',
      '<svg><image href="https://example.com/a.png"/></svg>',
      '<svg><use href="https://example.com/a.svg#x"/></svg>',
      '<svg><use href="data:image/svg+xml;base64,AAAA"/></svg>',
      '<svg><use href="#missing"/></svg>',
      '<svg><defs><use id="cycle" href="#cycle"/></defs></svg>',
      '<svg xmlns:xlink="https://example.com"><use xlink:href="#mark"/></svg>',
      '<svg>visible text</svg>',
      '<?xml version="1.0"?><svg><?evil run="now"?></svg>',
    ];

    for (final String input in rejected) {
      expect(
        () => validateSvgMarkup(input),
        throwsArgumentError,
        reason: input,
      );
    }
    expect(() => transformSvg(rawSvg: ''), throwsArgumentError);
  });

  test('Deterministic generation matches the complete descriptor file', () {
    final String generated = generateIconsSource(
      repositoryRoot: Directory.current,
    );
    final String checkedIn = File('lib/src/icons/icons.g.dart')
        .readAsStringSync();
    expect(generated, checkedIn);
  });
}
