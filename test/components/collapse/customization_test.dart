import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../customization_projection.dart';

void main() {
  final cases = <String, ({AnimalCollapseStyle a, AnimalCollapseStyle b})>{
    'backgroundColor': (
      a: AnimalCollapseStyle(backgroundColor: Colors.red),
      b: AnimalCollapseStyle(backgroundColor: Colors.blue),
    ),
    'borderColor': (
      a: AnimalCollapseStyle(borderColor: Colors.red),
      b: AnimalCollapseStyle(borderColor: Colors.blue),
    ),
    'borderWidth': (
      a: AnimalCollapseStyle(borderWidth: 3.1),
      b: AnimalCollapseStyle(borderWidth: 4.2),
    ),
    'borderRadius': (
      a: AnimalCollapseStyle(borderRadius: BorderRadius.circular(7)),
      b: AnimalCollapseStyle(borderRadius: BorderRadius.circular(11)),
    ),
    'shadow': (
      a: AnimalCollapseStyle(
        shadow: const BoxShadow(
          color: Colors.red,
          blurRadius: 13,
          offset: Offset(3, 4),
        ),
      ),
      b: AnimalCollapseStyle(
        shadow: const BoxShadow(
          color: Colors.blue,
          blurRadius: 19,
          offset: Offset(3, 4),
        ),
      ),
    ),
    'headerPadding': (
      a: AnimalCollapseStyle(headerPadding: const EdgeInsets.all(9)),
      b: AnimalCollapseStyle(headerPadding: const EdgeInsets.all(13)),
    ),
    'contentPadding': (
      a: AnimalCollapseStyle(contentPadding: const EdgeInsets.all(9)),
      b: AnimalCollapseStyle(contentPadding: const EdgeInsets.all(13)),
    ),
    'gap': (
      a: AnimalCollapseStyle(gap: 23.25),
      b: AnimalCollapseStyle(gap: 27.25),
    ),
    'iconGap': (
      a: AnimalCollapseStyle(iconGap: 23.25),
      b: AnimalCollapseStyle(iconGap: 27.25),
    ),
    'iconSize': (
      a: AnimalCollapseStyle(iconSize: 23.25),
      b: AnimalCollapseStyle(iconSize: 27.25),
    ),
    'iconColor': (
      a: AnimalCollapseStyle(iconColor: Colors.red),
      b: AnimalCollapseStyle(iconColor: Colors.blue),
    ),
    'headerBackgroundColor': (
      a: AnimalCollapseStyle(
        headerBackgroundColor: const WidgetStatePropertyAll<Color?>(Colors.red),
      ),
      b: AnimalCollapseStyle(
        headerBackgroundColor: const WidgetStatePropertyAll<Color?>(
          Colors.blue,
        ),
      ),
    ),
    'textStyle': (
      a: AnimalCollapseStyle(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      b: AnimalCollapseStyle(
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    ),
    'textColor': (
      a: AnimalCollapseStyle(
        textColor: const WidgetStatePropertyAll<Color?>(Colors.red),
      ),
      b: AnimalCollapseStyle(
        textColor: const WidgetStatePropertyAll<Color?>(Colors.blue),
      ),
    ),
    'contentBackgroundColor': (
      a: AnimalCollapseStyle(contentBackgroundColor: Colors.red),
      b: AnimalCollapseStyle(contentBackgroundColor: Colors.blue),
    ),
    'contentTextColor': (
      a: AnimalCollapseStyle(contentTextColor: Colors.red),
      b: AnimalCollapseStyle(contentTextColor: Colors.blue),
    ),
    'duration': (
      a: AnimalCollapseStyle(duration: const Duration(milliseconds: 350)),
      b: AnimalCollapseStyle(duration: const Duration(milliseconds: 500)),
    ),
    'curve': (
      a: AnimalCollapseStyle(curve: Curves.linear),
      b: AnimalCollapseStyle(curve: Curves.easeIn),
    ),
  };
  Widget subject(AnimalCollapseStyle? style) => AnimalCollapse(
    style: style,
    defaultActiveIds: {'a', 'b'},
    items: [
      AnimalCollapseItem(
        id: 'a',
        title: const Text('Title A'),
        content: const Text('Body A'),
      ),
      AnimalCollapseItem(
        id: 'b',
        title: const Text('Title B'),
        content: const Text('Body B'),
      ),
    ],
  );
  testWidgets(
    'API06 collapse every visual field has efficacy and instance precedence',
    (tester) async {
      for (final entry in cases.entries) {
        final field = entry.key, a = entry.value.a, b = entry.value.b;
        final theme = AnimalIslandTheme.light.copyWith(
          components: AnimalIslandTheme.light.components.copyWith(collapse: a),
        );
        final baseline = await customizationProjection(
          tester,
          subject(null),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'collapse' == 'carousel' && field == 'duration',
        );
        final themed = await customizationProjection(
          tester,
          subject(null),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'collapse' == 'carousel' && field == 'duration',
        );
        expect(
          themed,
          isNot(equals(baseline)),
          reason: '$field must reach rendering',
        );
        final instance = await customizationProjection(
          tester,
          subject(b),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'collapse' == 'carousel' && field == 'duration',
        );
        final precedence = await customizationProjection(
          tester,
          subject(b),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'collapse' == 'carousel' && field == 'duration',
        );
        expect(
          precedence,
          equals(instance),
          reason: 'instance $field must win over component theme',
        );
        expect(
          instance,
          isNot(equals(themed)),
          reason: '$field instance override must reach rendering',
        );
        expect(a.copyWith(), a);
        expect(b.merge(a), b);
        expect(AnimalCollapseStyle.lerp(a, b, 1.5), b);
        expect(AnimalCollapseStyle.lerp(a, b, -.5), a);
      }
    },
  );
  test('API06 collapse boundary validation rejects invalid dimensions', () {
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(
        () => AnimalCollapseStyle(borderWidth: value),
        throwsArgumentError,
      );
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalCollapseStyle(gap: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalCollapseStyle(iconGap: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalCollapseStyle(iconSize: value), throwsArgumentError);
    }
    expect(
      () => AnimalCollapseStyle(headerPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalCollapseStyle(contentPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalCollapseStyle(duration: const Duration(milliseconds: -1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalCollapseStyle(textStyle: const TextStyle(fontSize: 0)),
      throwsArgumentError,
    );
  });
}
