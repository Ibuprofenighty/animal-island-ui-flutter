import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C19 AnimalForm renders its field with the third theme', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ValueKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalForm(
              child: AnimalFormItem<String>(
                name: 'nickname',
                label: 'Island name',
                child: const SizedBox(width: 48, height: 24),
              ),
            ),
          ),
        ),
      );

      final item = find.byType(AnimalFormItem<String>);
      final margin = tester.widget<Padding>(
        find.descendant(of: item, matching: find.byType(Padding)).first,
      );
      final label = tester.widget<Text>(find.text('Island name'));
      expect(margin.padding, EdgeInsets.only(bottom: theme.spacing.lg));
      expect(label.style?.fontSize, theme.typography.body.fontSize);
      expect(label.style?.color, theme.colors.text);
      expect(
        themeContrastRatio(label.style!.color!, theme.colors.bg),
        greaterThanOrEqualTo(4.5),
      );
    }
  });
}
