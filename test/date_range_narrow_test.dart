import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The reference range panel is 600 wide and, at 375, hangs off the left
  // edge of the page where the first month cannot be reached. Here the panel
  // stays inside the viewport and scrolls horizontally to the second month.
  testWidgets('a narrow range panel scrolls to its second month', (t) async {
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(375, 812);
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        locale: const Locale('zh'),
        localizationsDelegates: IslandLocalizations.delegates,
        supportedLocales: IslandLocalizations.supportedLocales,
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: IslandDatePicker.range(
              value: DateTimeRange(
                start: DateTime(2026, 9, 23),
                end: DateTime(2026, 10, 2),
              ),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await t.tap(find.byType(IslandDatePicker));
    await t.pumpAndSettle();
    final first = find.text('2026年9月'), second = find.text('2026年10月');
    expect(t.getRect(first).left, greaterThanOrEqualTo(0));
    expect(t.getRect(second).right, greaterThan(375));
    await t.drag(first, const Offset(-400, 0));
    await t.pumpAndSettle();
    final rect = t.getRect(second);
    expect(rect.left, greaterThanOrEqualTo(0));
    expect(rect.right, lessThanOrEqualTo(375));
    expect(t.takeException(), isNull);
  });
}
