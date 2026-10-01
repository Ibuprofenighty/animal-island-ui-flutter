import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  group('AnimalButton theme token rendering', () {
    testWidgets(
      'M28: rendered filled tone pairs meet 4.5 contrast in all themes',
      (tester) async {
        final themes = <AnimalIslandTheme>[
          AnimalIslandTheme.light,
          AnimalIslandTheme.dark,
          thirdAnimalIslandTheme(),
        ];

        for (var themeIndex = 0; themeIndex < themes.length; themeIndex++) {
          final theme = themes[themeIndex];
          for (final tone in AnimalButtonTone.values) {
            final label = 'contrast-$themeIndex-${tone.name}';
            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates:
                    AnimalLocalizations.localizationsDelegates,
                supportedLocales: AnimalLocalizations.supportedLocales,

                theme: theme.toThemeData(),
                home: Scaffold(
                  body: AnimalButton(
                    tone: tone,
                    onPressed: () {},
                    child: Text(label),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final text = _buttonTextStyle(tester, label);
            final surface = _buttonSurface(tester, find.byType(AnimalButton));
            expect(
              themeContrastRatio(text.color!, surface.color!),
              greaterThanOrEqualTo(4.5),
              reason: '$label uses actual rendered foreground/surface colors',
            );
          }
        }
      },
    );

    testWidgets('filled tones pair themed surfaces with their on-tone text', (
      tester,
    ) async {
      final themes = <AnimalIslandTheme>[
        AnimalIslandTheme.light,
        AnimalIslandTheme.dark,
        thirdAnimalIslandTheme(),
      ];

      for (var themeIndex = 0; themeIndex < themes.length; themeIndex++) {
        final theme = themes[themeIndex];
        for (final tone in AnimalButtonTone.values) {
          final label = 'filled-$themeIndex-${tone.name}';
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: theme.toThemeData(),
              home: Scaffold(
                body: AnimalButton(
                  tone: tone,
                  onPressed: () {},
                  child: Text(label),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final button = find.byType(AnimalButton);
          final surface = _buttonSurface(tester, button);
          final buttonContainer = tester.widget<AnimatedContainer>(
            find.descendant(
              of: button,
              matching: find.byType(AnimatedContainer),
            ),
          );
          final text = _buttonTextStyle(tester, label);
          final expectedSurface = switch (tone) {
            AnimalButtonTone.primary => theme.colors.primary,
            AnimalButtonTone.neutral => theme.colors.bgContent,
            AnimalButtonTone.warning => theme.colors.warning,
            AnimalButtonTone.success => theme.colors.success,
            AnimalButtonTone.danger => theme.colors.error,
          };
          final expectedText = switch (tone) {
            AnimalButtonTone.primary => theme.colors.onPrimary,
            AnimalButtonTone.neutral => theme.colors.text,
            AnimalButtonTone.warning => theme.colors.onWarning,
            AnimalButtonTone.success => theme.colors.onSuccess,
            AnimalButtonTone.danger => theme.colors.onError,
          };

          expect(surface.color, expectedSurface, reason: label);
          expect(surface.borderRadius, theme.radii.pillBorder, reason: label);
          expect(text.color, expectedText, reason: label);
          expect(
            text.fontSize,
            AnimalButtonSize.middle.fontSize,
            reason: label,
          );
          expect(text.wordSpacing, theme.typography.button.wordSpacing);
          expect(text.letterSpacing, theme.typography.button.letterSpacing);
          expect(text.fontFamily, theme.typography.button.fontFamily);
          expect(buttonContainer.duration, theme.motion.fast);
          expect(buttonContainer.curve, theme.motion.ease);

          final depthShadows = surface.boxShadow!;
          if (tone == AnimalButtonTone.neutral) {
            expect(depthShadows, [theme.shadows.softElevation], reason: label);
            expect(
              (surface.border! as Border).top.color,
              theme.colors.brightness == Brightness.dark
                  ? theme.colors.border
                  : theme.colors.borderLight,
              reason: label,
            );
          } else if (tone == AnimalButtonTone.primary ||
              tone == AnimalButtonTone.danger) {
            expect(
              depthShadows,
              contains(theme.shadows.button3d),
              reason: label,
            );
            expect(
              tester
                  .widget<AnimatedContainer>(
                    find.descendant(
                      of: button,
                      matching: find.byType(AnimatedContainer),
                    ),
                  )
                  .margin!
                  .resolve(TextDirection.ltr)
                  .bottom,
              4.0,
              reason: '$label keeps the frozen press travel geometry',
            );

            final gesture = await tester.startGesture(
              tester.getCenter(find.text(label)),
            );
            await tester.pump();
            final pressedSurface = _buttonSurface(tester, button);
            expect(
              pressedSurface.boxShadow,
              isNot(contains(theme.shadows.button3d)),
            );
            expect(
              tester
                  .widget<AnimatedContainer>(
                    find.descendant(
                      of: button,
                      matching: find.byType(AnimatedContainer),
                    ),
                  )
                  .margin!
                  .resolve(TextDirection.ltr)
                  .top,
              4.0,
            );
            await gesture.up();
            await tester.pumpAndSettle();
          } else {
            expect(depthShadows, isEmpty, reason: label);
          }
        }
      }
    });

    testWidgets('surface variants use the semantic surface text role', (
      tester,
    ) async {
      final themes = <AnimalIslandTheme>[
        AnimalIslandTheme.light,
        AnimalIslandTheme.dark,
        thirdAnimalIslandTheme(),
      ];
      for (final theme in themes) {
        for (final tone in AnimalButtonTone.values) {
          for (final variant in <AnimalButtonVariant>[
            AnimalButtonVariant.outlined,
            AnimalButtonVariant.dashed,
            AnimalButtonVariant.text,
            AnimalButtonVariant.link,
          ]) {
            final label =
                '${theme.colors.brightness.name}-${tone.name}-${variant.name}';
            await tester.pumpWidget(
              MaterialApp(
                localizationsDelegates:
                    AnimalLocalizations.localizationsDelegates,
                supportedLocales: AnimalLocalizations.supportedLocales,

                theme: theme.toThemeData(),
                home: Scaffold(
                  body: AnimalButton(
                    tone: tone,
                    variant: variant,
                    onPressed: () {},
                    child: Text(label),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();

            final expectedText = switch (tone) {
              AnimalButtonTone.primary => theme.colors.primaryText,
              AnimalButtonTone.neutral =>
                variant == AnimalButtonVariant.link
                    ? theme.colors.primaryText
                    : theme.colors.text,
              AnimalButtonTone.warning => theme.colors.warningText,
              AnimalButtonTone.success => theme.colors.successText,
              AnimalButtonTone.danger => theme.colors.errorText,
            };
            final renderedText = _buttonTextStyle(tester, label);
            final surface = _buttonSurface(tester, find.byType(AnimalButton));
            expect(renderedText.color, expectedText, reason: label);
            expect(surface.color, Colors.transparent, reason: label);
            expect(
              themeContrastRatio(renderedText.color!, theme.colors.bg),
              greaterThanOrEqualTo(4.5),
              reason: '$label is rendered over the Scaffold background',
            );
            if (variant == AnimalButtonVariant.outlined ||
                variant == AnimalButtonVariant.dashed) {
              expect((surface.border! as Border).top.color, expectedText);
            } else {
              expect(surface.border, isNull);
            }
            expect(
              renderedText.decoration,
              variant == AnimalButtonVariant.link
                  ? TextDecoration.underline
                  : TextDecoration.none,
            );
          }
        }
      }
    });

    testWidgets('disabled state suppresses tone color and tactile depth', (
      tester,
    ) async {
      final themes = <AnimalIslandTheme>[
        AnimalIslandTheme.light,
        AnimalIslandTheme.dark,
        thirdAnimalIslandTheme(),
      ];
      for (final theme in themes) {
        for (final variant in AnimalButtonVariant.values) {
          final label =
              'disabled-${theme.colors.brightness.name}-${variant.name}';
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              theme: theme.toThemeData(),
              home: Scaffold(
                body: AnimalButton(
                  tone: AnimalButtonTone.success,
                  variant: variant,
                  disabled: true,
                  onPressed: () {},
                  child: Text(label),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final surface = _buttonSurface(tester, find.byType(AnimalButton));
          expect(
            _buttonTextStyle(tester, label).color,
            theme.colors.textDisabled,
          );
          expect(surface.boxShadow, isEmpty);
          expect(surface.color, switch (variant) {
            AnimalButtonVariant.text ||
            AnimalButtonVariant.link => Colors.transparent,
            _ =>
              theme.colors.brightness == Brightness.dark
                  ? theme.colors.surfaceAlt
                  : theme.colors.bgDisabled,
          });
          if (variant == AnimalButtonVariant.outlined ||
              variant == AnimalButtonVariant.filled) {
            expect(
              (surface.border! as Border).top.color,
              theme.colors.brightness == Brightness.dark
                  ? theme.colors.border
                  : theme.colors.borderLight,
            );
          }
        }
      }
    });

    testWidgets('button icon gap uses active theme spacing', (tester) async {
      final theme = thirdAnimalIslandTheme();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalButton(
              icon: const Icon(Icons.add),
              onPressed: () {},
              child: const Text('add item'),
            ),
          ),
        ),
      );

      final gap = find.descendant(
        of: find.byType(AnimalButton),
        matching: find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == theme.spacing.sm,
        ),
      );
      expect(gap, findsOneWidget);
      expect(tester.getSize(gap).width, theme.spacing.sm);
    });
  });
}

BoxDecoration _buttonSurface(WidgetTester tester, Finder button) {
  final container = tester.widget<AnimatedContainer>(
    find.descendant(of: button, matching: find.byType(AnimatedContainer)).first,
  );
  return container.decoration! as BoxDecoration;
}

TextStyle _buttonTextStyle(WidgetTester tester, String label) {
  final style = tester.widget<DefaultTextStyle>(
    find
        .ancestor(of: find.text(label), matching: find.byType(DefaultTextStyle))
        .first,
  );
  return style.style;
}
