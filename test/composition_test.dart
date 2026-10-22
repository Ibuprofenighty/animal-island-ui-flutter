import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

class _OpaqueStateAction extends StatefulWidget {
  const _OpaqueStateAction({
    super.key,
    required this.focus,
    required this.onPressed,
  });
  final FocusNode focus;
  final VoidCallback onPressed;
  @override
  State<_OpaqueStateAction> createState() => _OpaqueStateActionState();
}

class _OpaqueStateActionState extends State<_OpaqueStateAction> {
  var count = 0;
  @override
  Widget build(BuildContext context) => IslandButton(
    focusNode: widget.focus,
    onPressed: () {
      setState(() => count++);
      widget.onPressed();
    },
    child: Text(
      'Opaque $count',
      style: const TextStyle(color: Colors.purple, fontSize: 17),
    ),
  );
}

void _expectPreservedOpaqueState(
  WidgetTester t,
  GlobalKey<_OpaqueStateActionState> key,
  State original,
  FocusNode focus,
  int count,
) {
  expect(key.currentState, same(original));
  expect(focus.hasPrimaryFocus, isTrue);
  final label = find.text('Opaque $count');
  expect(label, findsOneWidget);
  expect(
    (t.renderObject<RenderParagraph>(label).text as TextSpan).style!.color,
    Colors.purple,
  );
  expect(
    (t.renderObject<RenderParagraph>(label).text as TextSpan).style!.fontSize,
    17,
  );
}

