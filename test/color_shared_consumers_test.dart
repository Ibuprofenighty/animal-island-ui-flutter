import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show host, foreground, fill, readable;
import 'counter_audit_test.dart' show pixel;

void main() {
  testWidgets(
    'busy owned surface supplies readable nested defaults and preserves extensions',
    (t) async {
      final previous = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = previous);
      for (final brightness in Brightness.values) {
        for (final variant in IslandButtonVariant.values) {
          final node = FocusNode();
          var outerCalls = 0, childCalls = 0;
          double? retainedRadius;
          final data = IslandTheme.create(brightness: brightness);
          await t.pumpWidget(
            MaterialApp(
              theme: data.copyWith(
                extensions: [
                  ...data.extensions.values,
                  const IslandCardTheme(radius: 37),
                ],
              ),
              home: Scaffold(
                backgroundColor: brightness == Brightness.light
                    ? IslandTokens.light.paper
                    : IslandTokens.dark.paper,
                body: Center(
                  child: IslandButton(
                    busy: true,
                    onPressed: () => outerCalls++,
                    child: Builder(
                      builder: (context) {
                        retainedRadius = Theme.of(context)
                            .extension<IslandCardTheme>()
                            ?.radius;
                        return IslandButton(
                          focusNode: node,
                          variant: variant,
                          onPressed: () => childCalls++,
                          child: const Text('Nested busy action'),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
          await t.pump(const Duration(milliseconds: 400));
          expect(retainedRadius, 37);
          void check(String state) => readable(
            foreground(t, 'Nested busy action'),
            fill(t, find.text('Nested busy action')),
            reason: '$brightness/$variant/$state busy-owned nested default',
          );
          check('normal');
          final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(t.getCenter(find.text('Nested busy action')));
          await t.pump();
          await mouse.down(t.getCenter(find.text('Nested busy action')));
          for (final ms in [0, 16, 125, 300]) {
            await t.pump(Duration(milliseconds: ms));
            check('pressed+$ms');
          }
          await mouse.up();
          await t.pump(const Duration(milliseconds: 50));
          check('release');
          expect(childCalls, 1);
          expect(outerCalls, 0);
          node.requestFocus();
          await t.pump();
          expect(node.hasPrimaryFocus, isTrue);
          check('focus');
          await mouse.moveTo(Offset.zero);
          await t.pump(const Duration(milliseconds: 20));
          await mouse.moveTo(t.getCenter(find.text('Nested busy action')));
          await t.pump(const Duration(milliseconds: 200));
          check('interrupted hover');
          await mouse.removePointer();
          await t.pumpWidget(const SizedBox());
          node.dispose();
        }
      }
    },
  );

  testWidgets(
    'Title yellow-green nested actions stay readable across sizes and interrupted hover',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final variant in IslandTitleVariant.values) {
          for (final size in IslandSize.values) {
            for (final recipe in ['text', 'link', 'ghost']) {
              final boundary = GlobalKey(), focus = FocusNode();
              await t.pumpWidget(
                RepaintBoundary(
                  key: boundary,
                  child: host(
                    IslandTitle(
                      palette: IslandPalette.yellowGreen,
                      variant: variant,
                      size: size,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Title text'),
                            IslandButton(
                              focusNode: focus,
                              variant: recipe == 'text'
                                  ? IslandButtonVariant.text
                                  : recipe == 'link'
                                  ? IslandButtonVariant.link
                                  : IslandButtonVariant.primary,
                              ghost: recipe == 'ghost',
                              onPressed: () {},
                              child: const Text('Title action'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    brightness: brightness,
                  ),
                ),
              );
              await t.pumpAndSettle();
              final mouse = await t.createGesture(
                kind: ui.PointerDeviceKind.mouse,
              );
              await mouse.addPointer(location: Offset.zero);
              for (final state in [
                'normal',
                'hover',
                'pressed',
                'release',
                'reverse',
                'focus',
              ]) {
                final center = t.getCenter(find.text('Title action'));
                if (state == 'hover') await mouse.moveTo(center);
                if (state == 'pressed') await mouse.down(center);
                if (state == 'release') await mouse.up();
                if (state == 'reverse') {
                  await mouse.moveTo(Offset.zero);
                  await t.pump(const Duration(milliseconds: 20));
                  await mouse.moveTo(center);
                }
                if (state == 'focus') focus.requestFocus();
                for (final ms in [0, 16, 100, 300]) {
                  await t.pump(Duration(milliseconds: ms));
                  for (final label in ['Title text', 'Title action']) {
                    final rect = t.getRect(find.text(label));
                    final bg = await pixel(
                      t,
                      boundary,
                      Offset(rect.center.dx, rect.top - 2),
                    );
                    readable(
                      foreground(t, label),
                      bg,
                      reason:
                          '$brightness/$variant/$size/$recipe/$state/$ms/$label',
                    );
                  }
                }
              }
              await mouse.removePointer();
              await t.pumpWidget(const SizedBox());
              focus.dispose();
            }
          }
        }
      }
    },
  );
  testWidgets(
    'shared colorway consumers and independent close states retain contrast',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final c in [
          IslandColorway.green,
          IslandColorway.lime,
          IslandColorway.yellowGreen,
        ]) {
          for (final variant in IslandTagVariant.values) {
            var closes = 0, parents = 0;
            await t.pumpWidget(
              host(
                IslandTag(
                  colorway: c,
                  variant: variant,
                  onPressed: () => parents++,
                  onClose: () => closes++,
                  child: const Text('Tag text'),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            Color backing(String text) {
              try {
                return fill(t, find.text(text));
              } on StateError {
                return brightness == Brightness.light
                    ? IslandTokens.light.paper
                    : IslandTokens.dark.paper;
              }
            }

            readable(foreground(t, 'Tag text'), backing('Tag text'));
            final mouse = await t.createGesture(
              kind: ui.PointerDeviceKind.mouse,
            );
            await mouse.addPointer(location: Offset.zero);
            await mouse.moveTo(t.getCenter(find.text('×')));
            await t.pump();
            for (final duration in [0, 16, 100, 250]) {
              await t.pump(Duration(milliseconds: duration));
              readable(
                foreground(t, '×'),
                backing('×'),
                minimum: 3,
                reason: '${c.name}/${variant.name}/$brightness close hover',
              );
            }
            await mouse.down(t.getCenter(find.text('×')));
            await t.pump(const Duration(milliseconds: 50));
            readable(foreground(t, '×'), backing('×'), minimum: 3);
            await mouse.up();
            await t.pumpAndSettle();
            expect(closes, 1);
            expect(parents, 0);
            await mouse.moveTo(Offset.zero);
            await t.pumpAndSettle();
            await t.sendKeyEvent(LogicalKeyboardKey.tab);
            await t.pump();
            readable(foreground(t, '×'), backing('×'), minimum: 3);
            await mouse.removePointer();
          }
          await t.pumpWidget(
            host(
              IslandBadge(text: 'Badge text', color: c),
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
          readable(
            foreground(t, 'Badge text'),
            fill(t, find.text('Badge text')),
          );
          for (final variant in IslandButtonVariant.values) {
            await t.pumpWidget(
              host(
                IslandCard(
                  colorway: c,
                  child: IslandButton(
                    variant: variant,
                    onPressed: () {},
                    child: const Text('Nested action'),
                  ),
                ),
                brightness: brightness,
              ),
            );
            await t.pumpAndSettle();
            final mouse = await t.createGesture(
              kind: ui.PointerDeviceKind.mouse,
            );
            await mouse.addPointer(location: Offset.zero);
            await mouse.moveTo(t.getCenter(find.text('Nested action')));
            await t.pump();
            await mouse.down(t.getCenter(find.text('Nested action')));
            for (final ms in [0, 16, 125, 300]) {
              await t.pump(Duration(milliseconds: ms));
              readable(
                foreground(t, 'Nested action'),
                fill(t, find.text('Nested action')),
                reason: '${c.name}/$variant/$brightness nested press',
              );
            }
            await mouse.up();
            await mouse.moveTo(Offset.zero);
            await t.pump(const Duration(milliseconds: 20));
            await mouse.moveTo(t.getCenter(find.text('Nested action')));
            await t.pump(const Duration(milliseconds: 200));
            readable(
              foreground(t, 'Nested action'),
              fill(t, find.text('Nested action')),
            );
            await mouse.removePointer();
          }
        }
      }
    },
  );
  testWidgets(
    'busy recipe transitions preserve variant styles and paired defaults',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final variant in IslandButtonVariant.values) {
          for (final danger in [false, true]) {
            for (final ghost in [false, true]) {
              Widget sample(bool busy) => host(
                IslandButton(
                  variant: variant,
                  danger: danger,
                  ghost: ghost,
                  busy: busy,
                  onPressed: () {},
                  child: const Text('Busy text'),
                ),
                brightness: brightness,
              );
              await t.pumpWidget(sample(false));
              await t.pump(const Duration(milliseconds: 100));
              for (final busy in [true, false, true]) {
                await t.pumpWidget(sample(busy));
                for (final ms in [0, 16, 90, 300]) {
                  await t.pump(Duration(milliseconds: ms));
                  if (busy) {
                    expect(
                      fill(t, find.text('Busy text')),
                      const Color(0xff0ec4b6),
                    );
                    readable(
                      foreground(t, 'Busy text'),
                      fill(t, find.text('Busy text')),
                      reason:
                          '$variant/$brightness/danger=$danger/ghost=$ghost busy step$ms',
                    );
                  }
                }
              }
            }
          }
        }
      }
      const style = ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(Colors.black),
        backgroundColor: WidgetStatePropertyAll(Colors.white),
      );
      await t.pumpWidget(
        host(
          IslandButton(
            busy: true,
            style: style,
            onPressed: () {},
            child: const Text('Styled'),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 50));
      expect(foreground(t, 'Styled'), Colors.black);
      expect(fill(t, find.text('Styled')), Colors.white);
      await t.pumpWidget(
        host(
          IslandButton(
            busy: true,
            onPressed: () {},
            child: const Text(
              'Opaque override',
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ),
      );
      await t.pump(const Duration(milliseconds: 50));
      expect(foreground(t, 'Opaque override'), Colors.purple);
    },
  );
}
