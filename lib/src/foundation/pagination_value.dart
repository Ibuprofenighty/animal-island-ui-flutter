import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// One committed paging value. Components normalize display against their total.
@immutable
class IslandPaginationValue {
  const IslandPaginationValue({this.page = 1, this.pageSize = 10})
    : assert(page >= 1),
      assert(pageSize > 0);
  final int page, pageSize;
  int pageCount(int total) =>
      math.max(1, (math.max(0, total) / pageSize).ceil());
  IslandPaginationValue normalized(int total) => IslandPaginationValue(
    page: page.clamp(1, pageCount(total)),
    pageSize: pageSize,
  );
  int startIndex(int total) =>
      math.min(math.max(0, total), (normalized(total).page - 1) * pageSize);
  int endIndex(int total) =>
      math.min(math.max(0, total), startIndex(total) + pageSize);
  @override
  bool operator ==(Object other) =>
      other is IslandPaginationValue &&
      page == other.page &&
      pageSize == other.pageSize;
  @override
  int get hashCode => Object.hash(page, pageSize);
}
