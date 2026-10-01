import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('checked switch uses success, themed label and motion', (
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
                AnimalSwitch(
                  key: const ValueKey('checked'),
                  value: true,
                  onChanged: (_) {},
                  checkedChildren: const Text('ON'),
                  focusNode: focusNode,
                ),
                AnimalSwitch(
                  key: const ValueKey('unchecked'),
                  value: false,
                  onChanged: (_) {},
                  unCheckedChildren: const Text('OFF'),
                ),
                const AnimalSwitch(
                  key: ValueKey('disabled'),
                  value: false,
                  onChanged: null,
                  disabled: true,
                  unCheckedChildren: Text('DISABLED'),
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

      AnimatedContainer track(String name) => tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byKey(ValueKey<String>(name)),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is AnimatedContainer &&
                    widget.decoration is BoxDecoration &&
                    ((widget.decoration! as BoxDecoration).border != null),
              ),
            ),
          )
          .single;

      final checkedTrack = track('checked');
      expect(
        (checkedTrack.decoration! as BoxDecoration).color,
        theme.colors.success,
      );
      expect(
        ((checkedTrack.decoration! as BoxDecoration).border!.top.color),
        theme.colors.success,
      );
      expect(checkedTrack.duration, theme.motion.normal);
      expect(checkedTrack.curve, theme.motion.ease);
      final checkedThumbMotion = tester.widget<AnimatedPositioned>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('checked')),
          matching: find.byType(AnimatedPositioned),
        ),
      );
      expect(checkedThumbMotion.duration, theme.motion.normal);
      expect(checkedThumbMotion.curve, theme.motion.spring);
      expect(
        checkedThumbMotion.left,
        AnimalSwitchSize.defaultSize.width -
            AnimalSwitchSize.defaultSize.thumbSize -
            (AnimalSwitchSize.defaultSize.height -
                    AnimalSwitchSize.defaultSize.thumbSize) /
                2,
      );
      final checkedStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('ON'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(checkedStyle.color, theme.colors.onSuccess);
      expect(checkedStyle.letterSpacing, theme.typography.body.letterSpacing);
      expect(
        themeContrastRatio(checkedStyle.color!, theme.colors.success),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} checked switch text pair',
      );

      final uncheckedTrack = track('unchecked');
      expect(
        (uncheckedTrack.decoration! as BoxDecoration).color,
        theme.colors.bgSecondary,
      );
      final inactiveBorder = theme.colors.brightness == Brightness.dark
          ? theme.colors.border
          : theme.colors.borderLight;
      expect(
        (uncheckedTrack.decoration! as BoxDecoration).border!.top.color,
        inactiveBorder,
      );
      final uncheckedStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('OFF'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(uncheckedStyle.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(uncheckedStyle.color!, theme.colors.bgSecondary),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} unchecked switch text pair',
      );

      final disabledTrack = track('disabled');
      final disabledTrackColor = theme.colors.brightness == Brightness.dark
          ? theme.colors.surfaceAlt
          : theme.colors.bgDisabled;
      expect(
        (disabledTrack.decoration! as BoxDecoration).color,
        disabledTrackColor,
      );
      expect(
        (disabledTrack.decoration! as BoxDecoration).border!.top.color,
        inactiveBorder,
      );
      final disabledSemantics = tester
          .widgetList<Semantics>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('disabled')),
              matching: find.byType(Semantics),
            ),
          )
          .firstWhere((semantics) => semantics.properties.enabled == false);
      expect(disabledSemantics.properties.enabled, isFalse);
      final disabledStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('DISABLED'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;
      expect(disabledStyle.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(disabledStyle.color!, disabledTrackColor),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled switch label pair',
      );
      final disabledThumb = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('disabled')),
              matching: find.byType(Container),
            ),
          )
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).shape ==
                    BoxShape.circle,
          );
      expect(
        (disabledThumb.decoration! as BoxDecoration).color,
        theme.colors.surfaceHeader,
      );
      expect((disabledThumb.decoration! as BoxDecoration).boxShadow, [
        theme.shadows.softElevation,
      ]);

      final focusShell = tester
          .widgetList<Container>(
            find.descendant(
              of: find.byKey(const ValueKey<String>('checked')),
              matching: find.byType(Container),
            ),
          )
          .firstWhere(
            (container) =>
                container.decoration is BoxDecoration &&
                (container.decoration! as BoxDecoration).border?.top.color ==
                    theme.colors.focusYellow,
          );
      expect(
        (focusShell.decoration! as BoxDecoration).border!.top.color,
        theme.colors.focusYellow,
      );
      expect(
        themeContrastRatio(theme.colors.focusYellow, theme.colors.bgSecondary),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} switch focus outline pair',
      );
      final labelPosition = tester
          .widgetList<Positioned>(find.byType(Positioned))
          .firstWhere((positioned) => positioned.left == theme.spacing.sm);
      expect(labelPosition.left, theme.spacing.sm);

      await tester.pumpWidget(const SizedBox.shrink());
      focusNode.dispose();
    }
  });
}
