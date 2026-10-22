import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:island_gallery/pages/stories/background_story.dart';

class _SceneProbe extends SingleChildRenderObjectWidget {
  const _SceneProbe({required this.original, required super.child});
  final SingleChildRenderObjectWidget original;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      original.createRenderObject(context);
}

class _PaintWitness extends SingleChildRenderObjectWidget {
  const _PaintWitness({required this.onPaint, required super.child});
  final VoidCallback onPaint;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _PaintObserver(onPaint);
}

class _PaintObserver extends RenderProxyBox {
  _PaintObserver(this.onPaint);
  final VoidCallback onPaint;
  @override
  void paint(PaintingContext context, Offset offset) {
    onPaint();
    super.paint(context, offset);
  }
}

void main() {
  testWidgets(
    'scene culling preserves boundary painting, reversal, resize, scale, input and semantics',
    (t) async {
      t.view.physicalSize = const Size(1280, 720);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: BackgroundStory())),
        ),
      );
      await t.pumpAndSettle();
      final sceneWidgets = find.byWidgetPredicate(
        (w) => w.runtimeType.toString() == '_VisibleScenePreview',
      );
      expect(sceneWidgets, findsNWidgets(2));
      final original = t.widget<SingleChildRenderObjectWidget>(
        sceneWidgets.first,
      );
      final semantics = t.ensureSemantics();
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var paints = 0, clicks = 0, enters = 0, exits = 0;
      final leafKey = GlobalKey();
      var height = 180.0, scale = 1.0;
      Future<void> host({bool inViewport = true}) async {
        final leaf = _SceneProbe(
          original: original,
          child: _PaintWitness(
            onPaint: () => paints++,
            child: SizedBox(
              width: 220,
              height: 120,
              child: MouseRegion(
                onEnter: (_) => enters++,
                onExit: (_) => exits++,
                child: Semantics(
                  key: leafKey,
                  label: 'scene action',
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => clicks++,
                    child: const ColoredBox(
                      color: Colors.orange,
                      child: Center(child: Text('scene')),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        await t.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 300,
                  height: height,
                  child: inViewport
                      ? SingleChildScrollView(
                          controller: scroll,
                          child: Column(
                            children: [
                              const SizedBox(height: 220),
                              Transform.scale(
                                scale: scale,
                                alignment: Alignment.topLeft,
                                child: leaf,
                              ),
                              const SizedBox(height: 800),
                            ],
                          ),
                        )
                      : leaf,
                ),
              ),
            ),
          ),
        );
        await t.pumpAndSettle();
      }

      await host();
      final retainedElement = leafKey.currentContext;
      Future<void> at(double offset, bool visible) async {
        paints = 0;
        scroll.jumpTo(offset);
        t
            .renderObject<_PaintObserver>(find.byType(_PaintWitness))
            .markNeedsPaint();
        await t.pump();
        expect(
          paints > 0,
          visible,
          reason: 'scroll=$offset,scale=$scale,height=$height',
        );
        expect(leafKey.currentContext, same(retainedElement));
        expect(t.getSize(find.byType(_SceneProbe)), const Size(220, 120));
        expect(t.takeException(), isNull);
      }

      // Completely clipped, tiny fractional bottom entry, full visibility, tiny
      // fractional top exit, clipped, and immediate reverse back through both edges.
      for (final sample in <(double, bool)>[
        (0, false),
        (40.25, true),
        (220, true),
        (339.75, true),
        (342, false),
        (339.75, true),
        (220, true),
        (40.25, true),
        (0, false),
      ]) {
        await at(sample.$1, sample.$2);
      }
      await at(220, true);
      expect(
        t.getSemantics(find.byKey(leafKey)).label,
        contains('scene action'),
      );
      final mouse = await t.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: const Offset(500, 500));
      await mouse.moveTo(t.getCenter(find.byKey(leafKey)));
      await t.pump();
      expect(enters, 1);
      await t.tap(find.byKey(leafKey));
      await t.pump();
      expect(clicks, 1);
      await mouse.moveTo(const Offset(500, 500));
      await t.pump();
      expect(exits, 1);
      await mouse.removePointer();
      await at(0, false);
      height = 400;
      await host();
      await at(0, true);
      height = 180;
      scale = 1.25;
      await host();
      await at(40.25, true);
      await at(369.75, true);
      await at(372, false);
      // Device-pixel scaling is a widget binding test, not a real OS-DPI claim.
      t.view.physicalSize = const Size(1600, 900);
      t.view.devicePixelRatio = 1.25;
      await t.pump();
      await at(220, true);
      expect(clicks, 1);
      // No scroll viewport must paint normally rather than hiding the content.
      paints = 0;
      await host(inViewport: false);
      expect(t.takeException(), isNull);
      expect(t.getSize(find.byType(_SceneProbe)), const Size(300, 180));
      expect(paints, greaterThan(0));
      semantics.dispose();
    },
  );
}
