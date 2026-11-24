import 'package:flutter/foundation.dart';

/// Language of the month and weekday names produced by date format tokens
/// such as `dddd`, `ddd`, `MMM` and `A`.
enum IslandTimeLocale {
  /// English names (`Monday`, `Jun`, `AM`).
  en,

  /// Simplified Chinese names (`星期一`, `6月`, `上午`).
  zhCn,
}

/// Local wall-clock time without a date or timezone.
@immutable
class IslandTimeValue {
  const IslandTimeValue(this.hour, this.minute, [this.second = 0])
    : assert(hour >= 0 && hour < 24),
      assert(minute >= 0 && minute < 60),
      assert(second >= 0 && second < 60);
  final int hour, minute, second;
  IslandTimeValue copyWith({int? hour, int? minute, int? second}) =>
      IslandTimeValue(
        hour ?? this.hour,
        minute ?? this.minute,
        second ?? this.second,
      );

  /// Formats this time with core date tokens (`HH`, `H`, `hh`, `h`, `mm`,
  /// `m`, `ss`, `s`, `A`, `a`, …); `[text]` renders `text` literally. The
  /// value carries no date: date tokens render the fixed anchor 2000-01-01.
  String format([String pattern = 'HH:mm:ss']) =>
      formatDateTokens(DateTime(2000, 1, 1, hour, minute, second), pattern);
  @override
  bool operator ==(Object other) =>
      other is IslandTimeValue &&
      hour == other.hour &&
      minute == other.minute &&
      second == other.second;
  @override
  int get hashCode => Object.hash(hour, minute, second);
  @override
  String toString() => format();
}

final _formatToken = RegExp(
  r'\[([^\]]+)]|Y{1,4}|M{1,4}|D{1,2}|d{1,4}|H{1,2}|h{1,2}|a|A|m{1,2}|s{1,2}|Z{1,2}|SSS',
);

const _enWeekdays = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];
const _enMonths = [
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
const _zhWeekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
const _zhWeekdaysShort = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
const _zhWeekdaysMin = ['日', '一', '二', '三', '四', '五', '六'];
const _zhMonths = [
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
];

String _zhMeridiem(int hour, int minute) {
  final hm = hour * 100 + minute;
  if (hm < 600) return '凌晨';
  if (hm < 900) return '早上';
  if (hm < 1100) return '上午';
  if (hm < 1300) return '中午';
  if (hm < 1800) return '下午';
  return '晚上';
}

/// Formats [date] with the reference's core date tokens (`YYYY`, `YY`, `M`…
/// `MMMM`, `D`, `DD`, `d`…`dddd`, `H`, `HH`, `h`, `hh`, `a`, `A`, `m`, `mm`,
/// `s`, `ss`, `SSS`, `Z`, `ZZ`) in [locale]; `[text]` renders `text`
/// literally. Plugin-owned tokens (`Q`, `Do`, `L`…) are not expanded, and an
/// unlisted run of a token letter (`Y`, `YYY`) renders the compact zone
/// offset, as the reference formatter does.
String formatDateTokens(
  DateTime date,
  String pattern, {
  IslandTimeLocale locale = IslandTimeLocale.en,
}) {
  String pad(int n, int width) => n.toString().padLeft(width, '0');
  final zh = locale == IslandTimeLocale.zhCn;
  final year = '${date.year}';
  final weekday = date.weekday % 7;
  final month = date.month - 1;
  final offset = date.timeZoneOffset;
  final zone =
      '${offset.isNegative ? '-' : '+'}'
      '${pad(offset.inMinutes.abs() ~/ 60, 2)}:'
      '${pad(offset.inMinutes.abs() % 60, 2)}';
  String meridiem(bool lower) {
    if (zh) return _zhMeridiem(date.hour, date.minute);
    final value = date.hour < 12 ? 'AM' : 'PM';
    return lower ? value.toLowerCase() : value;
  }

  return pattern.replaceAllMapped(_formatToken, (m) {
    if (m[1] != null) return m[1]!;
    return switch (m[0]) {
      'YY' => year.substring(year.length > 2 ? year.length - 2 : 0),
      'YYYY' => pad(date.year, 4),
      'M' => '${date.month}',
      'MM' => pad(date.month, 2),
      'MMM' => zh ? '${date.month}月' : _enMonths[month].substring(0, 3),
      'MMMM' => (zh ? _zhMonths : _enMonths)[month],
      'D' => '${date.day}',
      'DD' => pad(date.day, 2),
      'd' => '$weekday',
      'dd' =>
        zh ? _zhWeekdaysMin[weekday] : _enWeekdays[weekday].substring(0, 2),
      'ddd' =>
        zh ? _zhWeekdaysShort[weekday] : _enWeekdays[weekday].substring(0, 3),
      'dddd' => (zh ? _zhWeekdays : _enWeekdays)[weekday],
      'H' => '${date.hour}',
      'HH' => pad(date.hour, 2),
      'h' => '${date.hour % 12 == 0 ? 12 : date.hour % 12}',
      'hh' => pad(date.hour % 12 == 0 ? 12 : date.hour % 12, 2),
      'a' => meridiem(true),
      'A' => meridiem(false),
      'm' => '${date.minute}',
      'mm' => pad(date.minute, 2),
      's' => '${date.second}',
      'ss' => pad(date.second, 2),
      'SSS' => pad(date.millisecond, 3),
      'Z' => zone,
      _ => zone.replaceFirst(':', ''),
    };
  });
}
