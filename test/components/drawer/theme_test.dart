import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets('C22 AnimalDrawer renders themed shape, spacing and elevation', (
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
            body: AnimalDrawer(
              title: Text('Island drawer'),
              child: Text('Drawer content'),
            ),
          ),
        ),
      );

      final drawer = find.byType(AnimalDrawer);
      final surface = tester.widget<Container>(
        find.descendant(of: drawer, matching: find.byType(Container)).first,
      );
      final decoration = surface.decoration! as BoxDecoration;
      final titleStyle = DefaultTextStyle.of(
        tester.element(find.text('Island drawer')),
      ).style;
      final contentStyle = DefaultTextStyle.of(
        tester.element(find.text('Drawer content')),
      ).style;
      expect(decoration.color, theme.colors.bgContent);
      expect(titleStyle.color, theme.colors.text);
      expect(titleStyle.fontSize, theme.typography.title.fontSize! * 0.75);
      expect(contentStyle.color, theme.colors.textBody);
      expect(
        themeContrastRatio(titleStyle.color!, decoration.color!),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        themeContrastRatio(contentStyle.color!, decoration.color!),
        greaterThanOrEqualTo(4.5),
      );
      final bodyPadding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.text('Drawer content'),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(
        decoration.borderRadius,
        BorderRadius.horizontal(left: Radius.circular(theme.radii.card * 1.2)),
      );
      expect(decoration.boxShadow, theme.shadows.modal);
      expect(
        bodyPadding.padding,
        EdgeInsets.all(theme.spacing.lg + theme.spacing.xs),
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
                onPressed: () => AnimalDrawer.show<void>(
                  context: context,
                  title: const Text('Routed island drawer'),
                  builder: (context, close) =>
                      const Text('Routed drawer content'),
                ),
                child: const Text('Open drawer'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open drawer'));
      await tester.pump();
      await tester.pump(theme.motion.normal ~/ 2);
      final routedContent = find.text('Routed drawer content');
      final drawerRoute = ModalRoute.of(tester.element(routedContent))!;
      expect(drawerRoute.transitionDuration, theme.motion.normal);
      final slide = tester.widget<SlideTransition>(
        find
            .ancestor(of: routedContent, matching: find.byType(SlideTransition))
            .first,
      );
      expect(
        slide.position.value.dx,
        closeTo(1 - theme.motion.spring.transform(0.5), 0.03),
      );
      await tester.pumpAndSettle();
    }
  });
}
