import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C12 clear action localizes while caller placeholder updates', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    final textController = TextEditingController(text: 'value');
    addTearDown(textController.dispose);

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Builder(
          builder: (context) {
            final localizations = AnimalLocalizations.of(context)!;
            final placeholder = localizations.localeName == 'zh'
                ? '搜索项目'
                : 'Search items';
            return Scaffold(
              body: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimalInput(
                    controller: textController,
                    clearable: true,
                    placeholder: placeholder,
                  ),
                  AnimalInput(placeholder: placeholder),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(find.semantics.byLabel('Clear input'), findsOneWidget);
    expect(find.text('Search items'), findsNWidgets(2));

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.semantics.byLabel('清除输入'), findsOneWidget);
    expect(find.text('搜索项目'), findsNWidgets(2));
    expect(find.semantics.byLabel('Clear input'), findsNothing);
  });
}
