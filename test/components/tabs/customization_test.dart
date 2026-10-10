import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../customization_projection.dart';

void main() {
  final cases = <String, ({AnimalTabsStyle a, AnimalTabsStyle b})>{
    'backgroundColor': (
      a: AnimalTabsStyle(backgroundColor: Colors.red),
      b: AnimalTabsStyle(backgroundColor: Colors.blue),
    ),
    'borderColor': (
      a: AnimalTabsStyle(borderColor: Colors.red),
      b: AnimalTabsStyle(borderColor: Colors.blue),
    ),
    'borderWidth': (
      a: AnimalTabsStyle(borderWidth: 3.1),
      b: AnimalTabsStyle(borderWidth: 4.2),
    ),
    'borderRadius': (
      a: AnimalTabsStyle(borderRadius: BorderRadius.circular(7)),
      b: AnimalTabsStyle(borderRadius: BorderRadius.circular(11)),
    ),
    'padding': (
      a: AnimalTabsStyle(padding: const EdgeInsets.all(9)),
      b: AnimalTabsStyle(padding: const EdgeInsets.all(13)),
    ),
    'tabPadding': (
      a: AnimalTabsStyle(tabPadding: const EdgeInsets.all(9)),
      b: AnimalTabsStyle(tabPadding: const EdgeInsets.all(13)),
    ),
    'iconGap': (
      a: AnimalTabsStyle(iconGap: 23.25),
      b: AnimalTabsStyle(iconGap: 27.25),
    ),
    'iconSize': (
      a: AnimalTabsStyle(iconSize: 23.25),
      b: AnimalTabsStyle(iconSize: 27.25),
    ),
    'textStyle': (
      a: AnimalTabsStyle(
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      ),
      b: AnimalTabsStyle(
        textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
      ),
    ),
    'textColor': (
      a: AnimalTabsStyle(
        textColor: const WidgetStatePropertyAll<Color?>(Colors.red),
      ),
      b: AnimalTabsStyle(
        textColor: const WidgetStatePropertyAll<Color?>(Colors.blue),
      ),
    ),
    'indicatorColor': (
      a: AnimalTabsStyle(indicatorColor: Colors.red),
      b: AnimalTabsStyle(indicatorColor: Colors.blue),
    ),
    'shadow': (
      a: AnimalTabsStyle(
        shadow: const BoxShadow(
          color: Colors.red,
          blurRadius: 13,
          offset: Offset(3, 4),
        ),
      ),
      b: AnimalTabsStyle(
        shadow: const BoxShadow(
          color: Colors.blue,
          blurRadius: 19,
          offset: Offset(3, 4),
        ),
      ),
    ),
    'duration': (
      a: AnimalTabsStyle(duration: const Duration(milliseconds: 350)),
      b: AnimalTabsStyle(duration: const Duration(milliseconds: 500)),
    ),
    'curve': (
      a: AnimalTabsStyle(curve: Curves.linear),
      b: AnimalTabsStyle(curve: Curves.easeIn),
    ),
  };
  Widget subject(AnimalTabsStyle? style) => AnimalTabs(
    style: style,
    selectedId: 'a',
    onChanged: (_) {},
    tabs: [
      AnimalTabItem(id: 'a', label: 'First', icon: const Icon(Icons.home)),
      AnimalTabItem(id: 'b', label: 'Second'),
    ],
  );
  testWidgets(
    'API06 tabs every visual field has efficacy and instance precedence',
    (tester) async {
      for (final entry in cases.entries) {
        final field = entry.key, a = entry.value.a, b = entry.value.b;
        final theme = AnimalIslandTheme.light.copyWith(
          components: AnimalIslandTheme.light.components.copyWith(tabs: a),
        );
        final baseline = await customizationProjection(
          tester,
          subject(null),
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'tabs' == 'carousel' && field == 'duration',
        );
        final themed = await customizationProjection(
          tester,
          subject(null),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'tabs' == 'carousel' && field == 'duration',
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
          advanceCarousel: 'tabs' == 'carousel' && field == 'duration',
        );
        final precedence = await customizationProjection(
          tester,
          subject(b),
          theme: theme,
          press: field == 'depth',
          width: field == 'flexMinWidth' ? 320 : 800,
          advanceCarousel: 'tabs' == 'carousel' && field == 'duration',
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
        expect(AnimalTabsStyle.lerp(a, b, 1.5), b);
        expect(AnimalTabsStyle.lerp(a, b, -.5), a);
      }
    },
  );
  test('API06 tabs boundary validation rejects invalid dimensions', () {
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTabsStyle(borderWidth: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTabsStyle(iconGap: value), throwsArgumentError);
    }
    for (final value in [double.nan, double.infinity, -1.0]) {
      expect(() => AnimalTabsStyle(iconSize: value), throwsArgumentError);
    }
    expect(
      () => AnimalTabsStyle(padding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalTabsStyle(tabPadding: const EdgeInsets.all(-1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalTabsStyle(duration: const Duration(milliseconds: -1)),
      throwsArgumentError,
    );
    expect(
      () => AnimalTabsStyle(textStyle: const TextStyle(fontSize: 0)),
      throwsArgumentError,
    );
  });
}
