import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show fill, foreground, readable;

const tagCloseCaptureKey = ValueKey('tag-close-capture');

void main() => registerTagCloseTests();

/// Runs the same public consumption scenarios in widget and real engine tests.
void registerTagCloseTests({
  Future<void> Function(WidgetTester, String)? capture,
}) {
  Widget host(Widget child, Brightness brightness, {bool card = false}) {
    final tokens = brightness == Brightness.dark
        ? IslandTokens.dark
        : IslandTokens.light;
    return RepaintBoundary(
      key: tagCloseCaptureKey,
      child: MaterialApp(
        theme: IslandTheme.create(brightness: brightness),
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(color: tokens.paper),
            alignment: Alignment.center,
            child: card ? IslandCard(child: child) : child,
          ),
        ),
      ),
    );
  }

  testWidgets('Tag close hover pairs its glyph with the actual pale surface', (
    t,
  ) async {
    for (final variant in [
      IslandTagVariant.outlined,
      IslandTagVariant.dashed,
    ]) {
      var closes = 0, parents = 0;
      await t.pumpWidget(
        host(
          IslandTag(
            variant: variant,
            onClose: () => closes++,
            onPressed: () => parents++,
            child: const Text('Retained tag'),
          ),
          Brightness.dark,
        ),
      );
      await t.pumpAndSettle();
      final close = find.bySemanticsLabel('close');
      expect(close, findsOneWidget);
      expect(t.getSize(close), const Size(16, 16));
      readable(foreground(t, '×'), fill(t, find.text('×')), minimum: 3);
      await capture?.call(t, '${variant.name}-dark-default');
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(close));
      await t.pump();
      // A captured witness precedes the oracle so failing platform runs retain it.
      await capture?.call(t, '${variant.name}-dark-hover');
      expect(fill(t, find.text('×')), IslandColorway.neutral.soft);
      readable(
        foreground(t, '×'),
        fill(t, find.text('×')),
        minimum: 3,
        reason: '${variant.name}: close hover on the actual 16px target',
      );
      await mouse.down(t.getCenter(close));
      await t.pump(const Duration(milliseconds: 100));
      await capture?.call(t, '${variant.name}-dark-pressed');
      readable(foreground(t, '×'), fill(t, find.text('×')), minimum: 3);
      await mouse.up();
      await t.pumpAndSettle();
      expect(closes, 1);
      expect(parents, 0);
      expect(find.text('Retained tag'), findsOneWidget);
      await mouse.moveTo(Offset.zero);
      await t.pumpAndSettle();
      await t.sendKeyEvent(LogicalKeyboardKey.tab);
      Focus.of(t.element(find.text('×'))).requestFocus();
      await t.pumpAndSettle();
      expect(Focus.of(t.element(find.text('×'))).hasPrimaryFocus, isTrue);
      await capture?.call(t, '${variant.name}-dark-close-focus');
      for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
        await t.sendKeyEvent(key);
        await t.pumpAndSettle();
      }
      expect(closes, 3);
      expect(parents, 0);
      expect(find.text('Retained tag'), findsOneWidget);
      await mouse.removePointer();
    }
  });

  testWidgets(
    'Tag close color matrix covers every palette variant size and host',
    (t) async {
      var combinations = 0;
      for (final brightness in Brightness.values) {
        for (final card in [false, true]) {
          for (final colorway in IslandColorway.values) {
            for (final variant in IslandTagVariant.values) {
              for (final size in IslandSize.values) {
                await t.pumpWidget(
                  host(
                    IslandTag(
                      colorway: colorway,
                      variant: variant,
                      size: size,
                      onPressed: () {},
                      onClose: () {},
                      child: const Text('Tag'),
                    ),
                    brightness,
                    card: card,
                  ),
                );
                await t.pumpAndSettle();
                final close = find.bySemanticsLabel('close');
                final reason =
                    '$brightness card=$card $colorway $variant $size';
                void check(String state) {
                  readable(
                    foreground(t, '×'),
                    fill(t, find.text('×')),
                    minimum: 3,
                    reason: '$reason $state',
                  );
                  readable(
                    foreground(t, 'Tag'),
                    fill(t, find.text('Tag')),
                    reason: '$reason body $state',
                  );
                }

                check('default');
                final mouse = await t.createGesture(
                  kind: ui.PointerDeviceKind.mouse,
                );
                await mouse.addPointer(location: Offset.zero);
                await mouse.moveTo(t.getCenter(close));
                await t.pump();
                expect(fill(t, find.text('×')), colorway.soft, reason: reason);
                for (final ms in [0, 50, 50, 100]) {
                  await t.pump(Duration(milliseconds: ms));
                  check('hover +$ms ms');
                }
                await mouse.down(t.getCenter(close));
                await t.pump(const Duration(milliseconds: 100));
                check('pressed');
                await mouse.up();
                await mouse.moveTo(Offset.zero);
                await t.pump(const Duration(milliseconds: 50));
                check('reverse');
                await mouse.moveTo(t.getCenter(close));
                await t.pump();
                check('interrupted reverse');
                await mouse.removePointer();
                await t.pumpAndSettle();
                await t.sendKeyEvent(LogicalKeyboardKey.tab);
                final closeFocus = Focus.of(t.element(find.text('×')));
                closeFocus.requestFocus();
                await t.pump();
                expect(closeFocus.hasPrimaryFocus, isTrue, reason: reason);
                expect(t.getSize(close), const Size(16, 16), reason: reason);
                check('keyboard focus');
                combinations++;
              }
            }
          }
        }
      }
      expect(combinations, 624);
    },
  );

  testWidgets(
    'Tag close requests and optional actions preserve opaque children',
    (t) async {
      var disabled = false, closable = true, actionable = true;
      var closes = 0, parents = 0;
      late StateSetter update;
      final childKey = GlobalKey<_OpaqueState>();
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, set) {
              update = set;
              return IslandTag(
                disabled: disabled,
                onPressed: actionable ? () => parents++ : null,
                onClose: closable ? () => closes++ : null,
                child: _Opaque(key: childKey),
              );
            },
          ),
          Brightness.dark,
        ),
      );
      await t.pumpAndSettle();
      final identity = childKey.currentState;
      await t.tap(find.text('Opaque 0'));
      await t.pumpAndSettle();
      expect(find.text('Opaque 1'), findsOneWidget);
      final childFocus = Focus.of(t.element(find.text('Opaque 1')));
      childFocus.requestFocus();
      await t.pumpAndSettle();
      for (final value in [false, true, false, true]) {
        update(() {
          closable = value;
          actionable = value;
        });
        await t.pumpAndSettle();
        expect(childKey.currentState, same(identity));
        expect(childFocus.hasPrimaryFocus, isTrue);
        expect(foreground(t, 'Opaque 1'), Colors.purple);
      }
      await t.tap(find.bySemanticsLabel('close'));
      await t.pumpAndSettle();
      expect(closes, 1);
      expect(parents, 0);
      expect(childKey.currentState, same(identity));
      update(() => disabled = true);
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('close'));
      await t.sendKeyEvent(LogicalKeyboardKey.enter);
      await t.sendKeyEvent(LogicalKeyboardKey.space);
      await t.pumpAndSettle();
      expect(closes, 1);
      expect(parents, 0);
      expect(childKey.currentState, same(identity));
      expect(t.takeException(), isNull);
    },
  );
}

class _Opaque extends StatefulWidget {
  const _Opaque({super.key});
  @override
  State<_Opaque> createState() => _OpaqueState();
}

class _OpaqueState extends State<_Opaque> {
  var count = 0;
  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () => setState(() => count++),
    child: Text('Opaque $count', style: const TextStyle(color: Colors.purple)),
  );
}
