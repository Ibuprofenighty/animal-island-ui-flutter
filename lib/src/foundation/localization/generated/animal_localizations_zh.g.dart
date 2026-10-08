// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'animal_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AnimalLocalizationsZh extends AnimalLocalizations {
  AnimalLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get cancel => '取消';

  @override
  String get clear => '清空';

  @override
  String get now => '此刻';

  @override
  String get today => '今天';

  @override
  String get copied => '已复制';

  @override
  String get copyFailed => '复制失败';

  @override
  String get loading => '加载中...';

  @override
  String get empty => '暂无数据';

  @override
  String get backToTop => '返回顶部';

  @override
  String get requiredField => '此字段为必填项';

  @override
  String get footerDefaultText => 'Animal Island UI • 温暖呈现';

  @override
  String get dismiss => '关闭';

  @override
  String get selectPlaceholder => '请选择';

  @override
  String get datePickerSinglePlaceholder => '选择日期';

  @override
  String get datePickerRangePlaceholder => '选择日期范围';

  @override
  String get datePickerPreviousYear => '上一年';

  @override
  String get datePickerNextYear => '下一年';

  @override
  String get clearDate => '清除日期';

  @override
  String get timePickerPlaceholder => '选择时间';

  @override
  String get timePickerTitle => '选择时间';

  @override
  String get clearTime => '清除时间';

  @override
  String timePickerWheelValue(int value, String unit) {
    String _temp0 = intl.Intl.selectLogic(unit, {
      'hours': '$value小时',
      'minutes': '$value分钟',
      'seconds': '$value秒',
      'other': '$value',
    });
    return '$_temp0';
  }

  @override
  String get inputClearLabel => '清除输入';

  @override
  String get switchSemanticLabel => '开关';

  @override
  String get selectClearLabel => '清除所选项';

  @override
  String get carouselPreviousSlide => '上一张幻灯片';

  @override
  String get carouselNextSlide => '下一张幻灯片';

  @override
  String carouselSlidePosition(int index, int total) {
    return '第 $index 张，共 $total 张';
  }

  @override
  String get modalConfirm => '确认';

  @override
  String get modalContinue => '继续';

  @override
  String get modalCloseLabel => '关闭对话框';

  @override
  String get modalRouteLabel => '对话框';

  @override
  String get drawerRouteLabel => '抽屉';

  @override
  String get drawerCloseLabel => '关闭抽屉';

  @override
  String get progressLabel => '进度';

  @override
  String get circularProgressLabel => '圆形进度';

  @override
  String get notificationDismissLabel => '关闭通知';

  @override
  String get tableLoadingLabel => '正在加载表格数据';

  @override
  String paginationNavigation(int current, int total) {
    return '第 $current 页，共 $total 页';
  }

  @override
  String get paginationPrevious => '上一页';

  @override
  String get paginationNext => '下一页';

  @override
  String get paginationSkipBackward => '向前跳过五页';

  @override
  String get paginationSkipForward => '向后跳过五页';

  @override
  String paginationPage(int page) {
    return '第 $page 页';
  }

  @override
  String get codeCopyLabel => '复制';

  @override
  String get codeCopySemanticLabel => '复制代码到剪贴板';

  @override
  String get codeCopiedSemanticLabel => '代码已复制到剪贴板';

  @override
  String get codeDefaultLanguage => 'dart';

  @override
  String get tagRemoveLabel => '移除标签';

  @override
  String get imagePreviewCloseLabel => '关闭预览';

  @override
  String get imagePreviewRouteLabel => '图片预览';

  @override
  String imagePreviewSemanticLabel(String label) {
    return '$label，点击预览';
  }

  @override
  String get imagePreviewDefaultSemanticLabel => '预览图片';

  @override
  String get currentTimeLabel => '当前时间';

  @override
  String countdownRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '剩余 $count 秒',
      zero: '时间已结束',
    );
    return '$_temp0';
  }

  @override
  String get countdownUnitDays => '天';

  @override
  String get countdownUnitHours => '时';

  @override
  String get countdownUnitMinutes => '分';

  @override
  String get countdownUnitSeconds => '秒';

  @override
  String get validationEmail => '请输入有效的电子邮件地址';

  @override
  String get validationUrl => '请输入有效的网址';

  @override
  String get validationPattern => '输入内容不符合要求的格式';

  @override
  String validationMinimum(num value) {
    return '数值必须大于或等于 $value';
  }

  @override
  String validationMaximum(num value) {
    return '数值不能大于 $value';
  }

  @override
  String validationLengthMinimum(int minimum) {
    return '长度至少为 $minimum';
  }

  @override
  String validationLengthMaximum(int maximum) {
    return '长度不能超过 $maximum';
  }

  @override
  String validationLengthRange(int minimum, int maximum) {
    return '长度必须介于 $minimum 和 $maximum 之间';
  }

  @override
  String get validationFailure => '验证暂时无法完成';

  @override
  String iconSemanticName(String icon) {
    String _temp0 = intl.Intl.selectLogic(icon, {
      'airplane': '飞机',
      'anchor': '锚',
      'apple': '苹果',
      'balloon': '气球',
      'bear': '熊',
      'bee': '蜜蜂',
      'bell': '铃铛',
      'bicycle': '自行车',
      'bird': '鸟',
      'book': '书',
      'bookmark': '书签',
      'bulb': '灯泡',
      'butterfly': '蝴蝶',
      'cactus': '仙人掌',
      'cake': '蛋糕',
      'calendar': '日历',
      'camera': '相机',
      'candle': '蜡烛',
      'car': '汽车',
      'cart': '购物车',
      'cat': '猫',
      'chat': '聊天',
      'check': '勾选',
      'cherry': '樱桃',
      'clock': '时钟',
      'close': '关闭',
      'cloud': '云',
      'code': '代码',
      'coffee': '咖啡',
      'compass': '指南针',
      'creditCard': '信用卡',
      'dog': '狗',
      'donut': '甜甜圈',
      'download': '下载',
      'edit': '编辑',
      'eye': '眼睛',
      'file': '文件',
      'fish': '鱼',
      'flag': '旗帜',
      'flame': '火焰',
      'flower': '花朵',
      'folder': '文件夹',
      'fox': '狐狸',
      'frog': '青蛙',
      'gift': '礼物',
      'globe': '地球',
      'headphones': '耳机',
      'heart': '爱心',
      'home': '主页',
      'icecream': '冰淇淋',
      'image': '图片',
      'key': '钥匙',
      'ladybug': '瓢虫',
      'lamp': '台灯',
      'leaf': '叶子',
      'lemon': '柠檬',
      'location': '位置',
      'lock': '锁',
      'magnet': '磁铁',
      'mail': '邮件',
      'map': '地图',
      'mic': '麦克风',
      'moon': '月亮',
      'mushroom': '蘑菇',
      'music': '音乐',
      'owl': '猫头鹰',
      'paintbrush': '画笔',
      'pencil': '铅笔',
      'penguin': '企鹅',
      'phone': '电话',
      'play': '播放',
      'plus': '加号',
      'rabbit': '兔子',
      'rainbow': '彩虹',
      'refresh': '刷新',
      'rocket': '火箭',
      'sailboat': '帆船',
      'save': '保存',
      'search': '搜索',
      'settings': '设置',
      'share': '分享',
      'shoppingBag': '购物袋',
      'smile': '微笑',
      'snail': '蜗牛',
      'snowflake': '雪花',
      'star': '星星',
      'strawberry': '草莓',
      'sun': '太阳',
      'tag': '标签',
      'thermometer': '温度计',
      'thumbsUp': '点赞',
      'train': '火车',
      'trash': '垃圾桶',
      'tree': '树',
      'trophy': '奖杯',
      'umbrella': '雨伞',
      'upload': '上传',
      'user': '用户',
      'video': '视频',
      'watermelon': '西瓜',
      'wifi': '无线网络',
      'other': '图标',
    });
    return '$_temp0';
  }
}
