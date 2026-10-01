import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C32 pagination navigation semantics follow the mounted locale', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: AnimalPagination(
          current: 6,
          total: 100,
          pageSize: 10,
          onChanged: (_) {},
        ),
      ),
    );
    for (final label in const [
      'Page 6 of 10',
      'Previous page',
      'Next page',
      'Skip five pages backward',
      'Skip five pages forward',
    ]) {
      final node = tester.getSemantics(find.bySemanticsLabel(label));
      expect(node.label, label);
    }
    expect(tester.getSemantics(find.text('6')).label, 'Page 6');

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    for (final label in const [
      '第 6 页，共 10 页',
      '上一页',
      '下一页',
      '向前跳过五页',
      '向后跳过五页',
    ]) {
      final node = tester.getSemantics(find.bySemanticsLabel(label));
      expect(node.label, label);
    }
    expect(tester.getSemantics(find.text('6')).label, '第 6 页');
    semantics.dispose();
  });
}
