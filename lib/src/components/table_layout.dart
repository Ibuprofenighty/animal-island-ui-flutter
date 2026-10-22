part of 'table.dart';

// The table measures only its explicitly registered cell render boxes. Rows,
// gestures, semantics and opaque widget subtrees keep their existing owners.
class _ColumnGeometry {
  final cells = <_RenderColumnCell>{};
  List<double> widths = [];
  _RenderIntrinsicColumns? owner;
}

class _IntrinsicColumns extends SingleChildRenderObjectWidget {
  const _IntrinsicColumns({
    required this.geometry,
    required this.minimumWidth,
    required this.fixedWidths,
    required this.preferredWidths,
    required super.child,
  });
  final _ColumnGeometry geometry;
  final double minimumWidth;
  final List<double?> fixedWidths, preferredWidths;
  @override
  _RenderIntrinsicColumns createRenderObject(BuildContext context) =>
      _RenderIntrinsicColumns(
        geometry,
        minimumWidth,
        fixedWidths,
        preferredWidths,
      );
  @override
  void updateRenderObject(
    BuildContext context,
    _RenderIntrinsicColumns object,
  ) {
    object.minimumWidth = minimumWidth;
    object.fixedWidths = fixedWidths;
    object.preferredWidths = preferredWidths;
  }
}

class _RenderIntrinsicColumns extends RenderProxyBox {
  _RenderIntrinsicColumns(
    this.geometry,
    this._minimumWidth,
    this._fixedWidths,
    this._preferredWidths,
  ) {
    geometry.owner = this;
  }
  final _ColumnGeometry geometry;
  double _minimumWidth;
  List<double?> _fixedWidths, _preferredWidths;
  set fixedWidths(List<double?> value) {
    if (listEquals(value, _fixedWidths)) return;
    _fixedWidths = value;
    markNeedsLayout();
  }

  set minimumWidth(double value) {
    if (_minimumWidth == value) return;
    _minimumWidth = value;
    markNeedsLayout();
  }

  set preferredWidths(List<double?> value) {
    if (listEquals(value, _preferredWidths)) return;
    _preferredWidths = value;
    markNeedsLayout();
  }

  @override
  void dispose() {
    geometry.owner = null;
    super.dispose();
  }

  @override
  void performLayout() {
    final count = _fixedWidths.length;
    final minima = List<double>.filled(count, 0);
    final maxima = List<double>.filled(count, 0);
    for (final cell in geometry.cells) {
      final index = cell.column;
      // Explicit column widths support constraint-dependent opaque children.
      if (_fixedWidths[index] != null) continue;
      final min = cell.child!.getMinIntrinsicWidth(double.infinity);
      final max = cell.child!.getMaxIntrinsicWidth(double.infinity);
      assert(
        min.isFinite && max.isFinite,
        'Auto Table columns require finite intrinsic widths; supply column.width for constraint-dependent content.',
      );
      minima[index] = math.max(minima[index], min);
      maxima[index] = math.max(maxima[index], max);
    }
    final auto = <int>[];
    var fixed = 0.0, minTotal = 0.0;
    for (var i = 0; i < count; i++) {
      final preferred = _fixedWidths[i];
      if (preferred != null) {
        fixed += preferred;
      } else {
        auto.add(i);
        minTotal += minima[i];
      }
    }
    final width = math.max(_minimumWidth, fixed + minTotal);
    final available = width - fixed;
    final widths = [
      for (var i = 0; i < count; i++) _fixedWidths[i] ?? minima[i],
    ];
    if (auto.isEmpty) {
      if (fixed > 0) {
        for (var i = 0; i < count; i++) widths[i] = width * widths[i] / fixed;
      }
    } else {
      final flexiblePreferred = [
        for (final i in auto)
          if (_preferredWidths[i] != null) i,
      ];
      final unconstrained = [
        for (final i in auto)
          if (_preferredWidths[i] == null) i,
      ];
      final targets = {
        for (final i in flexiblePreferred)
          i: math.max(minima[i], _preferredWidths[i]!),
      };
      final desired = targets.values.fold(0.0, (a, b) => a + b);
      final otherMin = unconstrained.fold(0.0, (sum, i) => sum + minima[i]);
      if (available < desired + otherMin) {
        final demand = flexiblePreferred.fold(
          0.0,
          (sum, i) => sum + targets[i]! - minima[i],
        );
        final fraction = demand == 0 ? 0.0 : (available - minTotal) / demand;
        for (final i in flexiblePreferred) {
          widths[i] = minima[i] + (targets[i]! - minima[i]) * fraction;
        }
      } else {
        for (final i in flexiblePreferred) {
          widths[i] = targets[i]!;
        }
        final recipients = unconstrained.isEmpty
            ? flexiblePreferred
            : unconstrained;
        final remaining = unconstrained.isEmpty
            ? available
            : available - desired;
        final recipientMin = recipients.fold(0.0, (sum, i) => sum + minima[i]);
        final recipientMax = recipients.fold(0.0, (sum, i) => sum + maxima[i]);
        if (remaining >= recipientMax) {
          for (final i in recipients) {
            widths[i] = recipientMax == 0
                ? remaining / recipients.length
                : remaining * maxima[i] / recipientMax;
          }
        } else {
          final fraction =
              (remaining - recipientMin) / (recipientMax - recipientMin);
          for (final i in recipients) {
            widths[i] = minima[i] + (maxima[i] - minima[i]) * fraction;
          }
        }
      }
    }
    final previous = geometry.widths;
    geometry.widths = widths;
    // A child can invalidate its intrinsic size without rebuilding the table.
    // Re-layout every affected cell, including otherwise clean sibling rows.
    invokeLayoutCallback<BoxConstraints>((_) {
      for (final cell in geometry.cells) {
        if (cell.column >= previous.length ||
            previous[cell.column] != widths[cell.column]) {
          cell.markNeedsLayout();
        }
      }
    });
    child!.layout(BoxConstraints.tightFor(width: width), parentUsesSize: true);
    size = constraints.constrain(child!.size);
  }
}

class _IntrinsicColumnCell extends SingleChildRenderObjectWidget {
  const _IntrinsicColumnCell({
    super.key,
    required this.geometry,
    required this.column,
    required super.child,
  });
  final _ColumnGeometry geometry;
  final int column;
  @override
  _RenderColumnCell createRenderObject(BuildContext context) =>
      _RenderColumnCell(geometry, column);
  @override
  void updateRenderObject(BuildContext context, _RenderColumnCell object) {
    object.column = column;
  }
}

class _RenderColumnCell extends RenderProxyBox {
  _RenderColumnCell(this.geometry, this._column);
  final _ColumnGeometry geometry;
  int _column;
  int get column => _column;
  set column(int value) {
    if (_column == value) return;
    _column = value;
    markNeedsLayout();
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    geometry.cells.add(this);
    geometry.owner?.markNeedsLayout();
  }

  @override
  void detach() {
    geometry.cells.remove(this);
    geometry.owner?.markNeedsLayout();
    super.detach();
  }

  @override
  void performLayout() {
    child!.layout(
      constraints.tighten(width: geometry.widths[column]),
      parentUsesSize: true,
    );
    size = child!.size;
  }
}
