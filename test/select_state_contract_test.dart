import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

const options = [
  IslandOption(value: 'a', label: 'Apple'),
  IslandOption(value: 'b', label: 'Berry'),
];
Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);
void main() {
  testWidgets(
    'Search editable semantic owner stays named and stable across panel updates',
    (t) async {
      final semantics = t.ensureSemantics();
      try {
        await t.pumpWidget(
          host(
            IslandSelect<String>(
              label: 'Fish search',
              showSearch: true,
              value: null,
              onChanged: (_) {},
              options: options,
            ),
          ),
        );
        SemanticsNode editable() {
          final found = <SemanticsNode>[];
          void visit(SemanticsNode n) {
            if (n.getSemanticsData().flagsCollection.isTextField) found.add(n);
            n.visitChildren((child) {
              visit(child);
              return true;
            });
          }

          visit(
            t
                .binding
                .renderViews
                .single
                .owner!
                .semanticsOwner!
                .rootSemanticsNode!,
          );
          return found.single;
        }

        final id = editable().id;
        void check() {
          expect(editable().id, id);
          expect(editable().getSemanticsData().label, contains('Fish search'));
        }

        check();
        await t.tap(find.byType(TextField));
        await t.pumpAndSettle();
        check();
        await t.enterText(find.byType(TextField), 'B');
        await t.pumpAndSettle();
        check();
        await t.tapAt(const Offset(5, 5));
        await t.pumpAndSettle();
        check();
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'Select preserves the Tab destination through closing scope blur',
    (t) async {
      final trigger = FocusNode();
      final requests = <String?>[];
      try {
        await t.pumpWidget(
          host(
            IslandSelect<String>(
              options: options,
              value: 'a',
              onChanged: requests.add,
              focusNode: trigger,
              allowClear: true,
            ),
          ),
        );
        await t.tap(find.text('Apple'));
        await t.pumpAndSettle();
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        await t.pump();
        expect(trigger.hasPrimaryFocus, isFalse);
        FocusManager.instance.rootScope.requestScopeFocus();
        await t.pumpAndSettle();
        await t.sendKeyEvent(LogicalKeyboardKey.enter);
        await t.pumpAndSettle();
        expect(requests, [null]);
        expect(find.text('Berry'), findsNothing);
        await t.pumpWidget(const SizedBox.shrink());
      } finally {
        trigger.dispose();
      }
    },
  );

  testWidgets('Select does not recover presentation focus in an inactive app', (
    t,
  ) async {
    final trigger = FocusNode();
    final semantics = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          IslandSelect<String>(
            options: options,
            value: 'a',
            allowClear: true,
            onChanged: (_) {},
            focusNode: trigger,
          ),
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pump();
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      FocusManager.instance.rootScope.requestScopeFocus();
      await t.pumpAndSettle();
      expect(trigger.hasFocus, isFalse);
      expect(find.bySemanticsLabel('清除'), findsNothing);
      expect(
        FocusManager.instance.primaryFocus,
        same(FocusManager.instance.rootScope),
      );
      await t.pumpWidget(const SizedBox.shrink());
    } finally {
      t.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      semantics.dispose();
      trigger.dispose();
    }
  });
  for (final externalWins in [false, true]) {
    testWidgets(
      externalWins
          ? 'Select closing respects an explicit external control focus'
          : 'Select restores trigger after closing scope blur',
      (t) async {
        final trigger = FocusNode(), external = FocusNode();
        try {
          await t.pumpWidget(
            host(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IslandSelect<String>(
                    options: options,
                    value: 'a',
                    onChanged: (_) {},
                    focusNode: trigger,
                  ),
                  TextField(focusNode: external),
                ],
              ),
            ),
          );
          await t.tap(find.text('Apple'));
          await t.pumpAndSettle();
          await t.sendKeyEvent(LogicalKeyboardKey.escape);
          await t.pump();
          if (externalWins) {
            external.requestFocus();
          } else {
            FocusManager.instance.rootScope.requestScopeFocus();
          }
          await t.pumpAndSettle();
          expect(trigger.hasPrimaryFocus, !externalWins);
          expect(external.hasPrimaryFocus, externalWins);
          expect(find.text('Berry'), findsNothing);
          await t.pumpWidget(const SizedBox.shrink());
        } finally {
          trigger.dispose();
          external.dispose();
        }
      },
    );
  }

  testWidgets('Select completes keyboard selection after opening scope blur', (
    t,
  ) async {
    final semantics = t.ensureSemantics();
    final focus = FocusNode();
    final requests = <String?>[];
    String? value = 'a';
    try {
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, update) => IslandSelect<String>(
              options: options,
              value: value,
              focusNode: focus,
              onChanged: (next) => update(() {
                requests.add(next);
                value = next;
              }),
            ),
          ),
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pump();
      // The live Web portal reparents semantic ancestors during opening,
      // moving focus to the root scope before the overlay has settled.
      FocusManager.instance.rootScope.requestScopeFocus();
      await t.pump();
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(requests, ['b']);
      expect(value, 'b');
      expect(find.text('Berry'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);
      expect(focus.hasPrimaryFocus, isTrue);
      await t.pumpWidget(const SizedBox.shrink());
    } finally {
      semantics.dispose();
      focus.dispose();
    }
  });

  testWidgets(
    'Select opening never steals an explicit external control focus',
    (t) async {
      final trigger = FocusNode(), external = FocusNode();
      try {
        await t.pumpWidget(
          host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IslandSelect<String>(
                  options: options,
                  value: 'a',
                  onChanged: (_) => fail('External keyboard must not select'),
                  focusNode: trigger,
                ),
                TextField(focusNode: external),
              ],
            ),
          ),
        );
        await t.tap(find.text('Apple'));
        await t.pump();
        external.requestFocus();
        await t.pumpAndSettle();
        expect(external.hasPrimaryFocus, isTrue);
        expect(trigger.hasFocus, isFalse);
        await t.sendKeyEvent(LogicalKeyboardKey.enter);
        await t.pumpAndSettle();
        expect(external.hasPrimaryFocus, isTrue);
        await t.pumpWidget(const SizedBox.shrink());
      } finally {
        trigger.dispose();
        external.dispose();
      }
    },
  );

  for (final interruption in ['close', 'disable', 'replace-focus', 'unmount']) {
    testWidgets('Select preserves external focus on $interruption', (t) async {
      final first = FocusNode(),
          replacement = FocusNode(),
          external = FocusNode();
      var disabled = false, replace = false;
      late StateSetter update;
      try {
        await t.pumpWidget(
          host(
            StatefulBuilder(
              builder: (_, set) {
                update = set;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IslandSelect<String>(
                      options: options,
                      value: 'a',
                      onChanged: (_) {},
                      disabled: disabled,
                      focusNode: replace ? replacement : first,
                    ),
                    TextField(focusNode: external),
                  ],
                );
              },
            ),
          ),
        );
        await t.tap(find.text('Apple'));
        await t.pump();
        switch (interruption) {
          case 'close':
            await t.tapAt(Offset.zero);
          case 'disable':
            update(() => disabled = true);
          case 'replace-focus':
            update(() => replace = true);
          case 'unmount':
            await t.pumpWidget(host(TextField(focusNode: external)));
        }
        external.requestFocus();
        await t.pumpAndSettle();
        expect(external.hasPrimaryFocus, isTrue);
        expect(first.hasFocus, isFalse);
        expect(replacement.hasFocus, isFalse);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox.shrink());
        void listener() {}
        first.addListener(listener);
        first.removeListener(listener);
        replacement.addListener(listener);
        replacement.removeListener(listener);
      } finally {
        first.dispose();
        replacement.dispose();
        external.dispose();
      }
    });
  }

  testWidgets('Select never recovers focus from a caller-owned scope', (
    t,
  ) async {
    final node = FocusNode();
    final scope = FocusScopeNode();
    final requests = <String?>[];
    try {
      await t.pumpWidget(
        host(
          FocusScope(
            node: scope,
            onKeyEvent: (_, _) => KeyEventResult.handled,
            child: IslandSelect<String>(
              options: options,
              value: 'a',
              focusNode: node,
              onChanged: requests.add,
            ),
          ),
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pumpAndSettle();
      expect(identical(scope, FocusManager.instance.rootScope), isFalse);
      scope.requestScopeFocus();
      await t.pumpAndSettle();
      expect(scope.hasPrimaryFocus, isTrue);
      expect(node.hasFocus, isFalse);
      await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect(scope.hasPrimaryFocus, isTrue);
      expect(requests, isEmpty);
      await t.pumpWidget(const SizedBox.shrink());
    } finally {
      node.dispose();
      scope.dispose();
    }
  });
  testWidgets(
    'Select trigger publishes primary focus independently from clear',
    (t) async {
      final handle = t.ensureSemantics();
      final focus = FocusNode();
      try {
        await t.pumpWidget(
          host(
            IslandSelect<String>(
              label: 'Fruit',
              options: options,
              value: 'a',
              onChanged: (_) {},
              allowClear: true,
              focusNode: focus,
            ),
          ),
        );
        final trigger = find.byWidgetPredicate(
          (widget) =>
              widget is Semantics &&
              widget.properties.label == 'Fruit' &&
              widget.properties.button == true,
        );

        SemanticsData data() => t.getSemantics(trigger).getSemanticsData();
        expect(data().flagsCollection.isFocused, ui.Tristate.isFalse);
        t.binding.renderViews.single.owner!.semanticsOwner!.performAction(
          t.getSemantics(trigger).id,
          ui.SemanticsAction.focus,
        );
        await t.pumpAndSettle();
        expect(focus.hasPrimaryFocus, isTrue);
        expect(data().flagsCollection.isFocused, ui.Tristate.isTrue);
        await t.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await t.pumpAndSettle();
        final clear = find.bySemanticsLabel('清除');
        t
            .widget<FocusableActionDetector>(
              find.descendant(
                of: clear,
                matching: find.byType(FocusableActionDetector),
              ),
            )
            .focusNode!
            .requestFocus();
        await t.pumpAndSettle();
        expect(data().flagsCollection.isFocused, ui.Tristate.isFalse);
        expect(
          t.getSemantics(clear).flagsCollection.isFocused,
          ui.Tristate.isTrue,
        );
        await t.pumpWidget(const SizedBox.shrink());
        void borrowedNodeStillUsable() {}
        focus.addListener(borrowedNodeStillUsable);
        focus.removeListener(borrowedNodeStillUsable);
      } finally {
        handle.dispose();
        focus.dispose();
      }
    },
  );
  testWidgets(
    'Search begins after committed label and preserves composing suffix',
    (t) async {
      final queries = <String>[];
      await t.pumpWidget(
        host(
          IslandSelect<String>(
            options: options,
            value: 'a',
            onChanged: (_) {},
            showSearch: true,
            onSearch: queries.add,
          ),
        ),
      );
      await t.tap(find.byType(TextField));
      await t.pumpAndSettle();
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'AppleB',
          selection: TextSelection.collapsed(offset: 6),
          composing: TextRange(start: 5, end: 6),
        ),
      );
      await t.pumpAndSettle();
      final value = t
          .widget<TextField>(find.byType(TextField))
          .controller!
          .value;
      expect(value.text, 'AppleB');
      expect(value.selection, const TextSelection.collapsed(offset: 6));
      expect(value.composing, const TextRange(start: 5, end: 6));
      expect(queries, ['B']);
      expect(find.text('Berry'), findsOneWidget);
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'AppleBe',
          selection: TextSelection.collapsed(offset: 7),
          composing: TextRange(start: 5, end: 7),
        ),
      );
      await t.pumpAndSettle();
      var editing = t
          .widget<TextField>(find.byType(TextField))
          .controller!
          .value;
      expect(editing.text, 'AppleBe');
      expect(editing.composing, const TextRange(start: 5, end: 7));
      expect(queries, ['B', 'Be']);
      expect(find.text('Berry'), findsOneWidget);
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'AppleBe',
          selection: TextSelection.collapsed(offset: 7),
        ),
      );
      await t.pumpAndSettle();
      editing = t.widget<TextField>(find.byType(TextField)).controller!.value;
      expect(editing.text, 'Be');
      expect(editing.selection, const TextSelection.collapsed(offset: 2));
      expect(editing.composing, TextRange.empty);
      expect(queries, ['B', 'Be']);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(queries, ['B', 'Be', '']);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Apple',
      );
      expect(find.text('Berry'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.text('Berry'), findsNothing);
      expect(queries, ['B', 'Be', '']);
    },
  );
  for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
    testWidgets('Clear owns its keyboard activation: ${key.keyLabel}', (
      t,
    ) async {
      final proposals = <String?>[];
      var cleared = 0;
      await t.pumpWidget(
        host(
          IslandSelect<String>(
            options: options,
            value: 'a',
            onChanged: proposals.add,
            allowClear: true,
            onClear: () => cleared++,
          ),
        ),
      );
      await t.tap(find.text('Apple'));
      await t.pumpAndSettle();
      final clear = find.bySemanticsLabel('清除');
      final detector = find.descendant(
        of: clear,
        matching: find.byType(FocusableActionDetector),
      );
      t.widget<FocusableActionDetector>(detector).focusNode!.requestFocus();
      await t.pump();
      await t.sendKeyEvent(key);
      await t.pumpAndSettle();
      expect(proposals, [null]);
      expect(cleared, 1);
      expect(find.text('Berry'), findsOneWidget);
    });
  }
  testWidgets(
    'Trigger, controlled panel and clear remain separate semantics owners',
    (t) async {
      final handle = t.ensureSemantics();
      try {
        await t.pumpWidget(
          host(
            IslandSelect<String>(
              label: 'Fruit',
              options: options,
              value: 'a',
              onChanged: (_) {},
              allowClear: true,
            ),
          ),
        );
        await t.tap(find.text('Apple'));
        await t.pumpAndSettle();
        final nodes = <SemanticsNode>[];
        void visit(SemanticsNode n) {
          nodes.add(n);
          n.visitChildren((child) {
            visit(child);
            return true;
          });
        }

        visit(
          t
              .binding
              .renderViews
              .single
              .owner!
              .semanticsOwner!
              .rootSemanticsNode!,
        );
        final combo = nodes.singleWhere(
          (n) =>
              n.getSemanticsData().value == 'Apple' &&
              n.getSemanticsData().label == 'Fruit',
        );
        final data = combo.getSemanticsData();
        expect(data.label, 'Fruit');
        expect(data.value, 'Apple');
        expect(data.flagsCollection.isExpanded, ui.Tristate.isTrue);
        final list = nodes.singleWhere(
          (n) => n.getSemanticsData().role == ui.SemanticsRole.list,
        );
        expect(
          data.controlsNodes,
          contains(list.getSemanticsData().identifier),
        );
        final clear = nodes.singleWhere(
          (n) => n.getSemanticsData().label == '清除',
        );
        expect(clear.id, isNot(combo.id));
        expect(clear.parent?.id, isNot(combo.id));
        expect(list.parent?.id, isNot(combo.id));
      } finally {
        handle.dispose();
      }
    },
  );
  for (final operation in ['cancel', 'close', 'disable', 'replace-value']) {
    testWidgets(
      'Select active composing prefix is session-owned on $operation',
      (t) async {
        var disabled = false;
        var selected = 'a';
        late StateSetter update;
        final queries = <String>[];
        final proposals = <String?>[];
        await t.pumpWidget(
          host(
            StatefulBuilder(
              builder: (_, set) {
                update = set;
                return IslandSelect<String>(
                  options: options,
                  value: selected,
                  onChanged: proposals.add,
                  disabled: disabled,
                  showSearch: true,
                  onSearch: queries.add,
                );
              },
            ),
          ),
        );
        await t.tap(find.byType(TextField));
        await t.pumpAndSettle();
        t.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'AppleB',
            selection: TextSelection.collapsed(offset: 6),
            composing: TextRange(start: 5, end: 6),
          ),
        );
        await t.pumpAndSettle();
        expect(queries, ['B']);
        expect(proposals, isEmpty);
        if (operation == 'cancel') {
          t.testTextInput.updateEditingValue(
            const TextEditingValue(
              text: 'Apple',
              selection: TextSelection.collapsed(offset: 5),
            ),
          );
          await t.pumpAndSettle();
          expect(queries, ['B', '']);
          expect(
            t.widget<TextField>(find.byType(TextField)).controller!.text,
            '',
          );
        } else if (operation == 'close') {
          await t.tapAt(const Offset(5, 5));
          await t.pumpAndSettle();
          expect(
            t.widget<TextField>(find.byType(TextField)).controller!.text,
            'Apple',
          );
          expect(queries, ['B', '']);
        } else if (operation == 'disable') {
          update(() => disabled = true);
          await t.pumpAndSettle();
          expect(
            t.widget<TextField>(find.byType(TextField)).controller!.text,
            'Apple',
          );
          update(() => disabled = false);
          await t.pumpAndSettle();
        } else {
          update(() => selected = 'b');
          await t.pumpAndSettle();
          t.testTextInput.updateEditingValue(
            const TextEditingValue(
              text: 'AppleBe',
              selection: TextSelection.collapsed(offset: 7),
            ),
          );
          await t.pumpAndSettle();
          expect(
            t.widget<TextField>(find.byType(TextField)).controller!.text,
            'Be',
          );
          expect(queries, ['B', 'Be']);
          await t.sendKeyEvent(LogicalKeyboardKey.escape);
          await t.pumpAndSettle();
          expect(
            t.widget<TextField>(find.byType(TextField)).controller!.text,
            'Berry',
          );
        }
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
        expect(t.takeException(), isNull);
      },
    );
  }
  for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.escape]) {
    testWidgets('Select leaves active IME ${key.keyLabel} to its text editor', (
      t,
    ) async {
      final requests = <String?>[];
      final queries = <String>[];
      await t.pumpWidget(
        host(
          IslandSelect<String>(
            options: options,
            value: 'a',
            onChanged: requests.add,
            showSearch: true,
            onSearch: queries.add,
          ),
        ),
      );
      await t.tap(find.byType(TextField));
      await t.pumpAndSettle();
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'AppleB',
          selection: TextSelection.collapsed(offset: 6),
          composing: TextRange(start: 5, end: 6),
        ),
      );
      await t.pumpAndSettle();
      await t.sendKeyEvent(key);
      await t.pump();
      expect(requests, isEmpty);
      expect(queries, ['B']);
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    });
  }
  testWidgets(
    'Select normalizes a focus-ended composition without stealing clear focus',
    (t) async {
      final focus = FocusNode();
      final requests = <String?>[];
      final queries = <String>[];
      try {
        await t.pumpWidget(
          host(
            IslandSelect<String>(
              options: options,
              value: 'a',
              onChanged: requests.add,
              showSearch: true,
              allowClear: true,
              focusNode: focus,
              onSearch: queries.add,
            ),
          ),
        );
        await t.tap(find.byType(TextField));
        await t.pumpAndSettle();
        t.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'AppleB',
            selection: TextSelection.collapsed(offset: 6),
            composing: TextRange(start: 5, end: 6),
          ),
        );
        await t.pumpAndSettle();
        final clear = find.bySemanticsLabel('清除');
        final clearFocus = t
            .widget<FocusableActionDetector>(
              find.descendant(
                of: clear,
                matching: find.byType(FocusableActionDetector),
              ),
            )
            .focusNode!;
        clearFocus.requestFocus();
        await t.pumpAndSettle();
        expect(clearFocus.hasPrimaryFocus, isTrue);
        expect(
          t.widget<TextField>(find.byType(TextField)).controller!.text,
          'B',
        );
        expect(queries, ['B']);
        expect(requests, isEmpty);
        await t.sendKeyEvent(LogicalKeyboardKey.enter);
        await t.pumpAndSettle();
        expect(requests, [null]);
        expect(queries, ['B']);
        await t.pumpWidget(const SizedBox());
        await t.pumpAndSettle();
      } finally {
        focus.dispose();
      }
    },
  );
  testWidgets(
    'Select retains the composing label session through a parent value change before the first character',
    (t) async {
      var selected = 'a';
      late StateSetter update;
      final queries = <String>[];
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandSelect<String>(
                options: options,
                value: selected,
                onChanged: (_) {},
                showSearch: true,
                onSearch: queries.add,
              );
            },
          ),
        ),
      );
      await t.tap(find.byType(TextField));
      await t.pumpAndSettle();
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'Apple',
          selection: TextSelection.collapsed(offset: 5),
          composing: TextRange(start: 0, end: 5),
        ),
      );
      await t.pump();
      update(() => selected = 'b');
      await t.pumpAndSettle();
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Apple',
      );
      expect(queries, isEmpty);
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'AppleB',
          selection: TextSelection.collapsed(offset: 6),
          composing: TextRange(start: 5, end: 6),
        ),
      );
      await t.pumpAndSettle();
      expect(queries, ['B']);
      t.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'AppleB',
          selection: TextSelection.collapsed(offset: 6),
        ),
      );
      await t.pumpAndSettle();
      expect(t.widget<TextField>(find.byType(TextField)).controller!.text, 'B');
      expect(queries, ['B']);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'Berry',
      );
      await t.pumpWidget(const SizedBox());
      await t.pumpAndSettle();
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'Search disable retires its editing client before restoring the committed label',
    (t) async {
      var disabled = false;
      var value = 'a';
      late StateSetter update;
      final focus = FocusNode();
      final queries = <String>[];
      final proposals = <String?>[];
      try {
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (_, set) {
                    update = set;
                    return IslandSelect<String>(
                      label: 'Fruit',
                      showSearch: true,
                      focusNode: focus,
                      disabled: disabled,
                      value: value,
                      onChanged: proposals.add,
                      onSearch: queries.add,
                      options: const [
                        IslandOption(value: 'a', label: 'Apple'),
                        IslandOption(value: 'b', label: 'Berry'),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
        await t.tap(find.byType(TextField));
        await t.pumpAndSettle();
        final controller = t
            .widget<TextField>(find.byType(TextField))
            .controller!;
        t.testTextInput.updateEditingValue(
          const TextEditingValue(
            text: 'AppleB',
            selection: TextSelection.collapsed(offset: 6),
            composing: TextRange(start: 5, end: 6),
          ),
        );
        await t.pumpAndSettle();
        expect(controller.text, 'AppleB');
        expect(queries, ['B']);
        t.testTextInput.log.clear();
        update(() {
          disabled = true;
          value = 'b';
        });
        await t.pumpAndSettle();
        expect(controller.text, 'Berry');
        expect(controller.value.composing, TextRange.empty);
        expect(focus.hasPrimaryFocus, isFalse);
        expect(proposals, isEmpty);
        expect(queries, ['B']);
        final stale = t.testTextInput.log.where(
          (call) =>
              call.method == 'TextInput.setEditingState' &&
              (call.arguments as Map)['text'] == 'Berry',
        );
        expect(
          stale,
          isEmpty,
          reason: 'The inactive editor must be disconnected before replacing its native composition buffer with the host label.',
        );
        await t.pumpWidget(const SizedBox());
      } finally {
        focus.dispose();
      }
    },
  );
}
