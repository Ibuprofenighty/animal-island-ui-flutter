import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'readable_motion_test.dart' show opaque;

void main() {
  testWidgets('shared empty dialog consumes Tab and Escape restores origin', (
    t,
  ) async {
    late BuildContext page;
    final origin = FocusNode();
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            page = context;
            return Scaffold(
              body: TextButton(
                focusNode: origin,
                onPressed: () {},
                child: const Text('Origin'),
              ),
            );
          },
        ),
      ),
    );
    origin.requestFocus();
    await t.pumpAndSettle();
    final nav = Navigator.of(page, rootNavigator: true);
    nav.push(
      IslandDialogRoute<void>(
        context: page,
        builder: (_) => const AlertDialog(content: Text('No actions')),
      ),
    );
    await t.pumpAndSettle();
    final current = FocusManager.instance.primaryFocus;
    expect(origin.hasFocus, isFalse);
    expect(await t.sendKeyEvent(LogicalKeyboardKey.tab), isTrue);
    await t.pumpAndSettle();
    expect(FocusManager.instance.primaryFocus, same(current));
    expect(await t.sendKeyEvent(LogicalKeyboardKey.escape), isTrue);
    await t.pumpAndSettle();
    expect(origin.hasPrimaryFocus, isTrue);
    await t.pumpWidget(const SizedBox());
    origin.dispose();
    expect(t.takeException(), isNull);
  });
  for (final kind in ['shared-closed', 'shared-leave', 'modal']) {
    testWidgets(
      '$kind sole dialog action consumes closed-loop Tab and preserves explicit leave policy',
      (t) async {
        late BuildContext page;
        final origin = FocusNode(), inside = FocusNode();
        var calls = 0;
        await t.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                page = context;
                return Scaffold(
                  body: TextButton(
                    focusNode: origin,
                    onPressed: () {},
                    child: const Text('Origin'),
                  ),
                );
              },
            ),
          ),
        );
        origin.requestFocus();
        await t.pumpAndSettle();
        final nav = Navigator.of(page, rootNavigator: true);
        Widget action(BuildContext context) => TextButton(
          focusNode: inside,
          autofocus: true,
          onPressed: () {
            calls++;
            Navigator.of(context).pop();
          },
          child: const Text('Done'),
        );
        if (kind == 'modal') {
          showIslandModal<void>(
            context: page,
            builder: (_) => const Text('Body'),
            actions: (context) => [action(context)],
          );
        } else {
          nav.push(
            IslandDialogRoute<void>(
              context: page,
              traversalEdgeBehavior: kind == 'shared-leave'
                  ? TraversalEdgeBehavior.leaveFlutterView
                  : TraversalEdgeBehavior.closedLoop,
              builder: (context) => AlertDialog(
                content: const Text('Body'),
                actions: [action(context)],
              ),
            ),
          );
        }
        await t.pumpAndSettle();
        inside.requestFocus();
        await t.pumpAndSettle();
        expect(inside.hasPrimaryFocus, isTrue);
        final consumed = await t.sendKeyEvent(LogicalKeyboardKey.tab);
        await t.pumpAndSettle();
        if (kind == 'shared-leave') {
          expect(consumed, isFalse);
          nav.pop();
          await t.pumpAndSettle();
        } else {
          expect(consumed, isTrue);
          expect(inside.hasPrimaryFocus, isTrue);
          await t.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
          expect(await t.sendKeyEvent(LogicalKeyboardKey.tab), isTrue);
          await t.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
          await t.pumpAndSettle();
          expect(inside.hasPrimaryFocus, isTrue);
          await t.sendKeyEvent(LogicalKeyboardKey.enter);
          await t.pumpAndSettle();
          expect(calls, 1);
          expect(origin.hasPrimaryFocus, isTrue);
        }
        await t.pumpWidget(const SizedBox());
        inside.dispose();
        origin.dispose();
        expect(t.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'shared public dialog route keeps one subtree through entry reverse reopen and reduced settlement',
    (t) async {
      var reduced = false;
      late StateSetter update;
      late BuildContext page;
      final triggerFocus = FocusNode(), childFocus = FocusNode();
      final edit = TextEditingController(text: 'retained');
      await t.pumpWidget(
        StatefulBuilder(
          builder: (_, set) {
            update = set;
            return MaterialApp(
              theme: IslandTheme.create(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(disableAnimations: reduced),
                child: child!,
              ),
              home: Builder(
                builder: (context) {
                  page = context;
                  return Scaffold(
                    body: IslandButton(
                      focusNode: triggerFocus,
                      onPressed: () {},
                      child: const Text('Trigger'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
      triggerFocus.requestFocus();
      await t.pump();
      final nav = Navigator.of(page, rootNavigator: true);
      for (var run = 0; run < 3; run++) {
        final key = GlobalKey();
        final route = IslandDialogRoute<void>(
          context: page,
          barrierColor: Colors.transparent,
          builder: (_) => AlertDialog(
            content: TextField(
              key: key,
              controller: edit,
              focusNode: childFocus,
              style: const TextStyle(color: Colors.purple),
            ),
            actions: [
              TextButton(onPressed: () => nav.pop(), child: const Text('Done')),
            ],
          ),
        );
        nav.push(route);
        await t.pump();
        final identity = t.state(find.byType(EditableText));
        for (final ms in [0, 16, 40]) {
          await t.pump(Duration(milliseconds: ms));
          opaque(t, find.byType(TextField));
          expect(t.state(find.byType(EditableText)), same(identity));
          expect(
            t.widget<EditableText>(find.byType(EditableText)).style.color,
            Colors.purple,
          );
        }
        childFocus.requestFocus();
        await t.pump();
        if (run == 1) {
          update(() => reduced = true);
          await t.pump();
          await t.pump();
          expect(route.animation!.value, 1);
          expect(childFocus.hasPrimaryFocus, isTrue);
          expect(t.state(find.byType(EditableText)), same(identity));
          update(() => reduced = false);
          await t.pump();
        }
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pump();
        if (run == 2) {
          route.updateReducedMotion(true);
          await t.pump();
          await t.pump();
        } else {
          await t.pump(const Duration(milliseconds: 30));
          if (find.byType(TextField).evaluate().isNotEmpty) {
            opaque(t, find.byType(TextField));
            expect(t.state(find.byType(EditableText)), same(identity));
          }
        }
        await t.pumpAndSettle();
        expect(find.byType(TextField), findsNothing);
        expect(triggerFocus.hasPrimaryFocus, isTrue);
        expect(edit.text, 'retained');
      }
      await t.pumpWidget(const SizedBox());
      edit.dispose();
      childFocus.dispose();
      triggerFocus.dispose();
      expect(t.takeException(), isNull);
    },
  );

  testWidgets(
    'creator can remove only its public dialog route beneath a later route',
    (t) async {
      late BuildContext page;
      await t.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              page = context;
              return const SizedBox();
            },
          ),
        ),
      );
      final nav = Navigator.of(page, rootNavigator: true);
      final route = IslandDialogRoute<void>(
        context: page,
        builder: (_) => const AlertDialog(content: Text('Owned')),
      );
      nav.push(route);
      await t.pump();
      await t.pump(const Duration(milliseconds: 30));
      final later = MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Later')),
      );
      nav.push(later);
      await t.pumpAndSettle();
      nav.removeRoute(route);
      await t.pumpAndSettle();
      expect(later.isCurrent, isTrue);
      expect(find.text('Later'), findsOneWidget);
      nav.pop();
      await t.pumpAndSettle();
      await t.pumpWidget(const SizedBox());
      expect(t.takeException(), isNull);
    },
  );
}
