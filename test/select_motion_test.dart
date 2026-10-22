import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host({bool reduced = false}) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Scaffold(
        body: Center(
          child: IslandSelect<String>(
            options: const [IslandOption(value: 'a', label: 'Apple')],
            value: null,
            onChanged: (_) {},
          ),
        ),
      ),
    ),
  );
  double opacity(WidgetTester t) => t
      .widgetList<Opacity>(
        find.ancestor(of: find.text('Apple'), matching: find.byType(Opacity)),
      )
      .fold(1.0, (value, widget) => value * widget.opacity);

  testWidgets(
    'Select stays opaque without translation through entry and immediate exit',
    (t) async {
      await t.pumpWidget(host());
      await t.tap(find.text('请选择'));
      await t.pump();
      await t.pump();
      final initial = t.getTopLeft(find.text('Apple'));
      expect(opacity(t), 1);
      await t.pump(const Duration(milliseconds: 100));
      expect(opacity(t), 1);
      expect(t.getTopLeft(find.text('Apple')), initial);
      await t.pump(const Duration(milliseconds: 100));
      expect(opacity(t), 1);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump();
      await t.pump();
      expect(find.text('Apple'), findsNothing);
    },
  );

  testWidgets(
    'Select interruption and disposal cancel pending panel lifecycle',
    (t) async {
      await t.pumpWidget(host());
      await t.tap(find.text('请选择'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 40));
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump();
      await t.pump(const Duration(milliseconds: 10));
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
      expect(opacity(t), 1);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump();
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(milliseconds: 300));
      expect(t.takeException(), isNull);
      expect(find.text('Apple'), findsNothing);
    },
  );

  testWidgets('Select reduced motion opens and closes immediately', (t) async {
    await t.pumpWidget(host(reduced: true));
    await t.tap(find.text('请选择'));
    await t.pump();
    await t.pump();
    expect(opacity(t), 1);
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pump();
    await t.pump();
    expect(find.text('Apple'), findsNothing);
  });
  testWidgets(
    'Select hover arrow keeps reference 10 by 14 geometry outside panel',
    (t) async {
      await t.pumpWidget(host());
      await t.tap(find.text('请选择'));
      await t.pumpAndSettle();
      final pointer = await t.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      await pointer.moveTo(t.getCenter(find.text('Apple')));
      await t.pumpAndSettle();
      final arrow = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.size == const Size(10, 14),
      );
      expect(arrow, findsOneWidget);
      final row = find
          .ancestor(of: find.text('Apple'), matching: find.byType(MouseRegion))
          .first;
      final rowRect = t.getRect(row);
      final arrowRect = t.getRect(arrow);
      expect(arrowRect.left, rowRect.left - 14);
      expect(arrowRect.center.dy, rowRect.center.dy);
      expect(
        t.widget<Text>(find.text('Apple')).style!.fontWeight,
        FontWeight.w700,
      );
      await pointer.moveTo(Offset.zero);
      await t.pumpAndSettle();
      expect(arrow, findsNothing);
      expect(
        t.widget<Text>(find.text('Apple')).style!.fontWeight,
        FontWeight.w500,
      );
      await pointer.removePointer();
    },
  );
}
