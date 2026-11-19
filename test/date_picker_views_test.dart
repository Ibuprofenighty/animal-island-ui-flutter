import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import 'date_picker_test.dart' show choose, host;

void main() {
  // Reference DatePicker: the footer renders for the day view and for the
  // month view of a month picker only; MONTHS reads 一月…十二月 with the
  // accessible name `N月`.
  testWidgets('month and year views reached from the header have no footer; '
      'month cells read 一月…十二月', (t) async {
    await t.pumpWidget(
      host(IslandDatePicker.uncontrolled(initialValue: DateTime(2026, 8, 10))),
    );
    await choose(t, '选择日期');
    expect(find.text('确定'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);

    await choose(t, '2026年8月');
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('确定'), findsNothing);
    expect(find.text('今天'), findsNothing);

    await choose(t, '2028年');
    expect(find.text('一月'), findsOneWidget);
    expect(find.text('十二月'), findsOneWidget);
    expect(find.text('8月'), findsNothing);
    expect(find.bySemanticsLabel('8月'), findsOneWidget);
    expect(find.text('确定'), findsNothing);
    expect(find.text('今天'), findsNothing);

    await choose(t, '3月');
    expect(find.text('确定'), findsOneWidget);
    expect(find.text('今天'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('a month picker keeps the footer in its month view', (t) async {
    await t.pumpWidget(
      host(
        IslandDatePicker.uncontrolled(
          mode: IslandDatePickerMode.month,
          initialValue: DateTime(2026, 8),
        ),
      ),
    );
    await choose(t, '选择日期');
    expect(find.text('八月'), findsOneWidget);
    expect(find.text('确定'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
