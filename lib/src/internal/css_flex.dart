/// CSS Flexbox 9.7 "Resolving Flexible Lengths" for a shrinking row of
/// `flex-shrink: 1`, `min-width: auto` items: each item starts at its
/// max-content [base] width; when their sum exceeds [available] the
/// overflow is taken from the items in proportion to their bases, and an
/// item that would go below its min-content [floor] freezes there while
/// the rest keep shrinking. Below the summed floors the floors are returned
/// (CSS overflow); the caller decides what to do with that.
List<double> cssShrinkWidths({
  required List<double> base,
  required List<double> floor,
  required double available,
}) {
  assert(base.length == floor.length);
  final count = base.length;
  final widths = [...base];
  if (!available.isFinite ||
      base.fold<double>(0, (a, b) => a + b) <= available) {
    return widths;
  }
  final frozen = List.filled(count, false);
  while (true) {
    final open = [
      for (var i = 0; i < count; i++)
        if (!frozen[i]) i,
    ];
    if (open.isEmpty) break;
    final frozenWidth = [
      for (var i = 0; i < count; i++)
        if (frozen[i]) widths[i],
    ].fold<double>(0, (a, b) => a + b);
    final openBase = open.fold<double>(0, (a, i) => a + base[i]);
    final overflow = openBase + frozenWidth - available;
    if (overflow <= 0 || openBase <= 0) break;
    var violated = false;
    for (final i in open) {
      widths[i] = base[i] - overflow * base[i] / openBase;
      if (widths[i] < floor[i]) {
        widths[i] = floor[i];
        frozen[i] = true;
        violated = true;
      }
    }
    if (!violated) break;
  }
  return widths;
}
