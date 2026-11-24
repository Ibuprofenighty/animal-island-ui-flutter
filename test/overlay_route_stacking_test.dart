import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Keeps a count so a lost subtree state is visible.
class _Counter extends StatefulWidget {
  const _Counter();
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  var count = 0;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count++),
    child: Text('count $count'),
  );
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  Widget app(Widget Function(BuildContext) body) => MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: IslandLocalizations.delegates,
    supportedLocales: IslandLocalizations.supportedLocales,
    home: IslandDrawerHost(
      child: Scaffold(body: Builder(builder: body)),
    ),
  );

  Widget drawer(Widget Function(BuildContext) child) => IslandDrawer(
    open: true,
    onClose: () {},
    title: const Text('Panel'),
    child: Builder(builder: child),
  );

  Future<void> modal(BuildContext context, String name, {Widget? body}) =>
      showIslandModal<void>(
        context: context,
        title: Text(name),
        builder: (_) => body ?? Text('$name body'),
        actions: (ctx) => [
          IslandButton(
            onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
            child: Text('close $name'),
          ),
        ],
      );

  testWidgets(
    'a Modal opened inside an open Drawer is above it, at any depth, and the Drawer keeps its state',
    (t) async {
      await t.pumpWidget(
        app(
          (_) => drawer(
            (context) => Column(
              children: [
                const _Counter(),
                TextButton(
                  onPressed: () => modal(
                    context,
                    'first',
                    body: Builder(
                      builder: (inner) => TextButton(
                        onPressed: () => modal(inner, 'second'),
                        child: const Text('open second'),
                      ),
                    ),
                  ),
                  child: const Text('open first'),
                ),
              ],
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      await t.tap(find.text('count 0'));
      await t.pump();
      expect(find.text('count 1'), findsOneWidget);

      await t.tap(find.text('open first'));
      await t.pump();
      // Already above the Drawer on the first frame after the push.
      await t.tap(find.text('open second'));
      await t.pumpAndSettle();
      expect(find.text('second body'), findsOneWidget);
      await t.tap(find.text('close second'));
      await t.pumpAndSettle();
      expect(find.text('second body'), findsNothing);
      await t.tap(find.text('close first'));
      await t.pumpAndSettle();
      expect(find.text('open second'), findsNothing);
      // The Drawer is reachable again and never rebuilt its content state.
      await t.tap(find.text('count 1'));
      await t.pump();
      expect(find.text('count 2'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('a foreign dialog route also covers an open Drawer', (t) async {
    await t.pumpWidget(
      app(
        (_) => drawer(
          (context) => TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('dismiss'),
                ),
              ),
            ),
            child: const Text('open dialog'),
          ),
        ),
      ),
    );
    await t.pumpAndSettle();
    await t.tap(find.text('open dialog'));
    await t.pumpAndSettle();
    await t.tap(find.text('dismiss'));
    await t.pumpAndSettle();
    expect(find.text('dismiss'), findsNothing);
    expect(find.text('open dialog'), findsOneWidget);
  });

  testWidgets('Drawers of one route keep their order after a Modal closes', (
    t,
  ) async {
    late BuildContext page;
    await t.pumpWidget(
      app((context) {
        page = context;
        return Stack(
          children: [
            drawer((_) => const Text('outer')),
            IslandDrawer(
              open: true,
              onClose: () {},
              placement: IslandDrawerPlacement.left,
              title: const Text('Later'),
              child: const _Counter(),
            ),
          ],
        );
      }),
    );
    await t.pumpAndSettle();
    modal(page, 'page');
    await t.pumpAndSettle();
    await t.tap(find.text('close page'));
    await t.pumpAndSettle();
    // The Drawer mounted later is still above the earlier one's mask.
    await t.tap(find.text('count 0'));
    await t.pump();
    expect(find.text('count 1'), findsOneWidget);
  });

  testWidgets('BackTop is covered by a Modal barrier', (t) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    late BuildContext page;
    await t.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: IslandLocalizations.delegates,
        supportedLocales: IslandLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              page = context;
              return Stack(
                children: [
                  ListView(
                    controller: controller,
                    children: const [SizedBox(height: 4000)],
                  ),
                  IslandBackTop(controller: controller),
                ],
              );
            },
          ),
        ),
      ),
    );
    controller.jumpTo(1000);
    await t.pumpAndSettle();
    final button = t.getCenter(find.bySemanticsLabel('返回顶部'));
    modal(page, 'page');
    await t.pumpAndSettle();
    // The tap lands on the dismissible barrier, not on BackTop.
    await t.tapAt(button);
    await t.pumpAndSettle();
    expect(find.text('page body'), findsNothing);
    expect(controller.offset, 1000);
    await t.tapAt(button);
    await t.pumpAndSettle();
    expect(controller.offset, 0);
  });
}
