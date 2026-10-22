import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import 'components_test.dart' show host;

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return ((x > y ? x : y) + 0.05) / ((x > y ? y : x) + 0.05);
}

void main() {
  test('semantic theme contrast budgets light/dark', () {
    final failures = <String>[];
    String hex(Color color) =>
        '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
    for (final (name, t) in [
      ('light', IslandTokens.light),
      ('dark', IslandTokens.dark),
    ]) {
      for (final (role, foreground, background, minimum) in [
        ('ink/paper', t.ink, t.paper, 4.5),
        ('muted/paper', t.muted, t.paper, 4.5),
        ('leaf/onLeaf', t.leaf, t.onLeaf, 4.5),
        ('light.ink/sun', IslandTokens.light.ink, t.sun, 4.5),
        ('outline/paper', t.outline, t.paper, 3.0),
      ]) {
        final actual = contrast(foreground, background);
        if (actual < minimum) {
          failures.add(
            '$name $role ${hex(foreground)}/${hex(background)}: '
            '$actual < $minimum',
          );
        }
      }
    }
    expect(
      failures,
      isEmpty,
      reason:
          'All existing contrast budgets are evaluated; no rounding, '
          'palette substitution, exception or lowered threshold.',
    );
  });
  test('theme extension copy and interpolation preserve roles', () {
    expect(IslandTokens.light.copyWith(leaf: Colors.red).leaf, Colors.red);
    expect(
      IslandTokens.light.lerp(IslandTokens.dark, 1).ink,
      IslandTokens.dark.ink,
    );
  });
  testWidgets('local theme isolation', (t) async {
    Color? left, right;
    await t.pumpWidget(
      host(
        Row(
          children: [
            Theme(
              data: IslandTheme.create(
                tokens: IslandTokens.light.copyWith(leaf: Colors.red),
              ),
              child: Builder(
                builder: (c) {
                  left = IslandTheme.of(c).leaf;
                  return const Text('Local');
                },
              ),
            ),
            Builder(
              builder: (c) {
                right = IslandTheme.of(c).leaf;
                return const Text('Default');
              },
            ),
          ],
        ),
      ),
    );
    expect(left, Colors.red);
    expect(right, IslandTokens.light.leaf);
  });
  testWidgets('locale-layout Chinese defaults and RTL 2x narrow', (t) async {
    t.view.physicalSize = const Size(375, 1400);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    String? close;
    await t.pumpWidget(
      host(
        Builder(
          builder: (c) {
            close = IslandLocalizations.of(c).close;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                IslandButton(
                  child: const Text('一段比较长的操作说明文字'),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                const IslandCard(child: Text('这是一段需要换行展示的说明文字。')),
                IslandRadioGroup<String>(
                  vertical: true,
                  options: const [
                    IslandOption(value: '今天去探索', label: '今天去探索'),
                    IslandOption(value: '明天再出发', label: '明天再出发'),
                  ],
                  value: '今天去探索',
                  onChanged: (_) {},
                ),
                const IslandTextField(
                  label: '来访者姓名',
                  helper: '请填写名字，不会发送到服务器。',
                ),
                const IslandCheckbox(
                  label: '一个比较长的同意选项说明文字',
                  value: false,
                  onChanged: null,
                ),
                IslandTabs(
                  items: const [
                    IslandTab(value: 0, label: Text('今天'), child: SizedBox()),
                    IslandTab(value: 1, label: Text('明天'), child: SizedBox()),
                  ],
                  value: 0,
                  onChanged: (_) {},
                ),
              ],
            );
          },
        ),
        locale: const Locale('zh'),
        rtl: true,
        scale: 2,
        dark: true,
      ),
    );
    await t.pumpAndSettle();
    expect(close, '关闭');
    expect(t.takeException(), isNull);
  });
}
