/// Mathematical pagination algorithm and window calculation model.
class AnimalPaginationModel {
  /// Solves the sequence of page numbers and ellipsis tokens.
  ///
  /// Returns a list of integers:
  /// - Positive integer: 1-based page number.
  /// - `-1`: Left ellipsis node (jumps backward by 5 pages).
  /// - `-2`: Right ellipsis node (jumps forward by 5 pages).
  static List<int> calculatePageItems({
    required int current,
    required int totalPages,
  }) {
    if (totalPages < 1) {
      throw ArgumentError.value(totalPages, 'totalPages', 'must be positive');
    }
    RangeError.checkValueInInterval(current, 1, totalPages, 'current');
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    if (current <= 4) {
      return [1, 2, 3, 4, 5, -2, totalPages];
    } else if (current >= totalPages - 3) {
      return [
        1,
        -1,
        totalPages - 4,
        totalPages - 3,
        totalPages - 2,
        totalPages - 1,
        totalPages,
      ];
    } else {
      return [1, -1, current - 1, current, current + 1, -2, totalPages];
    }
  }

  /// Computes total pages safely using integer arithmetic.
  ///
  /// Throws [ArgumentError] if [pageSize] is <= 0 or [total] is negative.
  static int calculateTotalPages({required int total, required int pageSize}) {
    if (pageSize <= 0) {
      throw ArgumentError.value(
        pageSize,
        'pageSize',
        'pageSize must be greater than 0',
      );
    }
    if (total < 0) {
      throw ArgumentError.value(total, 'total', 'total must not be negative');
    }
    if (total == 0) return 1;
    return (total - 1) ~/ pageSize + 1;
  }
}
