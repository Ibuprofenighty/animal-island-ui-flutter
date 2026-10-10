import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../customization_projection.dart';

void main() {
  final cases = <String, ({AnimalCarouselStyle a, AnimalCarouselStyle b})>{
    'height': (
      a: AnimalCarouselStyle(height: 260),
      b: AnimalCarouselStyle(height: 280),
    ),
    'backgroundColor': (
      a: AnimalCarouselStyle(backgroundColor: Colors.red),
      b: AnimalCarouselStyle(backgroundColor: Colors.blue),
    ),
    'borderColor': (
      a: AnimalCarouselStyle(borderColor: Colors.red),
      b: AnimalCarouselStyle(borderColor: Colors.blue),
    ),
    'borderWidth': (
      a: AnimalCarouselStyle(borderWidth: 3.1),
      b: AnimalCarouselStyle(borderWidth: 4.2),
    ),
    'borderRadius': (
      a: AnimalCarouselStyle(borderRadius: BorderRadius.circular(7)),
      b: AnimalCarouselStyle(borderRadius: BorderRadius.circular(11)),
    ),
    'dotBorderRadius': (
      a: AnimalCarouselStyle(dotBorderRadius: BorderRadius.circular(7)),
      b: AnimalCarouselStyle(dotBorderRadius: BorderRadius.circular(11)),
    ),
    'arrowColor': (
      a: AnimalCarouselStyle(arrowColor: Colors.red),
      b: AnimalCarouselStyle(arrowColor: Colors.blue),
    ),
    'arrowBackgroundColor': (
      a: AnimalCarouselStyle(arrowBackgroundColor: Colors.red),
      b: AnimalCarouselStyle(arrowBackgroundColor: Colors.blue),
    ),
    'arrowIconSize': (
      a: AnimalCarouselStyle(arrowIconSize: 23.25),
      b: AnimalCarouselStyle(arrowIconSize: 27.25),
    ),
    'controlInset': (
      a: AnimalCarouselStyle(controlInset: 23.25),
      b: AnimalCarouselStyle(controlInset: 27.25),
    ),
    'controlPadding': (
      a: AnimalCarouselStyle(controlPadding: const EdgeInsets.all(9)),
      b: AnimalCarouselStyle(controlPadding: const EdgeInsets.all(13)),
    ),
    'dotColor': (
      a: AnimalCarouselStyle(dotColor: Colors.red),
      b: AnimalCarouselStyle(dotColor: Colors.blue),
    ),
    'activeDotColor': (
      a: AnimalCarouselStyle(activeDotColor: Colors.red),
      b: AnimalCarouselStyle(activeDotColor: Colors.blue),
    ),
    'dotSize': (
      a: AnimalCarouselStyle(dotSize: 23.25),
      b: AnimalCarouselStyle(dotSize: 27.25),
    ),
    'activeDotWidth': (
      a: AnimalCarouselStyle(activeDotWidth: 23.25),
      b: AnimalCarouselStyle(activeDotWidth: 27.25),
    ),
    'dotGap': (
      a: AnimalCarouselStyle(dotGap: 23.25),
      b: AnimalCarouselStyle(dotGap: 27.25),
    ),
    'dotPadding': (
      a: AnimalCarouselStyle(dotPadding: const EdgeInsets.all(9)),
      b: AnimalCarouselStyle(dotPadding: const EdgeInsets.all(13)),
    ),
    'dotBackgroundColor': (
      a: AnimalCarouselStyle(dotBackgroundColor: Colors.red),
      b: AnimalCarouselStyle(dotBackgroundColor: Colors.blue),
    ),
    'shadow': (
      a: AnimalCarouselStyle(
        shadow: const BoxShadow(
          color: Colors.red,
          blurRadius: 13,
          offset: Offset(3, 4),
        ),
      ),
      b: AnimalCarouselStyle(
        shadow: const BoxShadow(
          color: Colors.blue,
          blurRadius: 19,
          offset: Offset(3, 4),
        ),
      ),
    ),
    'duration': (
      a: AnimalCarouselStyle(duration: const Duration(milliseconds: 350)),
      b: AnimalCarouselStyle(duration: const Duration(milliseconds: 500)),
    ),
    'dotDuration': (
      a: AnimalCarouselStyle(dotDuration: const Duration(milliseconds: 350)),
      b: AnimalCarouselStyle(dotDuration: const Duration(milliseconds: 500)),
    ),
    'curve': (
      a: AnimalCarouselStyle(curve: Curves.linear),
      b: AnimalCarouselStyle(curve: Curves.easeIn),
    ),
  };
  Widget subject(AnimalCarouselStyle? style, String field) =>
      AnimalCarousel.uncontrolled(
        style: style,
        autoPlay: false,
        items:
            field == 'backgroundColor' ||
                field == 'borderColor' ||
                field == 'borderWidth'
            ? []
            : [
                AnimalCarouselItem(id: 'a', child: const Text('A')),
                AnimalCarouselItem(id: 'b', child: const Text('B')),
              ],
      );
  testWidgets(
    'API06 carousel every visual field has efficacy and instance precedence',
    (tester) async {
      for (final entry in cases.entries) {
        final field = entry.key, a = entry.value.a, b = entry.value.b;
        final theme = AnimalIslandTheme.light.copyWith(
          components: AnimalIslandTheme.light.components.copyWith(carousel: a),
        );
        final baseline = await customizationProjection(
          tester,
          subject(null, field),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'carousel' == 'carousel' && field == 'duration',
        );
        final themed = await customizationProjection(
          tester,
          subject(null, field),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'carousel' == 'carousel' && field == 'duration',
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
          advanceCarousel: 'carousel' == 'carousel' && field == 'duration',
        );
        final precedence = await customizationProjection(
          tester,
          subject(b, field),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'carousel' == 'carousel' && field == 'duration',
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
        expect(AnimalCarouselStyle.lerp(a, b, 1.5), b);
        expect(AnimalCarouselStyle.lerp(a, b, -.5), a);
      }
    },
  );
  test('API06 carousel boundary validation rejects invalid dimensions', () {
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalCarouselStyle(height: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(
        () => AnimalCarouselStyle(borderWidth: value),
        throwsArgumentError,
      );
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(
        () => AnimalCarouselStyle(arrowIconSize: value),
        throwsArgumentError,
      );
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(
        () => AnimalCarouselStyle(controlInset: value),
        throwsArgumentError,
      );
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalCarouselStyle(dotSize: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(
        () => AnimalCarouselStyle(activeDotWidth: value),
        throwsArgumentError,
      );
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalCarouselStyle(dotGap: value), throwsArgumentError);
    }
    expect(
      () => AnimalCarouselStyle(controlPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalCarouselStyle(dotPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalCarouselStyle(duration: const Duration(milliseconds: -1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalCarouselStyle(dotDuration: const Duration(milliseconds: -1)),
      throwsArgumentError,
    );
  });
}
