import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/time_picker/time_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C18 open time picker localizes actions and wheel values', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    var triggerClearCalls = 0;
    var panelClearCalls = 0;

    Finder clearRegion(Finder scope, String label) => find.descendant(
      of: scope,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is InteractiveRegion && widget.semanticLabel == label,
      ),
    );

    void activateSemanticRegion(Finder target, String label) {
      final int targetId = tester.getSemantics(target).id;
      final SemanticsFinder labeledTargets = find.semantics.byLabel(label);
      final List<SemanticsNode> nodes = labeledTargets.evaluate().toList();
      final int targetIndex = nodes.indexWhere((node) => node.id == targetId);
      expect(targetIndex, greaterThanOrEqualTo(0));
      tester.semantics.tap(labeledTargets.at(targetIndex));
    }

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimalTimePicker.popover(
              key: const ValueKey('empty-picker'),
              value: null,
              onChanged: (value) {
                expect(value, isNull);
                panelClearCalls++;
              },
            ),
            AnimalTimePicker.popover(
              key: const ValueKey('custom-placeholder-picker'),
              value: null,
              placeholder: 'Caller time',
              onChanged: (_) {},
            ),
            AnimalTimePicker.popover(
              key: const ValueKey('selected-picker'),
              value: AnimalTimeValue(hour: 9, minute: 30),
              onChanged: (value) {
                expect(value, isNull);
                triggerClearCalls++;
              },
            ),
          ],
        ),
      ),
    );

    expect(find.text('Select time'), findsOneWidget);
    expect(find.text('Caller time'), findsOneWidget);
    expect(find.semantics.byLabel('Clear time'), findsOneWidget);
    final selectedPicker = find.byKey(const ValueKey('selected-picker'));
    final englishTriggerClear = clearRegion(selectedPicker, 'Clear time');
    expect(englishTriggerClear, findsOneWidget);
    expect(
      tester
          .getSemantics(englishTriggerClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(englishTriggerClear, 'Clear time');
    await tester.pump();
    expect(triggerClearCalls, 1);
    expect(panelClearCalls, 0);

    await tester.tap(find.text('Select time'));
    await tester.pumpAndSettle();
    expect(find.text('Now'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.semantics.byLabel('0 hours\n00'), findsOneWidget);
    expect(find.semantics.byLabel('Clear time'), findsNWidgets(2));
    final englishPanelClear = clearRegion(
      find.byType(AnimalTimePickerPanel),
      'Clear time',
    );
    expect(englishPanelClear, findsOneWidget);
    expect(
      tester
          .getSemantics(englishPanelClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      tester
          .getSemantics(englishTriggerClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(englishPanelClear, 'Clear time');
    await tester.pump();
    expect(panelClearCalls, 1);
    expect(triggerClearCalls, 1);
    activateSemanticRegion(englishTriggerClear, 'Clear time');
    await tester.pump();
    expect(panelClearCalls, 1);
    expect(triggerClearCalls, 2);

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    expect(find.text('选择时间'), findsNWidgets(2));
    expect(find.text('Caller time'), findsOneWidget);
    expect(find.semantics.byLabel('清除时间'), findsNWidgets(2));
    expect(find.text('此刻'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
    expect(find.semantics.byLabel('0小时\n00'), findsOneWidget);
    final chineseTriggerClear = clearRegion(selectedPicker, '清除时间');
    final chinesePanelClear = clearRegion(
      find.byType(AnimalTimePickerPanel),
      '清除时间',
    );
    expect(chineseTriggerClear, findsOneWidget);
    expect(chinesePanelClear, findsOneWidget);
    expect(
      tester
          .getSemantics(chineseTriggerClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      tester
          .getSemantics(chinesePanelClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(chinesePanelClear, '清除时间');
    await tester.pump();
    expect(panelClearCalls, 2);
    expect(triggerClearCalls, 2);
    activateSemanticRegion(chineseTriggerClear, '清除时间');
    await tester.pump();
    expect(panelClearCalls, 2);
    expect(triggerClearCalls, 3);
    expect(find.text('Select time'), findsNothing);
    expect(find.text('Now'), findsNothing);
    expect(find.text('Clear'), findsNothing);
    expect(find.semantics.byLabel('Clear time'), findsNothing);
    expect(find.semantics.byLabel('0 hours\n00'), findsNothing);
    expect(find.semantics.byLabel('Select time'), findsNothing);
    semantics.dispose();
  });
}
