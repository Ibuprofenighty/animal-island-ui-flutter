import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/localization_app.dart';

void main() {
  testWidgets('C31 table empty and loading labels follow the mounted locale', (
    tester,
  ) async {
    final controller = LocalizationTestController();
    addTearDown(controller.dispose);
    Widget table({bool loading = false, Widget? emptyWidget}) => SizedBox(
      width: 200,
      height: 250,
      child: AnimalTable(
        rowKey: (index) => ValueKey('row-$index'),
        columns: [AnimalTableColumn(title: 'Name', width: 150)],
        rowCount: 0,
        loading: loading,
        emptyWidget: emptyWidget,
        maxHeight: 250,
        rowBuilder: (_, _) => const <Widget>[],
      ),
    );

    await tester.pumpWidget(
      AnimalLocalizationTestApp(
        controller: controller,
        child: Scaffold(
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              table(loading: true),
              table(),
              table(emptyWidget: const Text('Caller empty state')),
            ],
          ),
        ),
      ),
    );
    final english = AnimalLocalizations.of(
      tester.element(find.byType(AnimalTable).first),
    )!;
    final englishLoading = find.bySemanticsLabel(english.tableLoadingLabel);
    expect(englishLoading, findsOneWidget);
    expect(
      tester.getSemantics(englishLoading).label,
      english.tableLoadingLabel,
    );
    expect(
      tester.getSemantics(find.text('Caller empty state')).label,
      'Caller empty state',
    );
    expect(find.text('No Data'), findsOneWidget);
    expect(find.text('Caller empty state'), findsOneWidget);

    controller.locale = const Locale('zh');
    await tester.pump();

    final chinese = AnimalLocalizations.of(
      tester.element(find.byType(AnimalTable).first),
    )!;
    final chineseLoading = find.bySemanticsLabel(chinese.tableLoadingLabel);
    expect(chineseLoading, findsOneWidget);
    expect(
      tester.getSemantics(chineseLoading).label,
      chinese.tableLoadingLabel,
    );
    expect(
      tester.getSemantics(find.text('Caller empty state')).label,
      'Caller empty state',
    );
    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.text('Caller empty state'), findsOneWidget);
  });
}
