import 'dart:ui' show Tristate, PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(
  Widget child, {
  bool dark = false,
  bool rtl = false,
  bool reduced = false,
  double scale = 1,
  Locale locale = const Locale('en'),
}) => MaterialApp(
  theme: IslandTheme.create(
    brightness: dark ? Brightness.dark : Brightness.light,
  ),
  locale: locale,
  supportedLocales: IslandLocalizations.supportedLocales,
  localizationsDelegates: IslandLocalizations.delegates,
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        disableAnimations: reduced,
        textScaler: TextScaler.linear(scale),
      ),
      child: Directionality(
        textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(padding: const EdgeInsets.all(20), child: child),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('button.activation pointer/keyboard/disabled/busy', (t) async {
    var calls = 0;
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await t.pumpWidget(
      host(
        Column(
          children: [
            IslandButton(
              child: const Text('Go'),
              focusNode: focus,
              onPressed: () => calls++,
            ),
            const IslandButton(child: Text('Disabled'), onPressed: null),
            IslandButton(
              child: const Text('Busy'),
              busy: true,
              onPressed: () => calls++,
            ),
          ],
        ),
      ),
    );
    await t.tap(find.text('Go'));
    await t.pump();
    expect(calls, 1);
    focus.requestFocus();
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.enter);
    await t.pump();
    expect(calls, 2);
    await t.sendKeyEvent(LogicalKeyboardKey.space);
    await t.pump();
    expect(calls, 3);
    await t.tap(find.text('Disabled'));
    await t.tap(find.text('Busy'));
    expect(calls, 3);
    expect(t.getSize(find.byType(IslandButton).first).height, equals(45));
  });
  testWidgets('icon-button.label and activation', (t) async {
    final h = t.ensureSemantics();
    try {
      var calls = 0;
      await t.pumpWidget(
        host(
          IslandIconButton(
            glyph: IslandGlyph.heart,
            label: 'Favorite',
            onPressed: () => calls++,
          ),
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is IslandTooltip && w.message == 'Favorite',
        ),
        findsOneWidget,
      );
      expect(
        t.getSemantics(find.bySemanticsLabel('Favorite')).label,
        'Favorite',
      );
      await t.tap(find.byType(IslandIconButton));
      expect(calls, 1);
    } finally {
      h.dispose();
    }
  });
  testWidgets('icon.semantics meaningful and decorative', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          const Row(
            children: [
              IslandIcon(IslandGlyph.leaf),
              IslandIcon(IslandGlyph.sun, semanticLabel: 'Daylight'),
            ],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Daylight'), findsOneWidget);
      expect(find.bySemanticsLabel('leaf'), findsNothing);
    } finally {
      h.dispose();
    }
  });
  testWidgets('card.content wraps at narrow widths', (t) async {
    t.view.physicalSize = const Size(375, 900);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      host(
        const IslandCard(
          child: Text(
            'A long invitation to a quieter island, where every visitor is welcome.',
          ),
        ),
        scale: 2,
      ),
    );
    expect(t.takeException(), isNull);
    expect(find.textContaining('every visitor'), findsOneWidget);
  });
  testWidgets('badge.label', (t) async {
    await t.pumpWidget(
      host(const IslandBadge(text: 'Growing', color: IslandColorway.green)),
    );
    expect(find.text('Growing'), findsOneWidget);
  });
  testWidgets('avatar.name excludes decorative initials', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          const IslandAvatar(child: Text('MR'), semanticLabel: 'Mira River'),
        ),
      );
      expect(find.bySemanticsLabel('Mira River'), findsOneWidget);
      expect(find.bySemanticsLabel('MR'), findsNothing);
    } finally {
      h.dispose();
    }
  });
  testWidgets('divider.decorative', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          const Column(
            children: [Text('Before'), IslandDivider(), Text('After')],
          ),
        ),
      );
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(find.bySemanticsLabel('Before'), findsOneWidget);
      expect(find.bySemanticsLabel('After'), findsOneWidget);
    } finally {
      h.dispose();
    }
  });
  testWidgets('text-field.validation and controller ownership', (t) async {
    final form = GlobalKey<FormState>();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await t.pumpWidget(
      host(
        Form(
          key: form,
          child: IslandTextField(
            label: 'Name',
            controller: controller,
            validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
          ),
        ),
      ),
    );
    expect(form.currentState!.validate(), false);
    await t.pump();
    expect(find.text('Name required'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'Mira');
    expect(form.currentState!.validate(), true);
    await t.pump();
    expect(find.text('Name required'), findsNothing);
    await t.pumpWidget(const SizedBox());
    controller.text = 'Still owned';
    expect(controller.text, 'Still owned');
  });
  testWidgets('checkbox.controlled requests without internal commit', (
    t,
  ) async {
    bool? requested;
    await t.pumpWidget(
      host(
        IslandCheckbox(
          label: 'Agree',
          value: false,
          onChanged: (v) => requested = v,
        ),
      ),
    );
    await t.tap(find.text('Agree'));
    await t.pump();
    expect(requested, true);
    expect(t.widget<IslandCheckbox>(find.byType(IslandCheckbox)).value, false);
  });
  testWidgets('switch.controlled host commits', (t) async {
    var value = false, calls = 0;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => IslandSwitch(
            label: 'Reminder',
            value: value,
            onChanged: (v) => setState(() {
              value = v;
              calls++;
            }),
          ),
        ),
      ),
    );
    await t.tap(find.text('Reminder'));
    await t.pumpAndSettle();
    expect(value, true);
    expect(calls, 1);
    expect(t.widget<IslandSwitch>(find.byType(IslandSwitch)).value, true);
  });
  testWidgets('radio.selection typed host commit', (t) async {
    var value = 'A';
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => IslandRadioGroup<String>(
            options: const [
              IslandOption(value: 'A', label: 'A'),
              IslandOption(value: 'B', label: 'B'),
            ],
            value: value,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await t.tap(find.text('B'));
    await t.pumpAndSettle();
    expect(value, 'B');
    expect(
      t
          .widget<IslandRadioGroup<String>>(
            find.byType(IslandRadioGroup<String>),
          )
          .value,
      'B',
    );
  });
  testWidgets('select.selection typed host commit', (t) async {
    var value = 'A';
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => IslandSelect<String>(
            label: 'Island',
            value: value,
            options: const [
              IslandOption(value: 'A', label: 'Cedar'),
              IslandOption(value: 'B', label: 'Maple'),
            ],
            onChanged: (v) => setState(() => value = v!),
          ),
        ),
      ),
    );
    await t.tap(find.byType(IslandSelect<String>));
    await t.pumpAndSettle();
    await t.tap(find.text('Maple').last);
    await t.pumpAndSettle();
    expect(value, 'B');
    expect(
      t.widget<IslandSelect<String>>(find.byType(IslandSelect<String>)).value,
      'B',
    );
  });
  testWidgets('tabs.selection', (t) async {
    var index = 0;
    await t.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => IslandTabs(
            items: const [
              IslandTab(
                value: 0,
                label: Text('Today'),
                child: Text('Today panel'),
              ),
              IslandTab(
                value: 1,
                label: Text('Tomorrow'),
                child: Text('Tomorrow panel'),
              ),
            ],
            value: index,
            onChanged: (v) => setState(() => index = v),
          ),
        ),
      ),
    );
    await t.tap(find.text('Tomorrow'));
    await t.pumpAndSettle();
    expect(index, 1);
  });
  testWidgets('tabs keyboard, RTL and rejected host commit', (t) async {
    var requested = -1;
    await t.pumpWidget(
      host(
        IslandTabs(
          items: const [
            IslandTab(value: 0, label: Text('Today'), child: SizedBox()),
            IslandTab(value: 1, label: Text('Tomorrow'), child: SizedBox()),
            IslandTab(value: 2, label: Text('Later'), child: SizedBox()),
          ],
          value: 0,
          onChanged: (v) => requested = v,
        ),
        rtl: true,
      ),
    );
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await t.pump();
    expect(requested, 1);
    expect(t.widget<IslandTabs<int>>(find.byType(IslandTabs<int>)).value, 0);
    await t.sendKeyEvent(LogicalKeyboardKey.end);
    await t.pump();
    expect(requested, 2);
    await t.sendKeyEvent(LogicalKeyboardKey.home);
    await t.pump();
    expect(requested, 0);
  });
  testWidgets('progress.value semantic percent', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          const IslandProgress(percent: 50, label: 'Garden', showInfo: false),
        ),
      );
      final node = t.getSemantics(find.byType(IslandProgress));
      expect(node.label, 'Garden');
      expect(node.value, '50%');
    } finally {
      h.dispose();
    }
  });
  testWidgets('tooltip.message', (t) async {
    await t.pumpWidget(
      host(
        const IslandTooltip(message: 'A helpful note', child: Text('Hover')),
      ),
    );
    final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(t.getCenter(find.text('Hover')));
    addTearDown(mouse.removePointer);
    await t.pumpAndSettle();
    expect(find.text('A helpful note'), findsOneWidget);
  });
  testWidgets('disabled controlled inputs never dispatch', (t) async {
    await t.pumpWidget(
      host(
        Column(
          children: [
            const IslandCheckbox(
              label: 'Disabled check',
              value: false,
              onChanged: null,
            ),
            const IslandSwitch(
              label: 'Disabled switch',
              value: false,
              onChanged: null,
            ),
            IslandRadioGroup<String>(
              options: const [
                IslandOption(value: 'One', label: 'One'),
                IslandOption(value: 'Two', label: 'Two'),
              ],
              value: 'One',
              onChanged: null,
            ),
          ],
        ),
      ),
    );
    expect(
      t.widget<IslandCheckbox>(find.byType(IslandCheckbox)).onChanged,
      isNull,
    );
    expect(t.widget<IslandSwitch>(find.byType(IslandSwitch)).onChanged, isNull);
    expect(
      t
          .widget<IslandRadioGroup<String>>(
            find.byType(IslandRadioGroup<String>),
          )
          .onChanged,
      isNull,
    );
  });
  testWidgets('button semantics exposes button and enabled state', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(IslandButton(child: const Text('Go'), onPressed: () {})),
      );
      final node = t.getSemantics(find.byType(IslandButton));
      expect(node.flagsCollection.isButton, true);
      expect(node.flagsCollection.isEnabled, Tristate.isTrue);
    } finally {
      h.dispose();
    }
  });

  group('CodeBlock', () {
    Map<String, Color?> roles(WidgetTester t) {
      final result = <String, Color?>{};
      void visit(InlineSpan span) {
        if (span is! TextSpan) return;
        if (span.text case final text? when text.trim().isNotEmpty) {
          result[text] = span.style?.color;
        }
        span.children?.forEach(visit);
      }

      visit(
        t
            .state<EditableTextState>(find.byType(EditableText))
            .renderEditable
            .text!,
      );
      return result;
    }

    testWidgets(
      'shell highlights reference # comments, tree, flags and files',
      (t) async {
        const code =
            '# 复制技能 PowerShell\n'
            'Copy-Item -Recurse skills/animal-island-ui-flutter ~/.agents/\n'
            '├── SKILL.md   # 方法\n'
            'flutter pub add a#b';
        await t.pumpWidget(
          host(
            const IslandCodeBlock(
              code: code,
              language: IslandCodeLanguage.shell,
            ),
          ),
        );
        final spans = roles(t);
        const comment = Color(0xff9d8f7e);
        expect(spans['# 复制技能 PowerShell'], comment);
        expect(spans['# 方法'], comment);
        expect(spans['-Recurse'], const Color(0xffd4b896));
        expect(spans['├──'], const Color(0xffd4b896));
        expect(spans['SKILL.md'], const Color(0xff80c0e0));
        expect(spans['~/.agents/'], const Color(0xffa8d4a0));
        // A path keeps its embedded words, such as `flutter`, as plain source.
        expect(spans['skills/animal-island-ui-flutter'], isNull);
        expect(spans['flutter'], const Color(0xfff0a870));
        // `#` inside a word is not a comment.
        expect(spans.keys.where((k) => k.startsWith('#b')), isEmpty);
        // Dart keeps `#` as source.
        await t.pumpWidget(
          host(const IslandCodeBlock(code: '# not a comment', copyable: false)),
        );
        expect(roles(t).values.whereType<Color>(), isNot(contains(comment)));
      },
    );

    testWidgets(
      'shell // comments are italic at weight 400 without changing line metrics',
      (t) async {
        TextSpan span(String text) {
          TextSpan? found;
          void visit(InlineSpan s) {
            if (s is TextSpan && s.text == text) found = s;
            if (s is TextSpan) s.children?.forEach(visit);
          }

          visit(
            t
                .state<EditableTextState>(find.byType(EditableText))
                .renderEditable
                .text!,
          );
          return found!;
        }

        // Equal-length lines: the comment line and a plain source line.
        const code = '# abcdefgh\n// abcdefg\nabcdefghij';
        await t.pumpWidget(
          host(
            const IslandCodeBlock(
              code: code,
              language: IslandCodeLanguage.shell,
              copyable: false,
            ),
          ),
        );
        expect(span('// abcdefg').style!.fontStyle, FontStyle.italic);
        expect(span('// abcdefg').style!.fontWeight, FontWeight.w400);
        expect(span('// abcdefg').style!.color, const Color(0xff9d8f7e));
        // `#` comments keep the comment colour and stay upright.
        expect(span('# abcdefgh').style!.fontStyle, isNull);
        expect(span('# abcdefgh').style!.fontWeight, isNull);
        expect(span('# abcdefgh').style!.color, const Color(0xff9d8f7e));
        expect(span('abcdefghij').style?.fontStyle, isNull);
        List<TextBox> rows() {
          final editable = t
              .state<EditableTextState>(find.byType(EditableText))
              .renderEditable;
          return [
            for (final start in [0, 11, 22])
              ...editable.getBoxesForSelection(
                TextSelection(baseOffset: start, extentOffset: start + 10),
              ),
          ];
        }

        final slanted = rows();
        final height = t.getSize(find.byType(IslandCodeBlock)).height;
        // Plain language draws the same source with no span styles.
        await t.pumpWidget(
          host(
            const IslandCodeBlock(
              code: code,
              language: IslandCodeLanguage.plain,
              copyable: false,
            ),
          ),
        );
        final upright = rows();
        expect(slanted, hasLength(3));
        expect(upright, hasLength(3));
        // One pitch and one line box whether the line is slanted or not.
        for (var i = 0; i < 3; i++) {
          expect(slanted[i].left, closeTo(upright[i].left, .01));
          expect(slanted[i].right, closeTo(upright[i].right, .01));
          expect(slanted[i].top, closeTo(upright[i].top, .01));
          expect(slanted[i].bottom, closeTo(upright[i].bottom, .01));
        }
        expect(t.getSize(find.byType(IslandCodeBlock)).height, height);

        // Dart and JavaScript comments stay upright as reference highlightJSX.
        await t.pumpWidget(
          host(const IslandCodeBlock(code: '// note\nfinal a = 1;')),
        );
        expect(span('// note').style!.fontStyle, isNull);
        expect(span('// note').style!.fontWeight, isNull);
      },
    );

    testWidgets('copy button lifts 1px on hover and rings focus outside', (
      t,
    ) async {
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(
        () => FocusManager.instance.highlightStrategy =
            FocusHighlightStrategy.automatic,
      );
      await t.pumpWidget(host(const IslandCodeBlock(code: 'final a = 1;')));
      final copy = find.text('复制');
      final rest = t.getRect(copy);
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(t.getCenter(copy));
      await t.pump();
      await t.pump(const Duration(milliseconds: 125));
      final mid = t.getRect(copy).top - rest.top;
      expect(mid, inExclusiveRange(-1, 0));
      await t.pumpAndSettle();
      expect(t.getRect(copy).top - rest.top, closeTo(-1, .001));
      await mouse.down(t.getCenter(copy));
      await t.pumpAndSettle();
      expect(t.getRect(copy).top, closeTo(rest.top, .001));
      // Leave before release so the press cancels without copying.
      await mouse.moveTo(Offset.zero);
      await mouse.up();
      await t.pumpAndSettle();

      Finder pill() =>
          find.ancestor(of: copy, matching: find.byType(Container)).first;
      expect(t.widget<Container>(pill()).foregroundDecoration, isNull);
      // Selectable source may take focus first; the copy action follows it.
      for (var i = 0; i < 3; i++) {
        if (t.widget<Container>(pill()).foregroundDecoration != null) break;
        await t.sendKeyEvent(LogicalKeyboardKey.tab);
        await t.pumpAndSettle();
      }
      final decoration =
          t.widget<Container>(pill()).decoration! as BoxDecoration;
      expect(
        (decoration.border! as Border).top.color,
        const Color(0x4de8d5bc),
        reason: 'the resting border stays; focus is a separate outer ring',
      );
      expect(t.widget<Container>(pill()).foregroundDecoration, isNotNull);
    });

    testWidgets('copy lift settles immediately under reduced motion', (
      t,
    ) async {
      await t.pumpWidget(
        host(const IslandCodeBlock(code: 'final a = 1;'), reduced: true),
      );
      final copy = find.text('复制');
      final rest = t.getRect(copy);
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(t.getCenter(copy));
      await t.pump();
      await t.pump();
      expect(t.getRect(copy).top - rest.top, closeTo(-1, .001));
    });
  });
}
