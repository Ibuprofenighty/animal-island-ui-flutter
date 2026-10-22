import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final date in [true, false]) {
    Widget picker() => date
        ? IslandDatePicker.uncontrolled(
            label: 'Picker',
            initialValue: DateTime(2026, 8, 10),
            allowClear: true,
          )
        : const IslandTimePicker.uncontrolled(
            label: 'Picker',
            initialValue: IslandTimeValue(0, 0),
            allowClear: true,
          );
    Widget host(Widget child) => MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: IslandLocalizations.delegates,
      supportedLocales: IslandLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    );
    testWidgets(
      '${date ? 'Date' : 'Time'} clear action excludes its decorative glyph',
      (tester) async {
        final semantics = tester.ensureSemantics();
        try {
          await tester.pumpWidget(host(picker()));
          expect(find.bySemanticsLabel(date ? '清除日期' : '清除时间'), findsOneWidget);
        } finally {
          semantics.dispose();
        }
      },
    );
    testWidgets('${date ? 'Date' : 'Time'} picker action names occur once', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(host(picker()));
        await tester.tap(
          find.bySemanticsLabel(RegExp(r'^Picker(?:\n|$)')).first,
        );
        await tester.pumpAndSettle();
        expect(find.bySemanticsLabel('确定'), findsOneWidget);
        expect(find.bySemanticsLabel(date ? '今天' : '此刻'), findsOneWidget);
        if (!date) {
          expect(find.bySemanticsLabel('0 时'), findsOneWidget);
          expect(find.bySemanticsLabel('0 分'), findsOneWidget);
          expect(find.bySemanticsLabel('0 秒'), findsOneWidget);
        }
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      } finally {
        semantics.dispose();
      }
    });
  }
  testWidgets('Input clear action excludes its decorative glyph', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController(text: 'Island');
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IslandTextField(
              label: 'Name',
              controller: controller,
              allowClear: true,
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('清空'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('清空'));
      expect(controller.text, isEmpty);
      await tester.pumpWidget(const SizedBox());
    } finally {
      controller.dispose();
      semantics.dispose();
    }
  });
}
