import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../customization_projection.dart';

void main() {
  final cases = <String, ({AnimalTableStyle a, AnimalTableStyle b})>{
    'backgroundColor': (
      a: AnimalTableStyle(backgroundColor: Colors.red),
      b: AnimalTableStyle(backgroundColor: Colors.blue),
    ),
    'headerBackgroundColor': (
      a: AnimalTableStyle(headerBackgroundColor: Colors.red),
      b: AnimalTableStyle(headerBackgroundColor: Colors.blue),
    ),
    'evenRowBackgroundColor': (
      a: AnimalTableStyle(evenRowBackgroundColor: Colors.red),
      b: AnimalTableStyle(evenRowBackgroundColor: Colors.blue),
    ),
    'oddRowBackgroundColor': (
      a: AnimalTableStyle(oddRowBackgroundColor: Colors.red),
      b: AnimalTableStyle(oddRowBackgroundColor: Colors.blue),
    ),
    'borderColor': (
      a: AnimalTableStyle(borderColor: Colors.red),
      b: AnimalTableStyle(borderColor: Colors.blue),
    ),
    'borderWidth': (
      a: AnimalTableStyle(borderWidth: 3.1),
      b: AnimalTableStyle(borderWidth: 4.2),
    ),
    'borderRadius': (
      a: AnimalTableStyle(borderRadius: BorderRadius.circular(7)),
      b: AnimalTableStyle(borderRadius: BorderRadius.circular(11)),
    ),
    'dividerColor': (
      a: AnimalTableStyle(dividerColor: Colors.red),
      b: AnimalTableStyle(dividerColor: Colors.blue),
    ),
    'dividerThickness': (
      a: AnimalTableStyle(dividerThickness: 3.1),
      b: AnimalTableStyle(dividerThickness: 4.2),
    ),
    'rowPadding': (
      a: AnimalTableStyle(rowPadding: const EdgeInsets.all(9)),
      b: AnimalTableStyle(rowPadding: const EdgeInsets.all(13)),
    ),
    'minRowHeight': (
      a: AnimalTableStyle(minRowHeight: 90),
      b: AnimalTableStyle(minRowHeight: 110),
    ),
    'flexMinWidth': (
      a: AnimalTableStyle(flexMinWidth: 210),
      b: AnimalTableStyle(flexMinWidth: 250),
    ),
    'headerTextStyle': (
      a: AnimalTableStyle(
        headerTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      b: AnimalTableStyle(
        headerTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    'textStyle': (
      a: AnimalTableStyle(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      b: AnimalTableStyle(
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    ),
    'headerTextColor': (
      a: AnimalTableStyle(headerTextColor: Colors.red),
      b: AnimalTableStyle(headerTextColor: Colors.blue),
    ),
    'textColor': (
      a: AnimalTableStyle(textColor: Colors.red),
      b: AnimalTableStyle(textColor: Colors.blue),
    ),
    'emptyTextStyle': (
      a: AnimalTableStyle(
        emptyTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      b: AnimalTableStyle(
        emptyTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    'emptyTextColor': (
      a: AnimalTableStyle(emptyTextColor: Colors.red),
      b: AnimalTableStyle(emptyTextColor: Colors.blue),
    ),
    'emptyPadding': (
      a: AnimalTableStyle(emptyPadding: const EdgeInsets.all(9)),
      b: AnimalTableStyle(emptyPadding: const EdgeInsets.all(13)),
    ),
    'emptyIconSize': (
      a: AnimalTableStyle(emptyIconSize: 23.25),
      b: AnimalTableStyle(emptyIconSize: 27.25),
    ),
    'emptyIconGap': (
      a: AnimalTableStyle(emptyIconGap: 23.25),
      b: AnimalTableStyle(emptyIconGap: 27.25),
    ),
    'loadingSize': (
      a: AnimalTableStyle(loadingSize: 23.25),
      b: AnimalTableStyle(loadingSize: 27.25),
    ),
  };
  Widget subject(AnimalTableStyle? style, String field) => TickerMode(
    enabled: field != 'loadingSize',
    child: AnimalTable(
      style: style,
      columns: [
        AnimalTableColumn(title: 'Header A'),
        AnimalTableColumn(title: 'Header B'),
      ],
      rowCount: field.startsWith('empty') ? 0 : 3,
      loading: field == 'loadingSize',
      rowKey: (i) => ValueKey(i),
      rowBuilder: (context, i) => [Text('A $i'), Text('B $i')],
    ),
  );
  testWidgets(
    'API06 table every visual field has efficacy and instance precedence',
    (tester) async {
      for (final entry in cases.entries) {
        final field = entry.key, a = entry.value.a, b = entry.value.b;
        final theme = AnimalIslandTheme.light.copyWith(
          components: AnimalIslandTheme.light.components.copyWith(table: a),
        );
        final baseline = await customizationProjection(
          tester,
          subject(null, field),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'table' == 'carousel' && field == 'duration',
        );
        final themed = await customizationProjection(
          tester,
          subject(null, field),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'table' == 'carousel' && field == 'duration',
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
          advanceCarousel: 'table' == 'carousel' && field == 'duration',
        );
        final precedence = await customizationProjection(
          tester,
          subject(b, field),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'table' == 'carousel' && field == 'duration',
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
        expect(AnimalTableStyle.lerp(a, b, 1.5), b);
        expect(AnimalTableStyle.lerp(a, b, -.5), a);
      }
    },
  );
  test('API06 table boundary validation rejects invalid dimensions', () {
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTableStyle(borderWidth: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(
        () => AnimalTableStyle(dividerThickness: value),
        throwsArgumentError,
      );
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTableStyle(minRowHeight: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTableStyle(flexMinWidth: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTableStyle(emptyIconSize: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTableStyle(emptyIconGap: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTableStyle(loadingSize: value), throwsArgumentError);
    }
    expect(
      () => AnimalTableStyle(rowPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalTableStyle(emptyPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );

    expect(
      () => AnimalTableStyle(headerTextStyle: const TextStyle(fontSize: 0)),
      throwsArgumentError,
    );
    expect(
      () => AnimalTableStyle(textStyle: const TextStyle(fontSize: 0)),
      throwsArgumentError,
    );
    expect(
      () => AnimalTableStyle(emptyTextStyle: const TextStyle(fontSize: 0)),
      throwsArgumentError,
    );
  });
}
