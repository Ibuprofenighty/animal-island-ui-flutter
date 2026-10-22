import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'palette_contrast_test.dart' show host, foreground, fill, readable;
import 'readable_motion_test.dart' show opaque;

Finder button(String label) => find.byWidgetPredicate(
  (w) =>
      w is Semantics &&
      w.properties.button == true &&
      w.properties.label == label,
);
Future<Color> pixel(WidgetTester t, GlobalKey key, Offset global) async {
  final render =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final point = render.globalToLocal(global);
  return (await t.runAsync(() async {
    final image = await render.toImage();
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final i = (point.dy.floor() * image.width + point.dx.floor()) * 4;
    final color = Color.fromARGB(
      bytes.getUint8(i + 3),
      bytes.getUint8(i),
      bytes.getUint8(i + 1),
      bytes.getUint8(i + 2),
    );
    image.dispose();
    return color;
  }))!;
}

void main() {
  testWidgets(
    'Input focus border remains visible through first/middle frames in both modes and readonly',
    (t) async {
      for (final brightness in Brightness.values) {
        for (final readonly in [false, true]) {
          final boundary = GlobalKey(), focus = FocusNode();
          await t.pumpWidget(
            host(
              RepaintBoundary(
                key: boundary,
                child: SizedBox(
                  width: 300,
                  child: IslandTextField(
                    label: 'Field',
                    showLabel: false,
                    readOnly: readonly,
                    focusNode: focus,
                  ),
                ),
              ),
              brightness: brightness,
            ),
          );
          await t.pumpAndSettle();
          focus.requestFocus();
          for (final ms in [0, 16, 40, 80, 100]) {
            await t.pump(Duration(milliseconds: ms));
            final rect = t.getRect(find.byType(TextField));
            final color = await pixel(
              t,
              boundary,
              Offset(rect.center.dx, rect.top + .5),
            );
            final background = await pixel(t, boundary, rect.center);
            readable(
              color,
              background,
              minimum: 3,
              reason: 'Input $brightness readonly=$readonly ms=$ms',
            );
          }
          await t.pumpWidget(const SizedBox());
          focus.dispose();
        }
      }
    },
  );
  testWidgets(
    'Avatar overflow and CountUp complete celebration gradient use readable foregrounds',
    (t) async {
      await t.pumpWidget(
        host(
          IslandAvatarGroup(
            maxCount: 1,
            children: const [
              IslandAvatar(child: Text('A')),
              IslandAvatar(child: Text('B')),
            ],
          ),
        ),
      );
      readable(foreground(t, '+1'), fill(t, find.text('+1')));
      await t.pumpWidget(
        host(
          const IslandCountUp(
            end: 1,
            isCounting: true,
            duration: Duration(milliseconds: 1),
            celebration: Text('Done'),
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(milliseconds: 2));
      await t.pump();
      final fg = foreground(t, 'Done');
      final decoration = t
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text('Done'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((w) => w.decoration)
          .whereType<BoxDecoration>()
          .firstWhere((d) => d.gradient != null);
      final colors = (decoration.gradient! as LinearGradient).colors;
      for (var i = 0; i <= 100; i++) {
        readable(fg, Color.lerp(colors.first, colors.last, i / 100)!);
      }
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'Date range placeholder and selected interior hover retain the complete paired surface',
    (t) async {
      await t.pumpWidget(host(const IslandDatePicker.rangeUncontrolled()));
      for (final element in find.text('请选择日期').evaluate()) {
        final p = element.findRenderObject()! as RenderParagraph;
        readable(
          (p.text as TextSpan).style!.color!,
          fill(t, find.byWidget(element.widget)),
        );
      }
      await t.pumpWidget(
        host(
          IslandDatePicker.rangeUncontrolled(
            key: const ValueKey('range'),
            initialValue: DateTimeRange(
              start: DateTime(2026, 8, 10),
              end: DateTime(2026, 8, 20),
            ),
          ),
        ),
      );
      await t.tap(button('选择日期'));
      await t.pumpAndSettle();
      final day = find.descendant(
        of: button('2026年8月15日'),
        matching: find.text('15'),
      );
      final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(t.getCenter(day));
      for (final ms in [0, 16, 80, 200]) {
        await t.pump(Duration(milliseconds: ms));
        final p = t.renderObject<RenderParagraph>(day);
        readable((p.text as TextSpan).style!.color!, fill(t, day));
      }
      await mouse.removePointer();
      await t.pumpWidget(const SizedBox());
      await t.pump();
    },
  );
  testWidgets(
    'Upload progress is readable over arbitrary thumbnail; preview control stays opaque on every route frame',
    (t) async {
      for (final background in [
        Colors.white,
        Colors.black,
        IslandTokens.light.focus,
      ]) {
        await t.pumpWidget(
          host(
            IslandUpload(
              files: [
                IslandUploadFile(
                  id: 'a',
                  name: 'photo',
                  percent: 50,
                  status: IslandUploadStatus.uploading,
                  thumbnailBuilder: (_, _) => SizedBox(
                    width: 84,
                    height: 84,
                    child: ColoredBox(color: background),
                  ),
                ),
              ],
              onChanged: (_) {},
              pickFiles: ({required multiple, required accept}) async => [],
              request: (_) async => null,
              listType: IslandUploadListType.pictureCard,
              tip: const Text('Tip'),
            ),
            brightness: Brightness.dark,
          ),
        );
        await t.pump();
        readable(foreground(t, '50%'), fill(t, find.text('50%')));
        readable(foreground(t, 'Tip'), IslandTokens.dark.paper);
        final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
        await mouse.addPointer(
          location: t.getCenter(find.byKey(const ValueKey('a'))),
        );
        await t.pump();
        await t.tap(button('预览 photo'));
        await t.pump();
        for (final ms in [0, 16, 40, 80, 200]) {
          await t.pump(Duration(milliseconds: ms));
          opaque(t, button('关闭预览'));
        }
        await t.sendKeyEvent(LogicalKeyboardKey.escape);
        await t.pump();
        for (final ms in [16, 40, 80]) {
          await t.pump(Duration(milliseconds: ms));
          if (button('关闭预览').evaluate().isNotEmpty) opaque(t, button('关闭预览'));
        }
        await t.pump(const Duration(milliseconds: 300));
        await mouse.removePointer();
        await t.pumpWidget(const SizedBox());
        await t.pump();
      }
    },
  );
  testWidgets('IconButton tooltip uses opaque first and exit frames', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        IslandIconButton(
          glyph: IslandGlyph.check,
          label: 'Confirm',
          onPressed: () {},
        ),
      ),
    );
    final mouse = await t.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(t.getCenter(find.byType(IslandIconButton)));
    await t.pump();
    for (final ms in [0, 16, 80, 200]) {
      await t.pump(Duration(milliseconds: ms));
      opaque(t, find.text('Confirm'));
    }
    await mouse.moveTo(Offset.zero);
    await t.pump(const Duration(milliseconds: 120));
    if (find.text('Confirm').evaluate().isNotEmpty)
      opaque(t, find.text('Confirm'));
    await mouse.removePointer();
    await t.pumpWidget(const SizedBox());
    await t.pump();
  });
  testWidgets(
    'preview captures local theme and follows local reduced-motion changes without replacing content',
    (t) async {
      for (final initial in [false, true]) {
        var reduced = initial;
        late StateSetter update;
        final previewKey = GlobalKey();
        await t.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(disableAnimations: reduced),
                  child: Theme(
                    data: IslandTheme.create(brightness: Brightness.dark),
                    child: Scaffold(
                      body: IslandUpload.uncontrolled(
                        pickFiles: ({
                          required multiple,
                          required accept,
                        }) async => [],
                        request: (_) async => null,
                        initialFiles: [
                          IslandUploadFile(
                            id: 'local',
                            name: 'local',
                            status: IslandUploadStatus.done,
                            thumbnailBuilder: (context, fit) =>
                                fit == BoxFit.contain
                                ? SizedBox(
                                    width: 200,
                                    height: 80,
                                    child: Material(
                                      child: TextField(
                                        key: previewKey,
                                        decoration: InputDecoration(
                                          labelText:
                                              'preview ${Theme.of(context).brightness.name}',
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: Text('thumb'),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await t.pumpAndSettle();
        await t.tap(button('预览 local'));
        await t.pump();
        await t.pump(const Duration(milliseconds: 16));
        expect(find.text('preview dark'), findsOneWidget);
        final identity = t.state(find.byKey(previewKey));
        await t.enterText(find.byKey(previewKey), 'retained');
        update(() => reduced = true);
        await t.pump();
        await t.pump();
        expect(t.state(find.byKey(previewKey)), same(identity));
        expect(find.text('retained'), findsOneWidget);
        for (final w in t.widgetList<Transform>(
          find.ancestor(
            of: find.byKey(previewKey),
            matching: find.byType(Transform),
          ),
        )) {
          expect(w.transform.storage[13], 0);
        }
        await t.tap(button('关闭预览'));
        await t.pumpAndSettle();
        expect(find.byKey(previewKey), findsNothing);
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      }
    },
  );
  testWidgets(
    'necessary close glyph and Table loading indicator meet graphic contrast in rendered pixels',
    (t) async {
      final boundary = GlobalKey();
      await t.pumpWidget(
        host(
          RepaintBoundary(
            key: boundary,
            child: const IslandIcon(IslandGlyph.close, size: 48),
          ),
        ),
      );
      await t.pumpAndSettle();
      final rect = t.getRect(find.byType(IslandIcon));
      readable(
        await pixel(t, boundary, rect.topLeft + const Offset(24, 24)),
        await pixel(t, boundary, rect.topLeft + const Offset(24, 12)),
        minimum: 3,
      );
      await t.pumpWidget(
        host(
          RepaintBoundary(
            key: boundary,
            child: IslandTable<int>(
              loading: true,
              columns: [
                IslandTableColumn(
                  id: 'n',
                  title: const Text('N'),
                  cellBuilder: (_, n, _) => Text('$n'),
                ),
              ],
              rows: const [1],
              rowKey: (n) => n,
            ),
          ),
        ),
      );
      await t.pump();
      final spinner = find.byWidgetPredicate(
        (w) => w is CustomPaint && w.size == const Size(40, 40),
      );
      expect(spinner, findsOneWidget);
      final area = t.getRect(spinner);
      readable(
        await pixel(t, boundary, area.topLeft + const Offset(20, 4)),
        await pixel(t, boundary, area.center),
        minimum: 3,
      );
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'named IconButton does not repeat its label in tooltip semantics',
    (t) async {
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        host(
          IslandIconButton(
            glyph: IslandGlyph.check,
            label: 'Confirm',
            onPressed: () {},
          ),
        ),
      );
      final data = t.getSemantics(button('Confirm')).getSemanticsData();
      expect(data.label, 'Confirm');
      expect(data.tooltip, isEmpty);
      semantics.dispose();
    },
  );
  testWidgets(
    'Input owns one stable accessible name before editing and after clear',
    (t) async {
      final semantics = t.ensureSemantics();
      await t.pumpWidget(
        host(
          const IslandTextField(label: 'Name', hint: 'Name', allowClear: true),
        ),
      );
      String fieldName() =>
          t.getSemantics(find.byType(EditableText)).getSemanticsData().label;
      expect(fieldName(), 'Name');
      await t.enterText(find.byType(TextField), 'edited');
      await t.pump();
      expect(fieldName(), 'Name');
      await t.tap(button('清空'));
      await t.pump();
      expect(fieldName(), 'Name');
      expect(find.text('edited'), findsNothing);
      semantics.dispose();
    },
  );
}
