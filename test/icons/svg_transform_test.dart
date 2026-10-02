import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/src/icons/svg_transform.dart';

void main() {
  setUp(SvgTransformCache.clear);
  tearDown(SvgTransformCache.clear);

  test('SVG transform cache uses complete structural keys and bounded LRU', () {
    final SvgTransformKey first = SvgTransformKey(
      rawSvg: '<svg><circle r="3"/></svg>',
    );
    final SvgTransformKey differentSource = SvgTransformKey(
      rawSvg: '<svg><rect width="6"/></svg>',
    );
    final SvgTransformKey differentWidth = SvgTransformKey(
      rawSvg: first.rawSvg,
      strokeWidth: 3,
    );
    expect(first, isNot(equals(differentSource)));
    expect(first, isNot(equals(differentWidth)));

    final ({SvgTransformKey first, SvgTransformKey second}) collision =
        _findHashCollision();
    expect(collision.first.hashCode, equals(collision.second.hashCode));
    expect(collision.first, isNot(equals(collision.second)));
    SvgTransformCache.set(collision.first, 'first');
    SvgTransformCache.set(collision.second, 'second');
    expect(SvgTransformCache.get(collision.first), 'first');
    expect(SvgTransformCache.get(collision.second), 'second');

    SvgTransformCache.clear();
    final SvgTransformKey oldest = SvgTransformKey(rawSvg: 'oldest');
    final SvgTransformKey recentlyUsed = SvgTransformKey(rawSvg: 'recent');
    SvgTransformCache.set(oldest, 'oldest-value');
    SvgTransformCache.set(recentlyUsed, 'recent-value');
    expect(SvgTransformCache.get(oldest), 'oldest-value');
    for (int index = 0; index < SvgTransformCache.maxEntries - 2; index++) {
      SvgTransformCache.set(
        SvgTransformKey(rawSvg: 'fill-$index'),
        'fill-value-$index',
      );
    }
    expect(SvgTransformCache.length, SvgTransformCache.maxEntries);
    SvgTransformCache.set(
      SvgTransformKey(rawSvg: 'evict-one'),
      'eviction-value',
    );
    expect(SvgTransformCache.length, lessThanOrEqualTo(128));
    expect(SvgTransformCache.get(recentlyUsed), isNull);
    expect(SvgTransformCache.get(oldest), 'oldest-value');
  });

  test('Alpha quantization, quote variants, existing opacity and stroke sentinels transform consistently', () {
    const String alphaInput =
        '<svg viewBox="0 0 10 10"><path stroke="#112233"/></svg>';
    const Color alphaA = Color.from(
      alpha: 0.5002,
      red: 0.12,
      green: 0.34,
      blue: 0.56,
    );
    const Color alphaB = Color.from(
      alpha: 0.5012,
      red: 0.12,
      green: 0.34,
      blue: 0.56,
    );
    expect(alphaA.toARGB32(), alphaB.toARGB32());

    final String outputA = transformSvg(
      rawSvg: alphaInput,
      strokeColor: alphaA,
    );
    final String outputB = transformSvg(
      rawSvg: alphaInput,
      strokeColor: alphaB,
    );
    expect(outputA, contains('stroke="#1f578f"'));
    expect(
      outputA,
      contains('stroke-opacity="0.5"'),
      reason: 'Preserves canonical tint alpha in SVG output',
    );
    expect(outputB, contains('stroke-opacity="0.501"'));
    expect(outputA, isNot(outputB));

    const String quotedInput =
        "<svg viewBox='0 0 10 10'><path stroke='#111111' "
        "stroke-opacity='0.200'/><path stroke=\"#222222\" "
        'stroke-opacity="0.300"/></svg>';
    final String quotedOutput = transformSvg(
      rawSvg: quotedInput,
      strokeColor: const Color.from(
        alpha: 0.75,
        red: 0.2,
        green: 0.4,
        blue: 0.6,
      ),
    );
    expect(RegExp('stroke="#336699"').allMatches(quotedOutput).length, 2);
    expect(RegExp('stroke-opacity="0.75"').allMatches(quotedOutput).length, 2);

    const String groupedOpacityInput =
        '<svg opacity="0.6"><g opacity="0.4" stroke="currentColor" '
        'stroke-opacity="0.2"><path d="M0 0" stroke-opacity="0.3"/>'
        '<path d="M1 1"/></g><path stroke="none" '
        'stroke-opacity="0.1"/></svg>';
    final String groupedOpacityOutput = transformSvg(
      rawSvg: groupedOpacityInput,
      strokeColor: const Color.from(
        alpha: 0.75,
        red: 0.2,
        green: 0.4,
        blue: 0.6,
      ),
    );
    expect(groupedOpacityOutput, contains('<svg opacity="0.6">'));
    expect(
      groupedOpacityOutput,
      contains('<g opacity="0.4" stroke="#336699" stroke-opacity="0.75">'),
    );
    expect(
      RegExp('stroke-opacity="0.75"').allMatches(groupedOpacityOutput).length,
      3,
      reason: 'the tint replaces inherited and local stroke opacity values',
    );
    expect(
      groupedOpacityOutput,
      contains('<path stroke="none" stroke-opacity="0.1"/>'),
      reason: 'none strokes and their local opacity remain unchanged',
    );

    const String sentinels =
        '<svg><path stroke="none"/><path stroke="currentColor"/></svg>';
    final String tintedSentinels = transformSvg(
      rawSvg: sentinels,
      strokeColor: const Color(0xFF123456),
    );
    expect(tintedSentinels, contains('stroke="none"'));
    expect(tintedSentinels, contains('stroke="#123456"'));
    expect(tintedSentinels, isNot(contains('stroke="currentColor"')));

    const String widthInput =
        '<svg><path stroke="#112233" stroke-width="2"/></svg>';
    final String widthOutput = transformSvg(
      rawSvg: widthInput,
      strokeWidth: 3.5,
    );
    expect(widthOutput, contains('stroke-width="3.50"'));
    expect(
      transformSvg(rawSvg: widthInput, strokeWidth: 0),
      contains('stroke-width="0"'),
    );
    expect(
      () => transformSvg(rawSvg: widthInput, strokeWidth: double.nan),
      throwsArgumentError,
    );
  });

  test('Transformed cache cannot reuse output for different raw SVG', () {
    const String circle =
        '<svg viewBox="0 0 10 10"><circle cx="5" cy="5" r="4"/></svg>';
    const String rectangle =
        '<svg viewBox="0 0 10 10"><rect x="1" y="1" width="8" height="8"/></svg>';
    final String circleOutput = transformSvg(
      rawSvg: circle,
      strokeColor: const Color(0xFF123456),
    );
    final String rectangleOutput = transformSvg(
      rawSvg: rectangle,
      strokeColor: const Color(0xFF123456),
    );
    expect(circleOutput, contains('<circle'));
    expect(
      rectangleOutput,
      contains('<rect'),
      reason: 'Retains each complete raw SVG source',
    );
    expect(circleOutput, isNot(rectangleOutput));
  });
}

({SvgTransformKey first, SvgTransformKey second}) _findHashCollision() {
  final Map<int, SvgTransformKey> keysByHash = <int, SvgTransformKey>{};
  for (int index = 0; index < 400000; index++) {
    final SvgTransformKey key = SvgTransformKey(rawSvg: 'collision-$index');
    final SvgTransformKey? previous = keysByHash[key.hashCode];
    if (previous != null && previous != key) {
      return (first: previous, second: key);
    }
    keysByHash[key.hashCode] = key;
  }
  throw StateError('Could not find a distinct SVG key hash collision.');
}
