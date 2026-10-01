import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('AnimalLoading updates its default semantics with the locale', (
    tester,
  ) async {
    final controller = LocalizationTestController(
      initialLocale: const Locale('en'),
    );
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: const Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimalLoading.spinner(),
              AnimalLoading.spinner(tip: 'Caller tip'),
              AnimalLoading.spinner(tipWidget: Text('Caller widget tip')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.getSemantics(find.byType(AnimalLoading).at(0)).label,
      'Loading...',
    );
    expect(
      tester.getSemantics(find.byType(AnimalLoading).at(1)).label,
      'Caller tip',
    );
    expect(
      tester.getSemantics(find.byType(AnimalLoading).at(2)).label,
      'Loading...\nCaller widget tip',
    );
    expect(find.text('Caller tip'), findsOneWidget);
    expect(find.text('Caller widget tip'), findsOneWidget);

    controller.locale = const Locale('zh', 'CN');
    await tester.pump();
    expect(
      tester.getSemantics(find.byType(AnimalLoading).at(0)).label,
      '加载中...',
    );
    expect(
      tester.getSemantics(find.byType(AnimalLoading).at(1)).label,
      'Caller tip',
    );
    expect(
      tester.getSemantics(find.byType(AnimalLoading).at(2)).label,
      '加载中...\nCaller widget tip',
    );
    expect(find.text('Caller tip'), findsOneWidget);
    expect(find.text('Caller widget tip'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
