import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Reference 4.0.0 `Upload.tsx` / `upload.module.less` list and card details.

Widget host(Widget child) => MaterialApp(
  theme: IslandTheme.create(),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 600, child: child),
    ),
  ),
);

Widget upload(
  IslandUploadFile file, {
  IslandUploadListType listType = IslandUploadListType.text,
}) => IslandUpload.uncontrolled(
  key: UniqueKey(),
  pickFiles: ({required multiple, required accept}) async => const [],
  request: (_) async => null,
  listType: listType,
  initialFiles: [file],
);

Widget preview(BuildContext context, BoxFit fit) =>
    const ColoredBox(color: Color(0xffffffff), child: SizedBox.expand());

Finder inUpload(Finder f) =>
    find.descendant(of: find.byType(IslandUpload), matching: f);

Finder action(String label) => find.bySemanticsLabel(label);

Finder icon(IslandGlyph glyph) => inUpload(
  find.byWidgetPredicate((w) => w is IslandIcon && w.glyph == glyph),
);

Finder get card => inUpload(
  find.byWidgetPredicate(
    (w) =>
        w is Container &&
        w.constraints?.maxWidth == 84 &&
        w.decoration is BoxDecoration,
  ),
).first; // the file card precedes the add tile

Future<TestGesture> mouse(WidgetTester t) async {
  final m = await t.createGesture(kind: PointerDeviceKind.mouse);
  await m.addPointer(location: Offset.zero);
  addTearDown(m.removePointer);
  return m;
}

