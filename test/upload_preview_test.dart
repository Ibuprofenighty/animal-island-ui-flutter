import 'dart:ui' show PointerDeviceKind;
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';
import 'package:animal_island_ui/animal_island_upload_platform.dart';

class CountingImage extends XFile {
  CountingImage()
    : super.fromData(
        Uint8List.fromList(
          utf8.encode(
            '<svg xmlns="http://www.w3.org/2000/svg" width="24" height="12"><rect width="24" height="12" fill="#19c8b9"/></svg>',
          ),
        ),
        name: 'synthetic.svg',
        mimeType: 'image/svg+xml',
      );
  int reads = 0;
  @override
  Future<Uint8List> readAsBytes() {
    reads++;
    return super.readAsBytes();
  }
}

Widget host(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 500, child: child)),
);
void main() {
  testWidgets(
    'platform SVG stays unread until accepted and then renders as a preview',
    (t) async {
      final file = CountingImage(), fits = <BoxFit>[];
      final source = await islandUploadSource(file);
      expect(file.reads, 0);
      await t.pumpWidget(
        host(
          IslandUpload.uncontrolled(
            pickFiles: ({required multiple, required accept}) async => [source],
            beforeUpload: (_, _) => null,
            request: (_) async => null,
          ),
        ),
      );
      await t.tap(find.text('点击上传'));
      await t.pumpAndSettle();
      expect(file.reads, 0);
      await t.pumpWidget(
        host(
          IslandUpload.uncontrolled(
            key: const ValueKey('accepted'),
            pickFiles: ({required multiple, required accept}) async => [],
            request: (_) async => null,
            listType: IslandUploadListType.pictureCard,
            initialFiles: [
              IslandUploadFile(
                id: 'svg',
                name: 'synthetic.svg',
                status: IslandUploadStatus.done,
                thumbnailBuilder: (context, fit) {
                  fits.add(fit);
                  return source.thumbnailBuilder!(context, fit);
                },
              ),
            ],
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(file.reads, 1);
      expect(fits, contains(BoxFit.cover));
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(
        location: t.getCenter(find.byKey(const ValueKey('svg'))),
      );
      await t.pumpAndSettle();
      await t.tap(find.bySemanticsLabel('预览 synthetic.svg'));
      await t.pumpAndSettle();
      expect(fits, contains(BoxFit.contain));
      expect(find.bySemanticsLabel('关闭预览'), findsWidgets);
      expect(t.takeException(), isNull);
      await t.tap(
        find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              w.properties.label == '关闭预览' &&
              w.properties.button == true,
        ),
      );
      await t.pumpAndSettle();
      expect(find.bySemanticsLabel('关闭预览'), findsNothing);
    },
  );
  testWidgets(
    'preview disposal removes its own route while retaining another dialog',
    (t) async {
      var visible = true;
      late StateSetter update;
      await t.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, set) {
              update = set;
              return visible
                  ? IslandUpload.uncontrolled(
                      pickFiles: ({required multiple, required accept}) async =>
                          [],
                      request: (_) async => null,
                      initialFiles: [
                        IslandUploadFile(
                          id: 'a',
                          name: 'preview.png',
                          status: IslandUploadStatus.done,
                          thumbnailBuilder: (_, fit) => const SizedBox(
                            width: 80,
                            height: 40,
                            child: ColoredBox(color: Colors.teal),
                          ),
                        ),
                      ],
                    )
                  : const Text('Owner removed');
            },
          ),
        ),
      );
      final context = t.element(find.byType(IslandUpload));
      final navigator = Navigator.of(context);
      await t.tap(find.bySemanticsLabel('预览 preview.png'));
      await t.pumpAndSettle();
      navigator.push(
        DialogRoute<void>(
          context: context,
          builder: (_) => const Dialog(child: Text('Other owner')),
        ),
      );
      await t.pumpAndSettle();
      update(() => visible = false);
      await t.pumpAndSettle();
      expect(find.text('Other owner'), findsOneWidget);
      expect(t.takeException(), isNull);
      navigator.pop();
      await t.pumpAndSettle();
      expect(find.text('Owner removed'), findsOneWidget);
      expect(find.bySemanticsLabel('关闭预览'), findsNothing);
    },
  );
}
