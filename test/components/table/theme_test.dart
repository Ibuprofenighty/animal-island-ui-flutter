import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/table/table_row.dart';

import '../../support/theme_contrast.dart';
import '../theme_fixtures.dart';

void main() {
  testWidgets(
    'C31 AnimalTable renders themed row spacing and header typography',
    (tester) async {
      for (final theme in animalIslandThemeVariants()) {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AnimalLocalizations.localizationsDelegates,
            supportedLocales: AnimalLocalizations.supportedLocales,

            key: ValueKey(theme),
            theme: theme.toThemeData(),
            home: Scaffold(
              body: SizedBox(
                width: 360,
                height: 180,
                child: AnimalTable(
                  rowKey: (index) => ValueKey('row-$index'),
                  columns: [AnimalTableColumn(title: 'Island name')],
                  rowCount: 1,
                  maxHeight: 180,
                  rowBuilder: (_, index) => [Text('Island $index')],
                ),
              ),
            ),
          ),
        );

        final header = find.byType(AnimalTableRow).first;
        final rowContainer = tester.widget<Container>(
          find.descendant(of: header, matching: find.byType(Container)).first,
        );
        final headerStyle = DefaultTextStyle.of(
          tester.element(find.text('Island name')),
        ).style;
        final headerBackground =
            (rowContainer.decoration! as BoxDecoration).color!;
        expect(
          rowContainer.padding,
          EdgeInsets.symmetric(
            horizontal: theme.spacing.lg,
            vertical: theme.spacing.md,
          ),
        );
        expect(headerStyle.fontSize, theme.typography.button.fontSize);
        expect(headerStyle.color, theme.colors.text);
        expect(headerBackground, theme.colors.surfaceHeader);
        expect(
          themeContrastRatio(headerStyle.color!, headerBackground),
          greaterThanOrEqualTo(4.5),
        );

        final bodyRow = find.byType(AnimalTableRow).at(1);
        final bodyContainer = tester.widget<Container>(
          find.descendant(of: bodyRow, matching: find.byType(Container)).first,
        );
        final bodyStyle = DefaultTextStyle.of(
          tester.element(find.text('Island 0')),
        ).style;
        final bodyBackground =
            (bodyContainer.decoration! as BoxDecoration).color!;
        expect(bodyBackground, theme.colors.surfaceAlt);
        expect(bodyStyle.color, theme.colors.textBody);
        expect(
          themeContrastRatio(bodyStyle.color!, bodyBackground),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byType(AnimalTable),
                  matching: find.byType(Container),
                ),
              )
              .any(
                (container) =>
                    container.decoration is BoxDecoration &&
                    (container.decoration! as BoxDecoration).borderRadius ==
                        theme.radii.cardBorder,
              ),
          isTrue,
        );
      }
    },
  );
}
