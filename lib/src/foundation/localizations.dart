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

  /// Name of the page-size button: the size, then the visible
  /// [perPage] text.
  String perPageName(int size) =>
      _zh ? '每页 $size 条，${perPage(size)}' : '$size per page, ${perPage(size)}';
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
  String get noResults => _zh ? '没有找到相关结果' : 'No matching results';

  /// Calendar shortcut to the current day.
  String get today => _zh ? '今天' : 'Today';

  /// Calendar arrow one year back.
  String get previousYear => _zh ? '上一年' : 'Previous year';

  /// Calendar arrow one month back.
  String get previousMonth => _zh ? '上个月' : 'Previous month';

  /// Calendar arrow one month forward.
  String get nextMonth => _zh ? '下个月' : 'Next month';

  /// Calendar arrow one year forward.
  String get nextYear => _zh ? '下一年' : 'Next year';

  /// Calendar month title, `2026年8月` / `August 2026`.
  String monthTitle(int year, int month) =>
      _zh ? '$year年$month月' : '${_months[month - 1]} $year';

  /// Calendar weekday header from Sunday to Saturday.
  List<String> get weekdaysFromSunday => _zh
      ? const ['日', '一', '二', '三', '四', '五', '六']
      : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  /// Calendar day cell name. It starts with the visible [day] number, then
  /// the `YYYY-MM-DD` [date], the number of events covering it and their
  /// distinct non-empty [titles]; [more] says that duplicate titles were
  /// collapsed.
  String calendarDay(
    int day,
    String date,
    int count,
    List<String> titles, {
    bool more = false,
  }) {
    final name = _zh ? '$day 日，$date' : '$day, $date';
    if (count == 0) return name;
    final events = _zh
        ? '$name $count 项事项'
        : '$name, $count ${count == 1 ? 'event' : 'events'}';
    if (titles.isEmpty) return events;
    return _zh
        ? '$events：${titles.join('，')}${more ? ' 等' : ''}'
        : '$events: ${titles.join(', ')}${more ? ' and more' : ''}';
  }

  /// Chart name when the caller gives neither a semantic label nor a title.
  String get chart => _zh ? '统计图表' : 'Chart';

  /// Chart busy status.
  String get chartLoading => _zh ? '正在整理数据…' : 'Preparing data…';

  /// Hover text and accessible name of a chart map region without data.
  String chartRegionNoData(String name) =>
      _zh ? '$name：$noData' : '$name: $noData';

  /// Chart empty state when every legend entry is hidden.
  String get chartAllHidden =>
      _zh ? '所有图例已隐藏' : 'All legend entries are hidden';

  /// Chart hint under [chartAllHidden].
  String get chartAllHiddenHint => _zh
      ? '恢复图例后，即可继续查看统计。'
      : 'Show the legend again to keep reading the chart.';

  /// Chart empty state of a map without region outlines.
  String get chartMissingMap =>
      _zh ? '请提供地图区域轮廓' : 'Provide the map region outlines';

  /// Chart action showing every hidden legend entry.
  String get chartRestoreLegend => _zh ? '恢复全部图例' : 'Show all legend entries';

  /// Chart legend group name.
  String get chartLegend => _zh ? '图例' : 'Legend';

  /// Chart tooltip badge of a locked reading.
  String get chartLocked => _zh ? '已锁定' : 'Locked';

  /// Chart selection bar naming the locked reading.
  String chartLockedReading(String name) => _zh ? '已锁定：$name' : 'Locked: $name';

  /// Chart action releasing the locked reading.
  String get chartUnlock => _zh ? '解除锁定' : 'Unlock';

  /// Chart tooltip hint while a reading is not locked.
  String get chartLockHint => _zh ? '点击锁定读数' : 'Click to lock the reading';

  /// Chart tooltip hint while a reading is locked.
  String get chartUnlockHint =>
      _zh ? '再次点击或按 Esc 解除锁定' : 'Click again or press Esc to unlock';

  /// Chart tooltip share of the drawn total; [percent] is formatted.
  String chartShare(String percent) => _zh ? '占比 $percent%' : 'Share $percent%';

  /// Funnel tooltip rate against the first visible stage.
  String chartOfFirstStage(String percent) =>
      _zh ? '较首阶段 $percent%' : '$percent% of the first stage';

  /// Funnel tooltip rate against the preceding visible stage.
  String chartOfPreviousStage(String percent) =>
      _zh ? '较上阶段 $percent%' : '$percent% of the previous stage';

  /// Ring chart centre caption under the visible total.
  String get chartTotal => _zh ? '合计' : 'Total';

  /// Candle reading from formatted open, close, low and high values.
  String chartCandle(String open, String close, String low, String high) => _zh
      ? '开 $open / 收 $close / 低 $low / 高 $high'
      : 'Open $open / Close $close / Low $low / High $high';

  /// Bubble weight appended to a coordinate reading.
  String chartWeight(String weight) => _zh ? '权重 $weight' : 'Weight $weight';

  /// Name of one chart reading: series, datum name and formatted reading.
  String chartReading(String series, String name, String reading) =>
      _zh ? '$series，$name，$reading' : '$series, $name, $reading';

  /// Chart data table disclosure with its row count.
  String chartViewData(int rows) => _zh ? '查看数据（$rows）' : 'View data ($rows)';

  /// Chart data table caption for the chart named [chart].
  String chartDataCaption(String chart) => _zh ? '$chart数据明细' : '$chart data';

  /// Chart data table column headers: series, item and value.
  List<String> get chartTableHeaders =>
      _zh ? const ['系列', '项目', '数值'] : const ['Series', 'Item', 'Value'];

  /// Word chart note when some words do not fit in the plot.
  String get chartWordsOmitted => _zh
      ? '部分词条未能放入当前绘图区，完整数值可展开查看数据。'
      : 'Some words do not fit in the plot; open the data table for every value.';

  /// Default confirming action of Modal and the picker footers.
  String get ok => _zh ? '确定' : 'OK';

  /// Name of a clear button (Input, Select).
  String get clear => _zh ? '清除' : 'Clear';

  /// BackTop button name.
  String get backToTop => _zh ? '返回顶部' : 'Back to top';

  /// Name of a Badge dot without text.
  String get newMessage => _zh ? '有新消息' : 'New message';

  /// CodeBlock copy button text in its idle, copied and failed states.
  String get copy => _zh ? '复制' : 'Copy';
  String get copied => _zh ? '已复制' : 'Copied';
  String get copyFailed => _zh ? '复制失败' : 'Copy failed';

  /// CodeBlock copy button name in its idle, copied and failed states.
  String get copyCode => _zh ? '复制代码' : 'Copy code';
  String get codeCopied => _zh ? '代码已复制' : 'Code copied';
  String get codeCopyFailed => _zh ? '代码复制失败' : 'Failed to copy code';

  /// DatePicker placeholder, name, range panel name and clear button name.
  String get datePlaceholder => _zh ? '请选择日期' : 'Select date';
  String get dateLabel => _zh ? '选择日期' : 'Choose date';
  String get dateRangeLabel => _zh ? '选择日期范围' : 'Choose date range';
  String get clearDate => _zh ? '清除日期' : 'Clear date';

  /// DatePicker month title, `2026年8月` / `Aug 2026`; the abbreviated month
  /// keeps the panel header as narrow as the Chinese one.
  String monthTitleShort(int year, int month) =>
      _zh ? '$year年$month月' : '${_months[month - 1].substring(0, 3)} $year';

  /// DatePicker year title, `2026年` / `2026`.
  String yearTitle(int year) => _zh ? '$year年' : '$year';

  /// DatePicker decade title from its first year, `2020 - 2029年`.
  String decadeTitle(int start) =>
      _zh ? '$start - ${start + 9}年' : '$start - ${start + 9}';

  /// DatePicker month cell text, `一月` / `Jan`.
  String monthName(int month) => _zh
      ? const [
          '一月',
          '二月',
          '三月',
          '四月',
          '五月',
          '六月',
          '七月',
          '八月',
          '九月',
          '十月',
          '十一月',
          '十二月',
        ][month - 1]
      : _months[month - 1].substring(0, 3);

  /// DatePicker month cell name, `8月` / `August`.
  String monthLabel(int month) => _zh ? '$month月' : _months[month - 1];

  /// DatePicker weekday header from Sunday to Saturday.
  List<String> get weekdaysMin => _zh
      ? const ['日', '一', '二', '三', '四', '五', '六']
      : const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  /// DatePicker day cell name, `2026年8月5日` / `August 5, 2026`.
  String fullDate(int year, int month, int day) =>
      _zh ? '$year年$month月$day日' : '${_months[month - 1]} $day, $year';

  /// TimePicker placeholder, name and clear button name.
  String get timePlaceholder => _zh ? '请选择时间' : 'Select time';
  String get timeLabel => _zh ? '选择时间' : 'Choose time';
  String get clearTime => _zh ? '清除时间' : 'Clear time';

  /// TimePicker column headers.
  String get hour => _zh ? '时' : 'Hour';
  String get minute => _zh ? '分' : 'Min';
  String get second => _zh ? '秒' : 'Sec';

  /// TimePicker shortcut to the current time.
  String get now => _zh ? '此刻' : 'Now';

  /// Select accessible name and placeholder.
  String get select => _zh ? '选择' : 'Select';
  String get selectPlaceholder => _zh ? '请选择' : 'Please select';

  /// Rate group name and the name of the [count]-star choice.
  String get rating => _zh ? '评分' : 'Rating';
  String stars(int count) =>
      _zh ? '$count 星' : '$count ${count == 1 ? 'star' : 'stars'}';

  /// Form marker after the label of an optional item.
  String get optionalMark => _zh ? '（选填）' : ' (optional)';

  /// Form error shown when a validator throws.
  String get validationFailed =>
      _zh ? '暂时无法完成校验' : 'Validation could not be completed';

  /// Upload name, drop-zone hint and button text.
  String get upload => _zh ? '上传文件' : 'Upload file';

  /// Name of the built-in upload trigger: [upload], then its visible
  /// [hint] ([uploadClick] or [uploadDragHint]).
  String uploadName(String hint) =>
      _zh ? '$upload，$hint' : '$upload, ${hint.toLowerCase()}';
  String get uploadDragHint => _zh ? '点击或拖拽文件到这里' : 'Click or drag files here';
  String get uploadClick => _zh ? '点击上传' : 'Click to upload';

  /// Upload file actions and progress names for the file [name].
  String previewFile(String name) => _zh ? '预览 $name' : 'Preview $name';
  String removeFile(String name) => _zh ? '删除 $name' : 'Remove $name';
  String uploadProgress(String name) =>
      _zh ? '$name 上传进度' : '$name upload progress';

  /// Upload file status names.
  String get uploadDone => _zh ? '上传完成' : 'Uploaded';
  String get uploadFailed => _zh ? '上传失败' : 'Upload failed';
  String uploading(int percent) =>
      _zh ? '上传中 $percent%' : 'Uploading $percent%';

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

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
