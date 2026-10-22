import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';
import '../../shared/background_preview.dart';

class BackgroundStory extends StatelessWidget {
  const BackgroundStory({super.key});
  static const labels = [
    '奶油色波点（默认）',
    '网格',
    '深绿波点',
    '彩色针糖',
    '甜点街角',
    '咖啡时光',
    '应用粉',
    '紫色',
    '应用蓝',
    '应用黄',
    '应用橙',
    '应用青',
    '应用绿',
    '应用红',
    '青柠绿',
    '黄绿色',
    '棕色',
    '暖桃粉',
    '浅灰波点',
  ];
  Widget _isolatePreview(IslandBackgroundType type, Widget child) {
    // Keep scene vectors in the parent canvas: a new local layer changes a few
    // SVG edge samples at fractional scroll transforms on Windows Impeller.
    if (type == IslandBackgroundType.sweetCorner ||
        type == IslandBackgroundType.coffeeBreak) {
      return _VisibleScenePreview(child: child);
    }
    return RepaintBoundary(child: child);
  }

  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'Background',
    tags: ["19 types · Card pattern base · 2 scene images"],
    children: [
      const StoryLabel('全部类型（dots-* 底色对应 Card pattern-* 系列，hover 预览整站壁纸）'),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final type in IslandBackgroundType.values)
            MouseRegion(
              onEnter: (_) => BackgroundPreview.show(context, type),
              onExit: (_) => BackgroundPreview.show(context, null),
              child: SizedBox(
                width: type.index >= 3 && type.index <= 5 ? 348 : 168,
                height: 120,
                child: _isolatePreview(
                  type,
                  IslandBackground(
                    type: type,
                    sceneScale: type.index == 4 || type.index == 5 ? 2.4 : 1,
                    borderRadius: BorderRadius.circular(14),
                    child: Center(
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: IslandTokens.light.ink,
                          backgroundColor: type.index >= 3 && type.index <= 5
                              ? IslandTokens.light.paper
                              : null,
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              type.referenceName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Opacity(
                              opacity: 1,
                              child: Text(
                                labels[type.index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      const StoryLabel('承载内容（children 渲染在图案之上）'),
      SizedBox(
        height: 180,
        width: double.infinity,
        child: RepaintBoundary(
          child: IslandBackground(
            type: IslandBackgroundType.sprinkles,
            padding: const EdgeInsets.all(24),
            borderRadius: BorderRadius.circular(16),
            child: const Center(
              child: Text(
                '卡片内容、表单、图表都可以放在这里',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff725d42),
                ),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      const StoryCode(
        "const SizedBox(\n  height: 200,\n  child: IslandBackground(\n    type: IslandBackgroundType.sprinkles,\n    padding: EdgeInsets.all(24),\n    child: Text('内容渲染在图案背景之上'),\n  ),\n)",
      ),
      const StoryApi(
        rows: [
          ('type', '背景图案类型', 'IslandBackgroundType', 'cream'),
          ('child', '背景上方的内容', 'Widget?', 'null'),
          ('padding', '内容内边距', 'EdgeInsetsGeometry', 'zero'),
          ('borderRadius', '裁剪圆角', 'BorderRadius', 'zero'),
          ('sceneScale', '场景图缩放', 'double', '1'),
        ],
      ),
    ],
  );
}

/// A fully clipped preview retains its subtree without submitting its scene.
/// Visible previews paint in the existing canvas so subpixel sampling is kept.
class _VisibleScenePreview extends SingleChildRenderObjectWidget {
  const _VisibleScenePreview({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderVisibleScenePreview();
}

class _RenderVisibleScenePreview extends RenderProxyBox {
  @override
  void paint(PaintingContext context, Offset offset) {
    final viewport = RenderAbstractViewport.maybeOf(this);
    if (viewport != null) {
      final bounds = MatrixUtils.transformRect(
        getTransformTo(viewport),
        paintBounds,
      );
      if (bounds.isFinite &&
          !bounds.overlaps(viewport.paintBounds.inflate(1))) {
        return;
      }
    }
    super.paint(context, offset);
  }
}