void main() {
  testWidgets(
    'Card slot defaults preserve explicit child text and button theme',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create().copyWith(
            extensions: [
              IslandTokens.light,
              const IslandButtonTheme(
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(Colors.purple),
                ),
              ),
            ],
          ),
          home: Scaffold(
            body: IslandCard(
              style: const IslandCardStyle(
                foregroundColor: WidgetStatePropertyAll(Colors.red),
                textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 22)),
              ),
              header: const Text('Header'),
              child: Column(
                children: [
                  const Text('Inherited'),
                  const Text('Explicit', style: TextStyle(color: Colors.blue)),
                  IslandButton(onPressed: () {}, child: const Text('Action')),
                ],
              ),
            ),
          ),
        ),
      );
      TextStyle effective(String label) {
        final rich = tester.widget<RichText>(
          find.descendant(
            of: find.text(label),
            matching: find.byType(RichText),
          ),
        );
        return (rich.text as TextSpan).style!;
      }

      expect(effective('Inherited').color, Colors.red);
      expect(effective('Explicit').color, Colors.blue);
      expect(effective('Action').color, Colors.purple);
      expect(effective('Action').fontSize, 14);
      expect(effective('Inherited').fontSize, 22);
    },
  );
  testWidgets('Nested action activates child once without activating Card', (
    tester,
  ) async {
    var parent = 0, child = 0;
    final focus = FocusNode();
    await tester.pumpWidget(
      MaterialApp(
        theme: IslandTheme.create(),
        home: Scaffold(
          body: IslandCard(
            onTap: () => parent++,
            child: IslandButton(
              focusNode: focus,
              onPressed: () => child++,
              child: const Text('Child'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Child'));
    await tester.pump();
    expect((parent, child), (0, 1));
    focus.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect((parent, child), (0, 2));
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect((parent, child), (0, 3));
    await tester.pumpWidget(const SizedBox());
    focus.dispose();
  });
  testWidgets('Local component theme stays scoped and instance property wins', (
    tester,
  ) async {
    final base = IslandTheme.create();
    await tester.pumpWidget(
      MaterialApp(
        theme: base,
        home: Scaffold(
          body: Column(
            children: [
              Theme(
                data: base.copyWith(
                  extensions: [
                    IslandTokens.light,
                    const IslandButtonTheme(
                      style: ButtonStyle(
                        foregroundColor: WidgetStatePropertyAll(Colors.red),
                      ),
                    ),
                  ],
                ),
                child: IslandButton(
                  style: const ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                  onPressed: () {},
                  child: const Text('Local'),
                ),
              ),
              IslandButton(onPressed: () {}, child: const Text('Sibling')),
            ],
          ),
        ),
      ),
    );
    TextStyle effective(String text) =>
        (tester
                    .widget<RichText>(
                      find.descendant(
                        of: find.text(text),
                        matching: find.byType(RichText),
                      ),
                    )
                    .text
                as TextSpan)
            .style!;
    expect(effective('Local').color, Colors.blue);
    expect(effective('Sibling').color, IslandTokens.light.ink);
  });
  testWidgets(
    'Busy and disabled actions suppress pointer and keyboard activation',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create(),
          home: Scaffold(
            body: IslandButton(
              busy: true,
              onPressed: () => calls++,
              child: const Text('Busy'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Busy'));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      expect(calls, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Progress opaque info retains keyed state explicit style focus and local actions through clamped reversals',
    (t) async {
      final focus = FocusNode(), key = GlobalKey<_OpaqueStateActionState>();
      var parent = 0, child = 0;
      var percent = 50.0;
      var dark = false;
      var rtl = false;
      var reduced = false;
      late StateSetter update;
      double? supplied;
      await t.pumpWidget(
        StatefulBuilder(
          builder: (_, set) {
            update = set;
            return MaterialApp(
              theme: IslandTheme.create(
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              home: MediaQuery(
                data: MediaQueryData(disableAnimations: reduced),
                child: Directionality(
                  textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Scaffold(
                    body: GestureDetector(
                      onTap: () => parent++,
                      child: IslandProgress(
                        percent: percent,
                        label: 'Progress',
                        infoBuilder: (value) {
                          supplied = value;
                          return _OpaqueStateAction(
                            key: key,
                            focus: focus,
                            onPressed: () => child++,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await t.pumpAndSettle();
      final original = key.currentState!;
      await t.tap(find.text('Opaque 0'));
      await t.pumpAndSettle();
      expect((parent, child), (0, 1));
      focus.requestFocus();
      await t.pump();
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect((parent, child), (0, 2));
      for (final value in [-5.0, double.nan, 150.0, 25.0, 0.0]) {
        update(() {
          percent = value;
          dark = !dark;
          rtl = !rtl;
          reduced = !reduced;
        });
        await t.pump();
        await t.pump(const Duration(milliseconds: 45));
        _expectPreservedOpaqueState(t, key, original, focus, 2);
        expect(supplied, value.isNaN ? 0 : value.clamp(0, 100));
        expect((parent, child), (0, 2));
      }
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect((parent, child), (0, 3));
      await t.pumpWidget(const SizedBox());
      await t.pump();
      void listener() {}
      focus.addListener(listener);
      focus.removeListener(listener);
      focus.dispose();
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'Skeleton loaded opaque child survives host changes and placeholder availability owns hits',
    (t) async {
      final focus = FocusNode(), key = GlobalKey<_OpaqueStateActionState>();
      var parent = 0, child = 0;
      var dark = false, rtl = false, loading = false, active = true;
      var variant = IslandSkeletonVariant.text;
      late StateSetter update;
      await t.pumpWidget(
        StatefulBuilder(
          builder: (_, set) {
            update = set;
            return MaterialApp(
              theme: IslandTheme.create(
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              home: MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Directionality(
                  textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
                  child: Scaffold(
                    body: GestureDetector(
                      onTap: () => parent++,
                      child: IslandSkeleton(
                        loading: loading,
                        active: active,
                        variant: variant,
                        width: 260,
                        rows: 4,
                        rowWidths: const [.8, .5],
                        child: _OpaqueStateAction(
                          key: key,
                          focus: focus,
                          onPressed: () => child++,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
      await t.pumpAndSettle();
      final original = key.currentState!;
      await t.tap(find.text('Opaque 0'));
      await t.pumpAndSettle();
      expect((parent, child), (0, 1));
      focus.requestFocus();
      await t.pump();
      for (final value in IslandSkeletonVariant.values) {
        update(() {
          variant = value;
          dark = !dark;
          rtl = !rtl;
          active = !active;
        });
        await t.pump();
        _expectPreservedOpaqueState(t, key, original, focus, 1);
      }
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pumpAndSettle();
      expect((parent, child), (0, 2));
      update(() => loading = true);
      await t.pump();
      expect(find.byType(_OpaqueStateAction), findsNothing);
      expect(focus.hasFocus, isFalse);
      expect(t.hasRunningAnimations, isFalse);
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.pump();
      expect((parent, child), (0, 2));
      update(() => loading = false);
      await t.pump();
      expect(key.currentState, isNot(same(original)));
      expect(find.text('Opaque 0'), findsOneWidget);
      await t.tap(find.text('Opaque 0'));
      await t.pump();
      expect((parent, child), (0, 3));
      await t.pumpWidget(const SizedBox());
      await t.pump();
      void listener() {}
      focus.addListener(listener);
      focus.removeListener(listener);
      focus.dispose();
      expect(t.takeException(), isNull);
    },
  );
}
