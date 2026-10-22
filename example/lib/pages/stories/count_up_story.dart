import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class CountUpStory extends StatefulWidget {
  const CountUpStory({super.key});
  @override
  State<CountUpStory> createState() => _CountUpStoryState();
}

class _CountUpStoryState extends State<CountUpStory> {
  int scoreRound = 0,
      wood = 0,
      celebrateRound = 0,
      formatRound = 0,
      easingRound = 0;
  double score = 1320, celebrateScore = 2480;
  final level = IslandCountUpController();
  final random = math.Random();
  @override
  void dispose() {
    level.dispose();
    super.dispose();
  }

  double nextScore(double current) {
    const scores = [1320.0, 2480.0, 960.0, 3060.0];
    final next = scores[random.nextInt(scores.length)];
    return next == current
        ? scores[(scores.indexOf(next) + 1) % scores.length]
        : next;
  }

  Widget button(String label, VoidCallback action) => IslandButton(
    size: IslandSize.small,
    onPressed: action,
    child: Text(label),
  );
  Widget replay(VoidCallback action) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: button('重播', action),
  );
  Widget row(List<Widget> children, {double gap = 16}) => Wrap(
    spacing: gap,
    runSpacing: 16,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: children,
  );
  @override
  Widget build(BuildContext context) => StoryPanel(
    title: 'CountUp',
    tags: ["数字滚动", "游戏结算"],
    children: [
      const StoryLabel('游戏结算：从 0 滚到本局总分，结束时庆祝一下'),
      IslandCountUp(
        key: ValueKey('score-$scoreRound'),
        isCounting: true,
        end: score,
        thousandsSeparator: ',',
        suffix: const Text('分'),
        size: IslandSize.large,
        variant: IslandCountUpVariant.island,
        celebrate: true,
      ),
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: button(
          '再来一局',
          () => setState(() {
            score = nextScore(score);
            scoreRound++;
          }),
        ),
      ),
      const StoryLabel('累加计数：每捡一次木头 +15，接着上一个数往上滚'),
      row([
        IslandCountUp(
          isCounting: true,
          start: math.max(0, wood - 15).toDouble(),
          end: wood.toDouble(),
          duration: const Duration(milliseconds: 600),
          suffix: const Text(' 木头'),
        ),
        button('捡到木头 +15', () => setState(() => wood += 15)),
        button('重置', () => setState(() => wood = 0)),
      ]),
      const StoryLabel('庆祝动效：celebrate 开启，传 text 可以放任意文案'),
      row([
        for (final text in [null, '完美！', '当当！'])
          IslandCountUp(
            key: ValueKey('celebrate-$text-$celebrateRound'),
            isCounting: true,
            end: celebrateScore,
            duration: const Duration(milliseconds: 1600),
            suffix: const Text('分'),
            celebrate: true,
            celebration: text == null ? null : Text(text),
          ),
      ], gap: 24),
      replay(
        () => setState(() {
          celebrateScore = nextScore(celebrateScore);
          celebrateRound++;
        }),
      ),
      const StoryLabel('格式化：千分位 / 小数位 / 前后缀', strutStyle: storyCaptionStrut),
      row([
        IslandCountUp(
          key: ValueKey('thousand-$formatRound'),
          isCounting: true,
          end: 1320,
          duration: const Duration(milliseconds: 1500),
          thousandsSeparator: ',',
        ),
        IslandCountUp(
          key: ValueKey('decimal-$formatRound'),
          isCounting: true,
          end: 1320.5,
          duration: const Duration(milliseconds: 1500),
          decimalPlaces: 1,
          thousandsSeparator: ',',
        ),
        IslandCountUp(
          key: ValueKey('prefix-$formatRound'),
          isCounting: true,
          end: 88,
          duration: const Duration(milliseconds: 1500),
          prefix: const Text('¥'),
        ),
        IslandCountUp(
          key: ValueKey('separator-$formatRound'),
          isCounting: true,
          end: 99.9,
          duration: const Duration(milliseconds: 1500),
          decimalPlaces: 1,
          decimalSeparator: ',',
          suffix: const Text('分'),
        ),
      ], gap: 20),
      replay(() => setState(() => formatRound++)),
      const StoryLabel('缓动曲线（同为 2 秒 7890 分）'),
      row([
        for (final curve in [
          Curves.linear,
          Curves.easeOutCubic,
          Curves.easeOutExpo,
        ])
          IslandCountUp(
            key: ValueKey((curve, easingRound)),
            isCounting: true,
            end: 7890,
            curve: curve,
            thousandsSeparator: ',',
          ),
      ], gap: 20),
      replay(() => setState(() => easingRound++)),
      const StoryLabel('尺寸 / 风格 / 边框', strutStyle: storyCaptionStrut),
      row([
        for (final size in IslandSize.values)
          IslandCountUp(
            isCounting: true,
            end: 960,
            duration: const Duration(milliseconds: 1500),
            size: size,
          ),
        const IslandCountUp(
          isCounting: true,
          end: 960,
          duration: Duration(milliseconds: 1500),
          variant: IslandCountUpVariant.island,
        ),
        const IslandCountUp(
          isCounting: true,
          end: 960,
          duration: Duration(milliseconds: 1500),
          variant: IslandCountUpVariant.island,
          bordered: true,
        ),
      ]),
      const StoryLabel('children 渲染函数：接管数字渲染，reset 可交给外部按钮重播'),
      row([
        IslandCountUp(
          isCounting: true,
          end: 86,
          duration: const Duration(milliseconds: 1200),
          controller: level,
          builder: (_, value) => Text('第 ${value.round()} 关'),
        ),
        button('重播本关计数', () => level.reset(0)),
      ]),
      const StoryCode(r"""IslandCountUp(
  isCounting: true,
  end: score,
  duration: Duration(seconds: 2),
  thousandsSeparator: ',',
  suffix: Text('分'),
  size: IslandSize.large,
  variant: IslandCountUpVariant.island,
  celebrate: true,
)
IslandCountUp(
  isCounting: true, start: previous, end: wood,
  duration: Duration(milliseconds: 600), suffix: Text(' 木头'),
)
IslandCountUp(
  controller: level, isCounting: true, end: 86,
  builder: (_, value) => Text('第 ${value.round()} 关'),
)
// A separate button can call level.reset(0)."""),
      const StoryApi(
        rows: [
          ('end * / start', '目标 / 起始数值', 'double', '— / 0'),
          ('duration', '计数时长；0 直接到达', 'Duration', '2 秒'),
          ('isCounting', '暂停/继续；暂停保留进度', 'bool', 'false'),
          ('decimalPlaces', '小数位数', 'int?', '自动'),
          (
            'decimalSeparator / thousandsSeparator',
            '小数点 / 分组符号',
            'String',
            '. / 空',
          ),
          ('curve', '内置或自定义缓动', 'Curve', 'Curves.easeOutCubic'),
          ('updateInterval', '量化展示时间轴', 'Duration', '0'),
          ('prefix / suffix', '不透明的展示前后缀', 'Widget?', '—'),
          (
            'size / variant / bordered',
            '尺寸、风格、边框',
            'IslandSize / IslandCountUpVariant / bool',
            'middle / normal / false',
          ),
          (
            'celebrate / celebration',
            '庆祝效果与可选贴纸',
            'bool / Widget?',
            'false / —',
          ),
          ('onUpdate', '每帧数值通知', 'ValueChanged<double>?', '—'),
          (
            'onComplete',
            '完成通知，可返回重播配置',
            'IslandCountUpRepeat? Function(Duration)?',
            '—',
          ),
          ('controller', '借用的重播命令句柄', 'IslandCountUpController?', '—'),
          ('semanticLabel', '显式语义名称；不从展示子树推断', 'String?', 'null'),
          (
            'builder',
            '仅展示数字的自定义内容',
            'Widget Function(BuildContext,double)?',
            '—',
          ),
        ],
      ),
    ],
  );
}
