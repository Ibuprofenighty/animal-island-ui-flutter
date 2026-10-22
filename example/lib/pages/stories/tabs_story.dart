import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class TabsStory extends StatefulWidget {
  const TabsStory({super.key});
  @override
  State<TabsStory> createState() => _TabsStoryState();
}

class _TabsStoryState extends State<TabsStory> {
  String active = 'tab1';
  Widget paragraph(String text) => Padding(
    padding: const EdgeInsets.only(top: 14),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Text(text),
    ),
  );
  // Known Gallery leaves declare CJK line-break opportunities explicitly.
  // Flutter paragraph intrinsic minima otherwise treat these dictionary words
  // as indivisible; the public Tabs owner keeps all opaque labels untouched.
  List<IslandTab<String>> get shortItems => [
    IslandTab(
      value: 'a',
      label: const Text('鱼\u200b类', strutStyle: storyCaptionStrut),
      semanticLabel: '鱼类',
      child: paragraph('鲈鱼、鲷鱼...'),
    ),
    IslandTab(
      value: 'b',
      label: const Text('昆\u200b虫', strutStyle: storyCaptionStrut),
      semanticLabel: '昆虫',
      child: paragraph('蝴蝶、瓢虫...'),
    ),
  ];
  Widget box(Widget child, {bool fill = false}) => Container(
    width: fill ? double.infinity : null,
    margin: EdgeInsets.only(top: fill ? 0 : 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xfffaf8f3),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xffe8e2d6)),
    ),
    child: child,
  );
  Widget paragraphs(String first, String second) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(first), const SizedBox(height: 14), Text(second)],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final items = [
      IslandTab(
        value: 'tab1',
        label: const Text(
          '岛\u200b屿\u200b概\u200b况',
          strutStyle: storyCaptionStrut,
        ),
        semanticLabel: '岛屿概况',
        child: paragraphs('这里是一座小岛，环境优美，气候宜人。', '可以钓鱼、捉虫、种植各种植物。'),
      ),
      IslandTab(
        value: 'tab2',
        label: const Text('商\u200b店', strutStyle: storyCaptionStrut),
        semanticLabel: '商店',
        child: paragraphs('狸然超市营业中！', '各种商品应有尽有，价格实惠。'),
      ),
      IslandTab(
        value: 'tab3',
        label: const Text('服\u200b务\u200b台', strutStyle: storyCaptionStrut),
        semanticLabel: '服务台',
        child: paragraphs('欢迎来到服务台！', '可以办理各种服务业务。'),
      ),
    ];
    return StoryPanel(
      title: 'Tab',
      tags: ["基础用法"],
      children: [
        const StoryLabel('shadow 阴影控制'),
        storyRow([
          box(IslandTabs.uncontrolled(items: shortItems, initialValue: 'a')),
          box(
            IslandTabs.uncontrolled(
              items: shortItems,
              initialValue: 'a',
              shadow: false,
            ),
          ),
        ]),
        const StoryLabel('非受控模式', strutStyle: storyCaptionStrut),
        box(
          IslandTabs.uncontrolled(
            items: [
              IslandTab(
                value: 'a',
                label: const Text('鱼\u200b类', strutStyle: storyCaptionStrut),
                semanticLabel: '鱼类',
                child: paragraph('鲈鱼、鲷鱼、河童...'),
              ),
              IslandTab(
                value: 'b',
                label: const Text('昆\u200b虫', strutStyle: storyCaptionStrut),
                semanticLabel: '昆虫',
                child: paragraph('蝴蝶、瓢虫、蜻蜓...'),
              ),
              IslandTab(
                value: 'c',
                label: const Text(
                  '海\u200b洋\u200b生\u200b物',
                  strutStyle: storyCaptionStrut,
                ),
                semanticLabel: '海洋生物',
                child: paragraph('海星、珊瑚、小丑鱼...'),
              ),
            ],
          ),
          fill: true,
        ),
        const StoryLabel('受控模式', strutStyle: storyCaptionStrut),
        box(
          IslandTabs(
            items: items,
            value: active,
            onChanged: (v) => setState(() => active = v),
          ),
          fill: true,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text.rich(
            strutStyle: const StrutStyle(
              fontSize: 13,
              height: 20 / 13,
              forceStrutHeight: true,
            ),
            TextSpan(
              children: [
                const TextSpan(text: '当前选中: '),
                TextSpan(
                  text: items
                      .firstWhere((item) => item.value == active)
                      .semanticLabel,
                  style: TextStyle(
                    color: IslandTokens.light.link,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            style: TextStyle(fontSize: 13, color: IslandTokens.light.muted),
          ),
        ),
        const StoryLabel('leafAnimation 叶子动画控制'),
        storyRow([
          for (final caption in [
            'leafAnimation=true (默认)',
            'leafAnimation=false',
          ])
            box(
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IslandTabs.uncontrolled(items: shortItems),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      caption,
                      strutStyle: StrutStyle(
                        fontSize: 12,
                        height: (caption.contains('默认') ? 18 : 16) / 12,
                        forceStrutHeight: true,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: IslandTokens.light.muted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ]),
        const StoryCode(
          """IslandTabs.uncontrolled(
  items: [
    IslandTab(value: 'one', label: Text('标签一'), child: Text('内容一')),
    IslandTab(value: 'two', label: Text('标签二'), child: Text('内容二')),
  ],
  initialValue: 'one',
)
IslandTabs(items: items, value: active, onChanged: onChanged)
// The reference's deprecated leafAnimation has no visual effect.
// Both legacy demonstration captions above show the same current appearance.""",
        ),
        const StoryApi(
          rows: [
            ('items *', '稳定值、标题和内容', 'List<IslandTab<T>>', '—'),
            ('initialValue', '非受控初始选中', 'T?', '首项'),
            ('value', '受控当前选中；null 不选中', 'T?', '—'),
            ('onChanged', '切换请求', 'ValueChanged<T>?', '—'),
            ('shadow', '选中状态阴影', 'bool', 'true'),
            ('semanticLabel', '无可见标题时的页签组名称', 'String?', '—'),
          ],
        ),
      ],
    );
  }
}
