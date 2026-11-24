import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'chart_test.dart' show chartHost;

void main() {
  // Component default copy comes from IslandLocalizations: the reference
  // Chinese strings under a zh locale, English otherwise and when the host
  // registers no delegate.
  Widget host(Widget child, {Locale? locale}) => MaterialApp(
    locale: locale,
    supportedLocales: IslandLocalizations.supportedLocales,
    localizationsDelegates: locale == null
        ? null
        : IslandLocalizations.delegates,
    theme: IslandTheme.create(),
    home: Scaffold(body: Center(child: child)),
  );

  Widget fields() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IslandSelect<int>(
        options: const [IslandOption(value: 1, label: 'One')],
        value: null,
        onChanged: (_) {},
      ),
      IslandDatePicker(value: null, onChanged: (_) {}),
      IslandTimePicker(value: null, onChanged: (_) {}),
      const IslandCodeBlock(code: 'a'),
    ],
  );

  testWidgets('default copy is the reference Chinese under a zh locale', (
    t,
  ) async {
    await t.pumpWidget(host(fields(), locale: const Locale('zh')));
    for (final text in ['请选择', '请选择日期', '请选择时间', '复制']) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    await t.tap(find.text('请选择日期'));
    await t.pumpAndSettle();
    for (final text in ['今天', '确定', '日', '2026年${DateTime.now().month}月']) {
      if (text.startsWith('2026') && DateTime.now().year != 2026) continue;
      expect(find.text(text), findsOneWidget, reason: text);
    }
  });

  for (final locale in [const Locale('en'), null]) {
    testWidgets('default copy is English under ${locale ?? 'no delegate'}', (
      t,
    ) async {
      await t.pumpWidget(host(fields(), locale: locale));
      for (final text in [
        'Please select',
        'Select date',
        'Select time',
        'Copy',
      ]) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      await t.tap(find.text('Select date'));
      await t.pumpAndSettle();
      for (final text in ['Today', 'OK', 'Su', 'Sa']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(t.takeException(), isNull);
      await t.tapAt(const Offset(2, 2));
      await t.pumpAndSettle();
      await t.tap(find.text('Select time'));
      await t.pumpAndSettle();
      for (final text in ['Hour', 'Min', 'Sec', 'Now', 'OK']) {
        expect(find.text(text), findsOneWidget, reason: text);
      }
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('a caller string replaces the localized default', (t) async {
    await t.pumpWidget(
      host(
        IslandSelect<int>(
          options: const [IslandOption(value: 1, label: 'One')],
          value: null,
          onChanged: (_) {},
          placeholder: 'Pick a fruit',
        ),
        locale: const Locale('zh'),
      ),
    );
    expect(find.text('Pick a fruit'), findsOneWidget);
    expect(find.text('请选择'), findsNothing);
  });

  testWidgets('the default Modal actions follow the locale', (t) async {
    for (final (locale, labels) in [
      (const Locale('zh'), ['取消', '确定']),
      (const Locale('en'), ['Cancel', 'OK']),
    ]) {
      late BuildContext context;
      await t.pumpWidget(
        host(
          Builder(
            builder: (c) {
              context = c;
              return const SizedBox();
            },
          ),
          locale: locale,
        ),
      );
      showIslandModal<void>(
        context: context,
        builder: (_) => const Text('body'),
      );
      await t.pumpAndSettle();
      for (final label in labels) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      await t.tap(find.text(labels.last));
      await t.pumpAndSettle();
    }
  });

  testWidgets('the Chart default number format uses the units of the locale', (
    t,
  ) async {
    for (final (locale, summary, value) in [
      (const Locale('zh'), '查看数据（1）', '1.2万'),
      (const Locale('en'), 'View data (1)', '12K'),
    ]) {
      await t.pumpWidget(
        chartHost(
          IslandChart(
            key: ValueKey(locale),
            data: IslandChartData.column(
              categories: const ['A'],
              series: [
                IslandChartSeries.values('S', [12000]),
              ],
            ),
          ),
          locale: locale,
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text(summary));
      await t.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(Table), matching: find.text(value)),
        findsOneWidget,
        reason: value,
      );
    }
  });

  testWidgets('Drawer body and footer follow the text direction', (t) async {
    for (final rtl in [false, true]) {
      await t.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create(),
          home: Directionality(
            textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
            child: IslandDrawerHost(
              child: Scaffold(
                body: IslandDrawer(
                  key: ValueKey(rtl),
                  open: true,
                  onClose: () {},
                  title: const Text('Panel'),
                  footer: const Text('Footer'),
                  child: const Text('Body'),
                ),
              ),
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final body = t.getRect(find.text('Body'));
      final footer = t.getRect(find.text('Footer'));
      // The body starts and the footer ends on the reading edges; both sit
      // 24px inside the panel.
      if (rtl) {
        expect(footer.left, lessThan(body.left));
        expect(body.right - footer.left, greaterThan(200));
      } else {
        expect(footer.right, greaterThan(body.right));
        expect(footer.right - body.left, greaterThan(200));
      }
    }
  });
}
