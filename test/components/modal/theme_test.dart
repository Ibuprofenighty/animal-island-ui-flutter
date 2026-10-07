import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/modal/modal_surface.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C21 AnimalModal renders themed surface spacing and elevation', (
    tester,
  ) async {
    for (final theme in animalIslandThemeVariants()) {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ValueKey(theme),
          theme: theme.toThemeData(),
          home: const Scaffold(
            body: AnimalModal(
              title: Text('Island dialog'),
              content: Text('Modal content'),
            ),
          ),
        ),
      );

      final surface = find.byType(AnimalModalSurface);
      final surfacePainter =
          tester
                  .widgetList<CustomPaint>(
                    find.descendant(
                      of: surface,
                      matching: find.byType(CustomPaint),
                    ),
                  )
                  .firstWhere((paint) => paint.painter is BlobModalPainter)
                  .painter!
              as BlobModalPainter;
      final titleStyle = DefaultTextStyle.of(
        tester.element(find.text('Island dialog')),
      ).style;
      final contentStyle = DefaultTextStyle.of(
        tester.element(find.text('Modal content')),
      ).style;
      expect(surfacePainter.fillColor, theme.colors.bgContent);
      expect(titleStyle.color, theme.colors.text);
      expect(titleStyle.fontSize, theme.typography.title.fontSize! * 0.75);
      expect(contentStyle.color, theme.colors.textBody);
      expect(
        contentStyle.fontSize,
        theme.typography.body.fontSize! * (15 / 14),
      );
      expect(
        themeContrastRatio(titleStyle.color!, surfacePainter.fillColor),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        themeContrastRatio(contentStyle.color!, surfacePainter.fillColor),
        greaterThanOrEqualTo(4.5),
      );
      final modalPadding = EdgeInsets.symmetric(
        horizontal: theme.spacing.xxl + theme.spacing.xs,
        vertical: theme.spacing.xxl,
      );
      final descendants = find.descendant(
        of: surface,
        matching: find.byType(Padding),
      );
      expect(
        tester
            .widgetList<Padding>(descendants)
            .map((padding) => padding.padding),
        contains(modalPadding),
      );
      final shadowedContainers = tester.widgetList<Container>(
        find.descendant(of: surface, matching: find.byType(Container)),
      );
      expect(
        shadowedContainers.any(
          (container) =>
              container.decoration is BoxDecoration &&
              (container.decoration! as BoxDecoration).boxShadow ==
                  theme.shadows.modal,
        ),
        isTrue,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          key: ValueKey('${theme.hashCode}-route'),
          theme: theme.toThemeData(),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => AnimalModal.showDialogue(
                  context: context,
                  avatar: const Icon(Icons.person),
                  dialogue: 'Welcome, islander.',
                ),
                child: const Text('Open dialogue'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open dialogue'));
      await tester.pumpAndSettle();
      final dialogueRoute = ModalRoute.of(tester.element(find.text('Cancel')))!;
      expect(dialogueRoute.transitionDuration, theme.motion.normal);
      final dialogueGaps = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(AnimalModal),
              matching: find.byType(SizedBox),
            ),
          )
          .where((sizedBox) => sizedBox.width != null)
          .map((sizedBox) => sizedBox.width);
      expect(dialogueGaps, contains(theme.spacing.md + theme.spacing.xxs / 2));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    }
  });
}
