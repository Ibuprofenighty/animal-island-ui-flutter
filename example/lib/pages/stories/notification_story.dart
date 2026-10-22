import 'dart:async';

import 'package:flutter/material.dart';
import 'package:animal_island_ui/animal_island_ui.dart';

import '../../shared/story.dart';

class NotificationStory extends StatefulWidget {
  const NotificationStory({super.key});
  @override
  State<NotificationStory> createState() => _NotificationStoryState();
}

class _NotificationStoryState extends State<NotificationStory> {
  final notifications = IslandNotificationsController();
  final timers = <Timer>[];
  @override
  void dispose() {
    for (final timer in timers) {
      timer.cancel();
    }
    notifications.dispose();
    super.dispose();
  }

  IslandNotificationHandle show(
    String message, {
    String? description,
    IslandNotificationType type = IslandNotificationType.info,
    IslandNotificationPosition position = IslandNotificationPosition.top,
    Duration duration = const Duration(milliseconds: 4500),
    Widget? icon,
    Widget? closeIcon,
    Widget? action,
    VoidCallback? onPressed,
    VoidCallback? onClose,
    Object? id,
  }) => notifications.show(
    IslandNotification(
      message: Text(message),
      description: description == null ? null : Text(description),
      type: type,
      position: position,
      duration: duration,
      icon: icon,
      closeIcon: closeIcon,
      action: action,
      onPressed: onPressed,
      onClose: onClose,
    ),
    id: id,
  );
  Widget button(
    String label,
    VoidCallback action, {
    bool primary = false,
    bool danger = false,
  }) => IslandButton(
    onPressed: action,
    variant: primary ? IslandButtonVariant.primary : IslandButtonVariant.normal,
    danger: danger,
    child: Text(label),
  );
  Widget row(List<Widget> children) =>
      Wrap(spacing: 12, runSpacing: 12, children: children);
  void upload() {
    final handle = show('上传中... 0%', duration: Duration.zero, id: 'upload');
    for (final percent in [50, 100]) {
      timers.add(
        Timer(Duration(milliseconds: percent * 6), () {
          handle.update(
            IslandNotification(
              message: Text(percent == 100 ? '上传完成 100%' : '上传中... 50%'),
              type: percent == 100
                  ? IslandNotificationType.success
                  : IslandNotificationType.info,
              duration: percent == 100
                  ? const Duration(seconds: 3)
                  : Duration.zero,
            ),
          );
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) => IslandNotifications(
    controller: notifications,
    child: StoryPanel(
      title: 'Notification',
      tags: ["命令式", "4 types", "6 positions"],
      children: [
        const Text(
          'Notification 采用命令式 API — 通过控制器调用 show(...) 即可触发，通知挂到视口根容器。',
          style: TextStyle(fontSize: 14, color: Color(0xff7c5734)),
        ),
        const StoryLabel('4 种 type + 字符串简写'),
        row([
          button(
            'success 字符串',
            () => show('保存成功!', type: IslandNotificationType.success),
            primary: true,
          ),
          button('info 字符串', () => show('这是一条普通提示')),
          button(
            'warning 字符串',
            () => show('库存不足,请补充', type: IslandNotificationType.warning),
          ),
          button(
            'error 字符串',
            () => show('网络请求失败', type: IslandNotificationType.error),
            primary: true,
            danger: true,
          ),
        ]),
        const StoryLabel('带 description 描述'),
        row([
          button(
            '升级成功',
            () => show(
              '岛屿升级成功',
              description: '岛屿评价 +1,新访客即将到来。',
              type: IslandNotificationType.success,
            ),
            primary: true,
          ),
          button(
            '系统通知',
            () => show('系统通知', description: '今天有流星雨,记得晚上 8 点去海滩许愿。'),
          ),
          button(
            '库存警告',
            () => show(
              '果实快过期',
              description: '桃子和梨还有 1 天就过期,记得吃掉。',
              type: IslandNotificationType.warning,
            ),
          ),
          button(
            '错误详情',
            () => show(
              '连接失败',
              description: '与服务器断开连接,请检查网络后重试。',
              type: IslandNotificationType.error,
            ),
            primary: true,
            danger: true,
          ),
        ]),
        const StoryLabel('6 个 position'),
        row([
          for (final entry in const {
            IslandNotificationPosition.top: 'top(顶部居中)',
            IslandNotificationPosition.topLeft: 'topLeft(左上)',
            IslandNotificationPosition.topRight: 'topRight(右上)',
            IslandNotificationPosition.bottom: 'bottom(底部居中)',
            IslandNotificationPosition.bottomLeft: 'bottomLeft(左下)',
            IslandNotificationPosition.bottomRight: 'bottomRight(右下)',
          }.entries)
            button(
              entry.value,
              () => show(
                '位置: ${entry.key.name}',
                description: '点击通知本体或操作按钮可以触发 onClick。',
                position: entry.key,
                duration: const Duration(seconds: 3),
              ),
            ),
        ]),
        const StoryLabel('duration 控制自动关闭(秒)'),
        row([
          button(
            'duration=5',
            () => show('5 秒后关闭', duration: const Duration(seconds: 5)),
          ),
          button(
            'duration=10',
            () => show('停留 10 秒', duration: const Duration(seconds: 10)),
          ),
          button(
            'duration=0(不自动关闭)',
            () => show('永不自动关闭(手动 × 关闭)', duration: Duration.zero),
          ),
        ]),
        const StoryLabel('onClick / onClose 回调'),
        row([
          button(
            'onClick 可点击',
            () => show(
              '点击我',
              description: '点击通知本体可触发 onClick',
              type: IslandNotificationType.success,
              onPressed: () => Navigator.of(context, rootNavigator: true).push(
                IslandDialogRoute<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: const Text('通知被点击了!'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            primary: true,
          ),
          button(
            'onClose',
            () => show(
              '观察 console',
              description: '关闭时会调用 onClose',
              duration: const Duration(seconds: 2),
              onClose: () => debugPrint('Notification closed'),
            ),
          ),
        ]),
        const StoryLabel('btn 自定义操作按钮'),
        row([
          button(
            '带 btn 的常驻通知',
            () => show(
              '收到邻居的礼物',
              description: '是否接受?',
              duration: Duration.zero,
              action: IslandButton(
                size: IslandSize.small,
                variant: IslandButtonVariant.primary,
                onPressed: () =>
                    show('已接受礼物', type: IslandNotificationType.success),
                child: const Text('接受'),
              ),
            ),
            primary: true,
          ),
        ]),
        const StoryLabel('custom icon / closeIcon'),
        row([
          button(
            '自定义 icon',
            () => show(
              '自定义 icon',
              description: '替换默认 type 图标',
              icon: const IslandIcon(IslandGlyph.flower, size: 18),
            ),
          ),
          button(
            '自定义 closeIcon',
            () => show(
              '自定义关闭按钮',
              description: '× 替换为文字',
              closeIcon: const Text(
                'CLOSE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ]),
        const StoryLabel('key 更新现有通知(用户关闭后停止后续状态)'),
        row([button('模拟上传进度', upload, primary: true)]),
        const StoryLabel('destroy 全局控制'),
        row([
          button('弹出 3 条', () {
            show('通知 1');
            show('通知 2', type: IslandNotificationType.success);
            show('通知 3', type: IslandNotificationType.warning);
          }),
          button(
            'destroy 关闭全部',
            notifications.dismiss,
            primary: true,
            danger: true,
          ),
          button(
            "destroy('upload') 关闭指定 key",
            () => notifications.dismiss('upload'),
          ),
        ]),
        const StoryCode(
          """final notifications = IslandNotificationsController();
// Install one IslandNotifications(controller: notifications, child: page).
final handle = notifications.show(
  IslandNotification(message: Text('上传中... 0%'), duration: Duration.zero),
  id: 'upload',
);
handle.update(IslandNotification(message: Text('上传完成 100%')));
// Updates after dismissal return false; they cannot revive this handle.
handle.close();
notifications.dismiss(); // all current notifications
// Controller creator disposes it when finished.
notifications.dispose();""",
        ),
        const StoryApi(
          rows: [
            ('message *', '通知标题', 'Widget', '—'),
            ('description', '描述/富内容', 'Widget?', 'null'),
            ('type', '通知配色和默认图标', 'IslandNotificationType', 'info'),
            ('position', '六个视口位置', 'IslandNotificationPosition', 'top'),
            ('duration', '自动关闭延时；零为常驻', 'Duration', '4500ms'),
            ('icon / closeIcon', '图标插槽', 'Widget?', '默认图标 / ×'),
            ('action', '独立操作按钮插槽', 'Widget?', 'null'),
            ('closeLabel', '关闭动作的语义名称', 'String', '关闭'),
            ('onPressed', '点击通知本体', 'VoidCallback?', 'null'),
            ('onDismiss', '开始关闭，立即触发', 'VoidCallback?', 'null'),
            ('onClose', '退场完成后触发', 'VoidCallback?', 'null'),
          ],
        ),
        const StoryLabel('控制器方法', strutStyle: storyCaptionStrut),
        const StoryApi(
          rows: [
            (
              'show(config, id:)',
              '新建或更新同一 ID',
              'IslandNotificationHandle',
              '—',
            ),
            ('handle.update(config)', '更新当前通知；关闭后返回 false', 'bool', '—'),
            ('handle.close()', '关闭这一代通知', 'void', '—'),
            ('dismiss([id])', '关闭指定 ID 或全部当前通知', 'void', '—'),
            ('dispose()', '取消资源；由创建者调用', 'void', '—'),
          ],
        ),
      ],
    ),
  );
}
