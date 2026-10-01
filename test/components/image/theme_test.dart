import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/image/image_preview.dart';

import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C35 AnimalImage renders themed frame radius, spacing and shadow',
    (tester) async {
      final theme = thirdAnimalIslandTheme();
      final image = MemoryImage(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/paoAAAAASUVORK5CYII=',
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AnimalLocalizations.localizationsDelegates,
          supportedLocales: AnimalLocalizations.supportedLocales,

          theme: theme.toThemeData(),
          home: Scaffold(
            body: AnimalImage(
              image: image,
              width: 80,
              height: 60,
              variant: AnimalImageVariant.bordered,
              preview: true,
              semanticLabel: 'Island scene',
            ),
          ),
        ),
      );

      final frame = tester.widget<Container>(
        find.descendant(
          of: find.byType(AnimalImage),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.padding ==
                    EdgeInsets.all(theme.spacing.xs + theme.spacing.xxs),
          ),
        ),
      );
      final decoration = frame.decoration! as BoxDecoration;
      expect(
        frame.padding,
        EdgeInsets.all(theme.spacing.xs + theme.spacing.xxs),
      );
      expect(decoration.borderRadius, theme.radii.smBorder);
      expect(decoration.boxShadow, [theme.shadows.softElevation]);
      expect(decoration.color, theme.colors.bgContent);
      expect(decoration.border!.top.color, theme.colors.borderLight);

      await tester.tap(find.byType(AnimalImage));
      await tester.pump();
      final previewContent = find.byType(InteractiveViewer);
      final previewRoute = ModalRoute.of(tester.element(previewContent))!;
      expect(previewRoute, isA<AnimalImagePreviewRoute>());
      expect(previewRoute.transitionDuration, theme.motion.normal);
    },
  );
}
