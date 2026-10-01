import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/notification/notification_card.dart';
import 'package:animal_island_ui/src/components/notification/notification_queue.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C30 AnimalNotificationCard renders themed semantic text and surface',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        for (final (type, headingColor, background) in [
          (
            AnimalNotificationType.info,
            theme.colors.infoText,
            theme.colors.infoBg,
          ),
          (
            AnimalNotificationType.success,
            theme.colors.successText,
            theme.colors.successBg,
          ),
          (
            AnimalNotificationType.warning,
            theme.colors.warningText,
            theme.colors.warningBg,
          ),
          (
            AnimalNotificationType.error,
            theme.colors.errorText,
            theme.colors.errorBg,
          ),
        ]) {
          await tester.pumpWidget(
            MaterialApp(
              localizationsDelegates:
                  AnimalLocalizations.localizationsDelegates,
              supportedLocales: AnimalLocalizations.supportedLocales,

              key: ValueKey('${theme.hashCode}-$type'),
              theme: theme.toThemeData(),
              home: Scaffold(
                body: AnimalNotificationCard(
                  config: AnimalNotificationConfig(
                    message: const Text('Island notice'),
                    description: const Text('Notice detail'),
                    type: type,
                    duration: const Duration(days: 1),
                  ),
                  onDismiss: () {},
                  onTimeout: () {},
                ),
              ),
            ),
          );

          final titleStyle = DefaultTextStyle.of(
            tester.element(find.text('Island notice')),
          ).style;
          final descriptionStyle = DefaultTextStyle.of(
            tester.element(find.text('Notice detail')),
          ).style;
          final bodyPadding = tester.widget<Padding>(
            find
                .ancestor(
                  of: find.text('Island notice'),
                  matching: find.byType(Padding),
                )
                .first,
          );
          final cardFinder = find.ancestor(
            of: find.text('Island notice'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container &&
                  widget.decoration is BoxDecoration &&
                  (widget.decoration! as BoxDecoration).color == background,
            ),
          );
          expect(cardFinder, findsOneWidget);
          final card = tester.widget<Container>(cardFinder);
          final cardDecoration = card.decoration! as BoxDecoration;
          expect(titleStyle.color, headingColor);
          expect(
            titleStyle.fontSize,
            theme.typography.heading.fontSize! * 0.75,
          );
          expect(descriptionStyle.color, theme.colors.textBody);
          expect(
            descriptionStyle.fontSize,
            theme.typography.body.fontSize! * (13 / 14),
          );
          expect(cardDecoration.color, background);
          expect(cardDecoration.borderRadius, theme.radii.cardBorder);
          expect(
            themeContrastRatio(titleStyle.color!, cardDecoration.color!),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            themeContrastRatio(descriptionStyle.color!, cardDecoration.color!),
            greaterThanOrEqualTo(4.5),
          );
          final icon = tester.widget<AnimalIcon>(find.byType(AnimalIcon).first);
          expect(icon.color, headingColor);
          expect(
            themeContrastRatio(icon.color!, cardDecoration.color!),
            greaterThanOrEqualTo(3),
          );

          if (type == AnimalNotificationType.info) {
            final cardShadow = cardDecoration.boxShadow!.single;
            expect(
              cardShadow.color,
              theme.colors.info.withValues(
                alpha: theme.colors.brightness == Brightness.dark ? 0.35 : 0.20,
              ),
            );
            expect(
              cardShadow.offset,
              Offset(
                theme.shadows.softElevation.offset.dx * 3,
                theme.shadows.softElevation.offset.dy * 3,
              ),
            );
            expect(
              cardShadow.blurRadius,
              theme.shadows.softElevation.blurRadius * 3.5,
            );
            expect(
              bodyPadding.padding,
              EdgeInsets.only(
                left: theme.spacing.lg + theme.spacing.xs,
                top: theme.spacing.lg - theme.spacing.xxs,
                bottom: theme.spacing.lg - theme.spacing.xxs,
              ),
            );
          }
        }

        AnimalNotificationQueueState? queueState;
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey('${theme.hashCode}-queue'),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: Stack(
                children: [
                  AnimalNotificationQueueContainer(
                    placement: AnimalNotificationPlacement.topRight,
                    onStateReady: (state) => queueState = state,
                    onEmpty: () {},
                  ),
                ],
              ),
            ),
          ),
        );
        queueState!.add(
          AnimalNotificationConfig(
            key: 'theme-probe',
            message: const Text('Queued notice'),
            duration: const Duration(days: 1),
          ),
        );
        await tester.pump();
        await tester.pump(theme.motion.normal ~/ 2);
        final notificationCard = find.byType(AnimalNotificationCard);
        final fade = tester.widget<FadeTransition>(
          find
              .descendant(
                of: notificationCard,
                matching: find.byType(FadeTransition),
              )
              .first,
        );
        final slide = tester.widget<SlideTransition>(
          find
              .descendant(
                of: notificationCard,
                matching: find.byType(SlideTransition),
              )
              .first,
        );
        expect(
          fade.opacity.value,
          closeTo(theme.motion.ease.transform(0.5), 0.04),
        );
        expect(
          slide.position.value.dy,
          closeTo(-0.4 * (1 - theme.motion.spring.transform(0.5)), 0.03),
        );
        await tester.pump(theme.motion.normal - (theme.motion.normal ~/ 2));
        expect(fade.opacity.value, 1);
        final queuePaddings = tester.widgetList<Padding>(
          find.descendant(
            of: find.byType(AnimalNotificationQueueContainer),
            matching: find.byType(Padding),
          ),
        );
        expect(
          queuePaddings.map((padding) => padding.padding),
          contains(
            EdgeInsets.only(
              top: theme.spacing.lg,
              left: theme.spacing.lg,
              right: theme.spacing.lg,
            ),
          ),
        );
        expect(
          queuePaddings.map((padding) => padding.padding),
          contains(
            EdgeInsets.only(bottom: theme.spacing.sm + theme.spacing.xxs / 2),
          ),
        );
      }
    },
  );
}
