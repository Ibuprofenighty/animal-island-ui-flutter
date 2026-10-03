import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('select uses theme surface, popup shape, spacing and timing', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
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
                AnimalSelect<String>(
                  key: const ValueKey('normal'),
                  value: 'a',
                  options: const [
                    AnimalOption(value: 'a', label: 'Selected'),
                    AnimalOption(value: 'b', label: 'Other'),
                    AnimalOption(value: 'c', label: 'Locked', disabled: true),
                  ],
                  onChanged: (_) {},
                  allowClear: true,
                ),
                const SizedBox(height: 8),
                AnimalSelect<String>(
                  key: const ValueKey('error'),
                  value: null,
                  options: const [],
                  placeholder: 'Error placeholder',
                  onChanged: (_) {},
                  status: AnimalInputStatus.error,
                ),
                const SizedBox(height: 8),
                AnimalSelect<String>(
                  key: ValueKey('disabled'),
                  value: 'locked',
                  options: [AnimalOption(value: 'locked', label: 'Disabled')],
                  onChanged: null,
                  disabled: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      AnimatedContainer trigger(String name) => tester
          .widgetList<AnimatedContainer>(
            find.descendant(
              of: find.byKey(ValueKey<String>(name)),
              matching: find.byWidgetPredicate(
                (widget) =>
                    widget is AnimatedContainer &&
                    widget.decoration is BoxDecoration &&
                    (widget.decoration! as BoxDecoration).border != null &&
                    (widget.decoration! as BoxDecoration).color != null,
              ),
            ),
          )
          .single;

      BoxDecoration triggerDecoration(String name) =>
          trigger(name).decoration! as BoxDecoration;

      Text triggerText(String name, String label) => tester.widget<Text>(
        find.descendant(
          of: find.byKey(ValueKey<String>(name)),
          matching: find.text(label),
        ),
      );

      final normalTrigger = trigger('normal');
      final normalDecoration = triggerDecoration('normal');
      expect(normalDecoration.color, theme.colors.bgInput);
      expect(normalDecoration.border!.top.color, theme.colors.border);
      expect(normalDecoration.borderRadius, theme.radii.pillBorder);
      expect(normalTrigger.duration, theme.motion.fast);
      expect(normalTrigger.curve, theme.motion.ease);
      expect(
        normalTrigger.padding,
        EdgeInsets.symmetric(horizontal: theme.spacing.lg),
      );
      final normalText = triggerText('normal', 'Selected');
      expect(
        normalText.style!.letterSpacing,
        theme.typography.body.letterSpacing,
      );
      expect(normalText.style!.color, theme.colors.text);
      expect(
        themeContrastRatio(normalText.style!.color!, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected trigger text pair',
      );
      final clearIcon = tester.widget<AnimalIcon>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('normal')),
          matching: find.byType(AnimalIcon),
        ),
      );
      expect(clearIcon.color, theme.colors.textSecondary);
      final arrow = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('normal')),
          matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
        ),
      );
      expect(arrow.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(theme.colors.textSecondary, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} select utility icon pair',
      );
      expect(
        themeContrastRatio(clearIcon.color!, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
      );

      final placeholderText = triggerText('error', 'Error placeholder');
      expect(placeholderText.style!.color, theme.colors.textSecondary);
      expect(
        themeContrastRatio(placeholderText.style!.color!, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} enabled placeholder pair',
      );
      final errorDecoration = triggerDecoration('error');
      expect(errorDecoration.border!.top.color, theme.colors.errorText);
      expect(
        errorDecoration.boxShadow!.single.color,
        theme.colors.errorText.withValues(alpha: 0.45),
      );
      expect(
        themeContrastRatio(theme.colors.errorText, theme.colors.bgInput),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} select validation stroke pair',
      );

      final disabledDecoration = triggerDecoration('disabled');
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
      final disabledText = triggerText('disabled', 'Disabled');
      expect(disabledText.style!.color, theme.colors.textDisabled);
      expect(
        themeContrastRatio(disabledText.style!.color!, disabledSurface),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} true-disabled select text pair; exemption is scoped to disabled trigger',
      );
      final disabledTriggerOwner = tester.widget<InteractiveRegion>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('disabled')),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is InteractiveRegion &&
                widget.semanticLabel == 'Disabled',
          ),
        ),
      );
      expect(disabledTriggerOwner.disabled, isTrue);
      expect(disabledTriggerOwner.onPressed, isNotNull);
      final disabledArrow = tester.widget<Icon>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('disabled')),
          matching: find.byIcon(Icons.keyboard_arrow_down_rounded),
        ),
      );
      expect(disabledArrow.color, theme.colors.textDisabled);

      await tester.tap(find.byKey(const ValueKey<String>('normal')));
      await tester.pumpAndSettle();
      final anchor = tester.widget<MenuAnchor>(
        find.descendant(
          of: find.byKey(const ValueKey<String>('normal')),
          matching: find.byType(MenuAnchor),
        ),
      );
      expect(anchor.controller!.isOpen, isTrue);
      final focusedTrigger = triggerDecoration('normal');
      expect(focusedTrigger.border!.top.color, theme.colors.focusYellow);
      expect(
        themeContrastRatio(theme.colors.focusYellow, theme.colors.bgInput),
        greaterThanOrEqualTo(3.0),
        reason: '${theme.colors.brightness.name} select focus outline pair',
      );

      final popup = anchor.style!;
      expect(
        popup.backgroundColor!.resolve(<WidgetState>{}),
        theme.colors.bgContent,
      );
      final popupShape =
          popup.shape!.resolve(<WidgetState>{}) as RoundedRectangleBorder;
      expect(popupShape.borderRadius, theme.radii.tooltipBorder);
      expect(popupShape.side.color, theme.colors.border);
      expect(
        popup.padding!.resolve(<WidgetState>{}),
        EdgeInsets.symmetric(vertical: theme.spacing.xs),
      );

      final selectedMenuText = tester
          .widgetList<Text>(find.text('Selected'))
          .firstWhere((text) => text.style?.color == theme.colors.primaryText);
      final selectedMenuOwner = tester.widget<InteractiveRegion>(
        find.ancestor(
          of: find.byWidget(selectedMenuText),
          matching: find.byWidgetPredicate(
            (widget) => widget is InteractiveRegion && widget.selected == true,
          ),
        ),
      );
      final selectedFill = theme.colors.primary.withValues(alpha: 0.12);
      expect(selectedMenuOwner.surfaceColor, selectedFill);
      expect(selectedFill, theme.colors.primary.withValues(alpha: 0.12));
      expect(selectedMenuText.style!.fontSize, theme.typography.body.fontSize);
      expect(
        selectedMenuOwner.padding,
        EdgeInsets.symmetric(
          horizontal: theme.spacing.lg,
          vertical: theme.spacing.sm,
        ),
      );
      expect(
        find.descendant(
          of: find.ancestor(
            of: find.byWidget(selectedMenuText),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is InteractiveRegion && widget.selected == true,
            ),
          ),
          matching: find.byWidgetPredicate(
            (widget) => widget is SizedBox && widget.width == theme.spacing.md,
          ),
        ),
        findsOneWidget,
      );
      final selectedSurface = Color.alphaBlend(
        selectedFill,
        theme.colors.bgContent,
      );
      expect(
        themeContrastRatio(selectedMenuText.style!.color!, selectedSurface),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} selected menu text pair',
      );

      final otherMenuText = tester
          .widgetList<Text>(find.text('Other'))
          .firstWhere((text) => text.style?.color == theme.colors.text);
      expect(
        themeContrastRatio(otherMenuText.style!.color!, theme.colors.bgContent),
        greaterThanOrEqualTo(4.5),
        reason: '${theme.colors.brightness.name} other menu text pair',
      );
      final disabledMenuText = tester
          .widgetList<Text>(find.text('Locked'))
          .single;
      expect(disabledMenuText.style!.color, theme.colors.textDisabled);
      final disabledMenuOwner = tester.widget<InteractiveRegion>(
        find.ancestor(
          of: find.byWidget(disabledMenuText),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is InteractiveRegion &&
                widget.disabled &&
                widget.selected != true,
          ),
        ),
      );
      expect(disabledMenuOwner.onPressed, isNull);
      expect(disabledMenuOwner.disabled, isTrue);
      expect(
        themeContrastRatio(
          disabledMenuText.style!.color!,
          theme.colors.bgContent,
        ),
        greaterThan(1.0),
        reason:
            '${theme.colors.brightness.name} genuine disabled option text pair',
      );
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
