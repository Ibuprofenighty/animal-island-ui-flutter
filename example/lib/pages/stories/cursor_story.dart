import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class CursorStory extends StatelessWidget {
  const CursorStory({super.key});
  Widget box(Widget child) => StoryDemoBox(
    dashed: true,
    padding: const EdgeInsets.all(25),
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 16, height: 25 / 16),
      child: child,
    ),
  );
  Widget nativeButton(String label, double width, {required bool enabled}) =>
      SizedBox(
        width: width,
        height: 25,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: const RoundedRectangleBorder(),
            side: const BorderSide(color: Color(0xff767676), width: 2),
            backgroundColor: const Color(0xfff0f0f0),
            disabledBackgroundColor: const Color(0xfff0f0f0),
            foregroundColor: IslandTokens.light.ink,
            disabledForegroundColor: IslandTokens.light.muted,
            // Bundled metric-compatible Arimo stands in for the UA Arial.
            // It must be the primary family: an unbundled 'Arial' resolves to
            // the host default face before any fallback (test-font boxes in
            // the harness, no Arial on Web), so Latin never reached Arimo.
            textStyle: const TextStyle(
              fontFamily: 'IslandGalleryControls',
              fontFamilyFallback: ['IslandGallerySans'],
              fontSize: 13.333333,
              fontWeight: FontWeight.w400,
              height: 1,
            ),
          ),
          onPressed: enabled ? () {} : null,
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.visible,
          ),
        ),
      );
  Widget intro(BuildContext context) {
    // UA monospace `<code>`: 13/16 of the inherited 14px label size.
    final code = TextStyle(
      fontSize: 14 * 13 / 16,
      fontFamily: IslandTheme.codeFontFamily,
      fontFamilyFallback: DefaultTextStyle.of(context).style.fontFamilyFallback,
    );
    TextSpan c(String text) => TextSpan(text: text, style: code);
    // Reference <p style={labelStyle}> with inline <code> spans.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Cursor 将鼠标光标替换为自定义图标，提供 '),
            c('arrow'),
            const TextSpan(text: '（手指箭头）与 '),
            c('raindrop'),
            const TextSpan(text: '（蓝色雨滴）两种风格。默认 '),
            c('forceAll=true'),
            const TextSpan(text: ' 全覆盖所有后代；'),
            c('forceAll=false'),
            const TextSpan(text: ' 保留子控件的 pointer / text / not-allowed 语义。'),
          ],
        ),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: kTextHeightNone,
          color: IslandTokens.light.muted,
        ),
      ),
    );
  }

  // Reference section root is a `demo-raindrop-zone`: the panel shows the
  // raindrop cursor; each preview IslandCursor keeps its own cursor.
  @override
  Widget build(BuildContext context) => IslandCursor(
    variant: IslandCursorVariant.raindrop,
    child: panel(context),
  );

  Widget panel(BuildContext context) => StoryPanel(
    title: 'Cursor',
    tags: ["光标"],
    children: [
      intro(context),
      const StoryLabel('type="default"（默认）：手指箭头'),
      // Reference flex box: the anonymous text item sits at the start.
      IslandCursor(child: box(const StoryText('鼠标移入此区域将显示自定义光标'))),
      const StoryLabel('type="raindrop"：蓝色雨滴'),
      IslandCursor(
        variant: IslandCursorVariant.raindrop,
        child: box(const StoryText('鼠标移入此区域将显示雨滴光标')),
      ),
      const StoryLabel('forceAll=false：保留原生光标语义'),
      IslandCursor(
        forceAll: false,
        child: box(
          Column(
            spacing: 12,
            children: [
              const StoryText('鼠标移入此区域，交互元素恢复语义光标'),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 97.9375,
                    height: 25,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: const Color(0xff0000ee),
                      ),
                      onPressed: () {},
                      child: const Text(
                        '链接 (pointer)',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        strutStyle: StrutStyle(
                          fontSize: 16,
                          height: 25 / 16,
                          forceStrutHeight: true,
                        ),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  nativeButton('按钮 (pointer)', 96, enabled: true),
                  MouseRegion(
                    cursor: SystemMouseCursors.forbidden,
                    child: nativeButton(
                      '禁用 (not-allowed)',
                      123.421875,
                      enabled: false,
                    ),
                  ),
                  SizedBox(
                    width: 189,
                    height: 27,
                    child: TextField(
                      style: const TextStyle(
                        fontFamily: 'IslandGalleryControls',
                        fontFamilyFallback: ['IslandGallerySans'],
                        fontSize: 13.333333,
                        height: 15 / 13.333333,
                        color: Color(0xff714821),
                      ),
                      strutStyle: const StrutStyle(
                        fontSize: 13.333333,
                        height: 15 / 13.333333,
                        forceStrutHeight: true,
                      ),
                      decoration: InputDecoration(
                        constraints: const BoxConstraints.tightFor(height: 27),
                        hintText: '输入框 (text)',
                        isDense: true,
                        isCollapsed: false,
                        visualDensity: VisualDensity.standard,
                        hintStyle: TextStyle(
                          fontFamily: 'IslandGalleryControls',
                          fontFamilyFallback: const ['IslandGallerySans'],
                          fontSize: 13.333333,
                          color: IslandTokens.light.muted,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: Color(0xff767676),
                            width: 2,
                          ),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: Color(0xff767676),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(
                            color: IslandTokens.light.focus,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SelectableText(
                    '可选中文本 (默认)',
                    strutStyle: StrutStyle(
                      fontSize: 16,
                      height: 25 / 16,
                      forceStrutHeight: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const StoryCode("""IslandCursor(child: content)
IslandCursor(variant: IslandCursorVariant.raindrop, child: content)
IslandCursor(forceAll: false, child: Column(children: [
  IslandButton(onPressed: action, child: Text('保留 pointer')),
  TextField(), // keeps its text cursor
]))"""),
      const StoryApi(
        rows: [
          ('variant', '手指箭头 / 蓝色雨滴', 'IslandCursorVariant', 'arrow'),
          ('forceAll', '强制覆盖；false 保留子控件光标', 'bool', 'true'),
          ('child *', '保持手势与焦点的子树', 'Widget', '—'),
        ],
      ),
    ],
  );
}
