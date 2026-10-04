import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/src/components/date_picker/date_picker_panel.dart';
import 'package:animal_island_ui/src/internal/interaction/interactive_region.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C17 open date picker localizes prompts, calendar and actions', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    final selectedDate = AnimalDate(2024, 5, 6);
    var clearCalls = 0;

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
        child: SingleChildScrollView(
          child: Column(
            children: [
              AnimalDatePicker.popover(
                key: const ValueKey('date-picker'),
                selection: AnimalDateSelection.date(selectedDate),
                onChanged: (value) {
                  expect(value, isNull);
                  clearCalls++;
                },
                showToday: true,
                allowClear: true,
              ),
              AnimalDatePicker.popover(
                key: const ValueKey('empty-picker'),
                showToday: false,
                allowClear: false,
              ),
              AnimalDatePicker.popover(
                key: const ValueKey('empty-range-picker'),
                mode: AnimalDatePickerMode.range,
                showToday: false,
                allowClear: false,
              ),
              AnimalDatePicker.popover(
                key: const ValueKey('custom-placeholder-picker'),
                placeholder: 'Caller date',
                showToday: false,
                allowClear: false,
              ),
              AnimalDatePicker.popover(
                key: const ValueKey('month-picker'),
                selection: AnimalDateSelection.date(
                  AnimalDate(selectedDate.year, selectedDate.month, 1),
                ),
                mode: AnimalDatePickerMode.month,
                showToday: false,
                allowClear: false,
              ),
            ],
          ),
        ),
      ),
    );

    final dateTriggerFinder = find.byKey(const ValueKey('date-picker'));
    Finder panelText(String value) => find.descendant(
      of: find.byType(AnimalDatePickerPanel),
      matching: find.text(value),
    );
    final englishMaterialLocalizations = MaterialLocalizations.of(
      tester.element(dateTriggerFinder),
    );
    final englishDateLabel = englishMaterialLocalizations.formatMediumDate(
      DateTime.utc(2024, 5, 6),
    );
    expect(
      find.descendant(
        of: dateTriggerFinder,
        matching: find.text(englishDateLabel),
      ),
      findsOneWidget,
    );
    expect(find.text('Select date'), findsOneWidget);
    expect(find.text('Select date range'), findsOneWidget);
    expect(find.text('Caller date'), findsOneWidget);
    expect(find.semantics.byLabel('Clear date'), findsOneWidget);
    final englishTriggerClear = clearRegion(dateTriggerFinder, 'Clear date');
    expect(englishTriggerClear, findsOneWidget);
    expect(
      tester
          .getSemantics(englishTriggerClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(englishTriggerClear, 'Clear date');
    await tester.pump();
    expect(clearCalls, 1);
    expect(
      find.descendant(
        of: dateTriggerFinder,
        matching: find.text(englishDateLabel),
      ),
      findsOneWidget,
    );

    await tester.tap(dateTriggerFinder);
    await tester.pumpAndSettle();
    expect(
      panelText(
        englishMaterialLocalizations.formatMonthYear(DateTime.utc(2024, 5)),
      ),
      findsOneWidget,
    );
    expect(
      find.text(englishMaterialLocalizations.narrowWeekdays.first),
      findsNWidgets(
        englishMaterialLocalizations.narrowWeekdays
            .where(
              (day) => day == englishMaterialLocalizations.narrowWeekdays.first,
            )
            .length,
      ),
    );
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    final englishSelectedDate = englishMaterialLocalizations.formatFullDate(
      DateTime.utc(2024, 5, 6),
    );
    final englishSelectedDay = find.byWidgetPredicate(
      (widget) =>
          widget is InteractiveRegion &&
          widget.semanticLabel == englishSelectedDate,
    );
    expect(englishSelectedDay, findsOneWidget);
    expect(
      tester
          .getSemantics(englishSelectedDay)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      find.descendant(of: englishSelectedDay, matching: find.text('6')),
      findsOneWidget,
    );
    expect(find.semantics.byLabel('Previous year'), findsOneWidget);
    expect(find.semantics.byLabel('Next year'), findsOneWidget);
    expect(find.semantics.byLabel('Clear date'), findsNWidgets(2));
    final englishPanelClear = clearRegion(
      find.byType(AnimalDatePickerPanel),
      'Clear date',
    );
    expect(englishPanelClear, findsOneWidget);
    expect(
      tester
          .getSemantics(englishPanelClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(englishPanelClear, 'Clear date');
    await tester.pumpAndSettle();
    expect(clearCalls, 2);
    expect(
      panelText(
        englishMaterialLocalizations.formatMonthYear(DateTime.utc(2024, 5)),
      ),
      findsNothing,
    );
    await tester.tap(dateTriggerFinder);
    await tester.pumpAndSettle();

    controller.locale = const Locale('zh');
    await tester.pumpAndSettle();

    final chineseMaterialLocalizations = MaterialLocalizations.of(
      tester.element(dateTriggerFinder),
    );
    final chineseDateLabel = chineseMaterialLocalizations.formatMediumDate(
      DateTime.utc(2024, 5, 6),
    );
    expect(
      find.descendant(
        of: dateTriggerFinder,
        matching: find.text(chineseDateLabel),
      ),
      findsOneWidget,
    );
    expect(find.text('选择日期'), findsOneWidget);
    expect(find.text('选择日期范围'), findsOneWidget);
    expect(find.text('Caller date'), findsOneWidget);
    expect(find.semantics.byLabel('清除日期'), findsNWidgets(2));
    expect(
      panelText(
        chineseMaterialLocalizations.formatMonthYear(DateTime.utc(2024, 5)),
      ),
      findsOneWidget,
    );
    expect(
      find.text(chineseMaterialLocalizations.narrowWeekdays.first),
      findsNWidgets(
        chineseMaterialLocalizations.narrowWeekdays
            .where(
              (day) => day == chineseMaterialLocalizations.narrowWeekdays.first,
            )
            .length,
      ),
    );
    expect(find.text('今天'), findsOneWidget);
    expect(find.text('清空'), findsOneWidget);
    final chineseSelectedDate = chineseMaterialLocalizations.formatFullDate(
      DateTime.utc(2024, 5, 6),
    );
    final chineseSelectedDay = find.byWidgetPredicate(
      (widget) =>
          widget is InteractiveRegion &&
          widget.semanticLabel == chineseSelectedDate,
    );
    expect(chineseSelectedDay, findsOneWidget);
    expect(
      tester
          .getSemantics(chineseSelectedDay)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    expect(
      find.descendant(of: chineseSelectedDay, matching: find.text('6')),
      findsOneWidget,
    );
    expect(find.semantics.byLabel('上一年'), findsOneWidget);
    expect(find.semantics.byLabel('下一年'), findsOneWidget);

    final chinesePanelClear = clearRegion(
      find.byType(AnimalDatePickerPanel),
      '清除日期',
    );
    expect(chinesePanelClear, findsOneWidget);
    expect(
      tester
          .getSemantics(chinesePanelClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(chinesePanelClear, '清除日期');
    await tester.pumpAndSettle();
    expect(clearCalls, 3);
    final chineseTriggerClear = clearRegion(dateTriggerFinder, '清除日期');
    expect(chineseTriggerClear, findsOneWidget);
    expect(
      tester
          .getSemantics(chineseTriggerClear)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      isTrue,
    );
    activateSemanticRegion(chineseTriggerClear, '清除日期');
    await tester.pump();
    expect(clearCalls, 4);
    expect(find.text(englishDateLabel), findsNothing);
    expect(find.text('Select date'), findsNothing);
    expect(find.text('Select date range'), findsNothing);
    expect(find.semantics.byLabel('Clear date'), findsNothing);
    expect(find.text('Today'), findsNothing);
    expect(find.text('Clear'), findsNothing);
    expect(find.semantics.byLabel('Previous year'), findsNothing);
    expect(find.semantics.byLabel('Next year'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('month-picker')));
    await tester.pumpAndSettle();
    expect(find.text('5月'), findsOneWidget);
    semantics.dispose();
  });
}
