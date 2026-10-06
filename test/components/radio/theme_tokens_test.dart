import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('radio selection pairs primary surface with onPrimary glyph', (
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
                AnimalRadio<String>(
                  key: const ValueKey('unselected'),
                  value: 'a',
                  groupValue: 'selected',
                  onChanged: (_) {},
                  label: const Text('Unselected'),
                  focusNode: focusNode,
                ),
                AnimalRadio<String>(
                  key: ValueKey('plain'),
                  value: 'b',
                  groupValue: 'selected',
                  onChanged: (_) {},
                  label: const Text('Plain'),
                ),
                AnimalRadio<String>(
                  key: const ValueKey('selected'),
                  value: 'selected',
                  groupValue: 'selected',
                  onChanged: (_) {},
                  label: const Text('Selected'),
                ),
                const AnimalRadio<String>(
                  key: ValueKey('disabled'),
                  value: 'disabled',
                  groupValue: 'selected',
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

      Finder boxFinder(String name) => find.descendant(
        of: find.byKey(ValueKey<String>(name)),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedContainer &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).borderRadius ==
                  BorderRadius.circular(14),
        ),
      );

      final selectedBoxFinder = boxFinder('selected');
      expect(selectedBoxFinder, findsOneWidget);
      final selectedBox = tester.widget<AnimatedContainer>(selectedBoxFinder);
      expect(tester.getSize(selectedBoxFinder), const Size(22, 22));
      final selectedDecoration = selectedBox.decoration! as BoxDecoration;
      expect(selectedDecoration.color, theme.colors.primary);
      expect(selectedDecoration.borderRadius, BorderRadius.circular(14));
      expect(selectedDecoration.boxShadow, [theme.shadows.softElevation]);
      expect(selectedBox.duration, theme.motion.fast);
      expect(selectedBox.curve, theme.motion.ease);
      final selectedIcon = tester.widget<AnimalIcon>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('selected')),
          matching: find.byType(AnimalIcon),
        ),
      );
      expect(selectedIcon.color, theme.colors.onPrimary);
      expect(
        themeContrastRatio(selectedIcon.color!, theme.colors.primary),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} radio glyph pair',
      );

      final selectedLabel = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('Selected'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(selectedLabel.fontSize, theme.typography.body.fontSize);
      expect(selectedLabel.color, theme.colors.text);
      expect(
        themeContrastRatio(selectedLabel.color!, theme.colors.bg),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} enabled radio label pair',
      );

      final unselectedFill = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceHeader
          : theme.colors.bgInput;
      final unselectedFinder = boxFinder('unselected');
      expect(unselectedFinder, findsOneWidget);
      final unselectedDecoration =
          tester.widget<AnimatedContainer>(unselectedFinder).decoration!
              as BoxDecoration;
      expect(unselectedDecoration.color, unselectedFill);
      expect(unselectedDecoration.border!.top.color, theme.colors.focusYellow);
      expect(
        themeContrastRatio(theme.colors.focusYellow, unselectedFill),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} radio focus outline pair',
      );
      final plainFinder = boxFinder('plain');
      expect(plainFinder, findsOneWidget);
      final plainDecoration =
          tester.widget<AnimatedContainer>(plainFinder).decoration!
              as BoxDecoration;
      expect(plainDecoration.border!.top.color, theme.colors.border);

      final disabledFill = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceAlt
          : theme.colors.bgDisabled;
      final disabledFinder = boxFinder('disabled');
      expect(disabledFinder, findsOneWidget);
      final disabledDecoration =
          tester.widget<AnimatedContainer>(disabledFinder).decoration!
              as BoxDecoration;
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
      final disabledLabel = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('Disabled'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(disabledLabel.color, theme.colors.textDisabled);
      expect(
        themeContrastRatio(disabledLabel.color!, theme.colors.bg),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled radio label pair; exemption applies only to this disabled label',
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey<String>('unselected')),
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
