import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C06 title keeps caller heading localized at runtime', (
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
            return AnimalTitle(
              semanticLabel: localizations.clear,
              child: Text(localizations.today),
            );
          },
        ),
      ),
    );

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Title'), findsNothing);
    expect(find.semantics.byLabel('Clear\nToday'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('今天'), findsOneWidget);
    expect(find.semantics.byLabel('清空\n今天'), findsOneWidget);
    expect(find.semantics.byLabel('Clear\nToday'), findsNothing);
    expect(find.text('Today'), findsNothing);
  });
}
