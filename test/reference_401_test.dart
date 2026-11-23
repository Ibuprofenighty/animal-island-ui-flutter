import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Behaviour taken from reference 4.0.1: uncontrolled Select, and accessible
// names that contain the visible text.
Widget host(Widget child, {Locale locale = const Locale('zh')}) => MaterialApp(
  locale: locale,
  localizationsDelegates: IslandLocalizations.delegates,
  supportedLocales: IslandLocalizations.supportedLocales,
  home: Scaffold(
    body: Padding(padding: const EdgeInsets.all(20), child: child),
  ),
);

const options = [
  IslandOption(value: 'a', label: 'Apple'),
  IslandOption(value: 'b', label: 'Berry'),
];

Finder named(String label) => find.byWidgetPredicate(
  (w) => w is Semantics && w.properties.label == label,
);

void main() {
  testWidgets('uncontrolled Select owns its value, reports it and clears', (
    t,
  ) async {
    final changes = <String?>[];
    var cleared = 0;
    await t.pumpWidget(
      host(
        IslandSelect<String>.uncontrolled(
          options: options,
          initialValue: 'a',
          onChanged: changes.add,
          allowClear: true,
          onClear: () => cleared++,
        ),
      ),
    );
    expect(find.text('Apple'), findsOneWidget);
    await t.tap(find.text('Apple'));
    await t.pumpAndSettle();
    await t.tap(find.text('Berry'));
    await t.pumpAndSettle();
    expect(changes, ['b']);
    expect(find.text('Berry'), findsOneWidget);
    expect(find.text('Apple'), findsNothing);

    await t.tap(find.text('Berry'));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('清除'));
    await t.pumpAndSettle();
    expect(changes, ['b', null]);
    expect(cleared, 1);
    expect(find.text('请选择'), findsOneWidget);
  });

  testWidgets('uncontrolled Select works without onChanged and ignores a '
      'later initialValue', (t) async {
    Widget build(String? initial) => host(
      IslandSelect<String>.uncontrolled(
        options: options,
        initialValue: initial,
      ),
    );
    await t.pumpWidget(build(null));
    await t.tap(find.text('请选择'));
    await t.pumpAndSettle();
    await t.tap(find.text('Apple'));
    await t.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);
    await t.pumpWidget(build('b'));
    await t.pumpAndSettle();
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Berry'), findsNothing);
  });

  testWidgets('uncontrolled searchable Select echoes the chosen label', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        IslandSelect<String>.uncontrolled(
          options: options,
          showSearch: true,
          allowClear: true,
        ),
      ),
    );
    await t.tap(find.byType(EditableText));
    await t.pumpAndSettle();
    await t.tap(find.text('Berry'));
    await t.pumpAndSettle();
    expect(
      t.widget<EditableText>(find.byType(EditableText)).controller.text,
      'Berry',
    );
    await t.tap(find.byType(EditableText));
    await t.pumpAndSettle();
    await t.tap(find.bySemanticsLabel('清除'));
    await t.pumpAndSettle();
    expect(
      t.widget<EditableText>(find.byType(EditableText)).controller.text,
      '',
    );
  });

  testWidgets('the Upload trigger name contains its visible hint', (t) async {
    Widget upload({bool drag = false, Widget? child, String? label}) => host(
      IslandUpload.uncontrolled(
        pickFiles: ({required multiple, required accept}) async => const [],
        request: (_) => throw UnimplementedError(),
        drag: drag,
        label: label,
        child: child,
      ),
    );
    await t.pumpWidget(upload());
    expect(named('上传文件，点击上传'), findsOneWidget);
    await t.pumpWidget(upload(drag: true));
    expect(named('上传文件，点击或拖拽文件到这里'), findsOneWidget);
    await t.pumpWidget(upload(child: const Text('选择')));
    expect(named('上传文件'), findsOneWidget);
    await t.pumpWidget(upload(label: '附件'));
    expect(named('附件'), findsOneWidget);
    await t.pumpWidget(
      host(
        IslandUpload.uncontrolled(
          pickFiles: ({required multiple, required accept}) async => const [],
          request: (_) => throw UnimplementedError(),
        ),
        locale: const Locale('en'),
      ),
    );
    expect(named('Upload file, click to upload'), findsOneWidget);
  });

  testWidgets('the page-size button name contains its visible text', (t) async {
    Widget pagination(Locale locale) => host(
      const IslandPagination.uncontrolled(total: 200, showSizeChanger: true),
      locale: locale,
    );
    await t.pumpWidget(pagination(const Locale('zh')));
    expect(named('每页 10 条，10 条/页'), findsOneWidget);
    await t.pumpWidget(pagination(const Locale('en')));
    await t.pumpAndSettle();
    expect(named('10 per page, 10 / page'), findsOneWidget);
  });

  testWidgets('a notification is a live region outside the Web engine', (
    t,
  ) async {
    final controller = IslandNotificationsController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      host(
        IslandNotifications(
          controller: controller,
          child: const SizedBox.expand(),
        ),
      ),
    );
    controller.show(
      const IslandNotification(
        message: Text('保存失败'),
        type: IslandNotificationType.error,
        duration: Duration.zero,
      ),
    );
    await t.pumpAndSettle();
    final region = find.ancestor(
      of: find.text('保存失败'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.liveRegion == true,
      ),
    );
    expect(region, findsOneWidget);
    expect(t.widget<Semantics>(region).properties.role, isNull);
  });
}
