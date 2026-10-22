import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Only internal action defaults. Application copy always belongs to the host.
@immutable
class IslandLocalizations {
  const IslandLocalizations(this.locale);
  final Locale locale;
  bool get _zh => locale.languageCode == 'zh';
  String get close => _zh ? '关闭' : 'Close';
  String get cancel => _zh ? '取消' : 'Cancel';
  String get confirm => _zh ? '确认' : 'Confirm';
  String get loading => _zh ? '加载中' : 'Loading';
  String get pagination => _zh ? '分页' : 'Pagination';
  String get previousPage => _zh ? '上一页' : 'Previous page';
  String get nextPage => _zh ? '下一页' : 'Next page';
  String pageLabel(int page) => _zh ? '第 $page 页' : 'Page $page';
  String totalItems(int total) => _zh ? '共 $total 条' : '$total items';
  String perPage(int size) => _zh ? '$size 条/页' : '$size / page';
  String get pageSize => _zh ? '选择每页条数' : 'Items per page';
  String get jumpTo => _zh ? '跳至' : 'Go to';
  String get pageSuffix => _zh ? '页' : 'page';
  String get jumpPage => _zh ? '跳转到指定页' : 'Jump to page';
  String get noData => _zh ? '暂无数据' : 'No data';
  String get carousel => _zh ? '轮播图' : 'Carousel';
  String get previousSlide => _zh ? '上一张' : 'Previous slide';
  String get nextSlide => _zh ? '下一张' : 'Next slide';
  String get chooseSlide => _zh ? '选择轮播页' : 'Choose slide';
  String goToSlide(int index) => _zh ? '转到第 $index 张' : 'Go to slide $index';
  String slidePosition(int index, int total) =>
      _zh ? '第 $index 张，共 $total 张' : 'Slide $index of $total';
  String get pauseAutoplay => _zh ? '暂停自动播放' : 'Pause autoplay';
  String get resumeAutoplay => _zh ? '继续自动播放' : 'Resume autoplay';
  String get play => _zh ? '播放' : 'Play';
  String get pause => _zh ? '暂停' : 'Pause';
  String get imageFailed => _zh ? '图片加载失败' : 'Image failed to load';
  String get imagePreview => _zh ? '图片预览' : 'Image preview';
  String get closePreview => _zh ? '关闭预览' : 'Close preview';
  String viewImage(String alt) => _zh ? '查看图片：$alt' : 'View image: $alt';
  static IslandLocalizations of(BuildContext context) =>
      Localizations.of<IslandLocalizations>(context, IslandLocalizations) ??
      const IslandLocalizations(Locale('en'));
  static const supportedLocales = [Locale('en'), Locale('zh')];
  static const LocalizationsDelegate<IslandLocalizations> delegate =
      _IslandDelegate();
  static const delegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

class _IslandDelegate extends LocalizationsDelegate<IslandLocalizations> {
  const _IslandDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);
  @override
  Future<IslandLocalizations> load(Locale locale) =>
      SynchronousFuture(IslandLocalizations(locale));
  @override
  bool shouldReload(_IslandDelegate old) => false;
}
