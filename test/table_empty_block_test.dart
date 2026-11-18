import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty slot hosts a block widget across the table width', (
    t,
  ) async {
    const block = ValueKey('block');
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: SizedBox(
            width: 480,
            child: IslandTable<String>(
              columns: [
                IslandTableColumn<String>(
                  id: 'name',
                  title: const Text('Name'),
                  cellBuilder: (_, record, _) => Text(record),
                ),
              ],
              rows: const [],
              rowKey: (record) => record,
              empty: const Column(
                key: block,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.inbox),
                  Text('暂无数据', textAlign: TextAlign.center),
                  Text('Add an island resident to get started'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Add an island resident to get started'), findsOneWidget);
    final table = t.getRect(find.byType(IslandTable<String>));
    final rect = t.getRect(find.byKey(block));
    expect(rect.width, greaterThan(table.width - 60));
    expect(rect.left, greaterThanOrEqualTo(table.left));
    expect(rect.right, lessThanOrEqualTo(table.right));
    expect(t.takeException(), isNull);
  });

  testWidgets('the loading spinner is the reference teal deepened to 3:1', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: SizedBox(
            width: 480,
            child: IslandTable<String>(
              columns: [
                IslandTableColumn<String>(
                  id: 'name',
                  title: const Text('Name'),
                  cellBuilder: (_, record, _) => Text(record),
                ),
              ],
              rows: const ['a'],
              rowKey: (record) => record,
              loading: true,
            ),
          ),
        ),
      ),
    );
    await t.pump();
    final spinner = find.byWidgetPredicate(
      (w) => w is CustomPaint && w.size == const Size(40, 40),
    );
    // Reference #19c8b9 is 1.9:1 on the loading surface; #039d91 is 3.02:1.
    expect(spinner, paints..arc(color: const Color(0xff039d91)));
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('custom empty content sits under the built-in 48px icon', (
    t,
  ) async {
    Future<void> pump(Widget? empty) => t.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: SizedBox(
            width: 480,
            child: IslandTable<String>(
              columns: [
                IslandTableColumn<String>(
                  id: 'name',
                  title: const Text('Name'),
                  cellBuilder: (_, record, _) => Text(record),
                ),
              ],
              rows: const [],
              rowKey: (record) => record,
              empty: empty,
            ),
          ),
        ),
      ),
    );
    await pump(null);
    final icon = find.byType(SvgPicture);
    expect(icon, findsOneWidget);
    final defaultText = t.getRect(find.text('No data'));
    expect(t.getSize(icon), const Size(48, 48));
    expect(defaultText.top - t.getRect(icon).bottom, closeTo(16, 0.01));

    await pump(const Text('写下今天的第一件小事。', key: ValueKey('custom')));
    expect(find.text('No data'), findsNothing);
    expect(icon, findsOneWidget);
    final custom = find.byKey(const ValueKey('custom'));
    expect(t.getRect(custom).top - t.getRect(icon).bottom, closeTo(16, 0.01));
    // Inherits the reference `.emptyContent` text: 14px muted, centred.
    final style = t.widget<RichText>(
      find.descendant(of: custom, matching: find.byType(RichText)),
    );
    expect(style.text.style?.fontSize, 14);
    expect(style.text.style?.color, IslandTokens.light.muted);
    expect(style.textAlign, TextAlign.center);
  });
}