void main() {
  testWidgets('a file without a size shows no size; a known size shows', (
    t,
  ) async {
    await t.pumpWidget(
      host(upload(const IslandUploadFile(id: 'a', name: 'a.png', percent: 46))),
    );
    expect(inUpload(find.textContaining(RegExp(r'\d B$'))), findsNothing);
    expect(inUpload(find.text('0 B')), findsNothing);
    await t.pumpWidget(
      host(
        upload(
          const IslandUploadFile(
            id: 'a',
            name: 'a.png',
            size: 2048,
            status: IslandUploadStatus.done,
            percent: 100,
          ),
        ),
      ),
    );
    expect(inUpload(find.text('2.0 KB')), findsOneWidget);
  });

  testWidgets('row actions sit 12px apart and tint their icon on hover', (
    t,
  ) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          upload(
            const IslandUploadFile(
              id: 'a',
              name: 'a.png',
              size: 3,
              status: IslandUploadStatus.done,
              percent: 100,
              thumbnailBuilder: preview,
            ),
          ),
        ),
      );
      final check = t.getRect(icon(IslandGlyph.check));
      final eye = t.getRect(action('预览 a.png'));
      final close = t.getRect(action('删除 a.png'));
      expect(eye.left - check.right, 12);
      expect(close.left - eye.right, 12);

      Color? disc(String label) =>
          (t
                      .widget<Container>(
                        find
                            .descendant(
                              of: action(label),
                              matching: find.byType(Container),
                            )
                            .first,
                      )
                      .decoration!
                  as BoxDecoration)
              .color;
      Color? glyph(IslandGlyph g) => t
          .widget<IslandIcon>(
            find.descendant(
              of: action(g == IslandGlyph.eye ? '预览 a.png' : '删除 a.png'),
              matching: find.byType(IslandIcon),
            ),
          )
          .color;
      expect(disc('预览 a.png'), isNull, reason: 'transparent at rest');
      expect(glyph(IslandGlyph.eye), isNull, reason: 'inherits at rest');
      final m = await mouse(t);
      await m.moveTo(eye.center);
      await t.pumpAndSettle();
      expect(disc('预览 a.png'), const Color(0x14000000));
      expect(glyph(IslandGlyph.eye), const Color(0xff007e72));
      await m.moveTo(close.center);
      await t.pumpAndSettle();
      expect(disc('删除 a.png'), const Color(0x14000000));
      expect(glyph(IslandGlyph.close), const Color(0xffc64245));
      expect(disc('预览 a.png'), isNull);
    } finally {
      h.dispose();
    }
  });

  testWidgets('picture row thumbnail: 18px file icon centred on cream', (
    t,
  ) async {
    await t.pumpWidget(
      host(
        upload(
          const IslandUploadFile(id: 'a', name: 'a.pdf', size: 3),
          listType: IslandUploadListType.picture,
        ),
      ),
    );
    final file = icon(IslandGlyph.file);
    expect(t.getSize(file), const Size(18, 18));
    final box = find.ancestor(of: file, matching: find.byType(Container)).first;
    expect(t.getSize(box), const Size(30, 30));
    expect(t.getCenter(file), t.getCenter(box));
    expect(
      (t.widget<Container>(box).decoration! as BoxDecoration).color,
      const Color(0xfffffdf7),
    );
  });

  testWidgets('picture-card add tile has a 2px dashed outline', (t) async {
    await t.pumpWidget(
      host(
        IslandUpload.uncontrolled(
          pickFiles: ({required multiple, required accept}) async => const [],
          request: (_) async => null,
          listType: IslandUploadListType.pictureCard,
        ),
      ),
    );
    final paint = t.widget<CustomPaint>(
      inUpload(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              w.foregroundPainter is IslandDashedBorderPainter,
        ),
      ),
    );
    expect(
      (paint.foregroundPainter! as IslandDashedBorderPainter).strokeWidth,
      2,
    );
  });

  testWidgets('card overlay actions: dark discs under white icons', (t) async {
    final h = t.ensureSemantics();
    try {
      await t.pumpWidget(
        host(
          upload(
            const IslandUploadFile(
              id: 'a',
              name: 'a.png',
              status: IslandUploadStatus.done,
              percent: 100,
              thumbnailBuilder: preview,
            ),
            listType: IslandUploadListType.pictureCard,
          ),
        ),
      );
      final m = await mouse(t);
      await m.moveTo(t.getCenter(card));
      await t.pumpAndSettle();
      Container disc(String label) => t.widget<Container>(
        find
            .descendant(of: action(label), matching: find.byType(Container))
            .first,
      );
      Color? fill(String label) =>
          (disc(label).decoration! as BoxDecoration).color;
      IslandIcon mark(String label) => t.widget<IslandIcon>(
        find.descendant(of: action(label), matching: find.byType(IslandIcon)),
      );
      expect(t.getSize(action('预览 a.png')), const Size(18, 18));
      expect(fill('预览 a.png'), const Color(0x73000000));
      expect(mark('预览 a.png').size, 18);
      expect(mark('预览 a.png').color, const Color(0xffffffff));
      expect(fill('删除 a.png'), const Color(0x73000000));
      expect(mark('删除 a.png').size, 16);
      expect(mark('删除 a.png').color, const Color(0xffffffff));
      await m.moveTo(t.getCenter(action('预览 a.png')));
      await t.pumpAndSettle();
      expect(fill('预览 a.png'), const Color(0xa6000000));
    } finally {
      h.dispose();
    }
  });

  testWidgets('card states: stacked spinner, red failure mark, done border', (
    t,
  ) async {
    final h = t.ensureSemantics();
    try {
      Color border() =>
          ((t.widget<Container>(card).decoration! as BoxDecoration).border!
                  as Border)
              .top
              .color;
      await t.pumpWidget(
        host(
          upload(
            const IslandUploadFile(id: 'a', name: 'a.png', percent: 46),
            listType: IslandUploadListType.pictureCard,
          ),
        ),
      );
      final status = find.bySemanticsLabel(RegExp('^上传中 46%'));
      final percent = t.getRect(
        find.descendant(of: status, matching: find.text('46%')),
      );
      final spinner = t.getRect(
        find.descendant(of: status, matching: find.byType(RotationTransition)),
      );
      expect(percent.top - spinner.bottom, 4, reason: 'column, 4px gap');
      expect(percent.center.dx, closeTo(spinner.center.dx, .01));

      await t.pumpWidget(
        host(
          upload(
            const IslandUploadFile(
              id: 'a',
              name: 'a.png',
              status: IslandUploadStatus.error,
              percent: 100,
            ),
            listType: IslandUploadListType.pictureCard,
          ),
        ),
      );
      final failed = t
          .widgetList<IslandIcon>(icon(IslandGlyph.close))
          .where((i) => i.size == 22)
          .single;
      expect(failed.size, 22);
      expect(failed.color, const Color(0xffe05a5a));

      await t.pumpWidget(
        host(
          upload(
            const IslandUploadFile(
              id: 'a',
              name: 'a.png',
              status: IslandUploadStatus.done,
              percent: 100,
            ),
            listType: IslandUploadListType.pictureCard,
          ),
        ),
      );
      expect(border(), const Color(0xffc4b89e));
    } finally {
      h.dispose();
    }
  });
}
