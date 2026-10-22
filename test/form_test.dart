import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 400, child: child)),
);
void main() {
  testWidgets('mixed-script labels use the reference fixed line box', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        const IslandForm(
          layout: IslandFormLayout.vertical,
          children: [IslandFormTextField(name: 'name', label: '用户名 Name')],
        ),
      ),
    );
    final label = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          (w.textSpan?.toPlainText().startsWith('用户名 Name') ?? false),
    );
    expect(
      t
          .getSize(
            find
                .ancestor(of: label, matching: find.byType(GestureDetector))
                .first,
          )
          .height,
      closeTo(22.4, .01),
    );
  });

  testWidgets(
    'labels focus the explicit text adapter and preserve borrowed nodes',
    (t) async {
      final first = FocusNode(), second = FocusNode();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      Future<void> show(FocusNode? focus, {bool disabled = false}) async {
        await t.pumpWidget(
          host(
            IslandForm(
              layout: IslandFormLayout.vertical,
              disabled: disabled,
              children: [
                IslandFormTextField(
                  name: 'name',
                  label: 'Name',
                  focusNode: focus,
                ),
              ],
            ),
          ),
        );
        await t.pump();
      }

      Future<void> label() async {
        await t.tap(
          find.byWidgetPredicate(
            (w) =>
                w is Text &&
                (w.textSpan?.toPlainText().startsWith('Name') ?? false),
          ),
        );
        await t.pump();
      }

      await show(first);
      await label();
      expect(first.hasFocus, isTrue);
      await show(second);
      await label();
      expect(second.hasFocus, isTrue);
      expect(first.hasFocus, isFalse);
      second.unfocus();
      await show(second, disabled: true);
      await label();
      expect(second.hasFocus, isFalse);
      await show(null);
      await label();
      expect(
        t.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
        isTrue,
      );
      await t.pumpWidget(const SizedBox());
      expect(() => first.addListener(() {}), returnsNormally);
      expect(() => second.addListener(() {}), returnsNormally);
    },
  );

  testWidgets(
    'text adapter supports atomic fill/reset and child actions submit once',
    (t) async {
      final c = IslandFormController(
        initialValues: {'name': '', 'fruit': 'apple'},
      );
      addTearDown(c.dispose);
      var submits = 0, changes = 0;
      await t.pumpWidget(
        host(
          IslandForm(
            controller: c,
            layout: IslandFormLayout.vertical,
            onFinish: (_) => submits++,
            onValuesChanged: (_, all) => changes++,
            children: [
              const IslandFormTextField(name: 'name', label: 'Name'),
              const IslandFormTextField(name: 'fruit', label: 'Fruit'),
              Builder(
                builder: (context) => IslandButton(
                  onPressed: () => IslandForm.of(context).submit(),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      );
      c.setValues({'name': 'Mochi', 'fruit': 'orange'});
      await t.pump();
      expect(find.text('Mochi'), findsOneWidget);
      expect(find.text('orange'), findsOneWidget);
      expect(changes, 0);
      await t.enterText(find.byType(TextField).first, 'Edited');
      await t.pumpAndSettle();
      expect(c.value<String>('name'), 'Edited');
      expect(changes, 1);
      await t.tap(find.text('Submit'));
      await t.pumpAndSettle();
      expect(submits, 1);
      c.reset();
      await t.pump();
      expect(c.value<String>('name'), '');
      expect(find.text('apple'), findsOneWidget);
      expect(c.isTouched('name'), isFalse);
      expect(c.errors('name'), isEmpty);
      expect(() => c.values['name'] = 'Illegal', throwsUnsupportedError);
    },
  );
  testWidgets(
    'new value supersedes pending validation and submission snapshot',
    (t) async {
      final pending = Completer<String?>();
      final c = IslandFormController(initialValues: {'name': 'old'});
      addTearDown(c.dispose);
      final submitted = <Map<String, Object?>>[];
      await t.pumpWidget(
        host(
          IslandForm(
            controller: c,
            children: [
              IslandFormTextField(
                name: 'name',
                label: 'Name',
                validators: [(v, _) => v == 'old' ? pending.future : null],
              ),
            ],
            onFinish: submitted.add,
          ),
        ),
      );
      final validation = c.submit();
      await t.pump();
      expect(c.isValidating('name'), isTrue);
      c.setValues({'name': 'new'});
      await t.pump();
      pending.complete('Stale error');
      final result = await validation;
      await t.pump();
      expect(result.outOfDate, isTrue);
      expect(c.errors('name'), isEmpty);
      expect(submitted, isEmpty);
      await c.submit();
      await t.pump();
      expect(submitted.single['name'], 'new');
    },
  );
  for (final operation in ['reset', 'remove', 'dispose']) {
    testWidgets('$operation invalidates a pending validator', (t) async {
      final pending = Completer<String?>();
      final c = IslandFormController(initialValues: {'name': 'old'});
      var finishes = 0;
      await t.pumpWidget(
        host(
          IslandForm(
            controller: c,
            onFinish: (_) => finishes++,
            onFinishFailed: (_) => finishes++,
            children: [
              IslandFormTextField(
                name: 'name',
                label: 'Name',
                validators: [(_, _) => pending.future],
              ),
            ],
          ),
        ),
      );
      final result = c.submit();
      await t.pump();
      if (operation == 'reset') {
        c.reset();
        await t.pump();
      } else if (operation == 'remove') {
        await t.pumpWidget(host(IslandForm(controller: c, children: const [])));
      } else {
        await t.pumpWidget(const SizedBox());
        c.dispose();
      }
      pending.complete('Old error');
      expect((await result).outOfDate, isTrue);
      await t.pump();
      expect(finishes, 0);
      expect(t.takeException(), isNull);
      if (operation != 'dispose') {
        expect(c.errors('name'), isEmpty);
        c.dispose();
      }
    });
  }
  testWidgets(
    'dependent validation, normalizing to null and explicit child overrides',
    (t) async {
      final c = IslandFormController(
        initialValues: {'password': 'abc', 'confirm': 'abc', 'value': 'old'},
      );
      addTearDown(c.dispose);
      late IslandFormBinding<String> binding;
      await t.pumpWidget(
        host(
          IslandForm(
            controller: c,
            disabled: true,
            children: [
              const IslandFormTextField(name: 'password', label: 'Password'),
              IslandFormTextField(
                name: 'confirm',
                label: 'Confirm',
                dependencies: const ['password'],
                validators: [
                  (v, all) => v == all['password'] ? null : 'Mismatch',
                ],
              ),
              IslandFormField<String>(
                name: 'value',
                enabled: true,
                size: IslandSize.small,
                normalize: (_, _, _) => null,
                builder: (context, b) {
                  binding = b;
                  return const Text('Custom editor');
                },
              ),
            ],
          ),
        ),
      );
      expect(binding.enabled, isTrue);
      expect(binding.size, IslandSize.small);
      binding.onChanged('clear');
      await t.pumpAndSettle();
      expect(c.values['value'], isNull);
      c.setValues({'password': 'different'}, userInitiated: true);
      await t.pumpAndSettle();
      expect(c.errors('confirm'), ['Mismatch']);
      expect(find.text('Mismatch'), findsOneWidget);
    },
  );
  testWidgets(
    'keyed fields keep editors on reorder and replacement detaches borrowed controller',
    (t) async {
      final a = IslandFormController(initialValues: {'a': 'A', 'b': 'B'});
      final b = IslandFormController(
        initialValues: {'a': 'Next', 'b': 'Other'},
      );
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      var reverse = false, useNext = false, submits = 0;
      late StateSetter change;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) {
              change = set;
              return IslandForm(
                controller: useNext ? b : a,
                onFinish: (_) => submits++,
                children: [
                  for (final name in reverse ? ['b', 'a'] : ['a', 'b'])
                    IslandFormTextField(
                      key: ValueKey(name),
                      name: name,
                      label: name,
                    ),
                ],
              );
            },
          ),
        ),
      );
      final editor = t.state(find.byType(EditableText).first);
      change(() => reverse = true);
      await t.pump();
      expect(t.state(find.byType(EditableText).last), same(editor));
      change(() => useNext = true);
      await t.pump();
      expect(find.text('Next'), findsOneWidget);
      await a.submit();
      expect(submits, 0);
      await b.submit();
      expect(submits, 1);
    },
  );
  testWidgets(
    'reentrant completion listener cannot submit an obsolete snapshot',
    (t) async {
      final c = IslandFormController(initialValues: {'name': 'before'});
      addTearDown(c.dispose);
      var finish = 0, armed = false;
      await t.pumpWidget(
        host(
          IslandForm(
            controller: c,
            onFinish: (_) => finish++,
            children: const [IslandFormTextField(name: 'name', label: 'Name')],
          ),
        ),
      );
      c.addListener(() {
        if (armed && !c.isValidating('name')) {
          armed = false;
          c.setValues({'name': 'after'});
        }
      });
      armed = true;
      final result = await c.submit();
      await t.pump();
      expect(result.outOfDate, isTrue);
      expect(finish, 0);
      expect(c.value<String>('name'), 'after');
    },
  );
  testWidgets(
    'duplicate names fail explicitly instead of sharing child metadata',
    (t) async {
      final oldErrorBuilder = ErrorWidget.builder;
      ErrorWidget.builder = (_) => const SizedBox.shrink();
      addTearDown(() => ErrorWidget.builder = oldErrorBuilder);
      await t.pumpWidget(
        host(
          const IslandForm(
            children: [
              IslandFormTextField(name: 'same', label: 'One'),
              IslandFormTextField(name: 'same', label: 'Two'),
            ],
          ),
        ),
      );
      expect(t.takeException(), isFlutterError);
      await t.pumpWidget(const SizedBox());
      await t.pump();
      ErrorWidget.builder = oldErrorBuilder;
    },
  );
}
