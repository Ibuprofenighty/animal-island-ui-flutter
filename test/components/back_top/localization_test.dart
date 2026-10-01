import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C27 back-to-top semantics follow the mounted locale', (
    tester,
  ) async {
    final localeController = LocalizationTestController();
    addTearDown(localeController.dispose);
    final scrollController = ScrollController(initialScrollOffset: 600);
    addTearDown(scrollController.dispose);
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: localeController,
        child: Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: scrollController,
                child: const SizedBox(height: 2000),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: AnimalBackTop(scrollController: scrollController),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Back to Top'), findsOneWidget);

    localeController.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('返回顶部'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
