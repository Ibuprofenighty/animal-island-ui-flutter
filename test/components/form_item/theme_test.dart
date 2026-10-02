import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C20 AnimalFormItem renders themed margin, label and validation feedback',
    (tester) async {
      final emailKey = AnimalFieldKey<String>(debugLabel: 'email');
      for (final theme in animalIslandThemeVariants()) {
        final controller = AnimalFormController();
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: AnimalForm(
                controller: controller,
                child: AnimalFormItem<String>(
                  fieldKey: emailKey,
                  label: 'Email address',
                  help: 'Use an island email format',
                  required: true,
                  rules: [AnimalRule.required(message: 'Email is required')],
                  builder: (context, binding) =>
                      const SizedBox(width: 60, height: 24),
                ),
              ),
            ),
          ),
        );

        final item = find.byType(AnimalFormItem<String>);
        final margin = tester.widget<Padding>(
          find.descendant(of: item, matching: find.byType(Padding)).first,
        );
        final label = tester.widget<Text>(find.text('Email address'));
        expect(margin.padding, EdgeInsets.only(bottom: theme.spacing.lg));
        expect(label.style?.fontSize, theme.typography.body.fontSize);
        expect(label.style?.color, theme.colors.text);
        expect(
          themeContrastRatio(label.style!.color!, theme.colors.bg),
          greaterThanOrEqualTo(4.5),
        );
        final required = tester.widget<Text>(find.text('* '));
        expect(required.style?.color, theme.colors.errorText);
        expect(
          themeContrastRatio(required.style!.color!, theme.colors.bg),
          greaterThanOrEqualTo(4.5),
        );

        final help = tester.widget<Text>(
          find.text('Use an island email format'),
        );
        expect(help.style?.color, theme.colors.textSecondary);
        expect(
          themeContrastRatio(help.style!.color!, theme.colors.bg),
          greaterThanOrEqualTo(4.5),
        );

        expect(await controller.validate(), isFalse);
        await tester.pumpAndSettle();

        final error = tester.widget<Text>(find.text('Email is required'));
        final feedback = tester.widget<AnimatedSwitcher>(
          find.descendant(of: item, matching: find.byType(AnimatedSwitcher)),
        );
        expect(error.style?.color, theme.colors.errorText);
        expect(
          themeContrastRatio(error.style!.color!, theme.colors.bg),
          greaterThanOrEqualTo(4.5),
        );
        expect(feedback.duration, theme.motion.fast * (200 / 150));
      }
    },
  );
}
