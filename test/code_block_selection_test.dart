import 'dart:ui' as ui;

import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

// Reference cursor.css: `.animal-cursor ::selection { background: #e9c46a;
// color: #2b2620 }`, and CodeBlock.tsx default ink #e8d5bc.
const _highlight = Color(0xffe9c46a);
const _selectedInk = Color(0xff2b2620);
const _codeInk = Color(0xffe8d5bc);

// `final` keyword, ` ` gap, `value` default ink, `12` literal.
const _code = 'final value = 12;';

Widget _host(GlobalKey boundary, {required bool cursor}) {
  const block = IslandCodeBlock(code: _code, margin: EdgeInsets.zero);
  return MaterialApp(
    theme: IslandTheme.create(),
    home: Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: boundary,
          child: SizedBox(
            width: 480,
            child: cursor ? const IslandCursor(child: block) : block,
          ),
        ),
      ),
    ),
  );
}

RenderEditable _editable(WidgetTester t) =>
    t.state<EditableTextState>(find.byType(EditableText)).renderEditable;

/// Global centre of the glyph at [index].
Offset _glyph(WidgetTester t, int index) {
  final editable = _editable(t);
  final box = editable
      .getBoxesForSelection(
        TextSelection(baseOffset: index, extentOffset: index + 1),
      )
      .single;
  return editable.localToGlobal(box.toRect().center);
}

Future<Map<int, Color>> _inks(
  WidgetTester t,
  GlobalKey boundary,
  List<int> indices,
) async {
  final points = {for (final i in indices) i: _glyph(t, i)};
  return (await t.runAsync(() async {
    final render =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final origin = render.localToGlobal(Offset.zero);
    final image = await render.toImage(pixelRatio: 1);
    final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final result = <int, Color>{};
    for (final MapEntry(:key, :value) in points.entries) {
      final local = value - origin;
      final p = (local.dy.floor() * image.width + local.dx.floor()) * 4;
      result[key] = Color.fromARGB(
        bytes.getUint8(p + 3),
        bytes.getUint8(p),
        bytes.getUint8(p + 1),
        bytes.getUint8(p + 2),
      );
    }
    image.dispose();
    return result;
  }))!;
}

Future<void> _dragSelect(WidgetTester t, int from, int to) async {
  final gesture = await t.startGesture(
    _glyph(t, from) - const Offset(5, 0),
    kind: PointerDeviceKind.mouse,
  );
  await t.pump();
  await gesture.moveTo(_glyph(t, to));
  await t.pump();
  await gesture.up();
  await t.pumpAndSettle();
}

void main() {
  testWidgets(
    'CodeBlock selected code inside an arrow Cursor paints the reference '
    'dark selected ink on the highlight; unselected code keeps its inks',
    (t) async {
      final boundary = GlobalKey();
      await t.pumpWidget(_host(boundary, cursor: true));
      await t.pumpAndSettle();
      final before = await _inks(t, boundary, [1, 7, 14]);
      // Drag over `final val` (indices 0-8).
      await _dragSelect(t, 0, 8);
      final selection = _editable(t).selection!;
      expect(selection.start, 0);
      expect(selection.end, 9);
      final after = await _inks(t, boundary, [1, 5, 7, 14]);
      expect(after[1], _selectedInk, reason: 'selected keyword glyph');
      expect(after[7], _selectedInk, reason: 'selected default-ink glyph');
      expect(after[5], _highlight, reason: 'selected gap shows the highlight');
      expect(after[14], before[14], reason: 'unselected literal keeps its ink');
      expect(before[7], _codeInk);
      expect(before[1], isNot(_selectedInk));

      // A click collapses the selection and restores the code inks.
      await t.tapAt(_glyph(t, 15), kind: PointerDeviceKind.mouse);
      await t.pumpAndSettle();
      expect(_editable(t).selection!.isCollapsed, isTrue);
      expect(await _inks(t, boundary, [1, 7, 14]), before);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'CodeBlock outside a Cursor scope keeps its own inks when selected',
    (t) async {
      final boundary = GlobalKey();
      await t.pumpWidget(_host(boundary, cursor: false));
      await t.pumpAndSettle();
      await _dragSelect(t, 0, 8);
      expect(_editable(t).selection!.end, 9);
      final after = await _inks(t, boundary, [7]);
      expect(after[7], _codeInk);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );

  testWidgets(
    'CodeBlock lines keep the reference 14 x 1.7 pitch with CJK fallback runs',
    (t) async {
      await t.pumpWidget(
        MaterialApp(
          theme: IslandTheme.create(),
          home: const Scaffold(
            body: IslandCodeBlock(
              code: 'a\n# 中文注释 b\nc',
              language: IslandCodeLanguage.shell,
              margin: EdgeInsets.zero,
            ),
          ),
        ),
      );
      await t.pumpAndSettle();
      final editable = _editable(t);
      // The forced strut is the line box for every run, including CJK
      // fallback runs whose own metrics exceed 14 x 1.7 (the test font has
      // none, so the strut itself is the contract here).
      final strut = editable.strutStyle!;
      expect(strut.forceStrutHeight, isTrue);
      expect(strut.fontSize, 14);
      expect(strut.height, 1.7);
      double top(int index) =>
          editable.getLocalRectForCaret(TextPosition(offset: index)).top;
      // Line tops of `a` (0), `#` (2) and `c` (11): one pitch apart.
      final pitch = top(2) - top(0);
      expect(pitch, closeTo(14 * 1.7, .25));
      expect(top(11) - top(2), pitch);
    },
  );
}
