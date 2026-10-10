import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../customization_projection.dart';

void main() {
  final cases = <String, ({AnimalPaginationStyle a, AnimalPaginationStyle b})>{
    'backgroundColor': (
      a: AnimalPaginationStyle(backgroundColor: Colors.red),
      b: AnimalPaginationStyle(backgroundColor: Colors.blue),
    ),
    'selectedBackgroundColor': (
      a: AnimalPaginationStyle(selectedBackgroundColor: Colors.red),
      b: AnimalPaginationStyle(selectedBackgroundColor: Colors.blue),
    ),
    'disabledBackgroundColor': (
      a: AnimalPaginationStyle(disabledBackgroundColor: Colors.red),
      b: AnimalPaginationStyle(disabledBackgroundColor: Colors.blue),
    ),
    'borderRadius': (
      a: AnimalPaginationStyle(borderRadius: BorderRadius.circular(7)),
      b: AnimalPaginationStyle(borderRadius: BorderRadius.circular(11)),
    ),
    'padding': (
      a: AnimalPaginationStyle(padding: const EdgeInsets.all(9)),
      b: AnimalPaginationStyle(padding: const EdgeInsets.all(13)),
    ),
    'gap': (
      a: AnimalPaginationStyle(gap: 23.25),
      b: AnimalPaginationStyle(gap: 27.25),
    ),
    'textStyle': (
      a: AnimalPaginationStyle(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      b: AnimalPaginationStyle(
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    ),
    'ellipsisTextStyle': (
      a: AnimalPaginationStyle(
        ellipsisTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      b: AnimalPaginationStyle(
        ellipsisTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    'textColor': (
      a: AnimalPaginationStyle(textColor: Colors.red),
      b: AnimalPaginationStyle(textColor: Colors.blue),
    ),
    'ellipsisTextColor': (
      a: AnimalPaginationStyle(ellipsisTextColor: Colors.red),
      b: AnimalPaginationStyle(ellipsisTextColor: Colors.blue),
    ),
    'selectedTextColor': (
      a: AnimalPaginationStyle(selectedTextColor: Colors.red),
      b: AnimalPaginationStyle(selectedTextColor: Colors.blue),
    ),
    'disabledTextColor': (
      a: AnimalPaginationStyle(disabledTextColor: Colors.red),
      b: AnimalPaginationStyle(disabledTextColor: Colors.blue),
    ),
    'iconSize': (
      a: AnimalPaginationStyle(iconSize: 23.25),
      b: AnimalPaginationStyle(iconSize: 27.25),
    ),
    'shadow': (
      a: AnimalPaginationStyle(
        shadow: const BoxShadow(
          color: Colors.red,
          blurRadius: 13,
          offset: Offset(3, 4),
        ),
      ),
      b: AnimalPaginationStyle(
        shadow: const BoxShadow(
          color: Colors.blue,
          blurRadius: 19,
          offset: Offset(3, 4),
        ),
      ),
    ),
    'depth': (
      a: AnimalPaginationStyle(depth: 23.25),
      b: AnimalPaginationStyle(depth: 27.25),
    ),
  };
  Widget subject(AnimalPaginationStyle? style, String field) =>
      AnimalPagination(
        style: style,
        current: 5,
        total: 200,
        disabled: field.startsWith('disabled'),
        onChanged: (_) {},
      );
  testWidgets(
    'API06 pagination every visual field has efficacy and instance precedence',
    (tester) async {
      for (final entry in cases.entries) {
        final field = entry.key, a = entry.value.a, b = entry.value.b;
        final theme = AnimalIslandTheme.light.copyWith(
          components: AnimalIslandTheme.light.components.copyWith(
            pagination: a,
          ),
        );
        final baseline = await customizationProjection(
          tester,
          subject(null, field),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'pagination' == 'carousel' && field == 'duration',
        );
        final themed = await customizationProjection(
          tester,
          subject(null, field),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'pagination' == 'carousel' && field == 'duration',
        );
        expect(
          themed,
          isNot(equals(baseline)),
          reason: '$field must reach rendering',
        );
        final instance = await customizationProjection(
          tester,
          subject(b, field),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'pagination' == 'carousel' && field == 'duration',
        );
        final precedence = await customizationProjection(
          tester,
          subject(b, field),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'pagination' == 'carousel' && field == 'duration',
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
        expect(AnimalPaginationStyle.lerp(a, b, 1.5), b);
        expect(AnimalPaginationStyle.lerp(a, b, -.5), a);
      }
    },
  );
  test('API06 pagination boundary validation rejects invalid dimensions', () {
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalPaginationStyle(gap: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalPaginationStyle(iconSize: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalPaginationStyle(depth: value), throwsArgumentError);
    }
    expect(
      () => AnimalPaginationStyle(padding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );

    expect(
      () => AnimalPaginationStyle(textStyle: const TextStyle(fontSize: 0)),
      throwsArgumentError,
    );
    expect(
      () => AnimalPaginationStyle(
        ellipsisTextStyle: const TextStyle(fontSize: 0),
      ),
      throwsArgumentError,
    );
  });
}
