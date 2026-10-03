import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('input surface, typography, radius, shadow and timing are themed', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      final focusNode = FocusNode();
      final normalController = TextEditingController(text: 'value');
      final placeholderController = TextEditingController();
      final warningController = TextEditingController(text: 'warning');
      final errorController = TextEditingController(text: 'error');
      final disabledController = TextEditingController(text: 'disabled');
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  AnimalInput(
                    controller: normalController,
                    key: const ValueKey('normal'),
                    prefix: const Icon(Icons.search),
                    shadow: true,
                    focusNode: focusNode,
                  ),
                  const SizedBox(height: 8),
                  AnimalInput(
                    controller: placeholderController,
                    key: ValueKey('placeholder'),
                    placeholder: 'Input hint',
                  ),
                  const SizedBox(height: 8),
                  AnimalInput(
                    controller: warningController,
                    key: ValueKey('warning'),
                    status: AnimalInputStatus.warning,
                  ),
                  const SizedBox(height: 8),
                  AnimalInput(
                    controller: errorController,
                    key: ValueKey('error'),
                    status: AnimalInputStatus.error,
                  ),
                  const SizedBox(height: 8),
                  AnimalInput(
                    controller: disabledController,
                    key: ValueKey('disabled'),
                    disabled: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();

      AnimatedContainer inputContainer(String name) => tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byKey(ValueKey<String>(name)),
              matching: find.byType(AnimatedContainer),
            ),
          )
          .single;

      TextField inputField(String name) => tester.widget<TextField>(
        find.descendant(
          of: find.byKey(ValueKey<String>(name)),
          matching: find.byType(TextField),
        ),
      );

      BoxDecoration inputDecoration(String name) =>
          inputContainer(name).decoration! as BoxDecoration;

      final normal = inputContainer('normal');
      final normalDecoration = inputDecoration('normal');
      expect(normalDecoration.color, theme.colors.bgInput);
      expect(normalDecoration.borderRadius, theme.radii.pillBorder);
      expect(normalDecoration.boxShadow, contains(theme.shadows.input3d));
      expect(normal.duration, theme.motion.fast);
      expect(normal.curve, theme.motion.ease);
      expect(normalDecoration.border!.top.color, theme.colors.focusYellow);
      expect(
        themeContrastRatio(theme.colors.focusYellow, theme.colors.bgInput),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} focused input outline pair',
      );

      final field = inputField('normal');
      expect(field.style!.fontSize, AnimalInputSize.middle.fontSize);
      expect(field.style!.letterSpacing, theme.typography.body.letterSpacing);
      expect(field.style!.color, theme.colors.text);
      expect(field.enabled, isTrue);
      expect(
        themeContrastRatio(field.style!.color!, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} enabled input text pair',
      );
      final hintStyle = inputField('placeholder').decoration!.hintStyle!;
      expect(hintStyle.color, theme.colors.textSecondary);
      final renderedHint = tester.widget<Text>(find.text('Input hint'));
      expect(renderedHint.style!.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(renderedHint.style!.color!, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} enabled placeholder text pair',
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('normal')),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == theme.spacing.sm,
          ),
        ),
        findsOneWidget,
      );

      final warningDecoration = inputDecoration('warning');
      expect(warningDecoration.border!.top.color, theme.colors.warningText);
      expect(
        warningDecoration.boxShadow!.single.color,
        theme.colors.warningText.withValues(alpha: 0.45),
      );
      expect(
        themeContrastRatio(theme.colors.warningText, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} warning status foreground',
      );
      expect(inputField('warning').enabled, isTrue);
      expect(inputField('warning').style!.color, theme.colors.text);
      expect(
        themeContrastRatio(theme.colors.text, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
      );

      final errorDecoration = inputDecoration('error');
      expect(errorDecoration.border!.top.color, theme.colors.errorText);
      expect(
        errorDecoration.boxShadow!.single.color,
        theme.colors.errorText.withValues(alpha: 0.45),
      );
      expect(
        themeContrastRatio(theme.colors.errorText, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} error status foreground pair',
      );
      expect(inputField('error').enabled, isTrue);
      expect(inputField('error').style!.color, theme.colors.text);

      final disabledDecoration = inputDecoration('disabled');
      final disabledSurface = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceHeader
          : theme.colors.bgInputDisabled;
      expect(disabledDecoration.color, disabledSurface);
      expect(
        disabledDecoration.border!.top.color,
        theme.colors.brightness == Brightness.dark
            ? theme.colors.border.withValues(alpha: 0.3)
            : theme.colors.borderLight,
      );
      final disabledField = inputField('disabled');
      expect(disabledField.enabled, isFalse);
      expect(disabledField.style!.color, theme.colors.textDisabled);
      expect(
        themeContrastRatio(disabledField.style!.color!, disabledSurface),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled input text pair; disabled text is the only contrast-exempt state here',
      );

      await tester.pumpWidget(const SizedBox.shrink());
      focusNode.dispose();
      normalController.dispose();
      placeholderController.dispose();
      warningController.dispose();
      errorController.dispose();
      disabledController.dispose();
    }
  });
}
