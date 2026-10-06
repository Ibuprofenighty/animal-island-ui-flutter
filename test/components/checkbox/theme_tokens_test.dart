import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('checkbox selected surface, label and theme motion render', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      final focusNode = FocusNode();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ObjectKey(theme),
          theme: theme.toThemeData(),
          home: Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimalCheckbox(
                  key: const ValueKey('unchecked'),
                  value: false,
                  onChanged: (_) {},
                  label: const Text('Unchecked'),
                  focusNode: focusNode,
                ),
                AnimalCheckbox(
                  key: ValueKey('unfocused'),
                  value: false,
                  onChanged: (_) {},
                  label: const Text('Unfocused'),
                ),
                AnimalCheckbox(
                  key: ValueKey('selected'),
                  value: true,
                  onChanged: (_) {},
                  label: const Text('Selected'),
                ),
                const AnimalCheckbox(
                  key: ValueKey('disabled'),
                  value: false,
                  onChanged: null,
                  disabled: true,
                  label: Text('Disabled'),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));
      focusNode.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.pump();
      expect(focusNode.hasFocus, isTrue);

      AnimatedContainer box(String name) => tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byKey(ValueKey<String>(name)),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is AnimatedContainer &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration! as BoxDecoration).color != null,
              ),
            ),
          )
          .single;

      DefaultTextStyle labelStyle(String label) =>
          tester.widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text(label),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          );

      final selectedBox = box('selected');
      final selectedDecoration = selectedBox.decoration! as BoxDecoration;
      expect(selectedDecoration.color, theme.colors.success);
      expect(selectedDecoration.borderRadius, BorderRadius.circular(6));
      expect(selectedDecoration.boxShadow, [theme.shadows.softElevation]);
      expect(selectedBox.duration, theme.motion.fast);
      expect(selectedBox.curve, theme.motion.ease);
      final selectedIcon = tester.widget<AnimalIcon>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('selected')),
          matching: find.byType(AnimalIcon),
        ),
      );
      expect(selectedIcon.color, theme.colors.onSuccess);
      expect(
        themeContrastRatio(selectedIcon.color!, theme.colors.success),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} checked checkbox icon pair',
      );

      final selectedLabelStyle = labelStyle('Selected').style;
      expect(selectedLabelStyle.color, theme.colors.text);
      expect(selectedLabelStyle.fontSize, theme.typography.body.fontSize);
      expect(
        themeContrastRatio(selectedLabelStyle.color!, theme.colors.bg),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} enabled checkbox text pair',
      );

      final uncheckedBox = box('unchecked');
      final uncheckedDecoration = uncheckedBox.decoration! as BoxDecoration;
      final uncheckedFill = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceHeader
          : theme.colors.bgInput;
      expect(uncheckedDecoration.color, uncheckedFill);
      expect(uncheckedDecoration.border!.top.color, theme.colors.focusYellow);
      expect(
        themeContrastRatio(theme.colors.focusYellow, uncheckedFill),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} checkbox focus outline pair',
      );
      expect(uncheckedDecoration.boxShadow!.first, theme.shadows.softElevation);
      expect(labelStyle('Unchecked').style.color, theme.colors.text);
      expect(
        themeContrastRatio(theme.colors.text, theme.colors.bg),
        greaterThanOrEqualTo(4.5),
      );

      final unfocusedDecoration = box('unfocused').decoration! as BoxDecoration;
      expect(unfocusedDecoration.border!.top.color, theme.colors.border);

      final disabledBox = box('disabled');
      final disabledDecoration = disabledBox.decoration! as BoxDecoration;
      final disabledFill = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceAlt
          : theme.colors.bgDisabled;
      expect(disabledDecoration.color, disabledFill);
      expect(
        disabledDecoration.border!.top.color,
        theme.colors.brightness == Brightness.dark
            ? theme.colors.border.withValues(alpha: 0.3)
            : theme.colors.borderLight,
      );
      expect(disabledDecoration.boxShadow, isEmpty);
      final disabledSemantics = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('disabled')),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((semantics) => semantics.properties.enabled == false);
      expect(disabledSemantics.properties.enabled, isFalse);
      expect(labelStyle('Disabled').style.color, theme.colors.textDisabled);
      expect(
        themeContrastRatio(theme.colors.textDisabled, theme.colors.bg),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled checkbox label pair; exemption applies only to this disabled label',
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('unchecked')),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == theme.spacing.sm,
          ),
        ),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      focusNode.dispose();
    }
  });
}
