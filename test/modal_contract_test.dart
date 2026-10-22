import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final variant in IslandModalVariant.values) {
    testWidgets(
      'Cursor composition preserves body and barrier hit targets: $variant',
      (t) async {
        late BuildContext host;
        await t.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                host = context;
                return const SizedBox();
              },
            ),
          ),
        );
        showIslandModal<void>(
          context: host,
          variant: variant,
          builder: (_) => const Text('body target'),
        );
        await t.pumpAndSettle();
        await t.tap(find.text('body target'));
        await t.pumpAndSettle();
        expect(find.byType(IslandModal), findsOneWidget);
        await t.tapAt(const Offset(5, 5));
        await t.pumpAndSettle();
        expect(find.byType(IslandModal), findsNothing);
        expect(t.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'Dialog has a named surface and independently readable opaque title',
    (t) async {
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        const MaterialApp(
          home: IslandModal(
            semanticLabel: 'named dialog',
            title: Text('opaque title'),
            child: Text('body'),
          ),
        ),
      );
      expect(find.bySemanticsLabel('named dialog'), findsOneWidget);
      expect(find.bySemanticsLabel('opaque title'), findsOneWidget);
      final node = t.getSemantics(find.bySemanticsLabel('named dialog'));
      expect(node.getSemanticsData().flagsCollection.namesRoute, isTrue);
      expect(node.rect.width, 520);
      expect(node.rect.height, lessThan(600));
      semantics.dispose();
    },
  );
  testWidgets(
    'Normal no-footer surface scrolls long opaque content without losing header',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          home: IslandModal(
            variant: IslandModalVariant.normal,
            title: const Text('fixed title'),
            child: Column(
              children: List.generate(
                30,
                (i) => SizedBox(height: 40, child: Text('row $i')),
              ),
            ),
          ),
        ),
      );
      final title = t.getTopLeft(find.text('fixed title'));
      await t.drag(find.byType(SingleChildScrollView), const Offset(0, -900));
      await t.pumpAndSettle();
      expect(t.getTopLeft(find.text('fixed title')), title);
      expect(find.text('row 29').hitTestable(), findsOneWidget);
      expect(find.byType(IslandButton), findsNothing);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('Modal uses reference entry curve and immediate exit', (t) async {
    late BuildContext host;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            host = context;
            return const SizedBox();
          },
        ),
      ),
    );
    showIslandModal<void>(context: host, builder: (_) => const Text('body'));
    await t.pump();
    final scale = find
        .ancestor(
          of: find.byType(IslandModal),
          matching: find.byType(ScaleTransition),
        )
        .first;
    expect(t.widget<ScaleTransition>(scale).scale.value, .92);
    await t.pump(const Duration(milliseconds: 150));
    expect(
      t.widget<ScaleTransition>(scale).scale.value,
      closeTo(.92 + .08 * Curves.ease.transform(.5), .0001),
    );
    await t.pump(const Duration(milliseconds: 150));
    expect(t.widget<ScaleTransition>(scale).scale.value, 1);
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pump();
    await t.pump();
    expect(find.byType(IslandModal), findsNothing);
  });
  testWidgets(
    'Modal traps focus, restores trigger and separates barrier from Escape',
    (t) async {
      final trigger = FocusNode();
      addTearDown(trigger.dispose);
      await t.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => IslandButton(
              focusNode: trigger,
              onPressed: () => showIslandModal<void>(
                context: context,
                dismissible: false,
                title: const Text('title'),
                builder: (_) => const Text('body'),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.byType(IconButton), findsNothing);
      expect(
        FocusManager.instance.primaryFocus!.context!
            .findAncestorWidgetOfExactType<IslandButton>()!
            .child,
        isA<Text>(),
      );
      expect(
        (FocusManager.instance.primaryFocus!.context!
                    .findAncestorWidgetOfExactType<IslandButton>()!
                    .child
                as Text)
            .data,
        '取消',
      );
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      expect(
        (FocusManager.instance.primaryFocus!.context!
                    .findAncestorWidgetOfExactType<IslandButton>()!
                    .child
                as Text)
            .data,
        '确定',
      );
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      await t.pump();
      expect(
        (FocusManager.instance.primaryFocus!.context!
                    .findAncestorWidgetOfExactType<IslandButton>()!
                    .child
                as Text)
            .data,
        '取消',
      );
      await t.tapAt(const Offset(5, 5));
      await t.pumpAndSettle();
      expect(find.byType(IslandModal), findsOneWidget);
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pumpAndSettle();
      expect(find.byType(IslandModal), findsNothing);
      expect(trigger.hasFocus, isTrue);
    },
  );
  testWidgets(
    'Modal slots preserve styles, state, and rejected Escape intent',
    (t) async {
      var closes = 0;
      var count = 0;
      late StateSetter update;
      var titled = true;
      final field = TextEditingController();
      addTearDown(field.dispose);
      final body = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: field),
          IslandButton(onPressed: () => count++, child: const Text('child')),
          const Text(
            'styled',
            style: TextStyle(color: Colors.red, fontSize: 11),
          ),
        ],
      );
      await t.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandModal(
                title: titled ? const Text('title') : null,
                onClose: () => closes++,
                child: body,
              );
            },
          ),
        ),
      );
      await t.enterText(find.byType(TextField), 'kept');
      await t.sendKeyEvent(LogicalKeyboardKey.escape);
      await t.pump();
      expect(closes, 1);
      expect(find.byType(IslandModal), findsOneWidget);
      await t.tap(find.text('child'));
      await t.pump();
      expect(count, 1);
      expect(closes, 1);
      update(() => titled = false);
      await t.pump();
      expect(field.text, 'kept');
      expect(t.widget<Text>(find.text('styled')).style!.color, Colors.red);
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('No-footer modal keeps Escape reachable with barrier disabled', (
    t,
  ) async {
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => IslandButton(
            onPressed: () => showIslandModal<void>(
              context: context,
              dismissible: false,
              actions: (_) => [],
              builder: (_) => const Text('passive'),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.sendKeyEvent(LogicalKeyboardKey.tab);
    await t.pump();
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.byType(IslandModal), findsNothing);
  });
  testWidgets('Retained default action removes only its own covered route', (
    t,
  ) async {
    late BuildContext host;
    late BuildContext modalContext;
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            host = context;
            return const SizedBox();
          },
        ),
      ),
    );
    showIslandModal<void>(
      context: host,
      builder: (context) {
        modalContext = context;
        return const Text('first');
      },
    );
    await t.pumpAndSettle();
    final close = t
        .widget<IslandButton>(find.widgetWithText(IslandButton, '取消'))
        .onPressed!;
    showIslandModal<void>(
      context: modalContext,
      builder: (_) => const Text('second'),
    );
    await t.pumpAndSettle();
    close();
    await t.pumpAndSettle();
    expect(find.text('second'), findsOneWidget);
    await t.sendKeyEvent(LogicalKeyboardKey.escape);
    await t.pumpAndSettle();
    expect(find.byType(IslandModal), findsNothing);
    expect(t.takeException(), isNull);
  });
  testWidgets(
    'Typewriter builder owns one grapheme timeline and cancels on removal',
    (t) async {
      var done = 0;
      var play = true;
      var trigger = 0;
      late StateSetter update;
      await t.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandTypewriter.builder(
                'A👨‍👩‍👧‍👦B',
                speed: const Duration(milliseconds: 80),
                play: play,
                trigger: trigger,
                onDone: () => done++,
                builder: (_, visible) => Text('visible:$visible'),
              );
            },
          ),
        ),
      );
      expect(find.text('visible:'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 80));
      expect(find.text('visible:A'), findsOneWidget);
      await t.pump(const Duration(milliseconds: 80));
      expect(find.text('visible:A👨‍👩‍👧‍👦'), findsOneWidget);
      update(() => play = false);
      await t.pump();
      expect(find.text('visible:A👨‍👩‍👧‍👦B'), findsOneWidget);
      expect(done, 1);
      update(() {
        play = true;
        trigger++;
      });
      await t.pump();
      expect(find.text('visible:'), findsOneWidget);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 1));
      expect(done, 1);
    },
  );
}
