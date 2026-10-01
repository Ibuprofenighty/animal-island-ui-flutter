import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C02 canonical icon semantics localize and caller labels win', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Builder(
          builder: (context) {
            final localizations = AnimalLocalizations.of(context)!;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimalIcon(data: AnimalIcons.search, onTap: () {}),
                AnimalIcon(
                  data: AnimalIcons.close,
                  semanticLabel: localizations.clear,
                  onTap: () {},
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(find.semantics.byLabel('Search'), findsOneWidget);
    expect(find.semantics.byLabel('Clear'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('搜索'), findsOneWidget);
    expect(find.semantics.byLabel('清空'), findsOneWidget);
    expect(find.semantics.byLabel('Search'), findsNothing);
    expect(find.semantics.byLabel('Clear'), findsNothing);
  });
}
