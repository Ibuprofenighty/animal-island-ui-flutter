import 'dart:ui' show CheckedState;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

Widget host(Widget child, {bool reduced = true}) => MaterialApp(
  theme: IslandTheme.create(),
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduced),
    child: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  testWidgets(
    'Tag close is independent of parent activation and removal is host-owned',
    (t) async {
      var closed = 0, activated = 0;
      await t.pumpWidget(
        host(
          IslandTag(
            onPressed: () => activated++,
            onClose: () => closed++,
            child: const Text('Fruit'),
          ),
        ),
      );
      await t.tap(find.bySemanticsLabel('close'));
      await t.pump();
      expect(closed, 1);
      expect(activated, 0);
      expect(find.text('Fruit'), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pump();
      expect(closed, 2);
      expect(activated, 0);
      await t.tap(find.text('Fruit'));
      await t.pump();
      expect(activated, 1);
    },
  );
  testWidgets('Tag disabled blocks both actions', (t) async {
    var calls = 0;
    await t.pumpWidget(
      host(
        IslandTag(
          disabled: true,
          onPressed: () => calls++,
          onClose: () => calls++,
          child: const Text('Fruit'),
        ),
      ),
    );
    await t.tap(find.bySemanticsLabel('close'));
    await t.tap(find.text('Fruit'));
    await t.pump();
    expect(calls, 0);
  });
  testWidgets(
    'Rate rejected proposal and keyboard navigation retain controlled value',
    (t) async {
      int? requested;
      await t.pumpWidget(
        host(IslandRate(value: 3, onChanged: (v) => requested = v)),
      );
      await t.tap(find.bySemanticsLabel('4 星'));
      await t.pump();
      expect(requested, 4);
      expect(
        t.getSemantics(find.bySemanticsLabel('3 星')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      expect(
        t.getSemantics(find.bySemanticsLabel('4 星')).flagsCollection.isChecked,
        CheckedState.isFalse,
      );
      await t.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await t.pump();
      expect(
        requested,
        4,
      ); // Reference steps from committed3, not rejected focus4.
      await t.sendKeyEvent(LogicalKeyboardKey.home);
      await t.pump();
      expect(requested, 1);
    },
  );
  testWidgets(
    'Rate uncontrolled selection clears and readonly does not dispatch',
    (t) async {
      await t.pumpWidget(host(const IslandRate(initialValue: 3)));
      await t.tap(find.bySemanticsLabel('3 星'));
      await t.pump();
      expect(
        t.getSemantics(find.bySemanticsLabel('3 星')).flagsCollection.isChecked,
        CheckedState.isFalse,
      );
      await t.tap(find.bySemanticsLabel('5 星'));
      await t.pump();
      expect(
        t.getSemantics(find.bySemanticsLabel('5 星')).flagsCollection.isChecked,
        CheckedState.isTrue,
      );
      var calls = 0;
      await t.pumpWidget(
        host(IslandRate(readOnly: true, value: 2, onChanged: (_) => calls++)),
      );
      await t.tap(find.bySemanticsLabel('5 星'));
      await t.pump();
      expect(calls, 0);
    },
  );
  testWidgets(
    'CodeBlock copies raw source and reports failure without success callback',
    (t) async {
      final binding =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      String? copied;
      var fail = false, successes = 0, failures = 0;
      binding.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          if (fail) throw PlatformException(code: 'denied');
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => binding.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await t.pumpWidget(
        host(
          SizedBox(
            width: 500,
            child: IslandCodeBlock(
              code: "final x = '<script>';\n// 中文",
              onCopied: (_) => successes++,
              onCopyError: (_) => failures++,
            ),
          ),
        ),
      );
      await t.tap(find.bySemanticsLabel('复制代码'));
      await t.pump();
      expect(copied, "final x = '<script>';\n// 中文");
      expect(successes, 1);
      expect(find.text('已复制'), findsOneWidget);
      await t.pump(const Duration(seconds: 2));
      fail = true;
      await t.tap(find.bySemanticsLabel('复制代码'));
      await t.pump();
      expect(successes, 1);
      expect(failures, 1);
      expect(find.text('复制失败'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 3));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Typewriter rich preserves styles, graphemes and replay lifecycle',
    (t) async {
      var completions = 0, replay = 0;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandTypewriter.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: '👨‍👩‍👧‍👦'),
                    TextSpan(
                      text: '好',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
                speed: const Duration(milliseconds: 10),
                trigger: replay,
                onDone: () => completions++,
              );
            },
          ),
          reduced: false,
        ),
      );
      await t.pump(const Duration(milliseconds: 10));
      expect(
        t.widget<Text>(find.byType(Text)).textSpan!.toPlainText(),
        '👨‍👩‍👧‍👦',
      );
      await t.pump(const Duration(milliseconds: 10));
      expect(completions, 1);
      final span = t.widget<Text>(find.byType(Text)).textSpan! as TextSpan;
      expect(span.children!.last.style!.color, Colors.orange);
      update(() {});
      await t.pump(const Duration(milliseconds: 40));
      expect(completions, 1);
      update(() => replay++);
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      expect(completions, 2);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Skeleton reduction stops animation; loaded child remains caller-owned',
    (t) async {
      final controller = TextEditingController(text: 'kept');
      addTearDown(controller.dispose);
      await t.pumpWidget(
        host(
          const SizedBox(
            width: 240,
            child: IslandSkeleton(variant: IslandSkeletonVariant.paragraph),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(t.binding.hasScheduledFrame, isFalse);
      await t.pumpWidget(
        host(
          IslandSkeleton(
            loading: false,
            child: SizedBox(
              width: 240,
              child: TextField(controller: controller),
            ),
          ),
        ),
      );
      await t.enterText(find.byType(TextField), 'new');
      expect(controller.text, 'new');
      await t.pumpWidget(const SizedBox());
      controller.text = 'still alive';
      expect(controller.text, 'still alive');
    },
  );
}
