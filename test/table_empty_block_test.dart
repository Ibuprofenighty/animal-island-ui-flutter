import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
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
}
